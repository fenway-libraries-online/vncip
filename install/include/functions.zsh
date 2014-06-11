human() {
    typeset code line
    while read -r line; do
        code=${line[1,3]}
        line[1,3]=''
        case $code in
            (BG:) hbegn $line ;;
            (:OK) hokay $line ;;
            (:FA) hfail $line ;;
            (:SK) hskip $line ;;
            (:WA) hwarn $line ;;
            (:GK) hgork $line ;;
            (:1:) hsout $line ;;
            (:2:) hserr $line ;;
        esac
    done
}

config() {
    case $1 in
        (-s) read -r; print -- $2 "$REPLY" >> install.conf ;;
        (*)  awk "/^$1 / { val = substr(\$0,length(\"$1 \")+1) } END { print val }" install.conf ;;
    esac
}

step() {
    typeset skippable=true num=$1 title="$2"; shift 2
    typeset opt
    {
        for opt in $@; do
            case $opt in
                (+noskip) skippable=false ;;
                (*) gork $num "$title: unrecognized option $opt" ;;
            esac
        done
        now $num $title
        if [[ -e state/$num.okay ]] && $skippable; then
            skip
        elif step/$num > >(showout) 2> >(showerr); then
            okay
            rm -f state/$num.*
            touch state/$num.okay
        else
            fail $num "$title: see build log for details"
            rm -f state/$num.*
            touch state/$num.fail
        fi
    } | human
}

hbegn() {
    print "[1mNOW[0m $* " >&2
}

hokay() {
    print '\r[32;1mOK [0m' "$*" >&2
}

hmore() {
    print '\r[32;1m...[0m' "$*" >&2
}

hfail() {
    print '\r[31;1mERR[0m' "$*" >&2
    exit 2
}

hwarn() {
    print '\r[33;1mWRN[0m' "$*" >&2
    exit 2
}

hgork() {
    print '\r[31;1m@#?[0m' "$*" >&2
    exit 2
}

hskip() {
    print '\r[31;1mSKP[0m' "$*" >&2
    exit 2
}

hsout() {
    :
}

hserr() {
    :
}

okay() { print ':OK'"$@" }
fail() { print ':FA'"$@" }
skip() { print ':SK'"$@" }
warn() { print ':WA'"$@" }
gork() { print ':GK'"$@" }

runas() {
    typeset logname=$1; shift
    case $logname in
        (root|vger) ;;
        (*) fail "Internal error: attempt to run as $logname" ;;
    esac
    sudo -u $logname "$@"
}

showout() {
    typeset R="$(tput cuf1)"
    sed 's/^/:1:/' >&3
    print
}

showerr() {
    typeset R="$(tput cuf1)"
    sed 's/^/:2:/' >&3
    print
}
