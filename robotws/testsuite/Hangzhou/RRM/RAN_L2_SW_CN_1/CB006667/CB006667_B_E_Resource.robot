*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
&{AP_ABIL}                 ip=192.168.253.85    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil
${CMD_OPEN_CP_DEBUG}       echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
${CMD_KILL_BIP_PROCESS}    pkill -9 tcpdump
${ALLOC_SUBFRAME}                   0010000010-0101001000-0011000010-0101001000-0010100010-0111001010-0011000110-0011001000
${PORT}                             7070
${PRB_LIST_10M_WITHOUT_BLANKING}    0,52
${PRB_LIST_15M_WITHOUT_BLANKING}    0,79
${PRB_LIST_20M_HIGN_BLANKING}       0,98
${PRB_LIST_20M_LOW_BLANKING}        2,104
${ATTACH_UE_NUM}                    10
${SCF_PATH}                ${CURDIR}/resources/config
#${RD_PARAM_R23}             SEPARATOR=${EMPTY}    0x590000=14;0x5800BA=17
#${RD_PARAM_AP_R23}          SEPARATOR=${EMPTY}    0x70649=11;0x70005=140
#${RD_PARAM_R22}             SEPARATOR=${EMPTY}    0x590000=13;0x5800BA=16
#${RD_PARAM_AP_R22}          SEPARATOR=${EMPTY}    0x70649=10;0x70005=140


*** Keywords ***
Convert TL Mode And Suite Setup
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    Suite Setup Update GNB    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Add Multi UE NSA    101-110
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup DSS
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    Suite Setup Update GNB    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite_Setup_Start_WTS_And_Check_OnAir_for_DSS

Change IPHY File Value
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Modify Text File    ${file_path}    ${OLD_PARAS_IPHY}    ${NEW_PARAS_IPHY}
    Send IPHY XML To Airphone    ${file_path}

Suite_Setup_Start_WTS_And_Check_OnAir_for_DSS
    [Arguments]        ${log}=${True}
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup_X2_Connection_for_DSS
    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

Setup_X2_Connection_for_DSS
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-2: X2AP Link with GNB-1 .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=2 target\=1
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok

SANSA Ue Attach With DSS
    [Arguments]    ${prb_list}    ${min_dss_ratio}    ${max_dss_ratio}    ${min_prb_ratio}    ${max_prb_ratio}
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup DSS Link
    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Coordination
    Set UL Resource Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Allocation    nor_subframe=${ALLOC_SUBFRAME}    prb_list=${prb_list}
    SANSA Muilt UE Register And PDU Session Setup    max_ue_num=${ATTACH_UE_NUM}

Set UL Resource Cell Reservation
    [Arguments]    ${min_prb_ratio}    ${max_prb_ratio}
    [Documentation]    This keyword is for ul resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_prb_ratio | Yes | The minimum value of PRB share ratio |
    ...    | max_prb_ratio | Yes | The maximum value of PRB share ratio |
    ...    Example:
    ...    | enb_dss_ul_cell_resource_reservation    | 2 | 1 | 30 | 70 |
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${command}    Set Variable    enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_dss_ul_cell_resource_reservation enb=2 cell=1 minimum_prb_share=${min_prb_ratio} maximum_prb_share=${max_prb_ratio}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}    timeout=3minutes
    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=2 cell=1

SANSA Muilt UE Register And PDU Session Setup
    [Arguments]    ${max_ue_num}    ${dl_tput}=60      ${ul_tput}=15
    : FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    \   SA 5G Attach        ${ue_id}
    \    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    \    SANSA_5G_PDU_Session_Setup_multiue       ${ue_id}
    \    Start DL Traffic        ${ue_id}   ${dl_tput}
    \    Start UL Traffic        ${ue_id}   ${ul_tput}
    \    Display_average_DL_and_UL_data        ${ue_id}
	
Display_average_DL_and_UL_data
    [Arguments]    ${ue_id}
    ${out_dl}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=dl
    Create File       ${OUTPUT_DIR}/dl_data1.txt    ${out_dl}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
    ${out_ul}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=ul
    Create File       ${OUTPUT_DIR}/ul_data1.txt    ${out_ul}
    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG UL : ${average_ul}    WARN
    [Return]    ${average_dl}    ${average_ul}

SANSA_5G_PDU_Session_Setup_multiue
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Start DL Traffic
    [Arguments]    ${ue_id}     ${dl_tput}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=dl trf_id\=1 mbps\=${dl_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
Start UL Traffic
    [Arguments]    ${ue_id}     ${ul_tput}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=ul trf_id\=1 mbps\=${ul_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Check DL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}    ${number}
    ${filters}    Set Variable    dlFdSchedData
    ${out_file_name}    Set Variable    ${tti_csv_dir}/dlFdSchedData.csv
    ${result}    Set Variable    ${False}
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*dl.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify DL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
    Exit For Loop If    ${result}==${True}
    END
    Should Be True    ${result}==${True}

Verify DL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    dlFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:dlFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    dlFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
    Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}

Check UL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}    ${number}
    ${filters}    Set Variable    ulFdSchedData
    ${out_file_name}    Set Variable    ${tti_csv_dir}/ulFdSchedData.csv
    ${result}    Set Variable    ${False}
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*ul.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify UL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
    Exit For Loop If    ${result}==${True}
    END
    Should Be True    ${result}==${True}

Verify UL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only ulFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    ulFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:ulFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    ulFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
    Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}

Start And Stop Tti Trace
    Start GNB TTI Trace
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}

Test Ttitrace With Snapshot Mode Catch Continously
    [Arguments]    ${log_path}
    Catch Ttitrace Log    1s
    Decode TTI Trace And Send To Control PC One By One    ${log_path}/

Set CP Debug
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${CMD_OPEN_CP_DEBUG}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Cell Resource Allocation
    [Arguments]    ${nor_subframe}    ${prb_list}
    [Documentation]    This keyword is used to allocate cell resource.
    ...    | Input Parameters | Man. | Description |
    ...    | nor_subframe | Yes | The dl allocated normal subframes |
    ...    | prb_list | Yes | It shows the info of startprb and amount of prbs. e.g. 1,30 1:startprb    30:amount of prbs.|
    ...    Example:
    ...    | Cell Resource Allocation | 0010000000-0000001000-0000000000-0000000000-0000000000-0000001000-0000000000-0000000000 | 1,30 |
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL
    ...    allocation_start_time=immediate dl_allocated_normal_subframes=${nor_subframe}
    ute_wtssim.Execute Egate Command    ${command}
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1
    ...    dir=UL allocation_start_time=immediate ul_allocated_prb_list=${prb_list}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber    timeout=2minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    
    ...    Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber    partial_match=${true}
    Log To Console    \n${output}
