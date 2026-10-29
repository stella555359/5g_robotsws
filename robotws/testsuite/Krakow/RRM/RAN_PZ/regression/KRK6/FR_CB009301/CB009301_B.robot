*** Settings ***
Documentation
...   Test Suite: CB009301 for 5G testing.
...   Test cases verify if the feature collects successfully initial and periodic eCPRI delay measurements during basic
...   operations performed on BTS.
...   In test scenarios below logs are used for verification:
...   1. eGEN logs - in collected pcap can be checked if count of MSG5 requests is matching MSG5 responses. It is done
...   by comparing amount of each action type: 0x00 & 0x02 for request & response for delay measurement in DL and
...   0x01, 0x05 & 0x04 for request & response for delay measurement in UL.
...   2. Snapshot - in L1 RMOD journal and L1 previous boots journal can be verified if unexpected actions occured
...   during test procedure e.g. timeout, no responses from RU.

...   author: Karolina Pacia, Mateusz Potoniec
...   contact: karolina.pacia@nokia.com, mateusz.potoniec@nokia.com
...   maintainer: karolina.pacia@nokia.com, mateusz.potoniec@nokia.com

Library    taf/rfrl/csv4all/CSV4AllTestCases.py    WITH NAME    CSV4All
Library    taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py

Resource    ./resources/suite_specific_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 increase_timeout_for_update_sw=1800
...                 increase_time_for_checking_cells=1800
Suite Teardown      Common Suite Setup With OnAir Test Line Preparation Teardown

*** Test Cases ***
CB009301_B_03_Online_Enable_Or_Disable_Delay_Measurement
    [Setup]  Test Setup
    Start Egen Logs Collector    host=SKA-ZD06-22-P01.p01.ska-lab.nsn-rdnet.net     timeout=5400
    Change actEcpriDelayMeasurement     True
    Log Action To Console    Wait 60min for periodic delay measurements collection
    Sleep    3600s
    Change actEcpriDelayMeasurement    False
    ${egen_logs_path}=    Stop Egen Logs Collector and Download Logs
    Log Action To Console    Check Egen eCPRI Logs
    Check Egen eCPRI Logs    ${egen_logs_path}
    [Teardown]    Test Teardown

