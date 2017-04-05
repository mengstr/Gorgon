#!/bin/bash

while read line
do
	w=${line:0:256}
	echo $line$w
done
