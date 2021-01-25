#!/usr/bin/env perl

use Mojolicious::Lite -strict;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json);

my $app_location = $ENV{HACKATHON_GAME_HOST} // 'localhost:5000';

my %map;
my %queue;

sub mk_response
{
	my ($data, $type) = @_;
	$type //= 1;
	my $label = $type ? 'result' : 'error';
	return {json => {status => \$type, $label => $data}};
}

sub query_game_server
{
	state $ua = Mojo::UserAgent->new;
	my ($c, $type, $hash, $content_type) = @_;
	$content_type //= 'form';
	$type = "api/$type";

	my $res = $ua->get("$app_location/$type", $content_type => $hash)->res;
	if ($res->error || $res->is_error) {
		if ($res->body) {
			$c->send({text => $res->body});
		}
		elsif (!$res->code) {
			$c->send(mk_response("Game server is offline", 0));
		}
		$c->finish;
		return undef;
	}
	else {
		my $body = $res->body;

		$c->send({text => $body});
		return $body;
	}
}

websocket '/' => sub {
	my ($mojo) = @_;

	$mojo->on(
		json => sub {
			my ($c, $hash) = @_;

			my $type = delete $hash->{type};

			if ($type eq 'new_player') {
				if (my $body = query_game_server($c, $type, $hash)) {
					my $res_data = decode_json $body;
					if ($res_data->{status}) {
						$map{$c->tx->connection} = $res_data->{result};
						$queue{$c->tx->connection} = [];
					}
				}
			}
			elsif ($type eq 'get_state') {
				my $commands = $queue{$c->tx->connection};
				if ($commands && $commands->@*) {
					$queue{$c->tx->connection} = [];
					query_game_server(
						$c, 'multi', {
							player => $map{$c->tx->connection},
							commands => $commands,
						},
						'json'
					);
				}
				else {
					query_game_server(
						$c, $type, {
							player => $map{$c->tx->connection},
						}
					);
				}
			}
			else {
				push $queue{$c->tx->connection}->@*, [$type, $hash->%*];
				$c->send(mk_response("queued"));
			}

		}
	);
};

app->start;
