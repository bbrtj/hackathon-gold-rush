#!/usr/bin/env perl

use Modern::Perl "2018";

use File::Basename;
use Plack::Builder;
use lib dirname(__FILE__) . "/lib";
use Test::More;
use Try::Tiny;
use List::Util qw(first);

use Game::Engine qw(:all);

my $player = generate_player_hash("test");
end_turn($player) for 1 .. 3;

my $state = get_state($player);
is (scalar $state->{settlements}->@*, 1, "Settlement exists");
my $base = $state->{settlements}[0];

sub get_base
{
	my ($state) = @_;
	state $base_id = $base->{id};
	return first { $_->{id} eq $base_id } $state->{settlements}->@*;
}

is ($base->{population}, 4, "Population grows");
my $explorer = train_explorer($player, $base->{id});
$state = get_state($player);
$base = get_base $state;
is ($base->{population}, 3, "Unit trained");
is (scalar $state->{explorers}->@*, 1, "Unit trained");
is ($state->{gold}, 30, "Gold reduced");
my $time = send_explorer_settle($player, $explorer, 5);
end_turn($player) for 1 .. $time;

$state = get_state($player);
is (scalar $state->{settlements}->@*, 2, "Settlement created");
is (scalar $state->{explorers}->@*, 0, "Explorer dismissed");
my $pop = get_base($state)->{population};
my $colony = first { $_->{id} ne $base->{id} } $state->{settlements}->@*;

sub get_colony
{
	my ($state) = @_;
	state $colony_id = $colony->{id};
	return first { $_->{id} eq $colony_id } $state->{settlements}->@*;
}

$time = resettle($player, $pop, $base->{id}, $colony->{id});
end_turn($player) for 1 .. $time;

$state = get_state($player);
is (get_base($state)->{population}, 0, "Base empty");
is (get_colony($state)->{population}, $pop + 1, "Colony population ok");
$explorer = train_explorer($player, $colony->{id});
my $worker = train_worker($player, $colony->{id});

sub has_mine
{
	my ($state) = @_;
	return $state->{mines}[0];
}

sub get_explorer
{
	my ($state) = @_;
	state $explorer_id = $explorer;
	return first { $_->{id} eq $explorer_id } $state->{explorers}->@*;
}

sub get_worker
{
	my ($state) = @_;
	state $worker_id = $worker;
	return first { $_->{id} eq $worker_id } $state->{workers}->@*;
}

my $mine;
while (1) {
	end_turn($player);
	$state = get_state($player);
	$mine = has_mine $state;
	$explorer = get_explorer $state;
	if ($explorer->{idle}) {
		$time = send_explorer($player, $explorer->{id}, $colony->{position} + 10);
	}
	if (defined $mine) {
		last;
	}
}

sub get_mine
{
	my ($state) = @_;
	state $mine_id = $mine->{id};
	return first { $_->{id} eq $mine_id } $state->{mines}->@*;
}

is(get_worker($state)->{working}, 0, "Worker is not working");
$time = send_worker($player, $worker, $mine->{id});
end_turn($player) for 2 .. $time;

$state = get_state($player);
is(get_worker($state)->{idle}, 0, "Worker has not arrived");
is(get_worker($state)->{working}, 0, "Worker is not working");
is($mine->{population}, 0, "Mine is empty");
is ($state->{gold}, 0, "Gold is zero");
end_turn($player);

$state = get_state($player);
$mine = get_mine($state);
is ($state->{gold}, 0, "Gold is zero");
is($mine->{population}, 1, "Mine population ok");
is(get_worker($state)->{position}, $mine->{position}, "Worker position ok");
is(get_worker($state)->{working}, 1, "Worker is working");

end_turn($player);
$state = get_state($player);
is ($state->{gold}, 1, "Gold is being extracted");

done_testing;
