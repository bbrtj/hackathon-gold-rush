package Game::Util;

use Modern::Perl "2018";
use Exporter qw(import);
use Time::HiRes qw(time);
use Digest::SHA qw(sha1_hex);

our @EXPORT_OK = qw(
	generate_id
	parameter_checks
);

sub generate_id
{
	my $data = join "::", @_, rand, time;
	return sha1_hex($data);
}

sub parameter_checks
{
	return {
		position => sub {
			die \"Position must be non-negative"
				if $_[0] < 0;
		},
		count => sub {
			die \"Count must be non-negative"
				if $_[0] < 0;
		},
	};
}

1;
