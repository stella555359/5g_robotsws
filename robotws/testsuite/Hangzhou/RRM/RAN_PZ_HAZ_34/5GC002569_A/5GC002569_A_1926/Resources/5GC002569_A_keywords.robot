*** Settings ***
Documentation
...   This is for 2569-A-1926 TA common keywords
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

Resource    ./5GC002569_A_Variables.robot
Variables   ../TestData/5GC002569_A_nidd_parameters.py
Resource    ../../../5GC001911_AA/Resources/5GC001911_AA_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py

*** Keywords ***
Case preparation
    [Documentation]    Author: Cui Lingxue
    ...    1. create case log dir
    ...    2. online modify nidd parameters
    ...    3. verify cell on-air status
    ...    4. prepare IPSL server
    ...    5. setup connections
    [Arguments]    ${dl_port_list_2drb}=${DL_PORT_QCI6_7}    ${dl_port_list_4drb}=${DL_PORT_QCI6_7_8_9}
    ...    ${online_modify_parameters}=${ONLINE_MODIFY_schedulWeight_DEFAULT}    ${timeout}=20 min    ${ipsl_template_dir}=${IPSL_DEFAULT_TEMPLATE}
    ${dl_port_list_2drb}    Convert variable to list type    ${dl_port_list_2drb}
    ${dl_port_list_4drb}    Convert variable to list type    ${dl_port_list_4drb}
    set test variable    ${DL_PORT_LIST_2DRB}    ${dl_port_list_2drb}
    set test variable    ${DL_PORT_LIST_4DRB}    ${dl_port_list_4drb}

    Common case setup
    Cloud DU connect to gnb coam via ssl
#    COAM delete objects via rest api    objects_to_delete_via_api=${ONLINE_DELETE_QCI_PROFILE_3}
    run keyword if    ${online_modify_parameters}!=${NONE}
    ...    coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${online_modify_parameters}
    Wait until keyword succeeds    ${timeout}    20 sec    CU Verify All Cells Status Are Onair
    Wait until cluster is on cell on air status    timeout=${timeout}    is_all_cells_checking_needed=${True}

    IPSL server preparation    ipsl_template_dir=${ipsl_template_dir}    ipsl_config_dir=${IPSL_CONFIG_DIR}
    Connect to EPC APP
    Connect to control pc via cygwin    ue_index=${0}

Case Teardown
    [Documentation]    Author: Cui Lingxue
    ...    1. stop traffic and detach UEs
    ...    2. restore modified nidd parameters
    ...    3. stop IPS server
    ...    4. teardown connections
    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}

    Collect logs in teardown    is_btslog_required=${False}
    connect to IPSL server
    Stop IPSL server process
    disconnect from IPSL server
#    COAM delete objects via rest api    objects_to_delete_via_api=${ONLINE_DELETE_QCI_PROFILE_3}
    Common case teardown

# NIDD modification
Online add new qci profile
    [Arguments]    ${qci_profile}    ${connection}=GNB_OAM
    Cloud DU connect to gnb coam via ssl    connection=${connection}
    COAM add several MOs via rest api    objects_to_add_via_api=${qci_profile}    connection=${connection}

UE attach with x2 log
    [Arguments]    ${log_name}    ${ue_index}=${0}
    Start X2 log capture from eNB    log_name=${log_name}    interface=br1
    UE attach with WA    ue_index=${ue_index}
    ${log_path_ute}    Stop X2 log capture from eNB    log_name=${log_name}
    ${timestamp_attach}    DateTime.get current date    result_format=epoch    exclude_millis=True
    set test variable    ${ATTACH_END_TIME}    ${timestamp_attach}
    [Return]    ${log_path_ute}

UE re-attach with x2 log
    [Arguments]    ${log_name}    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    ${log_path_ute}    UE attach with x2 log    log_name=${log_name}
    [Return]    ${log_path_ute}

Sleep and wait for more drb setup
    [Arguments]    ${log_name}    ${attach_end_time}=${ATTACH_END_TIME}    ${add_drb_delay_time}=${DELAY_OF_DRB_SETUP}
    ${current_timestamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
    ${sleep_time}    evaluate    ${add_drb_delay_time}-(${current_timestamp} - ${attach_end_time}) - 20
    log to console    sleep ${sleep_time} sec to wait for two more DRBs setup.
    Start X2 log capture from eNB    log_name=${log_name}    interface=br1
    sleep    ${sleep_time}s
    ${log_path_ute}    Stop X2 log capture from eNB    log_name=${log_name}
    [Return]    ${log_path_ute}

Start DL traffic and verify tput
    [Arguments]    ${dl_port_list}    ${expected_ratio_list}
    Start DL traffic for multiple DRBs    ue_id=${1}    dl_port_list=${dl_port_list}
    sleep    ${DURATION_FOR_TPUT_STABLE}s
    ${tput_info_dict}    Check tput status via iperf    direction=dl    iperf_port_list=${dl_port_list}    traffic_duration=30
#    run keyword and ignore error    Capture event trace log
    Stop DL traffic for specific UE    dl_port_list=${dl_port_list}
    Verify DL tput ratio between drbs    dl_port_list=${dl_port_list}    tput_dict=${tput_info_dict}    expected_ratio_list=${expected_ratio_list}

# throughput verification
Verify DL tput ratio between drbs
    [Arguments]    ${dl_port_list}    ${tput_dict}    ${expected_ratio_list}
    ${drb_number}    get length    ${dl_port_list}
    FOR    ${i}    IN RANGE    ${drb_number}
        ${dl_port_1}    catenate   SEPARATOR=    port    ${dl_port_list[${i}]}
        ${dl_port_2}    catenate   SEPARATOR=    port    ${dl_port_list[${i+1}]}
        ${drb1_dl_tput}    set variable    ${tput_dict['UE1_DL']['${dl_port_1}']}
        ${drb2_dl_tput}    set variable    ${tput_dict['UE1_DL']['${dl_port_2}']}
        ${expected_ratio}    evaluate    float(${expected_ratio_list[${i}]})/float(${expected_ratio_list[${i+1}]})
        run keyword and continue on failure    Calculate tput ratio and compare with expected ratio
        ...    tput_value1=${drb1_dl_tput}    tput_value2=${drb2_dl_tput}    expected_ratio=${expected_ratio}
        exit for loop if    ${i}==${drb_number}-2
    END

Verify messages for multiple DRBs setup procedure
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${pcap_file_path}    ${qci}
    ${qci}    Convert variable to list type    ${qci}

    ${pdml_template}    set variable    {tshark_path} -r {pcap_file} -Y \"x2ap\" -T pdml
    ${pdml_list}    cap.load_pcap_file    pcap_file=${pcap_file_path}    command_template=${pdml_template}

# SgNBModificationRequest
    ${sgnbMod}    cap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 29) && (x2ap.X2AP_PDU == 0)
    ${qci_list}    cap.get_field_value_by_xpath    pdml_list=${sgnbMod}    xpath=.//x2ap.full_E_RAB_Level_QoS_Parameters_element/x2ap.qCI
    ...    attribute_name=show
    ${timestamp_sgnbMod}    cap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show

# SgNBModificationRequestAcknowledge, RRC Reconfiguration
    ${sgnbModAck}    cap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 29) && (x2ap.X2AP_PDU == 1)
    ${timestamp_sgnbModAck}    cap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show

# SgNBReconfigurationComplete, RRC Reconfiguration Complete
    ${sgnbReconfComp}    cap.filter_packets_by_expression
    ...    filter_expression=(nr-rrc.criticalExtensions == 0) && (x2ap.ResponseInformationSgNBReconfComp == 0)
    ${timestamp_sgnbReconfComp}    cap.get_field_value_by_name
    ...    field_name=frame.time_relative
    ...    attribute_name=show

    run keyword and continue on failure    list_should_contain_sub_list    ${qci_list}    ${qci}
    should be true    ${timestamp_sgnbMod}<${timestamp_sgnbModAck}<${timestamp_sgnbReconfComp}
