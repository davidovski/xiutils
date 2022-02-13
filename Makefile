CC=gcc
FLAGS=

DESTDIR=
PREFIX=/usr


.DEFAULT_GOAL := build

install: install-hbar install-headers
build: build-hbar

install-headers: src/*.h
	install -m644 src/*.h ${DESTDIR}${PREFIX}/include

install-hbar: bin/hbar
	install -m755 bin/hbar ${DESTDIR}${PREFIX}/bin

build-hbar: src/hbar.c
	${CC} src/hbar.c -o bin/hbar ${FLAGS}

prepare:
	rm -rf bin
	mkdir -pv bin
	
