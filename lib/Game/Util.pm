package Game::Util;

use Modern::Perl "2018";
use Exporter qw(import);
use Digest::SHA qw(sha1_hex);
use Data::Entropy::Algorithms qw(rand_flt);
use UUID::Tiny ':std';

use Types::Common::Numeric qw(PositiveInt PositiveOrZeroInt);

our @EXPORT_OK = qw(
	generate_id
	parameter_checks
	random
);

sub generate_id
{
	create_uuid_as_string(UUID_V4);
}

sub parameter_checks
{
	state $checks = {
		position => sub {
			PositiveOrZeroInt->assert_valid($_[0]);
		},
		count => sub {
			PositiveInt->assert_valid($_[0]);
		},
	};
}

sub random
{
	rand_flt 0, 1;
}

1;
