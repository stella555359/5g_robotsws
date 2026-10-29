*** Settings ***
Documentation
...   This is for 1200 log capture and analysis keywords with Viavi UE
...   squad group: mmW_SG1

Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Variables   ../TestData/1200_cplane_msg_checkpoints.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Library     taf.rfrl.common_resources.python.stream_manager    WITH NAME    stream_manager
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot


*** Keywords ***
Start tcpdump trace capturing
    [Documentation]    Author: Cui Lingxue
    ...    Description: this keyword is to start tcpdump process on specified connection.
    [Arguments]      ${log_prefix}    ${log_dir}=/tmp    ${connection_alias}=ASIK Master    ${interface}=any
    ${trace_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${log_name}    Set variable    ${log_prefix}_${trace_timestamp}.pcap
    ${log_full_path}    join path    ${log_dir}    ${log_name}
    ${tcpdump_command}    Set variable    setsid tcpdump -i ${interface} -s 0 -w ${log_full_path}
    ${connection}    csn.get_connection_by_alias    alias=${connection_alias}
    ${channel}    call method    ${connection}    invoke_shell
    call method    ${channel}    settimeout    ${10}
    call method    ${channel}    send    ${tcpdump_command}\n
    call method    ${channel}    recv    ${65535}
    call method    ${channel}    close
    Trace capturing process should be triggered    log_prefix=${log_prefix}    connection_alias=${connection_alias}
    ...    check_times=10    sleep_interval=1 sec
    [Return]    ${log_full_path}

Start L2PS trace capturing
    [Documentation]    Author: Cui Lingxue
    ...    itf_l2_ps_ctrl_UlRadioLinkStatusInd location differ from each stream, need to capture on specific board for different stream.
    ...    ${HW_SLOT} is set as suite variable in suite setup phase.
    ...    ${L2PS_CONNECTION} will be set as suite variable in this keyword.
    [Arguments]      ${log_prefix}    ${log_dir}=/tmp    ${interface}=any    ${hw_slot}=${HW_SLOT}
    Connect to Common Unit Master
    Connect to Capacity Unit Master    hw_slot=${hw_slot}
    ${base_band_type}    connection_alias_store.Get hardware type    alias=ABIL Master
    ${is_feature_1514_enabled}    stream_manager.feature_1514_opened    connection=ASIK Master
    ${connection_alias}    Set variable if     ${is_feature_1514_enabled} and '${base_band_type}'!='ABIO'    ABIL Slave    ABIL Master
    set suite variable    ${L2PS_CONNECTION}    ${connection_alias}
    Run keyword if    ${is_feature_1514_enabled} and '${base_band_type}'!='ABIO'
    ...    connection_alias_store.Connect to Capacity Unit Slave    hw_slot=${hw_slot}

    ${log_full_path}    Wait until keyword succeeds    10min    3 s    Start tcpdump trace capturing     log_prefix=${log_prefix}
    ...    log_dir=${log_dir}    interface=${interface}    connection_alias=${connection_alias}
    [Return]    ${log_full_path}



Verify rlResumeBackOffTmr in UPUE trace
    [Documentation]    Author: Cui Lingxue
    ...    Description: analyze l2ps trace, get timestamp of msg RrcReconfComplete and msg RL_Resume, calculate their timegap, and compare
    ...        with configured rlResumeBackoff timer value.
    ...    [added by Lingxue 2021-02-22]: if base band hardware type is ABIO, will not be able to capture itf_l2_ps_ctrl_UlRadioLinkStatusInd on
    ...    base band board, use itf_l2_hi_cu_user_BearerUlDataSplitModeInd instead.
    ...    :param file_path: the path of captured l2ps trace
    ...    :param rlResumeBackOffTmr: configured value for rlResumeBackOffTmr
    ...    :param error: allowed error range
    [Arguments]    ${file_path}    ${rlResumeBackOffTmr}    ${error}=0.1    ${lua_script}=${LUA_SCRIPT_PATH}    ${hw_slot}=${HW_SLOT}
    Connect to Common Unit Master
    Connect to Capacity Unit Master    hw_slot=${HW_SLOT}
    ${base_band_type}    Get hardware type    alias=ABIL Master

    ${pdml_template}    set variable    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y \"icom_5g\" -T pdml > {output_file}
    ${rlResumeBackOffTmr} =    evaluate    ${rlResumeBackOffTmr}/1000
    ${pdml_list}    pcap.load_pcap_file    pcap_file=${file_path}    luashark_path=${lua_script}    command_template=${pdml_template}

    ${filter_UlRadioLinkStatusInd_resume}    set variable if    '${base_band_type}'=='ABIO'
    ...    itf_l2_hi_cu_user_BearerUlDataSplitModeInd.BearerUlDataSplitModeInd.ulRlStatus == 2
    ...    itf_l2_ps_ctrl_UlRadioLinkStatusInd.UlRadioLinkStatusInd.ueUlRlStatus == 0x02
    ${filter_UlRadioLinkStatusInd_rlo}    set variable if    '${base_band_type}'=='ABIO'
    ...    itf_l2_hi_cu_user_BearerUlDataSplitModeInd.BearerUlDataSplitModeInd.ulRlStatus == 1
    ...    itf_l2_ps_ctrl_UlRadioLinkStatusInd.UlRadioLinkStatusInd.ueUlRlStatus == 0x01

    ${pkt_lst_rrcreconfcompletedreq}    pcap.filter_packets_by_expression
    ...    filter_expression=itf_l2_ps_user_rrcreconfcompletedreq
    ${pkt_lst_UlRadioLinkStatusInd_rlo}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter_UlRadioLinkStatusInd_rlo}
    ${pkt_lst_UlRadioLinkStatusInd_resume}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter_UlRadioLinkStatusInd_resume}

    ${rlo_rrcReconfComp_timestamp}    pcap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show
    ${rlo_ind_timestamp}    pcap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show
    ${rl_resume_ind_timestamp}    pcap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show

    #compare timestamp, if first resume time < rlo time, delete the first resume timestamp, ensure first is rlo, then resume
    ${status}   run keyword and return status   should be true    ${rl_resume_ind_timestamp[0]}<${rlo_rrcReconfComp_timestamp[0]}
    run keyword if   ${status}==${True}   Remove From List    ${rl_resume_ind_timestamp}    0

    ${timegap}    evaluate    float(${rl_resume_ind_timestamp[0]})-float(${rlo_rrcReconfComp_timestamp[0]})+${error}
    should be true    ${timegap}>${rlResumeBackOffTmr}
