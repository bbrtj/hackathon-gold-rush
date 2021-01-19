package Bot::Util;

use Modern::Perl "2018";
use List::Util qw(first sum);

use constant EXPLORER_GOLD => 30;
use constant WORKER_GOLD => 20;

sub can_train_explorer {
	my ($self, $phase) = @_;

	my $settlement = first {
		$_->{population} > 2
	} $phase->settlements->@*;

	my $working = sum map { $_->{population} } $phase->mines->@*;

	# care not to block ourselves from gaining gold
	if (
		$phase->gold >= EXPLORER_GOLD
		&& defined $settlement
		&& ($phase->workers->@* > 0 || $working > 0 || $phase->gold >= EXPLORER_GOLD + WORKER_GOLD)
		&& $phase->explorers->@* <= 2
	) {
		return $settlement;
	}

	return;
}

sub can_send_explorers {
	my ($self, $phase) = @_;

	my @idle = grep {
		$_->{idle}
	} $phase->explorers->@*;

	# if they are idle, we should use them
	return @idle;
}

sub can_train_workers {
	my ($self, $phase) = @_;

	return unless $phase->mines->@*;

	my @settlements = grep {
		$_->{population} > 2
	} $phase->settlements->@*;

	my @ret;
	my $gold = $phase->gold;
	while ($gold >= WORKER_GOLD && @settlements) {
		push @ret, shift @settlements;
		$gold -= WORKER_GOLD;
	}

	return @ret;
}

sub can_send_workers {
	my ($self, $phase) = @_;

	my @idle = grep {
		$_->{idle}
	} $phase->workers->@*;

	# if they are idle, we should use them
	return @idle;
}

sub should_transport_population {
	my ($self, $phase) = @_;

	# careful not to transfer everyone when the transport is in progress
	my @settlements = grep {
		$_->{population} < 2 && !$phase->transported_to->{$_->{id}}
	} $phase->settlements->@*;

	return @settlements;
}

1;
