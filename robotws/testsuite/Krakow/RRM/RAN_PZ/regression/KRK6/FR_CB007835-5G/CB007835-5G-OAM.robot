*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author:  Sara Nowak
...   contact: sara.nowak@nokia.com

Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Resource     resources/Bi-Directional_Throughput.robot
Resource     taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    resources/delta.py
Variables    resources/variables.py

Force Tags   STATE_SW_UPLOADED     RAN_5G    PY39    CLOUD_5G_CLASSICAL_QC_ASIBR_ABILB1_3xAHHB_ENB    CDRT
...     CA_RAN_PZ_KRK

Suite Setup       common_setups_and_teardowns.Common Suite Setup With Commissioning  prefix_tag=FULL
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions
Test Teardown     common_setups_and_teardowns.Common Postconditions

*** Variables ***
${runs_time_duration}    ${10}
@{mandatory_logs}        hlapi  runtime  startup  ps  fault_history  RP1OM
@{customers}             AMX Argentina
${should_LTE_neighbour_be_changed}   ${True}
${should_5G_neighbour_be_changed}    ${False}
################# L3 call ##############
${tput_dl}                320 Mbits/sec
${tput_ul}                49 Mbits/sec
${tput_dl_TL203}          256 Mbits/sec
${tput_ul_TL203}          35 Mbits/sec
${parallel_streams_ul}    4
${parallel_streams_dl}    4
${protocol}               tcp
${deviation}              5%
${size_packet_dl}         1436B
${size_packet_ul}         1436B
${capabilities}           REAL_UE
${duration}               1200s
${interval}               1
${reboot_ue}              False
${timeout_reboot_ue}      100
${linux_congestion}       reno
${current_config}         None
${COLLECT_LOGS_DURING_DATA_TRANSFER}  False
${runs_of_uuf_reset}     ${20}
${runs_of_bbmod_reset}   ${10}
${runs_of_rmod_reset}    ${20}
${runs_of_cell}          ${3}
${runs_of_delta}         ${1}
@{critical_faults}       0010  0016  1806  1868  4341  4352  4383
${QC_DOMAIN}             MN_RAN
${QC_PROJECT}            RAN_ST
@{CUSTOM_ALARMS}=        62003  7509

*** Test Cases ***
CB007835-5G-A_07_ENDC_Bi-directional_TCP_SU_throughput_3S-1CC-4DL-4UL
    Bi-Directional_Throughput    capabilities=${capabilities}     duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation=${deviation}     parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}    size_packet=${size_packet_dl}    interval=${interval}
    ...    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}    linux_congestion_dl=${linux_congestion}
    [Teardown]    Set Suite Variable  ${l3call_result}  ${TEST_STATUS}

CB007835-5G-A_05_Upgrade_L3_Call
    Should Be Equal As Strings    ${l3call_result}    PASS

CB007835-5G-A_12_4G_ENDC_Bi-directional_TCP_SU_throughput_3S-1CC-4DL-4UL
    Should Be Equal As Strings    ${l3call_result}    PASS

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    RAN_5G__WITH__SBTS00
    ...       RAN_5G__WITH__SBTS23R4
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...    test_iteration=${runs_of_delta}
    ...    customers_list=${customers}
    ...    critical_faults=@{critical_faults}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_delta_reset']}
    ...    qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]    RAN_5G__WITH__SBTS00
    ...       RAN_5G__WITH__SBTS23R4
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...    test_iteration=${runs_of_delta}
    ...    customers_list=${customers}
    ...    critical_faults=@{critical_faults}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_delta_online']}
    ...    qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]    RAN_5G__WITH__SBTS00
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...    test_iteration=${runs_of_delta}
    ...    delta_file=/home/ute/logs/delta.json
    ...    customers_list=${customers}
    ...    should_be_reported=True
    ...    critical_faults=@{critical_faults}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_delta_nr_reset']}
    ...    qc_project=${QC_PROJECT}

E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    RAN_5G__WITH__SBTS00
    ...       RAN_5G__WITH__SBTS23R4
    ...       RAN_5G__WITH__SBTS23R3
    ...       RAN_5G__WITH__SBTS23R2
    UUF4ALL_SITE_RESET_TEST
    ...    test_iteration=${runs_of_uuf_reset}
    ...    customers_list=${customers}
    ...    critical_faults=@{critical_faults}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_site_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    custom_alarms=${CUSTOM_ALARMS}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    RAN_5G__WITH__SBTS00
    ...       RAN_5G__WITH__SBTS23R4
    OAM_BBMOD_RESET
    ...    test_iteration=${runs_of_bbmod_reset}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_capacity_reset']}
    ...    qc_project=${QC_PROJECT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    RAN_5G__WITH__SBTS00
    ...       RAN_5G__WITH__SBTS23R4
    OAM_RMOD_RESET
    ...    test_iteration=${runs_of_rmod_reset}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_ru_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    custom_alarms=${CUSTOM_ALARMS}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    RAN_5G__WITH__SBTS00
    ...       RAN_5G__WITH__SBTS23R4
    OAM_NRCEL_BLOCK
    ...    test_iterations=${runs_of_cell}
    ...    customers_list=${customers}
    ...    should_be_reported=True
    ...    critical_faults=@{critical_faults}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_block_unblock']}
    ...    qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    RAN_5G__WITH__SBTS00
    ...       RAN_5G__WITH__SBTS23R4
    OAM_NRCEL_LOCK
    ...    test_iterations=${runs_of_cell}
    ...    customers_list=${customers}
    ...    should_be_reported=True
    ...    critical_faults=@{critical_faults}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_lock_unlock']}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***
Allow X2 alarms
    Allow Alarm    No X2 link available
    Allow Alarm    No X2 link available for a specific LTEENB
    Allow Alarm    F1 Cell activation failed due to X2 link unavailable
    Allow Alarm    Cell Activation timeout at gNB-DU

Disallow X2 alarms
    Disallow Alarm    No X2 link available
    Disallow Alarm    No X2 link available for a specific LTEENB
    Disallow Alarm    F1 Cell activation failed due to X2 link unavailable
    Disallow Alarm    Cell Activation timeout at gNB-DU


General SiSo Comissioning BTS Template Commissioning
    Save BTS Configuration
    Upload BTS Configuration via GUI   ${path_of_saved_BTS_commissioning}
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir

Save BTS Configuration
    ${path_of_saved_BTS_commissioning} =     Get BTS Configuration via GUI
    Set Test Variable   ${path_of_saved_BTS_commissioning}

Perform Delta Commissioning without reset
    Perform Delta Commissioning On gNB   ${delta_online}
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir

Perform Delta Commissioning with reset
    Perform Delta Commissioning On gNB   ${delta_reset}
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir
