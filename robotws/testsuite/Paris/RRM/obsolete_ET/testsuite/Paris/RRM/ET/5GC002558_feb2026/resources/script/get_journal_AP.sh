#!/bin/bash
#Script to collect the Airphone journal logs.
#Author: Nasmoudine TOYB. 

#----------------------------- Variable ----------------------
LOG_DIRECTORY=/tmp/Logs_AP
IP_L2=192.168.253.84
LOG_PATH_APL3=/tmp/startup_l3.log
LOG_PATH_L2=/tmp/node_L2RT00/tmp/ASP*
#----------------------------- Function ------------------------------
function remove_dir()
  {
  rm -rf $LOG_DIRECTORY
  }

function make_directories()
  {
   mkdir $LOG_DIRECTORY
   mkdir $LOG_DIRECTORY/node_L2SM
   mkdir $LOG_DIRECTORY/asik_master/
   mkdir $LOG_DIRECTORY/asik_slave/
   mkdir $LOG_DIRECTORY/abil_master/
   mkdir $LOG_DIRECTORY/abil_slave/
  }

function get_journals()
  {
   journalctl -ab> $LOG_DIRECTORY/asik_master/Asik_Master_Journal.log
   bsh 1 journalctl -ab> $LOG_DIRECTORY/asik_slave/Asik_Slave_Journal.log
   bsh 1:0 journalctl -ab> $LOG_DIRECTORY/abil_master/Abil_Master_Journal.log
   bsh 1:1 journalctl -ab> $LOG_DIRECTORY/abil_slave/Abil_Slave_Journal.log
   bsh 1:2 journalctl -ab> $LOG_DIRECTORY/phoner_Journal.log
  }

function get_startup_default()
  {
   cp /tmp/startup_DEFAULT.* $LOG_DIRECTORY/asik_master
   cp /tmp/startup_BTSOM.log $LOG_DIRECTORY/asik_master
   cp /tmp/startup_BM.log $LOG_DIRECTORY/asik_master
   scp toor4nsn@192.168.253.81:/tmp/startup_DEFAULT* $LOG_DIRECTORY/asik_slave/.
   scp toor4nsn@192.168.253.84:/tmp/startup_DEFAULT* $LOG_DIRECTORY/abil_master/.
   scp toor4nsn@192.168.253.85:/tmp/startup_DEFAULT* $LOG_DIRECTORY/abil_slave/.
  }

function get_specifics()
  {
   scp toor4nsn@$IP_L2:$LOG_PATH_L2 /tmp/Logs_AP/node_L2SM
   scp toor4nsn@192.168.253.85:/tmp/ASP* /tmp/Logs_AP/abil_slave
   cp $LOG_PATH_APL3 /tmp/Logs_AP
  }

#----------------------------- Main ------------------------------
echo "START"
remove_dir
make_directories
get_journals
get_startup_default
get_specifics
echo "END END"
