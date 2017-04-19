#!/bin/bash

txt=$1
in_start=$2
in_end=$3
in_div10k=$4
in_offset=$5

for ((i=$in_start; i<=in_end; i++)); do
	v=$(( ((i*10000)/$in_div10k)+$in_offset ))
	echo -e "\t$txt$v\t; Index #$i"
done
