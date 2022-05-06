#!/bin/bash


# set default number of QMGRs
max=6
if [ $# -ne 0 ] ; then
  max=$1
fi

dropQMGR() {
  num=$1	
  # stop and delete QMGRs
  endmqm -i TEST${num}
  dltmqm TEST${num}
}


for (( i = 1; $i <= $max; i += 1 )) ; do
  dropQMGR $i
done

