package Game::Element::Mine;

use Modern::Perl "2018";
use Moo;

use Game::Settings;
with "Game::Element::Role::Facility";

sub end_of_turn
{
	my ($self, $instance) = @_;

	my $miners = 0;
	for my $worker (@{$instance->workers}) {
		$miners += 1
			if !defined $worker->order && $worker->position == $self->position;
	}

	# mine!
	$instance->gold += $Game::Settings::mining->($miners);
}

1;
