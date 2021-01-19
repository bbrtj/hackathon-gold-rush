#!/usr/bin/env perl

use Modern::Perl "2018";
use AnyEvent;
use AnyEvent::WebSocket::Client;
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

my $host = shift @ARGV // '127.0.0.1:5000';

my $condvar = AE::cv;

Logger::log "Connecting to $host";

my $player = WebSocketPlayer->new;
my $json = JSON()->new;
my $client = AnyEvent::WebSocket::Client->new;
my $this_connection;
$client->connect("ws://$host/ws")->cb(
	sub {
		try {
			$this_connection = shift->recv
		}
		catch ($err) {
			die "Could not establish connection";
		}

		$this_connection->on(
			each_message => sub {
				my ($connection, $message) = @_;
				my $decoded;
				my $status;

				try {
					$decoded = $json->decode($message->{body});
					$status = $player->handle($decoded);
				} catch ($error) {
					Logger::log 'Exception occured: ' . $error;
					$condvar->send;
				}

				if ($status->playing) {
					Logger::log $status->log;
					$connection->send($json->encode($status->message));
				}
				else {
					Logger::log "Closing connection";
					$connection->close;
					$condvar->send;
				}
			}
		);

		$this_connection->send($json->encode($player->handle->message));
	}
);

$condvar->recv;
Logger::log "Finished";
