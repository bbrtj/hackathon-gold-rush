package Game::Element::Role::Mortal;

use Modern::Perl "2018";
use Moo::Role;
use MooX::Role qw(LvalueAttribute);
use Types::Standard qw(Int Bool);
use Game::Settings;

has "age" => (
	is => "rw",
	isa => Int,
	lvalue => 1,
	default => sub { 1 },
);

has 'dead' => (
	is => 'rw',
	isa => Bool,
	default => sub { 0 },
);

before end_of_turn => sub {
	my ($self, $instance) = @_;
	$self->age += 1;
	if ($self->age > $Game::Settings::unit_max_age) {
		$self->set_dead($instance);
	}
};

sub set_dead {
	my ($self, $instance) = @_;
	$self->dead(1);
}

1;
