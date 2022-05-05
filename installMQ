#!/bin/bash


## Make user group and directories
##
groupadd mqm
useradd mqm -g mqm
# Allow mqm to sudo
echo 'mqm ALL=(ALL)       NOPASSWD:ALL' >> /etc/sudoers
# add new MQ bin's to the path (won't be there until the install is donw)
echo 'PATH="$PATH:/opt/mqm92/bin"' >> ~mqm/.bashrc
echo 'export PATH' >> ~mqm/.bashrc
# make the directories
mkdir /var/mqm92
mkdir /opt/mqm92
mkdir /opt/software/IBM_MQ -p


## Expand the installation file in the software directory
##
#  (assumes you have already got the file on the server and you are inthe same dir)
mv IBM_MQ_9.2.0.2_LINUX_X86-64.tar.gz /opt/software/IBM_MQ/
cd /opt/software/IBM_MQ/
tar xvf IBM_MQ_9.2.0.2_LINUX_X86-64.tar.gz
chown -R mqm:mqm /var/mqm92 /opt/mqm92 /opt/software/IBM_MQ


## Install the software
##
cd MQServer/
# Accept the license
./mqlicense.sh << @
1
@

# package used be crtmqpkg
yum install-y rpm-build createrepo

#add installation92 suffix to rpm files and makes /opt/mqm92 as installation dir
./crtmqpkg installation92 /opt/mqm92
cd /var/tmp/mq_rpms/installation92/x86_64
# install MQ packages (can just do rpm -ivh MQ* to install the lot)
rpm -ivh MQSeriesServer_installation92-9.2.0-2.x86_64.rpm MQSeriesWeb_installation92-9.2.0-2.x86_64.rpm MQSeriesSamples_installation92-9.2.0-2.x86_64.rpm MQSeriesSDK_installation92-9.2.0-2.x86_64.rpm MQSeriesRuntime_installation92-9.2.0-2.x86_64.rpm MQSeriesMan_installation92-9.2.0-2.x86_64.rpm MQSeriesJRE_installation92-9.2.0-2.x86_64.rpm MQSeriesJava_installation92-9.2.0-2.x86_64.rpm MQSeriesGSKit_installation92-9.2.0-2.x86_64.rpm MQSeriesExplorer_installation92-9.2.0-2.x86_64.rpm 

## set up web users (optional this is not scripted)
#cp /opt/mqm92/web/mq/samp/configuration/basic_registry.xml /var/mqm/web/installations/Installation1/servers/mqweb/mqwebuser.xml
# Add userrmqwebadmin and add to group.
#
#vi /opt/mqm92/web/mq/etc/mqweb.xml 
#change httpHost from localhost to *
#
#su - mqm
#/opt/mqm92/bin/strmqweb 
#( To stop the web server use /opt/mqm92/bin/endmqweb )
#
#https://<server>:9443/ibmmq/console    (NOTE: doesn't work in Chrome)

dspmq
ps -ef | grep mqm

##### Ready to make DMGR's

