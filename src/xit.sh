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
    export LINES=$(tput lines)
    export COLUMNS=$(tput cols)
    t_styl_cur l
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
        [ "${#line}" -gt "$max" ] && max=${#line}
    done
    echo "$max"
}

t_styl_cur () {
    case "$1" in
        H) printf "\033[2 q";;
        H0) printf "\033[1 q";;
        l) printf "\033[6 q";;
        l0) printf "\033[5 q";;
        _) printf "\033[4 q";;
        _0) printf "\033[3 q";;
        *) printf"\033[0 q]";;
    esac > $(tty)
}


t_gen_ptrn () {
    export P=""
    for l in $(seq 7); do 
        for c in $(seq $COLUMNS); do
            case "$l" in
                1) [ "$((c%8))" != "0" ] ;;
                2) [ "$((c%8))" = "1" ] || [ "$((c%8))" = "7" ] ;;
                3) [ "$((c%2))" = "1" ] || [ "$((c%8))" = "4" ] ;;
                4) [ "$((c%2))" = "1" ] ;;
                5) [ "$((c%2))" != "0" ] || [ "$((c%8))" = "2" ] ;;
                6) [ "$((c%8))" = "5" ] || [ "$((c%8))" = "7" ] ;;
                7) [ "$((c%8))" != "6" ] ;;
                *) false ;;
            esac && P="$P█" || P="$P "
        done
        P="$P\n"
    done
}

t_prnt_ptrn () {
    printf "$@$P"
}

t_cls_ptrn () {
    tput cup 7 0
    printf " %.0s" $(seq $(( (LINES-14) * COLUMNS)))
    t_drw_ptrn
}

t_drw_ptrn () {
    t_drw_txt 0 0 "$P"
    t_drw_txt 0 $((LINES-7)) "$(printf "$P" | rev)"
}

# draws inside the given area
#   t_drw_box x y w h
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

# draw text at location
#   t_drw_txt x y [txt...]
#
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
    eval $(h_txt_w_h "$@\n")
    eval $(h_cntr $w $h)
    t_drw_box $((x-1)) $((y-1)) $((w+2)) $((h+2))
    t_drw_txt $x $y "$@"
}

h_drw_btns () {
    local btn_y=$1 sel=$2 i=0
    while read -r btn; do
        set -- $btn
        x=$1; shift; txt="${RESET}$@"

        [ "$sel" = "$i" ] \
            && txt="${COLOR_BG}$@"

        t_drw_txt $x $btn_y "$txt${RESET}" 
        i=$((i+1))
    done
}

h_cntr() {
    local w=$1 h=$2
    echo "x=$(( ( (COLUMNS+w)/2 ) - w ))"
    echo "y=$(( ( (LINES+h)/2 ) - h ))"
}

h_txt_w_h() {
    echo "w=$(printf "$*" | max_line_length)"
    echo "h=$(printf "$*" | wc -l)"
}

t_dialog() {
    local msg="$1"; shift

    local btns_len="$#" w_btns=$(echo "$*" | wc -c)

    eval $(h_txt_w_h "$msg\n$@\n")
    eval $(h_cntr $w $h)

    local btn_y=$((y+h-1)) \
        btn_x=$(( ((COLUMNS+w_btns) / 2) - w_btns ))

    btns="" 
    for btn in "$@"; do
        btns="$btns$btn_x $btn\n"
        btn_x=$((btn_x+${#btn}+1))
    done

    t_drw_box $((x-1)) $((y-1)) $((w+2)) $((h+2)) 
    t_drw_txt $x $y "$msg"

    local sel="0"
    while true; do
        printf "$btns" | h_drw_btns $btn_y $sel

        case "$(readc)" in
            '') break;;
            '[A'|'[C'|'	') 
                sel=$(((sel+1)%btns_len));;
            '[B'|'[D') 
                sel=$(((sel+i-1)%btns_len));;
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
    t_no_cur > $(tty)
}

t_tail() {
    t_drw_txt 0 7 "$(tail -$((LINES-14)) $1)"
}


t_demo () {
    t_init
    t_no_cur
    t_drw_ptrn "${COLOR_FG}"
    t_prompt "Hello world?"
    
    t_dialog "Can a match box?" "<Yes>" "<No>" "<No but a tin can>"

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

t_demo
