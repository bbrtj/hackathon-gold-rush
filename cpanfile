requires "Moo";
requires "MooX";
requires "MooX::HandlesVia";
requires "MooX::LvalueAttribute";

requires "Modern::Perl";
requires "aliased";
requires "Syntax::Keyword::Try";
requires "Type::Tiny";

requires "Kelp";
requires "Kelp::Module::WebSocket::AnyEvent";
requires "Twiggy";

requires "CryptX";

recommends "Cpanel::JSON::XS";

on test => sub {
	requires "Test::TCP";
	requires "AnyEvent::WebSocket::Client";
};
