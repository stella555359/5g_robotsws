*** Settings ***
Documentation     This contains keywords used for CNI116870 automation cases.
Library      ta5g_pm_counters
Library      getRecievedPackets.py
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${TOPOLOGY}         	CLOUD_5G_I_LO_AP_LO
${scf}       ${CURDIR}/../../config/gnb_scf
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts
${pdu_session_modify}     Added QosFlow with QFI
${pdu_setup}    PDU SESSION ID-1 setup/reestablishment complete
${VLAN_ID}                ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${vlanif_distname}        ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${timeout}    60
${sleep_timer}    ${7}
${num}     ${10}
${period}    ${700}


*** Keywords ***
Prepare for the case
    ${Test_CaseNumber}     Set Variable    CNI116870
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    Full Commission With SCF File For UTE   ${scf}/SCF_116870.xml
    sleep   400s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup.cfg
    Basic Bring up
    sleep     30s
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Establish PDU session and register UE
    [Arguments]    ${UE_ID}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    ue_register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${Register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    sleep    5s
    Read WTS Output For Pattern And Print matching Lines    ${pdu_setup}    ${Timeout_SA}

Modify PDU session to add Qos
    [Arguments]    ${ue_id}    ${qos}
    ue_pdu_session_modify    ue=${ue_id}    qosflows_to_add=${qos}     pdu=1    by=amf
    sleep    10s
    read_wtsemu_output_until    ${pdu_session_modify}    ${timeout}
    sleep    5s

Start and Verify RTP data
    [Arguments]    ${ue}    ${period}
    FOR    ${i}    IN RANGE    1    11
        trf_data_start    trf_id=${i}    ue=${ue}    rtp_send_silence_period=${period}    period_ms=${period}
        ...    pdu=1    qfi=3   dir=ul  protocol=udp    rtp_codec=custom    packets=10
        read_wtsemu_output_until_re    expected=Started Uplink RTP Internal traffic over UDP   timeout=10
        Wait Until Keyword Succeeds   60s    5s
        ...    Verify num of packets received from QFI display    ${ue}    ${num}
        ${period}=    Evaluate    ${period} + 500
        ${num}=     Evaluate    ${num} + 10
    END

Start and Verify TCP data
    [Arguments]    ${UE_ID}
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=1  qfi=3  dir=ul    protocol=tcp
    ...    period_ms=700     trf_id=11     packets=100
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=TCP UL TRF    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s

Start and Verify UDP data
    [Arguments]    ${UE_ID}
    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=1    qfi=3     dir=ul    protocol=udp
    ...    period_ms=1200    packets=100    trf_id=12
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=traffic over UDP   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s

Verify num of packets received from QFI display
    [Arguments]    ${ue_id}    ${num}
    LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in UL direction
    qfi_stats     ue=${ue_id}    qfi=3    dir=ul     pdu=1
    ${output}    Read WTS Output Until Pattern Matches      Average packet interval     60
    ${packet_count}    check_received_packets    ${output}
    Log to Console    \n${packet_count}
    Should Be Equal As Numbers    ${packet_count}    ${num}

UE Deregistration
    [Arguments]    ${ue_id}
    ue_deregister    id=${ue_id}    by=amf
    sleep    40s
    log to console    \n deregistered UE
