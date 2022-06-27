#!/bin/sh
JVM_DIR=/usr/lib/jvm
JAVA_BIN=/bin/java

usage () {
    cat << EOF 
xilinux-java 
    Print the name of the currently linked jvm
    non-zero exit code if none is linked
        
xilinux-java [name]
    create symlinks to /usr/lib/jvm/[name]/bin to /bin

xilinux-java [-l]
    list installed JVMs
EOF
}

get () {
    [ -h "$JAVA_BIN" ] && {
        path=$(readlink "$JAVA_BIN")
        path=${path%%/bin/java}
        path=${path##*/}
        echo $path
    } 
}

link ()  {
    [ -d "$1" ] && for bin in $1/bin/*; do 
        ln -sf $bin /bin/${bin##*/}
    done
}


[ "$#" = "0" ] && {
    get || return 1
} || {
    case "$1" in
        "-l"|"--list")
            ls -1 $JVM_DIR
            ;;
        "-h"|"--help")
            usage
            ;;
        *)
            link $1 \
            || link $JVM_DIR/$1 \
            || get
            ;;
    esac
}

