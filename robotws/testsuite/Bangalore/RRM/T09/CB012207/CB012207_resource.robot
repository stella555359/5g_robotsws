*** Settings ***
Documentation   :copyright: Nokia
...             :author: Shekhar
...             :contact: shekhar.vijay_barewar@nokia.com

Library          ../../../resources/python/BIP_Capture.py
Library          OperatingSystem
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Library          ../../../resources/python/CPRT_Capture.py
Library          String




*** Variables ***
${ECID_response_success_pattern}    Received ECID Measurement Response
${LMF_COMMAND_TIMEOUT}    10s


*** Keywords ***
Trigger Different delay simulation to get different InitialTAs for diff UEs before Attach
    [Arguments]   ${delay_1UE1}    ${delay_2UE2}    ${delay_3UE3}
    ${Testmode_profile_create_ue_p_delay_initial_UE1_Reg}    SET VARIABLE    ue_ta_nr profile_id=1 ue_p_delay_initial=${delay_1UE1}
    ute_wtssim.Execute Egate Command    ${Testmode_profile_create_ue_p_delay_initial_UE1_Reg}
    sleep    2s
    ${Testmode_activate_UE1_Reg}    SET VARIABLE   ue_testmode_set_nr id=1 testmode=ta action=activate profile_id=1
    ute_wtssim.Execute Egate Command    ${Testmode_activate_UE1_Reg}
    sleep    2s
    ${Testmode_profile_create_ue_p_delay_initial_UE2_Reg}    SET VARIABLE    ue_ta_nr profile_id=2 ue_p_delay_initial=${delay_2UE2}
    ute_wtssim.Execute Egate Command    ${Testmode_profile_create_ue_p_delay_initial_UE2_Reg}
    sleep    2s
    ${Testmode_activate_UE2_Reg}    SET VARIABLE   ue_testmode_set_nr id=2 testmode=ta action=activate profile_id=2
    ute_wtssim.Execute Egate Command    ${Testmode_activate_UE2_Reg}
    sleep    2s
    ${Testmode_profile_create_ue_p_delay_initial_UE3_Reg}    SET VARIABLE    ue_ta_nr profile_id=3 ue_p_delay_initial=${delay_3UE3}
    ute_wtssim.Execute Egate Command    ${Testmode_profile_create_ue_p_delay_initial_UE3_Reg}
    sleep    2s
    ${Testmode_activate_UE3_Reg}    SET VARIABLE   ue_testmode_set_nr id=3 testmode=ta action=activate profile_id=3
    ute_wtssim.Execute Egate Command    ${Testmode_activate_UE3_Reg}
Trigger Different delay simulation to get different InitialTAs for diff UEs before RRCReestablishment
    [Arguments]   ${delay_4UE1}    ${delay_5UE2}    ${delay_6UE3}
    ${Testmode_profile_create_ue_p_delay_initial_UE1_Re}    SET VARIABLE    ue_ta_nr profile_id=1 ue_p_delay_initial=${delay_4UE1}
    ute_wtssim.Execute Egate Command    ${Testmode_profile_create_ue_p_delay_initial_UE1_Re}
    sleep    2s
    ${Testmode_activate_UE1_Re}    SET VARIABLE   ue_testmode_set_nr id=1 testmode=ta action=activate profile_id=1
    ute_wtssim.Execute Egate Command    ${Testmode_activate_UE1_Re}
    sleep    2s
    ${Testmode_profile_create_ue_p_delay_initial_UE2_Re}    SET VARIABLE    ue_ta_nr profile_id=2 ue_p_delay_initial=${delay_5UE2}
    ute_wtssim.Execute Egate Command    ${Testmode_profile_create_ue_p_delay_initial_UE2_Re}
    sleep    2s
    ${Testmode_activate_UE2_Re}    SET VARIABLE   ue_testmode_set_nr id=2 testmode=ta action=activate profile_id=2
    ute_wtssim.Execute Egate Command    ${Testmode_activate_UE2_Re}
    sleep    2s
    ${Testmode_profile_create_ue_p_delay_initial_UE3_Re}    SET VARIABLE    ue_ta_nr profile_id=3 ue_p_delay_initial=${delay_6UE3}
    ute_wtssim.Execute Egate Command    ${Testmode_profile_create_ue_p_delay_initial_UE3_Re}
    sleep    2s
    ${Testmode_activate_UE3_Re}    SET VARIABLE   ue_testmode_set_nr id=3 testmode=ta action=activate profile_id=3
    ute_wtssim.Execute Egate Command    ${Testmode_activate_UE3_Re}
Multiple UEs SA L3 call should be successful
    [Arguments]  ${Start_UE}  ${MAX_UE}  ${DL_Rate}  ${UL_Rate}  ${pdu}=${Pdu_session_ID}  ${Traffic_rate_SA}=${Trf_rate_SA}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
        log to console   ${UE}th UE reg triggering now...
        ${Status}   Run Keyword and Return status  UE Register should be Successful     ${UE}   gw_id=1
        Run keyword if   ${status}==${True}    BuiltIn.Log    UE Registration Done...${UE}    WARN
        Run keyword if   ${status}==${False}    Exit For Loop
        sleep   2s
        Run Keyword And Continue On Failure  Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}  pdu_id=${pdu}  qfi_id=${qfi_id}
        ...  Traffic_rate=${Traffic_rate_SA}  ul_rate=${UL_Rate}
        Run Keyword And Continue On Failure  Trigger DL Non Bursty Data Traffic for SA   ue_id=${UE}  pdu_id=${pdu}  qfi_id=${qfi_id}
        ...  Traffic_rate=${Traffic_rate_SA}  dl_rate=${DL_Rate}
        sleep   2s
    END
Grep initialTA value and calculate NTA index
    [Arguments]    ${log_file}
    ${intialTA_values_grepped}    Run    command=grep -oP 'initialTa[:=]\\K\\d+' ${log_file}[btslog]/gnb_syslog.log
    @{intialTA_values}=    Split String    ${intialTA_values_grepped}    \n
    log    ${intialTA_values}   INFO    #these are the values
    ${NTA_index_list_values}    Calculate NTA Index    ${intialTA_values}
    [Return]    ${NTA_index_list_values}
#   Set Variable  ${NTA_index_list_values}  @{NTA_index_list_values}
Calculate NTA Index
    [Arguments]    ${initialTa_values}
    ${NTA_index_list_values}    Create List
    FOR    ${initialTa}    IN    @{initialTa_values}
        ${multiplied_value}    Evaluate    int(${initialTa} * (16/8) * (64/128))
        Append To List    ${NTA_index_list_values}    ${multiplied_value}
    END
    [Return]    ${NTA_index_list_values}
Trigger E-CID measurement initiation request with SSRSRP_SSRSQ_NR-TADV from SimLMF
    [Arguments]    ${ue_id}
    ${lmf_send_ecid_meas_req_part1}  SET VARIABLE  lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1
    ${lmf_send_ecid_meas_req_part2}  SET VARIABLE  report_characteristics=OnDemand meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    ${lmf_send_ecid_meas_req}=    Catenate    SEPARATOR=${SPACE}     ${lmf_send_ecid_meas_req_part1}    ${lmf_send_ecid_meas_req_part2}
    Log    ${lmf_send_ecid_meas_req}    INFO
    ute_wtssim.Execute Egate Command And Wait For Data    ${lmf_send_ecid_meas_req}    pass_regexp=${ECID_response_success_pattern}
    ...     timeout=${LMF_COMMAND_TIMEOUT}
Grep NR-TADV value reported at nrppa PDU in E-CID measurement initiation response
    [Arguments]    ${file_path}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.NR_TADV
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${NR-TADV_nrppa}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    ${NR-TADV_nrppa}=   Set Variable    ${NR-TADV_nrppa}[0]
    ${NR-TADV_nrppa}    String.Strip String     ${NR-TADV_nrppa}[8:]
    ${NR-TADV_nrppa_int}    Evaluate    int(${NR-TADV_nrppa})
    [Return]    ${NR-TADV_nrppa_int}
Grep SSRSRP value reported at nrppa PDU in E-CID measurement initiation response
    [Arguments]    ${file_path}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.sS_RSRP_PerSSB
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${SSRSRP}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.valueSS_RSRP  attrib_name=showname
    Builtin.Log   ${SSRSRP}
    Should Not Be Empty    ${SSRSRP}
    [Return]    ${SSRSRP}
Grep SSRSRQ value reported at nrppa PDU in E-CID measurement initiation response
    [Arguments]    ${file_path}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.sS_RSRP_PerSSB
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${SSRSRQ}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.valueSS_RSRQ  attrib_name=showname
    Builtin.Log   ${SSRSRQ}
    Should Not Be Empty    ${SSRSRQ}
    [Return]    ${SSRSRQ}
LMF MultiUE E-CID meas initiation req for RSRP_RSRQ_NR-TADV and Verify in E-CIDgNB res and create allUE NR-TADV list after Registration
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    ${nr_tadv_list}    Create List
    FOR    ${ueidx}  IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        log to console    CPRT log capture started for UE${ueidx}
        Start Log    cprt
        sleep    5s
        Trigger E-CID measurement initiation request with SSRSRP_SSRSQ_NR-TADV from SimLMF    ${ueidx}
        sleep    8s
        ${path}    Set test Variable    ${EMPTY_VAR}
        ${path}   Stop Log    cprt    test_scenario=ue${ueidx}_NR-TADV_after_Registration
        ${NR-TADV}  Grep NR-TADV value reported at nrppa PDU in E-CID measurement initiation response    ${path}[cprt]/NODECPRT_GNB.pcap
        sleep    2s
        Append To List    ${nr_tadv_list}    ${NR-TADV}
        sleep    2s
        Grep SSRSRP value reported at nrppa PDU in E-CID measurement initiation response  ${path}[cprt]/NODECPRT_GNB.pcap
        sleep    2s
        Grep SSRSRQ value reported at nrppa PDU in E-CID measurement initiation response  ${path}[cprt]/NODECPRT_GNB.pcap
        sleep    2s
    END
    [Return]    ${nr_tadv_list}
LMF MultiUE E-CID meas initiation req for RSRP_RSRQ_NR-TADV and Verify in E-CIDgNB res and create allUE NR-TADV list after Restablishment
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    ${nr_tadv_list}    Create List
    FOR    ${ueidx}  IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        log to console    CPRT log capture started for UE${ueidx}
        Start Log    cprt
        sleep    5s
        Trigger E-CID measurement initiation request with SSRSRP_SSRSQ_NR-TADV from SimLMF    ${ueidx}
        sleep    8s
        ${path}    Set test Variable    ${EMPTY_VAR}
        ${path}   Stop Log    cprt    test_scenario=ue${ueidx}_NR-TADV_after_RRCtrestablishmnet
        log to console    CPRT log capture stoped for ${ueidx}
        ${NR-TADV}  Grep NR-TADV value reported at nrppa PDU in E-CID measurement initiation response    ${path}[cprt]/NODECPRT_GNB.pcap
        sleep    2s
        Append To List    ${nr_tadv_list}    ${NR-TADV}
        sleep    2s
        Grep SSRSRP value reported at nrppa PDU in E-CID measurement initiation response  ${path}[cprt]/NODECPRT_GNB.pcap
        sleep    2s
        Grep SSRSRQ value reported at nrppa PDU in E-CID measurement initiation response  ${path}[cprt]/NODECPRT_GNB.pcap
        sleep    2s
    END
   [Return]    ${nr_tadv_list}

Calculated NTA Index from InitialTA should be equal TADV reported in NRppa
    [Arguments]    ${list1}    ${list2}
    ${length1}    Get Length    ${list1}
    ${length2}    Get Length    ${list2}
    Should Be Equal    ${length1}    ${length2}    Lists are of different lengths
    FOR    ${index}    IN RANGE    ${length1}
        ${value1}    Get From List    ${list1}    ${index}
        ${value2}    Get From List    ${list2}    ${index}
        Should Be Equal    ${value1}    ${value2}    Values at index ${index} are not equal
    END
Collect ECID Measurement Request Response Counters
    Log To Console    Collecting Counters
    [Documentation]      This KW will collect counters
    ...                   M55113C00013
    ...                   M55113C00014
    ...                   M55113C00015
    [Arguments]       ${nrcell}=NRCELL-1
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1_C1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55113C00013    moc=${nrcell}
    ${Cell1_C2}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55113C00014    moc=${nrcell}
    ${Cell1_C3}    Get PM counter value    pm_files_location=${pm_dir1}    pi_id=M55113C00015    moc=${nrcell}
    log to console       ${Cell1_C1}      ${Cell1_C2}    ${cell1_c3}
    [Return]    ${Cell1_C1}      ${Cell1_C2}      ${cell1_c3}

Validate Counters after Registration and before RRCRestablishment of UEs
    Wait until the next Measurement Period starts
#    Sleep    300s
    Log To Console   Collecting and Validating Counters
    ${M55113C00013}    ${M55113C00014}    ${M55113C00015}    Collect ECID Measurement Request Response Counters
    Set Suite Variable    ${M55113C00013}
    Set Suite Variable    ${M55113C00014}
    Set Suite Variable    ${M55113C00015}
    Log To Console    ${M55113C00013}    ${M55113C00014}    ${M55113C00015}
    Should Be True    ${M55113C00013} == 3
    Should Be True    ${M55113C00014} == 3
    Should Be True    ${M55113C00015} == 0

Validate Counters after RRCRestablishment of UEs
    Wait until the next Measurement Period starts
#    Sleep    300s
    Log To Console   Collecting and Validating Counters
    ${M55113C00013}    ${M55113C00014}    ${M55113C00015}    Collect ECID Measurement Request Response Counters
    Set Suite Variable    ${M55113C00013}
    Set Suite Variable    ${M55113C00014}
    Set Suite Variable    ${M55113C00015}
    Log To Console    ${M55113C00013}    ${M55113C00014}    ${M55113C00015}
    Should Be True    ${M55113C00013} == 3
    Should Be True    ${M55113C00014} == 3
    Should Be True    ${M55113C00015} == 0