*** Settings ***
Documentation   This is a keyword file for 5GC000710-C
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
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


setup UE and redirect cell
    [Documentation]    [PRIVATE]    register UE, start PDU, send A2 measurement with redirect
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}     ${redirection_cell}
    start wireshark trace
    register startPdu A2measurement   UE_id=${ue_id}   redirection_cell=${redirection_cell}
    stop wireshark trace
    move wireshark file for UE${ue_id}


setup UE${id}
    [Documentation]    [PRIVATE]    register UE, start PDU, send A2 measurement without redirect
    ...       :Autor: Sylvia Schneider
    start wireshark trace
    register startPdu A2measurement for UE${id}
    stop wireshark trace
    move wireshark file for UE${id}


setup UE52 and send 2 A2 measurements and redirect cell
    [Documentation]    [PRIVATE]    register UE, start PDU, send 2 times A2 measurement
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${redirection_cell}
    start wireshark trace
    register startPdu 2 times A2 measurement for UE52     redirection_cell=${redirection_cell}
    stop wireshark trace


setup UE51 and trigger handovers and redirect cell
    [Documentation]    [PRIVATE]    register UE, start PDU, send 2 times A3 for HO, send A2 measurement with redirect
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${redirection_cell}
    start wireshark trace
    setup UE51 trigger 2 handover and redirection      redirection_cell=${redirection_cell}
    stop wireshark trace


register UE and check success
    [Documentation]    [PRIVATE]    register UE and check success
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}   ${nwslice}
    ${cmd}     set variable   ue_register id=${ue_id} nwslice=${nwslice}
    ${check}   set variable   REGISTRATION COMPLETE from UE
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check "${check}"
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


start pdu and check success
    [Documentation]    [PRIVATE]    start pdu and check success
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}   ${nwslice}
    ${cmd}     set variable   ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}
    ${check}   set variable   Initial Context Setup Successful
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check "${check}"
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


Setup UE51 And Trigger Unsuccessful PDU Modification And Redirect To LTE
    Start Wireshark Trace
    Register UE And Check Success    ue_id=51    nwslice=1
    Start PDU And Check Success      ue_id=51    nwslice=1

    ${cmd}     Set Variable    ue_pdu_session_modify ue=51 pdu=1 qosflows_to_add=4 by=amf
    ${check}   Set Variable    Deleted Unsuccessful QosFlow QFI:2
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts unsuccessful pdu modify: ${check}
    Sleep     5s
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate

    ${cmd}     Set Variable    ue_measurement_send_nr event=A2 srsrp_nr=33 meas_id=1 id=51
    ${check}   Set Variable    Received RRCConnectionRelease with E-UTRA redirectedCarrierInfo=1800; redirect to eNB-1 cell 2
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts redirect: ${check}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    stop wireshark trace


set AMF param indexToRFSP
    [Documentation]    [PRIVATE]    set indexToRFSP in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${amf_id}=1     ${indexToRFSP}=none
    Log To Console    execute on wts: amf_ue_ics_param id=${amf_id} indexToRFSP=${indexToRFSP}
    sleep     5s
    ute_wtssim.execute egate command     cmd=amf_ue_ics_param id=${amf_id} indexToRFSP=${indexToRFSP}    alias=ap_egate


register startPdu A2measurement for UE${id}
    [Documentation]    [PRIVATE]    register, start PDU session, send A2 without redirect in wts
    ...       :Autor: Sylvia Schneider
    register UE and check success    ue_id=${id}    nwslice=1
    start pdu and check success      ue_id=${id}    nwslice=1

    ${cmd}     set variable    ue_measurement_send_nr event=A2 srsrp_nr=100 meas_id=1 id=${id}
    ${check}   set variable    Measurements for neighbor cells not present
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


register startPdu A2measurement
    [Documentation]    [PRIVATE]    register, start PDU session, send A2 with redirect in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${UE_id}   ${redirection_cell}
    register UE and check success    ue_id=${UE_id}    nwslice=1
    start pdu and check success      ue_id=${UE_id}    nwslice=1

    ${cmd}     set variable    ue_measurement_send_nr event=A2 srsrp_nr=100 meas_id=1 id=${UE_id}
    ${check}   set variable    Location changed to eNB-3 cell ${redirection_cell}
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


register startPdu 2 times A2 measurement for UE52
    [Documentation]    [PRIVATE]    register, start PDU session, send 2 times A2 for redirect in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${redirection_cell}
    register and start PDU session    UE=52     nwslice=2

    ${cmd}     set variable    ue_measurement_send_nr event=A2 srsrp_nr=100 srsrq_nr=31 meas_id=1 id=52
    Log To Console    execute on wts: ${cmd}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     set variable    ue_measurement_send_nr event=A2 srsrp_nr=100 srsrq_nr=25 meas_id=1 id=52
    ${check}   set variable    Location changed to eNB-3 cell ${redirection_cell}
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


setup UE51 trigger 2 handover and redirection
    [Documentation]    [PRIVATE]    register, start PDU session, send 2 times A3 for Ho, 1 time A2 for redirect in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${redirection_cell}
    register and start PDU session    UE=51     nwslice=1

    ${cmd}     set variable    ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=48 nrsrp_nr=70 meas_id=2 id=51
    Log To Console    execute on wts: ${cmd}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     set variable    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Log To Console    execute on wts: ${cmd}
    sleep     10s
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     set variable    ue_history_information_list id=1 action=commit
    ${check}   set variable    UE History List: 1 was committed
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     10s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate

    ${cmd}     set variable   ue_enb_param id=1 ue_history_list=1
    Log To Console    execute on wts: ${cmd}
    sleep     10s
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     set variable    ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=52 nrsrp_nr=70 meas_id=3 id=51
    Log To Console    execute on wts: ${cmd}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     set variable    ue_measurement_send_nr event=A2 srsrp_nr=30 meas_id=7 id=51
    ${check}   set variable    Location changed to eNB-3 cell ${redirection_cell}
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     5s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


register and start PDU session
    [Documentation]    [PRIVATE]    register, start PDU session in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${UE}     ${nwslice}
    register UE and check success    ue_id=${UE}    nwslice=${nwslice}
    start pdu and check success      ue_id=${UE}    nwslice=${nwslice}


move wireshark file for UE${id}
    [Documentation]    [PRIVATE]    move wireshark file
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark file wireshark.pcap moved to directory ${resultDir}/UE${id}
    Create Directory    ${resultDir}/UE${id}
    sleep     2s
    Move File    ${resultDir}/wireshark.pcap    ${resultDir}/UE${id}

