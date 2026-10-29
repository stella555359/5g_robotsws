*** Settings ***
Documentation
...   Test suite for feature CB009485: PCMD 5G SA NSA - UE DU Bearer and RRC status reporting
...   author: Paulina Karpf Matoga

Resource     ./resources/common.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup    Run keywords
...    Testline Setup    config=${SUITE_CONFIG}
...    AND    Add Simulated GNB to WTS Config    wts_in=${WTS_DRB}    wts_delta=${WTS_DELTA_A3_Xn}    wts_out=${WTS_final}
...    AND    Start WTS and Reach Onair    wts_cfg=${WTS_final}    skip_confirmation=yes
...    AND    Wait for All Cells to be Enabled
Suite Teardown    Testline Teardown
Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Run Keywords
...               Test Case Teardown
...      AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***
@{DCAP_GNB}              condor5gSyslog
@{DCAP_BTS}              ipCapture
&{DCAP_OPTIONS}          gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=no
&{LOGS_WITH_DCAP}        dcap=${DCAP_OPTIONS}

&{SUITE_CONFIG}          delta=${DELTA_FILES}    ip_addr=${IP_ADDR_SIM_GNB}
@{IP_ADDR_SIM_GNB}       eth3:10.0.1.3/24    eth3:10.0.1.4/24
@{DELTA_FILES}           ${DELTA_PCMD_DCAP}    ${DELTA_HO}    ${DELTA_5QI1}
${DELTA_PCMD_DCAP}       ${CURDIR}/resources/configs/Delta_PCMD_DCAP_A.json
${DELTA_HO}              ${CURDIR}/resources/configs/Delta_HO_Xn_A3_FR2.json
${DELTA_5QI1}            ${CURDIR}/resources/configs/Delta_5QI1.json
${WTS_DRB}               ${CURDIR}/resources/configs/basic_setup_A.cfg
${WTS_DELTA_A3_Xn}       ${CURDIR}/resources/configs/wts_sim_gnb_A3_XnHO_FR2.cfg
${WTS_final}             ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg

*** Test Cases ***
CB009485_B_03_gNB_triggered_UE_Release_in_source_cell
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1   param=rrcReestabTypeSA   value=sameGNB
    Start DCAP Trace
    Start GNB tcpdump Collection    log_dir=${TEST_log_dir}/Wireshark_reestablishment/
    Change UE Location    ue_id=1    node_id=2    cell_id=2
    SA UE Register    ue_id=1    should_contain=pcid:51
    PDU Session Setup    ue_id=1    pdu_id=1
    ${rnti_1}    Get CRNTI of UE    ue_id=1
    UE RRC Reestablish    ue_id=1   cell_id=1    gnb_id=2
    ...    pass_regexp=rrcReconfigurationComplete   should_contain=Reestablishment sucessfully completed
    ${rnti_2}    Get CRNTI of UE    ue_id=1
    Stop GNB tcpdump Collection
    ${dcap_files}    Stop and Collect DCAP Trace  log_dir=${TEST_log_dir}/DCAP_reestablishment/
    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.crnti == ${rnti_1} && nsetapx.ueReleaseRecord    save_to_file=${TEST_log_dir}/PCMD/PCMD_records_reestablishment.json
    Verify PCMD Record In Collection    ${records}    ueReleaseRecord    no
    ...    data_r1_element.*trigger=0    reason=16
    Run Keyword And Expect Error     *No field in ueReleaseRecord message matching pattern: ueCtxReleaseReqSendTime*
    ...    Verify PCMD Record In Collection    ${records}    ueReleaseRecord    no
    ...    ueCtxReleaseReqSendTime.*seconds=[0-9]+    ueCtxReleaseCmdRcvTime.*seconds=[0-9]+
    ...    ueCtxReleaseCmplSendTime.*seconds=[0-9]+    rrcReleaseSendTime.*seconds=[0-9]+
    SA UE Deregister    ue_id=1

    Start DCAP Trace
    Start GNB tcpdump Collection    log_dir=${TEST_log_dir}/Wireshark_idle_state/
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1   param=drbInactivityTimerSA   value=10
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1   param=srbInactivityTimerSA   value=10
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    should_contain=QoS Routing Table    pass_regexp=IS IDLE
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=e1ap.BearerContextInactivityNotification_element && e1ap.uE_Activity == not-active   count=1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=ngap.UEContextReleaseRequest_element && ngap.radioNetwork == user-inactivity   count=1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=ngap.UEContextReleaseCommand_element && ngap.radioNetwork == user-inactivity   count=1
    Stop GNB tcpdump Collection
    ${dcap_files}    Stop and Collect DCAP Trace  log_dir=${TEST_log_dir}/DCAP_idle_state/
    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx    save_to_file=${TEST_log_dir}/PCMD/PCMD_records_idle_state.json
    Verify PCMD Record In Collection    ${records}    ueReleaseRecord    no
    ...    data_r1_element.*trigger=0    reason=0    ueCtxReleaseReqSendTime.*seconds=[0-9]+
    ...    ueCtxReleaseCmdRcvTime.*seconds=[0-9]+    ueCtxReleaseCmplSendTime.*seconds=[0-9]+    rrcReleaseSendTime.*seconds=[0-9]+

    Start DCAP Trace
    Start GNB tcpdump Collection    log_dir=${TEST_log_dir}/Wireshark_fallback/
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1  param=voiceFBMode   value=redirection
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1   param=actNormVCFallback   value=true
    Update UE Parameters    ue_id=2    ue_nr_capabilities=$SA_UE_CAPABILITIES_BandEUTRA3
    Activate Voice Fallback AMF
    SA UE Register    ue_id=2
    PDU Session Setup    ue_id=2    pdu_id=1
    PDU Session Setup    ue_id=2    pdu_id=2
    Setup 5QI-1 and Expect Redirection    ue_id=2    pdu_id=2
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=ngap.PDUSessionResourceModifyResponse_element && ngap.radioNetwork == ims-voice-eps-fallback-or-rat-fallback-triggered    count=1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=ngap.UEContextReleaseCommand_element && ngap.radioNetwork == redirection    count=1
    Stop GNB tcpdump Collection
    ${dcap_files}    Stop and Collect DCAP Trace  log_dir=${TEST_log_dir}/DCAP_fallback/
    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx    save_to_file=${TEST_log_dir}/PCMD/PCMD_records_fallback.json
    Verify PCMD Record In Collection    ${records}    ueReleaseRecord    no
    ...    data_r1_element.*trigger=0    reason=8    redirectionType=2    ueCtxReleaseReqSendTime.*seconds=[0-9]+
    ...    ueCtxReleaseCmdRcvTime.*seconds=[0-9]+    ueCtxReleaseCmplSendTime.*seconds=[0-9]+    rrcReleaseSendTime.*seconds=[0-9]+
