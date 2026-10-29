*** Settings ***
Force Tags    PY36    SBTS00
Documentation
...   Testsuite for regression testing of feature CNI-86130
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource     ../CNI-87120/resources/keywords.robot

Test Setup             CNI-86130 test setup
Test Teardown          CNI-86130 test teardown

*** Test Cases ***
[1]CNI-86130 Fault 4080 Fan overspeed customer visibility based on configuration parameter
    Perform test for alarm disabled  syslog_name=fan_syslog_1.txt
    ...                              dist_name=MRBTS-1900/MNL-1/MNLENT-1/FMCADM-1
    ...                              param_name=enableFanOverspeedAlarm
    ...                              param_value=false
    Perform test for alarm enabled  syslog_name=fan_syslog_2.txt
    ...                             dist_name=MRBTS-1900/MNL-1/MNLENT-1/FMCADM-1
    ...                             param_name=enableFanOverspeedAlarm
    ...                             param_value=true
    Perform test for alarm disabled  syslog_name=fan_syslog_3.txt
    ...                              dist_name=MRBTS-1900/MNL-1/MNLENT-1/FMCADM-1
    ...                              param_name=enableFanOverspeedAlarm
    ...                              param_value=false
    Verify alarm in RawAlarmHistory file

*** Keywords ***
CNI-86130 test setup
    CNI-87120 test setup

CNI-86130 test teardown
    CNI-87120 test teardown
