*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env And IP added for simGNB
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs And start TCE
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-Blues_SGT&A    owner-zora.wang    release-5G23R4     CB008281
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{8281_enable}
...    @{PCMD_related}
...    @{parameters_related_to_Voice_call}
...    @{5GC000749}

@{parameters_related_to_Voice_call}

...    NRBTS-1:actNormVCFallback=true
...    NRBTS-1/NRCELL-1:actVoNR=false
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=0
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
...    NRBTS-1/NRDRB-15:discardTimer=150ms
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=6
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=1
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
...    NRBTS-1/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRBTS-1/NRDRB-16:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
@{5GC000749}
...    NRBTS:actNormVCFallback=true
...    NRBTS:actRedirect=true
...    NRCELL-1:voiceFBMode=redirection
...    NRCELL/NRREDRT-1:redirFreqEutra=39750
...    NRCELL/NRREDRT-1:redirRat=eutra
...    NRCELL/NRREDRT-1:redirPrio=5
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    NRCELL/NRREDRT-2:redirRat=nr
...    NRCELL/NRREDRT-2:redirSsbScs=30 KHz
...    NRCELL/NRREDRT-2:redirFreqNr=636666
...    NRCELL/NRREDRT-2:redirPrio=4

@{8281_enable}
...    NRBTS-1:timerRRCGuard=6000
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:nrEcidMeasSupervisionTimer=6100
...    NRBTS:tRLFindForDU=300ms
...    NRBTS:tRLFindForDUSA=300ms
...    NRCELL:rlpDetCsiBsiThreshold=3
...    NRCELL:rlpDetDlHarqThreshold=2

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

@{SBA_disable}
...    NRBTS:actSubscriberTraceReport=false

${UECapabilitiesWithVONR}    SEPARATOR=
...    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830E00
...    08193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB0405
...    0D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE38720C380
...    02064F1F55000005000000108389800000000404C17020070080880301EC2E003000281C1401C0C026007000683E0000000000000E54D0001
...    00000965950034AAA85800E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094C2680

@{ECID_Failure_and_redirection}
...    Received ECID Measurement Failure
...    Redirected carrier info is present in RRC Release
...    NgLink::OnReceiveUeContextReleaseComplete

*** Test Cases ***
CB008281-ET-A037_Cell Trace record during UL NR-ECID measurement for the positioning
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:This user scenario validates the cell trace records and/or
    ...    subscriber and equipment trace records when UE reports UL NR Enhanced Cell ID based on NR based measurement.
    ...    2. Test Case Steps:
    ...       a. setup SA call sucessfully.
    ...       b. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to On-Demand and Measurement
    ...         Quantity requested is "SS-RSRP".
    ...       c. gNB-CU-CP initiates E-CID MEASUREMENT INITIATION RESPONSE to LMF.
    ...       d. check cell trace.
    [Tags]     QC_303707    A037
    SA UE attach with single PDU
    trigger E-CID Measurement Initiation request
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_A037${/}a2a.ini    wait_string=UEContextReleaseComplete::8

CB008281-ET-A042_Verify Cell Trace or Subscriber Equipment trace when that gNB-CU-CP initiates termination of E-CID MEASUREMENT when RLF
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:US CB008281-A#B6:Verify that gNB-CU-CP initiates termination
    ...       of E-CID MEASUREMENT when RLF detection is notified by gNB-DU.
    ...    2. Test Case Steps:
    ...       a. setup SA call sucessfully.
    ...       b. delay 5s to send MR.
    ...       c.LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to On-Demand and Measurement
    ...         Quantity requested is "SS-RSRP,SS-RSRQ". While waiting for the MeasurementReport from the UE, egate simUe trigger radio link
    ...         failure, gnb receives F1AP: UE CONTEXT MODIFICATION REQUIRED with the cause indicating the RL Failure. gNB-CU-CP identifies that
    ...         E-CID Measurement reporting is configured for the UE,stops the E-CID Measurement supervision timer,forms E-CID MEASUREMENT
    ...         INITIATION FAILURE (RNL Cause = Requested Item Temporarily not Available).
    ...       d. check cell trace,then ue deregist.
    ...       e. online set actSubscriberTraceReport to false. setup SA call sucessfully.
    ...       f. delay 5s to send MR.
    ...       g.LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to On-Demand and Measurement
    ...         Quantity requested is "SS-RSRP,SS-RSRQ". While waiting for the MeasurementReport from the UE, egate simUe trigger radio link
    ...         failure, gnb receives F1AP: UE CONTEXT MODIFICATION REQUIRED with the cause indicating the RL Failure. gNB-CU-CP identifies that
    ...         E-CID Measurement reporting is configured for the UE,stops the E-CID Measurement supervision timer,forms E-CID MEASUREMENT
    ...         INITIATION FAILURE (RNL Cause = Requested Item Temporarily not Available).
    ...       h. check no sba cell trace.
    [Tags]     QC_303708    A042
    Start To Capture Wireshark Log    1st
    SA UE attach with single PDU for SBA trace
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request then UE CONTEXT MODIFICATION REQUIRED with the cause indicating the RL Failure
    Rlf recover to deactive
    UE Deregister From gNB For SBA
    Check Wireshark Log    ${CURDIR}${/}A2A_A042${/}a2a_1st.ini    name=1st    wait_string=UEContextReleaseComplete::14
    OnlineParamChange    ${SBA_disable}
    Start To Capture Wireshark Log    2nd
    SA UE attach with single PDU for SBA trace
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request then UE CONTEXT MODIFICATION REQUIRED with the cause indicating the RL Failure
    Check Wireshark Log    ${CURDIR}${/}A2A_A042${/}a2a_2nd.ini    name=2nd    wait_string=UEContextReleaseComplete::6
    [Teardown]    A042_Teardown

CB008281-ET-A047_Verify Cell Trace or Subscriber Equipment trace when that E-CID Measurement is terminated when Voice Fallback to LTE
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:US CB008281-A#B11: Verify that E-CID Measurement is terminated
    ...        by the gNB-CU-CP when the Call is Released with redirection initiated as part Voice Fallback to LTE.
    ...    2. Test Case Steps:
    ...       a. setup SA call sucessfully.
    ...       b. delay 5s to send MR.
    ...       c.LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to On-Demand and Measurement
    ...         Quantity requested is "SS-RSRP,SS-RSRQ". While waiting for the MeasurementReport from the UE, add DRB 5QI-1 to PDU session,
    ...         NGAP:PduSessionResourceModifyRequest from 5GC requesting to setup QoS flow with 5QI=1.gNB-CU-CP decides to initiate a voice
    ...         fallback procedure using redirection method if the redirection is configured and triggers Release with redirection.
    ...         E-CID Measurement reporting is configured for the UE,stops the E-CID Measurement supervision timer,forms E-CID MEASUREMENT
    ...         INITIATION FAILURE (RNL Cause = Requested Item Temporarily not Available).
    [Tags]     QC_304049    A047
    SA UE attach with single PDU for SBA trace VONR
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request then add DRB 5QI-1 to PDU session    pass_regexp=${ECID_Failure_and_redirection}
    Check Wireshark Log    ${CURDIR}${/}A2A_A047${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env And IP added for simGNB
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK

Common Test Setup And Start To Capture Logs And start TCE
    Common Test Setup And Start To Capture Logs
    Start TCE    ${TCE_PORT}

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_param id=1 nr_usage_setting=voice_centric ue_nr_capabilities=${UECapabilitiesWithVONR}
    Update Cfg    ue_param id=2 nr_usage_setting=voice_centric ue_nr_capabilities=${UECapabilitiesWithVONR}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=7
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 amf=1 default=on qos_flows=1,2,3,4 qos_rules=1,2 snssai=0x01:0xD143A5 ue=1-6
    Update Cfg    set_nwslice id=2 amf=1 qos_flows=1,2,3,4 qos_rules=1,2 snssai=0x01:0xD143A6 ue=1-6
    Update Cfg    set_nwslice id=3 amf=1 qos_flows=1,2,3,4 qos_rules=1,2 snssai=0x01:0xFFFFFF ue=1-6
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1 amf=1
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on voice_fallback=on

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

SA UE attach with single PDU for SBA trace VONR
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    ${command}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${TCE_IP}
    Execute Egate Command    ${command}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

SA UE attach with single PDU for SBA trace
    [Arguments]    ${ue_id}=1    ${target_cells}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    ${command}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${TCE_IP}
    Execute Egate Command    ${command}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

UE Deregister From gNB For SBA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ng_ue_trace_stop id=${ue_id} trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

A042_Teardown
    Rlf recover to deactive
    OnlineParamChange    ${CellTrace_enable}
    UE Deregister From gNB For SBA
    Common Test Teardown And Stop Capture Logs

Rlf recover to deactive
    Execute Egate Command    rlf_testmode_nr profile_id=1 num_stop_csi_report=200 num_stop_dlharq_tx=100
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=1

Delay Measurement Report from UE
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=5000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

trigger E-CID Measurement Initiation request then UE CONTEXT MODIFICATION REQUIRED with the cause indicating the RL Failure
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP,SS-RSRQ    ${tid}=1
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    ${cmd1}    Catenate    rlf_testmode_nr profile_id=1 num_stop_csi_report=200 num_stop_dlharq_tx=100
    ${uctmr_cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1
    Execute Egate Command    ${cmd1}
    Execute Egate Command    ${cmd}    pass_regexp=saved periodic meas report will be sent after 5000 ms with MeasId
    ${ret1}=    Execute Egate Command    ${uctmr_cmd}    pass_regexp=UE Context Release Complete

trigger E-CID Measurement Initiation request then add DRB 5QI-1 to PDU session
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP,SS-RSRQ    ${pass_regexp}=Received ECID Measurement Response
    ${cmd1}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd1}    pass_regexp=saved periodic meas report will be sent after 5000 ms with MeasId
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=${pass_regexp}
