A game server for a hackathon-like event
===========

### Name

Gold Rush - mine gold and grow your empire!

### Description

This is a Perl web game server that requires players to write programs in any
language that interact with it in a certain way. The game requires strategy and
improvisation, as some events occur randomly and has to be taken into account.
Your task is to build settlements, explore land, recruit units and gain as much
gold as possible. A person with the highest amount of gold after a given number
of turns win.

*Problem type:* optimize the process, take randomness into account.

*Required technical skills:* able to use HTTP APIs and WebSocket connections.

*Recommended skill level:* Intermediate. Likely too hard for beginners to have
fun.

*Recommended solving time:* no less than three hours for one person, as this is
the time it took the author to write the reference perl bot implementation.
Since the goal is not a simple matter of solving a puzzle, it can be back and
forth battle who has the better algorithm with live preview of current leaders.

### Player instructions

See instructions/lang.pod for game reference. Can do it in
command line with command: `pod2text instructions/lang.pod`.

### Existing implementations

The `examples` directory contains approaches to playing the game.
Caution: _SPOILERS_

### Running (with Docker)

`docker-compose up`

### Running (without Docker)

*Note: perl 5.28 with Carton required. Carton is a Perl module dependency
manager. You will need to have it installed prior to the script below: cpan
Carton*

```
carton install                              # install the dependencies
carton exec prove -l                        # test the installation
carton exec plackup -p 5000 -D runner.psgi  # daemonize the game server
carton exec ./websocket prefork             # run the websocket server
```

### Scores

After playing the game, a `scores` directory will contain scores for players. A
scores file contains multiple JSON documents, each in its own line. It
represents states of the game at different points in time (every 5 rounds).

### TODO

- Interactive scoreboard as a web page, with charts and stuff
