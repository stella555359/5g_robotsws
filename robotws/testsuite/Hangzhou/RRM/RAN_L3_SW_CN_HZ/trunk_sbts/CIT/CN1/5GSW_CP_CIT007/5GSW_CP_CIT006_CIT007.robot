*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CXT    team-SG2
...    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    CDXT  release-SBTS22R1 
...    owner-y33chen    5GC000786    5GC000733    

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UTE_WIRESHARK_FLAG}  ${False}

@{PARAMS_IN_SCF}    
...    @{CIT006_feature_flag}    
...    @{CIT006_paging_para}
...    @{CIT007_parameters_related_to_Voice_call}
...    @{CIT007_GNB_PMQAP}

@{CIT006_feature_flag}
...    NRBTS:actPaging=true
...    NRCELL-1:actCDrx=true

@{CIT006_paging_para}
...    NRBTS:drxDefaultPaging=v256
...    BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRCELL-1:numOfPagingFrames=halfT
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:numPagingOccsnPagingFrame=two
...    NRCELL-1:fPdcchMonOccsnPo=0,2
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320

@{CIT007_parameters_related_to_Voice_call}

...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0
...    NRBTS-1:actNormVCFallback=false
...    NRBTS-1/NRCELL-1:actVoNR=true
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1

@{CIT007_GNB_PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=15min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=15min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=15min
...    NRPMRNL-1:miNrSaCuNrpmqap=15min
...    NRPMRNL-1:miNrUeStatNrpmqap=15min
...    NRPMRNL-1:miNrX2ccNrpmqap=15min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=2
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=460
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=02
...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714342

@{CIT007_ret1}
...    QoS Routing Table   
...    UPF-1: Setup QosFlow with QFI:1 fiveQI:5
...    securityModeCommand
...    cipheringAlgorithm nea2
...    Initial Context Setup Successful for UE with AMF UE ID
...    AMF-1: Setup QosFlow with QFI:1 5QI:5

@{CIT007_ret2}
...    QoS Routing Table   
...    rrcReconfiguration
...    pdcp-SN-SizeUL len12bits
...    pdcp-SN-SizeDL len12bits
...    ul-UM-RLC
...    sn-FieldLength size12
...    dl-UM-RLC
...    sn-FieldLength size12
...    t-Reassembly ms40
...    logicalChannelGroup 4
...    schedulingRequestID 0

@{CIT007_ret3}
...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID   
...    AMF-1: Deleting QosFlow with
...    UPF-1: Deleted QoSFlow with
...    drb-ToReleaseList
...    5
...    AMF-1: PDU SESSION RESOURCE MODIFY RESPONSE

@{PM_Counters_CIT006_CIT007}
...    ${NF1CD_F1AP_PAGING_RECD}=1
...    ${NNGCB_NGAP_PAGING_RECD}=1
...    ${NRPAG_PAGING_SUCC_SENT}=2
...    ${NRRCD_RRC_STPREQ_MT_ACCESS}=1
...    ${NRRCC_RRC_STPREQ_MT_ACCESS}=1
...    ${NRRCC_RRC_STPSUCC_TOT}=4 
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMODREQ_RECD}=2
...    NRCELL-1:${NG_FLOW_SETUP_ATT_TOT_5QI1}=2
...    NRCELL-1:${NG_FLOW_SETUP_SUCC_TOT_5QI1}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=3
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=1
...    NRCELL-1:${PEAK_NUMBER_OF_UE_5QI1}=2
...    NRCELL-1:${AVE_NUMBER_OF_UE_5QI1}>1

${NF1CD_F1AP_PAGING_RECD}    M55117C03001    #Number of F1AP Paging message received at gNB-DU
${NNGCB_NGAP_PAGING_RECD}    M55119C01501    #Number of NGAP Paging message received at gNB-CU-CP
${NRPAG_PAGING_SUCC_SENT}    M55331C00001    #Number of RRC Paging message successfully broadcasted
${NRRCD_RRC_STPREQ_MT_ACCESS}    M55127C00003    #Number of RRC CONNECTION Attempts for Mobile Terminated Access,gNB-CU
${NRRCC_RRC_STPREQ_MT_ACCESS}    M55124C01003    #Number of RRC CONNECTION Attempts for Mobile Terminated Access,gNB-DU
${NRRCC_RRC_STPSUCC_TOT}    M55124C01031    #Number of RRC CONNECTION Attempts that were completed successfully
${NNGCC_PDUSESMODREQ_RECD}    M55125C03501
${NG_FLOW_SETUP_ATT_TOT_5QI1}    M55125C09517
${NG_FLOW_SETUP_SUCC_TOT_5QI1}    M55125C09518
${NG_FLOW_REL_AMF_NORMAL_PMQAP}    M55163C00519
${NG_FLOW_CONNECTED_SESSION_TIME}    M55125C09516
${NG_FLOW_REL_NORMAL_5QI1}    M55125C09514
${PEAK_NUMBER_OF_UE_5QI1}    M55125C09530
${AVE_NUMBER_OF_UE_5QI1}    M55125C09528

${BTS_STARTUP_RETRY}    4

${ue_nr_capabilities}    SEPARATOR=
...    21A01000010980200004600002681001C4600000000713400000801808D0137FD555540B00C000A070300F0600B0
...    0F000D03C01000000000000000040140622A001000000000000100400C0A8010008010020010040084A00008C35A

*** Test Cases ***
5GSW-CP-CIT006-CIT007_Verify_Classical_SA_FDD_cmWave_Paging_on_IDLE_and_L3_call_setup_for_VoNR_is_successful
    [Documentation]
    ...    1.Purpose
	...    [CIT006]
	...    include feature 5GC000733.Verify paging occasion for IDLE UE in single beam for 1208 slot pattern
	...    Configured 1208 slot with 0ms
	...    [CIT007]
    ...    it test cp-rt is running as user btssw instead of root after 5GC006048
    ...    it test one_VoNR_call_5QI5_setup_in_ICS_and_UE_capability_is_not_ICS_in_single_cell_TDD_SA_Airphone
    ...    it verify the feature CB008200 relate counter.
    ...    2. Test Case Steps
    ...    Step a. cp-rt is running as user btssw instead of root
	...         b. UE3 registered, make UE3 to idle, then AMF paging
    ...         c. setup VoNR call with ICS and UEcapability iteam not include in the ICS message (UE1)
    ...         d. setup 5QI1 (UE1)
    ...         e. setup VoNR call with ICS and release 5QI1 (UE2)
    ...         f. Check relate message and counters
    [Tags]
    Check If Started By Btssw    cp-rt
    Clear Counter Files
	SA UE Register and PDU Setup    ue_id=3
	Trigger paging from AMF
    Trigger UE MO VoNR call with PDU for CIT07
    Trigger UE 5QI1 setup successfully for CIT07
    Trigger UE VoNR call with ICS and release 5QI1
    Check message and counter

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
  Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
  ${C_1}    catenate
  ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
  ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
  ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
  Update Cfg    ${C_1}
  ${C_2}    catenate
  ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
  ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
  ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
  Update Cfg    ${C_2}
  Update Cfg    ue_param id=1 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
  Update Cfg    ue_param id=2 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
  Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
  Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
  Update Cfg    set_qosflow id=1 5qi=5 
  Update Cfg    set_qosflow id=2 5qi=1
  Update Cfg    set_qosflow id=3 5qi=7
  Update Cfg    set_qosflow id=4 5qi=2
  Update Cfg    set_qosflow id=6 5qi=6 default=on
  Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
  Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
  Update Cfg    set_nwslice id=1 amf=1 default=on qos_flows=1,2,3,4,6 qos_rules=1,2 snssai=0x01:0xD143A5 ue=1-6
  Update Cfg    set_nwslice id=2 amf=1 qos_flows=1,2,3,4,6 qos_rules=1,2 snssai=0x01:0xD143A6 ue=1-6
  Update Cfg    set_nwslice id=3 amf=1 qos_flows=1,2,3,4,6 qos_rules=1,2 snssai=0x01:0xFFFFFF ue=1-6
  Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1 amf=1

Trigger UE MO VoNR call with PDU for CIT07
  Execute Egate Command    smf_param id=1 reset
  Execute Egate Command    qosflow_modify qos_flow=1 default=on
  Execute Egate Command    ue_register id=1 nwslice=1    pass_regexp=UE now in NG RM Registered
  ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1
  ...    pass_regexp=${CIT007_ret1}

Trigger UE 5QI1 setup successfully for CIT07
  ${ret2}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
  ...    pass_regexp=${CIT007_ret2}

Trigger UE 5QI1 release
  ${ret3}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2 by=amf
  ...    pass_regexp=${CIT007_ret3}

Trigger UE VoNR call with ICS and release 5QI1
    [Arguments]    ${ue_id}=2
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    ${cmd_register}=    Set Variable    ue_register id=${ue_id} nwslice=1
    Execute Egate Command    ${cmd_register}    pass_regexp=Received REGISTRATION COMPLETE
    ${cmd_pdu}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${ret}=    Execute Egate Command    ${cmd_pdu}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 1 qfi 2
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} by=amf pdu=1    pass_regexp=Successfully released PDU Session with ID 1
    Trigger UE 5QI1 release
	
SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=3    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    ${cmd_pdu_regexp}
	Send And Verify Throuput
	
Verify Throuput
    [Arguments]    ${Tput_dl}=9.5    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=3    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=3    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=10
    Verify Throuput

Trigger paging from AMF
    Make UE to idle
    Paging from AMF
	Traffic Should Be OK    ue_id=3    type=sa

Make UE to idle
    ${cmd}    Catenate    amf_paging_param id=1 default_drx=256 max_paging_retries=1
    Execute Egate Command    ${cmd}
    ${cmd1}    Catenate    ue_ng_ctx_release id=3 cause=NAS_normal_release
    Execute Egate Command    ${cmd1}    UE Context Release Complete

Paging from AMF
    BuiltIn.Log    Start to paging
    ${cmd}    Catenate    amf_paging_start id=1 ue=3
    Execute Egate Command    ${cmd}    Initial Context Setup Successful

Check message and counter
	Check Wireshark Log    ${CURDIR}${/}a2a_CIT006${/}CIT006.ini    wait_string=UEContextModificationResponse::8
	Release Ues    ue_type=all
	Check Counters    ${PM_Counters_CIT006_CIT007}

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs
	
	
	
