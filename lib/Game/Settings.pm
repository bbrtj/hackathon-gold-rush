package Game::Settings;

use Modern::Perl "2018";

our $game_length = 4000;

our $default_gold = 50;
our $default_population = 3;

our %unit_prices = (
	worker => 10,
	explorer => 20,
);
our $exploring_success_rate = 0.4;

our $population_growth_tick = 3;
our $population_growth = sub {
	my ($pop) = @_;
	return int(100 / (-$pop - 18.1) + 5 + 0.9999);
};

my $mining_rate = 0.5;
my $mining_step = 10;
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

# TODO: modify the map here
our $map =
# normal
[3, 5, 9, 14, 16, 23, 26, 33, 35, 36, 40, 49, 54, 59, 63, 68, 72, 74, 79, 87, 91, 96, 108, 131, 155];
# barren
# [7, 15, 23, 35, 48, 54, 66, 80, 85, 93, 143];
# rich
# [3, 5, 6, 9, 11, 14, 16, 19, 24, 25, 29, 31, 34, 38, 39, 42, 45, 46, 50, 53, 55, 58, 61, 67, 70, 72, 73, 77, 80, 83, 85, 90, 91, 92, 95, 98, 111, 123, 134, 145];
1;
