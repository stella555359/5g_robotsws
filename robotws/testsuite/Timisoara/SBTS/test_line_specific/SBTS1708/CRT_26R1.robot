*** Settings ***
Documentation
    ...  This testsuite was created for CRT runs.
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS26R1  SRAN  CLOUD_SRAN_NLWG_1708_2ASIM_1ABIA_2ABIO_2ABIP_1ABIN_2AHCA_2AHMPDA_2FXDB_1AZNA_1AENB_1AZQS
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__LTE_NR_cells_degraded_when_1_RU_power_off.robot
Resource    ../../FM/test_resources/FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.robot
Resource    ../../FM/test_resources/FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.robot
Resource    ../../FM/test_resources/FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.robot
Resource    ../../FM/test_resources/FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.robot
Resource    ../../FM/test_resources/FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.robot
Resource    ../../FM/test_resources/FM__Robustness_trigger_different_faults_RMOD.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__5G_fault_tolerant_setup_degraded_cell.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1708

*** Test Cases ***

[1]FM__NR_and_LTE_cells_degraded_when_1_RU_power_off
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    		    1M161933127
    ...    AND    Set Test Variable    ${FAULT_10_TIMEOUT}      120
    ...    AND    Set Test Variable    ${FAULT_4589_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}      900

    ...    AND    FM__LTE_NR_cells_degraded_when_1_RU_power_off.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_NR_cells_degraded_when_1_RU_power_off
    FM__LTE_NR_cells_degraded_when_1_RU_power_off
    [Teardown]    Run Keywords    FM__LTE_NR_cells_degraded_when_1_RU_power_off.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIQ
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}           180

    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIP
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60

    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AEQQ
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360

    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOB
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AVHA

    ...    AND    FM__RMOD_reset_counter_exceeded_FID1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1907
    FM__RMOD_reset_counter_exceeded_FID1907
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1907.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_B3_Tx_Rx_Failure_detection_after_RF_recovery_reset_further_faults_appear
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300

    ...    AND    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    TC__FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    [Teardown]    Run Keywords    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300

    ...    AND    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.TC Setup
    ...    AND    Modify Resource Search Order    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    TC__FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Teardown]    Run Keywords    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AVHA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300

    ...    AND    FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    TC__FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    [Teardown]    Run Keywords    FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__CPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BREAK_TIME_VALUE}    220

    ...    AND    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.TC Setup
    ...    AND    Modify Resource Search Order    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    TC__FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case
    [Teardown]    Run Keywords    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Robustness_trigger_different_faults_RMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}             30m
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}           10m
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}         10m
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}               180

    ...    AND    FM__Robustness_trigger_different_faults_RMOD.TC Setup
    ...    AND    Modify Resource Search Order    FM__Robustness_trigger_different_faults_RMOD
    TC__FM__Robustness_trigger_different_faults_RMOD
    [Teardown]    Run Keywords    FM__Robustness_trigger_different_faults_RMOD.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_rst_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SN}    	L1224009428
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIP
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


[1]FM__5G_fault_tolerant_setup_degraded_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    	900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RMOD_TYPE}    FXDB

    ...    AND    FM__5G_fault_tolerant_setup_degraded_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__5G_fault_tolerant_setup_degraded_cell
    FM__5G_fault_tolerant_setup_degraded_cell
    [Teardown]    Run Keywords    FM__5G_fault_tolerant_setup_degraded_cell.TC Teardown
    ...    AND    Restore Resource Search Order

