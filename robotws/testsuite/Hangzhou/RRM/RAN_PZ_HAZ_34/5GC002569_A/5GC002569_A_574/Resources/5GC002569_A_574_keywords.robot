*** Settings ***
Documentation
...   This is for 2569-A-574 TA common keywords
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

Resource    ./5GC002569_A_574_variables.robot
Variables   ../TestData/5GC002569_A_574_nidd_parameters.py
Variables   ../TestData/5GC002569_A_574_cplane_msg_checkpoints.py
Resource    ../../../5GC001912_EB/Resources/5GC001912_EB_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/pm_counter.robot

*** Keywords ***
Attach and trigger eNB measurement report
    [Arguments]    ${cpif_log_name}    ${sgw_relocation}=${False}    ${is_need_to_download_file}=${True}
    ...    ${log_path}=${TS_CASE_LOG_PATH}
    Start X2 log capture from eNB    enb_index=${0}    log_name=eNB251_x2log   interface=br1    alias=ENB251
    Start X2 log capture from eNB    enb_index=${1}    log_name=eNB48_x2log    interface=br1    alias=ENB48
    Start X2 log capture on gNB CU    x2_log_name=${cpif_log_name}_x2
    Start F1 log capture on gNB CU    f1_log_name=${cpif_log_name}_f1

    ${e500_script_path}    set variable if    ${sgw_relocation}    ${E500_SCRIPTS_SGW_CHANGE}    ${E500_SCRIPTS_BASE}
    Cobham retry ue attach if failed    e500_script_path=${e500_script_path}
    ${filepath_on_cpc}    run keyword if    ${is_need_to_download_file}    Download file from FTP server to control PC using sftp
    Trigger eNB A3 measurement report
    run keyword if    ${is_need_to_download_file}    set test variable    ${PATH_OF_DOWNLOADED_FILE}    ${filepath_on_cpc}

    ${x2_log_path}    Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_x2
    ${f1_log_path}    Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_f1
    ${merged_log_path}    set variable    ${log_path}/${cpif_log_name}.pcap
    run    mergecap -w ${merged_log_path} ${x2_log_path} ${f1_log_path}
    [Return]    ${merged_log_path}
    [Teardown]    run keyword and ignore error  run keywords    Stop tcpdump log collection    tcpdump_collector_name=${cpif_log_name}_x2    AND
    ...    Stop tcpdump log collection    tcpdump_collector_name=${cpif_log_name}_f1    AND
    ...    Stop X2 log on eNB and rename downloaded file

Trigger eNB A3 measurement report
    [Arguments]    ${a3_meas_id}=${eNB_A3_MEAS_ID}    ${serving_cell_rsrp}=40    ${neigh_cell_rsrp}=70    ${neigh_cell_pci}=48
    ...    ${neigh_cell_tac}=6666    ${tm500_alias}=e500
    ${serving_cell_rsrq}    set variable    19
    ${neigh_cell_rsrq}      set variable    19
    ${plmn}                 set variable    26203
    ${cmd_a3_mr}    catenate    forw mte RrcAptTriggerMeasEvent 1 ${a3_meas_id} 0 [${serving_cell_rsrp}] [${serving_cell_rsrq}]
    ...    [1(1{${neigh_cell_pci} [${plmn} ${neigh_cell_pci} ${neigh_cell_tac} []] [${neigh_cell_rsrp}] [${neigh_cell_rsrq}] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    Wait until keyword succeeds    10s    200ms    match pattern in response    pattern=RRC Handover Complete
    ...    response=${response}    e500_alias=${tm500_alias}
    sleep    5s

Verify msgs of inter-eNB HO
    [Arguments]    ${msg_checkpoint}    ${detail_ie_filters}    ${log_path_pcap}=${CPIF_LOG}
    ${log_path_pdml}    Convert pcap to pdml    log_path_pcap=${log_path_pcap}    filter=f1ap||x2ap||e1ap
    ${packet_list}    run keyword and continue on failure    verify_msg_type_and_seq_in_pdml
    ...    log_path_pdml=${log_path_pdml}    filters=${msg_checkpoint}
    verify_detail_msg_ie_in_packet    packet_list=${packet_list}  detail_ie_filters=${detail_ie_filters}

Verify eNB msgs of inter-eNB HO
    [Arguments]    ${msg_checkpoint}    ${detail_ie_filters}    ${log_path_pcap}
    ${log_path_pdml}    Convert pcap to pdml    log_path_pcap=${log_path_pcap}    filter=s1ap||x2ap
    ${packet_list}    verify_msg_type_and_seq_in_pdml
    ...    log_path_pdml=${log_path_pdml}    filters=${msg_checkpoint}
    run keyword if    ${detail_ie_filters}!=${None}
    ...    verify_detail_msg_ie_in_packet    packet_list=${packet_list}  detail_ie_filters=${detail_ie_filters}

Verify S1U address changed after inter-eNB inter-SGW HO
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${sgnbAddReq}    cap.filter_packets_by_expression
    ...    filter_expression=(x2ap.SGNB_Addition_Trigger_Ind == 1) && (x2ap.X2AP_PDU == 0) && (x2ap.procedureCode == 27)
    ${sgnbModReq}    cap.filter_packets_by_expression
    ...    filter_expression=(x2ap.X2AP_PDU == 0) && (x2ap.procedureCode == 29) && (x2ap.resource_configuration == 0)
    ${old_s1u}    cap.get_field_value_by_xpath    pdml_list=${sgnbAddReq}
    ...    xpath=.//x2ap.s1_UL_GTPtunnelEndpoint_element/x2ap.transportLayerAddress/x2ap.transportLayerAddressIPv4
    ...    attribute_name=show
    ${new_s1u}    cap.get_field_value_by_xpath    pdml_list=${sgnbModReq}
    ...    xpath=.//x2ap.transportLayerAddressIPv4
    ...    attribute_name=show
    should not be equal    ${old_s1u}    ${new_s1u}

Verify counter value match expectation
    [Arguments]    ${counter_id_dict}
    @{counter_id_list}    get_dictionary_keys    ${counter_id_dict}
    &{counter_value_dict}    create dictionary
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${counter_id_dict['${counter_id}'][0]}    counter_id=${counter_id}
        run keyword and continue on failure    should be equal as integers    ${counter_value[0]}    1
        set_to_dictionary    ${counter_value_dict}    ${counter_id}=${counter_value}
    END
    [Return]    ${counter_value_dict}

Stop X2 log on eNB and rename downloaded file
    [Documentation]    Author: Cui Lingxue    5G_PZ_MMW_HZ_1_SG
    ...    Description: Stop tcpdump log capturing and rename it and move it to folder ${TS_LOG_PATH_BASE}.
    ...    log path on UTE set as test variable.
    ${log_path_enb251}    Stop X2 log capture from eNB    log_name=eNB251_x2log    alias=ENB251
    ${log_path_enb48}     Stop X2 log capture from eNB    log_name=eNB48_x2log     alias=ENB48
    ${log_path_enb251_renamed}    rename downloaded file    log_path=${log_path_enb251}
    ${log_path_enb48_renamed}     rename downloaded file    log_path=${log_path_enb48}
    set test variable    ${ENB251_X2LOG}    ${log_path_enb251_renamed}
    set test variable    ${ENB48_X2LOG}     ${log_path_enb48_renamed}

