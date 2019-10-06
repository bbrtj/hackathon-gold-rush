package Game::Element::Settlement;

use Modern::Perl "2018";
use Moo;

use Game::Settings;

with "Game::Element::Role::Facility";

sub train_unit
{
	my ($self, $unit) = @_;

	my $pop = $self->population;
	die "Cannot train unit, settlement is empty!"
		if $pop == 0;

	$unit->position($self->position);
	$self->population($pop - 1);

	return $unit;
}

sub end_of_turn
{
	my ($self, $instance) = @_;

	$self->population += $Game::Settings::population_growth->($self->population)
		if $instance->turn % $Game::Settings::population_growth_tick == 0;
}

1;
