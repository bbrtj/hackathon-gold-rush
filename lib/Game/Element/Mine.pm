package Game::Element::Mine;

use Modern::Perl "2018";
use Moo;

use Game::Settings;
with "Game::Element::Role::Facility";

sub end_of_turn
{
	my ($self, $instance) = @_;

	# mine!
	$instance->gold += $Game::Settings::mining->($self->population);
}

1;
