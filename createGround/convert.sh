#!/bin/bash

linecnt=0
cnt=0
gl=0

while read line
do		
	echo Ground$(( linecnt ))ofs$1:
	linecnt=$(( linecnt + 1 ))

	echo $line | fold -b8 | while read byte
	do
		if [ "$(( cnt % 16 ))" == "0" ]; then
			echo -ne "\tDB ";
		fi
		cnt=$(( cnt + 1 ))
		case "${byte:0:4}" in
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
		case "${byte:4:4}" in
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
		if [ "$((cnt % 16))" == "0" ]; then
			echo ""
		else
			echo -n ","
		fi
	done 
done	
	