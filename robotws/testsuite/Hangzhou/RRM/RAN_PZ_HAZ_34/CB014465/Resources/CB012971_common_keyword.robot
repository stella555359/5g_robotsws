*** Settings ***
Resource    CB014465_common_keyword.robot
Library    CB012971_compare.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02


*** Variables ***
${bip_dlpdsch_command_template}    {tshark_path} -r {pcap_file} -Y "dldata_pdschsendreql1sw and 3gpp.rnti!=65535" -T pdml
${bip_dluepairing_command_template}    {tshark_path} -r {pcap_file} -Y "dldata_uepairingreq" -T pdml
${bip_srs_command_template}    {tshark_path} -r {pcap_file} -Y "uldata_srsreceivereq" -T pdml
${subcellid_filter}    \"(3gpp.subcellid==6 or 3gpp.subcellid==7 or 3gpp.subcellid==10 or 3gpp.subcellid==11)\"
${rnti_name}    _3gpp.rnti
${rnti_filter}    3gpp.rnti
${subcellid_name}    _3gpp.subcellid
${streamIndex_name}    DlData_PdschGrantL1sw.streamIndex_item
${srsRtBfEnable_false_filter}    UlData_srsReceiveReqSubcell_t.srsRtBfEnable==False
${srsRtBfEnable_name}    UlData_srsReceiveReqSubcell_t.srsRtBfEnable

${rnti_pairue}    .//nr_l1dl_l2ps_dldata_pairedueinfo_t/_3gpp.rnti
${startStreamIndex_pairue}    .//nr_l1dl_l2ps_dldata_pairedueinfo_t/DlData_pairedUeInfo_t.startStreamIndex
${subcellid_pairue}    .//nr_l1dl_l2ps_dldata_pairedueinfo_t/_3gpp.subcellid
${numOfLayers_pairue}    .//nr_l1dl_l2ps_dldata_pairedueinfo_t/DlData_pairedUeInfo_t.numOfLayers
${numOfPrb_pairue}    DlData_virtualUe_t.numOfPrb
${slot_name}    _3gpp.slot
${slot_dlpdsch}    .//nr_l1dl_l2ps_dldata_pdschsendreql1sw_t/_3gpp.slot
${sfn_dlpdsch}    .//nr_l1dl_l2ps_dldata_pdschsendreql1sw_t/_3gpp.sfn
${numOfPrb_dlpdsch}    DlData_PdschGrantL1sw.numOfPrb


*** Keywords ***
CB012971 Prepare Multi UEs
    [Arguments]    ${ue_num}=8
    FOR    ${index}    IN RANGE    ${ue_num}
       CB012149 UE prepare UE    ue_index=${index}
    END

CB012971 Start Multi UEs attach
    [Arguments]    ${ue_num}=8
    FOR    ${index}    IN RANGE    ${ue_num}
       UE start attach    ue_index=${index}    power_reset=True
    END

CB012971 Start Multi UEs Traffic And Get CP-IF BIP TTI log
    [Arguments]    ${ue_num}=8    ${direction}=dl    ${need_TTI}=${True}   ${need_bip_log}=${True}
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    FOR    ${index}    IN RANGE    ${ue_num}
       ${cpif_log}    UE Start traffic only and Get logs    ue_index=${index}    direction=${direction}
    END
    Run Keyword If    ${need_bip_log}    bip_common_keyword.Start Bip Log with Suitable Means    target_file_name=l1l2bip_${timestamp}
    Connect to gnb coam via ssl
    ${tti_file_path}    Run Keyword If    ${need_TTI}    Capture TTitrace Log only    duration=1
    sleep    0.5s
    ${bip_log}    Run Keyword If    ${need_bip_log}    bip_common_keyword.Stop Bip Log with Suitable Means
    ...                                                target_file_name=l1l2bip_${timestamp}
    [Return]    ${cpif_log}    ${tti_file_path}    ${bip_log[0]}

UE Start traffic only and Get logs
    [Arguments]    ${ue_index}=${0}    ${du_index}=${0}
	...            ${direction}=dl    ${wireshark_capture_interface}=-p -i any -s 0
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Start CP-IF Log Collection     tcpdump_collector_name=antennaSwitch_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=${du_index}
    ...                            options=${wireshark_capture_interface}
    #...                            gnb_index=${nr_bts_id}
    Run Keyword Unless    '${direction}'=='ul'    power_ue.Start traffic    ue_type=${ue_type}
    ...                       direction=dl    throughput=${DL_THROUGHPUT}    duration=${duration}
    ...                       ue_index=${ue_index}    cap_index=${0}
    Run Keyword Unless    '${direction}'=='dl'    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...                       throughput=${UL_THROUGHPUT}    duration=${duration}    ue_index=${ue_index}
    sleep    3sec
    ${cpif_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=antennaSwitch_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
    [Return]    ${cpif_log}

UE Check traffic after all UEs traffic start
    [Arguments]    ${ue_num}=8    ${cellid}=4    ${start_ue_index}=0
    ...            ${ul_target}=${UL_THROUGHPUT}    ${dl_target}=${DL_THROUGHPUT}
	...            ${direction}=dl
    ${cells}    Get NRcellid list
    ${cell0}    Create list    ${cells}[${cellid}]
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m    ignore_time=0min    check_source=Aasyslog
    Run Keyword Unless    '${direction}'=='ul'    Run Keyword And Continue On Failure
    ...                                           power_ue.Check Tput    ue_type=${ue_type}    direction=DL    check_source=Aasyslog
    ...                                           log=${log_path}    cells=${cell0}    target_throughput=${dl_target}
    Run Keyword Unless    '${direction}'=='dl'    Run Keyword And Continue On Failure
    ...                                           power_ue.Check Tput    ue_type=${ue_type}    direction=UL    check_source=Aasyslog
    ...                                           log=${log_path}    cells=${cell0}    target_throughput=${ul_target}
    Sleep   2sec
    [Teardown]    CB012971 UE stop traffic    ue_num=${ue_num}    direction=${direction}    start_ue_index=${start_ue_index}

CB012971 UE stop traffic
    [Arguments]    ${ue_num}=8    ${direction}=dl    ${start_ue_index}=0
    FOR    ${index}    IN RANGE    ${ue_num}
        ${ue_index}    Evaluate    ${index}+${start_ue_index}
        Run Keyword Unless    '${direction}'=='ul'    Run keyword and ignore error
        ...                                           power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${index}
        Run Keyword Unless    '${direction}'=='dl'    Run keyword and ignore error
        ...                                           power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${index}
    END

#Check Bip log for CB012971
#    [Arguments]    ${bip_log}    ${bip_command_template}=${bip_dlpdsch_command_template}
#    Load BIP Log with Template Command    pcap_file=${bip_log}
#    ...                                   command_template=${bip_command_template}
#    ...                                   tshark_path=${tshark_path}
#    ${rnti_list}    Check expression in Bip Log by Name    filter_expression=${subcellid_filter}    field_name=${rnti_name}
#    ${rnti_list}    Remove Duplicates    ${rnti_list}
#    ${rnti_cnt}    Get Length    ${rnti_list}
#    Should Be Equal As Integers    ${rnti_cnt}    8
#    ${streamIndex_subcell6}    Create List
#    ${streamIndex_subcell7}    Create List
#    ${streamIndex_subcell10}    Create List
#    ${streamIndex_subcell11}    Create List
#    ${streamIndex_0}    Create List    0    1
#    ${streamIndex_1}    Create List    2    3    0
#    ${streamIndex_finall}    Create List    ${streamIndex_0}    ${streamIndex_1}
#    ${streamIndex_map}    Create Dictionary    6=${streamIndex_subcell6}    7=${streamIndex_subcell7}
#    ...                                        10=${streamIndex_subcell10}    11=${streamIndex_subcell11}
#    FOR    ${rnti}    IN    @{rnti_list}
#        Load BIP Log with Template Command    pcap_file=${bip_log}
#        ...                                   command_template=${bip_command_template}
#        ...                                   tshark_path=${tshark_path}
#        ${streamIndex_list}    Check expression in Bip Log by Name    filter_expression=${rnti_filter}==${rnti}    field_name=${streamIndex_name}
#        ${streamIndex_list}    Remove Duplicates    ${streamIndex_list}
##        ${status}   Run Keyword And Return Status    Lists Should Be Equal    ${streamIndex_0}    ${streamIndex_list}
##        Run Keyword Unless    ${status}    Lists Should Be Equal    ${streamIndex_1}    ${streamIndex_list}
#        ${subcellid_list}    Get value from Bip Log    field_name=${subcellid_name}
#        Append To List    ${streamIndex_map['${subcellid_list[0]}']}    ${streamIndex_list}
#    END
#    FOR    ${key}    ${value}    IN    &{streamIndex_map}
#        ${streamIndex_list}    Convert To List    ${value}
#        ${streamIndex_list}    Remove Duplicates    ${streamIndex_list}
#        Lists Should Be Equal    ${streamIndex_list}    ${streamIndex_finall}
#    END
#    Load BIP Log with Template Command    pcap_file=${bip_log}
#    ...                                   command_template=${bip_srs_command_template}
#    ...                                   tshark_path=${tshark_path}
#    ${enable_list}    Check expression in Bip Log by Name    filter_expression=${srsRtBfEnable_name}    field_name=${srsRtBfEnable_name}
#    Should Not Contain	${enable_list}    False
#    Should Contain	${enable_list}    True

Check Bip log for CB012971
    [Arguments]    ${bip_log}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_dlpdsch_command_template}
    ...                                   tshark_path=${tshark_path}
    ${rnti_list}    Check expression in Bip Log by Name    filter_expression=${subcellid_filter}    field_name=${rnti_name}
    ${numOfPrb_list}    Get value from Bip Log    field_name=${numOfPrb_dlpdsch}
    ${slot_list}    Get value from Bip Log by xpath    xpath=${slot_dlpdsch}
    ${sfn_list}    Get value from Bip Log by xpath    xpath=${sfn_dlpdsch}
    ${streamIndex_list}    Get value from Bip Log    field_name=${streamIndex_name}
    ${subcellid_list}    Get value from Bip Log    field_name=${subcellid_name}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_dluepairing_command_template}
    ...                                   tshark_path=${tshark_path}
    ${rnti_req}    Get value from Bip Log by xpath    xpath=${rnti_pairue}
    ${startStreamIndex_req}    Get value from Bip Log by xpath    xpath=${startStreamIndex_pairue}
    ${subcellid_req}    Get value from Bip Log by xpath    xpath=${subcellid_pairue}
    ${numOfLayers_req}    Get value from Bip Log by xpath    xpath=${numOfLayers_pairue}
    ${numOfPrb_req}    Get value from Bip Log    field_name=${numOfPrb_pairue}
    ${slot_req}    Get value from Bip Log    field_name=${slot_name}

    ${rnti_list}    Remove Duplicates    ${rnti_list}
    ${rnti_cnt}    Get Length    ${rnti_list}
    Should Be Equal As Integers    ${rnti_cnt}    8
    ${status}    check streamIndex for each subcell    slot_list=${slot_list}    sfn_list=${sfn_list}    subcellid_list=${subcellid_list}
    ...                                   numOfPrb_list=${numOfPrb_list}    streamIndex_list=${streamIndex_list}
    Should Be True    ${status}





