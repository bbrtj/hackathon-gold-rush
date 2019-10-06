package Game::Instance;

use Moo;
use MooX qw(HandlesVia LvalueAttribute);
use MooX::Types::MooseLike::Base qw(Int Num Str ArrayRef HashRef InstanceOf AnyOf);
use aliased "Game::Element::Settlement" => "Settlement";
use aliased "Game::Element::Worker" => "Worker";
use aliased "Game::Element::Explorer" => "Explorer";
use aliased "Game::Element::Mine" => "Mine";
use aliased "Game::Element::Transport" => "Transport";
use Game::Settings;

has "player_name" => (
	is => "ro",
	isa => Str,
);

has "map" => (
	is => "ro",
	isa => ArrayRef[Int],
	default => sub { $Game::Settings::map },
	handles_via => "Array",
	handles => {
		find_mine => "first"
	}
);

has "turn" => (
	is => "rw",
	isa => Int,
	lvalue => 1,
	default => 0,
);

has "gold" => (
	is => "rw",
	isa => Num,
	lvalue => 1,
	default => sub { $Game::Settings::default_gold },
);

has "settlements" => (
	is => "rw",
	isa => ArrayRef[InstanceOf["Game::Element::Settlement"]],
	default => sub { [Settlement->new(position => 0, population => $Game::Settings::default_population)] },
	handles_via => "Array",
	handles => {
		add_settlement => "push"
	}
);

has "workers" => (
	is => "rw",
	isa => ArrayRef[InstanceOf["Game::Element::Worker"]],
	default => sub { [] },
	handles_via => "Array",
	handles => {
		add_worker => "push"
	}
);

has "explorers" => (
	is => "rw",
	isa => ArrayRef[InstanceOf["Game::Element::Explorer"]],
	default => sub { [] },
	handles_via => "Array",
	handles => {
		add_explorer => "push"
	}
);

has "mines" => (
	is => "rw",
	isa => ArrayRef[InstanceOf["Game::Element::Mine"]],
	default => sub { [] },
	handles_via => "Array",
	handles => {
		add_mine => "push"
	}
);

has "pseudounits" => (
	is => "rw",
	isa => ArrayRef[AnyOf["Game::Element::Transport"]],
	default => sub { [] },
	handles_via => "Array",
	handles => {
		add_pseudounit => "push"
	}
);

sub _get_current_items
{
	my ($self) = @_;

	my %items = (
		settlements => $self->settlements,
		mines => $self->mines,
		workers => $self->workers,
		explorers => $self->explorers,
		pseudounits => $self->pseudounits,
	);

	return \%items;
}

sub _get_by_id
{
	my ($self, $what, $id) = @_;
	my $items = $self->_get_current_items;

	for my $item ($items->{$what}->@*) {
		if ($item->id eq $id) {
			return $item;
		}
	}
	die \"Couldn't find $what";
}

sub _update_state
{
	my ($self) = @_;

	my %items = %{$self->_get_current_items};
	my @update_order = qw(settlements explorers mines workers pseudounits);

	for my $ord (@update_order) {
		my $arr = $items{$ord};
		for my $item (@$arr) {
			$item->end_of_turn($self);
		}
	}
}

sub end_turn
{
	my ($self) = @_;
	die \"Game ended"
		if $self->turn >= $Game::Settings::game_length;

	$self->turn += 1;
	$self->_update_state;
	return $self->turn;
}

sub train_worker
{
	my ($self, $settlement_id) = @_;
	my $price = $Game::Settings::unit_prices{worker};
	die \"Not enough gold"
		if $price > $self->gold;

	my $settlement = $self->_get_by_id(settlements => $settlement_id);
	my $worker = Worker->new;
	$settlement->train_unit($worker);
	$self->gold -= $price;
	$self->add_worker($worker);

	return $worker->id;
}

sub train_explorer
{
	my ($self, $settlement_id) = @_;
	my $price = $Game::Settings::unit_prices{explorer};
	die \"Not enough gold"
		if $price > $self->gold;

	my $settlement = $self->_get_by_id(settlements => $settlement_id);
	my $explorer = Explorer->new;
	$settlement->train_unit($explorer);
	$self->gold -= $price;
	$self->add_explorer($explorer);

	return $explorer->id;
}

sub send_worker
{
	my ($self, $worker_id, $mine_id) = @_;
	my $worker = $self->_get_by_id(workers => $worker_id);
	my $mine = $self->_get_by_id(mines => $mine_id);

	return $worker->order_work($mine->position);
}

sub send_explorer
{
	my ($self, $explorer_id, $position) = @_;
	my $explorer = $self->_get_by_id(explorers => $explorer_id);

	return $explorer->order_explore($position);
}

sub send_explorer_settle
{
	my ($self, $explorer_id, $position) = @_;
	my $explorer = $self->_get_by_id(explorers => $explorer_id);

	return $explorer->order_settle($position, $self);
}

sub resettle
{
	my ($self, $count, $settlement_from_id, $settlement_to_id) = @_;
	my $settlement_from = $self->_get_by_id(settlements => $settlement_from_id);
	my $settlement_to = $self->_get_by_id(settlements => $settlement_to_id);
	die \"Insufficient population"
		if $settlement_from->population < $count;

	my $transport = Transport->new(position => $settlement_from->position, population => $count);
	my $ret = $transport->order_resettle($settlement_to->position);
	$settlement_from->population -= $count;
	$self->add_pseudounit($transport);

	return $ret;
}

sub serialize
{
	my ($self) = @_;

	my $base = {
		turn => $self->turn,
		gold => $self->gold,
		settlements => [],
		mines => [],
		workers => [],
		explorers => [],
		pseudounits => [],
	};

	my %items = %{$self->_get_current_items};

	for my $key (keys %items) {
		if (defined $base->{$key}) {
			my $value = $items{$key};

			for my $item (@$value) {
				push $base->{$key}->@*, $item->serialize;
			}
		}
	}

	return $base;
}

1;
