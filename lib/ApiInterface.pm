package ApiInterface;

use Modern::Perl "2018";
use Exporter qw(import);
use Syntax::Keyword::Try;

our @EXPORT_OK = qw(trap_errors api_call assert_params);

sub trap_errors
{
	my ($sub, @params) = @_;
	my $status;

	try {
		my $ret = $sub->(@params);
		$status = {status => \1, result => $ret};
	} catch ($code) {
		$code = $$code
			if ref $code eq ref \1;
		$status = {status => \0, error => $code};
	}
	return $status;
}

sub api_call
{
	my ($sub) = @_;
	my $subsub = sub {
		my ($kelp) = @_;
		return encode_json(trap_errors $sub, $kelp->query_parameters);
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
