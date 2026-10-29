*** Settings ***
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149_cm2/Resources/CB012149_common_keyword.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02


*** Variables ***
${bip_srs_command_template_pci504}    {tshark_path} -r {pcap_file} -Y "uldata_srsreceivereq and 3gpp.subcellid == 17" -T pdml
${bip_srs_command_template_pci503}    {tshark_path} -r {pcap_file} -Y "uldata_srsreceivereq and 3gpp.subcellid == 9" -T pdml
${bip_dlpdsch_command_template}    {tshark_path} -r {pcap_file} -Y "dldata_pdschsendreql1sw" -T pdml
${bip_srs_command_template_iwk}    {tshark_path} -r {pcap_file} -Y "uldata_srsreceivereq and 3gpp.subcellid == 12" -T pdml

${rrcreconfig_srs_filter_expression}    nr-rrc.usage==1 and nr-rrc.usage ==3
${rrcreconfig_c_srs_name}    nr-rrc.c_SRS
${rrcreconfig_srs_name}    nr-rrc.usage

${srsRtBfEnable_filter}    UlData_srsReceiveReqSubcell_t.srsRtBfEnable==True
${srsBmEnable_filter}    UlData_srsReceiveReqSubcell_t.srsBmEnable==True
${RtBf_symbolPosition_name}    UlData_srsRtBfReceiveReqUes_t.symbolPosition
${Bm_symbolPosition_name}    UlData_srsBmResource_t.symbolPosition

${rat0Bitmap_tdd_filter}    DlData_PdschGrantL1sw.rat0Bitmap == 0 and 3gpp.subcellid == 12
${rat0Bitmap_fdd_filter}    DlData_PdschGrantL1sw.rat0Bitmap == 0 and 3gpp.subcellid == 18
${rat0Bitmap_name}    DlData_PdschGrantL1sw.rat0Bitmap

${ue_support_ChipsetAndRanInfoExchange}    nr-rrc.mAC_ParametersCommon.dummy == 0
${ue_chipset_info}    nr-rrc.mIMO_ParametersPerBand.dummy4_element
${ue_chipset_info_buburstLength}    .//nr-rrc.mIMO_ParametersPerBand.dummy4_element/nr-rrc.burstLength
${ue_chipset_info_maxSimultaneousResourceSetsPerCC}    .//nr-rrc.mIMO_ParametersPerBand.dummy4_element/nr-rrc.maxSimultaneousResourceSetsPerCC
${ue_chipset_info_maxConfiguredResourceSetsPerCC}    nr-rrc.maxConfiguredResourceSetsPerCC
${ue_chipset_info_maxConfiguredResourceSetsAllCC}    .//nr-rrc.mIMO_ParametersPerBand.dummy4_element/nr-rrc.maxConfiguredResourceSetsAllCC
${ue_chipset_info_filter}    \"nr-rrc.mAC_ParametersCommon.dummy == 0 and
...                          nr-rrc.maxConfiguredResourceSetsPerCC and
...                          nr-rrc.mIMO_ParametersPerBand.dummy4_element\"

${uldata_puschreceivereq_layer1_filter}    \"UlData_puschReceiveReqGrant_t.numOfLayers == 1 and
...                                          3gpp.subcellid == 12\"
${uldata_puschreceivereq_layer2_filter}    \"UlData_puschReceiveReqGrant_t.numOfLayers == 2 and
...                                          3gpp.subcellid == 12\"

*** Keywords ***
Capture TTitrace Log only
    [Documentation]    Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=3    #${filter}=None    ${by_filter}=${False}    ${except_filter}=${False}
    ...    ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming    #${format_tti_log}=${False}
    TTI_logs_Capture.Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    TTI_logs_Capture.Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}
#    ${csv_file_path}    TTI_logs_Capture.Decode Ttitrace Logs    collector_names=${collector_names}    by_filter=${by_filter}
#    ...    except_filter=${except_filter}    filter=${filter}    format_tti_log=${format_tti_log}
#    [Return]    ${csv_file_path}
    [Return]    ${log_dir}

UE Start traffic and Get CP-IF BIP TTI log
    [Arguments]    ${ue_index}=${0}    ${du_index}=${0}    ${apn}=dxdata2    ${cellid}=5    ${scellid}=${None}
    ...            ${ul_target_tdd}=${UL_THROUGHPUT_TDD}
    ...            ${dl_target_tdd}=${DL_THROUGHPUT_TDD}
    ...            ${ul_target_fdd}=${UL_THROUGHPUT_FDD}
    ...            ${dl_target_fdd}=${DL_THROUGHPUT_FDD}
    ...            ${need_TTI}=${False}
	...            ${wireshark_capture_interface}=sctp or port 49148 -p -i any -s 0
    #...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
    #...            ${wireshark_capture_interface}=-p -i any '((sctp) and ${filter_ports})' -s 0
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Connect to Common Unit Master     alias=ASIK Master
    Start CP-IF Log Collection     tcpdump_collector_name=attach_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=${du_index}
    ...                            options=${wireshark_capture_interface}
    #...                            gnb_index=${nr_bts_id}
#    Start capture F1AP log   gnb_id=${0}    tcpdump_collector_name=antennaSwitch_${timestamp}
    UE start attach    ue_index=${ue_index}
    ${cpif_attach_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=attach_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
    ${bip_log}    ${tti_file_path}    ${cpif_log}    UE Start traffic and Get Bip log    ue_index=${ue_index}
    ...                                                                   apn=${apn}
    ...                                                                   cellid=${cellid}
    ...                                                                   scellid=${scellid}
    ...                                                                   need_TTI=${need_TTI}
    ...                                                                   ul_target_tdd=${ul_target_tdd}
    ...                                                                   dl_target_tdd=${dl_target_tdd}
    ...                                                                   ul_target_fdd=${ul_target_fdd}
    ...                                                                   dl_target_fdd=${dl_target_fdd}
    ...                                                                   du_index=${du_index}
    ...                                                                   wireshark_capture_interface=${wireshark_capture_interface}
    ...                                                                   timestamp=${timestamp}
#    sleep    3s
#    ${cpif_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
#    ...                                                        tcpdump_collector_name=antennaSwitch_${timestamp}
#    ...                                                        target_dir=${TS_CASE_LOG_PATH}
#    ${cpif_log}    logs.Stop capture F1AP log    tcpdump_collector_name=antennaSwitch_${timestamp}
    Sleep   10sec
    ${cpif_rel_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=antennaSwitch_release_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
    [Return]    ${cpif_log}    ${bip_log}    ${tti_file_path}    ${cpif_rel_log}    ${cpif_attach_log}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master    AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

UE start attach
    [Arguments]    ${ue_index}=${0}    ${power_reset}=False
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    sleep    5s
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Sleep   5sec

Check scell traffic
    [Arguments]    ${cells}    ${scellid}    ${ue_type}    ${log_path}
    ...            ${ul_target}    ${dl_target}
    ${scell}    Create list    ${cells}[${scellid}]
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    check_source=Aasyslog
    ...                                                           log=${log_path}    cells=${scell}    target_throughput=${dl_target}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    check_source=Aasyslog
    ...                                                           log=${log_path}    cells=${scell}    target_throughput=${ul_target}

UE Start traffic and Get Bip log
    [Arguments]    ${timestamp}    ${ue_index}=${0}    ${du_index}=${0}    ${apn}=dxdata2    ${cellid}=5    ${scellid}=${None}
    ...            ${ul_target_tdd}=${UL_THROUGHPUT_TDD}    ${dl_target_tdd}=${DL_THROUGHPUT_TDD}
    ...            ${ul_target_fdd}=${UL_THROUGHPUT_FDD}    ${dl_target_fdd}=${DL_THROUGHPUT_FDD}
    ...            ${need_TTI}=${False}   ${need_bip_log}=${True}
	...            ${wireshark_capture_interface}=-p -i any -s 0
    ${cells}    Get NRcellid list
    ${cell0}    Create list    ${cells}[${cellid}]
#    Run Keyword If    ${need_bip_log}    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    Start CP-IF Log Collection     tcpdump_collector_name=antennaSwitch_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=${du_index}
    ...                            options=${wireshark_capture_interface}
    #...                            gnb_index=${nr_bts_id}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${DL_THROUGHPUT}    duration=${duration}
    ...                       ue_index=${ue_index}    cap_index=${0}    apn=${apn}    process_num=1
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${UL_THROUGHPUT}    duration=${duration}
    ...                       ue_index=${ue_index}    apn=${apn}    process_num=1
    sleep    3sec
    ${cpif_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=antennaSwitch_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
#    ${bip_log}    Run Keyword If    ${need_bip_log}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    Run Keyword If    ${need_bip_log}    bip_common_keyword.Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    Connect to gnb coam via ssl
#    ${tti_file_path}    Run Keyword If    ${need_TTI}    Capture And Decode TTitrace Log    ${duration}=1
    ${tti_file_path}    Run Keyword If    ${need_TTI}    Capture TTitrace Log only    ${duration}=1
    sleep    0.5s
    ${bip_log}    Run Keyword If    ${need_bip_log}    bip_common_keyword.Stop Bip Log with Suitable Means
    ...                                                target_file_name=l1l2bip_log_${timestamp}
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m    ignore_time=0min    check_source=Aasyslog
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    check_source=Aasyslog
    ...                                                           log=${log_path}    cells=${cell0}    target_throughput=${dl_target_tdd}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    check_source=Aasyslog
    ...                                                           log=${log_path}    cells=${cell0}    target_throughput=${ul_target_tdd}
    run keyword if    '${scellid}'!='${None}'    Check scell traffic    cells=${cells}    scellid=${scellid}    log_path=${log_path}
    ...                                          ue_type=${ue_type}    ul_target=${ul_target_fdd}    dl_target=${dl_target_fdd}
    Start CP-IF Log Collection     tcpdump_collector_name=antennaSwitch_release_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=${du_index}
    ...                            options=${wireshark_capture_interface}
    #...                            gnb_index=${nr_bts_id}
    Sleep   2sec
    [Return]    ${bip_log[0]}    ${tti_file_path}    ${cpif_log}
    [Teardown]    Run Keywords
    ...             Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    AND
    ...             Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}

Check TAS and Codebook after DL traffic start or stop
    [Arguments]    ${cpif_log}    ${enable}=${True}
    [Documentation]    Check TAS and Codebook after DL traffic start or stop
    Load BIP Log with Template Command    pcap_file=${cpif_log}
    ...                                   command_template=${cpif_command_template}
    ...                                   tshark_path=${tshark_path}
    ${value}    Get value from Bip Log    field_name=${rrcreconfig_srs_name}
    Should Be Equal    ${value[0]}    1
    ${status}    Run Keyword And Return Status    Check expression in Bip Log by Name    filter_expression=${rrcreconfig_srs_filter_expression}
    ...                                                field_name=${rrcreconfig_c_srs_name}
    Should Be Equal    ${status}    ${enable}

Check SymbolPosition in Special Slot
    [Arguments]    ${bip_log}    ${codebook_symbol}=13    ${bip_srs_command_template}=${bip_srs_command_template_pci504}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_srs_command_template}
    ...                                   tshark_path=${tshark_path}
    ${value}    Check expression in Bip Log by Name    filter_expression=${srsRtBfEnable_filter}
    ...                                                field_name=${RtBf_symbolPosition_name}
    ${value}    Remove Duplicates    ${value}
    Should Be Equal    ${value[0]}    12
    ${value_length}    Get Length    ${value}
    Should Be Equal    ${value_length}    ${1}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_srs_command_template}
    ...                                   tshark_path=${tshark_path}
    ${value}    Check expression in Bip Log by Name    filter_expression=${srsBmEnable_filter}
    ...                                                field_name=${Bm_symbolPosition_name}
    ${value}    Remove Duplicates    ${value}
    Should Be Equal    ${value[0]}    ${codebook_symbol}
    ${value_length}    Get Length    ${value}
    Should Be Equal    ${value_length}    ${1}

Check Bip log for CB008927
    [Arguments]    ${bip_log}    ${bip_command_template}=${bip_dlpdsch_command_template}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_command_template}
    ...                                   tshark_path=${tshark_path}
    ${value}    Check expression in Bip Log by Name    filter_expression=${rat0Bitmap_tdd_filter}
    ...                                                field_name=${rat0Bitmap_name}
    ${value}    Check expression in Bip Log by Name    filter_expression=${rat0Bitmap_fdd_filter}
    ...                                                field_name=${rat0Bitmap_name}

Check UE capacity for CB010938
    [Arguments]    ${cpif_log}
    Load BIP Log with Template Command    pcap_file=${cpif_log}
    ...                                   command_template=${cpif_command_template}
    ...                                   tshark_path=${tshark_path}
    ${value}    Check expression in Bip Log by Xpath    filter_expression=${ue_chipset_info_filter}
    ...                                                field_xpath=${ue_chipset_info_maxConfiguredResourceSetsAllCC}
    ${buburstLength}    Get value from Bip Log by xpath    xpath=${ue_chipset_info_buburstLength}
    ${maxSimultaneousResourceSetsPerCC}    Get value from Bip Log by xpath    xpath=${ue_chipset_info_maxSimultaneousResourceSetsPerCC}
    Return From Keyword If    ${buburstLength[0]} != 1 or ${maxSimultaneousResourceSetsPerCC[0]} != 5    ${False}
    [Return]    ${True}

COAM Get BTS Counters via webUI
    [Arguments]    ${counter_id}    ${full_path}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}

Sum Value in Counter list
    [Arguments]    ${cnt_list}
    ${sum}    Set Variable    0
    FOR  ${item}  IN  @{cnt_list}
        Convert To Integer    ${item}
        ${sum}    Evaluate    ${item} + ${sum}
    END
    [Return]    ${sum}

Check Couter for CB010938
    [Arguments]    ${state}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${correct_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_10938[0]}[counter_id]
    ...                                                   full_path=${COUNTERS_10938[0]}[full_path]
    ${err_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_10938[1]}[counter_id]
    ...                                                   full_path=${COUNTERS_10938[1]}[full_path]
    ${counter_sum_correct}    Sum Value in Counter list    cnt_list=${correct_list}
    ${counter_sum_err}    Sum Value in Counter list    cnt_list=${err_list}
    Run Keyword If   '${state}'=='True'    Should Be True    ${counter_sum_correct} > 0
    ...    ELSE    Should Be True    ${counter_sum_err} > 0
    [Teardown]   COAM selenium logout

Check logs for CB010938
    [Arguments]    ${cpif_log}
    ${chipest_info_state}    Check UE capacity for CB010938    cpif_log=${cpif_log}
    Check Couter for CB010938    state=${chipest_info_state}