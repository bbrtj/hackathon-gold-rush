#!/usr/bin/env perl

use Modern::Perl "2018";

use File::Basename;
use Plack::Builder;
use lib dirname(__FILE__) . "/lib";
use Test::More;
use Try::Tiny;

use Game::Engine qw(:all);

my $player = generate_player_hash("test");
end_turn($player) for 1 .. 3;

my $state = get_state($player);
is (scalar $state->{settlements}->@*, 1, "Settlement exists");
my $base = $state->{settlements}[0];
is ($base->{population}, 4, "Population grows");
my $explorer = train_explorer($player, $base->{id});
$state = get_state($player);
$base = $state->{settlements}[0];
is ($base->{population}, 3, "Unit trained");
is (scalar $state->{explorers}->@*, 1, "Unit trained");
is ($state->{gold}, 30, "Gold reduced");
my $time = send_explorer_settle($player, $explorer, 5);
end_turn($player) for 1 .. $time;

$state = get_state($player);
is (scalar $state->{settlements}->@*, 2, "Settlement created");
is (scalar $state->{explorers}->@*, 0, "Explorer dismissed");
my $pop = $state->{settlements}[0]{population};
$time = resettle($player, $pop, $state->{settlements}[0]{id}, $state->{settlements}[1]{id});
end_turn($player) for 1 .. $time;

$state = get_state($player);
is ($state->{settlements}[0]{population}, 0, "Base empty");
is ($state->{settlements}[1]{population}, $pop + 1, "Second settlement population ok");

done_testing;
