package Websocket;

use Modern::Perl "2018";
use Dancer2 appname => "GoldRush";
use Dancer2::Plugin::WebSocket;
use Game::Engine qw(:all);
use ApiInterface qw(trap_errors assert_params);

my %conn_players;

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
		if ($type eq q<end_turn>) {
			$result = trap_errors \&end_turn, assert_params $params, qw(player);
		} elsif ($type eq q<train_worker>) {
			$result = trap_errors \&train_worker, assert_params $params, qw(player settlement);
		} elsif ($type eq q<train_explorer>) {
			$result = trap_errors \&train_explorer, assert_params $params, qw(player settlement);
		} elsif ($type eq q<send_worker>) {
			$result = trap_errors \&send_worker, assert_params $params, qw(player worker mine);
		} elsif ($type eq q<send_explorer>) {
			$result = trap_errors \&send_explorer, assert_params $params, qw(player explorer position);
		} elsif ($type eq q<send_explorer_settle>) {
			$result = trap_errors \&send_explorer_settle, assert_params $params, qw(player explorer position);
		} elsif ($type eq q<resettle>) {
			$result = trap_errors \&resettle, assert_params $params, qw(player count settlement_from settlement_to);
		} elsif ($type eq q<get_state>) {
			$result = trap_errors \&get_state, assert_params $params, qw(player);
		} else {
			$result = trap_errors sub { die \"Unknown request type"; };
		}
	}

	$conn->send($result);
};

1;
