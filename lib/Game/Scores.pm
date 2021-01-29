package Game::Scores;

use Modern::Perl "2018";
use MIME::Base64 qw(encode_base64url decode_base64url);
use JSON::MaybeXS;
use autodie ':io';

use List::Util qw(sum0);
use Path::Tiny;

my %scores;
my $dir = 'scores';
my $json = JSON->new;

sub _get_filename
{
	my ($self, $name) = @_;

	mkdir $dir unless -d $dir;
	return "$dir/" . encode_base64url($name, '');
}

sub _list_scores
{
	my ($self) = @_;

	return glob "$dir/*";
}

sub init_score
{
	my ($self, $name) = @_;
	$scores{$name} = [];

	return;
}

sub add_score
{
	my ($self, $name, $state) = @_;

	return if $scores{$name}->@*
		&& $scores{$name}[-1]{turn} eq $state->{turn};
	push $scores{$name}->@*, {
		turn => $state->{turn},
		gold => $state->{gold},

		set => scalar $state->{settlements}->@*,
		set_pos => {map { $_->{position} => $_->{population} } $state->{settlements}->@*},
		set_pop => sum0(map { $_->{population} } $state->{settlements}->@*),

		min => scalar $state->{mines}->@*,
		min_pos => {map { $_->{position} => $_->{population} } $state->{mines}->@*},
		min_pop => sum0(map { $_->{population} } $state->{mines}->@*),

		wor => scalar $state->{workers}->@*,
		wor_idle => scalar(grep{ $_->{idle} } $state->{workers}->@*),

		exp => scalar $state->{explorers}->@*,
		exp_idle => scalar(grep { $_->{idle} } $state->{explorers}->@*),
	};

	return;
}

sub save_score
{
	my ($self, $name) = @_;
	my $filename = $self->_get_filename($name);

	open my $fh, '>', $filename;
	say {$fh} $json->encode($scores{$name});
	return;
}

sub get_scores
{
	my ($self) = @_;
	my @scores = $self->_list_scores;

	my %ret;
	for my $player (@scores)
	{
		my $path = path($player);
		my $basename = $path->basename;
		$ret{decode_base64url($basename)} = $json->decode($path->slurp);
	}

	return \%ret;
}

1;
