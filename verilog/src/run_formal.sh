#!/bin/bash
while read file
do
    echo $file
    vbuild smt2 $file yices || exit 1
done < smt.lst
