#!/bin/sh

HBAR=./bin/hbar
TEXT="Hello there"
UNIT="mb"
MAX=100

for x in $(seq $MAX); do
    ${HBAR} -T "${TEXT}" -u ${UNIT} $x $MAX
    sleep 0.01
done
${HBAR} -t -T "${TEXT}" -u ${UNIT} $x $MAX

hbar
for x in $(seq $MAX); do
    ${HBAR} -l 0 -T "${TEXT}" $((MAX - x)) $MAX
    ${HBAR} -l 1 -T "${TEXT}" $x $MAX
    sleep 0.01
done
${HBAR} -l 1 -T "${TEXT}" $x $MAX
${HBAR} -l 0 -t -T "${TEXT}" $((MAX-x)) $MAX

MAX=20000000

for x in $(seq 0 991 $MAX); do
    ${HBAR} -h -T "${TEXT}" $x $MAX
    sleep 0.01
done
${HBAR} -ht -T "${TEXT}" $x $MAX
