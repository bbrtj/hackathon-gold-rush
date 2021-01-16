package Websocket;

use Modern::Perl "2018";
use Dancer2 appname => "GoldRush";
use Dancer2::Plugin::WebSocket;
use Game::Engine qw(:all);
use ApiInterface qw(trap_errors assert_params);

my %conn_players;

my %types = (
	end_turn => [\&end_turn, qw(player)],
	train_worker => [\&train_worker, qw(player settlement)],
	train_explorer => [\&train_explorer, qw(player settlement)],
	send_worker => [\&send_worker, qw(player worker mine)],
	send_explorer => [\&send_explorer, qw(player explorer position)],
	send_explorer_settle => [\&send_explorer_settle, qw(player explorer position)],
	resettle => [\&resettle, qw(player count settlement_from settlement_to)],
	get_state => [\&get_state, qw(player)],
);

websocket_on_message sub {
	my ($conn, $params) = @_;
	my $type = $params->{type};

	my $result;
	if (!defined $type) {
		$result = trap_errors sub { die \"Param `type` is required in websocket connection"; };
	} elsif ($type eq q<new_player>) {
		$result = trap_errors \&generate_player_hash, assert_params $params, qw(name);
		$conn_players{$conn->id} = $result->{result}
			if $result->{status};
	} else {
		$params->{player} = $conn_players{$conn->id};

		if (exists $types{$type}) {
			my $code_params = $types{$type};
			my $code_ref = shift $code_params->@*;
			$result = trap_errors $code_ref, assert_params $params, $code_params->@*;
		}
		else {
			$result = trap_errors sub { die \"Unknown request type"; };
		}
	}

	$conn->send($result);
};

1;
