use Modern::Perl "2018";
use Test::More;
use AnyEvent;
use Syntax::Keyword::Try;
use Test::TCP;
use Plack::Loader;
use AnyEvent::WebSocket::Client;
use Crypt::Misc qw(is_v4uuid);
use GoldRush;

my $app = GoldRush->new;
my $json = $app->json;

my @messages = map { $json->encode($_) } (
	{type => "get_state"},
	{type => "new_player", name => "mememe"},
	{type => "get_status"},
	{type => "get_state"},
);

my @results;
my @expected_results = (
	[0, sub { like shift->{error}, qr/param .+ is required/i, 'unknown param error ok' }],
	[1, sub { ok is_v4uuid shift->{result}, 'player uuid ok' }],
	[0, sub { like shift->{error}, qr/unknown request type/i, 'unknown req error ok' }],
	[1, sub {
		my $data = shift;
		is $data->{result}{settlements}[0]{population}, 3, 'state population ok';
		is $data->{result}{turn}, 0, 'state turn ok';
	}],
);

WEBSOCKET: {
	my $condvar = AE::cv;

	my $server = Test::TCP->new(
		code => sub {
			my ($port) = @_;

			my $server = Plack::Loader->load('Twiggy', port => $port, host => "127.0.0.1");
			$server->run($app->run_all);
		},
	);

	my $client = AnyEvent::WebSocket::Client->new;
	my $this_connection;
	$client->connect("ws://127.0.0.1:" . $server->port . "/ws")->cb(sub {
		try {
			$this_connection = shift->recv
		} catch ($err) {
			fail $err;
			return;
		}

		$this_connection->on(
			each_message => sub {
				my ($connection, $message) = @_;
				push @results, $json->decode($message->{body});

				if (@messages) {
					$connection->send(shift @messages)
				} else {
					$connection->close;
					note "Closing connection";
					$condvar->send;
				}
			}
		);

		$this_connection->send(shift @messages)
	});

	my $w = AE::timer 5, 0, sub {
		fail "event loop was not stopped";
		$condvar->send;
	};

	$condvar->recv;
}

is scalar @messages, 0, 'all messages sent ok';
is scalar @results, scalar @expected_results, 'results count ok';
for my $data (@expected_results) {
	my ($status, $test_sub) = $data->@*;

	my $res = shift @results;
	is $res->{status}, $status, 'message status ok';
	$test_sub->($res);
}

done_testing;
