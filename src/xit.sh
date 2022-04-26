#!/bin/sh

#################################################################
#███████ ███████ ███████ ███████ ███████ ███████ ███████ ███████#
#█     █ █     █ █     █ █     █ █     █ █     █ █     █ █     █#
#█ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █#
#█ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █#
#█ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███#
#█ █     █ █     █ █     █ █     █ █     █ █     █ █     █ █    #
#█ ███████ ███████ ███████ ███████ ███████ ███████ ███████ █████#
#                                                               #
#                                                               #
#                                                               #
#                                                               #
#                                                               #
#                                                               #
#                                                               #
#█ ███████ ███████ ███████ ███████ ███████ ███████ ███████ █████#
#█ █     █ █     █ █     █ █     █ █     █ █     █ █     █ █    #
#█ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███#
#█ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █#
#█ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █ █ ███ █#
#█     █ █     █ █     █ █     █ █     █ █     █ █     █ █     █#
#███████ ███████ ███████ ███████ ███████ ███████ ███████ ███████#
#################################################################

. /usr/lib/colors.sh

COLOR_FG=${LIGHT_BLUE}
COLOR_BG=${BG_WHITE}

t_init () {
    t_styl_cur H
    tput clear
    t_set_tty
    t_gen_ptrn

}
 
t_set_tty () {
    export SAVED_TTY_SETTINGS=$(stty -g)
    stty raw -echo
}

t_clean () {
    stty $SAVED_TTY_SETTINGS
    tput clear
    reset
}

readc () {
    stty -echo -icanon min 1 time 0
    s="$(dd bs=1 count=1 of=/dev/stdout 2>/dev/null)"
    stty -icanon min 0 time 0
    [ "$s" = "" ]  && {
        s="$s$(dd bs=1 count=2 of=/dev/stdout 2>/dev/null)"
    }   
    
    printf "$s"
} 


t_cls () {
    tput clear
}

t_no_cur () {
    tput civis
}

t_yes_cur () {
    tput cnorm
}

t_set_cur () {
    tput cup $1 $2
}

max_line_length () {
    local max=-1
    while IFS= read -r line; do
        [[ ${#line} -gt $max ]] && max=${#line}
    done
    echo "$max"
}

t_styl_cur () {
    case "$1" in
        H)
            printf "\033[2 q";;
        H0)
            printf "\033[1 q";;
        l)
            printf "\033[6 q";;
        l0)
            printf "\033[5 q";;
        _)
            printf "\033[4 q";;
        _0)
            printf "\033[3 q";;
        *)
            printf"\033[0 q]";;
    esac > $(tty)
}


t_gen_ptrn () {
    export P=""
    local wll=$(tput cols)
    for l in $(seq 7); do 
        for c in $(seq $wll); do
            case "$l" in
                1) [ "$((c%8))" != "0" ] ;;
                2) [ "$((c%8))" = "1" ] || [ "$((c%8))" = "7" ] ;;
                3) [ "$((c%2))" = "1" ] || [ "$((c%8))" = "4" ] ;;
                4) [ "$((c%2))" = "1" ] ;;
                5) [ "$((c%2))" != "0" ] || [ "$((c%8))" = "2" ] ;;
                6) [ "$((c%8))" = "5" ] || [ "$((c%8))" = "7" ] ;;
                7) [ "$((c%8))" != "6" ] ;;
                *) false ;;
            esac

            [ "$?" = "0" ] &&
                P="$P█" ||
                P="$P "

        done
        P="$P\n"
    done
}

t_prnt_ptrn () {
    printf "$@$P"
}

t_cls_ptrn () {
    local lines=$(tput lines)
    tput cup 7 0
    for i in $(seq $((lines-15))); do 
        tput el
        tput cud1
    done
    t_drw_ptrn
}

t_drw_ptrn () {
    local prfx=$1
    local flr=$(tput lines)
    t_drw_txt 0 0 "$P"
    t_drw_txt 0 $((flr-7)) "$(printf "$P" | rev)"
}

# draws inside the given area
#
# $0 x y w h
#
t_drw_box () {
    local x=$1 y=$2 w=$3 h=$4
    
    t_set_cur $y $x
    printf "${COLOR_FG}╔"
    printf "═%.0s" $(seq $((w-2)))
    printf "╗"
    for i in $(seq $((h-2))); do 
        t_set_cur $((y+i)) $x
        printf "${COLOR_FG}║"
        printf " %.0s" $(seq $((w-2)))
        printf "║"
    done

    t_set_cur $((y+h-1)) $x
    printf "${COLOR_FG}╚"
    printf "═%.0s" $(seq $((w-2)))
    printf "╝"
}

t_drw_txt () {
    local x=$1 y=$2 
    shift 2

    echo "$@" | while IFS= read -r line; do
        t_set_cur $y $x
        y=$((y+1))
        printf "${COLOR_FG}$line"
    done 
}

t_msg () {
    local msg="$@"
    local width=$(echo "$msg" | max_line_length) height=$(echo "$msg" | wc -l)
    local lines=$(tput lines) cols=$(tput cols)

    local x=$((((cols+width)/2)-width))
    local y=$((((lines+height)/2)-height))

    t_drw_box $((x-1)) $((y-1)) $((width+2)) $((height+2))
    t_drw_txt $x $y "$msg"
}

t_dialog() {
    local msg="$1"
    shift
    local btns="$@"
    local btns_len="$#"
    local btns_width=${#btns}

    local width=$(printf "$msg\n$btns" | max_line_length) height=$(echo "$msg" | wc -l)
    local lines=$(tput lines) cols=$(tput cols)

    local x=$((((cols+width)/2)-width))
    local y=$((((lines+height)/2)-height))

    local btn_y=$((y+height+1))
    local btn_x=$((((cols+btns_width)/2)-btns_width))

    btns=""
    for btn in "$@"; do
        btns="$btns$btn $btn_x "
        btn_x=$((btn_x+${#btn}+1))
    done
    height=$((height+2))

    t_drw_box $((x-1)) $((y-1)) $((width+2)) $((height+2))
    t_drw_txt $x $y "$msg"

    local btn_count=$(seq $#)


    local sel="0"

    while true; do
        set -- $btns

        for i in $btn_count; do 
            txt=$1; shift
            x=$1; shift

            [ "$((sel+1))" == "$i" ] && {
               txt="${COLOR_BG}$txt" 
            } || {
                txt="${RESET}$txt"
            }

            t_drw_txt $x $btn_y "$txt${RESET}"
        done

        c=$(readc)
        case "$c" in
            '') break;;
            '[A'|'[C'|'	') 
                sel=$(((sel+1)%btns_len)) ;;
            '[B'|'[D') 
                sel=$(((sel+btns_len-1)%btns_len));;
        esac

    done
    return $sel
}

t_prompt () {
    t_dialog "$@" "<ok>"
}

t_input () {
    stty $SAVED_TTY_SETTINGS
    t_msg "$@

>" > $(tty)
    t_yes_cur > $(tty)
    read var
    echo $var 
    t_set_tty
}

t_tail() {
    local file=$1 lines=$(tput lines)
    t_drw_txt 0 7 "$(tail -$((lines-14)) $1)"
}


t_demo () {
    t_init
    t_no_cur
    t_drw_ptrn "${COLOR_FG}"
    t_prompt "Hello world?"
    t_cls_ptrn
    name=$(t_input "Enter your name")
    t_prompt "Hello $name"

    t_cls_ptrn

    file=./xit.sh
    [ -f $file ] && {
        t_tail $file
    } || {
        t_prompt "The file $file does not exist"
    }
    t_prompt "Clear"
    t_cls_ptrn
    t_prompt "Exit?"

    t_clean
}
