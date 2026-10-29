*** Settings ***
Documentation
    ...  This testsuite was created for CRT runs.
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN  CLOUD_SRAN_NLWG_1708_2ASIM_1ABIA_2ABIO_2ABIP_1ABIN_2AHCA_2AHMPDA_2FXDB_1AZNA_1AENB_1AZQS
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.robot
Resource    ../../FM/test_resources/FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.robot
Resource    ../../FM/test_resources/FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature.robot
Resource    ../../FM/test_resources/FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.robot
Resource    ../../FM/test_resources/FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1708

*** Test Cases ***


[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AEQQ
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600

    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO

    ...    AND    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    TC__FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    900
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    300
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1600
    ...    AND    Set Test Variable    ${BREAK_TIME_VALUE}    220

    ...    AND    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.TC Setup
    ...    AND    Modify Resource Search Order    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    TC__FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Teardown]    Run Keywords    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.TC Setup
    ...    AND    Modify Resource Search Order    FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    TC__FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    [Teardown]    Run Keywords    FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${BLOCK_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AZQS
    ...    AND    Set Test Variable    ${RUNTIME_TIMEOUT}     260
    ...    AND    FM__RMOD_reset_counter_exceeded_FID1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1907
    FM__RMOD_reset_counter_exceeded_FID1907
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1907.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_rst_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SN}    	L1224009428
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    240
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    240
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    900
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    1800

    ...    AND    FM__Site_reset_escalation_to_BTS_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_escalation_to_BTS_power_reset
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]    Run Keywords    FM__Site_reset_escalation_to_BTS_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature.TC Setup
    ...    AND    Modify Resource Search Order    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    [Teardown]    Run Keywords    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_B3_Tx_Rx_Failure_detection_after_RF_recovery_reset_further_faults_appear
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  300

    ...    AND    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    TC__FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    [Teardown]    Run Keywords    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  300

    ...    AND    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.TC Setup
    ...    AND    Modify Resource Search Order    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    TC__FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Teardown]    Run Keywords    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.TC Teardown
    ...    AND    Restore Resource Search Order