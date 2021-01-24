#!/usr/bin/env perl

use Modern::Perl "2018";
use Mojo::IOLoop;
use Mojo::UserAgent;
use Syntax::Keyword::Try;
use JSON::MaybeXS;

use File::Basename;
use lib dirname(__FILE__) . '/lib';
use WebSocketPlayer;
use Logger;

###################### WEBSOCKET REFERENCE IMPLEMENTATION #####################
# This is a possible implementation of a simple bot solving the Gold Rush game.
# This bot, after a short setup phase and a population growing phase, enters
# the phase of intense worker production while always keeping two explorers,
# one for exploring and one for starting new settlements. It can randomly fail
# due to worker lifespan, but overall seem to stash at least 4000 gold, with up
# to over 10000 observed as the all time high.
###############################################################################

my $host = shift @ARGV // '127.0.0.1:3000';

my $ua = Mojo::UserAgent->new;

Logger::log "Connecting to $host";

my $player = WebSocketPlayer->new;
my $json = JSON()->new;
my $tx = $ua->build_websocket_tx("ws://$host");

$ua->start(
	$tx => sub {
		my ($ua, $conn) = @_;
		Logger::log 'WebSocket handshake failed!' and return
			unless $conn->is_websocket;

		$conn->on(
			message => sub {
				my ($connection, $message) = @_;
				my $decoded;
				my $status;

				try {
					$decoded = $json->decode($message);
					$status = $player->handle($decoded);
				}
				catch ($error) {
					Logger::log $message;
					Logger::log 'Exception occured: ' . $error;
					$connection->finish;
				}

				if ($status && $status->playing) {
					Logger::log $status->log;
					$connection->send($json->encode($status->message));
				}
				else {
					Logger::log "Closing connection";
					$connection->finish;
				}
			}
		);

		$conn->send($json->encode($player->handle->message));
	}
);

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
Logger::log "Finished";
