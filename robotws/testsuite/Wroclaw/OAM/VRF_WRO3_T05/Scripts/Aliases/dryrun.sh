#!/bin/bash
. /home/ute/test_repo/bin/activate
cd /home/ute/MN/UTE/robotws
echo "Running a dryrun on every test suite in robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/CBRS/CRT/ directory"
sleep 2s
robot --dryrun --log /home/ute/MN/UTE/robotws/dryrun_log.html -L TRACE -b debug.log testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/CBRS/CRT/
(google-chrome /home/ute/MN/UTE/robotws/dryrun_log.html --ignore-certificate-errors &> /dev/null &)