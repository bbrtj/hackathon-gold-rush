A game server for a hackathon-like event (in development)
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

*Recommended solving time:* no less than two hours. Since the goal is not a
simple matter of solving a puzzle, it can be back and forth battle who has the
better algorithm with live preview of current leaders.

### Configuration

Either Carton: `carton install`

or cpanm: `cpanm --installdeps .`

*Note: Carton is a Perl module dependency manager. If you choose to use it, all
of the other commands will have to start with `carton exec`.*

### Testing

`prove -l`

### Running

`plackup -s Twiggy runner.psgi`

### Instructions

See instructions/lang.pod for game reference. Can do it in
command line with command: `pod2text instructions/lang.pod`.

