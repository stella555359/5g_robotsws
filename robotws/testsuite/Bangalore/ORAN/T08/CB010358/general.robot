*** Settings ***

Documentation    Script for CB010358_counterscase
...   author: veena.bhaskaran@nokia.com
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB010358_$(date +%y%m%d) general.robot



Resource    ./testsuite/Bangalore/ORAN/T08/CB010358/CB010358_Keywords.robot
Force Tags       CRT    SBTS00    FL00    QCD_MN_RAN    QCP_RAN_VRF




Suite setup        Suite Setup
Test Setup        Test Preconditions
Test Teardown     Test Postconditions
Suite Teardown     Suite Teardown


*** Test Cases ***

[TC_01][1]CB010358 Simultaneous support of NETCONF/Yang & SOAP/RP1 FH M-Plane interfaces by 2 O-DUs with PM for rx-window & trrx stats Measurements
    Performance Monitoring for rx-window-stats and trrx stats Measurements