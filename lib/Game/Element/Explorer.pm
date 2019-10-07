package Game::Element::Explorer;

use Modern::Perl "2018";
use Moo;
use List::Util qw(first min);

use aliased "Game::Element::Mine" => "Mine";
use aliased "Game::Element::Settlement" => "Settlement";
use Game::Settings;
with "Game::Element::Role::Unit";

sub _order_settle
{
	my ($self, $instance) = @_;
	$self->_order_move($instance);
	if (!defined $self->order) {
		my $pos = $self->position;
		my %locations = $instance->settlements->get_rel_pos_map($pos)->%*;
		my $minimum = min keys %locations;
		if ($minimum < $Game::Settings::settlement_min_proximity) {
			my $closest = $instance->_get_by_id(settlements => $locations{$minimum}[0]);
			$self->order_move($closest->position);
		} else {
			my $settlement = Settlement->new(position => $pos, population => 1);
			$instance->add_settlement($settlement);

			# destroy the unit
			$instance->remove_explorer($self->id);
		}
	}
}

sub _order_explore
{
	my ($self, $instance) = @_;
	$self->_order_move($instance);
	my @map = $instance->map->@*;
	my $pos = $self->position;
	my $is_mine = defined first { $_ == $pos } @map;
	if ($is_mine && !scalar $instance->mines->find_by_pos($pos)->@*) {
		my $explore_roll = rand();
		if (1 - $explore_roll < $Game::Settings::exploring_success_rate) {
			my $mine = Mine->new(position => $pos);
			$instance->add_mine($mine);
		}
	}
	if (!defined $self->order) {
		my %locations = $instance->settlements->get_rel_pos_map($pos)->%*;
		my $minimum = min keys %locations;
		my $closest = $instance->_get_by_id(settlements => $locations{$minimum}[0]);
		$self->order_move($closest->position);
	}
}

sub order_settle
{
	my ($self, $position, $instance) = @_;

	my %locations = $instance->settlements->get_rel_pos_map($position)->%*;
	my $minimum = min keys %locations;
	die \"Cannot settle due to minimum proximity"
		if $minimum < $Game::Settings::settlement_min_proximity;

	my $ret = $self->order_move($position);
	$self->order = \&_order_settle;

	return $ret;
}

sub order_explore
{
	my ($self, $position) = @_;
	my $ret = $self->order_move($position);
	$self->order = \&_order_explore;

	return $ret || 1;
}

1;
