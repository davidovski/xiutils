#!/bin/sh

HBAR=./dist/hbar
UNIT="mb"
MAX=100

TEXT="✓ Привет World Привет World Привет World Привет World Привет World Привет World "
for x in $(seq $MAX); do
    ${HBAR} -T "${TEXT}" -u ${UNIT} $x $MAX
    #sleep 0.01
done

sleep 1
clear
echo Doing hello there bar
sleep 1

TEXT="Hello there"

${HBAR} -t -T "${TEXT}" -u ${UNIT} $x $MAX
for x in $(seq $MAX); do
    ${HBAR} -T "${TEXT}" -u ${UNIT} $x $MAX
    #sleep 0.01
done
${HBAR} -t -T "${TEXT}" -u ${UNIT} $x $MAX

sleep 1
clear
echo Doing 2 bars at the same time 
sleep 1

hbar
for x in $(seq $MAX); do
    ${HBAR} -l 0 -T "${TEXT}" $((MAX - x)) $MAX
    ${HBAR} -l 1 -T "${TEXT}" $x $MAX
done
${HBAR} -l 1 -T "${TEXT}" $x $MAX
${HBAR} -l 0 -t -T "${TEXT}" $((MAX-x)) $MAX

MAX=20000000

sleep 1
clear
echo Doing long bar 
sleep 1

for x in $(seq 0 991 $MAX); do
    ${HBAR} -h -T "${TEXT}" $x $MAX
done
${HBAR} -ht -T "${TEXT}" $x $MAX
