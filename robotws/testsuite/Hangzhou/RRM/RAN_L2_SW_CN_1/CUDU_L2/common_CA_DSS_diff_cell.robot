*** Settings ***
Resource          ./common_setup_teardown.robot

*** Variables ***
${FIX_SUBFRAMES}    1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001

*** Keywords ***
Start UTE WTS FOR DSS
    [Documentation]    This keyword is to kill Running WTS Binaries,start edaemon, egate and clean log files.
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log*

Setup XP LINK
    [Arguments]    ${enb_id}=2   ${xppeers_id}=1
    [Documentation]    This keyword is to setup XP Link.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | enb_id | No | bts_id for eNB |
    ...    | xppeers_id | No | bts_id for gNB |
    ...
    ...    Examples:
    ...    | Setup XP LINK | 2 | 1 |
    ...
    Log To Console   \nSetup XP Link...\n
    ute_wtssim.Execute Egate Command    sim_trace enb\=${enb_id} protocol\=xp on
    ute_wtssim.Execute Egate Command    sim_trace enb\=${enb_id} protocol\=xpu off
    # Sleep    1s    reason=make sure the cmd take affect
    ute_wtssim.Execute Egate Command    enb_xp_param id\=${enb_id} xp_peers\=none
    # Sleep    1s    reason=make sure the cmd take affect
    ute_wtssim.Execute Egate Command    enb_xp_param id\=${enb_id} xp_peers\=${xppeers_id}
    ${pattern}    Set Variable    ENB-${enb_id}: XpAP Link with GNB-${xppeers_id} .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_xp_link_up enb\=${enb_id} target\=${xppeers_id}
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

Set LTE NR DSS Mode
    [Arguments]   ${enb_id}=2    ${cell_id}=1    ${ant_port}=2
    [Documentation]    This keyword is to set LTE NR DSS Mode
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | enb_id | No | bts_id of eNB |
    ...    | cell_id | No | cell_id of eNB |
    ...    | ant_port | No | ant_port for eNB, |
    ...
    ...    Examples:
    ...    | Set LTE NR DSS Mode | 2 | 1 | 2 |
    ...
    Log To Console   \nSet LTE NR DSS Mode...\n
    ${cmd}    Catenate    SEPARATOR=${SPACE}    enb_cell_param id\=${cell_id} enb\=${enb_id}
    ...    lte_nr_dss_mode\=DL_CRS_TDM_UL_FDM antenna_ports_num\=${ant_port}
    ute_wtssim.Execute Egate Command    ${cmd}

Enable DSS Feature On
    [Arguments]    ${enb_id}=2
    ute_wtssim.Execute Egate Command    dss_enb_param id\=${enb_id} feature_flag\=on message_sets\=V1,DMS2

Setup DSS Link
    [Arguments]    ${enb_id}=2    ${gnb_id}=1    ${enb_cell_id}=1    ${gnb_cell_id}=1
    [Documentation]    This keyword is to setup DSS Link.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | enb_id | No | bts_id of eNB |
    ...    | gnb_id | No | bts_id for gNB |
    ...    | cell_id | No | cell_id of eNB and gNB, they are the same |
    ...
    ...    Examples:
    ...    | Setup DSS Link | 2 | 1 | 1 |
    ...
    Log To Console   \nSetup DSS Link...\n
    ${cmd}    Catenate    SEPARATOR=${SPACE}    enb_configure_dss_partnership enb\=${enb_id}
    ...    cell\=${enb_cell_id} dss_peer\=${gnb_id}:${gnb_cell_id}
    ute_wtssim.Execute Egate Command    ${cmd}
    ${cmd}    Catenate    SEPARATOR=${SPACE}    establish_enb_dss_partnership enb\=${enb_id}
    ...    cell\=${enb_cell_id} tgt_enb\=${gnb_id} tgt_cell\=${gnb_cell_id}
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

SA Register UE
    [Arguments]    ${ue_id}   ${profile_id}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during SA L3 Call on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | Specified UE ID |
    ...    | profile_id | Yes | Test profile in 5G-UE |
    ...
    ...    Example:
    ...    | SA Register UE | 1 | 1 |
    ...
    Log To Console    start 5G attach...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_register id\=${ue_id} profile\=${profile_id}    pass_regexp=REGISTRATION COMPLETE    timeout=3min
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=Wait 5G attach is stable

SA PDU Session Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup ue=${ue_id} gw=1 pdu=1 nwslice=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...   cmd=${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    \n${output}

Set DL RESOURCE Cell Reservation
    [Arguments]    ${min_dss_ratio}    ${max_dss_ratio}    ${enb_id}=2   ${enb_cell_id}=1
    [Documentation]    This keyword is used to set DL resource cell reservation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | min_dss_ratio | Yes | The minimum value of DSS share ratio |
    ...    | max_dss_ratio | Yes | The maximum value of DSS share ratio |
    ...    | enb_id | No | bts_id of eNB |
    ...    | enb_cell_id | No | cell_id of eNB |
    ...
    ...    Example:
    ...    | Set DL RESOURCE Cell Reservation | 15 | 70 | 2 | 1 |
    ...
    Reset DL Reservation    ${enb_id}   ${enb_cell_id}
    Reset UL Reservation    ${enb_id}   ${enb_cell_id}
    DL Resource cell Reservation    subframes=${FIX_SUBFRAMES}    min_dss_ratio=${min_dss_ratio}
    ...    max_dss_ratio=${max_dss_ratio}    enb_id=${enb_id}   enb_cell_id=${enb_cell_id}

Reset DL Reservation
    [Arguments]    ${enb_id}=2   ${enb_cell_id}=1
    [Documentation]    This keyword is used to reset DL reservation.
    Log To Console    start set dl resource cell reservation...
    ${command}    Set Variable    enb_dss_cell_resource_reservation_dl enb=${enb_id} cell=${enb_cell_id} reset
    ute_wtssim.Execute Egate Command    ${command}

Reset UL Reservation
    [Arguments]    ${enb_id}=2   ${enb_cell_id}=1
    [Documentation]    This keyword is used to reset UL reservation.
    Log To Console    start set ul resource cell reservation...
    ${command}    Set Variable    enb_dss_cell_resource_reservation_ul enb=${enb_id} cell=${enb_cell_id} reset
    ute_wtssim.Execute Egate Command    ${command}

DL Resource cell Reservation
    [Arguments]   ${subframes}   ${min_dss_ratio}    ${max_dss_ratio}    ${enb_id}=2   ${enb_cell_id}=1
    [Documentation]    This keyword is for dl resource cell Reservation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | subframes | Yes | Fixed normal subframes |
    ...    | min_dss_ratio | Yes | The minimum value of DSS share ratio |
    ...    | max_dss_ratio | Yes | The maximum value of DSS share ratio |
    ...    | enb_id | No | bts_id of eNB |
    ...    | enb_cell_id | No | cell_id of eNB |
    ...
    ...    Example:
    ...    | DL Resource cell Reservation | 1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001 | 15 | 70|
    ...
    ${cmd}    Catenate    SEPARATOR=${SPACE}    enb_dss_dl_resource_cell_reservation cell=${enb_cell_id}
    ...    enb=${enb_id} reserved_fixed_normal_subframes=${subframes}
    ute_wtssim.Execute Egate Command    cmd=${cmd}
    ${cmd}    Catenate    SEPARATOR=${SPACE}    enb_dss_dl_resource_cell_reservation cell=${enb_cell_id}
    ...    enb=${enb_id} min_lte_nr_dss_ratio=${min_dss_ratio} max_lte_nr_dss_ratio=${max_dss_ratio}
    ute_wtssim.Execute Egate Command    cmd=${cmd}

UL Resource Cell Reservation
    [Arguments]    ${min_prb_ratio}    ${max_prb_ratio}    ${enb_id}=2    ${gnb_id}=1    ${enb_cell_id}=1    ${gnb_cell_id}=1
    [Documentation]    This keyword is for ul resource cell Reservation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | min_prb_ratio | Yes | The minimum value of PRB share ratio |
    ...    | max_prb_ratio | Yes | The maximum value of PRB share ratio |
    ...    | enb_id | No | bts_id of eNB |
    ...    | gnb_id | No | bts_id for gNB |
    ...    | cell_id | No | cell_id of eNB and gNB, they are the same |
    ...
    ...    Example:
    ...    | enb_dss_ul_cell_resource_reservation | 30 | 70 | 2 | 1 | 1 |
    ...
    ${command}    Catenate    SEPARATOR=${SPACE}    enb_dss_ul_cell_resource_reservation enb=${enb_id} cell=${enb_cell_id}
    ...    minimum_prb_share=${min_prb_ratio} maximum_prb_share=${max_prb_ratio}
    ute_wtssim.Execute Egate Command    cmd=${command}
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${command}    Catenate    SEPARATOR=${SPACE}    enb_dss_cell_resource_coordination enb=${enb_id} cell=${enb_cell_id}
    ...    tgt_enb=${gnb_id} tgt_cell=${gnb_cell_id} dir=UL
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}   timeout=3minutes

Cell Resource Coordination
    [Arguments]    ${enb_id}=2    ${gnb_id}=1    ${enb_cell_id}=1    ${gnb_cell_id}=1    ${dir}=DL
    [Documentation]    This keyword is for cell resource coordination.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | enb_id | No | bts_id of eNB |
    ...    | gnb_id | No | bts_id for gNB |
    ...    | cell_id | No | cell_id of eNB and gNB, they are the same |
    ...    | dir | No | the directory of transfer, such as DL/UL |
    ...
    ...    Examples:
    ...    | Cell Resource Coordination | 2 | 1 | 1 | DL |
    ...
    ${pattern}    Set Variable    EN DSS DL Cell Subframe Resource Coordination(: both NEs synchronized)?( success on remote NE)?
    ${command}    Catenate    SEPARATOR=${SPACE}    enb_dss_cell_resource_coordination enb=${enb_id}
    ...    cell=${enb_cell_id} tgt_enb=${gnb_id} tgt_cell=${gnb_cell_id} dir=${dir}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}   timeout=3minutes
    Log To Console    \n${output}

Cell Allocation
    [Arguments]    ${nor_subframe}  ${prb_list}    ${enb_id}=2   ${gnb_id}=1    ${enb_cell_id}=1    ${gnb_cell_id}=1    ${dl_prb_list}=${EMPTY}
    [Documentation]    This keyword is used to allocate cell resource.
    ...    | Input Parameters | Man. | Description |
    ...    | nor_subframe | Yes | The dl allocated normal subframes |
    ...    | prb_list | Yes | It shows the info of startprb and amount of prbs. e.g. 1,30 1:startprb  30:amount of prbs.|
    ...    Example:
    ...    | Cell Allocation | 0010000000-0000001000-0000000000-0000000000-0000000000-0000001000-0000000000-0000000000 | 1,30 |
    ${command_wo_prb}    Catenate    SEPARATOR=${SPACE}    enb_dss_resource_allocation enb=${enb_id} cell=${enb_cell_id} tgt_enb=${gnb_id}
    ...    tgt_cell=${gnb_cell_id} dir=DL allocation_start_time=immediate dl_allocated_normal_subframes=${nor_subframe}
    ${command_w_prb}    Catenate    SEPARATOR=${SPACE}    enb_dss_resource_allocation enb=${enb_id} cell=${enb_cell_id} tgt_enb=${gnb_id}
    ...    tgt_cell=${gnb_cell_id} dir=DL allocation_start_time=immediate dl_allocated_normal_subframes=${nor_subframe}
    ...    dl_prb_area_allocation_list=${dl_prb_list}
    ${command}    Set Variable If    '${dl_prb_list}' == '${empty}'    ${command_wo_prb}    ${command_w_prb}
    ute_wtssim.Execute Egate Command    ${command}
    ${command}    Catenate    enb_dss_resource_allocation enb=${enb_id} cell=${enb_cell_id} tgt_enb=${gnb_id} tgt_cell=${gnb_cell_id}
    ...    dir=UL allocation_start_time=immediate ul_allocated_prb_list=${prb_list}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=CRM Trigger Resource Allocation   timeout=2minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    CRM Trigger Resource Allocation   partial_match=${true}
    Log To Console    \n${output}
    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=${enb_id} cell=${enb_cell_id}    pass_regexp=Configured DSS partnership

Enable DSS DMS3 Feature On
    [Arguments]    ${enb_id}=2
    ute_wtssim.Execute Egate Command    dss_enb_param id\=${enb_id} feature_flag\=on message_sets\=V1,DMS3

Set LTE NR DSS Mode PHASE3
    [Arguments]    ${enb_id}=2    ${enb_cell_id}=1    ${ant_port}=2
    [Documentation]    This keyword is to set LTE NR DSS Mode
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | enb_id | No | bts_id of eNB |
    ...    | cell_id | No | cell_id of eNB |
    ...    | ant_port | No | ant_port for eNB, |
    ...
    ...    Examples:
    ...    | Set LTE NR DSS Mode | 2 | 1 | 2 |
    ...
    Log To Console    \nSet LTE NR DSS Mode...\n
    ${cmd}    Catenate    SEPARATOR=${space}    enb_cell_param id\=${ENB_CELL_ID} enb\=${enb_id}
    ...    lte_nr_dss_mode\=DSS_PHASE_3 antenna_ports_num\=${ant_port}
    ute_wtssim.Execute Egate Command    ${cmd}
    ute_wtssim.Execute Egate Command    enb_cell_dss_feature enb\=${enb_id} id\=${enb_cell_id} nr_dl_peak_rate_increase\=on
    ute_wtssim.Execute Egate Command    enb_cell_dss_feature enb\=${enb_id} id\=${enb_cell_id} superfast_allocation\=on
    ute_wtssim.Execute Egate Command    enb_dss_cell_param enb\=${enb_id} id\=${enb_cell_id} dl_resource_sharing_algo\=dl_prb_load_based

Setup DSS Link PHASE3
    [Arguments]    ${enb_id}=2    ${gnb_id}=1    ${enb_cell_id}=1    ${gnb_cell_id}=1
    [Documentation]    This keyword is to setup DSS Link.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | enb_id | No | bts_id of eNB |
    ...    | gnb_id | No | bts_id for gNB |
    ...    | cell_id | No | cell_id of eNB and gNB, they are the same |
    ...
    ...    Examples:
    ...    | Setup DSS Link | 2 | 1 | 1 |
    ...
    Log To Console    \nSetup DSS Link...\n
    ${cmd}    Catenate    SEPARATOR=${space}    enb_configure_dss_partnership enb\=${enb_id}
    ...    cell\=${enb_cell_id} dss_peer\=${gnb_id}:${gnb_cell_id}
    ute_wtssim.Execute Egate Command    ${cmd}
    ${cmd}    Catenate    SEPARATOR=${space}    enb_crm_cell_resource_reservation enb\=${enb_id}
    ...    cell\=${enb_cell_id} tgt_enb\=${gnb_id} tgt_cell\=${gnb_cell_id}
    ...    assigned_dl_minimum_share_to_nr\=30 assigned_dl_maximum_share_to_nr\=100
    ...    assigned_dl_minimum_share_to_lte\=15 assigned_dl_maximum_share_to_lte\=70
    ...    assigned_ul_minimum_share_to_nr\=20 assigned_ul_maximum_share_to_nr\=70
    ute_wtssim.Execute Egate Command    ${cmd}
    ute_wtssim.Execute Egate Command    enb_crm_param id\=${enb_id} ul_qos_load_meas_timer\=30 dl_qos_load_meas_timer\=10
    ${cmd}    Catenate    SEPARATOR=${SPACE}    establish_enb_dss_partnership enb\=${enb_id}
    ...    cell\=${enb_cell_id} tgt_enb\=${gnb_id} tgt_cell\=${gnb_cell_id}
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

Cell Resource Coordination PHASE3
    [Arguments]    ${enb_id}=2    ${gnb_id}=1    ${enb_cell_id}=1    ${gnb_cell_id}=1    ${dir}=DL
    [Documentation]    This keyword is for cell resource coordination.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | enb_id | No | bts_id of eNB |
    ...    | gnb_id | No | bts_id for gNB |
    ...    | cell_id | No | cell_id of eNB and gNB, they are the same |
    ...    | dir | No | the directory of transfer, such as DL/UL |
    ...
    ...    Examples:
    ...    | Cell Resource Coordination | 2 | 1 | 1 | DL |
    ...
    ${pattern}    Set Variable    EN DSS DL Cell Resource Area Coordination: both NEs synchronized
    ${command}    Catenate    SEPARATOR=${space}    enb_dss_cell_resource_coordination enb=${enb_id}
    ...    cell=${enb_cell_id} tgt_enb=${gnb_id} tgt_cell=${gnb_cell_id} dir=${dir}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}    timeout=3minutes
    Log To Console    \n${output}
