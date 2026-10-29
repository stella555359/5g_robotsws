*** Settings ***
Documentation
...   Test Suite for testing TC30 of a CB007043 feature
...   author: Aleksander Gospodarczyk
...   contact: aleksander.gospodarczyk@nokia.com


Resource    testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CB007043/resources/CB007043_keywords.robot


Suite Setup          Test Suite Setup
Suite Teardown       Test Suite Teardown
Test Setup           Common Preconditions With Watching Alarms 
Test Teardown        Common Postconditions With Watching Alarms


*** Test Cases ***
[1][1.0] 030_CB007043_Migration of LTE parameters with sleeping cell detection methods disabled
        check_preconditions
        Perform SW Upgrade
        check_postconditions

