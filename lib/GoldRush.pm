package GoldRush;

our $VERSION = "0.02";

use Modern::Perl "2018";
use parent 'Kelp';
use Router;

sub build
{
	my ($self) = @_;
	my $r = $self->routes;

	$r->add('/', {
		method => 'GET',
		to => sub {
			return "GoldRush game version $VERSION";
		},
	});

	Router::install_routes($self);
}

1;

