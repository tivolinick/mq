#!/bin/bash

junctions=(0 10 0 6 0 8 3 0 5 0 1 0)

#uncommnet below for extra messages
debug=1

# set start of circle
start=6
# set default number of QMGRs
max=11

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

configQMGRline() {
  echo line${1}
}

# Number of steps from the junction to the target in the circle
calcSteps() {
  from=$1
  to=$2
  steps=$(expr ${junctions[$from]} - $to)
  
  #Adjustment when we pass through Test6/Test11
  if [ $from -eq 3 -a $to -ge 10 ] ; then
    steps=$(expr $steps + 6)
  fi
  if [ $from -eq 1 -a $to -le 7 ] ; then
      steps=$(expr $steps - 6)
  fi
  if [ $steps -lt 0 ] ; then
    steps=$(echo $steps| sed 's/-//')
  fi


  echo $steps
}


configQMGR() {
  curr=$1
  start=$2
  max=$3
  # number of QMGRs
  qm=$(expr $max - $start + 1)
  echo QMGR:$curr
  # work out previous QMGR
  if [ $curr -eq $start ] ; then
    prev=$max
  else
    prev=$(expr $curr - 1)
  fi
  # work out next QMGR

  if [ $curr -eq $max ] ; then
    next=$start
  else
    next=$(expr $curr + 1)
  fi

  [ $debug ] && echo "PCN: $prev $curr $next"


  # Setup QMGR TEST${curr}
  # Local Q to receive messages
  # 2 Transmission Qs
  # 2 Remote Q to send messages to TEST${next}
  # 2 Remote Q to send messages to TEST${prev}
  # 2 Send and 2 Receive channel
  # main remote Qs
  # backup remote Qs

  #prepare route info for T1 -T5
  extras=('' '' '' '' '' '' '' '' '' '' '' '')
  for (( j = 1; $j <= 5; j += 1 )) ; do
    route=$(calcRoute $curr $j | cut -d ':' -f2)
    extras[$route]="${extras[$route]} $j"
    echo "$curr $j $route"
  done
  echo EXTRAS:${extras[@]}
  # return

  cmd=''
  NL=$'\n'
  for (( j = 0; $j < $qm; j += 1 )) ; do
    if [ $j -eq 0 ] ; then
      jnext=${junctions[$curr]}
      if [ $jnext -eq 0 ] ; then
        continue
      fi
      # add some channels and queues for a junction
      nextport=$(expr 1520 + $jnext)
      cmd="$cmd ${NL} \
      DEFINE QLOCAL(T${curr}.T${jnext}) USAGE(XMITQ) ${NL} \
      DEFINE CHANNEL(T${curr}.T${jnext}) CHLTYPE(SDR) CONNAME('localhost(${nextport}') XMITQ(T${curr}.T${jnext}) ${NL} \
      DEFINE CHANNEL(T${jnext}.T${curr}) CHLTYPE(RCVR) ${NL} \
      START CHANNEL(T${curr}.T${jnext})"

      [ $debug ] && echo "${NL} \
      DEFINE QLOCAL(T${curr}.T${jnext}) USAGE(XMITQ) ${NL} \
      DEFINE CHANNEL(T${curr}.T${jnext}) CHLTYPE(SDR) CONNAME('localhost(${nextport}') XMITQ(T${curr}.T${jnext}) ${NL} \
      DEFINE CHANNEL(T${jnext}.T${curr}) CHLTYPE(RCVR) ${NL} \
      START CHANNEL(T${curr}.T${jnext})"

      for e in ${extras[$curr]} ; do
        cmd="$cmd ${NL} \
        DEFINE QREMOTE(T${e}) RNAME(T${e}) RQMNAME(TEST${jnext}) XMITQ(T${curr}.T${jnext}) ${NL} "
        [ $debug ] && echo "DEFINE QREMOTE(T${e}) RNAME(T${e}) RQMNAME(TEST${jnext}) XMITQ(T${curr}.T${jnext})"
      done
      continue
    fi
    rq=$(expr $curr + $j)
    if [ $rq -gt $max ] ; then
      rq=$(expr $rq - $qm)
    fi
    # remote Q's prefix with T point a the shortest route
    half=$(expr $qm / 2)
    
    [ $debug ] && echo "PREV:$prev:$bprev NEXT:$next:$bnext J:$j HALF:$half"
    if [ $j -le $half ] ; then
      [ $debug ] && echo FIRST
      cmd="$cmd ${NL} \
      DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next}) ${NL} "
      [ $debug ] && echo "DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next})"
      for e in ${extras[$rq]} ; do
        cmd="$cmd ${NL} \
        DEFINE QREMOTE(T${e}) RNAME(T${e}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next}) ${NL} "
        [ $debug ] && echo "DEFINE QREMOTE(T${e}) RNAME(T${e}) RQMNAME(TEST${next}) XMITQ(T${curr}.T${next})"
      done
    else
      [ $debug ] && echo SECOND
      cmd="$cmd ${NL}
      DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev}) ${NL} "
      [ $debug ] && echo "DEFINE QREMOTE(T${rq}) RNAME(T${rq}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev})"
      for e in ${extras[$rq]} ; do
        cmd="$cmd ${NL} \
        DEFINE QREMOTE(T${e}) RNAME(T${e}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev}) ${NL} "
        [ $debug ] && echo "DEFINE QREMOTE(T${e}) RNAME(T${e}) RQMNAME(TEST${prev}) XMITQ(T${curr}.T${prev}) ${NL} "
      done
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

# Work out which route to follow between line and circle
calcRoute() {
  #if to and from are both in the line or both in the circle. No junction
  if [ \( $1 -lt 6 -a $2 -lt 6 \) -o \( $1 -ge 6 -a $2 -ge 6 \) ] ; then
      echo -1
      return 1
    fi
  if [ $1 -lt $2 ] ; then
    from=$1
    to=$2
  else
    from=$2
    to=$1
  fi
  # target play
  if [ $from -eq $to ] ; then
    echo 0
    return 1
  fi
  # from line to circle.
  #if [ $from -lt 6 ] ; then
    if [ ${junctions[$from]} -ne 0 ]; then
      echo "$from:${junctions[$from]}"
    else
      closeP=$(calcSteps $(expr $from - 1) $to)
      closeN=$(calcSteps $(expr $from + 1) $to)
      if [ $closeP -lt $closeN ] ; then
        junc=$(expr $from - 1)
      else
        junc=$(expr $from + 1)
      fi
      # echo "$j: HARD BIT $closeP,$closeN"
      echo "$junc:${junctions[$junc]}"
    fi
}

# for r in $(calcRoute $1 $2) ; do
#   echo $r
# done


# ===== MAIN =====
for (( i = 1; $i <= $max; i += 1 )) ; do
  [ $debug ] && echo create $i
  echo "${junctions[$i]}"

  #createQMGR $i
  # line to line, circle to circle
  # for (( j = 1; $j <= $max; j += 1 )) ; do
  #   route=$(calcRoute $i $j)
  #   if [ $? -ne 0 ] ; then
  #     echo 'NO'
  #   else
  #     echo $route
  #   fi
    
  # done
done

for (( i = 1; $i < $start; i += 1 )) ; do
  configQMGRline $i $start $max
done
for (( i = $start; $i <= $max; i += 1 )) ; do
  configQMGR $i $start $max
done
exit

