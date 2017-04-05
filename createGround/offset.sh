#!/bin/bash

while read line
do
	part1=${line:0:$1}
	part2=${line:$1}
	echo $part2$part1
done
