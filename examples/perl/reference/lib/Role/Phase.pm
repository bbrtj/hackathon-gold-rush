package Role::Phase;

use Modern::Perl;
use Moo::Role;
use Types::Standard qw(InstanceOf);
use Logger;
use Bot::Actions;

has 'player' => (
	is => 'ro',
	isa => InstanceOf [WebSocketPlayer::],
	weak_ref => 1,
);

has 'gold' => (
	is => 'rw',
);

has 'workers' => (
	is => 'rw',
);

has 'explorers' => (
	is => 'rw',
);

has 'settlements' => (
	is => 'rw',
);

has 'mines' => (
	is => 'rw',
);

has 'pseudounits' => (
	is => 'rw',
);

has 'current_queue' => (
	is => 'rw',
);

has 'is_recruitment' => (
	is => 'rw',
);

has 'transported_to' => (
	is => 'ro',
	default => sub { {} }
);

has 'already_settling' => (
	is => 'rw',
	default => 0,
);

around 'handle' => sub {
	my ($orig, $self, @params) = @_;

	my $state = $self->player->state;

	# shallow copying
	$self->gold($state->{gold});
	$self->workers([$state->{workers}->@*]);
	$self->explorers([$state->{explorers}->@*]);
	$self->settlements([sort { $b->{population} <=> $a->{population} } $state->{settlements}->@*]);
	$self->mines([sort { $a->{population} <=> $b->{population} } $state->{mines}->@*]);
	$self->pseudounits([$state->{pseudounits}->@*]);

	$self->current_queue([]);

	$orig->($self, @params);

	# we can't return nothing or the program will hang
	if ($self->current_queue->@* == 0 && $self->is_recruitment) {
		$self->is_recruitment(!$self->is_recruitment);
		$orig->($self, @params);
	}

	# two stages: recruitment and orders. We end turn after orders
	if(!$self->is_recruitment) {
		Bot::Actions->end_turn($self);
	}

	$self->is_recruitment(!$self->is_recruitment);

	return $self->current_queue->@*;
};

sub add_order {
	my ($self, $type, %params) = @_;

	push $self->current_queue->@*, {
		type => $type,
		%params
	};
}

sub next {
	my ($self) = @_;

	Logger::log('Moving to phase ' . $self->next_phase);
	return $self->next_phase->new(player => $self->player);
}

requires qw (
	handle
	ended
);

1;
