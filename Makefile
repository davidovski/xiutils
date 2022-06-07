FLAGS=

DESTDIR=
PREFIX=/usr

DIST=dist

.DEFAULT_GOAL := build

install: build install-hbar install-colors install-parseconf install-shtests install-glyphs install-xitui install-xilib
check: check-parseconf
build: make-dist hbar shtests parseconf colors

make-dist:
	mkdir -p ${DIST}

install-headers: src/*.h
	install -Dm644 src/*.h ${DESTDIR}${PREFIX}/include

install-shtests: shtests
	install -Dm755 ${DIST}/shtests ${DESTDIR}${PREFIX}/bin/shtests

install-parseconf: parseconf
	install -Dm755 ${DIST}/parseconf ${DESTDIR}${PREFIX}/bin/parseconf

install-hbar: hbar
	install -Dm755 ${DIST}/hbar ${DESTDIR}${PREFIX}/bin

install-colors: src/colors.list
	install -Dm755 ${DIST}/colors.sh ${DESTDIR}${PREFIX}/lib/colors.sh
	install -Dm755 ${DIST}/colors.h ${DESTDIR}${PREFIX}/include/colors.h

install-glyphs: src/glyphs.sh
	install -Dm755 src/glyphs.sh ${DESTDIR}${PREFIX}/lib

install-xitui: src/xitui.sh
	install -Dm755 src/xitui.sh ${DESTDIR}${PREFIX}/lib

install-xilib: src/xilib.sh
	install -Dm755 src/xilib.sh ${DESTDIR}${PREFIX}/lib

check-parseconf: shtests parseconf test/parseconf.sh
	${DIST}/shtests ./test/parseconf.sh


hbar: colors src/hbar.c 
	${CC} -I${DIST} src/hbar.c -o ${DIST}/hbar ${FLAGS}

shtests: src/shtests.sh
	install -Dm755 src/shtests.sh ${DIST}/shtests

parseconf: src/parseconf.sh
	install -Dm755 src/parseconf.sh ${DIST}/parseconf

colors: src/colors.list
	cp src/colors.sh ${DIST}
	cp src/colors.h ${DIST}

clean:
	rm -r ${DIST}


# xichroot
#
install-chroot: src/xichroot.sh
	install -Dm755 src/xichroot.sh ${DESTDIR}${PREFIX}/bin/xichroot


# default-jvm
#
install-chroot: src/default-jvm.sh
	install -Dm755 src/default-jvm.sh ${DESTDIR}${PREFIX}/bin/default-jvm

