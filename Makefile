CC=gcc
FLAGS=

DESTDIR=
PREFIX=/usr

.DEFAULT_GOAL := build

install: install-hbar install-colors install-parseconf install-shtests install-glyphs
check: check-parseconf
build: build-hbar 

install-headers: src/*.h
	install -m644 src/*.h ${DESTDIR}${PREFIX}/include

install-shtests: src/shtests.sh
	install -m755 src/shtests.sh ${DESTDIR}${PREFIX}/bin/shtests

install-parseconf: src/parseconf.sh
	install -m755 src/parseconf.sh ${DESTDIR}${PREFIX}/bin/parseconf

install-hbar: build-hbar
	install -m755 bin/hbar ${DESTDIR}${PREFIX}/bin

install-colors: src/colors.list
	sh src/generate_colors.sh ${DESTDIR}${PREFIX} src/colors.list

install-glyphs: src/glyphs.sh
	install -m755 src/glyphs.sh ${DESTDIR}${PREFIX}/lib

check-parseconf: install-shtests test/parseconf.sh
	${DESTDIR}${PREFIX}/bin/shtests ./test/parseconf.sh

build-hbar: src/hbar.c install-colors
	mkdir -p bin
	${CC} src/hbar.c -o bin/hbar ${FLAGS}

clean:
	rm -r bin


# xichroot
#
install-chroot: src/xichroot.sh
	install -m755 src/xichroot.sh ${DESTDIR}${PREFIX}/bin/xichroot


# initramfs
#
install-mkinitramfs: src/mkinitramfs.sh src/initramfs-init.sh
	install -m755 src/mkinitramfs.sh ${DESTDIR}${PREFIX}/bin/mkinitramfs
	install -m755 src/initramfs-init.sh ${DESTDIR}${PREFIX}/bin/initramfs-init

