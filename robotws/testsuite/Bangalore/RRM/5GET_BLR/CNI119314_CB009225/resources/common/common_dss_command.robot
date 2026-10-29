*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com
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
    [Documentation]    This keyword is for setupping XP Link.
    Log To Console   \nSetup XP Link...\n
    ${pattern}    Set Variable    ENB-2: XpAP Link with GNB-1 .* is up
    ute_wtssim.Execute Egate Command    sim_trace enb\=2 protocol\=xp on
    Sleep    1s    reason=make sure the cmd take affect
    ute_wtssim.Execute Egate Command    enb_xp_param id\=2 xp_peers\=none
    Sleep    1s    reason=make sure the cmd take affect
    ute_wtssim.Execute Egate Command    enb_xp_param id\=2 xp_peers\=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_xp_link_up enb\=2 target\=1
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

Set LTE NR DSS Mode
    [Documentation]    This keyword is for setting LTE NR DSS MODE.
    Log To Console   \nSet LTE NR DSS Mode...\n
    ute_wtssim.Execute Egate Command    enb_cell_param id\=1 enb\=2 lte_nr_dss_mode\=DL_CRS_TDM_UL_FDM antenna_ports_num\=2

Setup DSS Link
    [Documentation]    This keyword is for setupping DSS Link.
    Log To Console   \nSetup DSS Link...\n
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ute_wtssim.Execute Egate Command    dss_enb_param id\=2 feature_flag\=on message_sets\=V1,DMS2
    Sleep    1s    reason=make sure the cmd take affect
    ute_wtssim.Execute Egate Command    enb_configure_dss_partnership enb\=2 cell\=1 dss_peer\=1:1
    Sleep    1s    reason=make sure the cmd take affect
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    establish_enb_dss_partnership enb\=2 cell\=1 tgt_enb\=1 tgt_cell\=1
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

SA Register UE
    [Arguments]    ${ue_id}   ${profile_id}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during SA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | Specified UE ID |
    ...    | profile_id | Yes | Test profile in 5G-UE |
    ...    Example:
    ...    | SA Register UE | 1 | 1 |
    Log To Console    start 5G attach...
    Sleep    60s    reason=make sure the procees is ready before ue attach
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_register id\=${ue_id} profile\=${profile_id}    pass_regexp=REGISTRATION COMPLETE    timeout=3minutes
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=wait 5G attach is stable

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
    [Arguments]    ${min_dss_ratio}    ${max_dss_ratio}
    [Documentation]    This keyword is used to set DL resource cell reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_dss_ratio | Yes | The minimum value of DSS share ratio |
    ...    | max_dss_ratio | Yes | The maximum value of DSS share ratio |
    ...    Example:
    ...    | Set DL RESOURCE Cell Reservation | 15 | 70 |
    Reset DL Reservation
    Sleep    2s    reason=make sure the cmd take affect
    Reset UL Reservation
    Sleep    2s    reason=make sure the cmd take affect
    DL Resource cell Reservation    subframes=${FIX_SUBFRAMES}  min_dss_ratio=${min_dss_ratio}  max_dss_ratio=${max_dss_ratio}

Reset DL Reservation
    [Documentation]    This keyword is used to reset DL reservation.
    Log To Console    start set dl resource cell reservation...
    ${command}    Set Variable    enb_dss_cell_resource_reservation_dl enb=2 cell=1 reset
    ute_wtssim.Execute Egate Command    ${command}

Reset UL Reservation
    [Documentation]    This keyword is used to reset UL reservation.
    Log To Console    start set ul resource cell reservation...
    ${command}    Set Variable    enb_dss_cell_resource_reservation_ul enb=2 cell=1 reset
    ute_wtssim.Execute Egate Command    ${command}

DL Resource cell Reservation
    [Arguments]  ${subframes}   ${min_dss_ratio}    ${max_dss_ratio}
    [Documentation]    This keyword is for dl resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | subframes | Yes | Fixed normal subframes |
    ...    | min_dss_ratio | Yes | The minimum value of DSS share ratio |
    ...    | max_dss_ratio | Yes | The maximum value of DSS share ratio |
    ...    Example:
    ...    | DL Resource cell Reservation | 1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001 | 15 | 70|
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_dss_dl_resource_cell_reservation cell=1 enb=2 reserved_fixed_normal_subframes=${subframes}
    Sleep    5s    reason=make sure the cmd take affect
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_dss_dl_resource_cell_reservation cell=1 enb=2 min_lte_nr_dss_ratio=${min_dss_ratio} max_lte_nr_dss_ratio=${max_dss_ratio}
    Sleep    5s    reason=make sure the cmd take affect

UL Resource cell Reservation
    [Arguments]    ${min_prb_ratio}    ${max_prb_ratio}
    [Documentation]    This keyword is for ul resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_prb_ratio | Yes | The minimum value of PRB share ratio |
    ...    | max_prb_ratio | Yes | The maximum value of PRB share ratio |
    ...    Example:
    ...    | enb_dss_ul_cell_resource_reservation  | 2 | 1 | 30 | 70 |
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${command}    Set Variable    enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_dss_ul_cell_resource_reservation enb=2 cell=1 minimum_prb_share=${min_prb_ratio} maximum_prb_share=${max_prb_ratio}
    Sleep    5s    reason=make sure the cmd take affect
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}   timeout=3minutes
    Sleep    5s    reason=make sure the cmd take affect
    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=2 cell=1

Cell Resource Coordination
    [Documentation]    This keyword is for cell resource coordination.
    ${pattern}    Set Variable    EN DSS DL Cell Subframe Resource Coordination: both NEs synchronized
    ${command}    Set Variable  enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}   timeout=3minutes
    Log To Console    \n${output}

Cell Allocation
    [Arguments]    ${nor_subframe}  ${prb_list}
    [Documentation]    This keyword is used to allocate cell resource.
    ...    | Input Parameters | Man. | Description |
    ...    | nor_subframe | Yes | The dl allocated normal subframes |
    ...    | prb_list | Yes | It shows the info of startprb and amount of prbs. e.g. 1,30 1:startprb  30:amount of prbs.|
    ...    Example:
    ...    | Cell Allocation | 0010000000-0000001000-0000000000-0000000000-0000000000-0000001000-0000000000-0000000000 | 1,30 |
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL
    ...    allocation_start_time=immediate dl_allocated_normal_subframes=${nor_subframe}
    ute_wtssim.Execute Egate Command    ${command}
    sleep    5s    reason=make sure the cmd take affect
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1
    ...    dir=UL allocation_start_time=immediate ul_allocated_prb_list=${prb_list}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=SystemInformationBlockType4-NR updated   timeout=2minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    SystemInformationBlockType4-NR updated   partial_match=${true}
    Log To Console    \n${output}

