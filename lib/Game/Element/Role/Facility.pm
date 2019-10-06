package Game::Element::Role::Facility;

use Modern::Perl "2018";
use Moo::Role;
use MooX::Role qw(LvalueAttribute);
use MooX::Types::MooseLike::Base qw(Int Str);

with "Game::Element::Role::Element";

has "population" => (
	is => "rw",
	isa => Int,
	lvalue => 1,
	default => sub { 0 },
);

sub serialize
{
	my ($self) = @_;

	return {
		id => $self->id,
		position => $self->position,
		population => $self->population,
	};
}

1;
