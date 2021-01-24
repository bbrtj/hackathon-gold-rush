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
}

1;
