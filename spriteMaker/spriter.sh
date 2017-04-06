#!/bin/bash

function bin2hex {
	s=$1
	case "${s:0:4}" in
		'....') echo -n \$0
		;;
		'...*') echo -n \$1
		;;
		'..*.') echo -n \$2
		;;
		'..**') echo -n \$3
		;;
		'.*..') echo -n \$4
		;;
		'.*.*') echo -n \$5
		;;
		'.**.') echo -n \$6
		;;
		'.***') echo -n \$7
		;;
		'*...') echo -n \$8
		;;
		'*..*') echo -n \$9
		;;
		'*.*.') echo -n \$A
		;;
		'*.**') echo -n \$B
		;;
		'**..') echo -n \$C
		;;
		'**.*') echo -n \$D
		;;
		'***.') echo -n \$E
		;;
		'****') echo -n \$F
		;;
	esac
	case "${s:4:4}" in
		'....') echo -n 0
		;;
		'...*') echo -n 1
		;;
		'..*.') echo -n 2
		;;
		'..**') echo -n 3
		;;
		'.*..') echo -n 4
		;;
		'.*.*') echo -n 5
		;;
		'.**.') echo -n 6
		;;
		'.***') echo -n 7
		;;
		'*...') echo -n 8
		;;
		'*..*') echo -n 9
		;;
		'*.*.') echo -n A
		;;
		'*.**') echo -n B
		;;
		'**..') echo -n C
		;;
		'**.*') echo -n D
		;;
		'***.') echo -n E
		;;
		'****') echo -n F
		;;
	esac
}


function offsetstring {
	line="$1"
	steps=$2
	len=$(( ${#line} - $steps ))
	blank="........"
	part1=${blank:0:$steps}
	part2=${line:0:$len}
	echo "$part1$part2"
}


# use either supplied sprite name or the file name
name=$2
if [ "$name" == "" ]
then
	name=$1
	name=$(basename "$name")
	name="${name%.*}"
fi

for offset in {0..7} 
do
	# Process the whole file with the current offset
	echo $name$offset:
	tac $1 | tr -cd '*.\n' | while read line
	do
		# check if line length is a multiple of 8 characters
		len=${#line}
		if [ "$(( $len % 8 ))" != "0" ]
		then
			echo "$len bytes is not a valid line length"
			exit
		fi

		# ignore empty lines
		if [ "$line" == "" ]
		then
			continue
		fi

		# move sprite to the right X pixels 
		line="$(offsetstring $line $offset)"
	
		# process one line in 8 char (1 byte) chunks
		echo -en "\t DB "
		notfirst=0
		echo "$line" | fold -b8 | while read byte
		do
			hex=$(bin2hex "$byte")
			if [ "$notfirst" == "0" ]
			then
				notfirst=1
			else
				echo -n ","
			fi
			echo -n "$hex"
		done
		echo  " ; $line"
	done
	echo ""
done
