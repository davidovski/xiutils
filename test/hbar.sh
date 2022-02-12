#!/bin/bash

HBAR=./bin/hbar
TEXT="Hello there"
UNIT="mb"
MAX=100

for x in $(seq $MAX); do
    ${HBAR} -T "${TEXT}" -u ${UNIT} $x $MAX
    sleep 0.01
done
${HBAR} -t -T "${TEXT}" -u ${UNIT} $x $MAX
