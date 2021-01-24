{
	modules => [
		qw(
			JSON
		)
	],

	middleware => [
		qw(
			TrailingSlashKiller
			)
	],

	middleware_init => {
		TrailingSlashKiller => {
			redirect => 1,
		},
	},
}
