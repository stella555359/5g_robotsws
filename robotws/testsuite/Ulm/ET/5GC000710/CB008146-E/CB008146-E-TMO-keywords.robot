*** Settings ***
Documentation   This is a keyword file for CB008146-E
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
...             Email: 'I_ECE_RD_ULM_SQD_60_GMS@internal.nsn.com'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false


*** Keywords ***

Start Wireshark Trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    Start Tcpdump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     5s
    Set Suite variable      ${WIRESHARK_RUNNING}    true


Stop Wireshark Trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${wireshark_running}'=='false'   RETURN
    Sleep     5s
    Stop Tcpdump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    OperatingSystem.Move File    ${resultDir}/dump_testpc/dump_testpc.pcap    ${wireshark_store}
    Sleep     2s
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Stop Wireshark Trace And Verify Successful Xn Setup
    [Documentation]    [PRIVATE]    stop wireshark trace and verify that xn setup is successful
    ...       :Autor: Sylvia Schneider
    Stop Wireshark Trace            wireshark_store=${resultDir}/wireshark_startTL.pcap
    Verify Successful Xn Setup      wireshark_store=${resultDir}/wireshark_startTL.pcap


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    Verify All Radios Are Online    connection=${oam_alias}
    Log To Console    RUs ready
    [Teardown]     connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${0}


Set spid For UE In AMF
    [Documentation]    [PRIVATE]    set spid in wts
    ...     :Autor: Sylvia Schneider
     ...     :param ${spid}:    spid value to be set
    [Arguments]     ${spid}
    ${cmd}   Set Variable   amf_ue_ics_param id=1 indexToRFSP=${spid}
    Log To Console    execute on wts: ${cmd}
    Sleep     2s
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Set AMF Param indexToRFSP
    [Documentation]    [PRIVATE]    set indexToRFSP in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${amf_id}=1     ${indexToRFSP}=none
    ${cmd}   Set Variable   amf_ue_ics_param id=${amf_id} indexToRFSP=${indexToRFSP}
    Log To Console    execute on wts: ${cmd}
    Sleep     2s
    ute_wtssim.Execute Egate Command
    ...     cmd=${cmd}
    ...     alias=ap_egate


Register startPdu For UE${id}
    [Documentation]    [PRIVATE]    register, start PDU session in wts
    ...       :Autor: Sylvia Schneider
    ${cmd}     Set Variable   ue_register id=${id} nwslice=1
    ${check}   Set Variable   REGISTRATION COMPLETE from UE
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check "${check}"
    Sleep     2s
    ${output_register}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate

    ${cmd}     Set Variable   ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=${id}
    ${check}   Set Variable   Initial Context Setup Successful
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}

Save Egate Log
    [Documentation]    [PRIVATE]    save egate log for verification
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${output_egate}
    Create File    ${resultDir}/egate_log${log_number}.txt    ${output_egate}
    ${log_number}   Evaluate   ${log_number}+1
    Set Test Variable   ${log_number}
    Sleep     2s


Modify PDU Session
    [Documentation]    [PRIVATE]    modify pdu session in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${UE_id}
    ${cmd}     Set Variable   ue_pdu_session_modify ue=${UE_id} pdu=1 qosflows_to_add=6 by=amf
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts : "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send A2 Measurement With srsrp_nr And srsrq_nr
    [Documentation]    [PRIVATE]    send A2 measurement with srsrp_nr and srsrq_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}
    ${cmd}     Set Variable   ue_measurement_send_nr event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send A2 Measurement With srsrp_nr And srsrq_nr And Check
    [Documentation]    [PRIVATE]    send A2 measurement with srsrp_nr and srsrq_nr and check in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}   ${check}=rrcReconfigurationComplete
    ${cmd}     Set Variable   ue_measurement_send_nr event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts : "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send A1 Measurement With srsrp_nr And srsrq_nr
    [Documentation]    [PRIVATE]    send A1 measurement with srsrp_nr and srsrq_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}
    ${cmd}     Set Variable   ue_measurement_send_nr event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send A1 Measurement With srsrp_nr And srsrq_nr And Check
    [Documentation]    [PRIVATE]    send A1 measurement with srsrp_nr and srsrq_nr and check in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}
    ${cmd}     Set Variable   ue_measurement_send_nr event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console   execute on wts: ${cmd}
    Log To Console    check on wts : "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send A3 Measurement With rsrp_nr And rsrq_nr
    [Documentation]    [PRIVATE]    send A3 measurement with rsrp_nr and rsrq_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${phycell_id}   ${nrsrq_nr}   ${meas_id}    ${UE_id}
    ${command_1}   Set Variable    ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${command_2}   Set Variable    nrsrp_nr=50 nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${UE_id}
    ${command}     Catenate   SEPARATOR=${SPACE}    ${command_1}    ${command_2}
    Log To Console   execute on wts: ${command}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}
    ...    return_output=True
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send A3 Measurement With rsrp_nr And rsrq_nr And Check
    [Documentation]    [PRIVATE]    send A3 measurement with rsrp_nr and rsrq_nr and check in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${phycell_id}   ${nrsrq_nr}   ${meas_id}    ${UE_id}
    ${command_1}   Set Variable    ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${command_2}   Set Variable    nrsrp_nr=50 nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${UE_id}
    ${command}     Catenate   SEPARATOR=${SPACE}    ${command_1}    ${command_2}
    Log To Console   execute on wts: ${command}
    Log To Console    check on wts : "pass_regexp=rrcReconfigurationComplete"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}
    ...    return_output=True
    ...    pass_regexp=rrcReconfigurationComplete
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send A3 Measurement With rsrp_nr And Check
    [Documentation]    [PRIVATE]    send A3 measurement with rsrp_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${phycell_id}    ${UE_id}
    ${cmd}     Set Variable   ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=${phycell_id} nrsrp_nr=70 meas_id=3 id=${UE_id}
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console   execute on wts: ${cmd}
    Log To Console    check on wts : "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Save Egate Log          ${output_egate}


Send History Information
    [Documentation]    [PRIVATE]    send history information in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${UE_id}
    ${cmd}     Set Variable   ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=310:260|0x01 time_ue_stayed_in_cell=100
    Log To Console    execute on wts: ${cmd}
    Sleep     10s
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     Set Variable   ue_history_information_list id=1 action=commit
    ${check}   Set Variable   UE History List: 1 was committed
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts : "${check}"
    Sleep     10s
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate

    ${cmd}     Set Variable   ue_enb_param id=${UE_id} ue_history_list=1
    Log To Console    execute on wts: ${cmd}
    Sleep     10s
    ute_wtssim.Execute Egate Command
    ...   cmd=${cmd}
    ...   alias=ap_egate


Display Measurement
    [Documentation]    [PRIVATE]    send history information in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${UE_id}  ${run}=_1
    ${cmd}     Set Variable   ue_meas_disp id=${UE_id}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_meas_disp_UE${UE_id}_${run}.txt    ${output_egate}
