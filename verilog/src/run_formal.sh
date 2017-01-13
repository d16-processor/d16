#!/bin/bash
while read file
do
    echo $file
    vbuild formal $file || exit 1
    vbuild smt2 $file yices || exit 1
done < smt.lst
