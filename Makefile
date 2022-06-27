DESTDIR=
PREFIX=/usr
.DEFAULT_GOAL := build

export PATH := .:$(PATH)

shmk0:
	@echo shmk stage0
	@install -m755 src/util/shmk.sh shmk

bootstrap: shmk0
	@echo shmk stage1
	@./shmk.shmk build
	@install -m755 dist/shmk shmk

build: bootstrap
	@echo all xiutils
	@./build.shmk build

clean:
	@rm -r dist
	@rm -r shmk
	@./build.shmk clean

check:
	@./build.shmk check

install:
	@./build.shmk install


