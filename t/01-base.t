use Modern::Perl "2018";
use Test::More;

use Syntax::Keyword::Try;
use List::Util qw(first);

use Game::Engine;
use Game::Settings;

$Game::Settings::map = [2, 4, 8, 11, 17, 20, 25, 34, 41, 60, 91, 142, 188];

sub get_colony
{
	my ($state, $colony) = @_;
	my $colony_id = $colony->{id};
	return first { $_->{id} eq $colony_id }
		$state->{settlements}->@*;
}

sub has_mine
{
	my ($state) = @_;
	return $state->{mines}[0];
}

sub get_explorer
{
	my ($state, $explorer) = @_;
	return first { $_->{id} eq $explorer }
		$state->{explorers}->@*;
}

sub get_worker
{
	my ($state, $worker_id) = @_;
	return first { $_->{id} eq $worker_id }
		$state->{workers}->@*;
}

sub get_mine
{
	my ($state, $mine) = @_;
	my $mine_id = $mine->{id};
	return first { $_->{id} eq $mine_id }
		$state->{mines}->@*;
}

sub get_base
{
	my ($state, $base) = @_;
	my $base_id = $base->{id};
	return first { $_->{id} eq $base_id }
		$state->{settlements}->@*;
}

try {
	my (
		$player,
		$mine,
		$time,
		$state,
		$base,
		$explorer_id,
		$explorer,
		$colony
	);

	$player = Game::Engine::generate_player_hash("test");
	Game::Engine::end_turn($player) for 1 .. 5;

	$state = Game::Engine::get_state($player);
	is(scalar $state->{settlements}->@*, 1, "Settlement exists");
	$base = $state->{settlements}[0];

	is($base->{population}, 4, "Population grows");
	$explorer_id = Game::Engine::train_explorer($player, $base->{id});
	$state = Game::Engine::get_state($player);
	$base = get_base $state, $base;
	is($base->{population}, 3, "Unit trained");
	is(scalar $state->{explorers}->@*, 1, "Unit trained");
	is($state->{gold}, 20, "Gold reduced");

	while (1) {
		Game::Engine::end_turn($player);
		$state = Game::Engine::get_state($player);
		$mine = has_mine $state;
		$explorer = get_explorer $state, $explorer_id;
		if ($explorer->{idle}) {
			$time = Game::Engine::send_explorer($player, $explorer->{id}, $base->{position} + 10);
		}
		if (defined $mine) {
			last;
		}
	}

	while(1) {
		Game::Engine::end_turn($player);
		$state = Game::Engine::get_state($player);
		$explorer = get_explorer $state, $explorer_id;
		if ($explorer->{idle}) {
			last;
		}
	}

	try {
		Game::Engine::send_explorer_settle($player, $explorer_id, 3);
		fail("Minimum proximity not respected");
	}
	catch {
		pass("Minimum proximity ok");
	}

	$time = Game::Engine::send_explorer_settle($player, $explorer_id, 5);
	Game::Engine::end_turn($player) for 1 .. $time;

	$state = Game::Engine::get_state($player);
	is(scalar $state->{settlements}->@*, 2, "Settlement created");
	is(get_explorer($state, $explorer_id), undef, "Explorer dismissed");
	my $pop = get_base($state, $base)->{population};
	$colony = first { $_->{id} ne $base->{id} }
		$state->{settlements}->@*;

	$time = Game::Engine::resettle($player, $pop, $base->{id}, $colony->{id});
	Game::Engine::end_turn($player) for 1 .. $time;

	$state = Game::Engine::get_state($player);
	is(get_base($state, $base)->{population}, 0, "Base empty");
	is(get_colony($state, $colony)->{population}, $pop + 1, "Colony population ok");
	my $worker_id = Game::Engine::train_worker($player, $colony->{id});
	$state = Game::Engine::get_state($player);

	is(get_worker($state, $worker_id)->{working}, 0, "Worker is not working");
	$time = Game::Engine::send_worker($player, $worker_id, $mine->{id});
	Game::Engine::end_turn($player) for 2 .. $time;

	$state = Game::Engine::get_state($player);
	is(get_worker($state, $worker_id)->{idle}, 0, "Worker has not arrived");
	is(get_worker($state, $worker_id)->{working}, 0, "Worker is not working");
	is($mine->{population}, 0, "Mine is empty");
	is($state->{gold}, 0, "Gold is zero");
	Game::Engine::end_turn($player);

	$state = Game::Engine::get_state($player);
	$mine = get_mine($state, $mine);
	is($state->{gold}, 0, "Gold is zero");
	is($mine->{population}, 1, "Mine population ok");
	is(get_worker($state, $worker_id), undef, "Worker is not listed, so is working");

	Game::Engine::end_turn($player);
	$state = Game::Engine::get_state($player);
	is($state->{gold}, 0.5, "Gold is being extracted");
}
catch ($error) {
	die $$error if ref $error;
	die $error;
}

done_testing;
