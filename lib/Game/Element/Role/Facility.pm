package Game::Element::Role::Facility;

use Modern::Perl "2018";
use Moo::Role;

with "Game::Element::Role::Element";

sub serialize
{
	my ($self) = @_;

	return {
		id => $self->id,
		position => $self->position,
	};
}

1;
