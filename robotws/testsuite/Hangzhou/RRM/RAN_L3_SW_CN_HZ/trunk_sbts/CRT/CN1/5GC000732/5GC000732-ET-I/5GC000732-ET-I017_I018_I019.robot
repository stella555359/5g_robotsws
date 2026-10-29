*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-christine.chen
...    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CRT    5GC000732-I    release-5G22R2
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
@{PARAMS_IN_SWCONFIG}    ${timerRRCGuard}=8500
${timerRRCGuard}    0x59012A

@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:actLocationReportingSA=true
...    @{IntragNB_IntraDU_HO_Config}

@{IntragNB_IntraDU_HO_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp

@{PM_Counters}
...    NRCELL-1:${NG_FLOW_REL_GNB_RLF}=0

${NG_FLOW_REL_GNB_RLF}    M55125C09003    #Number of QosFlows released due to radio link failure

@{randon_scenarios}
...    reestablish_during_PDU_setup_fallback
...    reestablish_during_PDU_release_fallback
...    reestablish_during_intragNB_intraDU_HO_fallback

${SCANRIO}    ${EMPTY}

*** Test Cases ***
5GC000732_ET_I017_I018_I019_Randon_Execute
    [Tags]    QC_167130
    ${randon_execute}    get random string    ${randon_scenarios}
    ${final_select}    set variable if    "${SCANRIO}" == "${EMPTY}"    ${randon_execute}    ${SCANRIO}
    Log To Console    ${final_select}
    run keyword    ${final_select}

*** Keywords ***
reestablish_during_PDU_setup_fallback
    [Documentation]
    ...    5GC000732_ET_I017_rrcreestablishmentrequest_incoming_during_PDU_setup_fallback
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1.
    ...         b. PDU session is setup successfully.
    ...         c. Iperf Send DL UL Traffic (egate command is not support in fallback case).
    ...         d. Trigger hold RRC reconfiguration complete during PDU setup procedure for 5s.
    ...         e. Trigger new PDU session setup for gNB.
    ...         f. Trigger RRC reestablishment request to serving cell.
    ...         g. Reestablishment aborted, PDU setup aborted,fallback should be triggered, UE is Active.
    ...         h. Check traffic is OK.
    Clear Counter Files    ${False}
    SA UE Register
    PDU Session Setup    pdu=1
    Iperf Send DL UL Traffic
    Trigger hold RRC reconfiguration complete
    PDU Session Setup    pdu=2    pass_regexp=Hit on error cases presence=any action=delay
    Trigger RRC reestablishment to serving cell without hit on error case
    Check Specific UE State    ue_id=1    state=ACTIVE
    Iperf DL UL Traffic Should Be OK
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I017${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters}

reestablish_during_PDU_release_fallback
    [Documentation]
    ...    5GC000732_ET_I018_rrcreestablishmentrequest_incoming_during_PDU_release_fallback
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1.
    ...         b. PDU session 1 is setup successfully, Iperf Send DL UL Traffic(egate command is not support in fallback case).
    ...            PDU session 2 is setup successfully.
    ...         c. Trigger hold RRC reconfiguration complete during PDU release procedure for 5s.
    ...         d. Trigger PDU session 2 release for gNB.
    ...         e. Trigger RRC reestablishment request to serving cell.
    ...         f. Reestablishment aborted, PDU release aborted, fallback should be triggered, UE is Active.
    ...         g. Check traffic is OK.
    Clear Counter Files    ${False}
    SA UE Register
    PDU Session Setup    pdu=1
    Iperf Send DL UL Traffic
    PDU Session Setup    pdu=2
    Trigger hold RRC reconfiguration complete
    Trigger PDU2 PDUSessionResourceReleaseCommand before RRE
    Trigger RRC reestablishment to serving cell without hit on error case
    Check Specific UE State    ue_id=1    state=ACTIVE
    Iperf DL UL Traffic Should Be OK
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I018${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters}

reestablish_during_intragNB_intraDU_HO_fallback
    [Documentation]
    ...    5GC000732_ET_I019_rrcreestablishmentrequest_incoming_during_intragNB_intraDU_HO_fallback
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1.
    ...         b. PDU sessions is setup successfully.
    ...         c. Iperf Send DL UL Traffic (egate command is not support in fallback case).
    ...         d. Trigger hold RRC reconfiguration complete during intragNB intraDU HO procedure for 5s.
    ...         e. Trigger A3 MR to trigger intragNB intraDU HO.
    ...         f. Trigger RRC reestablishment request to cell 1.
    ...         g. Reestablishment aborted, HO aborted, fallback should be triggered, UE is Active.
    ...         h. Check traffic is OK.
    SA UE Register
    PDU Session Setup    pdu=1
    Iperf Send DL UL Traffic
    Trigger hold RRC reconfiguration complete
    Trigger Intra-gnb HO
    Trigger RRC reestablishment to serving cell without hit on error case
    Check Specific UE State    ue_id=1    state=ACTIVE
    Iperf DL UL Traffic Should Be OK
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I019${/}a2a.ini    wait_string=UEContextReleaseComplete::4

SA UE Register
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register

PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=external
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=${pdu} nwslice=1    pass_regexp=${pass_regexp}

Iperf Send DL UL Traffic
    ${dl_send_file}    ${dl_receive_file}    Iperf Send Dl Traffic    ue_id=1    bandwith='70M'
    ${ul_send_file}    ${ul_receive_file}    Iperf Send Ul Traffic    ue_id=1    bandwith='10M'
    Set Test Variable    ${dl_send_file}
    Set Test Variable    ${ul_send_file}
    Set Test Variable    ${dl_receive_file}
    Set Test Variable    ${ul_receive_file}

Trigger hold RRC reconfiguration complete
    Execute Egate Command    ue_param id=1 reestablishing_state_timeout=10s
    Execute Egate Command    ue_nr_rrc_reconf_param id=1 if_contains=any delay=7s

Trigger RRC reestablishment to serving cell without hit on error case
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=reconfigurationFailure    UE CONTEXT RELEASE COMPLETE    timeout=7

Iperf DL UL Traffic Should Be OK
    Sleep    15s    #wait for traffic stable
    Iperf Traffic Should Be Ok    send_traffic_file=${dl_send_file}    received_traffic_file=${dl_receive_file}    diff_amount=5    bw_thresh=85
    Iperf Traffic Should Be Ok    send_traffic_file=${ul_send_file}    received_traffic_file=${ul_receive_file}    diff_amount=5    bw_thresh=85

Trigger PDU2 PDUSessionResourceReleaseCommand before RRE
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=2 by=ue    Hit on error cases presence=any action=delay    timeout=7

Trigger Intra-gnb HO
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=31 nrsrq_nr=31
    ...    Hit on error cases presence=any action=delay    timeout=7
