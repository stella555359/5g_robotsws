*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS23R1  SRAN  CLOUD_SRAN_NLWG_1719_1ASIB_1FSMF_1ABIA_1ABIN_2FBBC_2FXDB_2FRGY_1AHPMDA

Library           XML  use_lxml=True

Resource    ../../FM/test_resources/FM__Suppression_of_toggling_radio_alarm.robot
Resource    ../../FM/test_resources/FM__Suppression_of_toggling_transport_alarms.robot
Resource    ../../FM/test_resources/FM__Change_S1_connection_failure_alarm_severity_and_status_sync.robot
Resource    ../../FM/test_resources/FM__Improved_combined_FM_service_with_multiple_alarms.robot
Resource    ../../FM/test_resources/FM__Add_configure_remove_all_external_alarms_via_NA.robot
Resource    ../../FM/test_resources/FM__Alarm_From_Blocked_Cell_Not_Reported_To_NetAct.robot
Resource    ../../FM/test_resources/FM__FHNET_crash_VN_recovery_reset_AS.robot
Resource    ../../FM/test_resources/FM__FR_spontaneous_reset.robot
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__GSM_faults_handling_fault_2412_startup.robot
Resource    ../../FM/test_resources/FM__Iub_CNBAP_link_break.robot
Resource    ../../FM/test_resources/FM__Iub_DNBAP_link_break.robot
Resource    ../../FM/test_resources/FM__LTE_CCplane_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_crash_DSP_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.robot
Resource    ../../FM/test_resources/FM__LTE_L3_crash_VN_recovery_reset.robot
Resource    ../../FM/test_resources/FM__RAT_recovery_reset_counter_cleared_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_false_enabled_cells.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_true_degraded_cell.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_true_enabled_cells.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__RF_module_alarm_cancel_fault_1907.robot
Resource    ../../FM/test_resources/FM__RF_module_alarm_with_reco_reset.robot
Resource    ../../FM/test_resources/FM__RMOD_hot_remove_hot_insert_locked_RMOD.robot
Resource    ../../FM/test_resources/FM__SC_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_false.robot
Resource    ../../FM/test_resources/FM__SC_reset_actForceAutoReset_false_enabled_cells.robot
Resource    ../../FM/test_resources/FM__SC_reset_actForceAutoReset_true_enabled_cells.robot
Resource    ../../FM/test_resources/FM__Site_reset_actForceAutoReset_true_enabled_cell.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__WCDMA_Cplane_fault_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__WCDMA_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__WCDMA_VN_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__fault_handling_LTE_CPlane.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_long.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_short.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_startup.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_CNBAP_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_DNBAP_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_long.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_startup.robot
Resource    ../../FM/test_resources/FM__link_break_S1_long.robot
Resource    ../../FM/test_resources/FM__link_break_S1_short.robot
Resource    ../../FM/test_resources/FM__link_break_SBTS_long.robot
Resource    ../../FM/test_resources/FM__link_break_SBTS_short.robot

Resource    ../../FM/test_resources/FM__5G_RAT_reset_executed_as_autonomous_recovery_action.robot
Resource    ../../WebEM/test_resources/WebEM__RF_successful_start_up_notification_in_Web_Element_Manager.robot
Resource    ../../COMPA/test_resources/COMPA__SSH_snapshot.robot
Resource    ../../CIT/test_resources/STATE__GSM_TRX_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BTS_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource    ../../KPI/test_resources/KPI__Site_reset.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${261}
${WCDMAVlan}          ${361}
${LTEVlan}            ${461}
${Switch_IP}          10.255.10.101
${Switch_type}        Nokia_7210
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       19
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${SCOUT_TL_NAME}      MRBTS-10719
${COLLECT_SNAPSHOT_FLAG}    never

*** Test Cases ***


[1]Automated__FM__link_break_IuB_DNBAP
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    1

    ...    AND    FM__Iub_DNBAP_link_break.TC Setup
    ...    AND    Modify Resource Search Order    FM__Iub_DNBAP_link_break
    TC__FM__Iub_DNBAP_link_break
    [Teardown]    Run Keywords    FM__Iub_DNBAP_link_break.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3

    ...    AND    FM__link_break_IuB_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_short
    TC__FM__link_break_IuB_short
    [Teardown]    Run Keywords    FM__link_break_IuB_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_IuB_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_long
    TC__FM__link_break_IuB_long
    [Teardown]    Run Keywords    FM__link_break_IuB_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_S1_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3

    ...    AND    FM__link_break_S1_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_S1_short
    TC__FM__link_break_S1_short
    [Teardown]    Run Keywords    FM__link_break_S1_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_S1_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_S1_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_S1_long
    TC__FM__link_break_s1_long
    [Teardown]    Run Keywords    FM__link_break_S1_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_SBTS_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3

    ...    AND    FM__link_break_SBTS_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_SBTS_short
    TC__FM__link_break_SBTS_short
    [Teardown]    Run Keywords    FM__link_break_SBTS_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_SBTS_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_SBTS_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_SBTS_long
    TC__FM__link_break_SBTS_long
    [Teardown]    Run Keywords    FM__link_break_SBTS_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_Abis_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3

    ...    AND    FM__link_break_Abis_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_short
    TC__FM__link_break_Abis_short
    [Teardown]    Run Keywords    FM__link_break_Abis_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_Abis_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_Abis_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_long
    TC__FM__link_break_Abis_long
    [Teardown]    Run Keywords    FM__link_break_Abis_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__RMOD_spontaneous_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TESTED_RMOD_SN}

    ...    AND    FM__FR_spontaneous_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__FR_spontaneous_reset
    TC__FM__FR_spontaneous_reset
    [Teardown]    Run Keywords    FM__FR_spontaneous_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__RF_module_alarm_with_reco_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    ${EMPTY}
    ...    AND    Set Test Variable    ${CARRIERS_RESTORE_TIMEOUT}    180
    ...    AND    Set Test Variable    ${Active_Carriers_Before}    0
    ...    AND    Set Test Variable    ${Active_Carriers_After}    0

    ...    AND    FM__RF_module_alarm_with_reco_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_module_alarm_with_reco_reset
    TC__FM__RF_module_alarm_with_reco_reset
    [Teardown]    Run Keywords    FM__RF_module_alarm_with_reco_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__GSM_faults_handling_fault_2412
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__GSM_faults_handling_fault_2412_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_faults_handling_fault_2412_startup
    TC__FM__GSM_faults_handling_fault_2412_startup
    [Teardown]    Run Keywords    FM__GSM_faults_handling_fault_2412_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_Abis_startup
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Timer}    600

    ...    AND    FM__link_break_Abis_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_startup
    TC__FM__link_break_Abis_startup
    [Teardown]    Run Keywords    FM__link_break_Abis_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_CNBAP_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    10

    ...    AND    FM__link_break_IuB_CNBAP_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_CNBAP_short
    TC__FM__link_break_IuB_CNBAP_short
    [Teardown]    Run Keywords    FM__link_break_IuB_CNBAP_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_DNBAP_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    10

    ...    AND    FM__link_break_IuB_DNBAP_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_DNBAP_short
    TC__FM__link_break_IuB_DNBAP_short
    [Teardown]    Run Keywords    FM__link_break_IuB_DNBAP_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_startup
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Timer}    600

    ...    AND    FM__link_break_IuB_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_startup
    TC__FM__link_break_IuB_startup
    [Teardown]    Run Keywords    FM__link_break_IuB_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__fault_handling_LTE_CPlane
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_STATE}    ${FALSE}

    ...    AND    FM__fault_handling_LTE_CPlane.TC Setup
    ...    AND    Modify Resource Search Order    FM__fault_handling_LTE_CPlane
    TC__FM__fault_handling_LTE_CPlane
    [Teardown]    Run Keywords    FM__fault_handling_LTE_CPlane.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300

    ...    AND    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_CCplane_crash_RAT_recovery_reset
    TC__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_VN_crash_RAT_recovery_reset
    TC__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__FHNET_crash_VN_recovery_reset_AS
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300

    ...    AND    FM__FHNET_crash_VN_recovery_reset_AS.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_crash_VN_recovery_reset_AS
    TC__FM__FHNET_crash_VN_recovery_reset_AS
    [Teardown]    Run Keywords    FM__FHNET_crash_VN_recovery_reset_AS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_L3_crash_VN_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    180
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300

    ...    AND    FM__LTE_L3_crash_VN_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_L3_crash_VN_recovery_reset
    TC__FM___LTE_L3_crash_VN_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_L3_crash_VN_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_DSP_crash_DSP_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    120

    ...    AND    FM__LTE_DSP_crash_DSP_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_DSP_crash_DSP_recovery_reset
    TC__FM__LTE_DSP_crash_DSP_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_DSP_crash_DSP_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__WCDMA_CPlane_fault_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__WCDMA_Cplane_fault_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_Cplane_fault_RAT_recovery_reset
    TC__FM__WCDMA_Cplane_fault_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_Cplane_fault_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    180
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120

    ...    AND    FM__Site_reset_actForceAutoReset_true_enabled_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_actForceAutoReset_true_enabled_cell
    TC__FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Teardown]    Run Keywords    FM__Site_reset_actForceAutoReset_true_enabled_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order




[1]Automated__FM__Site_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__Site_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_exceeded
    TC__FM__Site_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__Site_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300

    ...    AND    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_CCplane_LTE_reset_counter_exceeded
    TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__RAT_reset_counter_exceeded__multi_RAT.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_counter_exceeded__multi_RAT
    TC__FM__RAT_reset_counter_exceeded_multi_RAT
    [Teardown]    Run Keywords    FM__RAT_reset_counter_exceeded__multi_RAT.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_reset_actForceAutoReset_false_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__SC_reset_actForceAutoReset_false_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_reset_actForceAutoReset_false_enabled_cells
    TC__FM__SC_reset_actForceAutoReset_false_enabled_cells
    [Teardown]    Run Keywords    FM__SC_reset_actForceAutoReset_false_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_reset_actForceAutoReset_true_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__SC_reset_actForceAutoReset_true_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_reset_actForceAutoReset_true_enabled_cells
    TC__FM__SC_reset_actForceAutoReset_true_enabled_cells
    [Teardown]    Run Keywords    FM__SC_reset_actForceAutoReset_true_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RAT_reset_actForceAutoreset_true_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__RAT_reset_actForceAutoReset_true_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_actForceAutoReset_true_enabled_cells
    TC__FM__RAT_reset_actForceAutoReset_true_enabled_cells
    [Teardown]    Run Keywords    FM__RAT_reset_actForceAutoReset_true_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RAT_reset_actForceAutoReset_false_enabled_cells
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__RAT_reset_actForceAutoReset_false_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_actForceAutoReset_false_enabled_cells
    TC__FM__RAT_reset_actForceAutoReset_false_enabled_cells
    [Teardown]    Run Keywords    FM__RAT_reset_actForceAutoReset_false_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_late_startup_actForceAutoReset_false
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__SC_late_startup_actForceAutoReset_false.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_late_startup_actForceAutoReset_false
    TC__FM__SC_Late_Startup_actForce_False
    [Teardown]    Run Keywords    FM__SC_late_startup_actForceAutoReset_false.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_reset_counter_cleared__manual_site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_recovery_counter_cleared_-_manual_site_reset
    TC__FM__Site_reset_recovery_counter_cleared_-_manual_site_reset
    [Teardown]    Run Keywords    FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RAT_reset_actForceAutoreset_true_degraded_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${FAULT_ID}    1907
    ...    AND    Set Test Variable    ${ANTL}    1

    ...    AND    FM__RAT_reset_actForceAutoReset_true_degraded_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_actForceAutoReset_true_degraded_cell
    TC__FM__RAT_reset_actForceAutoReset_true_degraded_cell
    [Teardown]    Run Keywords    FM__RAT_reset_actForceAutoReset_true_degraded_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RAT_reset_counter_cleared__manual_site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__RAT_recovery_reset_counter_cleared_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_recovery_reset_counter_cleared_manual_site_reset
    TC__FM__RAT_recovery_reset_counter_cleared_manual_site_reset
    [Teardown]    Run Keywords    FM__RAT_recovery_reset_counter_cleared_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__FM__RMOD_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300

    ...    AND    FM__RF_hot_remove_hot_insert.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_hot_remove_hot_insert
    TC__FM__RF_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__RF_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_hot_remove_hot_insert_locked_RMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M161933049
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300

    ...    AND    FM__RMOD_hot_remove_hot_insert_locked_RMOD.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_hot_remove_hot_insert_locked_RMOD
    TC__FM__RMOD_hot_remove_hot_insert_locked_RMOD
    [Teardown]    Run Keywords    FM__RMOD_hot_remove_hot_insert_locked_RMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]LTE656 - Suppression of toggling transport alarms
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M161933049
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300

    ...    AND    FM__Suppression_of_toggling_transport_alarms.TC Setup
    ...    AND    Modify Resource Search Order    FM__Suppression_of_toggling_transport_alarms
    TC__FM__Suppression_of_toggling_transport_alarms
    [Teardown]    Run Keywords    FM__Suppression_of_toggling_transport_alarms.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RP002086_Change_S1_connection_failure_alarm_severity_and_status_sync
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LNMME0_IP}             10.9.172.6

    ...    AND    FM__Change_S1_connection_failure_alarm_severity_and_status_sync.TC Setup
    ...    AND    Modify Resource Search Order    FM__Change_S1_connection_failure_alarm_severity_and_status_sync
    TC__FM__Change_S1_connection_failure_alarm_severity_and_status_sync
    [Teardown]    Run Keywords    FM__Change_S1_connection_failure_alarm_severity_and_status_sync.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Add_configure_remove_all_external_alarms
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M161933049
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300

    ...    AND    FM__Add_configure_remove_all_external_alarms_via_NA.TC Setup
    ...    AND    Modify Resource Search Order    FM__Add_configure_remove_all_external_alarms_via_NA
    TC__FM__Add_configure_remove_all_external_alarms_via_NA
    [Teardown]    Run Keywords    FM__Add_configure_remove_all_external_alarms_via_NA.TC Teardown
    ...    AND    Restore Resource Search Order



[1]LTE656 - Suppression of toggling radio alarm
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M161933049
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300

    ...    AND    FM__Suppression_of_toggling_radio_alarm.TC Setup
    ...    AND    Modify Resource Search Order    FM__Suppression_of_toggling_radio_alarm
    TC__FM__Suppression_of_toggling_radio_alarm
    [Teardown]    Run Keywords    FM__Suppression_of_toggling_radio_alarm.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__FM__RMOD_fault_without_recovery
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M161933049
    ...    AND    Set Test Variable    ${FAULT_ID}    1907
    ...    AND    Set Test Variable    ${ANTL}    1

    ...    AND    FM__RF_module_alarm_cancel_fault_1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_module_alarm_cancel_fault_1907
    TC__FM__RF_module_alarm_cancel_fault_1907
    [Teardown]    Run Keywords    FM__RF_module_alarm_cancel_fault_1907.TC Teardown
    ...    AND    Restore Resource Search Order

#FM__5G_RAT_reset_executed_as_autonomous_recovery_action
[1]Automated__FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__5G_RAT_reset_executed_as_autonomous_recovery_action.TC Setup
    ...    AND    Modify Resource Search Order    FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    TC__FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    [Teardown]    Run Keywords    FM__5G_RAT_reset_executed_as_autonomous_recovery_action.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__RF_successful_start_up_notification_in_Web_Element_Manager.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
    TC__WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
    [Teardown]    Run Keywords    WebEM__RF_successful_start_up_notification_in_Web_Element_Manager.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DSP_ID}    ${Empty}
    ...    AND    Set Test Variable    ${SITE_RESET}    False
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    60
    ...    AND    Set Test Variable    ${FAULT_TIMEOUT}    15
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    3600s
    ...    AND    Set Test Variable    ${VERIFICATION_TIMEOUT}    60
    ...    AND    Set Test Variable    ${MEMDUMP_PATTERN}    (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
    ...    AND    Set Test Variable    ${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
    ...    AND    Set Test Variable    ${DSP_RUNTIME_PATTERN}    [1-2]011_crash_{}00_RT\\.log\\.zip$
    ...    AND    Set Test Variable    ${DSP_MEMDUMP_PATTERN}    {}00\\w+MEMDUMP\\.bin.*
    ...    AND    Set Test Variable    ${SRIO_DIO_INTERFACE_PATERN}    riomemfs-logdump
    ...    AND    Set Test Variable
    ...    ${ADDITIONAL_IGNORED_ALARMS}    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]

    ...    AND    Modify Resource Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    ...    AND    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Setup
    TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Teardown]    Run Keywords    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    ${var_measurement_path}  Catenate  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific
    ...  /SBTS1210/counters/SBTS19A_Counters_2019-07-01_limited.xlsx
    ${var_abreviation_dict_path}  Catenate  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific
    ...  /SBTS1210/counters/LTE_Abbreviations.xlsx
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MEASUREMENT_PATH}    ${var_measurement_path}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${var_abreviation_dict_path}
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15

    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    TC__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__STATE__GSM_BTS_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BCF_SECTOR_TO_LOCK}
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    5
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]

    ...    AND    Modify Resource Search Order    STATE__GSM_BTS_lock_unlock_from_BSC
    ...    AND    STATE__GSM_BTS_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_BTS_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_BTS_lock_unlock_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__STATE__GSM_TRX_lock_unlock_from_BSC
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TRX_ID}
    ...    AND    Set Test Variable    ${BTS_ID}
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]

    ...    AND    Modify Resource Search Order    STATE__GSM_TRX_lock_unlock_from_BSC
    ...    AND    STATE__GSM_TRX_lock_unlock_from_BSC.TC Setup
    TC__STATE__GSM_TRX_lock_unlock_from_BSC
    [Teardown]    Run Keywords    STATE__GSM_TRX_lock_unlock_from_BSC.TC Teardown
    ...    AND    Restore Resource Search Order

[1]KPI__Site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]

    ...    AND    Modify Resource Search Order    KPI__Site_reset
    ...    AND    KPI__Site_reset.TC Setup
    TC__KPI__Site_reset
    [Teardown]    Run Keywords    KPI__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


