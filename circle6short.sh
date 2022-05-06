#!/bin/bash

#uncommnet below for extra messages
#debug=1

# set default number of QMGRs
max=6
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
  # work out previous QMGR
  if [ $curr -eq 1 ] ; then
    prev=$max
  else
    prev=$(expr $curr - 1)
  fi
  # work out next QMGR

  if [ $curr -eq $max ] ; then
    next=1
  else
    next=$(expr $curr + 1)
  fi

  [ $debug ] && echo "$prev $curr $next MAX:$max"




  # Setup QMGR TEST${curr}
  # Local Q to receive messages
  # 2 Transmission Qs
  # 2 Remote Q to send messages to TEST${next}
  # 2 Remote Q to send messages to TEST${prev}
  # 2 Send and 2 Receive channel
  # main remote Qs
  # backup remote Qs
  cmd=''
  NL=$'\n'
  for (( j = 1; $j < $max; j += 1 )) ; do
    rq=$(expr $curr + $j)
    if [ $rq -gt $max ] ; then
      rq=$(expr $rq - $max)
    fi
    # remote Q's prefix with T point a the shortest route
    half=$(expr $max / 2)
    # if next QMGR is target RNAME starts T not BT
    bprev=BT
    bnext=FT
    if [ $rq -eq $prev ] ; then
    [ $debug ] && echo 'bprev=T'
    bprev=T
    fi
    if [ $rq -eq $next ] ; then
    [ $debug ] && echo 'bnext=T'
    bnext=T
    fi
    [ $debug ] && echo "PREV:$prev:$bprev NEXT:$next:$bnext J:$j HALF:$half"
    if [ $j -le $half ] ; then
      [ $debug ] && echo FIRST
      cmd="$cmd ${NL} \
      DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next}) ${NL} \
      DEFINE QREMOTE(FT${rq}) RNAME(${bnext}${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next}) ${NL} \
      DEFINE QREMOTE(BT${rq}) RNAME(${bprev}${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev})"
      [ $debug ] && echo "DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next})"
      [ $debug ] && echo "DEFINE QREMOTE(FT${rq}) RNAME(${bnext}${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next})"
      [ $debug ] && echo "DEFINE QREMOTE(BT${rq}) RNAME(${bprev}${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev})"

    else
      [ $debug ] && echo SECOND
      cmd="$cmd ${NL}
      DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev}) ${NL}
      DEFINE QREMOTE(FT${rq}) RNAME(${bnext}${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next}) ${NL} \
      DEFINE QREMOTE(BT${rq}) RNAME(${bprev}${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev})"
      [ $debug ] && echo "DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev})"
      [ $debug ] && echo "DEFINE QREMOTE(FT${rq}) RNAME(${bnext}${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next})"
      [ $debug ] && echo "DEFINE QREMOTE(BT${rq}) RNAME(${bprev}${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev})"
    fi
  
  done
  [ $debug ] && echo CMD: $cmd
  prevport=$(expr 1520 + $prev)
  nextport=$(expr 1520 + $next)

  runmqsc TEST${curr} << @
  DEFINE QLOCAL(T${curr})

  DEFINE QLOCAL(T${curr}.T${next}) USAGE(XMITQ)
  DEFINE QLOCAL(T${curr}.T${prev}) USAGE(XMITQ)

  DEFINE CHANNEL(T${curr}.T${prev}) CHLTYPE(SDR) CONNAME('localhost(${prevport}') XMITQ(T${curr}.T${prev})
  DEFINE CHANNEL(T${curr}.T${next}) CHLTYPE(SDR) CONNAME('localhost(${nextport}') XMITQ(T${curr}.T${next})
  DEFINE CHANNEL(T${prev}.T${curr}) CHLTYPE(RCVR)
  DEFINE CHANNEL(T${next}.T${curr}) CHLTYPE(RCVR)
  START CHANNEL(T${curr}.T${prev})
  START CHANNEL(T${curr}.T${next})
  $cmd
@
}

# ===== MAIN =====
for (( i = 1; $i <= $max; i += 1 )) ; do
  createQMGR $i
  configQMGR $i $max
done
exit

