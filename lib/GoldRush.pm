package GoldRush;

our $VERSION = "0.02";

use Modern::Perl "2018";
use parent 'Kelp';
use Router;

# since I don't want to clutter the main dir
$ENV{KELP_CONFIG_DIR} = 'lib/conf';

sub build
{
	my ($self) = @_;
	my $r = $self->routes;

	$r->add(
		'/', {
			method => 'GET',
			to => sub {
				return "Gold Rush game server version $VERSION";
			},
		}
	);

	Router::install_routes($self);
}

1;

