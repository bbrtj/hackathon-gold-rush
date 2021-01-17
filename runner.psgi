#!/usr/bin/env perl

use Modern::Perl "2018";
use lib 'lib';
use GoldRush;

# since I don't want to clutter the main dir
$ENV{KELP_CONFIG_DIR} = 'lib/conf';

GoldRush->new->run_all;

