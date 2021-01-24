package Phase::Setup;

use Modern::Perl "2018";
use Moo;
use Bot::Actions;

with qw(Role::Phase);
use Phase::Growing;
use Logger;

use constant next_phase => Phase::Growing::;

sub handle
{
	my ($self) = @_;

	if ($self->is_recruitment) {
		Bot::Actions->train_explorers($self);
		Bot::Actions->train_workers($self);
	}
	else {
		Bot::Actions->send_explorers($self);
		Bot::Actions->send_workers($self);
	}
}

sub ended
{
	my ($self) = @_;

	# we can end this phase when we mine gold
	return
		$self->player->state->{mines}->@* > 0
		&& $self->player->state->{settlements}->@* > 1
		&& $self->player->state->{mines}[0]{population} > 1;
}

1;
