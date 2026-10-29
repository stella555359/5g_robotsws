*** Settings ***
Documentation
...   This is for 1911-AA TA common keywords
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

Library     String
Library     OperatingSystem
Library     DateTime
Library     Collections
Resource    ./5GC001911_AA_Variables.robot
Variables   ../TestData/5GC001911_AA_nidd_parameters.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
Library     taf.rfrl.common_resources.python.ssh_common_commands
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/common_event_trace_log_analysis.py
Library     common_event_trace_log_analysis.Event_trace_log_analysis    WITH NAME    event_trace_analysis

*** Keywords ***
Suite preparation
    [Documentation]    Author: Cui Lingxue
    ...    2020-10-27: Add ${EXP_TPUT_DL}. UE dl peak throughput is different on TL412 and TL54. On TL412 is 65M, on TL54 is 40M.
    [Arguments]    ${scf_parameters_list_cu}=${MODIFY_SCF_CU}    ${scf_parameters_list_du}=${MODIFY_SCF_DU}
    ...    ${swconfig_modify}=${MODIFY_SWCONFIG_COMMON}
    COAM Create log directory    is_set_to_test_case_level=${False}
    Enable support for special QCI on eNB

    ${SCF_DEFAULT_FILE_PATH_CU}    Get SCF template path for CU
    Set suite variable    ${SCF_DEFAULT_FILE_PATH_CU}
    Common suite setup preparation
    ...    cu_scf_parameters_list=${scf_parameters_list_cu}    cu_scf_template_path=${SCF_DEFAULT_FILE_PATH_CU}
    ...    du_scf_parameters_list=${scf_parameters_list_du}    du_scf_template_path=${SCF_DEFAULT_FILE_PATH_DU}
    ...    is_pdl_checking_needed=${False}    cu_timeout=20min
    ...    swconfig_template_path=${SWCONFIG_DEFAULT_FILE_PATH}    swconfig_modify=${swconfig_modify}

    ${EXP_TPUT_DL}    set variable if    '${BTS_ID}'=='54'    40    65
    set suite variable    ${EXP_TPUT_DL}
    set suite variable    ${EXP_TPUT_UL}    22

Case preparation
    [Documentation]    Author: Cui Lingxue
    ...    1. create case log dir
    ...    2. online modify nidd parameters
    ...    3. verify cell on-air status
    ...    4. prepare IPSL server
    ...    5. setup connections
    [Arguments]    ${ul_port_list_ue1}    ${dl_port_list_ue1}    ${ul_port_list_ue2}    ${dl_port_list_ue2}
    ...    ${online_modify_parameters}=${ONLINE_MODIFY_schedulWeight_DEFAULT}    ${timeout}=5 min    ${ipsl_template_dir}=${IPSL_DEFAULT_TEMPLATE}
    ...    ${is_x2_log_needed}=${True}
    ${ul_port_list_ue1}    Convert variable to list type    ${ul_port_list_ue1}
    ${dl_port_list_ue1}    Convert variable to list type    ${dl_port_list_ue1}
    ${ul_port_list_ue2}    Convert variable to list type    ${ul_port_list_ue2}
    ${dl_port_list_ue2}    Convert variable to list type    ${dl_port_list_ue2}
    set test variable    ${UL_PORT_LIST_UE1}    ${ul_port_list_ue1}
    set test variable    ${DL_PORT_LIST_UE1}    ${dl_port_list_ue1}
    set test variable    ${UL_PORT_LIST_UE2}    ${ul_port_list_ue2}
    set test variable    ${DL_PORT_LIST_UE2}    ${dl_port_list_ue2}

    Common case setup
    Cloud DU connect to gnb coam via ssl
    run keyword if    ${online_modify_parameters}!=${NONE}
    ...    coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${online_modify_parameters}
    Wait until keyword succeeds    ${timeout}    20 sec    CU Verify All Cells Status Are Onair
    Wait until cluster is on cell on air status    timeout=${timeout}    is_all_cells_checking_needed=${True}

    IPSL server preparation    ipsl_template_dir=${ipsl_template_dir}    ipsl_config_dir=${IPSL_CONFIG_DIR}
    Connect to EPC APP
    Connect to control pc via cygwin    ue_index=${0}
    Wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master
    run keyword if    ${is_x2_log_needed}    Start X2 log capture from eNB    log_name=eNBx2log    interface=br1

Case Teardown
    [Documentation]    Author: Cui Lingxue
    ...    1. stop traffic and detach UEs
    ...    2. restore modified nidd parameters
    ...    3. stop IPS server
    ...    4. teardown connections
    [Arguments]    ${ul_port_list_ue1}=${UL_PORT_LIST_UE1}    ${dl_port_list_ue1}=${DL_PORT_LIST_UE1}
    ...    ${ul_port_list_ue2}=${UL_PORT_LIST_UE2}    ${dl_port_list_ue2}=${DL_PORT_LIST_UE2}
    Stop X2 log capture from eNB    log_name=eNBx2log
    Stop traffic for UE1 and UE2
    Retry commercial ue detach if failed    ue_index=${0}    ue_type=${UE_TYPE}
    Retry commercial ue detach if failed    ue_index=${1}    ue_type=${UE_TYPE}

    connect to IPSL server
    Stop IPSL server process
    disconnect from IPSL server
    Common case teardown

UE attach with WA
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${ue_index}=${0}
    ${attach_status}    run keyword and return status    Retry commercial ue attach if failed    ue_index=${ue_index}    retry_time=${2}
    run keyword if    '${attach_status}'=='False'    run keywords
    ...    ADB Reboot UE    ue_index=${ue_index}    serial_number=${tl.ues[${ue_index}].serial_number}    AND
    ...    sleep    60s    AND
    ...    Retry commercial ue attach if failed    ue_index=${ue_index}    retry_time=${2}

Attach UE1 and UE2
    [Documentation]    Author: Cui Lingxue
    Retry commercial ue attach if failed    ue_index=${1}
    Retry commercial ue attach if failed    ue_index=${0}

Stop traffic for UE1 and UE2
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${ul_port_list_ue1}=${UL_PORT_LIST_UE1}    ${dl_port_list_ue1}=${DL_PORT_LIST_UE1}
    ...            ${ul_port_list_ue2}=${UL_PORT_LIST_UE2}    ${dl_port_list_ue2}=${DL_PORT_LIST_UE2}
    Stop UL&DL traffic for specific UE    ue_id=${1}    ul_port_list=${ul_port_list_ue1}    dl_port_list=${dl_port_list_ue1}
    Stop UL&DL traffic for specific UE    ue_id=${2}    ul_port_list=${ul_port_list_ue2}    dl_port_list=${dl_port_list_ue2}

Start UL&DL traffic for specific UE
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will trigger both ul and dl data transfer for multiple DRBs for specific UE.
    ...    :param ul_port_list: a list contain iperf ul ports for each DRB, eg,[5410 5411 5412]
    ...    :param dl_port_list: a list contain iperf dl ports for each DRB, eg,[41088 41089 41090]
    [Arguments]    ${ue_id}    ${ul_port_list}    ${dl_port_list}    ${ul_throughput}=${UL_THROUGHPUT}    ${dl_throughput}=${DL_THROUGHPUT}
    Start UL traffic for multiple DRBs    ue_id=${ue_id}    ul_port_list=${ul_port_list}    throughput=${ul_throughput}
    Start DL traffic for multiple DRBs    ue_id=${ue_id}    dl_port_list=${dl_port_list}    throughput=${dl_throughput}

Start UL traffic for multiple DRBs
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will trigger ul data transfer for multiple DRBs for specific UE.
    ...    :param ul_port_list: a list contain iperf ul ports for each DRB, eg,[5410 5411 5412]
    [Arguments]    ${ue_id}    ${ul_port_list}    ${throughput}=${UL_THROUGHPUT}
    ${ue_index}    evaluate    ${ue_id} - 1
    FOR    ${ul_port}    IN    @{ul_port_list}
        Wait until keyword succeeds    5X    3 s    power_ue.Start traffic
        ...    ue_type=${UE_TYPE}    direction=ul    throughput=${throughput}
        ...    ue_index=${ue_index}    iperf_port=${ul_port}    iperf_type=via_command
        ...    duration=${TRAFFIC_TIME}    buffer_size=${UL_BUFFER_SIZE}
    END

Start DL traffic for multiple DRBs
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will trigger dl data transfer for multiple DRBs for specific UE.
    ...    :param dl_port_list: a list contain iperf dl ports for each DRB, eg,[41088 41089 41090]
    [Arguments]    ${ue_id}    ${dl_port_list}    ${throughput}=${DL_THROUGHPUT}
    ${ue_index}    evaluate    ${ue_id} - 1
    FOR    ${dl_port}    IN    @{dl_port_list}
        power_ue.Start traffic
        ...    ue_type=${UE_TYPE}    direction=dl    throughput=${throughput}
        ...    ue_index=${ue_index}    iperf_port=${dl_port}
        ...    duration=${TRAFFIC_TIME}    buffer_size=${DL_BUFFER_SIZE}
    END

Stop UL&DL traffic for specific UE
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will stop both ul and dl data transfer for multiple DRBs for specific UE.
    ...    :param ul_port_list: a list contain iperf ul ports for each DRB, eg,[5410 5411 5412]
    ...    :param dl_port_list: a list contain iperf dl ports for each DRB, eg,[41088 41089 41090]
    [Arguments]    ${ue_id}    ${ul_port_list}    ${dl_port_list}
    Stop UL traffic for specific UE    ue_id=${ue_id}    ul_port_list=${ul_port_list}
    Stop DL traffic for specific UE    dl_port_list=${dl_port_list}

Stop DL traffic for specific UE
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will stop dl data transfer for multiple DRBs for specific UE.
    ...    :param dl_port_list: a list contain iperf dl ports for each DRB, eg,[41088 41089 41090]
    [Arguments]    ${dl_port_list}
    Connect to EPC APP
    FOR    ${dl_port}    IN    @{dl_port_list}
        @{filter_conditions}    create list    iperf    ${dl_port}
        ${pid}    Check process existence on APPServer    filter_conditions=${filter_conditions}
        wait until keyword succeeds    5x    200ms    Kill process on APPServer    pid=${pid}
    END

Stop UL traffic for specific UE
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will stop ul data transfer for multiple DRBs for specific UE.
    ...    :param ul_port_list: a list contain iperf ul ports for each DRB, eg,[5410 5411 5412]
    [Arguments]    ${ue_id}    ${ul_port_list}
    ${ue_index}    evaluate    ${ue_id} - 1
    Connect to control pc via cygwin    ue_index=${ue_index}
    FOR    ${ul_port}    IN    @{ul_port_list}
        @{filter_conditions}    create list    iperf    ${ul_port}
        ${pid}    Check process existence on adb device    ue_id=${ue_id}    filter_conditions=${filter_conditions}
        wait until keyword succeeds    5x    200ms    Kill process on adb device    ue_id=${ue_id}    pid=${pid}
    END

Check tput status for UE1 and UE2
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${port_list_ue1}    ${port_list_ue2}    ${direction}
    ${tput_file_ue1}    Check tput status and record to file    iperf_port_list=${port_list_ue1}    direction=${direction}    ue_id=${1}
    ${tput_file_ue2}    Check tput status and record to file    iperf_port_list=${port_list_ue2}    direction=${direction}    ue_id=${2}
    ${tput_file_list}    combine lists    ${tput_file_ue1}    ${tput_file_ue2}
    ${ue_tput_dict}    Get tput info from file    tput_file_list=${tput_file_list}
    log to console    ${ue_tput_dict}
    [Return]    ${ue_tput_dict}

Start UL traffic and get tput info
    [Documentation]    Author: Cui Lingxue
    ...    1. Start UL data transmission for UE1 and UE2
    ...    2. Get UL throughput info via iperf
    ...    3. Stop UL data transmission
    ...    4. Capture bip/eventTrace/x2log during traffic in case fail
    ...    5. Get throughput info from gNB as comparasion
    [Arguments]    ${ul_port_list_ue1}=${UL_PORT_LIST_UE1}    ${ul_port_list_ue2}=${UL_PORT_LIST_UE2}
    ...    ${ue1_ul_throughput}=${UL_THROUGHPUT}    ${ue2_ul_throughput}=${UL_THROUGHPUT}
    ...    ${is_bip_log_needed}=${False}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Start UL traffic for multiple DRBs    ue_id=1    ul_port_list=${ul_port_list_ue1}    throughput=${ue1_ul_throughput}
    Start UL traffic for multiple DRBs    ue_id=2    ul_port_list=${ul_port_list_ue2}    throughput=${ue2_ul_throughput}
    sleep    ${DURATION_FOR_TPUT_STABLE}s
    ${tput_dict_ul}    Check tput status for UE1 and UE2    port_list_ue1=${ul_port_list_ue1}    port_list_ue2=${ul_port_list_ue2}    direction=ul
    run keyword and ignore error    run keyword if    '${is_bip_log_needed}'=='${True}'    Capture BIP log
    [Return]    ${tput_dict_ul}

Start DL traffic and get tput info
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${dl_port_list_ue1}=${DL_PORT_LIST_UE1}    ${dl_port_list_ue2}=${DL_PORT_LIST_UE2}
    ...    ${ue1_dl_throughput}=${DL_THROUGHPUT}    ${ue2_dl_throughput}=${DL_THROUGHPUT}
    ...    ${is_bip_log_needed}=${False}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Start DL traffic for multiple DRBs    ue_id=1    dl_port_list=${dl_port_list_ue1}    throughput=${ue1_dl_throughput}
    Start DL traffic for multiple DRBs    ue_id=2    dl_port_list=${dl_port_list_ue2}    throughput=${ue2_dl_throughput}
    sleep    ${DURATION_FOR_TPUT_STABLE}s
    ${tput_dict_dl}    Check tput status for UE1 and UE2    port_list_ue1=${dl_port_list_ue1}    port_list_ue2=${dl_port_list_ue2}    direction=dl
    run keyword and ignore error    run keyword if    '${is_bip_log_needed}'=='${True}'    Capture BIP log
    [Return]    ${tput_dict_dl}

Calculate tput ratio and compare with expected ratio
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will compare actual tput of 2 UEs or 2 DRBs and verify if match expected ratio.
    ...      10 percent of deviation is allowed.
    [Arguments]    ${tput_value1}    ${tput_value2}    ${expected_ratio}=${10}    ${deviation}=${TPUT_DEVIATION}
    ${min}    evaluate    ${expected_ratio}*(1-${deviation})
    ${max}    evaluate    ${expected_ratio}*(1+${deviation})

    ${tput_ratio}    evaluate    float(${tput_value1})/float(${tput_value2})
    ${is_tput_ratio_as_expected}    evaluate    ${min} <= ${tput_ratio} <= ${max}
    should be true    '${is_tput_ratio_as_expected}'=='True'    Tput ratio is not as expected!

Verify tput ratio of UE1 to UE2 is as expected
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${tput_dict}    ${direction}    ${expected_ratio}=${10}    ${deviation}=${TPUT_DEVIATION}
    ${ue1_tput_sum}    set variable if    '${direction}'=='dl'    ${tput_dict['UE1_DL']['total']}    ${tput_dict['UE1_UL']['total']}
    ${ue2_tput_sum}    set variable if    '${direction}'=='dl'    ${tput_dict['UE2_DL']['total']}    ${tput_dict['UE2_UL']['total']}
    ${is_tput_ratio_as_expected}    run keyword and return status    Calculate tput ratio and compare with expected ratio
    ...    tput_value1=${ue1_tput_sum}    tput_value2=${ue2_tput_sum}    expected_ratio=${expected_ratio}    deviation=${deviation}
    run keyword if    '${is_tput_ratio_as_expected}'=='${False}'    Calculate BLER if throughput checking failed    direction=${direction}
    should be true    ${is_tput_ratio_as_expected}    msg=Tput is not as expected!

Verify UE tput as expected
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${tput_value}    ${expect_tput_value}    ${deviation}=${TPUT_DEVIATION}
    run keyword if    ${expect_tput_value}==${0}    run keywords
    ...    should be true    ${tput_value}<=1    AND   return from keyword

    ${min}    evaluate    ${expect_tput_value}*(1-${deviation})
    ${max}    evaluate    ${expect_tput_value}*(1+${deviation})
    ${is_tput_as_expected}    evaluate    ${min} <= ${tput_value} <= ${max}
    should be true    '${is_tput_as_expected}'=='True'    Tput is not as expected!

Start UL traffic and verify tput as expected
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${ul_port_list_ue1}=${UL_PORT_LIST_UE1}    ${ul_port_list_ue2}=${UL_PORT_LIST_UE2}
    ...    ${ue1_ul_throughput}=${UL_THROUGHPUT}    ${ue2_ul_throughput}=${UL_THROUGHPUT}
    ...    ${ue1_ul_expected_tput}=${UL_THROUGHPUT}    ${ue2_ul_expected_tput}=${UL_THROUGHPUT}
    ...    ${is_bip_log_needed}=${False}
    ${tput_dict_ul}    Start UL traffic and get tput info
    ...                  ul_port_list_ue1=${ul_port_list_ue1}
    ...                  ul_port_list_ue2=${ul_port_list_ue2}
    ...                  ue1_ul_throughput=${ue1_ul_throughput}
    ...                  ue2_ul_throughput=${ue2_ul_throughput}
    ...                  is_bip_log_needed=${is_bip_log_needed}
    ${ue1_ul_tput}    set variable    ${tput_dict_ul['UE1_UL']['total']}
    ${ue2_ul_tput}    set variable    ${tput_dict_ul['UE2_UL']['total']}
    run keyword and continue on failure    Verify UE tput as expected    tput_value=${ue1_ul_tput}    expect_tput_value=${ue1_ul_expected_tput}
    run keyword and continue on failure    Verify UE tput as expected    tput_value=${ue2_ul_tput}    expect_tput_value=${ue2_ul_expected_tput}

Start DL traffic and verify tput as expected
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${dl_port_list_ue1}=${DL_PORT_LIST_UE1}    ${dl_port_list_ue2}=${DL_PORT_LIST_UE2}
    ...    ${ue1_dl_throughput}=${DL_THROUGHPUT}    ${ue2_dl_throughput}=${DL_THROUGHPUT}
    ...    ${ue1_dl_expected_tput}=${DL_THROUGHPUT}    ${ue2_dl_expected_tput}=${DL_THROUGHPUT}
    ${tput_dict_dl}    Start DL traffic and get tput info
    ...                  dl_port_list_ue1=${dl_port_list_ue1}
    ...                  dl_port_list_ue2=${dl_port_list_ue2}
    ...                  ue1_dl_throughput=${ue1_dl_throughput}
    ...                  ue2_dl_throughput=${ue2_dl_throughput}
    ${ue1_dl_tput}    set variable    ${tput_dict_dl['UE1_DL']['total']}
    ${ue2_dl_tput}    set variable    ${tput_dict_dl['UE2_DL']['total']}
    run keyword and continue on failure    Verify UE tput as expected    tput_value=${ue1_dl_tput}    expect_tput_value=${ue1_dl_expected_tput}
    run keyword and continue on failure    Verify UE tput as expected    tput_value=${ue2_dl_tput}    expect_tput_value=${ue2_dl_expected_tput}
    [Return]    ${tput_dict_dl}

Online modify scheduling weights
    [Documentation]    Author: Cui Lingxue
    ...    Modify scheduling weights for one or several DRBs on DU.
    [Arguments]    ${schedulWeight}
    Cloud DU connect to gnb coam via ssl
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${schedulWeight}

Get current value of NIDD paramter on gNB CU
    [Documentation]    Author: Cui Lingxue
    ...    Get the value of a specified NIDD parameter.
    [Arguments]    ${parameter_name}    ${cu_ip}=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ${para_dict}   get_parameters_of_current_plan    parameter_name=${parameter_name}    cu_ip=${cu_ip}
    ${new_para}    evaluate    dict(${para_dict})
    ${para_value}    set variable    ${new_para['items'][0]['parameter']['simple_parameter']['value']}
    [Return]    ${para_value}

Turn on actNonGbrServiceDiff
    [Documentation]    Author: Cui Lingxue
    ...    Turn on flag actNonGbrServiceDiff on CU and DU.
    [Arguments]    ${log_dir}=${TS_CASE_LOG_PATH}
    Log to console    Turning on flag actNonGbrServiceDiff on gNB DU
    Cloud DU connect to gnb coam via ssl
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${TURN_ON_actNonGbrServiceDiff}

    log to console    Turning on flag actNonGbrServiceDiff on gNB CU
    ${NIDD_actNonGbrServiceDiff}    evaluate
    ...    {'MRBTS-${tl.gnbs[0].cu.instance_id}/NRBTS-${tl.gnbs[0].cu.global_bts_id}': {'actNonGbrServiceDiff': 'true'}}
    ${is_enabled}    Get current value of NIDD paramter on gNB CU    parameter_name=actNonGbrServiceDiff
    run keyword if    '${is_enabled}'=='false'    CU Delta Commission update    parameters=${NIDD_actNonGbrServiceDiff}    log_dir=${log_dir}
    ${is_enabled}    Get current value of NIDD paramter on gNB CU    parameter_name=actNonGbrServiceDiff
    should be equal    ${is_enabled}    true

Turn off actNonGbrServiceDiff
    [Documentation]    Author: Cui Lingxue
    ...    Turn off flag actNonGbrServiceDiff on DU.
    [Arguments]    ${log_dir}=${TS_CASE_LOG_PATH}
    Log to console    Turning off flag actNonGbrServiceDiff on gNB DU
    Cloud DU connect to gnb coam via ssl
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${TURN_OFF_actNonGbrServiceDiff}

    log to console    Turning off flag actNonGbrServiceDiff on gNB CU
    ${NIDD_actNonGbrServiceDiff}    evaluate
    ...    {'MRBTS-${tl.gnbs[0].cu.instance_id}/NRBTS-${tl.gnbs[0].cu.global_bts_id}': {'actNonGbrServiceDiff': 'false'}}
    ${is_enabled}    Get current value of NIDD paramter on gNB CU    parameter_name=actNonGbrServiceDiff
    run keyword if    '${is_enabled}'=='true'    CU Delta Commission update    parameters=${NIDD_actNonGbrServiceDiff}    log_dir=${log_dir}
    ${is_enabled}    Get current value of NIDD paramter on gNB CU    parameter_name=actNonGbrServiceDiff
    should be equal    ${is_enabled}    false

Verify messages for multiple DRBs setup in attach procedure
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${pcap_file_path}    ${qci}
    ${qci}    Convert variable to list type    ${qci}

    ${pdml_template}    set variable    {tshark_path} -r {pcap_file} -Y \"x2ap\" -T pdml
    ${pdml_list}    cap.load_pcap_file    pcap_file=${pcap_file_path}    command_template=${pdml_template}

# SgNBAdditionRequest
    ${sgnbAdd}    cap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 0)
    ${qci_list}    cap.get_field_value_by_xpath    pdml_list=${sgnbAdd}    xpath=.//x2ap.full_E_RAB_Level_QoS_Parameters_element/x2ap.qCI
    ...    attribute_name=show
    ${timestamp_sgnbAdd}    cap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show
# SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ${sgnbAddAck}    cap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)
    ${timestamp_sgnbAddAck}    cap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show
# SgNBReconfigurationComplete, RRC Reconfiguration Complete
    ${sgnbReconfComp}    cap.filter_packets_by_expression
    ...    filter_expression=(nr-rrc.criticalExtensions == 0) && (x2ap.ResponseInformationSgNBReconfComp == 0)
    ${timestamp_sgnbReconfComp}    cap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show

    run keyword and continue on failure    list_should_contain_sub_list    ${qci_list}    ${qci}
    should be true    ${timestamp_sgnbAdd}<${timestamp_sgnbAddAck}<${timestamp_sgnbReconfComp}

Get UserSetup times in cprt log
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${log_prefix}    ${local_dir}=${TS_CASE_LOG_PATH}
    ${cprt_location}    Get container location on DU    container_name=CPRT

    run keyword if    '${cprt_location}'=='ASIK Master'    Connect to Common Unit Master    alias=ASIK Master
    ...    ELSE IF    '${cprt_location}'=='ASIK Slave'     Connect to Common Unit Slave     alias=ASIK Slave
    ...    ELSE IF    '${cprt_location}'=='ABIL Master'    Connect to Capacity Unit Master    alias=ABIL Master
    ...    ELSE    FAIL    msg='Couln't find CPRT location.'

    ssh.send_command    command=ls -1 /tmp/node_CPRT00/tmp/startup_cp_rt*    connection=${cprt_location}
    ${file_path}    ssh.read_output    connection=${cprt_location}
    ${file_format}    fetch_from_right    ${file_path}    .
    ${file_format}    strip_string    ${file_format}
    ${file_name}    fetch_from_right    ${file_path}    /
    ${file_name}    strip_string    ${file_name}
    ${local_path}    join path    ${local_dir}    ${log_prefix}_${file_name}
    ${remote_path}    join path    /tmp/node_CPRT00/tmp/    ${file_name}
    ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=${cprt_location}
    ${cmd_uncompress}    set variable    xz -d ${local_path}
    run keyword if    '${file_format}'=='xz'    run    ${cmd_uncompress}
    ${local_path}    join path    ${local_dir}    ${log_prefix}_startup_cp_rt.log
    ${UserSetup}    grep_file    path=${local_path}    pattern=UserSetup
    ${match}    get_line_count    string=${UserSetup}
    [Return]    ${match}

Capture event trace log
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${capture_duration}=3s    ${local_dir}=${TS_CASE_LOG_PATH}
    TTI_Trace.Start TTI trace log capturing
    sleep    ${capture_duration}
    TTI_Trace.Stop TTI trace log capturing
    &{event_trace}    TTI_Trace.Convert TTI trace log and download combined csv logs to test pc    local_path=${local_dir}
    [Return]    ${event_trace}

Capture BIP log
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    Connect to Common Unit Master
    Bip Capture with gnbMirroring scripts with retry
    Stop BIP capture on ASIK if needed and download BIP Logs to testPC

Get tput info from GNB with connection
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${duration}=10s
    Connect to Common Unit Master
    run keyword and ignore error    Get tput info from GNB    duration=${duration}
    Cloud DU connect to gnb coam via ssl

Tput ratio of UE1 to UE2 should not be as expected
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${tput_dict}    ${expected_ratio}    ${direction}
    ${is_tput_as_exp_ratio}    run keyword and return status    Verify tput ratio of UE1 to UE2 is as expected
    ...    tput_dict=${tput_dict}    direction=${direction}    expected_ratio=${expected_ratio}
    run keyword and continue on failure    should not be true    ${is_tput_as_exp_ratio}

L3call and verify tput
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    [Arguments]    ${expected_ratio}    ${is_bip_log_needed}=${False}
    Attach UE1 and UE2
    ${tput_dict_ul}    Start UL traffic and get tput info    is_bip_log_needed=${is_bip_log_needed}
    ${tput_dict_dl}    Start DL traffic and get tput info
    Verify tput ratio of UE1 to UE2 is as expected    tput_dict=${tput_dict_ul}    direction=ul    expected_ratio=${expected_ratio}
    Verify tput ratio of UE1 to UE2 is as expected    tput_dict=${tput_dict_dl}    direction=dl    expected_ratio=${expected_ratio}
    [Return]    ${tput_dict_ul}    ${tput_dict_dl}

Get container location on DU
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    ...    Description: look for container location on ASIK Master, ASIK Slave, ABIL Master and ABIL Slave.
    ...    [Limitation] Only verified on cloud DU, might not working on classical. ASIL+ABIO deployment is not yet adapted.
    ...    :param ${container_name}: a description name of container, eg. CPRT, UPUE... not case sensitive.
    ...    :param ${hw_slot}: location of first ABIL, 1 means left side of AMIA, 5 means right side of AMIA.
    ...    :return: board name will be returned, eg. ASIK Master, ABIL Master...
    [Arguments]    ${container_name}=CPRT    ${hw_slot}=${1}
    Connect to Common Unit Master    alias=ASIK Master
    @{local_node_id_list}    run keyword if    ${hw_slot}==${1}
    ...    create list    0x1011    0x1021    0x123D
    ...    ELSE IF    ${hw_slot}==${5}    create list    0x2011    0x2021    0x223D
    ...    ELSE    FAIL    msg='${hw_slot}' should only be '${1}' or '${5}', other value is not supported!

    FOR    ${local_node_id}    IN    @{local_node_id_list}
        ${cmd_list_containers}    catenate    export PYTHONPATH=/opt/hwmt/python;python3 /opt/hwmt/python/hwapi/SupervisorS.py
        ...      -n ${local_node_id} -o list_cbts
        ${container_lilst}    csn.execute    command=${cmd_list_containers}    connection=ASIK Master
        ${is_container_exist}    run keyword and return status    should contain    ${container_lilst}    ${container_name}    ignore_case=True
        ${container_locate_local_node_id}    set variable if    ${is_container_exist}    ${local_node_id}    Container not found
        exit for loop if    ${is_container_exist}
    END
    should be true    ${is_container_exist}    msg=Container ${container_name} is not found on DU!

    ${container_location}    set variable if    '${container_locate_local_node_id}'=='0x1011'    ASIK Master    ${None}
    ${container_location}    set variable if    '${container_locate_local_node_id}'=='0x2011'    ASIK Master    ${container_location}
    ${container_location}    set variable if    '${container_locate_local_node_id}'=='0x1021'    ASIK Slave     ${container_location}
    ${container_location}    set variable if    '${container_locate_local_node_id}'=='0x2021'    ASIK Slave     ${container_location}
    ${container_location}    set variable if    '${container_locate_local_node_id}'=='0x123D'    ABIL Master    ${container_location}
    ${container_location}    set variable if    '${container_locate_local_node_id}'=='0x223D'    ABIL Master    ${container_location}
    [Return]    ${container_location}
    [Teardown]    csn.disconnect    connection=ASIK Master

Enable support for special QCI on eNB
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    ...    Description: Modify NIDD parameters on eNB to support special QCI like 69, 70...
    ...                 Parameters are:
    ...                 MRBTS-400/LNBTS-400/LNBTS_FDD-0
    ...                     - actPubSafetyBearers
    ...                     - actConvVoice
    ...                 MRBTS-400/LNBTS-400
    ...                     - actEnhAcAndGbrServices
    ...    **NOTE**: Modify actConvVoice will result in temprary cell failure because cell will be lock/unlock.
    ...              Modify actEnhAcAndGbrServices will cause LTE RAT reset.
    [Arguments]    ${enb_index}=${0}    ${connection}=ENB_OAM    ${log_path}=${SUITE_LOG_PATH}
    ${enable_actPubSafetyBearers}    create dictionary    dist_name=${LTE_NAME}/LNBTS_FDD-0    parameter=actPubSafetyBearers    value=true
    ${enable_actConvVoice}    create dictionary    dist_name=${LTE_NAME}/LNBTS_FDD-0    parameter=actConvVoice    value=true
    ${enable_actEnhAcAndGbrServices}    create dictionary    dist_name=${LTE_NAME}    parameter=actEnhAcAndGbrServices    value=true
    ${parameter_list}    create list    ${enable_actPubSafetyBearers}    ${enable_actConvVoice}    ${enable_actEnhAcAndGbrServices}

    Cloud DU connect to gnb coam via ssl    connection=${connection}
    ...    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${parameter_list}
    ...    connection=${connection}    timeout=${360}
    coam.get_current_scf_file    local_dir_path=${log_path}    file_name=SCF_eNB_${tl.enbs[${enb_index}].instance_id}.xml
    ...    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

UE2 TPUT should increase by amout of UE1 decrease
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    ...    Compare UE2 tput increase with UE1 tput decrease, should be same.
    ...    :${deviation}: allowed buffer range
    [Arguments]    ${previous_tput}    ${current_tput}    ${expected_increase}    ${deviation}=${TPUT_DEVIATION}
    ${min}    evaluate    ${previous_tput} + ${expected_increase}*(1-${deviation})
    ${max}    evaluate    ${previous_tput} + ${expected_increase}*(1+${deviation})
    ${is_tput_as_expected}    evaluate    ${min} <= ${current_tput} <= ${max}
    should be true    '${is_tput_as_expected}'=='True'    Tput is not as expected!

Verify UE tput change after traffic mode change
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    ...    Use 2 criterias to evaluate UE1 and UE2 tput. The verification pass if either of the criterias is meet.
    ...    CRITERIA 1: UE1 tput should be ${ue1_expected_tput}, UE2 tput should be ${ue2_expected_tput}.
    ...    CREITRIA 2: Tput increase of UE2 tput should be same as UE1 tput decrease ${expected_increase} with allowed buffer range ${deviation}.
    [Arguments]    ${direction}    ${tput_dict}    ${ue1_expected_tput}    ${ue2_expected_tput}    ${ue2_previous_tput}    ${expected_increase}
    ...    ${deviation}=${TPUT_DEVIATION}
    ${ue1_tput}    run keyword if    '${direction}'=='ul'    set variable    ${tput_dict['UE1_UL']['total']}
    ...    ELSE IF    '${direction}'=='dl'    set variable    ${tput_dict['UE1_DL']['total']}
    ...    ELSE    fail    msg='${direction}' should be 'ul' or 'dl', other values are not supported.
    ${ue2_tput}    run keyword if    '${direction}'=='ul'    set variable    ${tput_dict['UE2_UL']['total']}
    ...    ELSE IF    '${direction}'=='dl'    set variable    ${tput_dict['UE2_DL']['total']}
    ...    ELSE    fail    msg='${direction}' should be 'ul' or 'dl', other values are not supported.

    ${criteria1_1}    run keyword and return status    Verify UE tput as expected    tput_value=${ue1_tput}    expect_tput_value=${ue1_expected_tput}
    ${criteria1_2}    run keyword and return status    Verify UE tput as expected    tput_value=${ue2_tput}    expect_tput_value=${ue2_expected_tput}
    ${criteria2}      run keyword and return status    UE2 TPUT should increase by amout of UE1 decrease    previous_tput=${ue2_previous_tput}
    ...    current_tput=${ue2_tput}    expected_increase=${expected_increase}    deviation=${deviation}
    ${is_tput_as_expected}    evaluate    (${criteria1_1} and ${criteria1_2}) or ${criteria2}
    run keyword if    '${is_tput_as_expected}'=='${False}'    Calculate BLER if throughput checking failed    direction=${direction}
    should be true    '${is_tput_as_expected}'=='True'    msg=Tput is not as expected!

Set tput related test varialbes
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    ...    Calculate expected tput value for UE1 and UE2 for the second time data transmission. And set to test variables.
    ...    These variables will be to test level:
    ...        ${EXP_TPUT_DL_ALL}
    ...        ${EXP_TPUT_UL_ALL}
    ...        ${DECREASE_TPUT_DL_UE1}
    ...        ${DECREASE_TPUT_UL_UE1}
    ...        ${UE1_EXP_TPUT_DL}
    ...        ${UE1_EXP_TPUT_UL}
    ...        ${UE2_EXP_TPUT_DL}
    ...        ${UE2_EXP_TPUT_UL}
    [Arguments]    ${first_time_tput_dict_dl}    ${first_time_tput_dict_ul}    ${second_time_tput_dict_dl}    ${second_time_tput_dict_ul}
    ...    ${drb_number}=${1}
    ${TPUT_DL_UE1}    set variable    ${first_time_tput_dict_dl['UE1_DL']['total']}
    ${TPUT_DL_UE2}    set variable    ${first_time_tput_dict_dl['UE2_DL']['total']}
    ${TPUT_UL_UE1}    set variable    ${first_time_tput_dict_ul['UE1_UL']['total']}
    ${TPUT_UL_UE2}    set variable    ${first_time_tput_dict_ul['UE2_UL']['total']}

    ${EXP_TPUT_DL_ALL}    evaluate    ${TPUT_DL_UE1} + ${TPUT_DL_UE2}
    ${EXP_TPUT_UL_ALL}    evaluate    ${TPUT_UL_UE1} + ${TPUT_UL_UE2}
    ${DECREASE_TPUT_DL_UE1}    evaluate    ${TPUT_DL_UE1} - ${second_time_tput_dict_dl['UE1_DL']['total']}
    ${DECREASE_TPUT_UL_UE1}    evaluate    ${TPUT_UL_UE1} - ${second_time_tput_dict_ul['UE1_UL']['total']}

    ${UE1_EXP_TPUT_DL}    evaluate    ${SMALL_DATA_DL}*${drb_number}
    ${UE1_EXP_TPUT_UL}    evaluate    ${SMALL_DATA_UL}*${drb_number}
    ${UE2_EXP_TPUT_DL}    evaluate    ${EXP_TPUT_DL_ALL} - ${UE1_EXP_TPUT_DL}
    ${UE2_EXP_TPUT_UL}    evaluate    ${EXP_TPUT_UL_ALL} - ${UE1_EXP_TPUT_UL}
    set test variable    ${EXP_TPUT_DL_ALL}
    set test variable    ${EXP_TPUT_UL_ALL}
    set test variable    ${DECREASE_TPUT_DL_UE1}
    set test variable    ${DECREASE_TPUT_UL_UE1}
    set test variable    ${UE1_EXP_TPUT_DL}
    set test variable    ${UE1_EXP_TPUT_UL}
    set test variable    ${UE2_EXP_TPUT_DL}
    set test variable    ${UE2_EXP_TPUT_UL}

Calculate BLER if throughput checking failed
    [Documentation]    Author: Cui Lingxue    MMW_SG1
    ...    If throughput checking failed, capture event trace on gNB for ${capture_duration} seconds, calculate BLER from event trace.
    [Arguments]    ${direction}    ${capture_duration}=3s    ${local_dir}=${TS_CASE_LOG_PATH}
    run keyword and ignore error    Get tput info from GNB with connection
    ${event_trace}    Capture event trace log    capture_duration=${capture_duration}    local_dir=${local_dir}
    ${dict_blers}    run keyword if    '${direction}'=='ul'    event_trace_analysis.calculate_bler    file_path=${EVENT_TRACE['UL']}
    ...    ELSE IF    '${direction}'=='dl'    event_trace_analysis.calculate_bler    file_path=${EVENT_TRACE['DL']}
    ...    ELSE    fail    msg='${direction}' should be 'ul' or 'dl', other values are not supported.
    [Return]    ${dict_blers}
