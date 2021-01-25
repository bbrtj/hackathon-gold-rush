{
	modules => [
		qw(
			JSON
		),
	],

	middleware => [
		qw(
			Plack::Middleware::Static
		),
	],

	middleware_init => {
		'Plack::Middleware::Static' => {
			path => sub { $_ !~ m{^/api/} },
			root => "public/",
			pass_thrugh => 1,
		},
	},
}
