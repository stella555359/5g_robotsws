*** Settings ***
Documentation
...     Author:         Klaudyna Piechocka
...     Contact:        klaudyna.piechocka@nokia.com
...     Test Plan (QC): /VRF_WRO3_T04/CB0010969
...     Description:
...        CB008267:    Veryfing basic security concepts such as password  compexity check ro TLS connections
...        CB008259:    Veryfing removing RUEM logs and CRL download robustness

Resource        ../features/CB008259/TestCases/CB008259.robot
Resource        ../features/CB008267/TestCases/CB008267.robot
Resource        ../features/CB012562-A/TestCases/CB012562-A.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot


Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
CB012562-A_08_Subject_Name_SN_and_Subject_Alternative_Names_SANs_autocompletion_on_Target_SW_After_Reset
    CB012562-A_08_Subject_Name_(SN)_and_Subject_Alternative_Names_(SANs)_autocompletion_on_Target_SW_After_Reset

CB012562-A_06_Subject_Alternative_Names_SANs_depends_on_NumberOfSAN_parameter_expired_certificate_WebEM_and_NMS
    CB012562-A_06_Subject_Alternative_Names_(SANs)_depends_on_NumberOfSAN_parameter_expired_certificate_WebEM_and_NMS

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Add Alarm To Allowed Alarms     61675     WiFi Configuration Issue

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                             input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
