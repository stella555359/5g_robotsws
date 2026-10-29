*** Settings ***
Documentation
...    Contact: ming.shi@nokia.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_variables.py

Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_common_keywords.py
Library      taf.hw.rf_attenuator    WITH NAME    att
Library    DateTime

*** Variables ***
${CONFIGURATION_FILE}    /opt/workspace/SCF/E2E_case_configuration.yml

*** Keywords ***
Common Suite Setup For E2E case
    Common Suite Setup for COAM
    ${test_info}=    CB007834_common_keywords.get_info_from_file    file_path=${CONFIGURATION_FILE}
    Set Suite Variable    ${test_info}

Common Suite Teardown For E2E case
    Common Suite Teardown for COAM    gnb_list=${gnb_list}

Common Case Setup For E2E case
    Set Test Variable    ${allowed_faults_ids}    ${test_info}[allowed_faults_ids]
    ${allowed_faults_ids_string}=    Evaluate    ','.join(${allowed_faults_ids})
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids_string}
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    END
    paras change on LTE    paras=${PARAMETERS_LTE_CELL_LOCKED}    delta_file_name=${JSON_PATH}LTE_CELL_LOCKED.json
    ...    enb_index=${0}

Common Case Teardown For E2E case
    robot_common_operations.Common Case Teardown
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id}
    END
    COAM Save all gnb snapshot via api    gnb_list=${GNBS_INDEX}
    paras change on BTS    paras=${PARAMETERS_RECOVER_EPSFB}    delta_file_name=${JSON_PATH}RECOVER_EPSFB.json
    ...    gnb_index=${0}
    paras change on BTS    paras=${PARAMETERS_RECOVER_LTE_UNBARRED_NR_UNBARRED}
    ...    delta_file_name=${JSON_PATH}RECOVER_LTE_UNBARRED_NR_UNBARRED.json
    ...    gnb_index=${1}
    paras change on LTE    paras=${PARAMETERS_LTE_CELL_UNLOCKED}    delta_file_name=${JSON_PATH}LTE_CELL_UNLOCKED.json
    ...    enb_index=${0}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

ues were operated via py file
    [Arguments]    ${tl_id}    ${file_name}    ${pc_ip}    ${pc_usr}    ${pc_pwd}
    ...    ${path}=${PY_PATH}
    ${command}=    Catenate    source CIENV/7_5_UTE5G402T${tl_id}/bin/activate; python ${path}${file_name} ${pc_ip} ${pc_usr} ${pc_pwd}
    ${rc}    ${output}=    run and return rc and output    ${command}

ho hang up voice detach to end group_3
#    hang_up_vonr_call_per_ue    ue_index=${0}
#    hang_up_emc_call_per_ue    ue_index=${9}
    hang_up_vonr_and_emc_call    vonr_ue_index=${0}    emc_ue_index=${9}
    Sleep    5s
    ues were operated via py file
    ...    file_name=all_ues_detach_via_thread_pool.py
    ...    pc_ip=${test_info}[ues_were_operated_via_py_file][pc_ip]
    ...    pc_usr=${test_info}[ues_were_operated_via_py_file][pc_usr]
    ...    pc_pwd=${test_info}[ues_were_operated_via_py_file][pc_pwd]
    ...    tl_id=${test_info}[ues_were_operated_via_py_file][tl_id]

recover_pa
    [Arguments]
    ...    ${ports}
    ...    ${pa_index}=${1}
    att.setup_attenuator    ip_addr=${tl.attenuator[${pa_index}].ip_addr}
    ...                     port=${tl.attenuator[${pa_index}].port}
    ...                     model=${tl.attenuator[${pa_index}].model}
    ...                     attenuation_port_numbers=${tl.attenuator[${pa_index}].attenuator_ports[5]}
    ...                     max_attenuation=${127}
    ...                     vendor=${tl.attenuator[${pa_index}].vendor}
    ${num}=    Get Length    ${ports}
    ${v}=    Evaluate    [${127}] * ${num}
    att.set_ports_attenuation    ports=${ports}    values=${v}
    Sleep    1s
    ${ports_values}=    att.read_ports_attenuation    ports=${ports}
    ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
    ${sorted_v}=    Evaluate    sorted(${v})
    Should Be Equal    ${sorted_ports_values}    ${sorted_v}

set_pa
    [Arguments]
    ...    ${ports}
    ...    ${values}
    ...    ${pa_index}=${1}
    att.setup_attenuator    ip_addr=${tl.attenuator[${pa_index}].ip_addr}
    ...                     port=${tl.attenuator[${pa_index}].port}
    ...                     model=${tl.attenuator[${pa_index}].model}
    ...                     attenuation_port_numbers=${tl.attenuator[${pa_index}].attenuator_ports[5]}
    ...                     max_attenuation=${127}
    ...                     vendor=${tl.attenuator[${pa_index}].vendor}
    att.set_ports_attenuation    ports=${ports}    values=${values}
    Sleep    1s
    ${ports_values}=    att.read_ports_attenuation    ports=${ports}
    ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
    ${sorted_values}=    Evaluate    sorted(${values})
    Should Be Equal    ${sorted_ports_values}    ${sorted_values}

recover_rf_matrix
    [Arguments]
    ...    ${rf_matrix_index}=${0}
    ${ports}=    Evaluate    [i for i in range(1, 257)]
    ${values}=    Evaluate    [${120}] * ${256}
    att.setup_attenuator    ip_addr=${tl.attenuator[${rf_matrix_index}].ip_addr}
    ...                     port=${tl.attenuator[${rf_matrix_index}].port}
    ...                     model=${tl.attenuator[${rf_matrix_index}].model}
    ...                     attenuation_port_numbers=${ports}
    ...                     max_attenuation=${120}
    ...                     vendor=${tl.attenuator[${rf_matrix_index}].vendor}
    att.set_ports_attenuation    ports=${ports}    values=${values}
    Sleep    5s
#    ${ports_values}=    att.read_ports_attenuation    ports=${ports}
#    ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
#    ${sorted_values}=    Evaluate    sorted(${values})
#    Should Be Equal    ${sorted_ports_values}    ${sorted_values}

set_precondition_values_with_rf_matrix
    [Arguments]
    ...    ${ports}
    ...    ${values}
    ...    ${rf_matrix_index}=${0}
    att.setup_attenuator    ip_addr=${tl.attenuator[${rf_matrix_index}].ip_addr}
    ...                     port=${tl.attenuator[${rf_matrix_index}].port}
    ...                     model=${tl.attenuator[${rf_matrix_index}].model}
    ...                     attenuation_port_numbers=${ports}
    ...                     max_attenuation=${120}
    ...                     vendor=${tl.attenuator[${rf_matrix_index}].vendor}
    att.set_ports_attenuation    ports=${ports}    values=${values}
    Sleep    2s
#    ${ports_values}=    att.read_ports_attenuation    ports=${ports}
#    ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
#    ${sorted_values}=    Evaluate    sorted(${values})
#    Should Be Equal    ${sorted_ports_values}    ${sorted_values}

loop_cell21_ho_gnb2_cell1
    [Arguments]
    ...    ${source_ports}
    ...    ${source_values}
    ...    ${target_ports}
    ...    ${target_values}
    ...    ${step}
    ...    ${ho_times}=${1000}
    ...    ${rf_matrix_index}=${0}
    att.setup_attenuator    ip_addr=${tl.attenuator[${rf_matrix_index}].ip_addr}
    ...                     port=${tl.attenuator[${rf_matrix_index}].port}
    ...                     model=${tl.attenuator[${rf_matrix_index}].model}
    ...                     attenuation_port_numbers=${source_ports}
    ...                     max_attenuation=${120}
    ...                     vendor=${tl.attenuator[${rf_matrix_index}].vendor}
    FOR    ${t}    IN RANGE    ${ho_times}
        Log To Console    This is ${t} times HO with loop_cell21_ho_gnb2_cell1
        FOR    ${i}    IN RANGE    ${target_values}[0]    ${source_values}[0] - ${step}    -${step}
            ${num}=    Get Length    ${target_ports}
            ${v}=    Evaluate    [${i}] * ${num}
            att.set_ports_attenuation    ports=${target_ports}    values=${v}
            Sleep    1.5s
#            ${ports_values}=    att.read_ports_attenuation    ports=${target_ports}
#            ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
#            ${sorted_v}=    Evaluate    sorted(${v})
#            Should Be Equal    ${sorted_ports_values}    ${sorted_v}
        END
        FOR    ${i}    IN RANGE    ${source_values}[0]    ${target_values}[0] + ${step}    ${step}
            ${num}=    Get Length    ${source_ports}
            ${v}=    Evaluate    [${i}] * ${num}
            att.set_ports_attenuation    ports=${source_ports}    values=${v}
            Sleep    1.5s
#            ${ports_values}=    att.read_ports_attenuation    ports=${source_ports}
#            ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
#            ${sorted_v}=    Evaluate    sorted(${v})
#            Should Be Equal    ${sorted_ports_values}    ${sorted_v}
        END
    END

set_nr_pa_value_to_start_group_3
    [Arguments]
    ...    ${ports}
    ...    ${values}
    ...    ${pa_index}=${1}
    att.setup_attenuator    ip_addr=${tl.attenuator[${pa_index}].ip_addr}
    ...                     port=${tl.attenuator[${pa_index}].port}
    ...                     model=${tl.attenuator[${pa_index}].model}
    ...                     attenuation_port_numbers=${tl.attenuator[${pa_index}].attenuator_ports[5]}
    ...                     max_attenuation=${127}
    ...                     vendor=${tl.attenuator[${pa_index}].vendor}
    att.set_ports_attenuation    ports=${ports}    values=${values}
    Sleep    0.5s
    ${ports_values}=    att.read_ports_attenuation    ports=${ports}
    ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
    ${sorted_values}=    Evaluate    sorted(${values})
    Should Be Equal    ${sorted_ports_values}    ${sorted_values}

inter_rat_ho_make_voice
    [Arguments]
    ...    ${lte_ports}
    ...    ${lte_values}
    ...    ${lte_source_value}
    ...    ${lte_target_value}
    ...    ${lte_steps}
    ...    ${nr_ports}
    ...    ${nr_values_1}
    ...    ${nr_values_2}
    ...    ${nr_source_value}
    ...    ${nr_target_value}
    ...    ${nr_steps}
    ...    ${ho_times}
    ...    ${pa_index}=${1}
    att.setup_attenuator    ip_addr=${tl.attenuator[${pa_index}].ip_addr}
    ...                     port=${tl.attenuator[${pa_index}].port}
    ...                     model=${tl.attenuator[${pa_index}].model}
    ...                     attenuation_port_numbers=${tl.attenuator[${pa_index}].attenuator_ports[5]}
    ...                     max_attenuation=${127}
    ...                     vendor=${tl.attenuator[${pa_index}].vendor}
    FOR    ${t}    IN RANGE    ${ho_times}
        Log To Console    This is ${t} times HO with inter_rat_ho_make_voice
        # 4G
        att.set_ports_attenuation    ports=${lte_ports}    values=${lte_values}
        Sleep    0.5s
        ${ports_values}=    att.read_ports_attenuation    ports=${lte_ports}
        ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
        ${sorted_values}=    Evaluate    sorted(${lte_values})
        Should Be Equal    ${sorted_ports_values}    ${sorted_values}
        # 5G
        FOR    ${i}    IN RANGE    ${nr_source_value}    ${nr_target_value} + ${nr_steps}    ${nr_steps}
            ${num}=    Get Length    ${nr_ports}
            ${v}=    Evaluate    [${i}] * ${num}
            att.set_ports_attenuation    ports=${nr_ports}    values=${v}
            Sleep    0.5s
            ${ports_values}=    att.read_ports_attenuation    ports=${nr_ports}
            ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
            ${sorted_v}=    Evaluate    sorted(${v})
            Should Be Equal    ${sorted_ports_values}    ${sorted_v}
        END
        Sleep    10s
        # 5G
        att.set_ports_attenuation    ports=${nr_ports}    values=${nr_values_1}
        Sleep    0.5s
        ${ports_values}=    att.read_ports_attenuation    ports=${nr_ports}
        ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
        ${sorted_values}=    Evaluate    sorted(${nr_values_1})
        Should Be Equal    ${sorted_ports_values}    ${sorted_values}
        # 4G
        FOR    ${i}    IN RANGE    ${lte_source_value}    ${lte_target_value} + ${lte_steps}    ${lte_steps}
            ${num}=    Get Length    ${lte_ports}
            ${v}=    Evaluate    [${i}] * ${num}
            att.set_ports_attenuation    ports=${lte_ports}    values=${v}
            Sleep    0.5s
            ${ports_values}=    att.read_ports_attenuation    ports=${lte_ports}
            ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
            ${sorted_v}=    Evaluate    sorted(${v})
            Should Be Equal    ${sorted_ports_values}    ${sorted_v}
        END
        Sleep    10s
        # 5G
        att.set_ports_attenuation    ports=${nr_ports}    values=${nr_values_2}
        Sleep    0.5s
        ${ports_values}=    att.read_ports_attenuation    ports=${nr_ports}
        ${sorted_ports_values}=    Evaluate    sorted(${ports_values})
        ${sorted_values}=    Evaluate    sorted(${nr_values_2})
        Should Be Equal    ${sorted_ports_values}    ${sorted_values}
    END

Teardown TTitrace mirror on BTS
    [Arguments]    ${names}=l2stream3_ttitrace
    log to console    stop ttitrace mirror...
    core.teardown_collectors
    ...  names=${names}

Stop Collect TTitrace and package TTitrace on remote UTE
    [Arguments]    ${names}=tcpdump_ttitrace
    ...            ${uteTTI_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${uteTTI_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${uteTTI_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${tti_path}=/opt
    csn.Connect to    hostname=${uteTTI_ip}    username=${uteTTI_username}    password=${uteTTI_password}    alias=${names}
    csn.execute    command=ps -ef | grep tcpdump |grep -v grep|awk '{print $2}'|sudo xargs kill -9
    ...    connection=${names}
    csn.execute    command=sudo mkdir -p ${tti_path}&& sudo mv /tmp/ttitrace.pcap* ${tti_path}
    ...    connection=${names}
    [Teardown]    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=${names}

Start Collect TTitrace on remote UTE
    [Arguments]    ${names}=tcpdump_ttitrace
    ...            ${uteTTI_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${uteTTI_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${uteTTI_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${maxsize}=500
    ...            ${maxnumber}=200
    ...            ${ute_inet}=eth0
    ...            ${bts_port}=5678
    ...            ${timeout}=5
    csn.Connect to    hostname=${uteTTI_ip}    username=${uteTTI_username}    password=${uteTTI_password}    alias=${names}
    csn.execute    command=ps -ef | grep tcpdump |grep -v grep|awk '{print $2}'|sudo xargs kill -9
    ...    connection=${names}
    csn.execute    command=sudo rm -rf /tmp/ttitrace.pcap*
    ...    connection=${names}
    ${tti_cmd}    set variable    /tmp/ttitrace.pcap >& tmp_0.txt&
    csn.send command
    ...    command=nohup sudo timeout ${timeout}m tcpdump -v -ni ${ute_inet} port ${bts_port} -C ${maxsize} -W ${maxnumber} -w ${tti_cmd}
    ...    connection=${names}
    sleep    3s
    [Teardown]    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=${names}

Setup BTS TTitrace Mirror to remote UTE
    [Arguments]    ${names}=l2stream3_ttitrace
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${SW_BRANCH}=NULL
    ...            ${port_num}=eth0
    ...            ${gnb_ip}=${host_ip}
    ...            ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${tti_component}=L2PS
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='NULL'    Get Sw_Branch Version    gNB_index=${gNB_index}
    ${webserver}=  Create Dictionary    host=${host_ip}    user=${username}    password=${password}    port=443    release=${SW_BRANCH}
    Run Keyword If    "${nr_phy_cell_ids}"=="NULL"    Get PhysCellId Of GNB    gNB_index=${gNB_index}
    ${L2PS}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2Ps    trace_type=Component
    ${L2Lo}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2Lo    trace_type=Component
    ${L2HiRlc}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2HiRlc    trace_type=Component
    ${L2HiPdcp}=    Create Dictionary
    ...    up_sw=L2HiPdcp    trace_type=Component
    @{l2_stream_configurations}=  Create List
    FOR    ${item}    IN    @{tti_component.split(',')}
        append to list    ${l2_stream_configurations}    ${${item}}
    END
    tcpdump.create tcpdump collector
    ...    name=tcpdump_ttitrace    sudo_password=ute
    ...    options=-i ${port_num} udp and src ${gnb_ip} and dst ${ute_ip} and dst port 5678
    L2STREAM3.create_sbts_l2stream_collector
    ...    name=${names}    destination_ip_addr=${ute_ip}    source_ip_addr=${gnb_ip}    collector=tcpdump_ttitrace
    ...    l2_stream_configuration=${l2_stream_configurations}    webservice=${webserver}    dscp=10
    L2STREAM3.Set Suite Alias    alias=${names}
    core.setup_collectors    names=${names}
    log to console    finish admin process for ttitrace setup
