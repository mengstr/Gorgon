#!/bin/bash

function chr {
  printf "\\$(printf '%03o' "$1")"
}

function ord {
  LC_CTYPE=C printf '%d' "'$1"
}

function bin2hex {
	s="$1"
	case "${s:0:4}" in
		'....') echo -n \$0
		;;
		'...#') echo -n \$1
		;;
		'..#.') echo -n \$2
		;;
		'..##') echo -n \$3
		;;
		'.#..') echo -n \$4
		;;
		'.#.#') echo -n \$5
		;;
		'.##.') echo -n \$6
		;;
		'.###') echo -n \$7
		;;
		'#...') echo -n \$8
		;;
		'#..#') echo -n \$9
		;;
		'#.#.') echo -n \$A
		;;
		'#.##') echo -n \$B
		;;
		'##..') echo -n \$C
		;;
		'##.#') echo -n \$D
		;;
		'###.') echo -n \$E
		;;
		'####') echo -n \$F
		;;
	esac
	case "${s:4:4}" in
		'....') echo -n 0
		;;
		'...#') echo -n 1
		;;
		'..#.') echo -n 2
		;;
		'..##') echo -n 3
		;;
		'.#..') echo -n 4
		;;
		'.#.#') echo -n 5
		;;
		'.##.') echo -n 6
		;;
		'.###') echo -n 7
		;;
		'#...') echo -n 8
		;;
		'#..#') echo -n 9
		;;
		'#.#.') echo -n A
		;;
		'#.##') echo -n B
		;;
		'##..') echo -n C
		;;
		'##.#') echo -n D
		;;
		'###.') echo -n E
		;;
		'####') echo -n F
		;;
	esac
}

cnt=0
charno=$2
cat $1  | while read line
do
    # ignore empty lines
    if [ "$line" == "" ]
    then
        continue
    fi

    # check if line length is a multiple of 8 characters
    len=${#line}
    if [ "$(( $len % 8 ))" != "0" ]
    then
        echo "$len bytes is not a valid line length"
        exit
    fi

    # Get the character for the ascii number
    if [ "$charno" == "127" ]
    then
        ch=" "
    else 
        ch=$(chr $charno)
    fi

    hex=$(bin2hex "$line")

    if [ "$cnt" == "0" ]
    then
        echo -en "\tDB "
    fi
    if [ "$cnt" == "7" ]
    then
        echo -e "$hex\t; $ch"
        cnt=0
        charno=$((charno+1))
    else
        echo -n "$hex,"
        cnt=$((cnt+1))
    fi
done

