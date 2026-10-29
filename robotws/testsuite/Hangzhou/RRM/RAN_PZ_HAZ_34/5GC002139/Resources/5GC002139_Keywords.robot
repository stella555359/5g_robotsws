*** Settings ***
Resource     ../../5GC000920/Resources/5GC000920_Keywords.robot
Resource     ./5GC002139_Variables.robot
Library     ./event_trace_log_analysis.py
#Library      event_trace_log_analysis.Event_trace_alaysis_2139    WITH NAME    event_trace_py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_average_throughput.py
Variables    ../TestData/5GC002139_scf_modify.py
Variables    ../TestData/swconfig_modify.py

Documentation
...   author: Wang Yixiang
...   contact: yixiang.x.wang@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature 5GC002139 in 5G19A program


*** Keywords ***
Capture logs and verify numOfLayers MCS
    [Documentation]    Author: Wang Yixiang
    ...                Description: Capturing logs and do verifications
    Connect to Capacity Unit Master case
    Start TTI trace log capturing case
    Sleep    5s
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
    #set suite variable       ${dict_csv_file_path}
    Run keyword and continue on failure      Check_numOfLayers_single_ue     file_path=${dict_csv_file_path['DL']}
    
    Run keyword and continue on failure      Check_fixed_mcs_single_ue      file_path=${dict_csv_file_path['DL']}
    set suite variable       ${dict_csv_file_path['DL']}

    [Teardown]  Run keyword and ignore error   Stop TTI trace log capturing

Collect BIP messages and verify rdPdcchPrecodingOption4x4 message
    [Documentation]    Author: Wang Yixiang
    ...    If rdPdcchPrecodingOption4X4=0, DlData_PdcchSendReq.dciInfo_item_7.PdcchOLPrecodingOption4X4 value should be 0;
    ...    If rdPdcchPrecodingOption4X4=1, DlData_PdcchSendReq.dciInfo_item_7.PdcchOLPrecodingOption4X4 value should be 1;
    ...    If rdPdcchPrecodingOption4X4=2, DlData_PdcchSendReq.dciInfo_item_7.PdcchOLPrecodingOption4X4 value should be 0;
    [Timeout]    15 min
    [Arguments]    ${PdcchOLPrecodingOption4X4}
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts with retry
    sleep    10 sec
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ${dldata_pdcchPrecoding_filter}   set variable    DlData_DciInfo.pdcchPrecodingOption4x4 == 0x0${PdcchOLPrecodingOption4X4}
    Verify specific tcpdump messages frame number should exist    file_path=${list_log_path_local[0]}
    ...    display_filter=${dldata_pdcchPrecoding_filter}    lua_script=${LUA_SCRIPT_PATH}


L3 Call with Commercial UE and record throughput info
    [Documentation]  Description:
    ...              ${duration_time}: is the duration time for calculating average tput in one capturing
    ...              ${total_time}: is the duration time in which the throughput need to be checked. The time unit is second.
    ...              ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...              ${iperf_type}  can be via_app or via_command, via_command first should install iperf3 in /data/local/tmp/iperf3
    [Arguments]    ${duration_time}    ${interval_time}    ${total_time}    ${ul_exp_tput}=${UL_EXPECT}    ${ue_type}=${UE_TYPE}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${tput_percentage}=${EXP_TPUT_PERCENTAGE}    ${retry_time}=3    ${iperf_ul}=${None}    ${iperf_dl}=${None}
    ...    ${ul_buffer_size}=1400    ${dl_buffer_size}=1400    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...    ${ul_throughput}=${UL_THROUGHPUT}    ${dl_throughput}=${DL_THROUGHPUT}
    ...    ${is_need_to_capture_log}=${True}
    ...    ${data_transfer_direction}=both    ${prepare_ue_needed}=${True}    ${4G_check}=True
    ...    ${iperf_type}=via_app
    Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}
    ...                                     prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}
    ${traffic_time}    Evaluate    ${total_time}*10

    ${iperf_ul}    Set variable if    '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_ul}    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if      '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_dl}    ${tl.ues[${ue_index}].iperf_details.port}

    run keyword if  not '${data_transfer_direction}'=='dl'    Wait until keyword succeeds    5X    3 s    power_ue.Start traffic
    ...    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    iperf_type=${iperf_type}
    ...   duration=${traffic_time}    buffer_size=${ul_buffer_size}    iperf_port=${iperf_ul}    ue_alias=${ue_alias}    dt_name=dt_ul
    run keyword if  not '${data_transfer_direction}'=='ul'    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${traffic_time}    buffer_size=${dl_buffer_size}
    ...    iperf_port=${iperf_dl}    ue_alias=${ue_alias}    dt_name=dt_dl    iperf_type=${iperf_type}
    sleep   10s
    ${NRCELLIDENTITY}    Get nrCellIdentity for specific cell    cell_id=1
    Set test variable    ${NRCELLIDENTITY}
    Verify tput from GNB within duration and record data to csv    total_time=${total_time}    exp_dl_tput=${dl_exp_tput}
    ...    exp_ul_tput=${ul_exp_tput}    interval=${interval_time}    duration_time_for_once=${duration_time}
    ...    exp_min_ul=0     tput_percentage=${tput_percentage}    is_need_to_capture_log=${is_need_to_capture_log}
