#!/bin/bash

if [ $# -ne 1 ] ; then
  echo Q number please
  exit 1
fi
if [ "$(echo $1 | egrep '^[0-9]+$')" == '' ] ; then
  echo "QMGR number only please, $1 is not a number"
  exit 2
fi
depth=1
depth=$((runmqsc TEST${1} << EOF
  DISPLAY QLOCAL(T${1}) CURDEPTH
EOF
) | grep 'CURDEPTH(' | sed 's/.*(\(.*\)).*/\1/')
echo "T${1} Initial Queue Depth $depth"

while [ $depth != 0 ] ; do
depth=$((runmqsc TEST${1} << EOF
  CLEAR QLOCAL(T${1})
  DISPLAY QLOCAL(T${1}) CURDEPTH
EOF
) | grep 'CURDEPTH(' | sed 's/.*(\(.*\)).*/\1/')
echo "T${1} Queue Depth Now $depth"
if [ $depth != 0 ] ; then
  echo "T${1} sleeping..."
  sleep 10
fi
done

