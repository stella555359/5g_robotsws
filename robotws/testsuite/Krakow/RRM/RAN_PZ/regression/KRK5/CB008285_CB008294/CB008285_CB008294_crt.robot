*** Settings ***
Documentation
...   Test suite for regression testing of CB008285
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Resource     ./resources/common_resources.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      taf.ue     WITH NAME   ue
Library     ./resources/resources.py    WITH NAME    local_resources
Variables    ./resources/common_variables.py
Variables    ./resources/call_procedure/call_tmp_vars.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=3600
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown


*** Variables ***
@{CellIDs}         NRCELL-251
@{All_cells}       251    252    253    254    255    256    257    258    259    260
${capabilities}    REAL_UE

*** Test Cases ***
################# CRT ################
CB008285_B_008_5GC000740_NG_C_link_locking_unlocking_with_One_AMF_SA_calls
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=${None}
    Check time to next PM period    time_buffer=${120}
    Add new AMF
    Check All AMF ngLinkStatus    status=Unlocked
    gnbcell.Verify All Cells Are Onair
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008285_B_008_1
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008285_B_008
    Check time to next PM period    time_buffer=${120}
    Lock default AMF
    Check Only Default AMF ngLinkStatus    status=Locked
    gnbcell.Verify All Cells Are Onair
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008285_B_008_2
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008285_B_008
    UnLock default AMF
    BuiltIn.Sleep    60s
    Check All AMF ngLinkStatus    status=Unlocked
    gnbcell.Verify All Cells Are Onair
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008285_B_008
    Delete AMF
    [Teardown]    Actions after test


CB008285_B_020_CB007516_Successful_IDLE_Mode_mobility_to_select_Pcell_based_on_configured_Priority_FR2_SA
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008285_B_020
    Check time to next PM period    time_buffer=${240}    interval=${5}
    Attach UE    cell=NRCELL-251
    BuiltIn.Sleep    60s
    Detach UE
    logger.log_info_to_console    Waiting for 5min PM period is finished
    gnb_counter.Wait for next PM period    interval=5
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008285_B_020
    [Teardown]    Actions after test


CB008285_B_025_5GC001778_Successful_L3_call_PCMD_Cell_Trace_report_on_the_GNB_CU_DU_after_Cell_lock_unlock
    [Setup]    Actions before test        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[CB008285_B_025]
    Perform Full Commissioning and Wait for onAir    prefix_tag=${None}
    Activate PCMD trace in BTS
    ${additional_logs_dir}=    Create directory for additional logs
    Set Test Variable    ${dcap_logs}    dcap_logs
    Setup DCAP
    Check time to next PM period    time_buffer=${240}    interval=${5}
    ${trace_id}=    Start Emil Collection
    Perform Serving Cell Lock Unlock    cell_id=251

    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=30s      tc_name=CB008285_B_025
    Stop Emil Collection    trace_id=${trace_id}    log_dir=${additional_logs_dir}    filename=${dcap_logs}
    ${emil_json_file}=    Convert 5gm to json    dcap_log=${additional_logs_dir}/${dcap_logs}
    Check call flow    emil_json_file=${emil_json_file}
    Stop DCAP
    Deactivate PCMD trace in BTS
    Wait Until Keyword Succeeds     5x      10s
    ...    Verify Alarm is not Active on gNB    fault_name=Failure in connection between BTS and 3rd party tool
    [Teardown]    Actions after test    stop_dcap=${True}


CB008294_A_PMO1_001_check_counter_GNB-8CCDL_4CCUL_maxScell7DL3UL_contiguous_freq_with_SA_FR2_CA_enabled
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008294_A_PMO1
    Check time to next PM period    time_buffer=${600}
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=30s      tc_name=CB008294_A_PMO1_001
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008294_A_PMO1_001
    [Teardown]    Actions after test


CB008285_B_010_CNI_94156_ RRC_Setup_and_RRC_Reestablishment_FR2_SA_Cell
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008285_B_010
    ${additional_logs_dir}=    Create directory for additional logs
    ${capture_file}=    Set Variable    attach1.pcap
    Start_collect_backhaul_pcap    capture_file=${capture_file}    filter=sctp
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008285_B_010
    Stop_collect_backhaul_pcap    capture_file=${capture_file}    log_dir=${additional_logs_dir}
    Verify RRC SETUP configuring BWP using initial BWP profile    capture_file=${additional_logs_dir}/${capture_file}
    ...    initial_bwp=${False}
    Enable CNI94156
    ${capture_file}=    Set Variable    attach2.pcap
    Start_collect_backhaul_pcap    capture_file=${capture_file}    filter=sctp
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008285_B_010
    Stop_collect_backhaul_pcap    capture_file=${capture_file}    log_dir=${additional_logs_dir}
    Verify RRC SETUP configuring BWP using initial BWP profile    capture_file=${additional_logs_dir}/${capture_file}
    ...    initial_bwp=${True}
    [Teardown]    Actions after test


CB008285_B_053_5GC001732_1CC_CSI_Report_Multiplexig_Max_UL_Tput_coderate_0.15_max_bits_27
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008285_B_053
    ${additional_logs_dir}=    Create directory for additional logs
    ${capture_file}=    Set Variable    attach_zeroDot15.pcap
    Start_collect_backhaul_pcap    capture_file=${capture_file}    filter=sctp
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=60s      tc_name=CB008285_B_053
    Stop_collect_backhaul_pcap    capture_file=${capture_file}    log_dir=${additional_logs_dir}
    Check csi report    capture_file=${additional_logs_dir}/${capture_file}    exp_cqi=${11}    exp_beam_report=${12}
    Change pucchF2MaxCodeRate
    ${capture_file}=    Set Variable    attach_zeroDot25.pcap
    Start_collect_backhaul_pcap    capture_file=${capture_file}    filter=sctp
    Check time to next PM period    time_buffer=${600}
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=60s      tc_name=CB008285_B_053
    Stop_collect_backhaul_pcap    capture_file=${capture_file}    log_dir=${additional_logs_dir}
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008285_B_053
    Check csi report    capture_file=${additional_logs_dir}/${capture_file}    exp_cqi=${10}    exp_beam_report=${10}
    [Teardown]    Actions after test


CB008294_A_B3_002_FR2_CA_for_SA_GNB-8CCDL_4CCUL_maxScell7DL3UL_contiguous_UL_DL_data_UDP_Peak
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008294_A_B3_002
    Check time to next PM period    time_buffer=${360}
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008294_A_B3_002
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008294_A_B3_006_8_4
    [Teardown]    Actions after test
