package Game::Settings;

use Modern::Perl "2018";
use Quantum::Superpositions::Lazy qw(superpos collapse);

our $game_length = 1000;

our $default_gold = 50;
our $default_population = 3;

our %unit_prices = (
	worker => 20,
	explorer => 30,
);
our $exploring_success_rate = 0.4;

our $unit_max_age = 100;
our $population_growth_tick = 5;
our $population_growth = sub {
	my ($pop) = @_;
	return int(100 / (-$pop - 49) + 2 + 0.9999);
};

my $mining_rate = 0.5;
my $mining_step = 5;
my $mining_drop = 0.8;
our $mining = sub {
	my ($miners) = @_;

	my $mining = $mining_rate;
	my $income = 0;
	while ($miners > $mining_step) {
		$income += $mining_step * $mining;
		$mining *= $mining_drop;
		$miners -= $mining_step;
	}
	$income += $miners * $mining;
	return $income;
};

our $settlement_min_proximity = 5;

our $map = sub {
	my @positions;
	my $deposit_every = 5;
	for my $start (map { $_ * $deposit_every } 0 .. 40) {
		push @positions, superpos($start + 1 .. $start + $deposit_every);
	}
	return [collapse @positions];
	}
	->();

