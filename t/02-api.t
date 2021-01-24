use Modern::Perl "2018";
use Test::More;
use Test::Deep;
use Kelp::Test;
use HTTP::Request::Common;
use GoldRush;
use Crypt::Misc qw(is_v4uuid);

my $t = Kelp::Test->new(app => GoldRush->new);

$t->request(GET '/')
	->code_is(200)
	->content_like(qr/Gold Rush game server version \d+\.\d+/);

$t->request(GET '/new_playe')
	->code_is(404);

$t->request(GET '/new_player')
	->code_is(400)
	->json_cmp(
		{
			status => bool(0),
			error => ignore,
		}
	);

my $uuid;
$t->request(GET '/new_player?name=test')
	->code_is(200)
	->json_cmp(
		{
			status => bool(1),
			result => code(
				sub {
					$uuid = shift;
					is_v4uuid($uuid)
					?
					(1)
					:
					(0, 'player not an uuid');
				}
			)
		}
	);

$t->request(GET '/get_state?player=not-a-player')
	->code_is(403)
	->json_cmp(
		{
			status => bool(0),
			error => ignore,
		}
	);

$t->request(GET '/get_state?player=' . $uuid)
	->code_is(200)
	->json_cmp(
		{
			status => bool(1),
			result => {
				gold => ignore,
				turn => 0,
				settlements => ignore,
				explorers => ignore,
				workers => ignore,
				pseudounits => ignore,
				mines => ignore,
			},
		}
	);

done_testing;
