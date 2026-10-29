*** Settings ***
Documentation    This is to check Qualcomm L3 call whole process.
...              including Start UE Attach, Start UL/DL Traffic, Calculate Average UL/DL Throughput and Check UL Bler.
...              Author: Jia Lei
...              Contact: lei.jia@nokia-sbell.com
...              Squard: HZ SG6


Library    BuiltIn
Library    taf.analyzer.pcap    WITH NAME    cap
Library    ../python/check_average_throughput.py
Library    ../python/coam_gnb_classical.py
Library    ../python/ue.py
Resource    gnb_classical_hangzhou.robot
Resource    container_log_capturing.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    power_ue/power_ue.robot



*** Variables ***
${DATA_TIME}        9999
${DATA_LENGTH}      1400
${DL_PORT}          ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_PORT}          ${tl.ues[0].iperf_details.port}
@{data_direction_list}    ul    dl


*** Keywords ***
Verify Throughput And UL Bler
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                Descrition: Verify required throughput for all streams and calculate UL bler.
    ...                :param direction_component_list <list>:
    ...                 value can be single or multi values in [UL_L2LO,DL_L2LO]
    ...                :param is_ulbler_calcu <string>:
    ...                 default value is true, when it is set as fault, ul bler will not be calculated.
    ...                :param cellid <int>:
    ...                optional, 1,2 and so on, check specified cell L2LO tput under multi subsector env
    [Arguments]    ${direction_component_list}
    ...            ${expect_ul_tput}=${None}
    ...            ${expect_dl_tput}=${None}
    ...            ${expect_ul_bler}=0.03
    ...            ${duration}=180
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${hw_slot}=${1}
    ...            ${is_ulbler_calcu}=${True}
    ...            ${asik_alais}=ASIK Master
    ...            ${abil_alais}=ABIL Master
    ...            ${abil_slave_alais}=ABIL Slave
    ...            ${abil_index}=1
    ...            ${cellid}=1
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ${cellid}    Convert To Integer    ${cellid}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alais}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to Common Unit Master
    Connect to gnb coam via ssl    connection=${connection}
    Run Keyword If    ${is_ulbler_calcu}    gnb_classical_hangzhou.Reset UL Bler Counter On Loner
    ${download_tput_file_dict}    save_average_tput_file_from_aasyslog_and_download_to_testPC
#    ...                                 direction_component_list=${direction_component_list}
    ...                                 download_dir=${download_dir}
    ...                                 gnb_index=${gnb_index}
    ...                                 duration=${duration}
    ...                                 asik_alais=${asik_alais}
    FOR    ${item}    IN    @{direction_component_list}
        ${direction}    Set Variable    ${item.split('_')}[0]
        ${component}    Set Variable    ${item.split('_')}[1]
        ${expect_tput}    Set Variable If    '${direction}'=='UL'     ${expect_ul_tput}
        ...                                  '${direction}'=='DL'     ${expect_dl_tput}
        Run Keyword And Continue On Failure    Evaluate Average Tput For L2L0
        ...    tput_file=${download_tput_file_dict['${item}']}
        ...    expect_tput_value=${expect_tput}    cellid=${cellid}    direction=${direction}
        ...    connection=${connection}
    END
    Run Keyword If    ${is_ulbler_calcu}    gnb_classical_hangzhou.Calculate UL Bler On Loner    expect_value=${expect_ul_bler}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Evaluate Average Tput For L2L0
    [Documentation]    Auther:mengping.cai@nokia-sbell.com
    ...                Modifier:stella.lin@nokia-sbell.com
    ...                Descrition: Verify required throughput and calculate UL bler.
    ...                :param tput_file <string>:tput file dir
    ...                :param expect_tput_value <string or int>:expect_tput_value
    ...                :param cellid <int>:
    ...                optional,if need to get specified cell tput of multi-subsector env
    [Arguments]    ${tput_file}=${None}
    ...            ${expect_tput_value}=${None}
    ...            ${cellid}=${None}
    ...            ${direction}=None
    ...            ${connection}=GNB_OAM
    ${cell_mapping}=    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${nrcellid}=    Evaluate    int(${cell_mapping[${cellid}]['nrCellIdentity']})
    ${all_average_tput}    Run Keyword And Continue On Failure    get_tput_info_for_l2lo
    ...                   tput_file=${tput_file}
    ${average_tput}    Set Variable    ${all_average_tput[${nrcellid}]['average_tput']}
    ${expect_tput}=    Evaluate    float(${expect_tput_value})
    ${average_tput}=    Evaluate    float(${average_tput})
    Run Keyword If    ${expect_tput}>${average_tput}    Fail
    ...               avg ${direction} tput of ${cellid} is ${average_tput}, expect result is ${expect_tput}
    [Return]    ${average_tput}

Start UE Attach With Power UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                this keyword perform ue attach and verify 4g/5g rach success.
    ...                2020/2/22 Jia Lei: updated for two askey ues, as only one ue list out in init.py file.
    ...                If param ${is_wireshark_log_capture} set to Ture, then return the captured pcap file path on testPC.
    [Arguments]    ${is_wireshark_log_capture}=${False}
    ...            ${wireshark_log_prefix}=x2_log_attach
    ...            ${interface}=-i any -s 0
    ...            ${connection}=ASIK Master
    ...            ${container_id}=0x1011
    ...            ${retry_time}=10
    ...            ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ...            ${ue_index}=${0}
    ...            ${cap_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${abil_index}=${1}
    ...            ${hwcheck_index}=${1}
    ...            ${reset_sol}=none
    ...            ${detach_request}=${true}
    ...            ${4G_check}=True
    ...            ${5Gstatus}=PASS
    ...            ${asik_slave_alias}=ASIK Slave
    ...            ${is_askey_used}=False
    ...            ${power_reset}=False
    ...            ${sleep_interval}=10 sec
    ...            ${is_do_require_ue}=${True}
    ...            ${get_attach_cell_index_needed}=${False}
    ...            ${coam_connection}=GNB_OAM
    ...            ${mode}=SA
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${ue_type_index}    Set Variable If    ${is_askey_used}==${True}     ${0}    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_type_index}
    set test variable    ${ue_type}
    Run Keyword If    ${is_do_require_ue}    power_ue.Prepare UE    ue_type=${ue_type}
    ...                                                             ue_index=${ue_index}
    ...                                                             capatibility_index=${cap_index}
    ...                                                             reset_sol=${reset_sol}
    ...                                                             detach_request=${detach_request}
    ${wireshark_log_path}    Run Keyword If    ${is_wireshark_log_capture}
    ...    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=${wireshark_log_name}
    ...                                                                          asik_connection_alias=${connection}
    ...                                                                          gnb_index=${gnb_index}
    ...                                                                          du_index=${du_index}
    ...                                                                          options=${interface}
    Run Keyword If    ${is_wireshark_log_capture}    Sleep    ${sleep_interval}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    ...                                   ue_index=${ue_index}
    ...                                   gnb_index=${gnb_index}
    ...                                   hwcheck_index=${hwcheck_index}
    ...                                   abil_index=${abil_index}
    ...                                   du_index=${du_index}
    ...                                   power_reset=${power_reset}
    ${attach_status}    Run keyword and return status
    ...         power_ue.Verify attach    ue_type=${ue_type}
    ...                                   5Grach_ed=${5Grach_ed}
    ...                                   ue_index=${ue_index}
    ...                                   gnb_index=${gnb_index}
    ...                                   du_index=${du_index}
    ...                                   abil_index=${abil_index}
    ...                                   4G_check=${4G_check}
    ...                                   5Gstatus=${5Gstatus}
    csn.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
#    ${is_feature_1948_enabled}    Is Feature 1948 Enabled    connection_alias=${connection}
#    Run Keyword If    ${is_feature_1948_enabled}==${True}    connection_alias_store.Connect to Common Unit Slave
#    ${connection}    Set Variable If    ${is_feature_1948_enabled}==${True}    ${asik_slave_alias}    ${connection}
    Run Keyword If    ${is_wireshark_log_capture}    Sleep    ${sleep_interval}
    ${wireshark_log_path_on_testPC}    Run Keyword If    ${is_wireshark_log_capture}    Run Keyword And Continue On Failure
    ...                                Stop tcpdump log collection    tcpdump_collector_name=${wireshark_log_name}    target_dir=${log_dir_ute}
    ${attach_cell_index}    Run Keyword If    ${get_attach_cell_index_needed}    Get Attach Cell Index From Wireshark
    ...                                                                        cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                                        connection=${coam_connection}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        mode=${mode}
    ${attach_info_dict}    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}    attach_cell_index=${attach_cell_index}
    ${return_info}    Set Variable If    ${get_attach_cell_index_needed}       ${attach_info_dict}
    ...                                                                      ${wireshark_log_path_on_testPC}
    run keyword if  not ${attach_status}    Fail    UE ${ue_index} attach fail.
    [Return]     ${return_info}
    [Teardown]    Run Keyword If    ${is_wireshark_log_capture}    run keywords
    ...    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...    Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}

Start L3 Call With Power UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  this keyword start ul&dl traffic
    [Arguments]    ${ul_data_transfer}=20M
    ...             ${dl_data_transfer}=180M
    ...             ${duration}=600
    ...             ${ue_index}=${0}
    ...             ${cap_index}=${0}
    ...             ${buffer_size}=${DATA_LENGTH}
    ...             ${cap_index}=${0}
    ...             ${ul_dt_name}=dt_ul
    ...             ${dl_dt_name}=dt_dl
    ...             ${iperf_type}=via_app
    ...             ${apn_address}=wap1nokiacom
    ...             ${protocol}=udp
    ...             ${process_num}=${5}
    ...             ${dl_process_num}=1
    ${start_traffic_duration}    set variable if    'lg' in '${ue_type}'    ${duration}s    ${duration}
    ${process_no}    Set Variable If    '${protocol}'=='udp'     1    ${process_num}
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    power_ue.Start traffic    ue_type=${ue_type}
    ...                       direction=dl
    ...                       throughput=${dl_data_transfer}
    ...                       duration=${start_traffic_duration}
    ...                       protocol=${protocol}
    ...                       iperf_port=default
    ...                       ue_index=${ue_index}
    ...                       cap_index=${cap_index}
    ...                       buffer_size=${buffer_size}
    ...                       dt_name=${dl_dt_name}
    ...                       apn_address=${apn_address}
    ...                       process_num=${dl_process_num}
    power_ue.Start traffic    ue_type=${ue_type}
    ...                       direction=ul
    ...                       throughput=${ul_data_transfer}
    ...                       duration=${start_traffic_duration}
    ...                       protocol=${protocol}
    ...                       iperf_port=default
    ...                       ue_index=${ue_index}
    ...                       cap_index=${cap_index}
    ...                       buffer_size=${buffer_size}
    ...                       dt_name=${ul_dt_name}
    ...                       iperf_type=${iperf_type}
    ...                       apn_address=${apn_address}
    ...                       process_num=${process_no}

Stop Traffic With Power UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  this keyword stop ul/dl traffic and detach ue
    [Arguments]    ${ue_index}=${0}
    ...             ${data_transfer_direction}=${data_direction_list}
    ...             ${iperf_type}=via_app
    ...             ${apn_address}=wap1nokiacom
    ...             ${protocol}=udp
    ...             ${is_detach}=${True}
    FOR    ${direction}    IN    @{data_direction_list}
        run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}
        ...                                                             direction=${direction}
        ...                                                             dt_name=dt_${direction}
        ...                                                             protocol=${protocol}
        ...                                                             iperf_port=default
        ...                                                             iperf_type=${iperf_type}
        ...                                                             ue_index=${ue_index}
        ...                                                             apn_address=${apn_address}
    END
    Run Keyword If    ${is_detach}    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Check Tput With Power UE
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Descrition: Verify throughput with power ue.
    [Arguments]    ${direction_component_list}
    ...            ${expect_ul_tput}=${None}
    ...            ${expect_dl_tput}=${None}
    ...            ${expect_ul_bler}=0.03
    ...            ${duration}=300
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${hw_slot}=${1}
    ...            ${is_ulbler_calcu}=${True}
    ...            ${asik_alais}=ASIK Master
    ...            ${abil_alais}=ABIL Master
    ...            ${abil_slave_alais}=ABIL Slave
    ...            ${abil_index}=1
    ...            ${cellid}=1
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${ignore_time}=1min
    ...            ${target_avg_percent}=0.95
    ...            ${min_percent}=0.85
    ...            ${actCarrierAggregation}=${False}
    ...            ${list_all_cell_ids}=${False}
    ...            ${check_source}=spark
    ...            ${ue_type}=${ue_type}
    ...            ${whether_get_nrcellid}=${True}
    ${list_nrcell_ids}    Run Keyword If    ${whether_get_nrcellid}    Get NRCELLID based on CELLID    cellid=${cellid}
    ...                                                                                                connection=${connection}
    ...                                                                                                list_all_cell_ids=${list_all_cell_ids}
    ...                                                                                                gnb_index=${gnb_index}
    ...                             ELSE    Create List    ${cellid}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}
    ...    du_index=${du_index}    duration=${duration}    ignore_time=${ignore_time}    check_source=${check_source}
    FOR    ${item}    IN    @{direction_component_list}
        ${direction}    Set Variable    ${item.split('_')}[0]
        ${expect_tput}    Set Variable If    '${direction}'=='UL'     ${expect_ul_tput}
        ...                                  '${direction}'=='DL'     ${expect_dl_tput}
        Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
        ...                                                           log=${tput_log}    cells=${list_nrcell_ids}
        ...                                                           target_throughput=${expect_tput}
        ...                                                           target_avg_percent=${target_avg_percent}
        ...                                                           actCarrierAggregation=${actCarrierAggregation}
        ...                                                           check_source=${check_source}
        ...                                                           min_percent=${min_percent}
    END
    [Teardown]    Run Keyword If    ${whether_get_nrcellid}    Run keyword and ignore error    COAM Teardown gnb connections
    ...    connection=${connection}

Get NRCELLID based on CELLID
    [Arguments]    ${cellid}=1     ${connection}=GNB_OAM     ${list_all_cell_ids}=${False}    ${gnb_index}=0
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}=    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${all_cell_ids}    Get dictionary keys    ${cell_mapping}
    ${list_cell_ids}   Create list    ${cellid}
    ${list_nrcell_ids}   Create list
    ${list_cell_ids}    Set variable if    ${list_all_cell_ids}==${True}    ${all_cell_ids}    ${list_cell_ids}
    FOR    ${cellid}    IN    @{list_cell_ids}
        ${nrcellid}    set variable    ${cell_mapping[${cellid}]['nrCellIdentity']}
        ${nrcellid}    Convert To String    ${nrcellid}
        append to list    ${list_nrcell_ids}    ${nrcellid}
    END
    [Return]  ${list_nrcell_ids}

Get Attach Cell Index From Wireshark
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               SA:get attach cell index in message <InitialUEContext>,message filter: ngap.procedureCode == 15
    ...               NSA:get attach cell index in message <InitialUEContext>,message filter: f1ap.procedureCode == 5
    [Arguments]    ${cpif_log_path}    ${connection}=GNB_OAM    ${gnb_index}=0    ${mode}=SA
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${filter_expression}    Set Variable If    '${mode}'=='SA'    ngap.procedureCode == 15
    ...                                                           f1ap.procedureCode == 5 && f1ap.nRCellIdentity
    ${xpath}    Set Variable If    '${mode}'=='SA'    .//ngap.NRCellIdentity    .//f1ap.nRCellIdentity
    cap.load_pcap_file    pcap_file=${cpif_log_path}
    ...                                       command_template={tshark_path} -r {pcap_file} -Y \"${filter_expression}\" -T pdml
    ...                                       tshark_path=/usr/bin/tshark
    ${cell_nr_identity_on_wireshark}    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=value
    ${cell_nr_identity_on_wireshark}    Get Substring     ${cell_nr_identity_on_wireshark[0]}    0   9
    ${cell_nr_identity_on_wireshark}    Convert To Binary    ${cell_nr_identity_on_wireshark}    base=16
    ${cell_nr_identity}    Convert To Integer    ${cell_nr_identity_on_wireshark}    base=2
    ${cell_mapping}     coam_gnb_classical.get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${all_cell_ids}    Get dictionary keys    ${cell_mapping}
    FOR  ${cell_id}  IN  @{all_cell_ids}
     ${attach_cell_index}    Run Keyword If    '${cell_mapping[${cell_id}]['nrCellIdentity']}'=='${cell_nr_identity}'
     ...                                        Set Variable    ${cell_id}
     Exit For Loop If    '${attach_cell_index}'!='${None}'
    END
    [Return]    ${attach_cell_index}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
