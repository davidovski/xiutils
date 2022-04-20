#!/bin/sh

PARSECONF="./dist/parseconf"
SIMPLECONF="./test/simple.conf"

test_simple_loading () {
    cat ${SIMPLECONF} | ${PARSECONF} > /dev/null
}

test_simple_parsing () {
    config="
key value
    "
    retval=$(printf "$config" | ${PARSECONF} key)
    [ "$retval" = "key:value" ]
}

test_bad_formatting () {
    config="
      key       value    
    "
    retval=$(printf "$config" | ${PARSECONF} key) 
    [ "$retval" = "key:value" ]
}

test_unecessary_semicolons () {
    config="
key value;
    "
    retval=$(printf "$config" | ${PARSECONF} key)
    [ "$retval" = "key:value" ]
}

test_extra_unecessary_semicolons () {
    config="
key value;;;;;
    "
    retval=$(printf "$config" | ${PARSECONF} key)
    [ "$retval" = "key:value" ]
}

test_mutlikey_parsing() {
    config="
key1 value1
key2 value2
key3 value3
key4 value4
    "
    retval=$(printf "$config" | ${PARSECONF} key2)
    [ "$retval" = "key2:value2" ]
}


test_list_parsing() {
    config="
list [
    a
    b
    c
    d
    e
]
    "
    retval=$(printf "$config" | ${PARSECONF} list)
    [ "$retval" = "list:a b c d e " ]
}

test_dict_parsing() {
    config="
dict {
    a 1
    b 2
    c 3
    d 4
    e 5
}
    "
    retval=$(printf "$config" | ${PARSECONF} dict.a)
    [ "$retval" = "dict.a:1" ]
}

test_file_input () {
    retval=$(${PARSECONF} -f ${SIMPLECONF} key2)
    [ "$retval" = "key2:value2" ]
}

test_include () {
    config="
include test/simple.conf
    "
    retval=$(printf "$config" | ${PARSECONF} key2)
    [ "$retval" = "key2:value2" ]
}

test_glob_matching () {
    config="
dict {
    a 1
    b 2
    c 3
    d 4
}
    "
    retval=$(printf "$config" | ${PARSECONF} "dict.*" | wc -l)
    [ "$retval" = "4" ]
}

test_glob_max_count () {
    config="
dict {
    a 1
    b 2
    c 3
    d 4
}
    "
    retval=$(printf "$config" | ${PARSECONF} -c 1 "dict.*")
    [ "$retval" = "dict.a:1" ]
}

