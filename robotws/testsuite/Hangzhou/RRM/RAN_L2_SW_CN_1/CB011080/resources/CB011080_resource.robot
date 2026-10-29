*** Settings ***
Resource          ../../CUDU_L2/common_setup_teardown.robot

Documentation
...     CB011080 resource


*** Variables ***
${PDU_ID}         1
${MCC}            311
${MNC}            489
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Keywords ***
Configure IP For UEC2
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3

Single Ue Attach
    [Arguments]    ${ue_id}    ${amf_region}=1:2:2
    Log To Console    UE${ue_id} Start Attach...
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${PDU_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=${ue_id} registered_amf\=${MCC}:${MNC}|${amf_region}
    #Sleep    0.5s    reason=wait for taking effect
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${PDU_ID} ue=${ue_id} nwslice=1
    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes

Capture And Check TTitrace Logs
    [Arguments]    ${log_idx}    ${time}=1
    #Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_idx}
    CUDU_L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=${time}
    CUDU_L2 Check DTXNACK Rate    log_id=${log_idx}
    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_idx}

Capture Logs And Check MultiTTitrace
    [Arguments]    ${log_idx}
    Capture Convert Format Ttitrace With Streaming Mode    1s    log_dir=${test_log_directory}/ttitrace/${log_idx}
    Check DTXNACK Rate    log_id=${log_idx}
    Check UL DTXCRC Rate    log_id=${log_idx}

Check DTXNACK Rate
    [Arguments]    ${log_id}=1    ${expect_rate}=0.1
    Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

Check UL DTXCRC Rate
    [Arguments]    ${log_id}    ${expect_rate}=0.1
    Check Rate    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]    ${log_id}    ${expect_rate}
    Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

Check Rate
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK","NACK","DTX"]    ${failed}=["NACK","DTX"]    ${log_id}=1    ${expect_rate}=0.1
    ${sub_nm}=    Get Substring    ${name}    0    2
    ${csv_files}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}    output_${sub_nm}.\[0\-9\].csv    ${True}
    FOR    ${index}    ${csv_file_name}    IN ENUMERATE    @{csv_files}
        ${total_data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
        ...    ${csv_file_name}    ${name}    ${total}    include    no
        ${total_count}    Get Length    ${total_data_list}
        ${failed_data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
         ...    ${csv_file_name}    ${name}     ${failed}    include    no
        ${failed_count}    Get Length    ${failed_data_list}
        ${rate}    Evaluate    float(${failed_count})/(${total_count})
        Log To Console    \n${name} rate is ${rate}\n
        Should Be True    ${rate}<${expect_rate}
    END

Check UE DL All Pcell Scell TPut Uestats
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of single ue once.
    ${ue_dltput}    Set Variable    0
    FOR    ${id}    IN RANGE    ${cc_num}
        ${dl_tput}    Run Keyword If    ${id}==${0}    Check CA UE Pcell Scell Cell TPut On Target Uestats
        ...    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}
        ...    ELSE    Check CA UE Pcell Scell Cell TPut On Target Uestats
        ...    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=${id}    target_tp=${exp_dl_tput_list[${id}]}
        ${ue_dltput}    Evaluate    ${ue_dltput}+${dl_tput}
    END
    [Return]    ${ue_dltput}

Check CA UE Pcell Scell Cell TPut On Target Uestats
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}

    Should Be True    ${tput}>=${target_tp}
    ...    msg=UE${ue_id} ${cell_type}${scell_index} tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} ${cell_type} ${scell_index} ${dir} tput ${tput}Mb is on target: ${target_tp}Mb
    [Return]    ${tput}

Check UE 2CCUL Pcell Scell TPut Uestats
    [Arguments]    ${ue_id}    ${exp_ul_tput_list}    ${dl_cc_num}
    [Documentation]    This keyword is to check all ul Pcell Scell TP of single ue once.
    ${ue_ultput}    Set Variable    0
    FOR    ${id}    IN RANGE    2
        ${ul_tput}    Run Keyword If    ${id}==${0}    Check CA UE Pcell Scell Cell TPut On Target Uestats
        ...    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0    target_tp=${exp_ul_tput_list[0]}
        ...    ELSE    Check ULCA Scell L1 Cell Tput On Target Uestats
        ...    ue_id=${ue_id}    dl_cc_num=${dl_cc_num}    target_tp=${exp_ul_tput_list[1]}
        ${ue_ultput}    Evaluate    ${ue_ultput}+${ul_tput}
    END
    [Return]    ${ue_ultput}

Check ULCA Scell L1 Cell Tput On Target Uestats
    [Arguments]    ${ue_id}    ${dl_cc_num}    ${target_tp}
    ${tput}    Get ULCA SCell L1 Average Throughput    ${ue_id}    ${dl_cc_num}

    Should Be True    ${tput}>=${target_tp}
    ...    msg=UE${ue_id} UL scell tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} UL scell tput ${tput} is on target: ${target_tp}Mb
    [Return]    ${tput}

Check PatternID From Wirshark
    [Arguments]    ${log_id}    ${phycell_id}    ${msg_name}    ${field_name}    ${PatternID}=101,106
    Convert BIP To CSV By MCShark For PatternId    ${log_id}    ${phycell_id}    ${msg_name}    ${field_name}
    Check PatternID In Csv File    ${log_id}    ${msg_name}    ${field_name}    ${PatternID}

Convert BIP To CSV By MCShark For PatternId
    [Arguments]    ${log_id}    ${phycell_id}    ${msg_name}    ${field_name}
    ${filter}=    Set Variable    (${msg_name}) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
    @{csv_title_list}=    Create List    ${field_name}
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off.pcap    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_${msg_name}.csv    ${filter}
    ...    ${csv_title_list}

Check PatternID In Csv File
    [Arguments]    ${log_id}    ${msg_name}    ${field_name}    ${PatternID}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_${msg_name}.csv     ${field_name}    ["${PatternID}"]
    ...    include    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

Check overlap Symbols From Wirshark
    [Arguments]    ${log_id}    ${phycell_id}    ${symbol_num}
    Convert BIP To CSV By MCShark For overlapSymbol Of Puschreceivereq    ${log_id}    ${phycell_id}
    Check overlap Symbols In Puschreceivereq    ${log_id}    ${symbol_num}

Convert BIP To CSV By MCShark For overlapSymbol Of Puschreceivereq
    [Arguments]    ${log_id}    ${phycell_id}
    ${filter}=    Set Variable    (uldata_puschreceivereq) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
    @{csv_title_list}=    Create List    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off.pcap
    ...    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/12Symbols_Puschreceivereq.csv    ${filter}
    ...    ${csv_title_list}

Check overlap Symbols In Puschreceivereq
    [Arguments]    ${log_id}    ${symbol_num}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/12Symbols_Puschreceivereq.csv    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ...    ["${symbol_num}"]    include    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

Check Srsreceivereq With A2A
    [Arguments]    ${log_id}    ${ini_file}
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots    ${log_id}
    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/${ini_file}    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    ...    ${TEST_LOG_DIRECTORY}/${log_id}

Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_srsreceivereq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_srsBmResource_t.srsResourceIdentity
    Convert BIP To CSV By MCShark   ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    ${filter}    ${csv_title_list}
    OperatingSystem.Run
    ...    cp ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq_bk.csv

Check Rate in Bip Per Field
    [Arguments]    ${log_id}    ${msg_name}    ${field}    ${matchReg}    ${rate}=0.05
    Log To Console    \nCheck Rate in Bip ${msg_name} Per Field ${field}.
    Log To Console    \nCheck matchReg=${matchReg} ......
    ${data_list1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/${msg_name}.csv    ${field}    [${matchReg}]    except    no
    ${fail_number}    Get Length    ${data_list1}
    ${data_list2}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/${msg_name}.csv    ${field}    [${matchReg}]    include    no
    ${ok_number}    Get Length    ${data_list2}
    ${total_number}    Evaluate    ${fail_number}+${ok_number}
    Log To Console    fail_number=${fail_number}, ok_number=${ok_number}, total_number=${total_number}
    ${checkRate}    Evaluate    float(${fail_number})/(${total_number})
    Log To Console    ${field} Fail Rate is ${checkRate}
    Should Be True    ${checkRate}<${rate}

Convert BIP To CSV By MCShark For Bip Msg
    [Arguments]    ${log_id}    ${msg_name}
    ${filter}=    Set Variable    ${msg_name}
    ${csv_title_list}    Create List    3gpp.sfn    3gpp.slot
    Run Keyword If    "${msg_name}"=="uldata_puschreceiverespharqul1sw"
    ...    Collections.Append To List    ${csv_title_list}    UlData_UePuschReceiveRespHarqUL1sw_t.crc    UlData_UePuschReceiveRespHarqUL1sw_t.dtx
    Run Keyword If    "${msg_name}"=="uldata_puschreceiverespharqdl1sw"
    ...    Collections.Append To List    ${csv_title_list}    UlData_puschReceiveRespHarqDGrantsL1sw_t.ackCrcCheck
    ...    UlData_puschReceiveRespHarqDGrantsL1sw_t.dtxAckMoreThan1Bit
    Run Keyword If    "${msg_name}"=="uldata_puschreceiverespps"
    ...    Collections.Append To List    ${csv_title_list}    UlData_UePuschReceiveRespPs_t.dtx
    ...    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck
    ...    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1
    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart2

    Convert BIP To CSV By MCShark   ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/${msg_name}.csv    ${filter}    ${csv_title_list}
