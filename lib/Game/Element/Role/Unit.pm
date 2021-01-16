package Game::Element::Role::Unit;

use Modern::Perl "2018";
use Moo::Role;
use MooX::Role qw(LvalueAttribute);
use Types::Standard qw(Int Maybe CodeRef);

with "Game::Element::Role::Element";

has "moving" => (
	is => "rw",
	isa => Int,
	lvalue => 1,
	default => sub { 0 },
);

has "order" => (
	is => "rw",
	isa => Maybe[CodeRef],
	lvalue => 1,
	default => sub { undef },
);

before end_of_turn => sub {
	my ($self, $instance) = @_;
	if (defined $self->order) {
		$self->order->($self, $instance);
	}
};

sub _order_move
{
	my ($self, $instance) = @_;
	if ($self->moving) {
		my $direction = $self->moving / abs($self->moving);
		$self->position += $direction;
		$self->moving -= $direction;
	}
	if (!$self->moving) {
		$self->order = undef;
	}
}

sub order_move
{
	my ($self, $position) = @_;
	die \"Unit is busy"
		if defined $self->order;

	$self->moving = $position - $self->position;
	$self->order = \&_order_move
		if abs($self->moving) > 0;

	return abs($self->moving);
}

sub serialize
{
	my ($self) = @_;

	return {
		id => $self->id,
		position => $self->position,
		idle => defined $self->order ? 0 : 1,
	};
}

1;
