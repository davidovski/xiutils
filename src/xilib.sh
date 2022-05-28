#!/bin/sh

# format a number into a bytes, kibibytes, mebibytes, or gibibytes
#
format_bytes () {
    case "1" in 
        "$(($1>=1<<30))") printf "$(($1>>30))GiB";;
        "$(($1>=1<<20))") printf "$(($1>>20))MiB";;
        "$(($1>=1<<10))") printf "$(($1>>10))kiB";;
        *) printf "$1B";;
    esac
}

# ensure that the user is a root user
#
checkroot () {
    [ "$(id -u)" = "0" ] || {
        printf "${RED}Please run as root!\n"
        exit 1
    }
}

# reverse the order of lines
#
reverse_lines () {
    local result=
    while IFS= read -r line; do 
        result="$line
        $result"
    done
    echo "$result" 
}


