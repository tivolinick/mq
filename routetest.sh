
maps=[1:10,3:6,5:8]
start=6
max=11
for ((i=1; i<=$max ; i++ ))  do
	echo $i
	curr=$i
	# work out previous QMGR
	if [ $curr -eq $start ] ; then
		prev=$max
	else
		prev=$(expr $curr - 1)
	fi
	# work out next QMGR

	# Special case for end of line
	if [ $curr -eq 5 ] ; then
		next=0
		continue
	fi
	if [ $curr -eq $max ] ; then
		next=$start
	else
		next=$(expr $curr + 1)
	fi
	echo "PREV:$prev,NEXT:$next"

	for ((j=1; j<=$max ; j++ ))  do

		

		step=0

		echo "  :$j"
		if [ $i -eq $j ] ; then
			continue
		fi
		# Stright line
		if [ \( $i -lt $start -a $j -lt $start \) -o \( $i -ge $start -a $j -ge $start \) ] ; then
			if [ $j -gt $i ] ; then
				step=$next
			else
				step=$prev
			fi
		fi
		



		echo $i:$j $step
	done

done
