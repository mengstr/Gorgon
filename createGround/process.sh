#!/bin/bash
touch $1.Z80
rm $1.Z80
cat $1 | ./wrap.sh | ./offset.sh 0 | ./convert.sh 0 >> $1.Z80
cat $1 | ./wrap.sh | ./offset.sh 2 | ./convert.sh 1 >> $1.Z80
cat $1 | ./wrap.sh | ./offset.sh 4 | ./convert.sh 2 >> $1.Z80
cat $1 | ./wrap.sh | ./offset.sh 6 | ./convert.sh 3 >> $1.Z80
