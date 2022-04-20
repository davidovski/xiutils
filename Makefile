CC=gcc
FLAGS=

DESTDIR=
PREFIX=/usr

DIST=dist

.DEFAULT_GOAL := build

install: install-hbar install-colors install-parseconf install-shtests install-glyphs
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



check-parseconf: shtests parseconf test/parseconf.sh
	${DIST}/shtests ./test/parseconf.sh


hbar: colors src/hbar.c 
	${CC} -I${DIST} src/hbar.c -o ${DIST}/hbar ${FLAGS}

shtests: src/shtests.sh
	install -Dm755 src/shtests.sh ${DIST}/shtests

parseconf: src/parseconf.sh
	install -Dm755 src/parseconf.sh ${DIST}/parseconf

colors: src/colors.list
	sh src/generate_colors.sh ${DIST}/ src/colors.list

clean:
	rm -r ${DIST}


# xichroot
#
install-chroot: src/xichroot.sh
	install -Dm755 src/xichroot.sh ${DESTDIR}${PREFIX}/bin/xichroot


