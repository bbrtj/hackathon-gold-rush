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
		my %locations = map { abs($_->position - $pos) => $_->id } $instance->settlements->@*;
		if (defined first { $_ < $Game::Settings::settlement_min_proximity } keys %locations) {
			my $minimum = min keys %locations;
			my $closest = $instance->_get_by_id(settlements => $locations{$minimum});
			$self->order_move($closest->position);
		} else {
			my $settlement = Settlement->new(position => $pos, population => 1);
			$instance->add_settlement($settlement);

			# destroy the unit
			$instance->explorers([grep { $_->id ne $self->id } $instance->explorers->@*]);
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
	if ($is_mine && !defined first { $_->position == $pos } $instance->mines->@*) {
		my $explore_roll = rand();
		if (1 - $explore_roll < $Game::Settings::exploring_success_rate) {
			my $mine = Mine->new(position => $pos);
			$instance->add_mine($mine);
		}
	}
	if (!defined $self->order) {
		my %locations = map { abs($_->position - $pos) => $_->id } $instance->settlements->@*;
		my $minimum = min keys %locations;
		my $closest = $instance->_get_by_id(settlements => $locations{$minimum});
		$self->order_move($closest->position);
	}
}

sub order_settle
{
	my ($self, $position, $instance) = @_;

	my %locations = map { abs($_->position - $position) => $_->id } $instance->settlements->@*;
	die \"Cannot settle due to minimum proximity"
		if defined first { $_ < $Game::Settings::settlement_min_proximity } keys %locations;

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
