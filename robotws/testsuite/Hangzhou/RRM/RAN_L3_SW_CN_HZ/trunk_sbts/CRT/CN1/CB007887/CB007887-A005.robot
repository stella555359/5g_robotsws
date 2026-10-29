*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-SG02    owner-L19liu
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    release-SBTS22R1
...    STATE_CONFIGURED    RAN_5G

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{ET_A005}

@{ET_A005}
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=2
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:actVoNR=true
...    MRBTS-1/NRBTS-1:actNormVCFallback=false
...    delete:fiveGsTac
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actEmergencyCall=true
...    NRCELL:actARPBasedAC=on
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:t310VoNR=500ms
...    NRCELL:n310VoNR=n3
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:maxGBRTrafficLimit=75
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actTrsSepaSARanSharing=false
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=max_10_PLMNs
...    NRBTS:integrityProtPrefL:nia0=1
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=9
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actIncXn=true
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:discardTimer=150ms
...    NRBTS-1/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_MAC-4:lcgid=0
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRPLMN-1:mcc=311
...    NRBTS-1/NRPLMN-1:mnc=489
...    NRBTS-1/NRPLMN-1:mncLength=3
...    NRBTS-1/NRPLMN-2:mcc=311
...    NRBTS-1/NRPLMN-2:mnc=402
...    NRBTS-1/NRPLMN-2:mncLength=3
...    NRBTS-1/NRPLMN-3:mcc=460
...    NRBTS-1/NRPLMN-3:mnc=02
...    NRBTS-1/NRPLMN-3:mncLength=3
...    NRBTS-1/SNSSAI-3:sd=13714342
...    NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=4580
...    NRBTS-1/TRACKINGAREA-300:fiveGsTac=100
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS-1/TRACKINGAREA-200:fiveGsTac=0
...    SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=4580
...    NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=0
...    NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=633408
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS-1/NRADJGNB-1:gNodeBId=35
...    NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=35
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

@{ACoffandpduhofalse}
...    NRCELL:actARPBasedAC=off
...    NRCELL:pduHoSliceRelease=false

@{AConandpduhotrue}
...    NRCELL:actARPBasedAC=on
...    NRCELL:pduHoSliceRelease=true

${uecapability1}    SEPARATOR=
...    21A01000010980200004600002681001C4600000000713400000801808D0137FD555540B00C000A070300F0600B
...    00F000D03C01000000000000000040140622A001000000000000100400C0A8010008010020010040084A00008C35A

${FAIL_HO_PREP_EMERGENCY_RAC}    M55147C00505


*** Test Cases ***
CB007887-ET-A005_Verify_Unsuccessful_Intra_gnb_HO_with_not_support_slice_since_AC_failure
    [Documentation]
    ...    1. The purpose of this test case is to verify unsuccessful intra gnb ho with partial admission,
    ...       pduHoSliceRelease enabled and cell setting below:
    ...       GNB2 CELL1 support both standard slice and non-standard slice.
    ...       GNB2 CELL2 only support standard slice.
    ...       ENB1 CELL1 support both standard slice and non-standard slice.
    ...       Set CELL2 maxNumOfGBRBearersSA=0
    ...    2. Test Case Steps:
    ...         a. UE-1 setup call with 3 pdu sessions,EC_standardSlice,5QI7_standardSlice,5QI5_nonstandardSlice
    ...         b. UE-1 perform HO with 2 target cells.
    ...    3. Expected Results:
    ...         UE-1 HO to CELL2 failed due to 5QI1 AC failure although partial admission is allowed,
    ...         and keep in CELL1.
    [Tags]    QC_81695
    Unsuccessful HO with partial admission by maxNumOfGBRBearersSA
    Unsuccessful HO with partial admission by pduHoSliceRelease

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=GNB-3: XnAP Link with GNB-2
    
Modify Cfg
    Update Cfg    set_amf_region id=3 tac_list=0,100,200,258,788 plmn=311:402
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null nea=null ims_voice_3gpp=on
    Update Cfg    ue_param id=1 ue_nr_capabilities=${uecapability1} nr_usage_setting=voice_centric
    ${UE1_info}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${UE1_info}
    ${gnb3_info}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${gnb3_info}
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosflow id=3 5qi=7
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-4 qos_flows=1,2,3,4 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1 qos_flows=1,2,3,4 qos_rules=1,2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xFFFFFF ue=1-6 amf=1 qos_flows=1,2,3,4 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off

Normal call flow set
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on

Emergency call flow set
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    qosflow_modify qos_flow=3 default=on

UE1 attach with 3 PDU Session
    Normal call flow set
    Execute Egate Command    ue_register id=1    now Registered
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=1 nwslice=3 gw=1 request_type=initial-emergency-request    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table
    Emergency call flow set
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=1 nwslice=3 gw=2    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup pdu=3 ue=1 nwslice=1 gw=3    QoS Routing Table

UE1 attach with three new PDU Session
    Normal call flow set
    Execute Egate Command    ue_register id=1    now Registered
    Execute Egate Command    ue_pdu_session_setup pdu=4 ue=1 nwslice=3 gw=4 request_type=initial-emergency-request    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=4 qosflows_to_add=2 by=amf    QoS Routing Table
    Emergency call flow set
    Execute Egate Command    ue_pdu_session_setup pdu=5 ue=1 nwslice=3 gw=5    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup pdu=6 ue=1 nwslice=1 gw=6    QoS Routing Table

Trigger HO Failure
    [Arguments]    ${ue}=1
    BuiltIn.Log    UE${ue} Tirgger Intra-Frequency Intra-DU HO To Cell...    console=${True}
    ${measid_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A5
    ${intra_freq_intra_1}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_1} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    phycell_id=381 nrsrp_nr=25 nrsrq_nr=25
    execute egate command    ${intra_freq_intra_1}    pass_regexp=measId    fail_regexp=Intra-eNB handover

Online modify maxNumOfGBRBearersSA parameter with 0
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-2:maxNumOfGBRBearersSA=0

Online modify maxNumOfGBRBearersSA parameter with 10
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-2:maxNumOfGBRBearersSA=10

Trigger HO successful
    [Arguments]    ${ue}=1
    BuiltIn.Log    UE${ue} Tirgger Intra-Frequency Intra-DU HO To Cell...    console=${True}
    ${measid_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A5
    ${intra_freq_intra_1}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_1} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    phycell_id=381 nrsrp_nr=25 nrsrq_nr=25
    execute egate command    ${intra_freq_intra_1}    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
    ${measid_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A5
    ${intra_freq_intra_2}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_2} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    execute egate command    ${intra_freq_intra_2}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1

Unsuccessful HO with partial admission by pduHoSliceRelease
    UE1 attach with three new PDU Session
    Delta Commission Parameters    ${ACoffandpduhofalse}
    Trigger HO Failure
    Delta Commission Parameters    ${AConandpduhotrue}
    Trigger HO successful
    Release Ues    ue_type=all

Unsuccessful HO with partial admission by maxNumOfGBRBearersSA
    UE1 attach with 3 PDU Session
    Online modify maxNumOfGBRBearersSA parameter with 0
    Trigger HO Failure
    Online modify maxNumOfGBRBearersSA parameter with 10
    Trigger HO successful
    Release Ues    ue_type=all
