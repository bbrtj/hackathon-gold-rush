package Game::Instance;

use Modern::Perl "2018";
use Moo;
use MooX qw(HandlesVia LvalueAttribute);
use Types::Standard qw(Int Num Str ArrayRef HashRef InstanceOf);
use aliased "Game::Element::Settlement" => "Settlement";
use aliased "Game::Element::Worker" => "Worker";
use aliased "Game::Element::Explorer" => "Explorer";
use aliased "Game::Element::Mine" => "Mine";
use aliased "Game::Element::Transport" => "Transport";
use aliased "Game::Helpers::HashCollection" => "Collection";
use Game::Settings;
use JSON qw(to_json);

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
	isa => InstanceOf["Game::Helpers::HashCollection"],
	default => sub {
		my $c = Collection->new(type => "Game::Element::Settlement");
		$c->add(Settlement->new(position => 0, population => $Game::Settings::default_population));
		return $c;
	},
	handles => {
		add_settlement => "add",
		remove_settlement => "remove",
	}
);

has "workers" => (
	is => "rw",
	isa => InstanceOf["Game::Helpers::HashCollection"],
	default => sub { Collection->new(type => "Game::Element::Worker") },
	handles => {
		add_worker => "add",
		remove_worker => "remove",
	}
);

has "explorers" => (
	is => "rw",
	isa => InstanceOf["Game::Helpers::HashCollection"],
	default => sub { Collection->new(type => "Game::Element::Explorer") },
	handles => {
		add_explorer => "add",
		remove_explorer => "remove",
	}
);

has "mines" => (
	is => "rw",
	isa => InstanceOf["Game::Helpers::HashCollection"],
	default => sub { Collection->new(type => "Game::Element::Mine") },
	handles => {
		add_mine => "add",
		remove_mine => "remove",
	}
);

has "pseudounits" => (
	is => "rw",
	isa => InstanceOf["Game::Helpers::HashCollection"],
	default => sub { Collection->new(type => undef) },
	handles => {
		add_pseudounit => "add",
		remove_pseudounit => "remove",
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

	my $href = $items->{$what}->href;
	die \"Couldn't find $what"
		unless exists $href->{$id};
	return $href->{$id};
}

sub _update_state
{
	my ($self) = @_;

	my %items = %{$self->_get_current_items};
	my @update_order = qw(settlements explorers mines workers pseudounits);

	for my $ord (@update_order) {
		my $arr = $items{$ord}->aref;
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
			my $value = $items{$key}->aref;

			for my $item (@$value) {
				push $base->{$key}->@*, $item->serialize;
			}
		}
	}

	if (($base->{turn} + 3) % 5 == 0) {
		$self->save_score($base);
	}

	return $base;
}

sub save_score
{
	my ($self, $state) = @_;
	my $state_json = to_json $state;
	my $name = $self->player_name;
	open my $file, ">>", "scores/$name";
	print $file $state_json . "\n";
}

1;
