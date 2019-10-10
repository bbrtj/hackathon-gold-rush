package Game::Util;

use Modern::Perl "2018";
use Exporter qw(import);
use Digest::SHA qw(sha1_hex);

our @EXPORT_OK = qw(
	generate_id
	parameter_checks
);

sub generate_id
{
	my ($type) = @_;
	state $last = 1;
	if ($type eq "player") {
		my $data = join "::", @_;
		return substr sha1_hex($data), 0, 10;
	}
	if ($type eq "element") {
		return sprintf "%x", $last++;
	}
}

sub parameter_checks
{
	return {
		position => sub {
			die \"Position must be non-negative"
				if $_[0] < 0;
		},
		count => sub {
			die \"Count must be positive"
				unless $_[0] > 0;
		},
	};
}

1;
