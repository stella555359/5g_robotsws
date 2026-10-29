*** Settings ***
Documentation   This is a keyword file for CB008146-E
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
...             Email: 'I_ECE_RD_ULM_SQD_60_GMS@internal.nsn.com'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${wireshark_running}     false


*** Keywords ***

start wireshark trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    sleep     5s
    Set suite variable      ${wireshark_running}    true


stop wireshark trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${wireshark_running}'=='false'   RETURN
    sleep     5s
    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Move File    ${resultDir}/dump_testpc/dump_testpc.pcap    ${wireshark_store}
    sleep     2s
    Set suite variable      ${wireshark_running}    false


stop wireshark trace and verify successful xn setup
    [Documentation]    [PRIVATE]    stop wireshark trace and verify that xn setup is successful
    ...       :Autor: Sylvia Schneider
    stop wireshark trace            wireshark_store=${resultDir}/wireshark_startTL.pcap
    verify successful xn setup      wireshark_store=${resultDir}/wireshark_startTL.pcap


check all radio units online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    wait until keyword succeeds
    ...    10min   20sec
    ...    Verify All Radios are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM http session    node_type=gnb  node_id=${0}


set spid for UE in amf
    [Documentation]    [PRIVATE]    set spid in wts
    ...     :Autor: Sylvia Schneider
     ...     :param ${spid}:    spid value to be set
    [Arguments]     ${spid}
    Log To Console    execute on wts: amf_ue_ics_param id=1 indexToRFSP=${spid}
    sleep     2s
    ute_wtssim.execute egate command
    ...    cmd=amf_ue_ics_param id=1 indexToRFSP=${spid}
    ...    alias=ap_egate


set AMF param indexToRFSP
    [Documentation]    [PRIVATE]    set indexToRFSP in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${amf_id}=1     ${indexToRFSP}=none
    Log To Console    execute on wts: amf_ue_ics_param id=${amf_id} indexToRFSP=${indexToRFSP}
    sleep     5s
    ute_wtssim.execute egate command     cmd=amf_ue_ics_param id=${amf_id} indexToRFSP=${indexToRFSP}    alias=ap_egate


register startPdu for UE${id}
    [Documentation]    [PRIVATE]    register, start PDU session in wts
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: ue_register id=${id} nwslice=1
    Log To Console    and check "REGISTRATION COMPLETE from UE"
    sleep     5s
    ${output_register}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_register id=${id} nwslice=1
    ...    return_output=True
    ...    pass_regexp=REGISTRATION COMPLETE from UE
    ...    alias=ap_egate
    Log To Console    execute on wts: ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=${id}
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=${id}
    ...    return_output=True
    ...    pass_regexp=Initial Context Setup Successful
    ...    alias=ap_egate
    Save egate log          ${output_egate}

Save egate log
    [Documentation]    [PRIVATE]    save egate log for verification
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${output_egate}
    Create File    ${resultDir}/egate_log${log_number}.txt    ${output_egate}
    ${log_number}   Evaluate   ${log_number}+1
    Set test variable   ${log_number}
    sleep     2s


modify pdu session
    [Documentation]    [PRIVATE]    modify pdu session in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${UE_id}
    Log To Console   execute on wts: ue_pdu_session_modify ue=${UE_id} pdu=1 qosflows_to_add=2 by=amf
    Log To Console    check on wts : "pass_regexp=rrcReconfigurationComplete"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_pdu_session_modify ue=${UE_id} pdu=1 qosflows_to_add=2 by=amf
    ...    return_output=True
    ...    pass_regexp=rrcReconfigurationComplete
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A2 measurement with srsrp_nr and srsrq_nr
    [Documentation]    [PRIVATE]    send A2 measurement with srsrp_nr and srsrq_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}
    Log To Console   execute on wts: ue_measurement_send_nr event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    ...    return_output=True
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A2 measurement with srsrp_nr and srsrq_nr and check
    [Documentation]    [PRIVATE]    send A2 measurement with srsrp_nr and srsrq_nr and check in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}   ${check}=rrcReconfigurationComplete
    Log To Console   execute on wts: ue_measurement_send_nr event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    Log To Console    check on wts : "pass_regexp=${check}"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A1 measurement with srsrp_nr and srsrq_nr
    [Documentation]    [PRIVATE]    send A1 measurement with srsrp_nr and srsrq_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}
    Log To Console   execute on wts: ue_measurement_send_nr event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    ...    return_output=True
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A1 measurement with srsrp_nr and srsrq_nr and check
    [Documentation]    [PRIVATE]    send A1 measurement with srsrp_nr and srsrq_nr and check in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${srsrp_nr}   ${srsrq_nr}   ${meas_id}    ${UE_id}
    Log To Console   execute on wts: ue_measurement_send_nr event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    Log To Console    check on wts : "pass_regexp=rrcReconfigurationComplete"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} meas_id=${meas_id} id=${UE_id}
    ...    return_output=True
    ...    pass_regexp=rrcReconfigurationComplete
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A3 measurement with rsrp_nr and rsrq_nr
    [Documentation]    [PRIVATE]    send A3 measurement with rsrp_nr and rsrq_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${phycell_id}   ${nrsrq_nr}   ${meas_id}    ${UE_id}
    ${command_1}   Set Variable    ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${command_2}   Set Variable    nrsrp_nr=50 nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${UE_id}
    ${command}     Catenate   SEPARATOR=${SPACE}    ${command_1}    ${command_2}
    Log To Console   execute on wts: ${command}
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${command}
    ...    return_output=True
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A3 measurement with rsrp_nr and rsrq_nr and check
    [Documentation]    [PRIVATE]    send A3 measurement with rsrp_nr and rsrq_nr and check in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${phycell_id}   ${nrsrq_nr}   ${meas_id}    ${UE_id}
    ${command_1}   Set Variable    ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${command_2}   Set Variable    nrsrp_nr=50 nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${UE_id}
    ${command}     Catenate   SEPARATOR=${SPACE}    ${command_1}    ${command_2}
    Log To Console   execute on wts: ${command}
    Log To Console    check on wts : "pass_regexp=rrcReconfigurationComplete"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${command}
    ...    return_output=True
    ...    pass_regexp=rrcReconfigurationComplete
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A3 measurement with rsrp_nr and check
    [Documentation]    [PRIVATE]    send A3 measurement with rsrp_nr in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${phycell_id}    ${UE_id}
    Log To Console   execute on wts: ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=${phycell_id} nrsrp_nr=70 meas_id=3 id=${UE_id}
    Log To Console    check on wts : "pass_regexp=rrcReconfigurationComplete"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=${phycell_id} nrsrp_nr=70 meas_id=3 id=${UE_id}
    ...    return_output=True
    ...    pass_regexp=rrcReconfigurationComplete
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send history information
    [Documentation]    [PRIVATE]    send history information in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${UE_id}
    Log To Console    execute on wts: ue_history_information_list_add_ngran id=1 gnb_id=3...
    sleep     10s
    ute_wtssim.execute egate command
    ...    cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    ...    alias=ap_egate

    Log To Console    execute on wts: ue_history_information_list id=1 action=commit
    sleep     10s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_history_information_list id=1 action=commit
    ...    pass_regexp=UE History List: 1 was committed    alias=ap_egate

    Log To Console    execute on wts: ue_enb_param id=${UE_id} ue_history_list=1
    sleep     10s
    ute_wtssim.execute egate command
    ...   cmd=ue_enb_param id=${UE_id} ue_history_list=1    alias=ap_egate
