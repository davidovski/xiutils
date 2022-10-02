#!/bin/sh
. /usr/lib/colors.sh

move_up () {
    [ ! "$1" = "-1" ] &&
        printf "\033[%dA" "$1" "0"
}

move_down () {
    [ ! "$1" = "-1" ] &&
        printf "\033[%dA" "$1"
}

count_string () {
    local c t
    $human && {
        c=$(format_bytes $completed)
        t=$(format_bytes $total)
    } || {
        c=$1
        t=$2
    }
    printf "[%s%s/%s%s]" $c $unit $t $unit
}

hbar () {
    local width terminate human text color reset unit line count
    width=$(tput cols)
    color=$BG_BLUE
    reset=$BG_DEFAULT
    terminate=false
    human=false
    line=0

    while getopts ":T:c:r:u:l:ht" opt; do
       case "$opt" in
           T)
               text="$OPTARG"
               ;;
           c)
               color="$OPTARG"
               ;;
           r)
               reset="$OPTARG"
               ;;
           u)
               unit="$OPTARG"
               ;;
           t)
               terminate=true
               ;;
           h)
               human=true
               ;;
           l)
               line="$OPTARG"
               ;;
       esac
    done
    shift $((OPTIND-1))

    [ "$#" -lt 2 ] && {
       printf "$RESET\n"
       exit 1
    }

    completed="$1"
    total="$2"

    move_up $line

    count=$(count_string $completed $total)
    printf "\r$text"
    printf "$RESET\r"
    printf "$color"
    
    reset_at=0
    [ "$total" -gt "0" ] && reset_at=$(((completed*width)/total))

    i=0
    while [ "$i" -lt "$width" ]; do 
        [ "$i" = "$reset_at" ] && printf "$reset"

        printf " "
        i=$((i+1))
    done

    move_down $line

    $terminate && printf "$RESET\n"

    exit 0
}

hbar $@
