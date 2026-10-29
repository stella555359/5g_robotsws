*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__SWM__SW_Fallback.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}
&{ADD_IGNORED_ALARM_4459}    alarmId=7220    faultId=4459
&{ADD_IGNORED_ALARM_4420}    alarmId=7115    faultId=4420
&{ADD_IGNORED_ALARM_7300}    alarmId=7107    faultId=7300
&{ADD_IGNORED_ALARM_7319}    alarmId=7107    faultId=7319

*** Test Cases ***
[1]SBTS_SBTS__SWM__SW_Fallback
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BTS1
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_reset_number}    2
    ...    AND    Set Test Variable    ${BTS2_reset_number}    2
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    M139-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m139
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    M139-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m139
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.93
    ...    AND    Set Test Variable    ${BTS2_EIF_down}    M139-bts2-EIF-down
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}    EIF-down-m139
    ...    AND    Set Test Variable    ${BTS2_EIF_up}    M139-bts2-EIF-up
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}    EIF-up-m139
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}    10.255.10.93
    ...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_CNI_127210]  ${ADD_IGNORED_ALARM_4459}
    ...    ${ADD_IGNORED_ALARM_4420}  ${ADD_IGNORED_ALARM_7300}  ${ADD_IGNORED_ALARM_7319}
    ...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_CNI_127210]  ${ADD_IGNORED_ALARM_4459}
    ...    ${ADD_IGNORED_ALARM_4420}  ${ADD_IGNORED_ALARM_7300}  ${ADD_IGNORED_ALARM_7319}

    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Restore Resource Search Order
