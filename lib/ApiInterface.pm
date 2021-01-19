package ApiInterface;

use Modern::Perl "2018";
use Exporter qw(import);
use Syntax::Keyword::Try;
use Scalar::Util qw(blessed);
use Kelp::Exception;

our @EXPORT_OK = qw(trap_errors trap_websocket api_call assert_params);

sub trap_errors
{
	my ($sub, @params) = @_;
	my @err = (status => \0, error =>);

	try {
		my $ret = $sub->(@params);
		return {status => \1, result => $ret};
	}
	catch ($error) {
		die $error unless ref $error;

		my $exception;
		if (blessed $error && $error->isa(Kelp::Exception::)) {
			$exception = $error;
			$error->body({@err => $error->body});
		}
		else {
			$error = $$error
				if ref $error eq ref \1;
			$exception = Kelp::Exception->new(403, body => {@err => $error});
		}
		die $exception;
	}
}

sub trap_websocket
{
	try {
		return trap_errors(@_);
	}
	catch ($error) {
		die $error unless blessed $error;

		return $error->body;
	}
}

sub api_call
{
	my ($sub) = @_;
	my $subsub = sub {
		my ($kelp) = @_;
		return trap_errors $sub, $kelp->req->parameters;
	};

	return $subsub;
}

sub assert_params
{
	my ($params, @required) = @_;
	my @positional;
	for my $param (@required) {
		Kelp::Exception->throw(400, body => "param `$param` is required")
			unless defined $params->{$param};
		push @positional, $params->{$param};
	}
	return @positional;
}

1;
