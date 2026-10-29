*** Settings ***
Documentation
...  author : lei.nie@nokia-sbell.com
...  contact: lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***


*** Keyword ***
001_Netboot_Enable
    Log To Console   CB008329 001_Netboot_Enable

    Set Netboot Variable
    Sleep   60s
    Trigger SC via Admin
    Check Netboot Detection Alarm


Case Setup: 001
    Log To Console   Case setup

Case Teardown: 001
    Log To Console   Case teardown
    Sleep   60s

    Delete Netboot Variable

    Trigger SC via Admin
    Run Keyword And Ignore Error   Check No Netboot Detection Alarm

    Run Keyword And Ignore Error   CI_interface.Common Case Teardown


Set Netboot Variable
    csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    Run Keyword If   ${DUAL_CORE}
    ...   csn.Connect To   hostname=${DUALCORE_HOST}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=DUAL   proxy=LOCAL
    ${True_Connection}   Set Variable If   ${DUAL_CORE}   DUAL   LOCAL

    ${output}   csn.Execute   command=uboot_env set netboot=netboot_only   connection=${True_Connection}
    Should Contain Any   ${output}   Added 1 variable   Added 0 variable

    ${output}   csn.Execute   command=uboot_env get netboot   connection=${True_Connection}
    Should Contain   ${output}   netboot=netboot_only

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${DUAL_CORE}   csn.Disconnect   connection=DUAL   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=LOCAL

Delete Netboot Variable
    csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    Run Keyword If   ${DUAL_CORE}
    ...   csn.Connect To   hostname=${DUALCORE_HOST}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=DUAL   proxy=LOCAL
    ${True_Connection}   Set Variable If   ${DUAL_CORE}   DUAL   LOCAL

    ${output}   csn.Execute   command=uboot_env del netboot   connection=${True_Connection}
    Should Contain Any   ${output}   Deleted netboot   Variable netboot not found

    ${output}   csn.Execute   command=uboot_env get netboot   connection=${True_Connection}
    Should Contain   ${output}   Variable netboot not found

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${DUAL_CORE}   csn.Disconnect   connection=DUAL   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=LOCAL

Check Netboot Detection Alarm
    Log To Console   "Check Netboot Detection Alarm"
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Contain   ${supplAlarmInfo}   4
    Should Contain Any   ${severity}   Warning   Minor

Check No Netboot Detection Alarm
    Log To Console   "Check No Netboot Detection Alarm"
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Not Contain   ${supplAlarmInfo}   4
    Sleep   10s
