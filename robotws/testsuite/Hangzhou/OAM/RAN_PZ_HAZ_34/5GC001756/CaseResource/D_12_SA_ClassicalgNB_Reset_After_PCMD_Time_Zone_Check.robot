*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
D_12_SA_ClassicalgNB_Reset_After_PCMD_Time_Zone_Check
    ${timezone_value}   Get BTS Time Zone
    ${timezone_status}   OperatingSystem.Run   cat ${TXT_FILE} | grep "timezone-min"
    Should Contain   ${timezone_status}   ${timezone_value}

Case Setup: D_12
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: SA_ClassicalgNB_Reset_After_PCMD_Time_Zone_Check

Case Teardown: D_12
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: SA_ClassicalgNB_Reset_After_PCMD_Time_Zone_Check
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}

Get BTS Time Zone
    ${status_old}   ${timezone_old}   Run Keyword And Ignore Error   COAM Get Parameter Value
    ...   dist_name=${MRBTS}/MNL-1/MNLENT-1/SYNC-1/TIME-1   parameter=timeZone
    ${status_new}   ${timezone_new}   Run Keyword And Ignore Error   COAM Get Parameter Value
    ...   dist_name=${MRBTS}/MNL-1   parameter=timeZone
    ${timezone}   Set Variable If
    ...   "${status_old}"=="PASS"   ${timezone_old}
    ...   "${status_new}"=="PASS"   ${timezone_new}
    ${timezone}   Set Variable   ${timezone.split(")")[0].split("(GMT+")[-1]}
    ${timezone_value}   Convert To Integer   ${timezone}
    ${timezone_value}   Set Variable   ${timezone_value * 60}
    ${timezone_value}   Convert To String   ${timezone_value}
    [Return]   ${timezone_value}
