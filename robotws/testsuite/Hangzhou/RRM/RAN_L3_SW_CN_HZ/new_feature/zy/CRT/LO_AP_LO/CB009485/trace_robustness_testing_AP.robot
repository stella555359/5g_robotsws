*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
...    A1based CA config
...    [Configuration]:
...        GNBID         CELLID    band          nrarfcn    gscn    ssbFrequency    phycell_id
...    GNB-2(id=1)       CELL-1     n71    134980:127180    1589          127210            60
...                      CELL-2     n41           518598    6483          518670            50
...                      CELL-3     n71    133780:124580    1555          124370            61
Suite Setup       Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot


*** Variables ***
${CONFIG_WA}    ${False}
@{FAULTS_EXCLUDED_CHECKING}    8000
@{PARAMS_IN_SWCONFIG}
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4
...    0x890004=0
...    0x890003=0

${SYSCOM_FLAG}    ${True}

${DuBearerTraceRecord_mba_F}    (nsetapx.DuVendorExtensionRecordDataType == 13) && (nsetapx.traceActivationType == 0)
${DuBearerTraceRecord_sba_F}    ((nsetapx.DuVendorExtensionRecordDataType == 13)) && (nsetapx.traceActivationType == 1)

${CuUeReleaseTraceRecord_F}    nsetapx.CuVendorExtensionRecordDataType == 0
${CuUeReleaseTraceRecord_mba_F}    (nsetapx.CuVendorExtensionRecordDataType == 0) && (nsetapx.traceActivationType == 0)
${CuUeReleaseTraceRecord_sba_F}    (nsetapx.CuVendorExtensionRecordDataType == 0) && (nsetapx.traceActivationType == 1)

@{ueReleaseRecord_c2_c3_c4}
    ...        ueReleaseRecord/data-r1/trigger=gNB
    ...        ueReleaseRecord/data-r1/reason=ueInactivity
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=not_existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=not_existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=not_existing

*** Test Cases ***
c1_check mba and sba trace after enable NRBTS:actPCMDReport during call ongoing
    [Tags]    c1
    log to console    Step 1: register UE and setup pdu session with traceActivation IE in ICS request
    UE register and setup pdu session with traceActivation    ue_id=1
    release ues    ue_id=1

    log to console    Step 2: set NRBTS:actPCMDReport=false
    delta commission parameters    NRBTS:actPCMDReport=false

    log to console    Step 3: register UE
    register ue    ue_id=2

    log to console    Step 4: set NRBTS:actPCMDReport=true
    delta commission parameters    NRBTS:actPCMDReport=true
    Start TCE    ${TCE_PORT}

    log to console    Step 5: setup pdu session with traceActivation IE in ICS request
    setup pdu session with traceactivation    ue_id=2

c2_check mba and sba trace after disable and enable NRBTS:actPCMDReport
    [Tags]    c2    PR851869
    log to console    Step 1: register UE, setup pdu session with traceActivation IE in ICS request, and deregister UE
    UE register and setup pdu session with traceActivation    ue_id=1
    release ues    ue_id=1

    log to console    Step 2: set NRBTS:actPCMDReport=false
    delta commission parameters    NRBTS:actPCMDReport=false

    log to console    Step 3: set NRBTS:actPCMDReport=true
    delta commission parameters    NRBTS:actPCMDReport=true
    Start TCE    ${TCE_PORT}

    log to console    Step 4: register UE, setup pdu session with traceActivation IE in ICS request, and deregister UE
    UE register and setup pdu session with traceActivation    ue_id=2
    release ues    ue_id=2

    log to console    Step 5: repeat step4 after sleep 5min
    sleep    300s
    UE register and setup pdu session with traceActivation    ue_id=3
    release ues    ue_id=3

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_1T2F    ue_count=10
    Start TCE    ${TCE_PORT}

Modify Cfg
    Update Cfg Param    set_cell id=3 gnb=2 pci=20:1 nr_arfcn=133780:124580 gscn=1555
    FOR    ${id}    IN RANGE    1    11
        Update Cfg    ue_param id=${id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    END

Register UE
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE

Setup PDU session with TraceActivation
    [Arguments]    ${ue_id}=1
    ${ics_traceactivation}    catenate
    ...    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=${ue_id} trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=10.0.1.1
    Execute Egate Command     ${ics_traceactivation}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful
    sleep    10s    # wait some pcmd du records

UE register and setup pdu session with traceActivation
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${ics_traceactivation}    catenate
    ...    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=${ue_id} trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=10.0.1.1
    Execute Egate Command     ${ics_traceactivation}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful
    sleep    10s    # wait some pcmd du records

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}    ${times}=1
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}    ${times}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
