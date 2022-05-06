#!/bin/bash

max=6

for (( i = 1; $i <= $max; i += 1 )) ; do
  ./clearQ.sh $i &
done
wait

