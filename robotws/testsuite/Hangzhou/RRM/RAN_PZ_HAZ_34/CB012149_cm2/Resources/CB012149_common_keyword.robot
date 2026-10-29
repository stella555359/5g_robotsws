*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02


*** Variables ***
${DURATION}    6000

${UL_THROUGHPUT}    200Mbits/sec
${DL_THROUGHPUT}    1500Mbits/sec
${UL_THROUGHPUT_TDD}    351
${UL_THROUGHPUT_FDD}    118

${SA_RRC_RECONFIGURE_FILTER_ATTACH}    nr-rrc.rrcReconfiguration_element

${tshark_path}    /usr/bin/tshark
${cpif_command_template}    {tshark_path} -r {pcap_file} -Y "nr-rrc" -T pdml
${bip_command_template}    {tshark_path} -r {pcap_file} -Y "uldata_puschreceivereq" -T pdml
${UERadioCapabilityInfoIndication_filter}     \"ngap and
...                                             nr-rrc.BandCombination_UplinkTxSwitch_r16_element and
...                                             nr-rrc.uplinkTxSwitchRequest_r16 == 0 and
...                                             nr-rrc.uplinkTxSwitching_OptionSupport_r16 == 0 and
...                                             nr-rrc.uplinkTxSwitchingPeriod_r16 == 1\"

${UERadioCapabilityInfoIndication_name}    nr-rrc.UERadioAccessCapabilityInformation_element

${uldata_puschreceivereq_layer1_filter}    \"UlData_puschReceiveReqGrant_t.numOfLayers == 1 and
...                                          3gpp.subcellid == 0\"
${uldata_puschreceivereq_layer2_filter}    \"UlData_puschReceiveReqGrant_t.numOfLayers == 2 and
...                                          3gpp.subcellid == 0\"

${uldata_puschreceivereq_layer_name}    UlData_puschReceiveReqGrant_t.numOfLayers

${bip_srs_command_template}    {tshark_path} -r {pcap_file} -Y "uldata_srsreceivereq" -T pdml
${uldata_srsreceivereq_name}    UlData_srsBmStruct_t.numSrsSymbols
${uldata_slot5_filter}    3gpp.slot == 5
${uldata_slot9_filter}    3gpp.slot == 9

${bip_bler_command_template}    {tshark_path} -r {pcap_file} -Y "uldata_puschreceiverespharqu" -T pdml
${uldata_crc_name}    UlData_UePuschReceiveRespHarqU_t.crc

*** Keywords ***
CB012149 COAM update ulTxSwitchingSupportList
    [Arguments]    ${ulTxSwitchingSupportList}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${ulTxSwitchingSupportList}
    [Teardown]    COAM Teardown gnb connections

CB012149 COAM update Parameters
    [Arguments]    ${parameters}    ${timeout}=${60}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections

CB012149 UE prepare UE
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    log to console    \n***Prepare UE***
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

Qcom UE Attach and Get CP-IF log
    [Arguments]    ${ue_index}=${0}    ${du_index}=${0}
	...            ${wireshark_capture_interface}=-p -i any sctp -s 0
    #...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
    #...            ${wireshark_capture_interface}=-p -i any '((sctp) and ${filter_ports})' -s 0
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Connect to Common Unit Master     alias=ASIK Master
    Start CP-IF Log Collection     tcpdump_collector_name=ulTxSwithch_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=${du_index}
    ...                            options=${wireshark_capture_interface}
    #...                            gnb_index=${nr_bts_id}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    5s
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Sleep   5sec
    ${cpif_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=ulTxSwithch_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
    [Return]    ${cpif_log}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master    AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Qcom UE Start traffic and Get Bip log
    [Arguments]    ${ue_index}=${0}    ${ul_target_tdd}=${UL_THROUGHPUT_TDD}    ${ul_target_fdd}=${UL_THROUGHPUT_FDD}
    ...            ${asrs_flag}=${False}    ${asrs_ue}=${1}    ${need_TTI}=${False}
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${cells}    Get NRcellid list
    ${cell0}    Create list    ${cells}[0]
    ${cell1}    Create list    ${cells}[1]
    ${gnb_log}    Set Variable    ${None}
    #power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=2000M    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=500M    duration=${duration}    ue_index=${ue_index}
    sleep    3sec
    Run Keyword If    ${asrs_flag}    ASRS UE attach and start traffic    ue_index=${asrs_ue}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    Connect to gnb coam via ssl
    ${tti_file_path}    Run Keyword If    ${need_TTI}    Capture And Decode TTitrace Log    ${duration}=1
    sleep    0.5s
    ${bip_log}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m    ignore_time=0min
    #Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    #...                                                           log=${log_path}    cells=${cell0}    target_throughput=1500
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${log_path}    cells=${cell0}    target_throughput=${ul_target_tdd}
    #Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    #...                                                           log=${log_path}    cells=${cell1}    target_throughput=300
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${log_path}    cells=${cell1}    target_throughput=${ul_target_fdd}
    [Return]    ${bip_log[0]}    ${tti_file_path}
    [Teardown]    Run Keywords
    ...             Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    AND
    ...             Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_1}    direction=ul    ue_index=${asrs_ue}

Qcom UE attach and start traffic
    [Arguments]    ${ue_index}=${0}    ${dl_target}=${DL_THROUGHPUT}    ${ul_target}=${UL_THROUGHPUT}
    ${ue_type}    translate_power_ue_type_from_testline
    Set Test Variable    ${ue_type}
    Set Variable    ${dl_target}    ${dl_target}
    Set Variable    ${ul_target}    ${ul_target}
    log to console    \n***Prepare UE***
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    5s
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Sleep   5sec
    ${cells}    Get NRcellid list
    ${cell0}    Create list    ${cells}[0]
    ${cell1}    Create list    ${cells}[1]
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=2000M    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=500M    duration=${duration}    ue_index=${ue_index}
    Sleep   18min
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m    ignore_time=0min
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...                                                           log=${log_path}    cells=${cell0}    target_throughput=600
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${log_path}    cells=${cell0}    target_throughput=161
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...                                                           log=${log_path}    cells=${cell1}    target_throughput=160
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${log_path}    cells=${cell1}    target_throughput=117
    [Teardown]    Run Keywords
    ...             Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}    AND
    ...             Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}

ASRS UE attach and start traffic
    [Arguments]    ${ue_index}=${1}
    ${ue_type_1}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type_1}
    log to console    \n***Prepare UE***
    power_ue.Prepare UE    ue_type=${ue_type_1}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type_1}    ue_index=${ue_index}
    sleep    5s
    power_ue.UE Attach    ue_type=${ue_type_1}    ue_index=${ue_index}    timeout=${600}
    Sleep   5sec
    #power_ue.Start traffic    ue_type=${ue_type_1}    direction=dl    throughput=2000M    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type_1}    direction=ul    throughput=500M    duration=${duration}    ue_index=${ue_index}

Check ulTxSwitch Related Info during Attach Procedure
    [Arguments]    ${cpif_log}    ${feature_enable}=${True}
    Load BIP Log with Template Command    pcap_file=${cpif_log}
    ...                                   command_template=${cpif_command_template}
    ...                                   tshark_path=${tshark_path}
    ${status}    Run Keyword And Return Status    Check expression in Bip Log by Name    filter_expression=${UERadioCapabilityInfoIndication_filter}
    ...                                           field_name=${UERadioCapabilityInfoIndication_name}
    Should Be Equal    ${status}    ${feature_enable}

Check ulTxSwitch Related Info during Traffic Procedure
    [Arguments]    ${bip_log}    ${layer_true}=${uldata_puschreceivereq_layer2_filter}    ${layer_false}=${uldata_puschreceivereq_layer1_filter}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_command_template}
    ...                                   tshark_path=${tshark_path}
    Check expression in Bip Log by Name    filter_expression=${layer_true}
    ...                                    field_name=${uldata_puschreceivereq_layer_name}
    ${status}    Run Keyword And Return Status    Check expression in Bip Log by Name    filter_expression=${layer_false}
    ...                                           field_name=${uldata_puschreceivereq_layer_name}
    Should not be True    ${status}
    Check ulBler with BIP log    bip_log=${bip_log}

Check ulBler with BIP log
    [Arguments]    ${bip_log}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_bler_command_template}
    ...                                   tshark_path=${tshark_path}
    ${crc_list}    Get value from Bip Log    field_name=${uldata_crc_name}
    ${crc_sum}    Get Length    ${crc_list}
    ${crc_count_1}    Get Match Count    ${crc_list}    1
    ${bler_ul}    Run Keyword If    ${crc_sum}==0    Log To Console    no crc_sum=0
    ...    ELSE    Evaluate    round(round(${crc_count_1},1)/round(${crc_sum},1),4)*100

Check if A-SRS is triggered during Traffic Procedure
    [Arguments]    ${bip_log}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_srs_command_template}
    ...                                   tshark_path=${tshark_path}
    Check expression in Bip Log by Name    filter_expression=${uldata_slot5_filter}
    ...                                    field_name=${uldata_srsreceivereq_name}
    Check expression in Bip Log by Name    filter_expression=${uldata_slot9_filter}
    ...                                    field_name=${uldata_srsreceivereq_name}

Get NRcellid list
    [Arguments]    ${nrcell_r}=NRCELL_R    ${parameter}=parameters    ${nrcellidenty}=nrCellIdentity    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cell_info}    coam.get_subcells_info    timeout=20    connection=${connection}
    ${cell_len}    get length    ${cell_info}
    ${nrcell_list}    create list
    FOR    ${index}    IN RANGE    ${cell_len}
        ${num}    evaluate    2*${index}
        ${dic0}    get dictionary items    ${cell_info}
        ${nrcellgrp}    set variable    ${dic0}[${num}]
        ${dic1}    get dictionary items    ${cell_info}[${nrcellgrp}]
        ${nrcell}    set variable    ${dic1}[0]
        ${nrcellid}    Set Variable    ${cell_info}[${nrcellgrp}][${nrcell}][${nrcell_r}][${parameter}][${nrcellidenty}]
        Append to list    ${nrcell_list}    ${nrcellid}
    END
    [Return]    ${nrcell_list}
    [Teardown]    COAM Teardown gnb connections

COAM Get BTS Counter for Latest Value
    [Arguments]    ${counter_id}    ${full_path}
    ${counter_value}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    ...                                                        full_path=${full_path}
    ${counter_value}    Get Dictionary Values    ${counter_value}
    [Return]    ${counter_value[-3]}

COAM Get all BTS Counters and check values
    [Arguments]    ${counter}    ${min_dl}    ${max_dl}    ${min_ul}    ${max_ul}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${M55308C10013}    COAM Get BTS Counter for Latest Value    counter_id=${counter[0]['counter_id']}
    ...                                                         full_path=${counter[0]['full_path']}
    ${M55910C00001}    COAM Get BTS Counter for Latest Value    counter_id=${counter[1]['counter_id']}
    ...                                                         full_path=${counter[1]['full_path']}
    ${M55910C00002}    COAM Get BTS Counter for Latest Value    counter_id=${counter[2]['counter_id']}
    ...                                                         full_path=${counter[2]['full_path']}
    ${M55308C10012}    COAM Get BTS Counter for Latest Value    counter_id=${counter[3]['counter_id']}
    ...                                                         full_path=${counter[3]['full_path']}
    ${M55910C00003}    COAM Get BTS Counter for Latest Value    counter_id=${counter[4]['counter_id']}
    ...                                                         full_path=${counter[4]['full_path']}
    ${M55910C00004}    COAM Get BTS Counter for Latest Value    counter_id=${counter[5]['counter_id']}
    ...                                                         full_path=${counter[5]['full_path']}
    COAM selenium logout
    Run Keyword And Continue On Failure    Should Be True    ${min_dl} < ${M55910C00001}/${M55308C10013} * ${100} < ${max_dl}
    Run Keyword And Continue On Failure    Should Be True    ${0} < ${M55910C00002} <= ${100}
    Run Keyword And Continue On Failure    Should Be True    ${min_ul} < ${M55910C00003}/${M55308C10012} * ${100} < ${max_ul}
    Run Keyword And Continue On Failure    Should Be True    ${0} < ${M55910C00004} <= ${100}

Check Slot For FDD
    [Arguments]    ${log_file}    ${pci}    ${slotlist}    ${numOflayer}=ulFdSchedData.numOfLayers
    ${value}    handle_csv_pandas.Read Csv Column    ${testline_name}    ${log_file}    slot
	...    filter_conditions=`${numOflayer}`.notnull() and physCellId==${pci}
    ${list}     Evaluate      list(set(${value}))
    Log     ${list}
    Should Be True    ${list} == ${slotlist}
    Log to Console    \n Check Slot For FDD OK
