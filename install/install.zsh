#!/bin/zsh -e

main() {
    (( UID == 0 )) || fatal 'You must run this script as the superuser (root).'
    source include/functions.zsh
    ./make-steps.pl
    #./run-steps.zsh
}

main "$@"

# vim:ft=zsh:
