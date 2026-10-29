*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env And IP added for simGNB
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN1ET    owner-zora.wang    release-5G23R4     CB008281
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}
...    0x890073=3

@{PARAMS_IN_SCF}
...    @{8281_enable}
...    @{Paging_related}
...    @{PCMD_related}
...    NRCELL:fPdcchMonOccsnPo=2

@{8281_enable}
...    NRBTS-1:timerRRCGuard=6000
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:nrEcidMeasSupervisionTimer=6100

@{PCMD_related}
...    @{TCE}
...    @{NRMTRACECU}
...    @{CellTrace_enable}
...    @{traceAll}
...    @{PCMD_enable}
...    @{PeriodicUeMeas}
...    @{PCMD_DU_enable}
...    @{NRSTRACECU}

@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1

@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1

@{CellTrace_enable}
...    NRBTS:actCellTraceReport=true
...    NRBTS:actSubscriberTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all

@{PCMD_enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true

@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

@{PeriodicUeMeas}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly

@{PCMD_DU_enable}
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1

@{NRSTRACECU}
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:nrStraceCuId=1
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:applyDefNrTceForAllSessions=true
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:certTypeForTlsAuth=RSA
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:defaultNrTceIdentifier=1
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:nrTcePortNumber=49100
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:tlsEnabled=false

@{Paging_related}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=3
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:srbInactivityTimerSA=3
...    NRBTS:maxUeRrcInactTime=1
...    NRBTS:rrcInactIMMSteeringEnabled=true
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=5
...    NRBTS:ranPagingCycle=v32
...    NRCELL:ranAC=0
...    NRBTS:activityNotificationLevelSA=ue
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRRCC=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrPaging=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrF1CD=5min
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actIdleMMSteering=true
...    NRCELL:idleMMSteeringAlgo=non CA aware
...    NRCELL:idleMMSteeringPercentageOfUes=10
...    NRCELL:idleMMSteeringWRREnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=false

@{PDU_setup_and_IN_INACTIVE_state}
...    QoS Routing Table
...    Moving UE to NR_RRC_INACTIVE state
...    Is INACTIVE

@{A051_paging}
...    Received ECID Measurement Response

*** Test Cases ***
CB008281-ET-A051_Successful RAN Paging in RRC Inactive State-DL AMF signalling arrival with NGAP DownlinkUEAssociatedNRPPaTransport with NRPPa PDU
    [Documentation]
    ...    1. The purpose of this case:RAN Paging for the UEs in RRC_INACTIVE state for DL AMF signalling arrival with
    ...    NGAP:DownlinkUEAssociatedNRPPaTransport carrying NRPPa PDU is in the gNB buffer.5G_RAN_USR_RRM_20764
    ...    2. Test Case Steps:
    ...       a. setup SA call sucessfully.
    ...       b. when ue in RRC_INACTIVE state. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to On-Demand
    ...        and Measurement Quantity requested is SS-RSRP and SS-RSRQ.
    ...       c. before tRanPagingGuard expires, UE responds with RRCResumeRequest1 (resumeCause='mt-Access').
    ...       d. before E-CID Measurement supervision timer expiry,gNB-CU-CP forms the E-CID MEASUREMENT INITIATION RESPONSE with E-CID
    ...         Measurement Result.
    [Tags]     QC_46879    A051
    SA UE attach with single PDU
    trigger E-CID Measurement Initiation request    PDU_pass_regexp=${PDU_setup_and_IN_INACTIVE_state}    ECID_pass_regexp=${A051_paging}
    Release Ues    ue_type=sa    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}A2A_A051${/}a2a.ini    wait_string=UEContextReleaseComplete::6

CB008281-ET-A052_Failure RAN Paging in RRC Inactive State-DL AMF signalling arrival with NGAP DownlinkUEAssociatedNRPPaTransport with NRPPa PDU
    [Documentation]
    ...    1. The purpose of this case:RAN Paging for the UEs in RRC_INACTIVE state for DL AMF signalling arrival with
    ...    NGAP:DownlinkUEAssociatedNRPPaTransport carrying NRPPa PDU is in the gNB buffer.Failure scenario.5G_RAN_USR_RRM_18730
    ...    2. Test Case Steps:
    ...       a. setup SA call sucessfully.
    ...       b. set paging message is dropped at UE and no response is sent.
    ...       c. when ue in RRC_INACTIVE state. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to On-Demand
    ...         and Measurement Quantity requested is SS-RSRP and SS-RSRQ. After tRanPagingGuard expires, E-CIDMeasurementInitiationFailure
    ...         (RNL Cause = "Requested Item Temporarily Not Available") send.And gNB-CU-CP sends NGAP UEContextReleaseRequest with
    ...         Radio Network Layer Cause: 'UE in RRC_INACTIVE state not reachable' to AMF.
    ...       d. check cell trace.
    [Tags]     QC_321095    A052
    Start TCE    ${TCE_PORT}
    SA UE attach with single PDU for SBA trace
    Set paging message is dropped at UE and no response is sent
    trigger E-CID Measurement Initiation request    PDU_pass_regexp=${PDU_setup_and_IN_INACTIVE_state}
    Release Ues    ue_type=sa    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}A2A_A052${/}a2a.ini    wait_string=UEContextReleaseComplete::20
    [Teardown]    A052_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env And IP added for simGNB
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh

A052_Teardown
    Execute Egate Command    ng_ue_trace_stop id=1 trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1
    Execute Egate Command    ue_param id=1 ignore_paging=off
    Common Test Teardown And Stop Capture Logs

SA UE attach with single PDU for SBA trace
    [Arguments]    ${ue_id}=1    ${target_cells}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    ${command}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${TCE_IP}
    Execute Egate Command    ${command}
    ${command1}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=0
    Execute Egate Command    ${command1}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP,SS-RSRQ    ${tid}=1    ${ECID_pass_regexp}=Received ECID Measurement Failure
    ...    ${PDU_pass_regexp}=Initial Context Setup Successful
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${PDU_pass_regexp}
    sleep    2s    sleep for the process successfully
    Execute Egate Command    ${cmd}    pass_regexp=${ECID_pass_regexp}

Set paging message is dropped at UE and no response is sent
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_param id=${ue_id} ignore_paging=on

SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    ${command}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=0
    Execute Egate Command    ${command}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    ue_param id=${ue_id} ignore_paging=off
