#!/bin/bash

#uncommnet below for extra messages
debug=1

# set default number of QMGRs
max=8
if [ $# -ne 0 ] ; then
  max=$1
fi

createQMGR() {
  num=$1	
  # stop and delete QMGRs in case there have beencreated before
  endmqm -i TEST${num}
  dltmqm TEST${num}
  # Create the 5 QMGRs
  port=$(expr 1520 + $num)
  crtmqm -p ${port} TEST${num}
  # Start it up
  strmqm TEST${num}
}

configQMGR() {
  curr=$1
  max=$2
  cmd=''
  NL=$'\n'
  for (( j = 1; $j <= $max; j += 1 )) ; do
    if [ $j -eq $curr ] ; then
     continue
    fi
    port=$(expr 1520 + $j)
    # Create send and receive channels for all the other QMGRs
    # Create remote Q for each QMGR
    # Create Transmission Q for each QMGR
    cmd="$cmd ${NL} \
    DEFINE CHANNEL(T${curr}.T${j}) CHLTYPE(SDR) CONNAME('localhost(${nextport}') XMITQ(T${curr}.T${j}) ${NL} \
    DEFINE CHANNEL(T${j}.T${curr}) CHLTYPE(RCVR) ${NL} \
    DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next}) ${NL} \
    DEFINE QLOCAL(T${curr}.T${next}) USAGE(XMITQ) ${NL} \
    START CHANNEL(T${curr}.T${next}) ${NL} \
    "
  done
  [ $debug ] && echo CMD: $cmd

# Create local Q
  runmqsc TEST${curr} << @
  DEFINE QLOCAL(T${curr})
  $cmd
@
}


for (( i = 1; $i <= $max; i += 1 )) ; do
  createQMGR $i
  configQMGR $i $max
done
exit

