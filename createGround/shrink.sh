#!/bin/bash

declare -a big
declare -a small

readarray big < $1

grpsiz=8

for j in {0..159} 
do
	grp=$(( $j * $grpsiz ))
	for i in {0..13}
	do
		if [ "${big[i]:$grp:$grpsiz}" == "........" ] 
		then
			small[$i]=${small[i]}"."
		else
			small[$i]=${small[i]}"*"
		fi
	done
done

for i in {0..13}
do
	echo ${small[$i]}
done
