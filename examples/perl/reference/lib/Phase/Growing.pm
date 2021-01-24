package Phase::Growing;

use Modern::Perl "2018";
use Moo;
use List::Util qw(sum);
use Bot::Actions;

with qw(Role::Phase);
use Phase::Expansion;

use constant next_phase => Phase::Expansion::;

sub handle
{
	my ($self) = @_;

	if ($self->is_recruitment) {
		Bot::Actions->transport_population($self);
	}
	else {
		Bot::Actions->send_explorers($self);
		Bot::Actions->send_workers($self);
	}
}

sub ended
{
	my ($self) = @_;

	my $total_population = sum map
	{
		$_->{population};
	}
	$self->player->state->{settlements}->@*;

	# we can end this phase when we grow a bit
	return $total_population > 40;
}

1;
