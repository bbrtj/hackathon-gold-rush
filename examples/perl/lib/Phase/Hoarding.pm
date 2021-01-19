package Phase::Hoarding;

use Modern::Perl "2018";
use Moo;

with qw(Role::Phase);

sub handle {
	my ($self) = @_;

	if ($self->is_recruitment) {
		Bot::Actions->transport_population($self);
	} else {
		Bot::Actions->send_explorers($self);
		Bot::Actions->send_workers($self);
	}
}

sub ended {
	my ($self) = @_;

	return; # last phase
}

1;
