#!/bin/sh
echo "SAS_SIM.py path is "$(cd `dirname $0`;pwd)
SIM_PATH=`dirname $0`
echo "python version is ""`python -V`"
$SIM_PATH/SAS_Sim.py &
#/var/fpwork/jliu093/LTE3663/sysadapt/test/mt/tests/cbrs/SASSim/SAS_Sim.py &
