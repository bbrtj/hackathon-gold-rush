package Router;

use Modern::Perl "2018";
use Dancer2 appname => "GoldRush";
use Game::Engine qw(:all);
use ApiInterface qw(api_call assert_params);

prefix undef;

get q</new_player> => api_call sub {
	my ($params) = @_;
	return generate_player_hash assert_params $params, qw(name);
};

get q</end_turn> => api_call sub {
	my ($params) = @_;
	return end_turn assert_params $params, qw(player);
};

get q</train_worker> => api_call sub {
	my ($params) = @_;
	return train_worker assert_params $params, qw(player settlement);
};

get q</train_explorer> => api_call sub {
	my ($params) = @_;
	return train_explorer assert_params $params, qw(player settlement);
};

get q</send_worker> => api_call sub {
	my ($params) = @_;
	return send_worker assert_params $params, qw(player worker mine);
};

get q</send_explorer> => api_call sub {
	my ($params) = @_;
	return send_explorer assert_params $params, qw(player explorer position);
};

get q</send_explorer_settle> => api_call sub {
	my ($params) = @_;
	return send_explorer_settle assert_params $params, qw(player explorer position);
};

get q</resettle> => api_call sub {
	my ($params) = @_;
	return resettle assert_params $params, qw(player count settlement_from settlement_to);
};

get q</get_state> => api_call sub {
	my ($params) = @_;
	return get_state assert_params $params, qw(player);
};

get q</results> => sub {
  # TODO
};

1;
