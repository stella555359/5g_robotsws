#!/bin/bash
# Author: pawel.1.wisniewski@nokia.com
# You need to pass 5 args. 1-time for logs, 2-ue com number, 3-host_password, 4-host_login, 5-host_ip   || host=ue pc
# The  script runs command on UEPC(background via cygwin) with pseudo terminal attached to process.
sshpass -p $3 ssh -t -t $4@$5 "python C:\\\auto\\\QxdmCommand.py -t $1 -p COM$2 -c C:\\\auto\\\qxdm_conf.dmc -s C:\\\auto\\\ue_logs.hdf"
