#!/bin/bash
DIST=$1

headerfile=${DIST}/colors.h
shlib=${DIST}/colors.sh

cat > $shlib << "EOF"
#
# colors.h
#
# list of ansi color codes
# provided by xiutils
#

EOF

cat > $headerfile << "EOF"
/*
 * colors.h
 *
 * list of ansi color codes
 * provided by xiutils
 *
 */

EOF

append_header() {
    echo "#define $1 $2" >> $headerfile
}

append_sh() {
    printf 'export %s=$(printf %s)\n' $1 $2 >> $shlib
}

while IFS= read -r line; do
    echo "$line" | grep -q "." || continue
    name=$(echo $line | awk '{ print $1 }')
    code=$(echo $line | awk '{ print $2 }')

    append_header $name $code
    append_sh $name $code
    
done < "$2"
