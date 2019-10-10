#!/usr/bin/env perl

use Modern::Perl "2018";

use File::Basename;
use Plack::Builder;
use lib dirname(__FILE__) . "/lib";
use GoldRush;

builder {
	enable "TrailingSlashKiller", redirect => 1;
	mount(GoldRush->websocket_mount);
	mount '/' => GoldRush->to_app;
};

