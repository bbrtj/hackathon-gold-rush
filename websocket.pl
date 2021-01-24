#!/usr/bin/env perl

use Mojolicious::Lite -strict;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json);

use constant APP_LOCATION => '127.0.0.1:5000';

my %map;

websocket '/' => sub {
	my ($mojo) = @_;

	my $ua = Mojo::UserAgent->new;
	$mojo->on(json => sub {
		my ($c, $hash) = @_;

		my $type = delete $hash->{type};

		if ($type ne 'new_player') {
			$hash->{player} = $map{$c->tx->connection};
		}

		my $res = $ua->get(APP_LOCATION . "/$type", form => $hash)->res;
		if ($res->error || $res->is_error) {
			if ($res->body) {
				$c->send({text => $res->body});
			}
			elsif (!$res->code) {
				$c->send({json => {
					status => \0,
					error => "Game server is offline",
				}});
			}
			$c->finish;
		}
		else {
			my $body = $res->body;
			if ($type eq 'new_player') {
				my $res_data = decode_json $body;
				if ($res_data->{status}) {
					$map{$c->tx->connection} = $res_data->{result};
				}
			}

			$c->send({text => $body});
		}
	});
};

app->start;
