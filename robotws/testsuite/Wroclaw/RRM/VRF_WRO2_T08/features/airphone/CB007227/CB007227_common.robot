*** Settings ***
Documentation
...            title:        CB007227-SR   PCMD/call trace RAN UE ID
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com,
...                          Jakub Rutyna, jakub.rutyna@nokia.com,
...                          Bartosz Szlezak, bartosz.szlezak@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com,
...                          Jakub Rutyna, jakub.rutyna@nokia.com

Library    ta_messaging
Library    ta5g_pm_counters
Resource    ../../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot
Resource    ../../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/wts.robot
#Resource    ./CB008187_common.robot
Resource    variables.robot
Resource    7227_B_variables.robot

*** Variables ***
@{TSHARK_NSETAPX}       -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148

*** Keywords ***
Perform NSA Handover To Target PCI
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${Empty}
    ${out}    Perform Intra-GNB X2 NSA Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    pass_regexp=${pass_regexp}
    RETURN    ${out}

Perform SA Inter-RAT HO
    [Arguments]    ${ue_id}      ${target_pci}
    ${out}    Perform Inter-RAT SA Handover To Target PCI    ue_id=${ue_id}    target_pci=${target_pci}    event=B2
    RETURN    ${out}

Get UE RAN IDs from PCAP
    [Documentation]    Extracts UE RAN IDs field values from StartRecordingSession messages and returns values
    ...                converted to DEC. Verifies expected ``$\{sessions\}`` number.
    [Arguments]    ${pcap_filepath}    ${sessions}
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148
    ...    -e    nsetapx.TraceMessage    -E    separator\=';'
    ${fields}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}    options=${options}
    ...    field_name=nsetapx.ranUeId    filter=nsetapx.TraceMessage == 4
    Length Should Be    ${fields}    ${sessions}
    ...    msg=Unexpected number of StartRecordingSession messages with ranUeId field.
    ${dec_ids}    Create List
    FOR    ${string}    IN    @{fields}
      ${msg_type}    ${ids}    Split String    ${string}    ;
      ${types_list}    Split String    ${msg_type}    ,
      ${ids_list}    Split String    ${ids}    ,
      ${start_ind}    Get Index From List    ${types_list}    4
      ${dec_id}    Evaluate    str(int("${ids_list}[${start_ind}]", 16))
      Append To List    ${dec_ids}    ${dec_id}
    END
    RETURN    ${dec_ids}

Verify UE RAN IDs in StopRecordingSession in PCAP
    [Arguments]    ${pcap_filepath}    ${sessions}    ${ran_ue_ids}
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148
    ...    -e    _ws.col.Info    -E    separator\=';'
    ${fields}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}    options=${options}
    ...    field_name=nsetapx.ranUeId    filter=nsetapx.TraceMessage == 5
    Length Should Be    ${fields}    ${sessions}
    ...    msg=Unexpected number of StopRecordingSession messages with ranUeId field.
    FOR    ${ran_ue_id}    ${string}    IN ZIP    ${ran_ue_ids}    ${fields}
      ${info}    ${ids}    Split String    ${string}    ;
      ${info_list}    Split String    ${info}
      ${ids_list}    Split String    ${ids}    ,
      ${start_ind}    Get Index From List    ${info_list}    StopRecordingSession
      Should Be True    int("${ids_list}[${start_ind}]", 16) == int("${ran_ue_id}")
      ...    msg=UE RAN ID from StartRecordingSession does not match StopRecordingSession message.
    END

Start NSA L3 Call to Sim GNB
    [Arguments]    ${ue_id}    ${target_gnb_cell}=1    ${dl_tput}=10mbps    ${ul_tput}=10mbps
    Start NSA L3 Call    ue_id=${ue_id}    target_gnb=3    target_gnb_cell=${target_gnb_cell}
    ...    dl_tput=${dl_tput}    ul_tput=${ul_tput}


Setup devices aliases
    Create ues alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Enable Internal Mirroring For Alias    gNB2

Get RAN UE ID reported by both entities from CU level
    [Documentation]     This keyword gets the RAN UE ID value taken from report messages (not StartRecordingSession)
    ...                 coming from gNB CU-CP or CU-UP.
    ...             - ``pcap_filepath``: Path which contains pcap, Default: Empty
    ...             - ``entity``: String value defining from where the reports shall be taken. Example: entity=cu-up
    ...             - ``nr_ues``: Number of traced UEs.
    ...             - ``trace_id``: This argument corresponds to the different values for trace type message
    [Arguments]    ${pcap_filepath}     ${entity}     ${nr_ues}    ${trace_id}=6
    ${entity_val}     Set variable if     '${entity}' == 'cu-up'
    ...    nsetapx.CuUpRecordingSessionReport_element
    ...    nsetapx.CuRecordingSessionReport_element
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148
    ...    -e    nsetapx.TraceMessage    -E    separator\=';'
    ${fields}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}    options=${options}
    ...    field_name=nsetapx.ranUeId    filter=nsetapx.TraceMessage == ${trace_id} && ${entity_val}
    ${dec_ids}    Create List
    FOR    ${string}    IN    @{fields}
      ${msg_type}    ${ids}    Split String    ${string}    ;
      ${types_list}    Split String    ${msg_type}    ,
      ${ids_list}    Split String    ${ids}    ,
      ${start_ind}    Get Index From List    ${types_list}    4
      ${dec_id}    Evaluate    str(int("${ids_list}[${start_ind}]", 16))
      Append To List    ${dec_ids}    ${dec_id}
    END
    ${decs_list}      Remove Duplicates	   ${dec_ids}
    Length Should Be    ${decs_list}    ${nr_ues}
    ...    msg=Unexpected number of reports containing messages with ranUeId field.
    RETURN    ${decs_list}

Get Message Timestamp List From Pcap
    [Arguments]    ${filter}=f1ap.UEContextSetupRequest_element    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    ${timestamps_list}    Create List
    ${message_amount}     Count Messages In PCAP File    pcap_filepath=${pcap_filepath}    filter=${filter}
    FOR    ${message}    IN RANGE    0    ${message_amount}
        ${message_timestamp}    Get Message Timestamp From Pcap
        ...    pcap_filepath=${pcap_filepath}     filter=${filter}    which_message=${message}
        Append To List    ${timestamps_list}    ${message_timestamp}
    END
    RETURN    ${timestamps_list}

Get Message Timestamp From Pcap
    [Arguments]    ${filter}=f1ap.UEContextSetupRequest_element    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    ...    ${which_message}=-1
    @{messages_timestamp}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    field_name=frame.time_epoch
    ...    filter=${filter}
    ${date}    Convert To String    ${messages_timestamp}[${which_message}]
    ${splitted_date}    Split String    ${date}    separator=.
    Log to console    ${splitted_date}
    RETURN    ${splitted_date}[0]

Count Messages In PCAP File
    [Arguments]    ${pcap_filepath}    ${filter}    ${options}=@{Empty}
    ${result}    Run Process And Expect Success    tshark    @{options}    -Y    ${filter}    -r    ${pcap_filepath}
    ${message_amount}    Get Line Count    ${result.stdout}
    RETURN    ${message_amount}

Get CRNTI Of UE
    [Arguments]  ${ue_id}
    ${egate_output}    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ...    pass_regexp=C-RNTI
    ${CRNTI_line}    Get Regexp Matches    ${egate_output}    C-RNTI .* [0-9]+
    ${Actual_CRNTI}    Get Regexp Matches  @{CRNTI_line}[0]   [0-9]+
    RETURN    ${Actual_CRNTI}[0]

Get Active UEs CRNTI
    ${ues_crnti_dict}  Create Dictionary
    FOR    ${ue_id}    IN    @{TEST_SA_UEs}
        ${ue_crnti}    Get CRNTI Of UE    ue_id=${ue_id}
        Set To Dictionary    ${ues_crnti_dict}    ${ue_id}=${ue_crnti}
    END
    RETURN    ${ues_crnti_dict}

Get Active UEs RAN ID
    @{ues_ran_ue_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=e1ap.GNB_CU_CP_UE_E1AP_ID
    ...    filter=e1ap.BearerContextSetupRequest_element
    ${ues_ran_id_dict}  Create Dictionary
    FOR    ${ue_id}    IN    @{TEST_SA_UEs}
        Set To Dictionary    ${ues_ran_id_dict}    ${ue_id}=${ues_ran_ue_id}[0]
        Remove From List     ${ues_ran_ue_id}    0
    END
    RETURN    ${ues_ran_id_dict}

Get CRNTI Of Last Attached NSA UE
    ${cmd}    Set Variable
    ...    grep -wo "newUE-Identity .*" ${TEST_log_dir}/Egate/egate_console.log | grep -Eo '[[:digit:]]+'
    ${crnti_list}    Run And Return Rc And Output    ${cmd}
    ${crnti_list}    Split String    ${crnti_list}[-1]    \n
    RETURN     ${crnti_list[-1]}

Get PCMD Records By UE CRNTI
    [Documentation]    This KW is not applicable for CU-UP PCMD records as those records do not support crnti
    [Arguments]    ${pcap_filepath}    ${UE_CRNTI}    ${save_to_file}=${Empty}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${pcap_filepath}
    #---------------------------------------------------------------------------------------------------------------
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148    -J    nsetapx
    ${json_file}    Convert PCAP to JSON
    ...    input_filepath=${pcap_filepath}    filter=nsetapx    options=${options}
    ${json_string}    OperatingSystem.Get File    ${json_file}
    ${json_obj}    json.loads    ${json_string}
    ${records}    Get Items Matching Regexp From PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    pattern=RecordingSessionReport_element
    ...    filter=nsetapx
    ...    search_for="nsetapx": {    replace_with="nsetapx_$": {    remove_per=yes
    ...    options=${options}
    @{items}    Create List
    FOR    ${item}    IN    @{records}
        ${keys}     Get Dictionary Keys    ${item}     sort_keys=False
        Continue For Loop If    '${keys[-1]}' == 'nsetapx.CuUpRecordingSessionReport_element'
        ${item1}    Get From Dictionary    ${item}     ${keys[-1]}
        ${item2}    Get From Dictionary    ${item1}    nsetapx.recordList_tree
        ${item3}    Get From Dictionary    ${item2}    Item 0
        ${keys}     Get Dictionary Keys    ${item3}    sort_keys=False
        ${item4}    Get From Dictionary    ${item3}    ${keys[-1]}
        ${crnti}    Get From Dictionary    ${item4}    nsetapx.crnti
        IF    '${UE_CRNTI}' == '${crnti}'
        ...    Append To List    ${items}    ${item}
    END
    ${PCMD_records}    find_nodes_matching_regexp    ${items}    nsetapx.*Record_tree
    IF    ${save_to_file} != ''    Save Data as JSON File    data=${PCMD_records}    filepath=${save_to_file}
    RETURN    ${PCMD_records}

Get PCMD Records By RAN UE ID
    [Documentation]    As for now this KW works correctly for CU-UP PCMD records. For DU and CU it is possible that those early records
    ...   will lack ranUeId field
    [Arguments]    ${pcap_filepath}    ${RAN_UE_ID}    ${save_to_file}=${Empty}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${pcap_filepath}
    #---------------------------------------------------------------------------------------------------------------
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148    -J    nsetapx
    ${json_file}    Convert PCAP to JSON
    ...    input_filepath=${pcap_filepath}    filter=nsetapx    options=${options}
    ${json_string}    OperatingSystem.Get File    ${json_file}
    ${json_obj}    json.loads    ${json_string}
    ${records}    Get Items Matching Regexp From PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    pattern=RecordingSessionReport_element
    ...    filter=nsetapx
    ...    search_for="nsetapx": {    replace_with="nsetapx_$": {    remove_per=yes
    ...    options=${options}
    @{items}    Create List
    FOR    ${item}    IN    @{records}
        ${keys}     Get Dictionary Keys    ${item}     sort_keys=False
        Continue For Loop If    '${keys[-1]}' != 'nsetapx.CuUpRecordingSessionReport_element'
        ${item1}    Get From Dictionary    ${item}     ${keys[-1]}
        ${ran-ue-id}    Get From Dictionary    ${item1}    nsetapx.ranUeId
        ${ran-ue-id}    Replace String    ${ran-ue-id}    :    ${EMPTY}
        ${dec_ran-ue-id}    Convert To Integer    ${ran-ue-id}    16
        IF    '${RAN_UE_ID}' == '${dec_ran-ue-id}'
        ...    Append To List    ${items}    ${item}
    END
    ${PCMD_records}    find_nodes_matching_regexp    ${items}    nsetapx.*Record_tree
    IF    ${save_to_file} != ''    Save Data as JSON File    data=${PCMD_records}    filepath=${save_to_file}
    RETURN    ${PCMD_records}

Verify ulRbRlcThroughputRecord And dlRbPdcpThroughputRecord Data In PCMD Records
    [Arguments]    ${ue_id}    ${record_name}    ${PCMD_records_file_path}    ${PM_counters}
    Should Be True    '${record_name}' in ('ulRbRlcThroughputRecord','dlRbPdcpThroughputRecord')   msg=Invalid KW parameter: record_name
    ${VOL_UE_TPUT_TOT}    ta5g_pm_counters.Get Pm Counter Value    ${${record_name}_VOL_UE_TPUT_TOT}    ${PM_MOID_NRCELL-${ue_id}}    ${PM_counters}
    ${VOL_UE_TPUT_TOT}    Evaluate    ${VOL_UE_TPUT_TOT}[0] * 1000
    ${TIME_UE_TPUT}    ta5g_pm_counters.Get Pm Counter Value    ${${record_name}_TIME_UE_TPUT}    ${PM_MOID_NRCELL-${ue_id}}    ${PM_counters}
    ${rc1}    ${output1}    Run And Return Rc And Output
    ...    grep -A 12 ${record_name} ${PCMD_records_file_path} | grep -w timeOfUeDataBurst[RT]x | cut -d "\\"" -f4
    ${rc2}    ${output2}    Run And Return Rc And Output
    ...    grep -A 12 ${record_name} ${PCMD_records_file_path} | grep -w sumOf.*Sdu[RT]xDataBurstBytes | cut -d "\\"" -f4
    @{list_of_all_timeOfUeDataBursts}    Split String    ${output1}    \n
    @{list_of_all_sumOfSduDataBurstBytes}    Split String    ${output2}    \n
    ${sum_of_timeOfUeDataBurst}            Set Variable    0
    ${sum_of_sumOfSduDataBurstBytes}    Set Variable    0
    FOR    ${timeOfUeDataBurst}    IN    @{list_of_all_timeOfUeDataBursts}
        ${timeOfUeDataBurst}    Convert To Integer    ${timeOfUeDataBurst}
        ${sum_of_timeOfUeDataBurst}    Evaluate    ${sum_of_timeOfUeDataBurst} + ${timeOfUeDataBurst}
    END
    FOR    ${sumOfSduDataBurstBytes}    IN    @{list_of_all_sumOfSduDataBurstBytes}
        ${sumOfSduDataBurstBytes}    Convert To Integer    ${sumOfSduDataBurstBytes}
        ${sum_of_sumOfSduDataBurstBytes}    Evaluate    ${sum_of_sumOfSduDataBurstBytes} + (${sumOfSduDataBurstBytes} * 8)
    END
    Should Be Equal    ${sum_of_timeOfUeDataBurst}    ${TIME_UE_TPUT}[0]
    Compare Values With A Margin    value=${sum_of_sumOfSduDataBurstBytes}    expected_value=${VOL_UE_TPUT_TOT}    margin_percentage=1
    Verify Throughput From Records    ${list_of_all_sumOfSduDataBurstBytes}    ${list_of_all_timeOfUeDataBursts}    margin_percentage=10

Compare Values With A Margin
    [Arguments]    ${value}    ${expected_value}    ${margin_percentage}
    ${margin}    Evaluate    ${margin_percentage} / 100.0
    ${diff}    Evaluate    abs(${expected_value} - ${value})
    IF    ${diff} > (${expected_value} * ${margin})    Fail    Compared values differ more than the margin.

Get Message Count From PCAP
    [Arguments]    ${pcap_filepath}    ${filter}    ${options}=@{Empty}
    ${result}    Run Process And Expect Success    tshark    @{options}    -Y    ${filter}    -r    ${pcap_filepath}
    ${message_count}    Get Line Count    ${result.stdout}
    RETURN    ${message_count}

Get Record Count From JSON
    [Arguments]    ${json_filepath}    ${record_name}
    ${rc}    ${output}    Run And Return Rc And Output    grep ${record_name} ${json_filepath} | wc -l
    @{message_count}    Split String    ${output}    \n
    RETURN    ${message_count}[0]

Perform Radio Bearer Throughput PCMD Record Verification
    [Arguments]    ${UE_ID}    ${PM_counters_filepath}    ${pcmd_records_collection}
    ...    ${json_filepath}    ${record_name}    ${expect_end_marker_true}=${True}
    Should Be True    '${record_name}' in ('ulRbRlcThroughputRecord','dlRbPdcpThroughputRecord')   msg=Invalid KW parameter: record_name
    ${recordsAmount}    Get Record Count From JSON    json_filepath=${json_filepath}    record_name=${record_name}
    ${PCMD_Seq}    Create List
    FOR    ${record}    IN RANGE    ${recordsAmount}-1
        ${prepared_dict}   Create Dictionary    &{${record_name}_EM0}
        Append To List     ${PCMD_Seq}    ${prepared_dict}
    END
    IF    ${expect_end_marker_true} == ${False}    Append To List     ${PCMD_Seq}    ${${record_name}_EM0}
    IF    ${expect_end_marker_true} == ${True}     Append To List     ${PCMD_Seq}    ${${record_name}_EM1}
    Verify PCMD Records Sequence in Collection   ${pcmd_records_collection}     ${PCMD_Seq}
    Verify ulRbRlcThroughputRecord And dlRbPdcpThroughputRecord Data In PCMD Records
    ...    ue_id=${UE_ID}    record_name=${record_name}    PCMD_records_file_path=${json_file_path}    PM_counters=${PM_counters_filepath}

Verify Throughput From Records
    [Arguments]    ${throughput_bytes}    ${time}    ${margin_percentage}
    ${size_bytes}    Get Length    ${throughput_bytes}
    ${size_time}    Get Length    ${time}
    Should Be Equal As Integers    ${size_time}    ${size_bytes}    msg=Mismatch in the lists size
    FOR    ${index}    IN RANGE    ${size_bytes}
        Should Be True    ${throughput_bytes}[${index}] >= 0    msg=Invalid throughput value
        Should Be True    ${time}[${index}] >= 0    msg=Invalid duration
        Continue For Loop If    ${throughput_bytes}[${index}] == 0 and ${time}[${index}] == 0
        ${throughput_value_from_record}    Evaluate    8000*int(${throughput_bytes}[${index}])/int(${time}[${index}])
        Compare Values With A Margin    value=${throughput_value_from_record}    expected_value=10000000    margin_percentage=${margin_percentage}
    END

Perform ${ho_type} Inter-GNB Handover to ${node_type} GNB with UE-${ue_id} using ${event} Event
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Simulated GNB Cell has PCI 52 and External GNB Cell has PCI 50.
    &{pci}    Create Dictionary    Sim=52    Ext=50
    Run Keyword    Perform Inter-GNB ${ho_type} Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${pci}[${node_type}]    event=${event}
