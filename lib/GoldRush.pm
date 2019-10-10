package GoldRush;

BEGIN {
	use File::Basename;
	$ENV{DANCER_CONFDIR} = dirname(__FILE__);
}

use Modern::Perl "2018";
use Dancer2;
use Dancer2::Plugin::WebSocket;
use Router;
use Websocket;

our $VERSION = "0.02";

get q</> => sub {
	return "GoldRush game version $VERSION";
};

dance;

