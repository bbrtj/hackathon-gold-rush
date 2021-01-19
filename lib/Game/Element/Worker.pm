package Game::Element::Worker;

use Modern::Perl "2018";
use Moo;
use MooX qw(LvalueAttribute);
use Types::Standard qw(Maybe InstanceOf);
use List::Util qw(first);

use Game::Element::Mine;
with "Game::Element::Role::Unit";

has "working" => (
	is => "rw",
	isa => Maybe [InstanceOf ["Game::Element::Mine"]],
	lvalue => 1,
	default => sub { undef },
);

sub _order_work
{
	my ($self, $instance) = @_;
	$self->_order_move($instance);
	if (!defined $self->order) {
		my $mine = $instance->mines->find_by_pos($self->position)->[0];
		$self->working = $mine;
		$mine->population += 1;
	}
}

sub order_work
{
	my ($self, $position) = @_;
	my $ret = $self->order_move($position);
	$self->order = \&_order_work;
	if (defined $self->working) {
		$self->working->population -= 1;
		$self->working = undef;
	}

	return $ret || 1;
}

around serialize => sub {
	my ($orig, $self) = (shift, shift);
	my $ret = $orig->($self, @_);

	$ret->{working} = defined $self->working ? 1 : 0;
	return $ret;
};

1;
