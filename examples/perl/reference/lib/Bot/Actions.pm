package Bot::Actions;

use Modern::Perl "2018";
use Bot::Util;
use List::Util qw(first max);

sub train_explorers
{
	my ($self, $phase) = @_;

	if (my $settlement = Bot::Util->can_train_explorer($phase)) {
		$phase->add_order('train_explorer', settlement => $settlement->{id});
		$phase->gold($phase->gold - Bot::Util->EXPLORER_GOLD);
	}
}

sub send_explorers
{
	my ($self, $phase) = @_;

	if (my @explorers = Bot::Util->can_send_explorers($phase)) {

		my $farthest_settlement = max map { $_->{position} } $phase->settlements->@*;
		for my $explorer (@explorers) {
			if (!grep { $_->{id} eq $phase->already_settling } $phase->explorers->@*) {
				$phase->already_settling(0);
			}

			if (!$phase->already_settling && $phase->mines->@* > 0) {

				# settling
				my $pos = $farthest_settlement + Bot::Util->SETTLEMENT_MINIMUM_DISTANCE;

				$phase->add_order(
					'send_explorer_settle',
					explorer => $explorer->{id},
					position => $pos
				);
				$phase->already_settling($explorer->{id});
			}
			else {
				# exploring
				my $pos = int(rand $farthest_settlement + 10) + 1;
				$pos += Bot::Util->SETTLEMENT_MINIMUM_DISTANCE
					if $pos == $explorer->{position};

				$phase->add_order(
					'send_explorer',
					explorer => $explorer->{id},
					position => $pos
				);
			}
		}
	}
}

sub train_workers
{
	my ($self, $phase) = @_;

	if (my @settlements = Bot::Util->can_train_workers($phase)) {
		foreach my $settlement (@settlements) {
			$phase->add_order('train_worker', settlement => $settlement->{id});
			$phase->gold($phase->gold - Bot::Util->WORKER_GOLD);
		}
	}
}

sub send_workers
{
	my ($self, $phase) = @_;

	if (my @workers = Bot::Util->can_send_workers($phase)) {
		my $mine = 0;
		my $total_mines = $phase->mines->@*;
		for my $worker (@workers) {
			$phase->add_order(
				'send_worker',
				worker => $worker->{id},
				mine => $phase->mines->[$mine]->{id}
			);

			# this does not really help
			# $mine = ($mine + 1) % $total_mines;
		}
	}
}

sub transport_population
{
	my ($self, $phase) = @_;

	if (my @settlements = Bot::Util->should_transport_population($phase)) {
		$phase->already_settling(0);
		for my $settlement (@settlements) {
			my $from = first {
				$_->{population} > Bot::Util->POP_GROW_THRESHOLD;
				}
				$phase->settlements->@*;

			if (defined $from) {
				$phase->add_order(
					'resettle',
					count => 1,
					settlement_from => $from->{id},
					settlement_to => $settlement->{id}
				);
				$phase->transported_to->{$settlement->{id}} = $from->{id};
				$from->{population} -= 1;
			}
		}
	}
}

sub end_turn
{
	my ($self, $phase) = @_;

	$phase->add_order('end_turn');
}

1;
