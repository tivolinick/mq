#!/bin/sh

endmqm TEST1
endmqm TEST2
endmqm TEST3
endmqm TEST4
endmqm TEST5

dltmqm TEST1
dltmqm TEST2
dltmqm TEST3
dltmqm TEST4
dltmqm TEST5

crtmqm -p 1521 TEST1
crtmqm -p 1522 TEST2
crtmqm -p 1523 TEST3
crtmqm -p 1524 TEST4
crtmqm -p 1525 TEST5

strmqm TEST1
strmqm TEST2
strmqm TEST3
strmqm TEST4
strmqm TEST5


runmqsc TEST1 << @
DEFINE QLOCAL(T1)
DEFINE QLOCAL(T1.T2) USAGE(XMITQ)
DEFINE QREMOTE(T5) RNAME(T5) RQMNAME(TEST2) XMITQ(T1.T2)
DEFINE CHANNEL(T1.T2) CHLTYPE(SDR) CONNAME('localhost(1522)') XMITQ(T1.T2)
DEFINE CHANNEL(T2.T1) CHLTYPE(RCVR)
START CHANNEL(T1.T2)
@

runmqsc TEST2 << @
DEFINE QLOCAL(T2.T3) USAGE(XMITQ)
DEFINE QLOCAL(T2.T1) USAGE(XMITQ)
DEFINE QREMOTE(T5) RNAME(T5) RQMNAME(TEST3) XMITQ(T2.T3)
DEFINE QREMOTE(T1) RNAME(T1) RQMNAME(TEST1) XMITQ(T2.T1)
DEFINE CHANNEL(T2.T3) CHLTYPE(SDR) CONNAME('localhost(1523)') XMITQ(T2.T3)
DEFINE CHANNEL(T2.T1) CHLTYPE(SDR) CONNAME('localhost(1521)') XMITQ(T2.T1)
DEFINE CHANNEL(T1.T2) CHLTYPE(RCVR) 
DEFINE CHANNEL(T3.T2) CHLTYPE(RCVR) 
START CHANNEL(T2.T3)
START CHANNEL(T2.T1)
@

runmqsc TEST3 << @
DEFINE QLOCAL(T3.T4) USAGE(XMITQ)
DEFINE QLOCAL(T3.T2) USAGE(XMITQ)
DEFINE QREMOTE(T5) RNAME(T5) RQMNAME(TEST4) XMITQ(T3.T4)
DEFINE QREMOTE(T1) RNAME(T1) RQMNAME(TEST2) XMITQ(T3.T2)
DEFINE CHANNEL(T3.T4) CHLTYPE(SDR) CONNAME('localhost(1524)') XMITQ(T3.T4)
DEFINE CHANNEL(T3.T2) CHLTYPE(SDR) CONNAME('localhost(1522)') XMITQ(T3.T2)
DEFINE CHANNEL(T2.T3) CHLTYPE(RCVR) 
DEFINE CHANNEL(T4.T3) CHLTYPE(RCVR) 
START CHANNEL(T3.T4)
START CHANNEL(T3.T2)
@

runmqsc TEST4 << @
DEFINE QLOCAL(T4.T5) USAGE(XMITQ)
DEFINE QLOCAL(T4.T3) USAGE(XMITQ)
DEFINE QREMOTE(T5) RNAME(T5) RQMNAME(TEST5) XMITQ(T4.T5)
DEFINE QREMOTE(T1) RNAME(T1) RQMNAME(TEST3) XMITQ(T4.T3)
DEFINE CHANNEL(T4.T5) CHLTYPE(SDR) CONNAME('localhost(1525)') XMITQ(T4.T5)
DEFINE CHANNEL(T4.T3) CHLTYPE(SDR) CONNAME('localhost(1523)') XMITQ(T4.T3)
DEFINE CHANNEL(T3.T4) CHLTYPE(RCVR) 
DEFINE CHANNEL(T5.T4) CHLTYPE(RCVR) 
START CHANNEL(T4.T5)
START CHANNEL(T4.T3)
@

runmqsc TEST5 << @
DEFINE QLOCAL(T5.T4) USAGE(XMITQ)
DEFINE QLOCAL(T5)
DEFINE QREMOTE(T1) RNAME(T1) RQMNAME(TEST4) XMITQ(T5.T4)
DEFINE CHANNEL(T5.T4) CHLTYPE(SDR) CONNAME('localhost(1524)') XMITQ(T5.T4)
DEFINE CHANNEL(T4.T5) CHLTYPE(RCVR) 
START CHANNEL(T5.T4)
@

