*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  RAN_MRAT  SRAN  CLOUD_SRAN_NLG_10680_1ASOG_2AHEGA
...    SBTS00    STATE_SKIP_AGENT
Library           XML  use_lxml=True


Resource    ../../CIT/test_resources/CIT_Test_Line_Recovery.robot
Resource    ../../FM/test_resources/FM__FID2087_fault_signature_active_UP_L1_process_crashed.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.robot



Suite Setup      Run keywords
...              Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...              AND  Map BuildShareTimi01 and move counters folder in test_line_specific

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1680

*** Test Cases ***


[1]FM__FID2087_fault_signature_active_UP_L1_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Modify Resource Search Order    FM__FID2087_fault_signature_active_UP_L1_process_crashed
    ...    AND    FM__FID2087_fault_signature_active_UP_L1_process_crashed.TC Setup
    FM__FID2087_fault_signature_active_UP_L1_process_crashed
    [Teardown]    Run Keywords    FM__FID2087_fault_signature_active_UP_L1_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed
    ...    AND    FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed.TC Setup
    FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${MODULE_TYPE}
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600	
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__SoC_reset_criteria_if_actForceUnitAutoReset=false_and_the_same_fault_appeared_for_the_SoC_in_pas_one_hour
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
