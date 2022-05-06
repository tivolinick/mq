#!/bin/bash
max=6
if [ $# -ne 0 ] ; then
  max=$1
fi

#dspmq -l
#114  DISPLAY CHANNEL(*) CHTYPE(SDR) XMITQ(SND.TO.RCV)
#108  display CHSTATUS(SND.TO.RCV)

for (( i = 1; $i <= $max; i += 1 )) ; do
  for (( j = 1; $j <= $max; j += 1 )) ; do
    if [ $i -eq $j ] ; then
      continue
    fi

echo "FROM TEST${i} for T${j}"
    /opt/mqm92/samp/bin/amqsput T${j} TEST${i} << EOF
FROM TEST${i} for T${j}
EOF

echo "FROM TEST${i} for FT${j}"
    /opt/mqm92/samp/bin/amqsput FT${j} TEST${i} << EOF
FROM TEST${i} for FT${j}
EOF

echo "FROM TEST${i} for BT${j}"
    /opt/mqm92/samp/bin/amqsput BT${j} TEST${i} << EOF
FROM TEST${i} for BT${j}
EOF

  done
done




for (( i = 1; $i <= $max; i += 1 )) ; do
  depth=$((runmqsc TEST${i} << @
    DISPLAY QLOCAL(T$i) CURDEPTH
@
 ) | grep 'CURDEPTH(' | sed 's/.*(\(.*\)).*/\1/')
echo "QMGR:TEST${i} Q:T${i} DEPTH:$depth"
T[$i]=$depth





  #  /opt/mqm92/samp/bin/amqsput T3 TEST6
done
