use Modern::Perl "2018";
use Test::More;
use KelpX::Symbiosis::Test;
use HTTP::Request::Common;
use GoldRush;

my $t = KelpX::Symbiosis::Test->wrap(app => GoldRush->new);

$t->request(GET '/')
	->code_is(200)
	->content_like(qr/Gold Rush game server version \d+\.\d+/);

done_testing;
