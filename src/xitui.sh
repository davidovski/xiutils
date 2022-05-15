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

COLOR_FG=${WHITE}
COLOR_FG2=${LIGHT_BLUE}
COLOR_PTRN=${LIGHT_BLUE}
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
    t_yes_cur
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
    printf "[$1;$2H"
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
    printf "[7;0H" 
    printf " %.0s" $(seq $(( (LINES-14) * COLUMNS)))
    t_drw_ptrn
}

t_drw_ptrn () {
    t_drw_txt_clr "${COLOR_PTRN}" 1 1 "$P"
    t_drw_txt_clr "${COLOR_PTRN}" 1 $((LINES-6)) "$(printf "$P" | rev)"
}

# draws inside the given area
#   t_drw_box x y w h
#
t_drw_box () {
    local x=$1 y=$2 w=$3 h=$4
    

    l="$(printf "${COLOR_FG2}║"
        printf " %.0s" $(seq $((w-2)))
        printf "${COLOR_FG2}║"
    )"
    b="$(printf "═%.0s" $(seq $((w-2))))"

    printf "[${y};${x}H${COLOR_FG2}╔$b╗"
    for i in $(seq $((y+1)) $((y+h-1))); do 
        printf "[${i};${x}H$l"
    done
    printf "[$((y+h-1));${x}H${COLOR_FG2}╚$b╝"
}

# draw text at location
#   t_drw_txt x y [txt...]
#
t_drw_txt () {
    local x=$1 y=$2 
    shift 2

    echo "$@" | while IFS= read -r line; do
        printf "[${y};${x}H$line"
        y=$((y+1))
    done 
}

# draw colored text
#
t_drw_txt_clr () {
    local clr=$1 x=$2 y=$3 
    shift 3

    echo "$@" | while IFS= read -r line; do
        printf "[${y};${x}H${clr}$line"
        y=$((y+1))
    done 
}

t_msg () {
    h_txt_w_h "$@\n"
    h_cntr $w $h
    t_drw_box $((x-1)) $((y-1)) $((w+2)) $((h+2))
    t_drw_txt_clr "${COLOR_FG}" $x $y "$@"
}

h_drw_btns () {
    local sel=$1 i=0
    while read -r btn; do
        [ "$sel" = "$i" ] && styl="${COLOR_BG}" || styl="${COLOR_FG2}"
        h_drw_btn "${styl}" ${btn}
        i=$((i+1))
    done
}

h_drw_btn () {
    styl="$1" x=$2 y=$3 ; shift 3; txt="$@"
    t_drw_txt $x $y "${COLOR_FG2}${styl}$txt${RESET}" 
}

h_cntr() {
    local w=$1 h=$2
    x=$(( ( (COLUMNS+w)/2 ) - $1 ))
    y=$(( ( (LINES+h)/2 ) - $2 ))
}

h_txt_w_h() {
    w=$(printf "$*" | max_line_length)
    h=$(printf "$*" | wc -l)
}

h_t_result() {
    local s=$1 i=0; shift
    for opt in "$@"; do
        case " $s " in 
            *" $i "*) echo "$opt";;
        esac
        i=$((i+1))
    done
}

t_dialog() {
    # TODO these are messy af
    local msg="$1"; shift
    local btns_len="$#" w_btns=$(echo "$*" | wc -c)

    h_txt_w_h "$msg\n $*\n"
    h_cntr $w $h

    local btn_y=$((y+h-1)) \
        btn_x=$(( ((COLUMNS+w_btns) / 2) - w_btns))

    btns="" 
    for btn in "$@"; do
        btns="$btns$btn_x $btn_y $btn\n"
        btn_x=$((btn_x+${#btn}+1))
    done

    t_drw_box $((x-1)) $((y-1)) $((w+2)) $((h+2)) 
    t_drw_txt_clr ${COLOR_FG} $x $y "$msg"

    local sel="0"
    while true; do
        printf "$btns" | h_drw_btns $sel

        case "$(readc)" in
            '') break;;
            '[B'|'[C'|'	') 
                sel=$(((sel+1)%btns_len));;
            '[A'|'[D') 
                sel=$(((sel+btns_len-1)%btns_len));;
        esac

    done
    export T_RESULT=$(h_t_result "$sel" "$@")
}

t_radio() {
    local msg="$1"; shift

    local btns_len="$#" w_btns=$(echo "$*" | wc -c)
    text=`{
        printf "$msg\n"
        for b in "$@"; do  
            printf "╚═$b${RESET}\n"
        done
    }`

    t_msg "$text"

    x=$((x+2)) y=$((y+1))
    local py=$((y))
    btns=""
    for btn in "$@"; do  
        btns="$btns$x $y $btn\n"
        y=$((y+1))
    done

    local sel="0"
    while true; do
        printf "$btns" | h_drw_btns $sel

        case "$(readc)" in
            '') break;;
            '[B'|'[C'|'	') 
                sel=$(((sel+1)%btns_len));;
            '[A'|'[D') 
                sel=$(((sel+btns_len-1)%btns_len));;
        esac

    done
    export T_RESULT=$(h_t_result "$sel" "$@")
}

t_check () {
    local msg="$1"; shift
    local btns_len="$#" 
    btns_len=$((btns_len+1))

    text=`{
        printf "$msg\n"
        for b in "$@"; do  
            printf "[ ] $b${RESET}\n"
        done
        printf "    <OK>${RESET}\n"
    }`

    t_msg "$text"

    x=$((x+4)) y=$((y+1))
    local py=$((y))
    btns=""
    for btn in "$@"; do  
        btns="$btns$x $y $btn\n"
        y=$((y+1))
    done
    btns="$btns$x $y <OK>\n"

    local sel="0" checked=""
    while true; do
        printf "$btns" | h_drw_btns $sel
        case "$(readc)" in
            '[B'|'[C'|'	') 
                sel=$(((sel+1)%btns_len))
                ;;
            '[A'|'[D') 
                sel=$(((sel+btns_len-1)%btns_len));;
            ' '|'') 
                [ "$((sel+1))" = "$btns_len" ] && break || {
                case " $checked " in 
                    *$sel*) 
                        checked=$(echo "$checked" | sed "s/$sel//")
                        t_drw_txt $((x-3)) $((py+sel)) " "
                        ;;
                    *)
                        checked="$checked$sel "
                        t_drw_txt $((x-3)) $((py+sel)) "x"
                        ;;
                esac
            };;
        esac
    done
    export T_RESULT=$(h_t_result "$checked" "$@")
}

t_prompt () {
    t_dialog "$@" "<ok>"
}

t_yesno () {
    t_dialog "$@" "<yes>" "<no>"
    [ "$T_RESULT" = "<yes>" ]
}

t_input () {
    stty $SAVED_TTY_SETTINGS
    t_msg "$@

>" > $(tty)
    t_yes_cu
    read var
    t_set_tty
    t_no_cur
    export T_RESULT="$var"
}

t_input_hidden () {
    stty $SAVED_TTY_SETTINGS
    stty -echo
    t_msg "$@

>" > $(tty)
    t_yes_cur
    read var
    t_set_tty
    t_no_cur
    export T_RESULT="$var"
}

t_tail() {
    t_drw_txt 0 7 "$(tail -$((LINES-14)) $1)"
}

t_paged_radio () {
    perpage=9
    heading=$1
    shift
    
    T_RESULT="more..."
    page=0
    max_pages=$((($#/perpage)+1))
    while true; do
        start=$((page*perpage))
        current=$(echo $@ | tr ' ' '\n' | tail -$(($#-start)) | head -$perpage)
        current="$current more..."

        t_cls_ptrn
        t_radio "$heading" $current
        [ "$T_RESULT" = "more..." ] && page=$(((page+1)%max_pages)) || return 0
    done
}


t_demo () {
    t_init
    t_no_cur


    t_cls_ptrn
    t_prompt "Hello world?"
    t_cls_ptrn

    t_paged_radio "Pick a number" $(seq 34)
    t_prompt "You selected the following: $T_RESULT"
    t_cls_ptrn

    exit 1

    t_radio "Pick one:" "toast" "bread" "bread but fishy" "empty sandwich"
    t_prompt "You selected the following: $T_RESULT"
    t_cls_ptrn

    t_check "Please select your order:" "yeast" "fish and chips" "twigs" "tuna" "pizza" "aspic"
    t_prompt "You selected the following: $T_RESULT"
    t_cls_ptrn
    
    t_dialog "Can a match box?" "<Yes>" "<No>" "<No but a tin can>"
    t_prompt "You selected the following: $T_RESULT"
    t_cls_ptrn

    #t_cls_ptrn
    t_input "Enter your name"
    t_prompt "Hello $T_RESULT"
    t_cls_ptrn

    file=$2.sh
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

"$@"
