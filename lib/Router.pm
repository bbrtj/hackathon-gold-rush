package Router;

use Modern::Perl "2018";
use Game::Engine;
use ApiInterface qw(api_call assert_params trap_websocket);

my %types = (
	new_player => [\&Game::Engine::generate_player_hash, [qw(name)]],
	end_turn => [\&Game::Engine::end_turn, [qw(player)]],
	train_worker => [\&Game::Engine::train_worker, [qw(player settlement)]],
	train_explorer => [\&Game::Engine::train_explorer, [qw(player settlement)]],
	send_worker => [\&Game::Engine::send_worker, [qw(player worker mine)]],
	send_explorer => [\&Game::Engine::send_explorer, [qw(player explorer position)]],
	send_explorer_settle => [\&Game::Engine::send_explorer_settle, [qw(player explorer position)]],
	resettle => [\&Game::Engine::resettle, [qw(player count settlement_from settlement_to)]],
	get_state => [\&Game::Engine::get_state, [qw(player)]],
);

sub install_routes
{
	my ($kelp) = @_;

	### API ###

	my $r = $kelp->routes;

	for my $type (keys %types) {
		my ($code_ref, $params_ref) = $types{$type}->@*;
		$r->add(
			'/' . $type => {
				to => api_call sub {
					my ($params) = @_;
					return $code_ref->(assert_params $params, @{$params_ref});
				},
			}
		);
	}

	$r->add(
		'/results' => sub {

			# TODO
		}
	);

	### WebSocket ###

	my $ws = $kelp->websocket;

	$ws->add(
		message => sub {
			my ($conn, $params) = @_;

			return $conn->send(trap_websocket sub { die \"Invalid input data" })
				unless ref $params eq ref {};

			my $result;
			$params->{player} = $conn->data->{player};

			my $type = $params->{type};
			if ($type && exists $types{$type}) {
				my ($code_ref, $params_ref) = $types{$type}->@*;
				$result = trap_websocket sub { $code_ref->(assert_params $params, $params_ref->@*) };

				# special case - set websocket connection player
				$conn->data->{player} = $result->{result}
					if $type eq q<new_player> && $result->{status};
			}
			else {
				$result = trap_websocket sub { die \"Unknown request type" };
			}

			$conn->send($result);
		}
	);

	$ws->add(
		malformed_message => sub {
			my ($conn, $message, $err) = @_;
			my $result = trap_websocket sub { die \"Invalid input data" };
			$conn->send($result);
		}
	);

	$ws->add(error => sub { die 'wtf' });
}

1;
