# *** Settings ***
# Resource    ../../CB007873/Resources/CB007873_keywords.robot
# 
# Documentation    Suite description
# ...   author: Cui Lingue
# ...   contact: lingxue.cui@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC001390-G/-EE
# 
# Force Tags    5G_RRM
# ...    PY36
# Suite Setup     Mobility suite preparation
# Suite Teardown  run keyword and ignore error    run keywords    Turn off cplane debug log on gNB    AND
# ...    COAM Teardown gnb connections    connection=${ADJ_GNB_OAM_ALIAS}    AND
# ...    ssh.disconnect    connection=${ADJ_GNB_ASIK_ALIAS}    AND
# ...    CA Suite teardown
# 
# *** Variables ***
# ${PCELL_EXP_RATIO_WI_MG}    0.8875
# ${SCELL_EXP_RATIO_WI_MG}    0.85
# 
# *** Test Cases ***
# #5GC001390-EE_01_Successful_Configuration_Of_Measurement_gap_configuration_with_beamforming_perUE_SA
# #    [Tags]    CRT_21A    CRT_21B
# #    [Documentation]    Author: Wang Yixiang
# #    ...    Description: The purpose of this test case is to verify that when UE configured with FDD  FR1-TDD carrier aggregation triggers
# #    ...    A2 measurement report with the purpose to initiate Inter-frequency measurements.
# #    ...    DRX configuration is released within the RRC reconfiguration configuring measurement gaps and A3/A5 and A1 measurements.
# #    ...    UE can perform CSI measurements and reporting for channel state on Pcell and Scell and also for beam reporting on the SCell.
# #    ...    test steps:
# #    ...    1. drx and A1/A2/A3/A5 confiuration configured at UE
# #    ...    2. ul/dl data transmition successfully
# #    ...    3. after A2 triggered successfully, measGap and A1/A3/A5 measConfig configured at UE.
# #    ...    4. 5G-UE can perform CSI measurements and reporting for channel state on Pcell and Scell and also for beam reporting on the SCell.
# #    ...    5. ul/dl data transmition successfully
# #    ...    6. trigger A1 successfully
# #    ...    7. after A1 triggered successfully, ul/dl data transmition successfully, peek possible
# #    ...       after A1 triggered successfully, measGap released and A2 measConfig configured at UE.
# #    [Setup]    Mobility case setup    nidd_modify_via_api=${API_CASE_MEAS_GAP}    nidd_modify_on_target_gnb=${TGT_GNB_API_NRARFCN_INTER_FREQ}
# #    sleep    30s    msg=Wait for gNB stable to be attach after restart.
# #    UE attach check CA and DRX
# #    Start data transfer based on direction    dl_tput=${DL_TPUT}     ul_tput=${UL_TPUT}
# #    ...    duration=${DURATION_OF_DATA_TRANSFER}    process_num=${TCP_PROCESS_NUMBER}    data_transfer_direction=both
# #    Sleep    ${WAIT_TIME_FOR_TPUT_STABLE}    reason=Wait for traffic to be stable.
# #    ${tput_info_before}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}    tput_duration=30s
# #
# #    ${csi_check_result}    Trigger A2 and verify config of A1 A3 A5 and drx release and csi report
# #    sleep    60s    msg=Aasyslog has 30s gap with real time.
# #    ${tput_info_A2_triggered}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}
# #    ...    tput_duration=30s
# #    run keyword if    '${csi_check_result}'=='${True}'     Verify TPUT change before and after measurement gap
# #    ...    tput_info_before=${tput_info_before}    tput_info_after=${tput_info_A2_triggered}
# #    ...    expected_ratio=${PCELL_EXP_RATIO_WI_MG},${SCELL_EXP_RATIO_WI_MG}
# #    ...    cell_id=${PCELL_ID},${SCELL_ID}
# #
# #    Trigger A1 and verify config of A2 and measurement gap release and drx setup
# #    sleep    60s    msg=Aasyslog has 30s gap with real time.
# #    ${tput_info_after}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}    tput_duration=30s
# #    Verify TPUT not change a lot before and after
# #    ...    tput_info_before=${tput_info_before}    tput_info_after=${tput_info_after}
# #    [Teardown]    run keyword and ignore error    Mobility case teardown
# 
# 5GC001390-EE_09_Successful_inter-Fre_inter-gNB_HO_from_FDD+FR1TDD_2CA_to_FDD+FR1TDD_2CA_SA
#     [Tags]    CRT_21A    CRT_21B    CRT_22R1
#     [Documentation]    Author: Cui Lingxue
#     [Setup]    Mobility case setup    nidd_modify_via_api=${API_CASE_HO_INTER_FREQ}    nidd_modify_on_target_gnb=${TGT_GNB_API_NRARFCN_INTER_FREQ}
#     sleep    30s    msg=Wait for gNB stable to be attach after restart.
#     CA_basic_L3_call    tcpdump_log_name=init_attach_for_unsucc_ho
#     Initialize PA ports of adjacent gNB RUs
# 
#     log to console    Start to trigger unsuccessful handover scenario...
#     run keyword if    '${PROGRAM}'=='22R1'    _WA_for_adj_gNB_SSH
#     ${delta_file_list_reverse}    Modify maxNumOfUsers to 0 on target gNB    connection=${ADJ_GNB_OAM_ALIAS}
#     Start capture F1AP log    tcpdump_collector_name=unsucc_handover_source    options=-i any sctp
#     Start capture F1AP log    gnb_id=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}    tcpdump_collector_name=unsucc_handover_
# ...target   options=-i any sctp
#     Adjust attenuator to trigger A2 measurement report
#     ${ho_log_source}    Stop tcpdump log collection    tcpdump_collector_name=unsucc_handover_source
#     ${ho_log_target}    Stop tcpdump log collection    tcpdump_collector_name=unsucc_handover_target
#     ${handover_status}    run keyword and return status    Verify inter-gNB handover    intra_freq=${False}
#     ...    log_path_source=${ho_log_source}    log_path_target=${ho_log_target}
#     should not be true    ${handover_status}
# 
#     log to console    Restore env to prepare for next handover....
#     run keyword if    '${PROGRAM}'=='22R1'    _WA_for_adj_gNB_SSH
#     Restore maxNumOfUsers on target gNB    delta_file_list_reverse=${delta_file_list_reverse}    connection=${ADJ_GNB_OAM_ALIAS}
#     Block adjacent gNB RUs
#     Initialize attenuator for specified RU    exp_pa_value=${INIT_PA_VALUE_${MRBTS_ID}}    ru_index=${PCELL_RU_INDEX}
#     Stop data transfer and detach UE
# 
#     log to console    Start to trigger successful handover scenario...
#     ${tput_info_cell_src_gnb}    CA_basic_L3_call    tcpdump_log_name=init_attach_for_succ_ho
#     Initialize PA ports of adjacent gNB RUs
#     run keyword if    '${PROGRAM}'=='22R1'    _WA_for_adj_gNB_SSH
#     Start capture F1AP log    tcpdump_collector_name=succ_handover_source    options=-i any sctp
#     Start capture F1AP log    gnb_id=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}    tcpdump_collector_name=succ_handover_target    options=-i any sctp
#     Adjust attenuator to trigger A2 measurement report
#     sleep    10s    msg=Wait for UE handover
#     ${ho_log_source}    Stop tcpdump log collection    tcpdump_collector_name=succ_handover_source
#     ${ho_log_target}    Stop tcpdump log collection    tcpdump_collector_name=succ_handover_target
# 
#     log to console    Verify tput on target gNB......
#     sleep    60s    msg=Aasyslog has 30s gap with real time.
# #    run keyword if    '${PROGRAM}'=='22R1'    _WA_for_adj_gNB_SSH
#     ${tput_info_cell_tgt_gnb}    run keyword and continue on failure
#     ...    Check Tput info for each cell    gnb_index=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}
#     ...    dl_cell_id=1,2    exp_dl=100,200    ul_cell_id=1,2    exp_ul=50,0
#     ...    nr_cell_id_mapping=${ADJ_GNB_NR_CELL_ID_MAPPING}
#     run keyword and continue on failure    Verify inter-gNB handover    intra_freq=${False}
#     ...    log_path_source=${ho_log_source}    log_path_target=${ho_log_target}
#     [Teardown]    run keyword and ignore error    Mobility case teardown
# 
# 5GC001390_G_B1_1001_Cell_Lock_of_FDD_Cell_with_Graceful_Cell_Shutdown_SA
#     [Tags]    CRT_21A    CIT_TRUNK    CIT_21B    CRT_22R1    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    Author: Cui Lingxue
#     ...    Description: The purpose of this test case is to verify GNB’s supporting of the Cell Unlock is performed on the FDD cell which is the
#     ...                 PCell for UEs configured for Carrier Aggregation.
#     ...    Step 1> UE attach with CA activated on FDD cell as PCell TDD cell as SCell.
#     ...    Step 2> Perform cell lock on FDD cell without graceful shutdown.
#     ...    Step 3> Check UE behaviour throught tcpdump log, UE should perform re-select to TDD cell without CA.
#     ...    Step 4> (WA) Set TDD cell status to barred, detach UE.
#     ...    Step 5> Unlock FDD cell, attach UE to FDD cell.
#     ...    Step 6> (WA) Set TDD cell status to unbarred, detach UE.
#     ...    Step 7> UE attach and check log, CA should be activated for FDD as PCell and TDD as SCell.
#     ...    Note 2021-11-16: [PR617418] When DRX activated, the allocation of CSI-RS will change every time UE attach. In current configuration,
#     ...                     uplane only allows to allocate CSI-RS resources on slots N*20 (0, 20, 40, etc.), which result in overlap and UE release
#     ...                     for some calls when gap offset is set to, for example, 19.
#     ...                     This is expected behavior, according to 5G_CP_ARC_ALG_1760.
#     [Setup]    Mobility case setup    nidd_modify_via_api=${API_CASE_HO_INTER_FREQ}    nidd_modify_on_target_gnb=${TGT_GNB_API_NRARFCN_INTER_FREQ}
#     Enable graceful shutdown function
#     Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
#     CA_basic_L3_call    tcpdump_log_name=init_attach
#     Initialize PA ports of adjacent gNB RUs
# 
#     log to console    Start to trigger FDD cell block via graceful shutdown method.
#     run keyword if    '${PROGRAM}'=='22R1'    _WA_for_adj_gNB_SSH
#     Start capture F1AP log    tcpdump_collector_name=lock_fdd_cell    options=-i any sctp
#     Start capture F1AP log    gnb_id=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}    tcpdump_collector_name=lock_fdd_cell_neigh    options=-i any sctp
#     Lock FDD cell via rest api    graceful_shutdown=${True}
#     wait until keyword succeeds    5min    10sec
#     ...    Verify cell administrative status    expect_status=Locked    cell_idx=${PCELL_ID}    cell_group_idx=${PCELLNRCELLGRPID}
#     sleep    90sec    msg=Wait for UE meas neighbour cell and perform handover.
#     ${ute_log_path}     Stop tcpdump log collection    tcpdump_collector_name=lock_fdd_cell
#     ${ute_log_path_neigh}    Stop tcpdump log collection    tcpdump_collector_name=lock_fdd_cell_neigh
# 
#     log to console    Verify UE handover to available adjacent cells, UE traffic is continued on new cell.
#     run keyword and continue on failure    Verify inter-gNB handover    intra_freq=${False}
#     ...    log_path_source=${ute_log_path}    log_path_target=${ute_log_path_neigh}
#     run keyword if    '${PROGRAM}'=='22R1'    _WA_for_adj_gNB_SSH
#     ${tput_info_cell_tgt_gnb}    run keyword and continue on failure
#     ...    Check Tput info for each cell    gnb_index=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}
#     ...    dl_cell_id=1,2    exp_dl=100,200    ul_cell_id=1,2    exp_ul=50,0
#     ...    nr_cell_id_mapping=${ADJ_GNB_NR_CELL_ID_MAPPING}
#     Stop data transfer and detach UE
#     Block adjacent gNB RUs
# 
#     log to console    Unblock FDD cell, re-attach UE to FDD cell to verify service restoration.
#     Unlock FDD cell via rest api
#     Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
#     ...    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
#     sleep    30sec    msg=Wait for cell be ready to access.
# 
#     Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
#     CA_basic_L3_call    tcpdump_log_name=attach_after_unlock_fdd
#     [Teardown]    run keyword and ignore error    run keywords    Unlock FDD cell via rest api    AND
#     ...    Mobility case teardown
# 
# #5GC001390_B_18_Successful_Intra_Freq_Inter_gNB_incoming_HO_from_FDD_to_FDD+FR1TDD_2CA_SA
# #    [Tags]    CRT_21B
# #    [Documentation]    Author: Cui Lingxue
# #    [Setup]    Mobility case setup    nidd_modify_via_api=${API_CASE_HO_INTRA_FREQ}    nidd_modify_on_target_gnb=${TGT_GNB_API_NRARFCN_INTRA_FREQ}
# #    ...    intra_freq=${True}
# #    Deactivate feature 5GC001390 by carrierAggregationSupportList to none
# #    ${tput_info_cell_src_gnb}    run keyword and continue on failure  Basic_L3_call_No_CA    tcpdump_log_name=Non-CA_L3call
# #    Initialize PA ports of adjacent gNB RUs
# #
# #    log to console    Start to trigger intra-freq inter-gNB handover scenario...
# #    Start capture F1AP log    tcpdump_collector_name=succ_handover_source    options=-i any sctp
# #    Start capture F1AP log    gnb_id=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}    tcpdump_collector_name=succ_handover_t
# ...arget    options=-i any sctp
# #    Adjust attenuator to trigger A2 measurement report
# #    sleep    10s    msg=Wait for UE handover
# #    ${ho_log_source}    Stop tcpdump log collection    tcpdump_collector_name=succ_handover_source
# #    ${ho_log_target}    Stop tcpdump log collection    tcpdump_collector_name=succ_handover_target
# #
# #    log to console    Verify tput on target gNB......
# #    sleep    60s    msg=Aasyslog has 30s gap with real time.
# #    ${tput_info_cell_tgt_gnb}    run keyword and continue on failure
# #    ...    Check Tput info for each cell    gnb_index=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}
# #    ...    dl_cell_id=1,2    exp_dl=100,200    ul_cell_id=1,2    exp_ul=50,0
# #    ...    nr_cell_id_mapping=${ADJ_GNB_NR_CELL_ID_MAPPING}
# #    run keyword and continue on failure    Verify inter-gNB handover    intra_freq=${True}    ca_enabled=${False}
# #    ...    log_path_source=${ho_log_source}    log_path_target=${ho_log_target}
# #    Get Cell Pci And UE Rnti In Tcpdump    tcpdump_log=${ho_log_target}    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}
# #    ...    cell_id=1,2
# #    [Teardown]    run keyword and ignore error    run keywords
# #    ...    Activate feature 5GC001390 by setting carrierAggregationSupportList to ca_Fdd_Fr1Tdd    AND
# #    ...    Mobility case teardown
# 
# 
# *** Keywords ***
# Check tput info of adjacent gNB
#     [Arguments]    ${dl_cell_id}=1,2    ${exp_dl}=100,200    ${ul_cell_id}=1,2    ${exp_ul}=50,0    ${tput_duration}=60s
#     ${tput_info_cell}    Check Tput info for each cell    dl_cell_id=${dl_cell_id}    exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}
#     ...    exp_ul=${exp_ul}    tput_duration=${tput_duration}
#     ...    gnb_index=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}    nr_cell_id_mapping=${ADJ_GNB_NR_CELL_ID_MAPPING}
#     [Return]    ${tput_info_cell}
# 
# 
# _WA_for_adj_gNB_SSH
#     run keyword and ignore error    COAM Teardown gnb connections    connection=${ADJ_GNB_OAM_ALIAS}
#     run keyword and ignore error    ssh.disconnect    connection=${ADJ_GNB_ASIK_ALIAS}
#     run keyword and ignore error    Connect to gnb coam via ssl    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}
#     run keyword and ignore error    Connect to Common Unit Master    alias=${ADJ_GNB_ASIK_ALIAS}    gnb_index=${1}
