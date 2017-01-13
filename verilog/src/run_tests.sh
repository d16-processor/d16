#!/bin/bash
TESTBENCHES=$(ls *_tb.v)
for test in $TESTBENCHES 
do
    vbuild test $test
done
