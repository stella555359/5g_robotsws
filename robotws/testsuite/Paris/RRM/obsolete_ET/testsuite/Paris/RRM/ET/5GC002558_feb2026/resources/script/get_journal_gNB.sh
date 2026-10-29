#!/bin/bash
#Script to collect the gNB journal logs.
#Author: Nasmoudine TOYB. 

#----------------------------- Variable ----------------------
LOG_DIRECTORY=/tmp/Logs_gNB
#----------------------------- Function ------------------------------
function remove_dir()
  {
  rm -rf $LOG_DIRECTORY
  }

function make_directories()
  {
   mkdir $LOG_DIRECTORY
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
   bsh 1:2 journalctl -ab> $LOG_DIRECTORY/Loner_Journal.log
  }

function get_startup_default()
  {
   cp /tmp/startup_DEFAULT.* $LOG_DIRECTORY/asik_master
   cp /tmp/startup_BTSOM.log $LOG_DIRECTORY/asik_master
   cp /tmp/startup_BM.log $LOG_DIRECTORY/asik_master
   scp toor4nsn@192.168.253.17:/tmp/startup_DEFAULT* $LOG_DIRECTORY/asik_slave/.
   scp toor4nsn@192.168.253.20:/tmp/startup_DEFAULT* $LOG_DIRECTORY/abil_master/.
   scp toor4nsn@192.168.253.21:/tmp/startup_DEFAULT* $LOG_DIRECTORY/abil_slave/.
  }
  
function get_containers_asik_master()
  {
   mkdir -p $LOG_DIRECTORY/asik_master/node_CPCL && \
   cp /tmp/node_CPCL00/tmp/startup_* $LOG_DIRECTORY/asik_master/node_CPCL	
   mkdir -p $LOG_DIRECTORY/asik_master/node_CPIF && \
   cp /tmp/node_CPIF00/tmp/startup_* $LOG_DIRECTORY/asik_master/node_CPIF		
   mkdir -p $LOG_DIRECTORY/asik_master/node_CPNB && \
   cp /tmp/node_CPNB00/tmp/startup_* $LOG_DIRECTORY/asik_master/node_CPNB	
  }

function get_containers_asik_slave()
  {
   mkdir -p $LOG_DIRECTORY/asik_slave/node_CPRT && \
   scp toor4nsn@192.168.253.17:/tmp/node_CPRT00/tmp/startup_* $LOG_DIRECTORY/asik_slave/node_CPRT	
   mkdir -p $LOG_DIRECTORY/asik_slave/node_CPNRT && \
   scp toor4nsn@192.168.253.17:/tmp/node_CPNRT00/tmp/startup_* $LOG_DIRECTORY/asik_slave/node_CPNRT	
  }

function get_containers_abil_master()
  {
   mkdir -p $LOG_DIRECTORY/abil_master/node_CPUE && \
   scp toor4nsn@192.168.253.20:/tmp/node_CPUE20/tmp/startup_* $LOG_DIRECTORY/abil_master/node_CPUE	
   mkdir -p $LOG_DIRECTORY/abil_master/node_UPUE && \
   scp toor4nsn@192.168.253.20:/tmp/node_UPUE20/tmp/ASP* $LOG_DIRECTORY/abil_master/node_UPUE
  }

function get_containers_abil_slave()
  {
   mkdir -p $LOG_DIRECTORY/abil_slave/node_L2RT && \
   scp toor4nsn@192.168.253.21:/tmp/node_L2RT20/tmp/ASP* $LOG_DIRECTORY/abil_slave/node_L2RT		
  }

#----------------------------- Main ------------------------------
echo "START"
remove_dir
make_directories
get_journals
get_startup_default
get_containers_asik_master
get_containers_asik_slave
get_containers_abil_master
get_containers_abil_slave
echo "END END"
