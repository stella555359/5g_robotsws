*** Settings ***
Documentation    This is for L3call related common keywords.
...              Please do not modify the file without notification to author
...              Author: Zhou Xiangyue
...              Squard: HZ SG6
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot

*** Keywords ***
Verify L3 Call With Power Ue
    [Documentation]   Auther: xiangyue.zhou@nokia-sbell.com
    ...           Descrition: check CA or non-CA L3 call,only can be used by 1cc/2cc env.
    ...           :param ul_data_transfer <int or float>:the data use when start ul data transfer
    ...           :param dl_data_transfer <int or float>:the data use when start dl data transfer
    ...           :param expect_ul_tput <int or float>:expect ul tput whatever CA or non-CA call
    ...           :param expect_dl_tput <int or float>: expect dl tput,just used by non-CA call
    ...           :param expect_dl_tput_on_pcell <int or float>:expect tput on pcell,just used by CA call on pcell
    ...           :param expect_dl_tput_on_scell <int or float>:expect tput on scell,just used by CA call on scell
    ...           :param expect_dl_bler <float>: ${expect_dl_bler}=0.1,used whatever CA or non-CA call
    ...           :param duration <int>:check traffic time,default is second,used whatever CA or non-CA call
    ...           :param is_CA_cell_call<boolean>:if CA call running,then value is True, else is False
    ...           :param pcell_id is used whatever CA or non-CA call,if non-CA call, pcell id is default cell id.
    ...           :param scell_id is only used CA call.
    [Arguments]     ${ul_data_transfer}=70
    ...             ${dl_data_transfer}=2500
    ...             ${expect_ul_tput}=60
    ...             ${expect_dl_tput}=2500
    ...             ${expect_dl_tput_on_pcell}=1200
    ...             ${expect_dl_tput_on_scell}=0
    ...             ${expect_dl_bler}=0.1
    ...             ${expect_ul_bler}=0.1
    ...             ${duration}=240
    ...             ${is_CA_cell_call}=${True}
    ...             ${reset_sol}=none
    ...             ${ue_index}=${0}
    ...             ${4G_check}=False
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ...             ${is_wireshark_log_capture}=${True}
    ...             ${wireshark_log_prefix}=x2_log_attach
    ...             ${iperf_type}=via_app
    ...             ${is_askey_used}=False
    ...             ${buffer_size}=${DATA_LENGTH}
    ...             ${cap_index}=${0}
    ...             ${ul_dt_name}=dt_ul
    ...             ${dl_dt_name}=dt_dl
    ...             ${apn_address}=wap1nokiacom
    ...             ${pcell_index}=0
    ...             ${scell_index}=1
    ...             ${sleep_interval}=10 sec
    ...             ${is_do_require_ue}=${True}
    ...             ${dl_process_num}=2
    log     ${buffer_size}
    log     ${wireshark_log_prefix}
    ${duration}    Convert To Integer    ${duration}
    ${expect_ul_tput}    Convert To Number    ${expect_ul_tput}
    ${expect_dl_tput}    Convert To Number    ${expect_dl_tput}
    ${expect_dl_tput_on_pcell}    Convert To Number    ${expect_dl_tput_on_pcell}
    ${expect_dl_tput_on_scell}    Convert To Number    ${expect_dl_tput_on_scell}
    ${wireshark_log_path_on_testPC}    Start UE Attach With Power UE    reset_sol=${reset_sol}
    ...                                ue_index=${ue_index}
    ...                                4G_check=${4G_check}
    ...                                is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                is_askey_used=${is_askey_used}
    ...                                sleep_interval=${sleep_interval}
    ...                                is_do_require_ue=${is_do_require_ue}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    Start L3 Call With Power UE       ul_data_transfer=${ul_data_transfer}
    ...                               dl_data_transfer=${dl_data_transfer}
    ...                               ue_index=${ue_index}
    ...                               iperf_type=${iperf_type}
    ...                               buffer_size=${DATA_LENGTH}
    ...                               cap_index=${cap_index}
    ...                               ul_dt_name=${ul_dt_name}
    ...                               dl_dt_name=${dl_dt_name}
    ...                               apn_address=${apn_address}
    ...                               dl_process_num=${dl_process_num}
    sleep    30s    reason=Wait for Traffic To Startup
    Run Keyword If    '${is_CA_cell_call}' == 'True'    Verify Throughput For CA Cell
    ...                                 expect_dl_tput_on_pcell=${expect_dl_tput_on_pcell}
    ...                                 expect_dl_tput_on_scell=${expect_dl_tput_on_scell}
    ...                                 expect_ul_tput=${expect_ul_tput}
    ...                                 expect_dl_bler=${expect_dl_bler}
    ...                                 expect_ul_bler=${expect_ul_bler}
    ...                                 duration=${duration}
    ...                                 connection=${connection}
    ...                                 gnb_index=${gnb_index}
    ...                                 pcell_index=${pcell_index}
    ...                                 scell_index=${scell_index}
    ...                                 actCarrierAggregation=${True}
    ...       ELSE          Verify Throughput For non-CA Cell
    ...                                 expect_dl_tput=${expect_dl_tput}
    ...                                 expect_ul_tput=${expect_ul_tput}
    ...                                 expect_ul_bler=${expect_ul_bler}
    ...                                 expect_dl_bler=${expect_dl_bler}
    ...                                 duration=${duration}
    ...                                 connection=${connection}
    ...                                 gnb_index=${gnb_index}
    ...                                 cell_index=${pcell_index}
    ...                                 actCarrierAggregation=${False}
    [Return]     ${wireshark_log_path_on_testPC}
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${ue_index}    iperf_type=${iperf_type}

Verify Throughput For CA Cell
    [Documentation]    Auther:xiangyue.zhou@nokia-sbell.com
    ...                Descrition: check CA L3 call,only can be used by 2cc env.
    ...                verify throughput for CA env ,DL(pcell&scell) UL(pcell)
    [Arguments]    ${expect_dl_tput_on_pcell}=1200
    ...            ${expect_dl_tput_on_scell}=1200
    ...            ${expect_ul_tput}=60
    ...            ${expect_dl_bler}=0.1
    ...            ${expect_ul_bler}=0.1
    ...            ${duration}=240
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${pcell_index}=0
    ...            ${scell_index}=1
    ...            ${actCarrierAggregation}=${True}
    ${direction_component_list}    Create List    DL_CELL_${pcell_index}    DL_CELL_${scell_index}    UL_CELL_${pcell_index}
    ${tput_log}     ${cell_mapping}   Get Tput Data And Cell Mapping     duration=${duration}
    ...                                                                  connection=${connection}
    ...                                                                  gnb_index=${gnb_index}
    ${nrCellIdentity_list}    Get NRCellidentity List    cell_mapping=${cell_mapping}
    FOR    ${item}    IN    @{direction_component_list}
        ${direction}    Set Variable    ${item.split('_')}[0]
        ${cell_index}    Set Variable    ${item.split('_')}[-1]
        ${expect_tput}    Run Keyword If     '${direction}'=='DL' and '${cell_index}'=='${pcell_index}'
        ...               Set Variable        ${expect_dl_tput_on_pcell}
        ...               ELSE IF            '${direction}'=='DL' and '${cell_index}'=='${scell_index}'
        ...               Set Variable        ${expect_dl_tput_on_scell}
        ...               ELSE                Set Variable    ${expect_ul_tput}
        ${expect_bler}    Set Variable If    '${direction}'=='DL'     ${expect_dl_bler}
        ...                                  '${direction}'=='UL'     ${expect_ul_bler}
        ${target_avg_percent}    Evaluate    float(1-${expect_bler})
        ${cells}    Create List     ${nrCellIdentity_list[${cell_index}]}
        Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
        ...                                                           log=${tput_log}    cells=${cells}
        ...                                                           target_throughput=${expect_tput}
        ...                                                           target_avg_percent=${target_avg_percent}
        ...                                                           actCarrierAggregation=${actCarrierAggregation}
    END

Verify Throughput For non-CA Cell
    [Documentation]    Auther:xiangyue.zhou@nokia-sbell.com
    ...                Descrition: check CA or non-CA L3 call,only can be used by 1cc env.
    ...                verify throughput for non-CA env ,DL(cell_index) UL(cell_index)
    [Arguments]     ${expect_ul_tput}=60
    ...             ${expect_dl_tput}=1200
    ...             ${duration}=240
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ...             ${cell_index}=0
    ...             ${expect_ul_bler}=0.1
    ...             ${expect_dl_bler}=0.1
    ...             ${actCarrierAggregation}=${False}
    ${direction_component_list}    Create List    DL_CELL_${cell_index}    UL_CELL_${cell_index}
    ${nrCellIdentity_list}    Get NRCellidentity List    cell_mapping=${cell_mapping}
    ${tput_log}     ${cell_mapping}   Get Tput Data And Cell Mapping     duration=${duration}
    ...                                                                  connection=${connection}
    ...                                                                  gnb_index=${gnb_index}
    FOR    ${item}    IN    @{direction_component_list}
       ${direction}    Set Variable    ${item.split('_')}[0]
       ${expect_tput}    Set Variable If    '${direction}'=='UL'     ${expect_ul_tput}
       ...                                  '${direction}'=='DL'     ${expect_dl_tput}
       ${expect_bler}    Set Variable If    '${direction}'=='UL'     ${expect_ul_bler}
       ...                                  '${direction}'=='DL'     ${expect_dl_bler}
       ${target_avg_percent}    Evaluate    float(1-${expect_bler})
       ${cells}    Create List     ${nrCellIdentity_list[${cell_index}]}
        Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
        ...                                                           log=${tput_log}    cells=${cells}
        ...                                                           target_throughput=${expect_tput}
        ...                                                           target_avg_percent=${target_avg_percent}
        ...                                                           actCarrierAggregation=${actCarrierAggregation}
    END

Get NRCellidentity List
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${cell_mapping}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${nrCellIdentity_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
    END
    [Return]    ${nrCellIdentity_list}

Get Tput Data And Cell Mapping
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                Modified by xiangyue.zhou@nokia-sbell.com for adjust power_ue.Collect Tput
    [Arguments]    ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${ignore_time}=10sec
    ...            ${duration}=240
    ...            ${type}=MCU
    log     ${type}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=${duration}    ignore_time=${ignore_time}
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    [Return]    ${tput_log}     ${cell_mapping}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


#------ Stella 2021-06-07 : New Version to Support Check Multi Cell Call ------#
Verify L3 Call Process
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    ...                Description: Verify L3 call process. it supports normal single and multi cell call , CA call.
    ...                :param ${cell_tput_check_info_dict}:tput check related parameterd, format as below
    ...                {'UL':{'cell_index':'0','expect_UL_tput':'50','expect_UL_bler':'0.03'}.
    ...                 'DL_PCELL':{'cell_index':'0','expect_DL_tput':'50','expect_DL_bler':'0.03'},
    ...                 'DL_SCELL_1':{'cell_index':'1','expect_DL_tput':'','expect_DL_bler':''}}
    [Arguments]     ${cell_tput_check_info_dict}
    ...             ${ul_data_transfer}=70
    ...             ${dl_data_transfer}=2500
    ...             ${duration}=240
    ...             ${download_dir}=${TS_CASE_LOG_PATH}
    ...             ${reset_sol}=none
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${asik_alais}=ASIK Master
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ...             ${is_wireshark_log_capture}=${False}
    ...             ${is_askey_used}=False
    ...             ${buffer_size}=${DATA_LENGTH}
    ...             ${cap_index}=${0}
    ...             ${apn_address}=wap1nokiacom
    ...             ${need_get_ue_ip}=${False}
    ...             ${cpif_log_path}=${None}
    ...             ${is_multi_pdu}=${False}
    ...             ${mode}=SA
    ...             ${dl_process_num}=2
    log   ${buffer_size}
    ${wireshark_log_path_on_testPC}    Start UE Attach With Power UE    reset_sol=${reset_sol}
    ...                              ue_index=${ue_index}
    ...                              4G_check=${4G_check}
    ...                              is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                              is_askey_used=${is_askey_used}
    Start L3 Call Data Transfer       ul_data_transfer=${ul_data_transfer}
    ...                               dl_data_transfer=${dl_data_transfer}
    ...                               duration=${duration}
    ...                               ue_index=${ue_index}
    ...                               buffer_size=${DATA_LENGTH}
    ...                               cap_index=${cap_index}
    ...                               apn_address=${apn_address}
    ...                               is_multi_pdu=${is_multi_pdu}
    ...                               cpif_log_path=${cpif_log_path}
    ...                               need_get_ue_ip=${need_get_ue_ip}
    ...                               mode=${mode}
    ...                               dl_process_num=${dl_process_num}
    sleep    30s    reason=Wait for Traffic To Startup
    Check L3 Call Tput    cell_tput_check_info_dict=${cell_tput_check_info_dict}
    ...                   duration=${duration}
    ...                   download_dir=${download_dir}
    ...                   asik_alais=${asik_alais}
    ...                   connection=${connection}
    ...                   gnb_index=${gnb_index}
    [Return]     ${wireshark_log_path_on_testPC}
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${ue_index}    iperf_type=${iperf_type}

Check L3 Call Tput
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    ...                Description: Verify Tput for UL/DL Cell, it supports normal single and multi cell call , CA call.
    ...                :param ${cell_tput_check_info_dict}:tput check related parameterd, format as below
    ...                {'UL':{'cell_index':'0','expect_UL_tput':'50','expect_UL_bler':'0.03'}.
    ...                 'DL_PCELL':{'cell_index':'0','expect_DL_tput':'50','expect_DL_bler':'0.03'},
    ...                 'DL_SCELL_1':{'cell_index':'1','expect_DL_tput':'','expect_DL_bler':''}}
    ...                :param ${duration}:duration to capture tput file.
    [Arguments]     ${cell_tput_check_info_dict}
    ...             ${duration}=120
    ...             ${download_dir}=${TS_CASE_LOG_PATH}
    ...             ${asik_alais}=ASIK Master
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ${duration}    Convert To Integer    ${duration}
    ${download_tput_file_dict}    Save Tput Result    connection=${connection}
    ...                                               gnb_index=${gnb_index}
    ...                                               asik_alais=${asik_alais}
    ...                                               duration=${duration}
    ...                                               download_dir=${download_dir}
    ${nrCellIdentity_list}   Get NR Cell Identity    connection=${connection}    gnb_index=${gnb_index}
    ${direction_list}    Get Dictionary Keys    ${cell_tput_check_info_dict}
    FOR  ${direction}  IN  @{direction_list}
      ${cell_index}    Set Variable    ${cell_tput_check_info_dict['${direction}']['cell_index']}
      ${data_direction}    Set Variable    ${direction.split('_')[0]}
      ${expect_tput}    set variable    ${cell_tput_check_info_dict['${direction}']['expect_${data_direction}_tput']}
      ${expect_bler}    set variable    ${cell_tput_check_info_dict['${direction}']['expect_${data_direction}_bler']}
      Run Keyword And Continue On Failure    Check Tput With Single Direction
      ...                                    direction=${data_direction}
      ...                                    nrCellIdentity_list=${nrCellIdentity_list}
      ...                                    tput_file_dict=${download_tput_file_dict}
      ...                                    cell_index=${cell_index}
      ...                                    expect_tput=${expect_tput}
      ...                                    expect_bler=${expect_bler}
    END

Check Tput With Single Direction
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...                :param ${direction}: single direction, value can be UL or DL
    ...                :param ${nrCellIdentity_list}:nrCellIdentity list get from kw
    ...                                              <get_relation_mapping_between_cell_index_and_nrCellIdentity>
    ...                :param ${tput_file_dict}:tput file get from kw <save_average_tput_file_from_aasyslog_and_download_to_testPC>
    ...                :param ${cell_index}: cell index, index from 0. not cell id.
    ...                :param ${expect_tput}:expect tput for one cell, if is normal CA case without peak, it can be set to None.
    ...                :param ${expect_bler}:expect bler for one cell, if is normal CA case without peak, it can be set to None.
    ...                :param ${is_normal_ca_call}:CA Call without peak,If set to ${True}, no need to compare expect tput and actual tput.
    [Arguments]     ${direction}
    ...             ${nrCellIdentity_list}
    ...             ${tput_file_dict}
    ...             ${cell_index}
    ...             ${expect_tput}=10
    ...             ${expect_bler}=0.1
    ${all_average_tput}    get_tput_info_for_l2lo    tput_file=${tput_file_dict['${direction}_L2LO']}
    ${average_tput}    Set Variable    ${all_average_tput[${nrCellIdentity_list}[${cell_index}]]['average_tput']}
    ${average_tput}    Convert To Integer    ${average_tput}
    ${expect_tput}    Convert To Number    ${expect_tput}
    ${expect_bler}    Convert To Number    ${expect_bler}
    ${expect_tput}    Evaluate    ${expect_tput}*${1-${expect_bler}}
    Run Keyword And Continue On Failure    Should Be True    ${average_tput}>=${expect_tput}
    ...    msg=avg tput for ${direction}_CELL-${cell_index} is ${average_tput}, expect result is ${expect_tput}.
    [Return]    ${average_tput}

Start L3 Call Data Transfer
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                 this keyword start ul&dl traffic
    [Arguments]     ${ul_data_transfer}=20M
    ...             ${dl_data_transfer}=180M
    ...             ${duration}=600
    ...             ${ue_index}=${0}
    ...             ${cap_index}=${0}
    ...             ${buffer_size}=${DATA_LENGTH}
    ...             ${cap_index}=${0}
    ...             ${apn_address}=wap1nokiacom
    ...             ${need_get_ue_ip}=${False}
    ...             ${cpif_log_path}=${None}
    ...             ${is_multi_pdu}=${False}
    ...             ${ue_iperf_path}=iperf
    ...             ${mode}=SA
    ...             ${ue_ip_type}=data
    ...             ${dl_process_num}=2
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    ${start_traffic_duration}    set variable if    'lg' in '${ue_type}'    ${duration}s    ${duration}
    ${DL_PORT}=    Get Variable Value    ${DL_PORT}    default
    ${UL_PORT}=    Get Variable Value    ${UL_PORT}    default
    ${need_get_ue_ip}    Set Variable If    ${is_multi_pdu}    ${True}    ${need_get_ue_ip}
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer_1}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Run Keyword If    ${need_get_ue_ip}    Start Data Transfer With UE IP Required
    ...                                    cpif_log_path=${cpif_log_path}
    ...                                    dl_port=${DL_PORT}
    ...                                    ul_port=${UL_PORT}
    ...                                    ue_index=${ue_index}
    ...                                    dl_data_transfer=${dl_data_transfer}
    ...                                    ul_data_transfer=${ul_data_transfer}
    ...                                    duration=${start_traffic_duration}
    ...                                    is_multi_pdu=${is_multi_pdu}
    ...                                    ue_iperf_path=${ue_iperf_path}
    ...                                    mode=${mode}
    ...                                    ue_ip_type=${ue_ip_type}
    ...                                    dl_process_num=${dl_process_num}
    ...    ELSE    Run Keywords    power_ue.Start traffic
    ...                            ue_type=${ue_type}
    ...                            direction=dl
    ...                            throughput=${dl_data_transfer_1}
    ...                            duration=${start_traffic_duration}
    ...                            iperf_port=${DL_PORT}
    ...                            ue_index=${ue_index}
    ...                            cap_index=${cap_index}
    ...                            buffer_size=${buffer_size}
    ...                            dt_name=dt_dl
    ...                            apn_address=${apn_address}
    ...                            process_num=${dl_process_num}                   AND    power_ue.Start traffic    ue_type=${ue_type}
    ...                                                                                           direction=ul
    ...                                                                                           throughput=${ul_data_transfer}
    ...                                                                                           duration=${start_traffic_duration}
    ...                                                                                           iperf_port=${UL_PORT}
    ...                                                                                           ue_index=${ue_index}
    ...                                                                                           cap_index=${cap_index}
    ...                                                                                           buffer_size=${buffer_size}
    ...                                                                                           dt_name=dt_ul
    ...                                                                                           iperf_type=${iperf_type}
    ...                                                                                           apn_address=${apn_address}


#Start Data Transfer With UE IP Required
#    [Documentation]    Author:stella.lin@nokia-sbell.com
#    ...                For senario : 1. without attach  2. multi-PDU
#    [Arguments]    ${cpif_log_path}    ${dl_port}    ${ul_port}    ${ue_index}
#    ...            ${dl_data_transfer}=180M    ${ul_data_transfer}=50M    ${duration}=600
#    ...            ${is_multi_pdu}=${False}    ${ue_iperf_path}=iperf    ${mode}=SA
#    Run Keyword And Continue On Failure    Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
#    ...                                                                                  ul_time=${DATA_TIME}
#    ...                                                                                  ul_port=${ul_port}
#    ...                                                                                  ul_throughput=${ul_data_transfer}
#    ...                                                                                  ul_length=${DATA_LENGTH}
#    ...                                                                                  iperf_path=${ue_iperf_path}
#    ${ue_ip}    Wait Until Keyword Succeeds    3X    10sec
#    ...         Get UE IP Address    cpif_log_path=${cpif_log_path}    is_multi_pdu=${False}    mode=${mode}    pdu_index=0
#    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
#    Run Keyword And Continue On Failure    csn.send command
#    ...    command=iperf -c ${ue_ip} -u -t ${duration} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_data_transfer} -l ${DATA_LENGTH} -T 64 &
#    ...    connection=APPserver
#    ${second_pdu_ip}    Run Keyword If    ${is_multi_pdu}    Get UE IP Address    cpif_log_path=${cpif_log_path}
#    ...                                                                           is_multi_pdu=${False}
#    ...                                                                           mode=${mode}
#    ...                                                                           pdu_index=1
#    Run Keyword If    ${is_multi_pdu}    Run Keyword And Continue On Failure    csn.send command
#    ...    command=iperf -c ${second_pdu_ip} -u -t ${duration} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_data_transfer} -l ${DATA_LENGTH} -T 64 &
#    ...    connection=APPserver
#    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=APPserver

Start Data Transfer With UE IP Required
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                For senario : 1. without attach  2. multi-PDU
    [Arguments]    ${cpif_log_path}    ${dl_port}    ${ul_port}    ${ue_index}
    ...            ${dl_data_transfer}=180M    ${ul_data_transfer}=50M    ${duration}=600
    ...            ${is_multi_pdu}=${False}    ${ue_iperf_path}=iperf    ${mode}=SA    ${ue_ip_type}=data
    ...            ${dl_process_num}=2
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Run Keyword And Continue On Failure    Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                                                  ul_time=${DATA_TIME}
    ...                                                                                  ul_port=${ul_port}
    ...                                                                                  ul_throughput=${ul_data_transfer}
    ...                                                                                  ul_length=${DATA_LENGTH}
    ...                                                                                  iperf_path=${ue_iperf_path}
    ${ue_ip_dict}    Wait Until Keyword Succeeds    3X    10sec
    ...        Get ALL PDU IP Address From Wireshark    cpif_log_path=${cpif_log_path}    is_multi_pdu=${is_multi_pdu}    mode=${mode}
    ${ue_ip}    Set Variable    ${ue_ip_dict['${ue_ip_type}']}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    ${dl_command}    Set Variable
    ...    iperf -c ${ue_ip} -u -t ${duration} -i 1 -p ${dl_port} -P ${dl_process_num} -f m -b ${dl_data_transfer} -l ${DATA_LENGTH} -T 64 &
    Run Keyword And Continue On Failure    csn.send command
    ...    command=${dl_command}
    ...    connection=APPserver
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=APPserver


Save Tput Result
    [Arguments]    ${asik_alais}=ASIK Master
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${duration}=120
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    connection_alias_store.Connect to Common Unit Master    alias=${asik_alais}    gnb_index=${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}
    ${download_tput_file_dict}    save_average_tput_file_from_aasyslog_and_download_to_testPC
    ...                           download_dir=${download_dir}
    ...                           gnb_index=${gnb_index}
    ...                           duration=${duration}
    ...                           asik_alais=${asik_alais}
    [Return]     ${download_tput_file_dict}
    [Teardown]    Run keyword and ignore error    Run Keywords
    ...                       COAM Teardown gnb connections    connection=${connection}    AND
    ...                       csn.disconnect    connection=${asik_alais}

Get ENB IPaddress From GNB
    [Timeout]    5 min
    [Arguments]    ${gnb_index}=0    ${timeout}=20 min    ${connection}=GNB_OAM_for_enbIP
    Wait Until Keyword Succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}
    &{dict_ipAddr}     coam.get_parameters    dist_name=${MOs_lteenb_a[0]['distName']}  pattern=ipAddr    connection=${connection}
    [Return]    ${dict_ipAddr['ipAddr']}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Procedures.UE Prepare
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ue_alias}=UE_${ue_index}    ${get_spark_license}=${False}
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Prepare UE    ue_index=${ue_index}
    ...    ELSE    power_ue.Prepare UE
    ...            ue_type=${ue_type}
    ...            ue_index=${ue_index}
    ...            ue_alias=${ue_alias}
     ...           get_spark_license=${get_spark_license}

Procedures.UE Attach
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    ...               Modify:Stella.lin@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=cpif_attach
    ...            ${ue_type}=${ue_type}
    ...            ${ue_mode}=SA
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=15 sec
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${4G_check}=True
    ...            ${5Gstatus}=PASS
    ...            ${attach_mode}=5G_${ue_mode}
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${is_power_ue_code}=${False}
    ...            ${enb_host}=${None}
    ...            ${enb_user}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${enb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...            ${input_attach_cell_index}=${None}
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${coam_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${cprt_log_name}    Set Variable    cprt_attach_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${wireshark_log_name}
    ...    cprt_collector_name=${cprt_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ${enb_in_init_file_existence}    ${output}    Run Keyword And Ignore Error    Set Variable    ${tl.enbs[0]}
    ${enb_ip}    Run Keyword If    '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='FAIL'
    ...    Get ENB IPaddress From GNB    gnb_index=${gnb_index}
    ...    ELSE IF   '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='PASS'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If     '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}'    ${enb_ip}    ${enb_host}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        enb_host=${enb_host}
    ...                                                                        enb_user=${enb_user}
    ...                                                                        enb_password=${enb_password}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${5Grach_ed}    Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${False}'
    ...                Spark_common_keywords.Start UE Attach And Enable Data Service
    ...                ue_index=${ue_index}
    ...    ELSE    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${ue_index}
    ...                                  gnb_index=${gnb_index}
    ...                                  hwcheck_index=${hwcheck_index}
    ...                                  du_index=${du_index}
    ...                                  power_reset=${power_reset}
    ...                                  ue_alias=${ue_alias}
    ...                                  attach_mode=${attach_mode}
    Run Keyword If    '${ue_type}'!='mtk'    power_ue.Verify attach    ue_type=${ue_type}
    ...                                                                ue_index=${ue_index}
    ...                                                                gnb_index=${gnb_index}
    ...                                                                du_index=${du_index}
    ...                                                                5Grach_ed=${5Grach_ed}
    ...                                                                4G_check=${4G_check}
    ...                                                                5Gstatus=${5Gstatus}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    ${sleep_interval}
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}    cprt_collector_name=${cprt_log_name}
    ...    gnb_index=${gnb_index}    asik_connection_alias=${asik_connection_alias}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index}    Run Keyword If    '${input_attach_cell_index}'=='${None}'
    ...    Get Attach Cell Index From Wireshark    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${ue_mode}
    ...     ELSE      Set Variable     ${input_attach_cell_index}
#    ${crnti}    Get UE CRNTI From Wireshark    cpif_log_path=${cpif_attach_log_on_testPC}
    ${attach_info}    Run Keyword If    '${ue_mode}'=='NSA'
    ...            Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                 attach_cell_index=${attach_cell_index}
    ...                                 enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
#    ...                                 crnti=${crnti}
    ...    ELSE    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index}
#    ...    crnti=${crnti}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}

Procedures.Start Data Transfer
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    ...               for mtk and samsung ue, default iperf_path is '/data/local/tmp/iperf'; for qxc_dx50, default iperf_path is 'iperf'
    ...               Modify:Stella.lin@nokia-sbell.com 2022-7-18
    [Arguments]    ${cpif_log_path}    ${ue_mode}=SA    ${ue_index}=${0}    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${ul_throughput}=150M    ${dl_throughput}=2500MKbits/sec    ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${iperf_path}=iperf
    ...            ${ul_process_num}=${10}    ${dl_process_num}=${35}    ${seg_size}=${1350}    ${window}=16M
    ...            ${whether_start_dl_call}=${True}    ${whether_start_ul_call}=${True}    ${ue_type}=${ue_type}
    ...            ${ue_alias}=UE_${ue_index}    ${is_power_ue_code}=${False}
    ...            ${dl_process_num}=2
    log     ${ue_alias}
    Log To Console    ${\n}INFO:-- start to L3 call --
    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${iperf_path}    iperf
    Run Keyword If    ${whether_start_dl_call}    Run Keyword And Continue On Failure
    ...    Procedures.Start DL Data Transfer    cpif_log_path=${cpif_log_path}
    ...                                ue_type=${ue_type}
    ...                                ue_mode=${ue_mode}
    ...                                ue_index=${ue_index}
    ...                                apn_address=${apn_address}
    ...                                dl_throughput=${dl_throughput}
    ...                                start_keep_on_duration=${start_keep_on_duration}
    ...                                buffer_size=${buffer_size}
    ...                                appserver=${appserver}
    ...                                protocol=${protocol}
    ...                                process_num=${dl_process_num}
    ...                                seg_size=${seg_size}
    ...                                window=${window}
    ...                                is_power_ue_code=${is_power_ue_code}
    ...                                dl_process_num=${dl_process_num}
    Run Keyword If    ${whether_start_ul_call} and '${is_power_ue_code}'=='${False}'
    ...        traffic_via_iperf.Start UL traffic via iperf from andriod UE
    ...        ue_index=${ue_index}
    ...        ul_time=${start_keep_on_duration}
    ...        ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...        ul_throughput=${ul_throughput}
    ...        ul_length=${buffer_size}
    ...        appserver=${appserver}
    ...        protocol=${protocol}
    ...        iperf_path=${iperf_path}
    ...        process_num=${ul_process_num}
    Run Keyword If    ${whether_start_ul_call} and '${is_power_ue_code}'=='${True}'
    ...    power_ue.Start traffic
    ...    ue_type=${ue_type}
    ...    direction=ul
    ...    duration=${start_keep_on_duration}
    ...    throughput=${ul_throughput}Kbits/sec
    ...    ue_index=${ue_index}
    ...    apn_address=${apn_address}

Procedures.Start DL Data Transfer
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${ue_mode}=SA    ${ue_index}=${0}    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${dl_throughput}=2500MKbits/sec    ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp
    ...            ${process_num}=${5}    ${seg_size}=${1372}    ${window}=2M    ${ue_type}=${ue_type}    ${is_power_ue_code}=${False}
    ...            ${dl_process_num}=2
    log     ${process_num}
    Log To Console    ${\n}INFO:-- start to DL call --
    ${ue_ip_dict}    Wait Until Keyword Succeeds    3X    10sec    Get ALL PDU IP Address From Wireshark
    ...    cpif_log_path=${cpif_log_path}    mode=${ue_mode}
    ${dl_throughput}    Set Variable If    '${ue_type}'!='huawei_sigspark'    ${dl_throughput.split('Mkbits')[0]}M
    ...    '${ue_type}'=='huawei_sigspark' and ${is_power_ue_code}    ${dl_throughput.split('M')[0]}M
    ...    '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${False}'    ${dl_throughput}
#    ${process_num}    Set Variable If    '${protocol}'=='udp'     1    ${process_num}
    ${dl_data_value}    get regexp matches    ${dl_throughput}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_throughput}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_throughput_1}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Run Keyword If    '${protocol}'=='udp' and '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${False}'
    ...                                       Spark_common_keywords.Start DL Traffic    dl_throughput=${dl_throughput}
    ...                                                                                 duration=${start_keep_on_duration}
    ...                                                                                 apn_address=${apn_address}
    ...                                                                                 ue_mode=${ue_mode}
    ...                                                                                 ue_index=${ue_index}
    ...    ELSE    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
    ...                                                       dl_time=${start_keep_on_duration}
    ...                                                       dl_port=${tl.ues[${ue_index}].iperf_details.port}
    ...                                                       dl_throughput=${dl_throughput_1}
    ...                                                       dl_length=${buffer_size}
    ...                                                       appserver=${appserver}
    ...                                                       protocol=${protocol}
    ...                                                       ue_index=${ue_index}
    ...                                                       process_num=${dl_process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}

Procedures.Check Tput
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    ...               Modify:Stella.lin@nokia-sbell.com
    ...               If ${whether_collect_tput}=${False}, the parameter ${tput_file_use_collested} must not be ${None}
    ...               Need to collect tput first, then set the vlaue of ${tput_file_use_collested} is the existed file.
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${addition_scell_index_list}=${None}
    ...            ${tput_collect_duration}=120    ${check_pcell_tput_type}=peak    ${check_scell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.9    ${check_ul_pcell_tput_type}=peak
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85    ${expect_tp_percent}=1
    ...            ${pcell_mapping}=${PCELL_MAPPING}    ${scell_mapping}=${SCELL_MAPPING}
    ...            ${whether_collect_tput}=${True}    ${tput_file_use_collected}=${None}
    ...            ${check_source}=aasyslog    ${ignore_time}=30sec
    ...            ${check_pcell_tput}=${True}    ${check_scell_tput}=${True}
    ...            ${is_ca_case}=${True}    ${inactivate_scell_index_list}=@{EMPTY}
    ...            ${auto_required_dl_tput_layers}=${False}
    log     ${ue_index}
    Log To Console    ${\n}INFO:-- start to check CA tupt --
    Run Keyword If    ${is_ca_case}    Check Tput For CA Group    ue_type=${ue_type}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           duration=${tput_collect_duration}
    ...                                                           addition_scell_index_list=${addition_scell_index_list}
    ...                                                           check_pcell_tput_type=${check_pcell_tput_type}
    ...                                                           check_scell_tput_type=${check_scell_tput_type}
    ...                                                           target_DL_avg_percent=${target_DL_avg_percent}
    ...                                                           target_UL_avg_percent=${target_UL_avg_percent}
    ...                                                           min_DL_percent=${min_DL_percent}
    ...                                                           min_UL_percent=${min_UL_percent}
    ...                                                           min_scell_percent=${min_scell_percent}
    ...                                                           expect_tp_percent=${expect_tp_percent}
    ...                                                           check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                                           pcell_mapping=${pcell_mapping}
    ...                                                           scell_mapping=${scell_mapping}
    ...                                                           whether_collect_tput=${whether_collect_tput}
    ...                                                           tput_file_use_collected=${tput_file_use_collected}
    ...                                                           check_source=${check_source}
    ...                                                           ignore_time=${ignore_time}
    ...                                                           check_pcell_tput=${check_pcell_tput}
    ...                                                           check_scell_tput=${check_scell_tput}
    ...                                                           inactivate_scell_index_list=${inactivate_scell_index_list}
    ...                                                           auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
