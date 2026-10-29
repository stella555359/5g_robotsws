*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLG_1328_2ASIL_4ABIO_1ABIP_1ABIA_2AZHL_3AHLOA_3AHFIB_1AHDB_1AENB
Library           XML  use_lxml=True

Documentation  crt_trunk_10328

Resource    ../../FM/test_resources/FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__eCPRI_RU_Fault_10_information_enriched_case_1.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot

*** Variables ***
${SCF_ID}    01

*** Test Cases ***
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
