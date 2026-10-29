*** Settings ***
Documentation
...    Author: valentin.sorescu@nokia.com
...    Description: CRT ASOG


Force Tags  QCD_MN_RAN  QCP_RAN_VRF  RAN_MRAT  SRAN  CLOUD_SRAN_NLG_10680_1ASOG_2AHEGA
...    SBTS25R1    STATE_ON_AIR
Library           XML  use_lxml=True


Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__GSM_faults_handling_fault_2412_startup.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_short.robot
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../FM/test_resources/FM__FID2087_fault_signature_active_UP_L1_process_crashed.robot
Resource    ../../FM/test_resources/FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.robot
esource    ../../WebEM/test_resources/WebEM__Admin_CLI_getSwVersionStatus.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getCellList.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getActiveAlarms.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getAmfData.robot



Suite Setup      Run keywords
...              Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...              AND  Map BuildShareTimi01 and move counters folder in test_line_specific

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
@{GSMVlan}            ${261}  ${262}
${WCDMAVlan}          ${464}
${LTEVlan}            ${461}
${Switch_IP}          10.255.6.18
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       7
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1680


*** Test Cases ***
[1]WebEM__Admin_CLI_getAmfData
    [Tags]  QC_89756
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    WebEM__Admin_CLI_getAmfData.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getAmfData
    TC__WebEM__Admin_CLI_getAmfData
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getAmfData.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getSwVersionStatus
    [Tags]  QC_89755
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    WebEM__Admin_CLI_getSwVersionStatus.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getSwVersionStatus
    TC__WebEM__Admin_CLI_getSwVersionStatus
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getSwVersionStatus.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults
    [Tags]  QC_89754
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults
    TC__WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults
    [Teardown]    Run Keywords    WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getCellList
    [Tags]  QC_89753
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    WebEM__Admin_CLI_getCellList.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getCellList
    TC__WebEM__Admin_CLI_getCellList
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getCellList.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getActiveAlarms
    [Tags]  QC_89752
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    WebEM__Admin_CLI_getActiveAlarms.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getActiveAlarms
    TC__WebEM__Admin_CLI_getActiveAlarms
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getActiveAlarms.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__B_5G_RAT_reset_counter_exceeded
    [Tags]  QC_89758
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    FM__B_5G_RAT_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_5G_RAT_reset_counter_exceeded
    TC__FM__B_5G_RAT_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__B_5G_RAT_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_5G_RAT_reset_counter_cleared__manual_site
    [Tags]  QC_89757
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    660
    ...    AND    FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_5G_RAT_reset_counter_cleared__manual_site_reset
    TC__FM__B_5G_RAT_reset_counter_cleared__manual_site_reset
    [Teardown]    Run Keywords    FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__GSM_faults_handling_fault_2412
    [Tags]  QC_89761
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    FM__GSM_faults_handling_fault_2412_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_faults_handling_fault_2412_startup
    TC__FM__GSM_faults_handling_fault_2412_startup
    [Teardown]    Run Keywords    FM__GSM_faults_handling_fault_2412_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_Abis_short
    [Tags]  QC_89760
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3
    ...    AND    FM__link_break_Abis_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_short
    TC__FM__link_break_Abis_short
    [Teardown]    Run Keywords    FM__link_break_Abis_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FID2087_fault_signature_active_UP_L1_process_crashed
    [Timeout]    14400
    [Tags]  QC_89748
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Modify Resource Search Order    FM__FID2087_fault_signature_active_UP_L1_process_crashed
    ...    AND    FM__FID2087_fault_signature_active_UP_L1_process_crashed.TC Setup
    TC__FM__FID2087_fault_signature_active_UP_L1_process_crashed
    [Teardown]    Run Keywords    FM__FID2087_fault_signature_active_UP_L1_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Tags]  QC_89759
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



[1]FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Timeout]    14400
    [Tags]  QC_89762
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Modify Resource Search Order    FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case
    ...    AND    FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case.TC Setup
    TC__FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case
    [Teardown]    Run Keywords    FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case.TC Teardown
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
