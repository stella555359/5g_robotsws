*** Settings ***
Force Tags    PY36    SBTS00
Documentation
...   Testsuite for regression testing of feature CNI-87120
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource     resources/keywords.robot

Test Setup             CNI-87120 test setup
Test Teardown          CNI-87120 test teardown

*** Test Cases ***
[1]CNI-87120 Fault 4080 Fan overspeed customer visibility based on configuration parameter
    Perform test for alarm disabled  syslog_name=fan_syslog_1.txt
    ...                              dist_name=MRBTS-1900/MNL-1
    ...                              param_name=tmpParam6
    ...                              param_value=0
    Perform test for alarm enabled  syslog_name=fan_syslog_2.txt
    ...                             dist_name=MRBTS-1900/MNL-1
    ...                             param_name=tmpParam6
    ...                             param_value=1
    Perform test for alarm disabled  syslog_name=fan_syslog_3.txt
    ...                              dist_name=MRBTS-1900/MNL-1
    ...                              param_name=tmpParam6
    ...                              param_value=0
    Verify alarm in RawAlarmHistory file
