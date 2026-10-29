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
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp

@{randon_scenarios}
...    UEContextRelease_during_reestablish
...    PDUSessionResourceRelease_during_reestablish
...    PDUSessionResourceModifyRequest_during_reestablish
...    UERadioCapabilityCheckRequest_during_reestablish
...    LocationReportingControl_during_reestablish
...    NGReset_during_reestablish

${SCANRIO}    ${EMPTY}

*** Test Cases ***
5GC000732_ET_I001_I004_I005_I008_I009_I010_Randon_Execute
    [Tags]    QC_167133
    ${randon_execute}    get random string    ${randon_scenarios}
    ${final_select}    set variable if    "${SCANRIO}" == "${EMPTY}"    ${randon_execute}    ${SCANRIO}
    Log To Console    ${final_select}
    run keyword    ${final_select}

*** Keywords ***
UEContextRelease_during_reestablish
    [Documentation]
    ...    5GC000732_ET_I001_NGAP_UEcontextReleaseCommand_incoming_during_reestablish_queue
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1.
    ...         b. PDU session is setup successfully.
    ...         c. Trigger hold RRC reconfiguration complete during reestablishment procedure for 5s.
    ...         d. Trigger RRC reestablishment request to serving cell.
    ...         e. Trigger NGAP: UEContextReleaseCommand to gNB in 5s.
    ...         f. RRC reestablishment be handled first, then handle UEContextReleaseCommand correctly. 
    UE1 Attach To Cell1
    Trigger hold RRC reconfiguration complete
    Trigger RRC reestablishment to serving cell
    Trigger UEContextReleaseCommand during RRE
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I001${/}a2a.ini    wait_string=UEContextReleaseComplete::4

PDUSessionResourceRelease_during_reestablish
    [Documentation]
    ...    5GC000732_ET_I004_NGAP_PDUSessionResource_ReleaseCommand_incoming_during_reestablish_queue
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1.
    ...         b. PDU session 1 and PDU session 2 are setup successfully.
    ...         c. Check traffic is OK.
    ...         d. Trigger hold RRC reconfiguration complete during reestablishment procedure for 5s.
    ...         e. Trigger RRC reestablishment request to serving cell.
    ...         f. Trigger PDUSessionResourceReleaseCommand to PDU session 2 in 5s.
    ...         g. RRC reestablishment be handled first, then handle PDUSessionResourceReleaseCommand correctly, UE is Active.  
    ...         h. Check traffic is OK.
    UE1 Attach To Cell1 with 2 PDUs
    Send And Verify Throuput    pdu=1
    Send And Verify Throuput    pdu=2
    Trigger hold RRC reconfiguration complete
    Trigger RRC reestablishment to serving cell
    Trigger PDUSessionResourceReleaseCommand on PDU2 during RRE
    Verify Throuput    pdu=1
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I004${/}a2a.ini    wait_string=PDUSessionResourceReleaseResponse::4
    Release UEs    ue_type=all

PDUSessionResourceModifyRequest_during_reestablish
    [Documentation]
    ...    5GC000732_ET_I005_NGAP_PDUSessionResource_ModifyRequest_incoming_during_reestablish_queue
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1.
    ...         b. PDU session(with 5QI6) is setup successfully.
    ...         c. Check traffic is OK.
    ...         d. Trigger hold RRC reconfiguration complete during reestablishment procedure for 5s.
    ...         e. Trigger RRC reestablishment request to serving cell.
    ...         f. Trigger PDUSessionResourceModifyRequest(add 5QI5) to PDU session in 5s.
    ...         g. RRC reestablishment be handled first, then handle PDUSessionResourceModifyRequest correctly, IE is Active.  
    ...         h. Check traffic is OK.
    UE1 Attach To Cell1
    Send And Verify Throuput
    Trigger hold RRC reconfiguration complete
    Trigger RRC reestablishment to serving cell
    Trigger PDUSessionResourceModifyRequest
    Verify Throuput
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I005${/}a2a.ini    wait_string=PDUSessionResourceModifyResponse::4

UERadioCapabilityCheckRequest_during_reestablish
    [Documentation]
    ...    5GC000732-ET-I009_NG_UERadioCapabilityCheckRequest_incoming_during_reestablish_ignore
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         note: 0x59012A=8500 is DU timer, NRBTS-1:timerRRCGuard=6000 is CU timer
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Trigger hold RRC reestablishment complete or RRC reconfiguration complete during reestablishment
    ...            procedure for 5s
    ...         d. Trigger RRC reestablishment request to ori cell1.
    ...         e. Trigger NGAP: UERadioCapabilityCheckRequest to gNB in 5s.
    ...         f. Check Reestablishment procedure ongoing, and reestablish successfully, UERadioCapabilityCheckRequest
    ...            been ignored, UE still in RRC connected state.
    UE1 Attach To Cell1
    Send And Verify Throuput
    Trigger hold RRC reconfiguration complete
    Trigger RRC reestablishment to serving cell
    Trigger UERadioCapabilityCheckRequest
    Verify Throuput
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I009${/}a2a.ini    wait_string=UEContextReleaseComplete::4

LocationReportingControl_during_reestablish
    [Documentation]
    ...    5GC000732-ET-I010_NGAP_LocationReportingControl_incoming_during_reestablish_queue
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Trigger hold RRC reestablishment complete or RRC reconfiguration complete during reestablishment
    ...            procedure for 5s
    ...         d. Trigger RRC reestablishment request to ori cell1.
    ...         e. Trigger NGAP: LocationReportingControl to gNB in 5s
    ...         f. Check Reestablishment procedure ongoing, and reestablish successfully, then LocationReportingControl
    ...            successfully, UE still in RRC connected state
    UE1 Attach To Cell1
    Send And Verify Throuput
    Trigger hold RRC reconfiguration complete
    Trigger RRC reestablishment to serving cell
    Trigger location reporting
    Verify Throuput
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I010${/}a2a.ini

NGReset_during_reestablish
    [Documentation]
    ...    5GC000732-ET-I008_NGAP_NGReset_incoming_during_reestablish_parallel
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Trigger hold RRC reestablishment complete or RRC reconfiguration complete during reestablishment
    ...            procedure for 5s
    ...         d. Trigger RRC reestablishment request to ori cell1.
    ...         e. Trigger NGAP: NG Reset to gNB in 5s.
    ...         f. Check Reestablishment procedure and NG reset procedure are parallel, and NG reset successfully,
    ...            then reestablishment is successfully, UE is active but no traffic.
    UE1 Attach To Cell1
    Send And Verify Throuput
    Trigger hold RRC reconfiguration complete
    Trigger RRC reestablishment to serving cell
    Trigger NG Reset
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I008${/}a2a.ini

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5    #Used for I005

UE1 Attach To Cell1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    QoS Routing Table

UE1 Attach To Cell1 with 2 PDUs
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 gw=2 nwslice=1    QoS Routing Table

Trigger UEContextReleaseCommand during RRE
    Execute Egate Command    ue_ng_ctx_release id=1 by=amf cause=MISC_unspecified    UE Context Release Complete    timeout=10
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=1    state=IDLE

Trigger PDUSessionResourceReleaseCommand on PDU2 during RRE
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=2 by=amf    Successfully released PDU Session with ID 2 in SMF    timeout=10
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=1    state=ACTIVE

Trigger PDUSessionResourceModifyRequest
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    Added QosFlow with QFI:2 fiveQI:5    timeout=10
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=1    state=ACTIVE

Trigger RRC reestablishment to serving cell
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=reconfigurationFailure
    ...    Hit on error cases presence=any action=delay    timeout=3

Trigger hold RRC reconfiguration complete
    Execute Egate Command    ue_param id=1 reestablishing_state_timeout=9s
    Execute Egate Command    ue_nr_rrc_reconf_param id=1 if_contains=any delay=5000

Trigger UERadioCapabilityCheckRequest
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=1 gnb=2    rrcReconfigurationComplete

Trigger location reporting
    Execute Egate Command    ue_send_location_reporting_control ue=1 event_type=direct    rrcReconfigurationComplete

Verify Throuput
    [Arguments]    ${sleep_time}=10s    ${pdu}=1
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=${pdu}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=${pdu}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Send And Verify Throuput
    [Arguments]    ${pdu}=1
    Execute Egate Command    trf_data_start ue=1 pdu=${pdu} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=1 pdu=${pdu} qfi=1 dir=ul mbps=10
    Verify Throuput    pdu=${pdu}

Trigger NG Reset
    Execute Egate Command   link_ng_reset by=amf:1 ue=1    rrcReconfigurationComplete
