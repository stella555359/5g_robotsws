*** Settings ***
Documentation    This file contains an simple example for alarm appearnce checks

Library     ../python/alarm_handling.py      WITH NAME   alarm_py
Resource    ../alarm_handling.robot
Resource    ../testline.robot

Test Setup  Setup Log Dir


*** Test Cases ***
Example 1 Fail A Test If New Active Alarms Appear
    [Documentation]     Fetches alarms 2 times, stores and compares active alarms.
    ...                 It raises warnings only, fails the test if ERROR is used in `Log Alarm List`.

    ${alarms_before_test}   alarm_handling.Get All Alarms From Node
    ...   node_id=0   node_type=gnb
    ...   time_sort=${True}   with_historic=${False}   targetfile=${TARGET_DIR}/alarms_before_test.json

    # perform your test steps here

    ${alarms_after_test}   alarm_handling.Get All Alarms From Node
    ...   node_id=0   node_type=gnb
    ...   time_sort=${True}   with_historic=${False}   targetfile=${TARGET_DIR}/alarms_after_test.json

    ${_}  ${new_alarms}  alarm_py.Check For New Alarms  ${alarms_before_test}  ${alarms_after_test}
    alarm_handling.Log Alarm List  ${new_alarms}   ERROR


*** Keywords ***
Setup Log Dir
    ${target_dir}   testline.Get Test Case Log Directory
    Set Test Variable   ${TARGET_DIR}   ${target_dir}
