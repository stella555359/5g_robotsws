*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    STATE_CONFIGURED    team-SG2    
...    owner-ying.5.chen    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    release-5G20A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{REDIR_INFO}
...    @{NEIGHBOR_INFO}
...    @{HANDOVER_INFO}
...    NRBTS:actEmergencyFallback=true
...    NRCELL:emergencyFBMode=redirection
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea3_128=0

@{REDIR_INFO}
...    NRCELL-1/NRREDRT-0:redirFreqNr=633372
...    NRCELL-1/NRREDRT-0:redirPrio=1
...    NRCELL-1/NRREDRT-0:redirRat=nr
...    NRCELL-1/NRREDRT-0:redirSsbScs=30 KHz
...    NRCELL/NRREDRT-1:redirFreqEutra=19000
...    NRCELL/NRREDRT-1:redirFreqNr=636666
...    NRCELL/NRREDRT-1:redirPrio=2
...    NRCELL/NRREDRT-1:redirRat=eutra
...    NRCELL/NRREDRT-1:redirSsbScs=${EMPTY}
...    NRCELL/NRREDRT-2:redirFreqEutra=1300
...    NRCELL/NRREDRT-2:redirPrio=3
...    NRCELL/NRREDRT-2:redirRat=eutra
...    NRCELL/NRREDRT-2:redirFreqNr=${EMPTY}
...    NRCELL/NRREDRT-2:redirSsbScs=${EMPTY}

@{NEIGHBOR_INFO}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=NSA
...    NRBTS/NRADJNRCELL-2:gNbId=31
...    NRBTS/NRADJNRCELL-2:lcrId=11
...    NRBTS/NRADJNRCELL-2:nrarfcn=636666
...    NRBTS/NRADJNRCELL-2:physCellId=383
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=${EMPTY}
...    NRBTS/NRADJNRCELL-3:cellDepType=NSA
...    NRBTS/NRADJNRCELL-3:gNbId=4
...    NRBTS/NRADJNRCELL-3:lcrId=2
...    NRBTS/NRADJNRCELL-3:nrarfcn=2071591
...    NRBTS/NRADJNRCELL-3:physCellId=384
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=${EMPTY}
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-11:gNbId=31
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=4
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
@{HANDOVER_INFO}
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{PM_COUNTERS_A002}
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=1
...    NRCELL-1:${NR_RRC_RELEASE_REDIR_EF_LTE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_RECD}=2
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_EF_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_SENT}=2
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_EF_SENT}=1

@{PM_COUNTERS_A004}
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=1
...    NRCELL-1:${NR_RRC_RELEASE_REDIR_EF_LTE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_RECD}=2
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_EF_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_SENT}=2
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_EF_SENT}=1

@{PM_COUNTERS_A010}
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_EF_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_FAIL_SENT}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_FAIL_EF_SENT}=1

@{PM_COUNTERS_B007}
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_FAIL_SENT}=1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_FAIL_EF_SENT}=1

${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502
${NR_RRC_RELEASE_REDIR_EF_LTE}    M55124C03501
${NNGCC_UE_CTXT_STP_REQ_RECD}    M55125C02501
${NNGCC_UE_CTXT_STP_REQ_EF_RECD}    M55125C03001
${NNGCC_UE_CTXT_STP_RESP_SENT}    M55125C02502
${NNGCC_UE_CTXT_STP_RESP_EF_SENT}    M55125C03002
${NNGCC_UE_CTXT_STP_FAIL_SENT}    M55125C02503
${NNGCC_UE_CTXT_STP_FAIL_EF_SENT}    M55125C03003
${NNGCC_UE_CTXT_MOD_REQ_RECD}    M55125C03004
${NNGCC_UE_CTXT_MOD_FAIL_SENT}    M55125C03006
${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}    M55125C03007
${NNGCC_UE_CTXT_MOD_FAIL_EF_SENT}    M55125C03009


${DISABLE_EMERGENCY}
...    NRBTS:actEmergencyFallback=false

@{delta_007}
...    NRCELL-1/NRREDRT-2:redirFreqEutra=19000
...    NRBTS:actEmergencyFallback=true

@{PARAMS_IN_SWCONFIG}    0x59004D=1
${RECREATE_WIRESHARK_FLAG}    False

${uecapabiliy}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C38002064F
...    1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2
...    898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E1DE38720C38002064F1F5500
...    0005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000001CA9A0002000012CB2A00695550103
...    800580000002004008D58980008101820283038405880889098C909293139425389B40

*** Test Cases ***
5GC001468-ET-A002_Verify_EmergencyFallback_with_Redirection_would_be_successful_when_UE_in_IDLE_with_PDUSession_with_UEcapability_in_ICSR
    [Documentation]    This Test case is to verify emergency services fallback with redirection would be successful, when ICS contains
        ...    PDUSession and UERadioCapability, also check related counter which matched with ET-A003
    [Tags]    QC_61641    002
    clear counter files
    Ue Register And Pdu Session Setup
    To Access RRC IDLE with PDU with UECapbility
    Perform IDLE UE ServiceRequest
    Deregister UE
    check wireshark log    ${CURDIR}${/}a2a_a002${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_A002}

5GC001468-ET-A004_Verify_EmergencyFallback_with_Redirection_would_be_successful_when_UE_in_IDLE_with_PDUSession_without_UEcapability_in_ICSR
    [Documentation]    This Test case is to verify emergency services fallback with redirection would be successful, when ICS contains
    ...    PDUSession but not UERadioCapability, also check related counter which matched with ET-A005
    [Tags]    QC_61635    004
    clear counter files
    Ue Register And Pdu Session Setup
    To Access RRC IDLE with PDU without UECapbility
    Perform IDLE UE ServiceRequest
    Deregister UE
    check wireshark log    ${CURDIR}${/}a2a_a004${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_A004}

5GC001468-ET-A010_Verify_EmergencyFallback_with_Redirection_would_be_unsuccessful_when_feature_deactivated_and_UE_in_IDLE
    [Documentation]    This Test case is to verify emergency services fallback with redirection would be unsuccessful
    ...    because of feature disabled when RRC IDLE, also check related counter which matched with ET-A011
    [Tags]    QC_61638    010
    clear counter files
    OnlineParamChange    ${DISABLE_EMERGENCY}
    Register UE
    To Access RRC IDLE without PDU with UECapbility
    Perform Idle UE ServiceRequest No Redir
    Deregister UE
    check wireshark log    ${CURDIR}${/}a2a_a010${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_A010}

5GC001468-ET-B007_Verify_EmergencyFallback_with_Redirection_would_be_unsuccessful_when_setting_unsupported_target_bands_and_UE_in_CONNECTED
    [Documentation]    This Test case is to verify emergency services fallback with redirection would be unsuccessful
    ...    because of unsupported band when RRC CONNECTED, also check related counter which matched with ET-B008
    [Tags]    QC_61634    007
    clear counter files
    OnlineParamChange    ${delta_007}
    Ue Register And Pdu Session Setup
    Perform CONNECTED UE ServiceRequest
    Deregister UE
    check wireshark log    ${CURDIR}${/}a2a_b007${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_B007}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${enb11}    catenate    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222
    ...    x2=10.0.1.127 x2u=10.0.1.137 type=simulated x2_peers=1
    update cfg    ${enb11}
    update cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    ${enb11_cell11}    catenate    set_cell id=11 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    tdd_cell=on mandatory_for_activation=off
    update cfg    ${enb11_cell11}
    update cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    update cfg    ue_param id=1 ue_nr_capabilities=${uecapabiliy}
    update cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null emergency_service_fallback=on target_cn=epc

Ue Register And Pdu Session Setup
    [Arguments]    ${ue_id}=1
    execute egate command    amf_ue_ics_param id=1 reset
    Register UE
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table

To Access RRC IDLE with PDU with UECapbility
    [Arguments]    ${ue_id}=1
    ${ret1}    execute egate command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    IS IDLE
    should contain    ${ret1}    rrcRelease
    Set RRC param with emergency
    Set ICS Param with emergencyFB and ueCapability    on

To Access RRC IDLE with PDU without UECapbility
    [Arguments]    ${ue_id}=1
    ${ret1}    execute egate command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    IS IDLE
    should contain    ${ret1}    rrcRelease
    Set RRC param with emergency
    Set ICS Param with emergencyFB and ueCapability    off

To Access RRC IDLE without PDU with UECapbility
    [Arguments]    ${ue_id}=1
    execute egate command    ue_im_entry id=${ue_id} by=ue    IS IDLE
    Set RRC param with emergency
    Set ICS Param with emergencyFB and ueCapability    off

Set RRC param with emergency
    [Arguments]    ${ue_id}=1
    execute egate command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

Set ICS Param with emergencyFB and ueCapability
    [Arguments]    ${uecap_flag}=on
    execute egate command     amf_ue_ics_param id=1 emergency_fb=on target_cn=epc include_ue_capabilities=${uecap_flag}

Perform IDLE UE ServiceRequest
    ${service_fallback}    catenate    ue_im_exit id=1 by=ue service_type=emergency_services_fallback
    ${ret1}    execute egate command    ${service_fallback}    Redirected carrier info is present in RRC Release
    should contain    ${ret1}    PDU Session Resource failed to setup list
    should contain    ${ret1}    Initial Context Setup Successful
    should contain    ${ret1}    redirectedCarrierInfo eutra
    should contain    ${ret1}    eutraFrequency 1300
    should contain    ${ret1}    was unsuccessful due to RAN ims voice eps fallback or rat fallback triggered
    execute egate command    ue_disp    IDLE

Deregister UE
    [Arguments]    ${ue_id}=1
    execute egate command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Register UE
    [Arguments]    ${ue_id}=1
    execute egate command    state_sim_disp
    execute egate command    amf_ue_ics_param id=1 reset
    execute egate command    ue_change_location id=1 cell=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registe

Perform Idle UE ServiceRequest No Redir
    ${service_fallback}    catenate    ue_im_exit id=1 by=ue service_type=emergency_services_fallback
    ${ret1}    execute egate command    ${service_fallback}    RrcRelease is received for UE_NAS_5GS_MM_SERVICE_REQUEST_INITIATED
    should contain    ${ret1}    Initial Context Setup Failure from GNB-2 with cause RAN unspecified
    should contain    ${ret1}    rrcRelease
    execute egate command    ue_disp    IDLE

Perform CONNECTED UE ServiceRequest
    [Arguments]    ${ue_id}=1
    ${service_request}    catenate     ue_conn_service_req id=1 service_type=emergency_services_fallback
    ${ret1}    execute egate command    ${service_request}     Received UE Context Modification Failure from GNB-2 with cause RAN unspecified
    should contain    ${ret1}    ServiceType is Emergency in Ue Active Mode
    execute egate command    ue_disp    ACTIVE
