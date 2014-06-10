#!/bin/sh

now() {
    echo -n "[1m>>>[0m $* " >&2
}

ok() {
    echo '\r[32;1mOK [0m' "$*" >&2
}

more() {
    echo '\r[32;1m...[0m' "$*" >&2
}

fail() {
    echo '\r[31;1mERR[0m' "Failed: $*" >&2
    exit 2
}

[ `id -u` -eq 0 ] || fail 'run as root'
ok 'The install script is running as root'

now 'Make build directory'
mkdir -p install/build && ok || fail 'mkdir -p install/build'

now 'Check for zsh'
if which zsh > /dev/null 2>&1; then
    ok
else
    more 'Install zsh using yum'
    exec > install/build/yum.log 2>&1
    yum install zsh || fail 'yum install zsh'
    ok
    exec > /dev/tty 2>&1
fi

now 'Hand control off to zsh'
cd install || fail 'cd install'
exec zsh install.zsh
fail 'exec zsh install.zsh'
