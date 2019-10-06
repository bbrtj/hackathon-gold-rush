package ApiInterface;

use Modern::Perl "2018";
use Dancer2 appname => "GoldRush";
use Exporter qw(import);
use Try::Tiny;

our @EXPORT_OK = qw(api_call assert_params);

sub api_call
{
	my ($sub) = @_;
	my $subsub = sub {
		try {
			my $ret = $sub->(scalar params);
			return encode_json({status => true, result => $ret});
		} catch {
			my $code = $_;
			$code = $$code
				if ref $code eq ref \1;
			return encode_json({status => false, error => $code});
		};
	};

	return $subsub;
}

sub assert_params
{
	my ($params, @required) = @_;
	my @positional;
	for my $param (@required) {
		die \"param `$param` is required"
			unless defined $params->{$param};
		push @positional, $params->{$param};
	}
	return @positional;
}

1;
