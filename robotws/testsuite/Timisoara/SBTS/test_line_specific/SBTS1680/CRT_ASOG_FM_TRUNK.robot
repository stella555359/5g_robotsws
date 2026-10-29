*** Settings ***
Documentation
...    Author: valentin.sorescu@nokia.com
...    Description: CRT ASOG


Force Tags  QCD_MN_RAN  QCP_RAN_VRF  RAN_MRAT  SRAN  CLOUD_SRAN_NLG_10680_1ASOG_2AHEGA
...    SBTS00    STATE_ON_AIR
Library           XML  use_lxml=True


Resource    ../../FM/test_resources/FM__link_break_Abis_short.robot
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__FHNET_crash_VN_recovery_reset_AS.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.robot


Suite Setup      Run keywords
...              Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...              AND  Map BuildShareTimi01 and move counters folder in test_line_specific

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
@{GSMVlan}            ${261}  ${262}
${LTEVlan}            ${461}
${Switch_IP}          10.255.10.234
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       13
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1680

*** Test Cases ***
[1]Automated__FM__link_break_Abis_short
    [Tags]  QC_180448
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3
    ...    AND    FM__link_break_Abis_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_short
    TC__FM__link_break_Abis_short
    [Teardown]    Run Keywords    FM__link_break_Abis_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
#    [Tags]  QC_62607
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    2700
    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__FHNET_crash_VN_recovery_reset_AS
#    [Tags]  QC_163226
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    FM__FHNET_crash_VN_recovery_reset_AS.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_crash_VN_recovery_reset_AS
    TC__FM__FHNET_crash_VN_recovery_reset_AS
    [Teardown]    Run Keywords    FM__FHNET_crash_VN_recovery_reset_AS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
#    [Tags]  QC_836491
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    2400
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    2400
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ASOG
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RAT_RESET}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=false_and_the_same_fault_appeared_for_the_SoC_in_pas_one_hour
#    [Tags]  QC_836492
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BBMOD_TYPE}
    ...    AND    Modify Resource Search Order    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    ...    AND    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Setup
    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    [Teardown]    Run Keywords    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***
Map BuildShareTimi01 and move counters folder in test_line_specific
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...                                    noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    ${cp_command}  Catenate  cp /media/BuildShareTimi01/SBTS/Trunk/counters_for_CIT_Trunk/1688/*
    ...                      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS10688/counters/
    Run  ${cp_command}
