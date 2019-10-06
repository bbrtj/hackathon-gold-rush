package Game::Element::Transport;

use Modern::Perl "2018";
use Moo;
use MooX qw(LvalueAttribute);
use MooX::Types::MooseLike::Base qw(Int);
use List::Util qw(first);

with "Game::Element::Role::Unit";

has "population" => (
	is => "rw",
	isa => Int,
	lvalue => 1,
);

sub _order_resettle
{
	my ($self, $instance) = @_;
	$self->_order_move($instance);
	if (!defined $self->order) {
		my $pos = $self->position;
		my $settlement = first { $_->position == $pos } $instance->settlements->@*;
		$settlement->population += $self->population;
		# destroy the unit
		$instance->pseudounits([grep { $_->id ne $self->id } $instance->pseudounits->@*]);
	}
}

sub order_resettle
{
	my ($self, $position) = @_;
	my $ret = $self->order_move($position);
	$self->order = \&_order_resettle;

	return $ret;
}

1;
