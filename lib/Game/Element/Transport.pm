package Game::Element::Transport;

use Modern::Perl "2018";
use Moo;
use MooX qw(LvalueAttribute);
use Types::Standard qw(Int);
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
		my $settlement = $instance->settlements->find_by_pos($pos)->[0];
		$settlement->population += $self->population;

		# destroy the unit
		$instance->remove_pseudounit($self->id);
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
