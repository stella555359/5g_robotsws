*** Settings ***
Resource    ./../../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${EGATE_FILE}    /opt/iphy/latest/egate_console.log

*** Keywords ***
Check Scell Active Status
    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${check_status}=pass
    ...    ${egate_file}=/opt/iphy/latest/egate_console.log
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    fail
    Should be True    '${scell_status}'=='${check_status}'

SA 5G PDU Session Setup for NewDRB
    [Arguments]    ${ue_id}
    Log To Console    start 5G PDU Session Setup for NewDRB...
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=15
    ${command}    Set Variable    ue_pdu_session_setup pdu=15 ue=${ue_id} nwslice=1 gw=15
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Established PDU session ID=15 using PDU Gateway    timeout=3minutes
    [Return]    ${output}
    Log To Console    ${output}

SA 5G PDU Session release for NewDRB
    [Arguments]    ${ue_id}
    Log To Console    start 5G PDU Session release for NewDRB...
    ${command}    Set Variable    ue_pdu_session_release ue=${ue_id} pdu=15 by=ue
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Successfully released PDU Session with ID 15    timeout=3minutes
    [Return]    ${output}
    Log To Console    ${output}
    sleep    20s

Set UE To Center
    [Arguments]    ${UE_ID}=1    ${scell}=0
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} testmode=phr_override action=activate profile_id=1 scell=0

Set UE To Edge
    [Arguments]    ${UE_ID}=1    ${scell}=0
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} testmode=phr_override action=activate profile_id=2 scell=0

Verify Multi UEs Released
    [Arguments]    ${ue_id_list}
    FOR    ${ue_id}    IN    @{ue_id_list}
        Wait Until Keyword Succeeds    5s    1s    Check Egate Log With Message    ${EGATE_FILE}
        ...    UE${ue_id}: detached
    END

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

Capture Logs And Check TTitrace
    [Arguments]    ${log_idx}
    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_idx}    
    CUDU_L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=3
    CUDU_L2 Check DTXNACK Rate    log_id=${log_idx}
    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_idx}
