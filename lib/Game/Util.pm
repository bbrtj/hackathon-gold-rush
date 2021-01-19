package Game::Util;

use Modern::Perl "2018";
use Exporter qw(import);
use Digest::SHA qw(sha1_hex);
use Crypt::PRNG::Fortuna qw(rand);
use Crypt::Misc qw(random_v4uuid);

use Types::Common::Numeric qw(PositiveInt PositiveOrZeroInt);

our @EXPORT_OK = qw(
	generate_id
	parameter_checks
	random
);

sub generate_id
{
	random_v4uuid;
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
	rand;
}

1;
