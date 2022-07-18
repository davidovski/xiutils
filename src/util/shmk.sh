#!/bin/sh
# 
# A tool to build a single executable from a collection of shell scripts

#include colors

usage () {
    cat << EOF
${BLUE}Available Options:

EOF
}

find_file () {
    for p in $search_path; do 
        for f in $p/$1.sh $p/$1; do 
            $verbose \
                && printf "${LIGHT_BLACK}checking: $f\n" 1>&2

            [ -f "$f" ] && {
                echo "$f" 
                return 0
            }
        done
    done
    return 1
}

parse_lines () {
    included=""
    while IFS= read -r line; do 
        case "$line" in 
            "#include "*)
                file="$(find_file ${line#\#include})"
                case "$included" in 
                    *"$file"*)
                        ;;
                    *)
                        cat $file | parse_lines
                        included="$included $file"
                esac
                ;;
            "#>"*)
                eval ${line#'#>'}
                ;;
            "#!"*)
                printf "%s\n" "$line"
                ;;
            "#"*);;
            *)
                printf "%s\n" "$line"
                ;;
        esac
    done 
}

build_shmk () {
    [ -f "$1" ] || return 1
    [ ! -z "$2" ] && output="$2"
    [ -z "$output" ] && output=$(basename $1) 
    output=./${output%.*}

    $clean && {
        rm -f $output
        exit
    }

    $verbose && echo "building $1 to $output"

    [ ! -d "${output%/*}" ] && mkdir -p "${output%/*}"

    cat $1 \
        | parse_lines > ${output} &&
    [ ! -z ${entry_function} ] && echo "$entry_function" >> ${output} 
    chmod +x ${output}
}

interpret_shmk () {
    . $1
    local cmdlist=""

    DIST="./dist"
    PROGS="$PROGS $(sed -rn "s/^prog_(.*)\s*\(\)\s*\{/\1/p" $1)"
    LIBS="$LIBS $(sed -rn "s/^lib_(.*)\s*\(\)\s*\{/\1/p" $1)"
    CHECKS="$CHECKS $(sed -rn "s/^check_(.*)\s*\(\)\s*\{/\1/p" $1)"

    shift
    [ -z "$1" ] && set -- clean build check install
    while [ ! -z "$1" ]; do 
        case "$1" in
            install)
                for prog in $PROGS; do 
                    prog=$(basename $prog)
                    prog="${prog%.*}"
                    cmdlist="$cmdlist
                    install -Dm755 $DIST/$prog ${DESTDIR}/${PREFIX}/bin/$prog #Install program $prog"
                done
                for lib in $LIBS; do 
                    lib=$(basename $lib)
                    lib="${lib%.*}"
                    cmdlist="$cmdlist
                    install -Dm755 $DIST/$lib ${DESTDIR}/${PREFIX}/lib/$lib.sh #Install library $lib"
                done
                ;;
            clean)
                [ -d "$DIST" ] && cmdlist="$cmdlist
                rm -r $DIST #Clean"
                ;;
            check)
                for check in $CHECKS; do
                    command -v check_$check > /dev/null 2>&1 && cmdlist="$cmdlist
                    check_$check #Check $check"
                done
                ;;
            *) # build all programs
                search_path="$DIST $search_path"

                for lib in $LIBS; do 
                    name=$(basename $lib)
                    build_cmd=lib_$lib
                    command -v $build_cmd > /dev/null 2>&1 || {
                        build_cmd="build_shmk $lib $DIST/$name"
                    }
                    cmdlist="$cmdlist
                    $build_cmd #Build library $name"
                done

                for prog in $PROGS; do 
                    name=$(basename $prog)
                    build_cmd=prog_$prog
                    command -v $build_cmd > /dev/null 2>&1 || {
                        build_cmd="build_shmk $prog $DIST/$name"
                    }
                    cmdlist="$cmdlist
                    $build_cmd #Build program $name"
                done

                # build all libs
                ;;
        esac
        shift
    done

    local out len i
    $verbose && out=/dev/stdout || out=/dev/null
    len=$(($(echo "$cmdlist" | wc -l)-1))
    i=-1
    echo "$cmdlist" | while read -r cmd; do
        i=$((i+1))
        printf "${LIGHT_BLACK}[${LIGHT_BLUE}%s${LIGHT_BLACK}/${LIGHT_BLUE}%s${LIGHT_BLACK}] ${LIGHT_WHITE}%s${RESET}\n" "$i" "$len" "${cmd#*#}"
        ${cmd%#*} 2>&1 > $out || {
            printf "${RED}Error $?\n"
            exit 1
        }
    done
}

search_path=".
/usr/lib
/usr/local/lib
/usr/share/shmk
"

verbose=false
clean=false

while getopts ":e:I:o:chv" opt; do
    case "${opt}" in 
        e)
            entry_function="$OPTARG"
            ;;
        o)
            output="$OPTARG"
            ;;
        c)
            clean=true
            ;;
        I)
            search_path="$search_path
            $OPTARG"
            ;;
        v)
            verbose=true
            ;;
        h)
            usage && exit 0
            ;;
    esac
done

shift $((OPTIND-1))

[ -z $1 ] && {
    exit 1
}

echo "$0 $*"
[ -f "$1" ] && shebang="$(head -1 $1)"
case "$shebang" in 
    "#!"*"shmk"*)
        interpret_shmk $@
    ;;
    *)
        build_shmk $@
    ;;
esac


