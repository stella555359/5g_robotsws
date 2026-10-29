*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1

Variables   ./../TestData/NIDD_modify.py
Resource    ./5GC001305_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/NIDD_modify_merge_scf.py

*** Keywords ***
Modify prachConfigurationIndex via rest api and wait onair
    [Documentation]   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    [Arguments]     ${prachConfigurationIndex}    ${timeout_restapi}=3 min    ${timeout_onair}=3 min    ${connection}=GNB_OAM
    ${nidd_prachConfigurationIndex1}    evaluate
    ...    [dict(dist_name='${NR_CELL_NAME}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
    ${nidd_prachConfigurationIndex2}    evaluate
    ...    [dict(dist_name='${NR_CELL_NAME2}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
    ${nidd_prachConfigurationIndex3}    evaluate
    ...    [dict(dist_name='${NR_CELL_NAME3}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
    ${nidd_prachConfigurationIndex4}    evaluate
    ...    [dict(dist_name='${NR_CELL_NAME4}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
    ${nidd_prachConfigurationIndex} =  Combine Lists  ${nidd_prachConfigurationIndex1}  ${nidd_prachConfigurationIndex2}
    ...    ${nidd_prachConfigurationIndex3}  ${nidd_prachConfigurationIndex4}

    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${nidd_prachConfigurationIndex}    timeout=${timeout_restapi}    connection=${connection}
    ${idx}    create list   11
    Wait until cluster is on cell on air status    timeout=${timeout_onair}    list_cell_index=${idx}     list_cell_group_index=1

Modify NIDD via rest api and wait onair
    [Documentation]   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    [Arguments]     ${parameters}    ${timeout_restapi}=3 min    ${timeout_onair}=3 min    ${connection}=GNB_OAM
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameters}    timeout=${timeout_restapi}    connection=${connection}
    ${idx}    create list   11
    Wait until cluster is on cell on air status    timeout=${timeout_onair}     list_cell_index=${idx}     list_cell_group_index=1

UE attach and check logs
    [Documentation]     Author: HuangMin
    ...    compare with keyword "Call case with Commercial UE and record throughput info", this keyword check tput via power ue
    ...    1. start X2 log capture
    ...    2. attach ue
    ...    3. stop X2 log capture and check logs
    ...    4. start traffic
    ...    5. check throughput
    ...    6. UE detach
    ...   :param cell_id: global cell id, can be 2
    ...   :param dl_tput: Start traffic of DL, Unit in Mbps.
    ...   :param ul_tput: Start traffic of UL, Unit in Mbps.
    ...   :param exp_ul: expected tput of UL, Unit in Mbps.
    ...   :param exp_dl: expected tput of DL, Unit in Mbps.
    [Arguments]    ${customized_log_name}=tput_pic     ${cell_id}=11    ${dl_tput}=50M    ${ul_tput}=50M    ${exp_ul}=1
    ...    ${exp_dl}=1    ${tput_check_duration}=60s
    ...    ${ignore_time}=30s    ${actCarrierAggregation}=${False}    ${data_transfer_direction}=both
    ...    ${traffic_duration}=200s    ${protocol}=udp    ${process_num}=${3}    ${seg_size}=1350
    ...    ${iperf_ul_port}=${None}    ${iperf_dl_port}=${None}    ${buffer_size}=1400B
    ...    ${iperf_type_ul}=via_command    ${window}=16M     ${log_name}=enb_x2

    ...    ${ue_type}=${UE_TYPE}    ${retry_time}=3    ${ue_index}=${0}    ${prepare_ue_needed}=${False}    ${4G_check}=${None}
    ...    ${attach_check_type}=GNB_log    ${duration}=5s    ${detach_request}=${False}    ${connection}=GNB_OAM    ${is_ue_reboot}=${False}
    ...    ${target_avg_percent}=0.95    ${filter}=L2Lo

    Start X2 log capture from eNB    log_name=${log_name}

    Run keyword and continue on failure    Retry commercial ue attach if failed     ue_type=${ue_type}    retry_time=${retry_time}
    ...    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}    attach_check_type=${attach_check_type}
    ...    duration=${duration}   detach_request=${detach_request}    connection=${connection}    is_ue_reboot=${is_ue_reboot}

    ${enb_x2_log}    Stop X2 log capture from eNB    log_name=${log_name}
    Check rach configuration from x2 log    x2_log=${enb_x2_log}

    Start data transfer based on direction    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${traffic_duration}    protocol=${protocol}
    ...    process_num=${process_num}    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}    seg_size=${seg_size}
    ...    iperf_ul=${iperf_ul_port}    iperf_dl=${iperf_dl_port}    buffer_size=${buffer_size}
    ...    iperf_type_ul=${iperf_type_ul}    window=${window}
    ${tput_log}    power_ue.Collect Tput     ue_type=${ue_type}    duration=${tput_check_duration}    ignore_time=${ignore_time}   filter=${filter}
    Check tput via power UE    cell_id=${cell_id}    exp_ul=${exp_ul}    exp_dl=${exp_dl}    log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}   customized_log_name=${customized_log_name}

    Run keyword and ignore error    Close iperf progress

    power_ue.ue detach    ue_type=${ue_type}    ue_index=${ue_index}


Check rach configuration from x2 log
    [Documentation]   author: Wang Yixiang
    ...    check rach configuration in RRC Reconfiguration (NSA) IE: rach-ConfigGeneric
    [Arguments]     ${x2_log}
    cap.load_pcap_file    pcap_file=${x2_log}    command_template=${PDML_CONVERT_X2AP_TEMPLATE}
    ...    tshark_path=${TSHARK_PATH}    alias=pcap_ue_id
    ${rrcReconfig}    cap.filter_packets_by_expression
    ...    filter_expression=x2ap.procedureCode == 27   pcap_parser=pcap_ue_id
    ${prachConfigurationIndex}    cap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.rach_ConfigGeneric_element/nr-rrc.prach_ConfigurationIndex
    ...    attribute_name=show  pcap_parser=pcap_ue_id
    ${msg1FrequencyStart}    cap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.rach_ConfigGeneric_element/nr-rrc.msg1_FrequencyStart
    ...    attribute_name=show  pcap_parser=pcap_ue_id
    ${zeroCorrelationZoneConfig}    cap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.rach_ConfigGeneric_element/nr-rrc.zeroCorrelationZoneConfig
    ...    attribute_name=show  pcap_parser=pcap_ue_id
    ${raResponseWindow}    cap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.rach_ConfigGeneric_element/nr-rrc.ra_ResponseWindow
    ...    attribute_name=show  pcap_parser=pcap_ue_id
    ${nbrOfSsbPerRachOccasion}    cap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.ssb_perRACH_OccasionAndCB_PreamblesPerSSB/nr-rrc.one
    ...    attribute_name=showname  pcap_parser=pcap_ue_id
    ${prachRootSequenceIndex}    cap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.prach_RootSequenceIndex/nr-rrc.l139
    ...    attribute_name=show  pcap_parser=pcap_ue_id

    ${prachConfigurationIndex_exp}    Get NIDD value via rest api   parameter=prachConfigurationIndex    dist_name=${NR_CELL_NAME}
    ${msg1FrequencyStart_exp}    Get NIDD value via rest api   parameter=msg1FrequencyStart    dist_name=${NR_CELL_NAME}
    ${zeroCorrelationZoneConfig_exp}    Get NIDD value via rest api   parameter=zeroCorrelationZoneConfig    dist_name=${NR_CELL_NAME}
    ${raResponseWindow_exp}    Get NIDD value via rest api   parameter=raResponseWindow    dist_name=${NR_CELL_NAME}
    ${nbrOfSsbPerRachOccasion_exp}    Get NIDD value via rest api   parameter=nbrOfSsbPerRachOccasion    dist_name=${NR_CELL_NAME}
    ${prachRootSequenceIndex_exp}    Get NIDD value via rest api   parameter=prachRootSequenceIndex    dist_name=${NR_CELL_NAME}
    ${raResponseWindow_exp}    set variable if    '${raResponseWindow_exp}'=='sl80'   7   None

#    WA_for_ssh_issue

    run keyword and continue on failure    should be equal as strings    ${prachConfigurationIndex}[0]   ${prachConfigurationIndex_exp}
    run keyword and continue on failure    should be equal as strings    ${msg1FrequencyStart}[0]    ${msg1FrequencyStart_exp}
    run keyword and continue on failure    should be equal as strings    ${zeroCorrelationZoneConfig}[0]    ${zeroCorrelationZoneConfig_exp}
    run keyword and continue on failure    should be equal as strings    ${raResponseWindow}[0]    ${raResponseWindow_exp}
    run keyword and continue on failure    should contain    ${nbrOfSsbPerRachOccasion}[0]    ${nbrOfSsbPerRachOccasion_exp}
    run keyword and continue on failure    should be equal as strings    ${prachRootSequenceIndex}[0]    ${prachRootSequenceIndex_exp}



