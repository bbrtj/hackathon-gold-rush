use File::Basename;

my $current = dirname(__FILE__);
my $current_uri = 'file://' . $current;

requires "Moo";
requires "MooX";
requires "MooX::HandlesVia";
requires "MooX::LvalueAttribute";

requires "Modern::Perl";
requires "aliased";
requires "Syntax::Keyword::Try";
requires "Type::Tiny";

requires "Kelp", 0,
	url => "$current_uri/Kelp-1.04.tar.gz";

requires "Kelp::Module::WebSocket::AnyEvent";
requires "Kelp::Module::Symbiosis";
requires "Twiggy";

requires "CryptX";
requires "Quantum::Superpositions::Lazy";

recommends "Cpanel::JSON::XS";

on test => sub {
	requires "Test::TCP";
	requires "AnyEvent::WebSocket::Client";
};
