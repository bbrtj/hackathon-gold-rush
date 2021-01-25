package Router;

use Modern::Perl "2018";
use Game::Engine;
use Game::Scores;
use ApiInterface qw(api_call assert_params trap_errors);

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
			'/api/' . $type => {
				to => api_call sub {
					my ($params) = @_;
					return $code_ref->(assert_params $params, @{$params_ref});
				},
			}
		);
	}

	$r->add(
		'/api/multi' => sub {
			my ($kelp) = @_;

			return trap_errors sub {
				die \'expected json' unless $kelp->req->is_json;

				my $player = $kelp->param('player');
				my $commands = $kelp->param('commands');
				die \'array reference expected'
					unless ref $commands eq ref [];

				die \'no commands'
					unless $commands->@*;

				for my $command ($commands->@*) {
					my ($type, %params) = $command->@*;
					$params{player} = $player;

					die \"unknown command $type"
						unless exists $types{$type};

					my ($code_ref, $params_ref) = $types{$type}->@*;
					$code_ref->(assert_params \%params, $params_ref->@*);
				}

				return $types{get_state}->[0]->($player);
			};

		},
	);

	$r->add(
		'/api/scores' => sub {
			my ($kelp) = @_;
			return Game::Scores->get_scores;
		}
	);

}

1;
