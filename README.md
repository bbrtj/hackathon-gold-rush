A game server for a hackathon-like event
===========

### Name
Gold Rush - mine gold and grow your empire!

### Configuration
Carton: `carton install`

cpanm: `cpanm --installdeps .`

*Note: Carton is a Perl module dependency manager. If you choose it, all of the other commands will have to start with `carton exec`.*

### Testing
`prove -l`

### Running
`plackup -s Twiggy runner.psgi`

### Instructions
See instructions/lang.pod for game reference. Can do it in command line with command: `pod2text insturctions/lang.pod`.

