*** Settings ***
Documentation
    ...  This testsuite was created for CRT runs.
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS26R2  SRAN  CLOUD_SRAN_NLWG_1708_2ASIM_1ABIA_2ABIO_2ABIP_1ABIN_2AHCA_2AHMPDA_2FXDB_1AZNA_1AENB_1AZQS
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__LTE_L2_MACPS_sw_critical_failure.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__Robustness_trigger_different_faults_RMOD.robot
Resource    ../../FM/test_resources/FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.robot
Resource    ../../FM/test_resources/FM__Suppress_alarms_based_on_both_fault_and_alarm_Id.robot
Resource    ../../FM/test_resources/FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.robot
Resource    ../../FM/test_resources/FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.robot
Resource    ../../FM/test_resources/FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1708

*** Test Cases ***


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


[1]FM__LTE_L2_MACPS_critical_failure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIP
    ...    AND    Set Test Variable    ${RAT}    LNCEL
    ...    AND    Set Test Variable    ${TECHNOLOGY}    FDD
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180

    ...    AND    FM__LTE_L2_MACPS_sw_critical_failure.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_L2_MACPS_sw_critical_failure
    FM__LTE_L2_MACPS_sw_critical_failure
    [Teardown]    Run Keywords    FM__LTE_L2_MACPS_sw_critical_failure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AEQQ
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120

    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
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

