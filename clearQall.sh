#!/bin/bash

max=6
if [ $# -ne 0 ] ; then
  max=$1
fi

for (( i = 1; $i <= $max; i += 1 )) ; do
  ./clearQ.sh $i &
done
wait

