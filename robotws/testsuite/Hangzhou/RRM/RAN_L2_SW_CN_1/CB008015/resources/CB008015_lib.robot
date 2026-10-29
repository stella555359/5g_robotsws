*** Settings ***
Resource          ../../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Check UE Tput With Bearer
    [Arguments]     ${traffic_type}     ${target_tp}
    ${tput}    SA Get UE Average Traffic Internal    ${UE_ID}    1    ${traffic_type}
    Should Be True    "${tput}">="${target_tp}"

Check UE Pcell Scell TP On Target
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    Log To Console    The UE${ue_id} scell ${scell_index} ${dir} TPUT is : ${tput}Mb \n
    ${tp_delta}    Evaluate    ${tput}-${target_tp}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The tput is on target: ${target_tp}Mb \n

Check Tput On Target Pcell Plus Scell
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_sum_tp}
    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
    ${sum_tp}    evaluate    ${pcell_TP}+${scell_TP}
    Log To Console    DL Troughput is ${sum_tp}    console=True
    Should Be True    ${sum_tp}>=${target_sum_tp}

Delta Commission
    [Arguments]    ${delta_scf}
    ${scf_file_type}    Get File Type    ${delta_scf}
    Run Keyword If    '${scf_file_type}'=='json'    Delta Commission With SCF File    ${delta_scf}

Multi NSA UE Attach
    [Arguments]    ${GNB_ID}    ${BEAR_ID}    ${PCELL}    ${SCELL}    @{nsa_ue_list}
    : FOR    ${t_ue_id}    IN    @{sa_ue_list}
    \    NSA LTE Attach    ${t_ue_id}    1
    \    NSA 5G Attach    ${t_ue_id}    ${GNB_ID}    ${PCELL}    ${BEAR_ID}
    \    NSA Verify If Attach Passed

Multi SA UE Attach
    [Arguments]    ${sa_ue_list}
    : FOR    ${t_ue_id}    IN    @{sa_ue_list}
    \    SA Attach    ${t_ue_id}

Not OnAir Workaround
    Reboot TL And Check Configured
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1

SA Attach
    [Arguments]    ${sa_ue_id}
    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
    ...    ue_register
    ...    set_pdu_param
    ...    ue_pdu_session_setup
    SA 5G Attach    ue_id=${sa_ue_id}
    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${sa_ue_id}

Set Reordering Timer
    [Arguments]    ${reordering_window_size}    ${reordering_timer}
    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=1
    ...    reordering_window_size\=${reordering_window_size} reordering_timer\=${reordering_timer}
    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}

Setup XP And Config Resource
    Setup DSS Link
    Reset DL Reservation
    DL Resource cell Reservation    1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001    30   70
    Cell Resource Coordination
    UL Resource cell Reservation    30    70
    CA Cell Allocation    0010000000-0111101000-0011100000-0111100000-0011100000-0111101000-0011100000-0011000000    1,50

Start Multi SA UE Traffic
    [Arguments]    @{sa_ue_list}    ${trf_type}    ${mbps}
    : FOR    ${t_ue_id}    IN    @{sa_ue_list}
    \    Run Keyword If    "${trf_type}"=="dl"    SA Start DL Traffic Internal    ${t_ue_id}    1    ${mbps}
    \    Run Keyword If    "${trf_type}"=="ul"    SA Start UL Traffic Internal    ${t_ue_id}    1    ${mbps}

Start Multi NSA UE Traffic
    [Arguments]    ${sa_ue_list}    ${trf_type}    ${mbps}
    : FOR    ${t_ue_id}    IN    @{sa_ue_list}
    \    Run Keyword If    "${trf_type}"=="dl"    NSA Start DL Traffic    ${t_ue_id}    1    ${mbps}
    \    Run Keyword If    "${trf_type}"=="ul"    NSA Start UL Traffic    ${t_ue_id}    1    ${mbps}

Start SA DL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    : FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
    \    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=175    trf_id=${t_time}
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${last_mbps}    trf_id=${dl_times+1}

Stop SA DL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to stop big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    : FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
    \    SA Stop Data Traffic Internal    ${UE_ID}    trf_id=${t_time}
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    SA Stop Data Traffic Internal    ${UE_ID}    trf_id=${dl_times+1}

Trigger Scell Addition With CoverbaseA1 Rsrp
    [Arguments]    ${ue_id}    ${pcell_id}    ${rsrp}    ${mea_id}=1
    ${cmd_rsrp}    Set Variable
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=A1 srsrp_nr\=${rsrp} phycell_id\=${pcell_id}
    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd_rsrp}    pass_regexp=rrcReconfigurationComplete    timeout=1minutes

Trigger Scell Addition With CoverbaseA1 RsrpCombined
    [Arguments]    ${ue_id}    ${pcell_id}    ${rsrp}    ${mea_id}=1    ${rsrq}=0
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=A1 srsrp_nr\=${rsrp} srsrq_nr\=${rsrq} phycell_id\=${pcell_id}
    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=rrcReconfigurationComplete    timeout=1minutes

Lock Cell
    [Arguments]    ${cell_name}
    Log To Console    Cell ${cell_name} Locked
    Setup Admin
    Block Cell    dist_name=${cell_name}
    Teardown Admin
    sleep    60s    #wait for cell locked

Unlock Cell
    [Arguments]    ${cell_name}
    Log To Console    Cell ${cell_name} Unlocked
    Setup Admin
    UnBlock Cell    dist_name=${cell_name}
    Teardown Admin
    sleep    60s    #wait for cell unlocked

Verify Ue Detached
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_path}
    Should Contain    ${content}    Received NG Reset from GNB-2

Suite Setup Start WTS And Check OnAir With Workaround
     ${KW_status}    ${BTSonair_status}    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
     Run Keyword If    '${KW_status}'=='FAIL'    Not OnAir Workaround

Suite Setup 8015
    [Arguments]    ${swconfig_param}=${empty}    ${iphy_file}=${empty}    ${swconfig_param_AP}=${empty}    ${log}=${True}
    ...    ${force_reboot}=${False}
    Import Testline Variables
    Print Current Time    Start Robot File Time
    Clean Up Env
    Create Suite Directory
    Run Keyword And Ignore Error    Get Qc File
    Get All Testline Information And Set Suite Variable
    Run Keyword If    '${iphy_file}'!='${empty}'    Get RRU Type From Local IPHY XML    ${iphy_file}
    Print Testline Info Ahead Of Report
    Setup Connections
    Set CP Debug Log
    Run Keyword If    "${log}"=="${True}"    common_log_capture.Start Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
    Run Keyword If    '${iphy_file}'!='${empty}'    Modify IPHY File And Send to Airphone    ${iphy_file}
    Run Keyword If    '${swconfig_param}'!='${empty}'    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
    Run Keyword If    '${swconfig_param_AP}'!='${empty}'    Add RD Parameters To Airphone Swconfig File    ${swconfig_param_AP}

Test Setup 8015
    [Arguments]    ${scf_file}=${empty}    ${delta_scf}=${empty}
    Full Commission With SCF File    ${scf_file}
    ${file_state}=    Evaluate    '${scf_file}'!='${empty}'
    Run Keyword If    '${file_state}'=='${TRUE}'
    ...    Reboot TL And Check Configured
    Run Keyword If    '${file_state}'=='${TRUE}'
    ...    Check Cell Status And Reboot If Need
    Delta Commission    delta_scf=${delta_scf}
    Suite Setup Start WTS And Check OnAir With Workaround
    Common Test Setup

Test Teardown 8015
    Common Test Teardown
	common_log_capture.Teardown All Connections
    ute_wtssim.Teardown All Aliases For Wts
