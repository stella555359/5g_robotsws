*** Settings ***
Documentation
...   Author: Wu Rong
...   Description: Test case steps implementation

*** Keywords ***
Change graceful shutdown status
    [Documentation]    Author: Wu Rong
    ...    1.exp_status: supported values: Shutting Down, Locked, Unlocked
    ...    2.Online modify administrativeState value
    [Arguments]    ${cell_idx}    ${gnb_index}=${0}
    ...    ${exp_status}=Shutting Down    ${du_index}=${0}
    log to console     ======Change administrativeState value======
    &{dict_params_to_modify}    Create dictionary
    ${NRBTS_ID}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].global_bts_id}
    ${MRBTS_ID}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].instance_id}
    ${nidd_modify_update}    evaluate
    ...    [dict(dist_name='MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}', parameter='administrativeState', value='${exp_status}')]
    Set to dictionary    ${dict_params_to_modify}    param_to_upd=${nidd_modify_update}
    cloud_online_modify.online_modify_for_params_update_with_non_provision_method    params_to_modify=${dict_params_to_modify}
    ...    connection=OAM_gnb${gnb_index}_du${du_index}    bts_type=du


Verify graceful cell administrative status
    [Documentation]     Author: Wu Rong
    ...    1.expect_status: supported values: Shutting Down, Locked, Unlocked
    [Arguments]    ${expect_status}    ${cell_idx}=${1}
    log to console    ======Check gracefull cell administrative status======
    ${NR_CELL_ID_MAPPING}=    cloud_gnb.get_relation_mapping_between_cell_and_others
    should_be_equal_as_strings    ${NR_CELL_ID_MAPPING[${cell_idx}]['detail_cells_info']['administrative_state']}    ${expect_status}
    ...    ignore_case = True


Step1 Change Pcell to graceful shutdown status and HO success
    [Documentation]    Author: Wu Rong
    ...    1.UE attach to TDD cell with 4CC UL CA, check tput;
    ...    2.Modify administrative value of TDD pcell to tigger graceful shutdown;
    ...    3.Verify intra-Ho successfully.
    [Arguments]    ${tcpdump_log_name}=Intra_gNB_Ho_By_Graceful_Shutdown
    log to console    ======Step1 Change Pcell to graceful shutdown status and HO success======
    Run keyword and continue on failure    ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    actBufferBasedScellAddition=oneShot_Dl_Fr1    is_need_to_stop_traffic=${False}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ${cell_informations}    cloud_gnb.get_relation_mapping_between_cell_and_others
    ${expect_Ho_target_cell}    Set variable    ${cell_informations[${GRACEFUL_SHUTDOWN_HO_TARGET_CELL}]['physicalCellId']}
    Change status for parameter cellBarred on GNB DU    exp_status=notBarred    list_cell_ids=${GRACEFUL_SHUTDOWN_HO_TARGET_CELL}
    Start F1AP Log On vCU OCP Master    gnb_index=${gnb_index}   f1ap_collector_alias=${tcpdump_log_name}
    Change graceful shutdown status    cell_idx=${PCELL_ID}
    wait until keyword succeeds    5min    10sec
    ...    Verify graceful cell administrative status    expect_status=Locked    cell_idx=${PCELL_ID}
    ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    Verify Intra-gNB handover successfully    tcpdump_log=${ute_log_path_f1ap}
    ...    expect_Ho_target_cell=${expect_Ho_target_cell}
    [Teardown]    Run keyword and ignore error    run keywords
    ...    Stop data transfer and detach UE    data_transfer_direction=both    AND
    ...    Change graceful shutdown status    exp_status=Unlocked    cell_idx=${PCELL_ID}    AND
    ...    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}

Step2 Change Scell to graceful shutdown status and scell release
    [Documentation]    Author: Wu Rong
    ...    1.UE attach to TDD cell with 4CC UL CA, check tput;
    ...    2.Modify administrative value of FDD scell to tigger scell release;
    ...    3.Verify scell release successfully.
    [Arguments]    ${tcpdump_log_name}=Scell_release_By_Graceful_Shutdown
    log to console    ======Step2 Change scell to graceful shutdown status and scell release======
    Change status for parameter cellBarred on GNB DU    exp_status=notBarred    list_cell_ids=${PCELL_ID}
    Run keyword and continue on failure    ca_specifical_step.L3 call with UL or DL CA exist
    ...    cell_index=${CELL_INDEX_LIST}    actBufferBasedScellAddition=oneShot_Dl_Fr1    is_need_to_stop_traffic=${False}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    Start F1AP Log On vCU OCP Master    gnb_index=${gnb_index}   f1ap_collector_alias=${tcpdump_log_name}
    Change graceful shutdown status    cell_idx=${GRACEFUL_SHUTDOWN_SCELL_RELEASE_CELL}
    wait until keyword succeeds    5min    10sec
    ...    Verify graceful cell administrative status    expect_status=Locked    cell_idx=${GRACEFUL_SHUTDOWN_SCELL_RELEASE_CELL}
    ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    Verify Scell Released from F1AP log    log_path_pcap=${ute_log_path_f1ap}
    [Teardown]    Run keyword and ignore error    run keywords    Change graceful shutdown status    exp_status=Unlocked
    ...    cell_idx=${GRACEFUL_SHUTDOWN_SCELL_RELEASE_CELL}    AND
    ...    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}
