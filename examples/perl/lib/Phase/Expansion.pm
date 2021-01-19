package Phase::Expansion;

use Modern::Perl "2018";
use Moo;

with qw(Role::Phase);
use Phase::Hoarding;

use constant next_phase => Phase::Hoarding::;

sub handle {
	my ($self) = @_;

	if ($self->is_recruitment) {
		Bot::Actions->transport_population($self);
		Bot::Actions->train_explorers($self);
		Bot::Actions->train_workers($self);
	} else {
		Bot::Actions->send_explorers($self);
		Bot::Actions->send_workers($self);
	}
}

sub ended {
	my ($self) = @_;

	# we should end this phase once we're close to the end
	return $self->player->state->{turn} > 975;
}

1;
