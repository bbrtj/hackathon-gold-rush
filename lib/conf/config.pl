{
	modules => [
		qw(
			JSON
			Symbiosis
			WebSocket::AnyEvent
			)
	],

	modules_init => {
		'WebSocket::AnyEvent' => {
			mount => '/ws',
			serializer => 'json'
		}
	},

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
