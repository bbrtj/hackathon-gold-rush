package Game::Engine;

use Modern::Perl "2018";
use Game::Instance;
use Game::Util qw(generate_id parameter_checks);

my %state;

sub get_instance
{
	my $player = shift;
	die \"Unknown player"
		unless defined $state{$player};
	return $state{$player}, @_;
}

sub end_turn
{
	my ($instance) = get_instance @_;
	return $instance->end_turn;
}

sub generate_player_hash
{
	my ($name) = @_;
	my $id = generate_id "player", $name;
	$state{$id} = Game::Instance->new(player_name => $name);
	mkdir "scores";
	open my $file, ">", "scores/$name";
	return $id;
}

sub get_state
{
	my ($instance) = get_instance @_;
	return $instance->serialize;
}

sub train_worker
{
	my ($instance, $settlement_id) = get_instance @_;
	return $instance->train_worker($settlement_id);
}

sub train_explorer
{
	my ($instance, $settlement_id) = get_instance @_;
	return $instance->train_explorer($settlement_id);
}

sub send_worker
{
	my ($instance, $worker_id, $mine_id) = get_instance @_;
	return $instance->send_worker($worker_id, $mine_id);
}

sub send_explorer
{
	my ($instance, $explorer_id, $position) = get_instance @_;
	parameter_checks->{position}->($position);
	return $instance->send_explorer($explorer_id, $position);
}

sub send_explorer_settle
{
	my ($instance, $explorer_id, $position) = get_instance @_;
	parameter_checks->{position}->($position);
	return $instance->send_explorer_settle($explorer_id, $position);
}

sub resettle
{
	my ($instance, $count, $settlement_from, $settlement_to) = get_instance @_;
	parameter_checks->{count}->($count);
	return $instance->resettle($count, $settlement_from, $settlement_to);
}

1;
