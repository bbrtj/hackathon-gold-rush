package ApiInterface;

use Modern::Perl "2018";
use Dancer2 appname => "GoldRush";
use Exporter qw(import);
use Try::Tiny;

our @EXPORT_OK = qw(trap_errors api_call assert_params);

sub trap_errors
{
	my ($sub, @params) = @_;
	my $status;

	try {
		my $ret = $sub->(@params);
		$status = {status => true, result => $ret};
	} catch {
		my $code = $_;
		$code = $$code
			if ref $code eq ref \1;
		$status = {status => false, error => $code};
	};
	return $status;
}

sub api_call
{
	my ($sub) = @_;
	my $subsub = sub {
		return encode_json(trap_errors $sub, scalar params);
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
