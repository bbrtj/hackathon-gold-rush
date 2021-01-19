package Game::Helpers::HashCollection;

use Modern::Perl "2018";
use Moo;
use Types::Standard qw(Maybe HashRef ConsumerOf Str ArrayRef);

has "type" => (
	is => "ro",
	isa => Maybe [Str],
	required => 1,
);

has "collection" => (
	is => "rw",
	isa => HashRef [ConsumerOf ["Game::Element::Role::Element"]],
	default => sub { {} },
);

has "position_cache" => (
	is => "rw",
	isa => HashRef [ArrayRef [Str]],
	default => sub { {} },
);

sub add
{
	my ($self, $element) = @_;
	die "Wrong argument type"
		if defined $self->type && !$element->isa($self->type);

	push @{$self->position_cache->{$element->position}}, $element->id
		if $element->does("Game::Element::Role::Facility");

	$self->collection->{$element->id} = $element;
}

sub remove
{
	my ($self, $element_id) = @_;
	my $element = delete $self->collection->{$element_id};
	$self->position_cache->{$element->position} =
		[grep { $_ ne $element->id } $self->position_cache->{$element->position} - @*]
		if defined $self->position_cache->{$element->position};
}

sub aref
{
	my ($self) = @_;
	return [values $self->collection->%*];
}

sub href
{
	my ($self) = @_;
	return $self->collection;
}

sub find_by_pos
{
	my ($self, $position) = @_;

	if (defined $self->position_cache->{$position}) {
		my @ids = $self->position_cache->{$position}->@*;
		return [@{$self->collection}{@ids}];
	}
	else {
		return [grep { $_->position == $position } values $self->collection->%*];
	}
}

# only for facilities!
sub get_rel_pos_map
{
	my ($self, $position) = @_;

	my %positions = $self->position_cache->%*;
	return {map { abs($_ - $position) => $positions{$_} } keys %positions};
}

1;
