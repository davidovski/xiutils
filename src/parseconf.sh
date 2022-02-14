#!/bin/bash

usage () {
    printf "Usage $0 "
    echo << "EOF"
OPTIONS... [FILTER]

Print the parsed config file filtering by the keys
Arguments:
    -f file         read configuration from a file, uses /dev/sdtin otherwise
    -v              only print values
    -c n            print the last [n]
EOF
}

getlevel() {
    for i in $*; do
        printf $i
        printf '.'
    done
}

parse_line() {
    [ $# == "0" ] && return

    local line="$@"
    local key=$1
    shift
    local value="$@"

    [ "$key" = "include" ] && cat $value | parse && return
    [ "$key" = "]" ] && unset list[-1] && printf "\n" && return
    [ "$key" = "}" ] && unset level[-1] && return

    case ${value: -1} in 
        "{")
            level+=("$key")
            ;;
        "[")
            list+=("$key")
            printf "$(getlevel ${level[@]})$key:"
            ;;
        *)

            [ "${#list[@]}" == "0" ] && 
                printf "$(getlevel ${level[@]})$key:$value\n" ||
                printf "$line "
            ;;
    esac
}

# print the parsed values from the config file in key:value format
#
parse () {
    local file="$1"

    export level=()
    export list=()
    while IFS= read -r line; do
        # strip whitespace
        parse_line $line 
    done < "/dev/stdin" 
}

# Use the env variable if exists
[ -z ${CONF_FILE} ] && CONF_FILE="/dev/stdin"

# initialise options
print_keys=true
count=

while getopts ":f:c:v" opt; do
    case "${opt}" in 
        f)
            [ "${OPTARG}" = "-" ] &&
                CONF_FILE="/dev/stdin" ||
                CONF_FILE="${OPTARG}"
            ;;

        v)
            print_keys=false
            ;;
        c)
            count="${OPTARG}q"
            ;;
        *)
    esac
done

shift $((OPTIND-1))

[ $# = 0 ] &&
    pattern=".*" ||
    pattern=$(sed "s/\*/[^:]*/g" <<< "$@")

$print_keys && 
    pattern="s/^($pattern:.+)/\1/p;${count}" ||
    pattern="s/^$pattern:(.+)/\1/p;${count}"

sed "s/^#.*$\|\s(\s\+)\|^\s\|\s^\|;*$//g" $CONF_FILE | parse $@ | sed -rn $pattern
