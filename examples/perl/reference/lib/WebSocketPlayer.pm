package WebSocketPlayer;

use Modern::Perl "2018";
use Moo;
use Types::Standard qw(ConsumerOf Int HashRef Str ArrayRef);
use Phase::Setup;
use WebSocketStatus;
use Scalar::Util qw(blessed);
use List::Util qw(sum0);
use Logger;

has 'phase' => (
	is => 'rw',
	isa => ConsumerOf[Role::Phase::],
	default => sub { Phase::Setup->new(player => shift) },
);

has 'state' => (
	is => 'rw',
	isa => HashRef,
	default => sub { {} },
);

has 'queue' => (
	is => 'ro',
	isa => ArrayRef,
	default => sub { [] },
);

has 'last_message' => (
	is => 'rw',
	isa => HashRef,
);

sub set_state {
	my ($self, $state) = @_;

	Logger::log('Now on turn ' . $state->{turn});
	$self->state($state);
}

sub say_hello {
	return {
		'type' => 'new_player',
		'name' => 'Perl reference implementation',
	}
}

sub _handle_last {
	my ($self, $message) = @_;

	# player initialization
	if (!defined $message) {
		push $self->queue->@*, {type => 'get_state'};
		return $self->say_hello;
	}

	# exit condition
	if (!$message->{status} && $message->{error} =~ /game ended/i) {
		Logger::log 'Stashed ' . $self->state->{gold} . ' gold pieces total';
		Logger::log 'Built ' . (scalar $self->state->{settlements}->@*) . ' settlements';
		Logger::log 'Discovered ' . (scalar $self->state->{mines}->@*) . ' mines';
		Logger::log 'Total population ' . (sum0 map { $_->{population} } $self->state->{settlements}->@*);
		Logger::log 'Total active miners ' . (sum0 map { $_->{population} } $self->state->{mines}->@*);

		return WebSocketStatus->new(
			playing => 0
		);
	}

	# an error
	if (!$message->{status}) {
		use Data::Dumper; die Dumper($message);
	}

	my %significant = (
		get_state => sub {
			$self->set_state($message->{result})
		}
	);

	my $type = $self->last_message->{type};
	if ($significant{$type}) {
		$significant{$type}->();
	}

	return;
}

sub _handle {
	my ($self) = @_;


	if ($self->queue->@*) {
		return shift $self->queue->@*;
	}

	if ($self->phase->ended) {
		$self->phase($self->phase->next);
	}

	push $self->queue->@*, $self->phase->handle;
	push $self->queue->@*, {type => 'get_state'};
	return $self->_handle;
}

sub handle {
	my ($self, $message) = @_;
	my $answer;

	# handle last message
	$answer = $self->_handle_last($message);

	# figure out next message, if we don't have any
	$answer //= $self->_handle;

	# convert to WebSocketStatus
	if (!blessed $answer) {
		$answer = WebSocketStatus->new(
			message => $answer
		);
	}

	# save next message and send it
	$self->last_message($answer->message);
	return $answer;
}

1;

