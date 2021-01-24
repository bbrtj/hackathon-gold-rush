package Status;

use Modern::Perl "2018";
use Moo;
use Types::Standard qw(Bool Str HashRef);

has 'playing' => (
	is => 'ro',
	isa => Bool,
	default => 1,
);

has 'message' => (
	is => 'ro',
	isa => HashRef,
	default => sub { {} },
);

has 'log' => (
	is => 'ro',
	isa => Str,
	lazy => 1,
	default => sub {
		my $self = shift;
		return "Sending: " . ($self->message->{type} // '(no type)');
	},
);

1;
