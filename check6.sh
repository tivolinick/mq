max=6
dspmq -l

#for (( i = 1; $i <= $max; i += 1 )) ; do
#  for (( j = 1; $j <= $max; j += 1 )) ; do
#    if [ $i -eq $j ] ; then
#      continue
#    fi
#    /opt/mqm92/samp/bin/amqsput T${j} TEST${i} << EOF
#FROM TEST${i} for T${j}
#EOF
#    /opt/mqm92/samp/bin/amqsput BT${j} TEST${i} << EOF
#FROM TEST${i} for BT${j}
#EOF

#  done
#done



#DISPLAY CHANNEL(*)

for (( i = 1; $i <= $max; i += 1 )) ; do
  runmqsc TEST${i} << EOF
  DISPLAY CHSTATUS(*) STATUS

EOF
done
