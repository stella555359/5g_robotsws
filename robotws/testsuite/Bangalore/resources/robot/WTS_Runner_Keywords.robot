*** Settings ***
Documentation    :copyright: Nokia

Library          ../python/check_cell_throughput.py    WITH NAME    Cell_TPT
*** Variables ***
${Ng_link_pattern}    NG link is Up
${Address_distribution_pattern}    Address Distribution is complete
${Cell_setup_complete_pattern}    Cell Setup completed
${UE_SIB_decoding_pattern}    SystemInformationBlockType1
${UE_register_complete_pattern}    .*REGISTRATION COMPLETE.*
${Register_complete_pattern}    REGISTRATION COMPLETE
${Initial_context_setup_pattern}    Initial Context Setup Successful
${Initial_UE_message_pattern}    I\nnitial UE Message Success
${Initial_UE_success_pattern}    .*Initial UE Message Success.*
${PDU_session_resource_setup_response}      PDU SESSION RESOURCE SETUP RESPONSE
${Pdu_session_mod_patten}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${Pdu_session_qos_patten}      QoS Routing Table
${pdu_addition_pattern}        Pdu Session Resource Setup Response Message
${pdu_del_pattern}             Received Pdu Session Resource Release Response Message
${UE_deregister_pattern}    UE Context Release Complete
${X2_link_pattern}    ENB-1: X2AP Link with GNB-2 .* is up
${LTE_attach_pattern}    UE IS ACTIVE
${UE_attach_pattern}    reported successful RA
${UE_5GDetach_pattern}    Bearer-type change from SCG-split to MCG
${UE_detach_pattern}    detached
${UE_reattach_pattern}    UE IS ACTIVE
${UE_RLF_pattern}     radioNetwork: rl-failure-rlc
${Trf_type}    internal
${GUI_Snapshot}    False

${Timeout_SA}    40
${Timeout_NSA}    300
${Total_Timeout}    5 min
${Retry_Timeout}    15 sec
${UE_Reattach_sleep}    20 sec
${UE_ID_SANSA}    11
${eNB_ID}    1
${eNB_target}    2
${Target_gNB}    2
${Target_Cells}    1
${Bearer_ID}    2
${Traffic_ul_rate_SA}    3
${Traffic_ul_rate_FDD}    3
${Traffic_ul_rate_TDD}    5
${Traffic_dl_rate}    5
${Traffic_ul_rate_TDD_mmwv}    2
#${Param}      0 rs_result=126:124:125 rs_result_index=1 rs_result=::125

*** Keywords ***
UE Register should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
#    wtsrunner.enb_x2_link_up   enb=${eNB_ID}   target=${eNB_target}
#    ${output}    Read WTS Output Until Pattern Matches    ${Ng_link_pattern}    ${Timeout_SA}
#    Log to Console    ---> ${Ng_link_pattern}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
#    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

UE Register should be Successful simulated gNB
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant for simulated gNB
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
#    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_response}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

UE Register should be Successful And Fetch RNTI
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
	Log to Console             ue_register_is_ok with ${crnti_value}
    BuiltIn.Log                ue_register_is_ok with ${crnti_value}
	[Return]      ${crnti_value}

UE PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    BuiltIn.Log                ue_pdu_addition_is_ok

UE PDU Modfication should be Successful
     [Arguments]     ${ue_id}      ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_add}=${Q_O_ADD}
     wtsrunner.ue_pdu_session_modify      ue=${ue_id}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}    by=amf
     ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
     Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
     Log to Console  ${Pdu_session_mod_patten}

UE Deregister should be Successful
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    wtsrunner.ue_deregister    id=${ue_id}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    BuiltIn.Log                ue_deregister_is_ok

UE Deregister should be Successful And Fetch RNTI
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    wtsrunner.ue_deregister    id=${ue_id}    ue_deregister_type=switch_off
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    BuiltIn.Log                ue_deregister_is_ok with ${crnti_value}
	[Return]      ${crnti_value}

Trigger DL Traffic for SA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}
    ...    period_ms=40
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger DL Data Traffic for SA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the max 175 DL data Traffic for the SA variant
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}    dir=dl    ${Traffic_rate}=${dl_rate}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}     ${Traffic_rate}=${ul_rate}
    ...    period_ms=40
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully


Trigger UL Non Bursty Data Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}   ${qfi_id}=${QFI_ID}
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    ${Traffic_rate}=${ul_rate}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Trigger DL Non Bursty Data Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${dl_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}   ${qfi_id}=${QFI_ID}
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    ${Traffic_rate}=${dl_rate}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully


Trigger UL Data Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the max 175 UL data Traffic for the SA variant
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}    dir=ul    ${Traffic_rate}=${ul_rate}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Stop Data Traffic for SA
    [Arguments]    ${ue_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Data Traffic for NSA
    [Arguments]    ${ue_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

TRF Data Stop for SA
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${trf_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_id}   pdu=${pdu_id}    dir=${dir}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

TRF Data Stop for NSA
    [Arguments]    ${ue_id}    ${Bearer_ID}    ${dir}    ${trf_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_id}    id=${Bearer_ID}      dir=${dir}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

DL TRF Data Stop for SA
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${trf_id}
    [Documentation]    This keyword stops the DL Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_id}   pdu=${pdu_id}    dir=${dir}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Stopped Downlink Internal traffic on Ue   timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Validate DL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    WTS_Runner_Keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    WTS_Runner_Keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate DL Traffic For SA for high data
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss for high data      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate UL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    WTS_Runner_Keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    WTS_Runner_Keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}

Traffic for SA should be Successful
    [Arguments]    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_SA}
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    Start and Validate Traffic For SA    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}
    BuiltIn.Log    traffic_is_ok

Start and Validate Traffic For SA
    [Arguments]    ${dl_rate}=5    ${ul_rate}=3    ${duration}=30sec
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=1   qfi=${qfi_id}    dir=dl    mbps=${dl_rate}
    ...    period_ms=40
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_start     ue=${ue_id}   pdu=1   qfi=${qfi_id}    dir=ul    mbps=${ul_rate}
    ...    period_ms=40
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    Sleep             ${duration}
    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic For SA    ${dl_rate}    ${ul_rate}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!
    Log to Console    Stopping DL + UL Traffic...
    wtsrunner.trf_data_stop     ue=${ue_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
#    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic For SA    ${dl_rate}    ${ul_rate}
#    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!

Validate Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${ul_rate}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

    wtsrunner.bearer_stats  ue=${ue_id}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}

Check Average Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Check DL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${data_loss}        Set Variable    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})
    ${bytes_sent_int}   Evaluate   ${bytes_sent_int} + 1000
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
#   BuiltIn.Log                 "Below is WA for ASIL Traffic issue seen in some TLs..."
#   ${data_loss}        Set Variable if    "${gnb_sm_hardware}"=="ASIL"    0.02    0.01

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    DL Bytes received complete (${bytes_rec[0]})
    ...               ELSE
    ...               BuiltIn.Log     DL Data Loss! Bytes Received (${bytes_rec[0]}) not matching given threshold! Sent (${bytes_sent[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Check DL Data Loss for high data
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_sent_int}=   Evaluate   ${bytes_sent_int} + 3000
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
#   BuiltIn.Log                 "Below is WA for ASIL Traffic issue seen in some TLs..."
#   ${data_loss}        Set Variable if    "${gnb_sm_hardware}"=="ASIL"    0.02    0.01
    ${data_loss}        Set Variable    0.06
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    DL Bytes received complete (${bytes_rec[0]})
    ...               ELSE
    ...               BuiltIn.Log     DL Data Loss! Bytes Received (${bytes_rec[0]}) not matching given threshold! Sent (${bytes_sent[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}


Check UL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_scg}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_all}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${data_loss}        Set Variable    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})
    ${bytes_sent_int}   Evaluate   ${bytes_sent_int} + 1000
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
#   BuiltIn.Log                  "Below is WA for ASIL Traffic issue seen in some TLs..."
#   ${data_loss}        Set Variable if    "${gnb_sm_hardware}"=="ASIL"    0.02    0.01

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    UL Bytes sent complete (${bytes_sent[0]})
    ...               ELSE
    ...               BuiltIn.Log     UL Data Loss! Bytes Sent (${bytes_sent[0]}) not matching given threshold! Received (${bytes_rec[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

X2AP Link Should be UP  #NSA
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=${eNB_ID}    target=${eNB_target}
    Read WTS Output For Pattern And Print matching Lines    ${X2_link_pattern}    ${Timeout_NSA}
    BuiltIn.Log    x2_is_ok

LTE Attach should be Successful     #NSA
    [Arguments]    ${NSA_UE_ID}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
#    wtsrunner.enb_x2_link_up   enb=${eNB_ID}   target=${eNB_target}
#    ${output}    Read WTS Output Until Pattern Matches    ${Ng_link_pattern}    ${Timeout_SA}
#    Log to Console    ---> ${Ng_link_pattern}
    wtsrunner.ue_attach    id=${NSA_UE_ID}
    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok

UE Attach should be Successful  #NSA
    [Arguments]    ${NSA_UE_ID}  ${Trgt_Cell}=${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}

UE Detach should be Successful
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    wtsrunner.ue_detach    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_detach_pattern}    ${Timeout_NSA}
    Print Matching Lines from Output File    ${output}    ${UE_detach_pattern}
    BuiltIn.Log    detach_is_ok

Trigger DL Traffic for NSA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${dl_rate}       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    id=${id}   dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=UDP.*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for NSA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    id=${id}   dir=ul    trf_id=${trf_id}     ${Traffic_rate}=${ul_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP.*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Validate DL Traffic For NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate DL Traffic For NSA for high data
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}    dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss for high data      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate UL Traffic For NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}

Trigger VoNR DL Traffic for SA
    [Arguments]    ${ue_id}   ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
    Log to Console    \nRunning VoNR DL Traffic for ${rtp_codec}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log    VoNR_DL_traffic_data_is_started_successfully

Trigger VoNR UL Traffic for SA
    [Arguments]    ${ue_id}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
    Log to Console    \nRunning VoNR UL Traffic for ${rtp_codec}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log    VoNR_UL_traffic_data_is_started_successfully

Replace DL Traffic for SA
    [Arguments]    ${ue_id}    ${Traffic_rate}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword replaces the dl data rate of an existing  traffic id instead of adding an extra rate.
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic over UDP*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output} DL_traffic_data_has_been_replaced_successfully
    BuiltIn.Log    DL_traffic_data_has_been_replaced_successfully with ${dl_rate}

Replace UL Traffic for SA
    [Arguments]    ${ue_id}    ${Traffic_rate}     ${ul_rate}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword replaces the ul data rate of an existing  traffic id instead of adding an extra rate.
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}     ${Traffic_rate}=${ul_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic over UDP*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output} UL_traffic_data_has_been_replaced_successfully
    BuiltIn.Log    UL_traffic_data_has_been_replaced_successfully with ${ul_rate}

MultiUE Register should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

MultiUE Deregister should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_deregister    id=${ue_idx}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    END
    BuiltIn.Log                multi_ue_deregister_is_ok

MultiUE Trigger DL Traffic for SA_8955
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID_1}
    ...     ${trf_id}=${TRF_ID_1}    ${qfi_id}=${QFI_ID_1}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}

    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

MultiUE Trigger DL Traffic for SA
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}

    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

MultiUE Trigger UL Traffic for SA_8955
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${ul_rate}    ${pdu_id}=${Pdu_session_ID_1}
    ...     ${trf_id}=${TRF_ID_1}    ${qfi_id}=${QFI_ID_1}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}      ${Traffic_rate}=${ul_rate}

    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    UL_traffic_data_is_started_successfully

MultiUE Trigger UL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${ul_rate}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}      ${Traffic_rate}=${ul_rate}

    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    UL_traffic_data_is_started_successfully



Validate DL Traffic For MultiUE for SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
   	END

Validate DL Traffic For MultiUE for NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${dl_rate}    ${id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   id=${id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
    END


Validate UL Traffic For MultiUE for SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}       ${ul_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END

Validate UL Traffic For MultiUE for NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}       ${ul_rate}    ${id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   id=${id}      dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END

Validate DL Traffic For MultiUE for SA with extended range of Avg data rate
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with expected result in range 70 to 110 percentage      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
    END

Validate UL Traffic For MultiUE for SA with extended range of Avg data rate
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}       ${ul_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with expected result in range 70 to 110 percentage     ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END

Check Average Rate with expected result in range 70 to 110 percentage
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.7)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!


Stop MultiUE Data Traffic for SA
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
	END

Stop MultiUE Data Traffic for SA DL UL SP
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${pdu}   ${qfi}   ${trfid}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_idx}  pdu=${pdu}   qfi=${qfi}   trf_id=${trfid}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
	END


Define Test Mode Profile for DCI Switch Drop
    [Arguments]        ${profile_Id}        ${drop_dci_with_different_bwp_Id}
    [Documentation]    This keyword defines testmode profile for the
    ...                drop_dci_with_different_bwp_Id=10
    Log to Console    \nDefining testmode profile for the drop_dci_with_different_bwp_Id...
    wtsrunner.forced_dtx_testmode_nr     profile_id=${profile_Id}     force_dtx_pusch=60:70
    ...                                drop_dci_with_different_bwp_Id=${drop_dci_with_different_bwp_Id}
    wtsrunner.forced_dtx_testmode_nr     profile_id=${profile_Id}
    ${output}        wtsrunner.read_wtsemu_output_until_re
    ...              expected=force_dtx_pusch.*    timeout=10
    Log to Console   ${output}
    BuiltIn.Log      drop_dci_with_different_bwp_Id Profile defined successfully

Trigger Test Mode for DCI Switch Drop
    [Arguments]    ${ue_id}       ${profile_Id}        ${action}
    Log to Console    \nTrigger testmode profile for the drop_dci_with_different_bwp_Id...
    wtsrunner.ue_testmode_set_nr     id=${ue_id}    testmode=bler
    ...                              profile_id=${profile_Id}   action=${action}
    ${output}         wtsrunner.read_wtsemu_output_until_re    expected=egate    timeout=10
    Log to Console    ${output}
    BuiltIn.Log       drop_dci_with_different_bwp_Id enabled successfully

Verify RLF in WTS egate log
     ${output}        Read WTS Output Until Pattern Matches    pattern=${UE_RLF_pattern}   timeout=10
     BuiltIn.log      Radio Link Failure Detected

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ${output}        Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    Log to Console    \n${output}

Initial Success Message for UE Register and Reregister
    [Arguments]    ${output}
    [Documentation]    This keyword checks the Initial status message for the completion of UE Registration
    ...                And UE Re-registration in the output file for the SA variant
    Should Contain    ${output}    ${Initial_UE_message_pattern}    ignore_case=True
    Print Matching Lines from Output File    ${output}    ${Initial_UE_success_pattern}


Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Start WTS Using WTS_Runner
    [Arguments]             ${wts_cfg_file}         ${timeout}=240
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=${timeout}
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=120
    sleep    120s

Stop Edaemon and Egate process
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate

Stop Sim_enb
    [Documentation]    Kill sim_enb process if already running
    ${sim_enb_pid}=    Run    pgrep sim_enb
    ${sim_enb_status}    Run Keyword and Return Status    Should Not Be Empty    ${sim_enb_pid}
    Run Keyword If    ${sim_enb_status}    Run    sudo kill -9 ${sim_enb_pid}

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    taf_ssh.Connect to     hostname=${WTS.Ip}
    ...                    username=${WTS.Username}
    ...                    alias=${WTS.Connection}

Kill WTS processes Using WTS_Runner
    wtsrunner.kill_wtsemu_edaemon    edaemon_port=22222   connection=${WTS.Connection}    sudo_password=ute
    sleep      5s
    wtsrunner.kill_wtsemu_egate      egate_port=20000     connection=${WTS.Connection}    sudo_password=ute

#VoNR keywords
UE PDU Realese should be successful
     [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}
	 wtsrunner.ue_pdu_session_release    ue=${ue_id}     pdu=${pdu_id}    by=amf
	 Read WTS Output For Pattern And Print matching Lines    ${pdu_del_pattern}     ${Timeout_SA}
	 BuiltIn.Log      Pdu_deletion_ok
	 Log to Console  ue=${ue_id}     ${Pdu_session_mod_patten}

MultiUE PDU Addition should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}     ${nw_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${gyw}=    Evaluate    int(${end_ue_id}) + int(${ue_idx})
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${gyw}
    Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    BuiltIn.Log          ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	Log to Console       ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	END
	BuiltIn.Log       All_ue_added_their_pdu_successfuly
	Log to Console    All_ue_added_their_pdu_successfuly

MultiUE PDU Modfication should be Successful
    [Arguments]     ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_add}=${Q_O_ADD}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows_to_add} added
	Log to Console            ue=${ue_idx} qosflow=${qosflows_to_add} added
    END
    BuiltIn.Log       All_ue_added_an_extra_qosflow_successfully
	Log to Console    All_ue_added_an_extra_qosflow_successfully

Trigger MultiUE VoNR DL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR DL Traffic for ue=${ue_idx} with ${rtp_codec}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_DL_traffic_data_is_started_successfully
	END
	BuiltIn.Log       All_ue_started_DL_VoNR_traff_succesfully
	Log to Console    All_ue_started_DL_VoNR_traff_succesfully

Trigger MultiUE VoNR UL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR UL Traffic for ue=${ue_idx} with ${rtp_codec}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_UL_traffic_data_is_started_successfully
	END
	BuiltIn.Log       All_ue_started_UL_VoNR_traff_succesfully
	Log to Console    All_ue_started_UL_VoNR_traff_succesfully

MultiUE Replace DL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}
    ...    ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword replaces the dl data rate of an existing  traffic id instead of adding an extra rate.
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nReplacing DL Traffic for ue=${ue_idx} with ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}
    ...      period_ms=40
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic over UDP*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} DL_traffic_data_has_been_replaced_successfully
	BuiltIn.Log    ue=${ue_idx} DL_traffic_data_has_been_replaced_successfully with ${dl_rate}
	END
	BuiltIn.Log       All_ue_replaced_dl_tr_succesfully
	Log to Console    All_ue_replaced_dl_tr_succesfully

MultiUE Replace UL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}     ${ul_rate}    ${pdu_id}=${Pdu_session_ID}
  	...    ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword replaces the ul data rate of an existing  traffic id instead of adding an extra rate.
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nReplacing UL Traffic for ue=${ue_idx} with ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}     ${Traffic_rate}=${ul_rate}
    ...      period_ms=40
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic over UDP*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} UL_traffic_data_has_been_replaced_successfully
    BuiltIn.Log      ue=${ue_idx} UL_traffic_data_has_been_replaced_successfully with ${ul_rate}
	END
	BuiltIn.Log       All_ue_replaced_ul_tr_succesfully
	Log to Console    All_ue_replaced_ul_tr_succesfully

Trigger RRC Reestablishment
    [Arguments]    ${ue_id}    ${cell_id}=1     ${cause}=otherFailure
    wtsrunner.ue_rrc_reestablish     id=${ue_id}      gnb=2      cell=${cell_id}     cause=${cause}
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=NR RRC Reestablishment sucessfully completed*     timeout=10

Validate DL Traffic For NSA for Maximum high data
    [Documentation]   SA Traffic Criteria
    #... 1. Average data rate must be within 90% and 110% of expected rate
    #... 2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]     ${ue_id}     ${dl_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats     ue=${ue_id}      id=${id}   dir=dl
    ${bearer_stat_dl}     wtsrunner.read_wtsemu_output_until     expected=Average packet interval    timeout=30
    Check Maximum Rate     ${bearer_stat_dl}     DL   ${dl_rate}
    Run keyword and Ignore Error     Check DL Data Loss for high data     ${bearer_stat_dl}     ${bearer_stat_dl}

Check Maximum Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Maximum data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Maximum data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log    ${dir} Maximum data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Maximum data rate failed!

Change CQI Number
    [Arguments]   ${profile_id}   ${ue_id}    ${CQI_value}   ${ri_id}   ${scell}
    Log To Console    Change CQI to ${CQI_value}...
    wtsrunner.csi_override_testmode_nr     profile_id=${profile_id}     cqi_mode=fixed      cqi=${CQI_value}     ri_mode=fixed
    ...         ri=${ri_id}
    Sleep    2s    reason=wait command finish
    wtsrunner.ue_testmode_set_nr    id=${ue_id}     testmode=csi_override    action=activate    profile_id=${profile_id}    scell=${scell}
    Sleep    2s    reason=wait command finish

HO SA A3 UE measurements
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=3    cell_type=medium    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}


IntragNB Intercell HO SA A3 UE measurements
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=1    cell_type=medium    nrcgi=311:489|0x01  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=51 nrsrp_nr=100
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

ue location change
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_change_location    id=${ue_id} enb=3  cell=1


gnb param
    [Arguments]    ${ue_id}=3
#    ${output}=  Execute Egate Command
    wtsrunner.gnb_param   id=${ue_id} sib1_period=40
    wtsrunner.gnb_param   id=${ue_id} sib2_period=40
    wtsrunner.gnb_param   id=${ue_id} sib5_period=40

Qosflow_modify Priority
     [Arguments]    ${qos_flow}   ${priority}
    wtsrunner.qosflow_modify    qos_flow=${qos_flow}   priority=${priority}

UE Emergency PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}   request_type=initial-emergency-request
    Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    BuiltIn.Log                ue_pdu_addition_is_ok

CFRA NSA RACH Attach
    [Arguments]    ${ue_id}
   # wtsrunner.ue_meas_param    id=${ue_id}  nr_neigh_cell=non_cfgd:53    nr_rsrp=127  nr_rsrq=127  rs_result_index=${Param}
    wtsrunner.ue_meas_param    id=${ue_id}   nr_neigh_cell=non_cfgd:50    nr_rsrp=127  nr_rsrq=127  rs_result_index=2    rs_result=126:124:125
    wtsrunner.enb_endc_param    id=1    include_candidate_cell_info_list_mn=on
    #wtsrunner.ue_dc_enb_start  ue=${ue_id}   target_gnb=2  target_cells=1  bearer=2    type=split_scg
    wtsrunner.enb_ue_dc_start    target_gnb=2    target_cells=1   ue=${ue_id}
    ...  bearer=${Bearer_ID}    type=split_scg

MultiUE Register should be Successful And Fetch RNTI with RAT1
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    ${crnti_list}       Create List
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output1}   Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Should Match Regexp   ${output1}   spCellConfig.*\\n.*\\n.*spCellConfigDedicated((.*\n){1,}).*resourceAllocation resourceAllocationType1
    BuiltIn.Log                first_ue_register_is_ok
	Log to Console             ue_register_is_ok with ${crnti_value}
    BuiltIn.Log                ue_register_is_ok with ${crnti_value}
    END
	[Return]      ${crnti_value}

MultiUE NSA Attach should be Successful and Fetch CRNTI with RAT1  #NSA
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${crnti_list}       Create List
    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_attach    id=${NSA_UE_ID}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
    Create File     ${OUTPUT_DIR}/regst_nsa.txt     ${output}
    ${x}    Set Variable    grep 'UEC-1: UE${NSA_UE_ID}: UE performed EPS_ATTACH'
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst_nsa.txt|${x}|awk -F 'crnti: ' '{print $2}'|awk -F ' = ' '{print$1}'
    BuiltIn.Log     ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
    BuiltIn.Log    lte_attach_is_ok
    Log to Console  crnti_list-${crnti_list}
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output1}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
#    Create File     ${OUTPUT_DIR}/rat1.txt     ${output1}
#    ${rc}   Run     cat ${OUTPUT_DIR}/rat1.txt|grep -m 1 'resourceAllocation resourceAllocationType1'
#    ${rc}   Strip String    ${rc}
#    Should Contain    '${rc}'     'resourceAllocation resourceAllocationType1,'
    BuiltIn.Should Match Regexp   ${output1}   spCellConfigDedicated((.|\n)*)resourceAllocation resourceAllocationType1
    Log to Console             nsa_ue_register_is_ok with ${crnti_value}
    BuiltIn.Log                nsa_ue_register_is_ok with ${crnti_value}
    END
    [Return]      ${crnti_value}


Check MIB_SIB status of GNB cell
   [Arguments]		${cell_id}
   wtsrunner.enb_cell_ib_disp   enb=2   cell=${cell_id}
   ${output}   wtsrunner.read_wtsemu_output_until_re    expected=SIB5.\*  timeout=120
   ${MIB}     Get Lines Matching Regexp    ${output}    MIB    partial_match=${TRUE}
   ${SIB1}     Get Lines Matching Regexp    ${output}    SIB1    partial_match=${TRUE}
   Should contain    ${MIB}     yes
   Should contain    ${SIB1}     yes

Get Max DL Cell throughput
    [Documentation]    Cell throughput DL
    [Arguments]    ${enb_id}=2     ${cell_id}=1     ${uec_id}=1
    wtsrunner.cell_stats_nr  enb=${enb_id}   id=${cell_id}   uec=${uec_id}   type=throughput
    ${cell_stats}      Wait Until Keyword Succeeds     1 min    2 sec   GET Cell Tput Stats
    ${max_dl_cell_tput_kbps}      Cell_TPT.get_max_dl_cell_tput    cell_stats_nr=${cell_stats}
    ${max_dl_cell_tput_mbps}   Evaluate   ${max_dl_cell_tput_kbps}/1000
    Log to Console          Max DL cell throughput for Cell ${cell_id} = ${max_dl_cell_tput_mbps} mbps
    [Return]   ${max_dl_cell_tput_mbps}

Get Max UL Cell throughput
    [Documentation]    Cell throughput UL
    [Arguments]    ${enb_id}=2     ${cell_id}=1     ${uec_id}=1
    wtsrunner.cell_stats_nr  enb=${enb_id}   id=${cell_id}   uec=${uec_id}   type=throughput
    ${cell_stats}      Wait Until Keyword Succeeds     1 min    2 sec   GET Cell Tput Stats
    ${max_ul_cell_tput_kbps}      Cell_TPT.get_max_ul_cell_tput    cell_stats_nr=${cell_stats}
    ${max_ul_cell_tput_mbps}   Evaluate   ${max_ul_cell_tput_kbps}/1000
    Log to Console          Max UL cell throughput for Cell ${cell_id} = ${max_ul_cell_tput_mbps} mbps
    [Return]   ${max_ul_cell_tput_mbps}

GET Cell Tput Stats
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Log to Console    ${output}
    should contain    ${output}    DL Max Data Rate
    [Return]      ${output}
