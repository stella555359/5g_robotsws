*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLG_1328_2ASIL_4ABIO_1ABIP_1ABIA_2AZHL_3AHLOA_3AHFIB_1AHDB_1AENB
Library           XML  use_lxml=True

Documentation  crt_trunk_10328

Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_successful_recovery.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__high_VoltUnstableThreshold_updated_fault_4680_cleared.robot
Resource    ../../FM/test_resources/FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_5G_RT_NRT_process.robot
Resource    ../../FM/test_resources/FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_cleared__manual_site_reset_fid_246.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__Multiple_Faults_cancel_on_managed_object_removal.robot
Resource    ../../FM/test_resources/FM__eCPRI_RU_Fault_10_information_enriched_case_1.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.robot

*** Variables ***
${SCF_ID}    01

*** Test Cases ***
[1]FM__B_L1Soc_NR_UL_DSP_successful_recovery
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9101
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${HW_VARIANT}        Loki
    ...    AND    Set Test Variable    ${RAT_TYPE}          NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}         ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_successful_recovery.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_successful_recovery
    TC__FM__B_L1Soc_NR_UL_DSP_successful_recovery
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_successful_recovery.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIP
    ...    AND    Set Test Variable    ${MODULE_SN}    L1241104106
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  300
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}  120

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
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60

    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM_high_VoltUnstableThreshold_updated_fault_4680_cleared
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PSU_IP}  10.255.1.50
    ...    AND    Set Test Variable    ${RMOD_SN}  EA191172176
    ...    AND    Set Test Variable    ${DEFAULT_VOLTAGE}  48
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  360
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}  300

	...    AND    FM__high_VoltUnstableThreshold_updated_fault_4680_cleared.TC Setup
    ...    AND    Modify Resource Search Order    FM__high_VoltUnstableThreshold_updated_fault_4680_cleared
    TC__FM__high_VoltUnstableThreshold_updated_fault_4680_cleared
    [Teardown]    Run Keywords    FM__high_VoltUnstableThreshold_updated_fault_4680_cleared.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}     180
    ...    AND    Set Test Variable    ${BBMOD_TYPE}   ABIP

    ...    AND    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.TC Setup
    ...    AND    Modify Resource Search Order    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    TC__FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Teardown]    Run Keywords    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__FID4383_fault_signature_active_5G_RT_NRT_process
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BBMOD_TYPE}         ABIP

    ...    AND    FM__FID4383_fault_signature_active_5G_RT_NRT_process.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_5G_RT_NRT_process
    TC__FM__FID4383_fault_signature_active_5G_RT_NRT_process
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_5G_RT_NRT_process.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__A_L1_5G_SoC_reset_escalation_actForceUnitReset=false
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}     180
    ...    AND    Set Test Variable    ${HW_VARIANT}    Thor
    ...    AND    Set Test Variable    ${SOC_TYPE}   ABIP

    ...    AND    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    TC__FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    [Teardown]    Run Keywords    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__Site_reset_counter_cleared__manual_site_reset_fid_246
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}     600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}       180

    ...    AND    FM__Site_reset_counter_cleared__manual_site_reset_fid_246.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_cleared__manual_site_reset_fid_246
    TC__FM__Site_reset_counter_cleared__manual_site_reset_fid_246
    [Teardown]    Run Keywords    FM__Site_reset_counter_cleared__manual_site_reset_fid_246.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__Site_rst_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SN}    L1241104106
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIP
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    240
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    360
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    900
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    1800

    ...    AND    FM__Site_reset_escalation_to_BTS_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_escalation_to_BTS_power_reset
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]    Run Keywords    FM__Site_reset_escalation_to_BTS_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__eCPRI_RU_Fault_10_information_enriched_case_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M224820442
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    900
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120

    ...    AND    FM__eCPRI_RU_Fault_10_information_enriched_case_1.TC Setup
    ...    AND    Modify Resource Search Order    FM__eCPRI_RU_Fault_10_information_enriched_case_1
    TC__FM__eCPRI_RU_Fault_10_information_enriched_case_1
    [Teardown]    Run Keywords    FM__eCPRI_RU_Fault_10_information_enriched_case_1.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__eCPRI_RU_Fault_10_information_enriched_case_7
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M224820442
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    240
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${PING_INSERT_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CHECK_NA_ALARM}    True

    ...    AND    FM__RF_hot_remove_hot_insert.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_hot_remove_hot_insert
    TC__FM__RF_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__RF_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_B4_Autonomous_RF_Recovery_Reset_due_to_Tx_Rx_Failure_cell_degraded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AHLOB
    ...    AND    Set Test Variable    ${RMOD_RESET_NEEDED}  ${FALSE}
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300

    ...    AND    FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.TC Setup
    ...    AND    Modify Resource Search Order    FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    TC__FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    [Teardown]    Run Keywords    FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.TC Teardown
    ...    AND    Restore Resource Search Order
