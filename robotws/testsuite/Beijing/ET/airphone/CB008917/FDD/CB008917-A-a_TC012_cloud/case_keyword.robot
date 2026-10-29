*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh

*** Variables ***
${CMD_OPEN_CP_DEBUG}    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
${BIP_NAME}             5GBipL2L1_filtering_off
${BIP_NAME_COVERT}      5GBipL2L1_filtering_off_filter

*** Keywords ***
Start And Stop Tti Trace
    Start Ttitrace With Streaming Mode
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/

Convert Tti To Csv Mode
    Format Tti In Stream Mode        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/output_dl.csv
    ...    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/output_dl_formated.csv
    Format Tti In Stream Mode        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/output_ul.csv
    ...    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/output_ul_formated.csv

Set CP Debug
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${CMD_OPEN_CP_DEBUG}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

MultiUE Attach And Do Traffic With NSA
    [Arguments]    ${max_ue_num}    ${dl_traffic}=1    ${ul_traffic}=1    ${profile_id}=1    ${gnb_id}=2    ${cell_id}=1
    ...    ${bearer_id}=2
    : FOR    ${ue_id}    IN RANGE    101    ${max_ue_num}+101
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    Sleep    1s
    \    NSA Start DL Traffic    ${ue_id}    ${bearer_id}    ${dl_traffic}    1
    \    NSA Start UL Traffic    ${ue_id}    ${bearer_id}    ${ul_traffic}    1
    \    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    \    Sleep    1s
    \    NSA Verify If Attach Passed

MultiUE Attach And Do Small Traffic With NSA
    [Arguments]    ${max_ue_num}    ${dl_traffic}=1    ${ul_traffic}=1    ${profile_id}=1    ${gnb_id}=2    ${cell_id}=1
    ...    ${bearer_id}=2
    : FOR    ${ue_id}    IN RANGE    101    ${max_ue_num}+101
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    Sleep    1s
    \    NSA Start DL Small Traffic    ${ue_id}    ${bearer_id}    ${dl_traffic}    1
    \    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    \    Sleep    1s
    \    NSA Verify If Attach Passed

MultiUE Attach And Do Traffic With NSA Check Tput
    [Arguments]    ${max_ue_num}    ${dl_traffic}=1    ${ul_traffic}=1    ${profile_id}=1    ${gnb_id}=2    ${cell_id}=1
    ...    ${bearer_id}=2
    : FOR    ${ue_id}    IN RANGE    101    ${max_ue_num}+101
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    \    NSA Verify If Attach Passed
    \    NSA Start UL Traffic    ${ue_id}    ${bearer_id}    ${ul_traffic}
    \    NSA Start DL Traffic    ${ue_id}    ${bearer_id}    ${dl_traffic}
    \    Sleep    5s    reason=Wait For UL Transmission
    \    NSA Get UE Average Traffic    ${ue_id}    ${bearer_id}    dl
    \    NSA Get UE Average Traffic    ${ue_id}    ${bearer_id}    ul

SomeUE Attach And Do Traffic With NSA
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${dl_traffic}=5    ${ul_traffic}=1    ${profile_id}=1
    ...    ${gnb_id}=2
    ...    ${cell_id}=1    ${bearer_id}=2
    : FOR    ${ue_id}    IN RANGE    ${start_ue_num}+101    ${stop_ue_num}+101
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    Sleep    1s
    \    NSA Start DL Small Traffic    ${ue_id}    ${bearer_id}    1    1
    \    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    \    Sleep    1s
    \    NSA Verify If Attach Passed

NSA UE Detach
    [Arguments]    ${start_ue_num}    ${stop_ue_num}
    : FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
    \    Log To Console    ===============UE${ue_id} Dettached:==============
    \    NSA LTE Detach    ${ue_id}

Download LUA And Convert BIP And Check A2A
    [Arguments]    ${A2A_path}    ${index}=0
    Download And Unzip Lua File    ${sw_version_total}
    ${covert_cmd}    Catenate    tshark -X lua_script:${output_dir}/generated_luashark/luashark.lua -r
    ...    ${output_dir}/${BIP_NAME}.pcap${index} -V > ${output_dir}/${BIP_NAME}${index}.txt
    Process.Run Process    ${covert_cmd}    shell=True
    Wireshark Filter Msg    ${output_dir}/${BIP_NAME}${index}.txt
    ...    ${output_dir}/${BIP_NAME_COVERT}${index}.txt    PdschSendReq|PuschReceiveReq|PdcchSendReq
    Set Test Variable    ${index}    ${index}
    Check Log With Au2anlysis    ${CURDIR}${/}${A2A_path}${/}a2a.ini    w    save_log_directory=${output_dir}

NSA NR UE Param Set
    [Arguments]    ${ue_id}    ${ue_nr_cap}
    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ue_nr_cap | Yes | ue_nr_cap |
    ...    Example:
    ...    | NSA NR UE Param Set | 1 | 01000000010800040004D100018000000BC00000000000008A8000100000000010010AAC |
    Log To Console    set UE NR capability...
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap}
    Log To Console    set_UE_NR_capability_is_ok
    Sleep    3s    reason=wait ue set nr capability is stable

NSA NR And Eutra UE Param Set
    [Arguments]    ${ue_id}    ${ue_nr_cap}    ${ue_eutra_nr_cap}
    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ue_nr_cap | Yes | ue_nr_cap |
    ...    | ue_eutra_nr_cap | Yes | ue_eutra_nr_cap |
    ...    Example:
    ...    | NSA NR And Eutra UE Param Set | 1 | 123 | 456 |
    Log To Console    set UE NR and eutra capability...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap} dual_conn=eutra_nr
#    ...    ue_eutra_nr_capabilities\=${ue_eutra_nr_cap}

    ${cmd_1}  Set Variable  cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap} dual_conn=eutra_nr
    ${cmd_2}  Set Variable  ue_eutra_nr_capabilities\=${ue_eutra_nr_cap}
    ute_wtssim.Execute Egate Command    ${cmd_1} ${cmd_2}

    Log To Console    set_UE_NR_and_eutra_capability_is_ok
    Sleep    3s    reason=wait ue set nr capability is stable

SA NR UE Param Set
    [Arguments]    ${ue_id}    ${ue_nr_cap}
    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ue_nr_cap | Yes | ue_nr_cap |
    ...    Example:
    ...    | SA NR UE Param Set | 1 | 01000000010800040004D100018000000BC00000000000008A8000100000000010010AAC |
    Log To Console    set UE NRcapability...
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap}
    Log To Console    set_UE_NRcapability_is_ok
    Sleep    3s    reason=wait ue set nr capability is stable


Get SA UL Tput And Make Sure Larger Than 0
    ${ul_avg_sa} =    SA Get UE Average Traffic    dir=ul
    Should Be True    ${ul_avg_sa}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue

Get SA DL Tput And Make Sure Larger Than 0
    ${dl_avg_sa} =    SA Get UE Average Traffic    dir=dl
    Should Be True    ${dl_avg_sa}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue

SA Stop DL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Stop DL Traffic EGate| 1 | 2 |
    Log To Console    stop DL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=dl trf_id\=${trf_id}

SA Stop UL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Stop UL Traffic EGate| 1 | 2 |
    Log To Console    stop UL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=ul trf_id\=${trf_id}
Modify DL MIMO Mode
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${dlmimomode}=4x4 or 4x2 Open Loop Spatial Multiplexing    ${connection}=GNB_OAM
    ${nrcell_list}    Get Cell ID list via Admin CLI    connection=${connection}
    ${modify_param}    Create List
    FOR    ${nrcell}    IN    @{nrcell_list}
        &{dlmimomode_param}  Create Dictionary    dist_name=NRBTS-${nr_bts_id}/${nrcell}    parameter=dlMimoMode
        ...    value=${dlmimomode}
        Append To List    ${modify_param}    ${dlmimomode_param}
    END
    [Return]    @{modify_param}

Update MIMO Mode And Wait On Air
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${bandwidth}=100MHz    ${slotRatio}=1/4    ${nrcelltype}=4DL2UL    ${actTddPrePooling}=false
    ...            ${dlmimomode}=4x4 or 4x2 Open Loop Spatial Multiplexing
    ${gscn_value}    Run keyword If  "${bandwidth}" =="20MHz"    Get GSCN Value  ELSE    set variable    none
    ${chbw_param}    Modify All Chbw Para    bandwidth=${bandwidth}    gscn=${gscn_value}
    ${slot_ratio_param}    Modify Slot Ratio Para    slotRatio=${slotRatio}
    ${nr_cell_param}    Modify NR Cell Type    nrcelltype=${nrcelltype}    actTddPrePooling=${actTddPrePooling}
    ${mimo_mode}    Modify DL MIMO Mode    dlmimomode=${dlmimomode}
    ${modify_param_list}    combine lists    ${chbw_param}    ${slot_ratio_param}    ${nr_cell_param}    ${mimo_mode}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_list}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Modify All Chbw Para
    [Documentation]  Author: xiaoxia.hao
    ...                Descrition：get cell number from site
    ...                modify_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Default to all: all cells on GNB will be updated
    ...               it only support modify NSA CHBW
    [Arguments]   ${bandwidth}=100MHz
    ...            ${shutdown_value}=none
    ...            ${gscn}=none
    ...            ${connection}=GNB_OAM
    ...            ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...            ${PDCCH_CONFIG_DEDICATED}=PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...            ${modify_cell_ids}=all
    ...            ${gnb_index}=0
    ...            ${prachRootSequenceIndex}=none
    &{shutdown_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}   parameter=shutdownNogNBCellTmr
    ...    value=${shutdown_value}
    @{modify_param}    Create List
    Run Keyword Unless    "${shutdown_value}"=="none"    Append To List    ${modify_param}    ${shutdown_param}
    ${gnb_nr_cell_id_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ...    connection_alias=${connection}
    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
    ${is_all_cellls_entered}    Run keyword and return status    Should contain    ${modify_cell_ids}    all
    ${modify_cell_ids}    Set variable if    ${is_all_cellls_entered}    ${all_cell_ids}    ${modify_cell_ids}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    FOR    ${cell_index}    IN    @{modify_cell_ids}
        &{bandwidth_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}    parameter=chBw
        ...    value=${bandwidth}
        Append To List    ${modify_param}    ${bandwidth_param}
        ${gscn_value}    coam_parameter.get_single_value_from_scf_file    parameter=gscn
        ...    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
        ...                                                               connection=${connection}
        ${gscn_value_length}    Get Length    ${gscn_value}
        ${gscn_param_name}    set variable if    "${gscn_value_length}"=="0"     gscnOrSsPbchArfcn    gscn
        &{gscn_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
        ...    parameter=${gscn_param_name}    value=${gscn}
        Run Keyword Unless    "${gscn}"=="none"    Append To List    ${modify_param}    ${gscn_param}
        &{prachRootSequenceIndex_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
        ...    parameter=prachRootSequenceIndex    value=${prachRootSequenceIndex}
        Run Keyword Unless    "${prachRootSequenceIndex}"=="none"    Append To List    ${modify_param}
        ...    ${prachRootSequenceIndex_param}
    END
    ${PDCCH_CONFIG_DEDICATED_params}    Modify 2197 parameter based on chbw for cells
    ...    modify_cell_ids=${modify_cell_ids}
    ...    connection=${connection}        gnb_index=${gnb_index}    bandwidth=${bandwidth}
    ${modify_param}    combine lists    ${modify_param}    ${PDCCH_CONFIG_DEDICATED_params}
    [Return]    @{modify_param}

Verify BTS Restart
    [Documentation]   Author:xiangyue.zhou@nokia-sbell.com
    ...              Description: This keyword for verify cluster restart function take action
    ${status} =    Run Keyword And Return Status    coam_gnb_classical.Connect to gnb coam via ssl
    Should Be Equal    ${status}    ${False}
