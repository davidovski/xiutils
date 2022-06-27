#!/bin/sh
#
# Simple shell test suite
#
# will run all functions with a name starting with test_ 
# the return value of said function will determine if its a pass or fail
#
# to run a shell file full of unit tests, run:
#   shtests [FILE]
#

#include colors

PASS="${BLUE}[ ${GREEN}PASS${BLUE} ]${RESET}"
FAIL="${BLUE}[ ${RED}FAIL${BLUE} ]${RESET}"

V=false

runtest () {
    test_name=$(echo $1 | sed "s/_/ /g")
    test_func="$2"
    printf "${BLUE}[      ] ${RESET}$test_name ";
    if "$test_func" ; then
        printf "\r$PASS\n"
        return 0
    else
        printf "\r$FAIL\n"
        return 1
    fi
}

# TODO use getopt for this
if [ "$1" = "-v" ]; then
    shift
    V=true
fi

if [ $# = "0" ]; then
    printf "${RED}No tests file has been provided\n"
    exit 1;
else
    . $@
fi

tests=$(sed -n "s/^test_\(.*\)\s*()\s*{/\1/p" $@)
total=$(echo $tests | wc -w)
passed=0
failed=0

printf "${BLUE}Running $total tests: \n"
for name in $tests; do
    if runtest "$name" "test_$name"; then
        passed=$((passed+1))
    else
        failed=$((failed+1))
    fi
done

printf "\n${BLUE}Summary for $total tests:\n"
printf "\t${PASS} $passed\n"
printf "\t${FAIL} $failed\n"
printf "\n"

[ "$passed" = "$total" ] || exit 1


