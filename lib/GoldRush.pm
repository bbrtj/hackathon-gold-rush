package GoldRush;

use Modern::Perl "2018";
use Dancer2;
use Router;

our $VERSION = "0.01";

get q</> => sub {
	return "GoldRush game version $VERSION";
};

dance;
