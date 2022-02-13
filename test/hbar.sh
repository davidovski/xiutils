#!/bin/bash

HBAR=./bin/hbar
TEXT="Hello there"
UNIT="mb"
MAX=100


echo
for x in $(seq $MAX); do
    ${HBAR} -T "${TEXT}" -u ${UNIT} $x $MAX
    sleep 0.01
done
${HBAR} -t -T "${TEXT}" -u ${UNIT} $x $MAX

echo 1; echo 2
for x in $(seq $MAX); do
    ${HBAR} -l 1 -T "${TEXT}" -u ${UNIT} $((MAX - x)) $MAX
    ${HBAR} -l 2 -T "${TEXT}" -u ${UNIT} $x $MAX
    sleep 0.01
done
${HBAR} -l 1 -t -T "${TEXT}" -u ${UNIT} $((MAX-x)) $MAX
${HBAR} -l 2 -t -T "${TEXT}" -u ${UNIT} $x $MAX
