*** Settings ***
Documentation
...    author: xiujuan.sun
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-L3CN3_SG1    owner-xiujuan.sun    release-SBTS23R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    master_vDU
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T

@{rrcReestabTypeSAEqualSameGNB}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tRLFindForDUSA=3000ms
...    NRBTS:tWaitingRlRecoverSA=5000ms

${NG_FLOW_REL_GNB_NG_RESET_5QI1}    M55125C09501
${NG_FLOW_REL_GNB_NG_RESET_PMQAP}    M55163C00502    # Increase NG_FLOW_REL_AMF_NG_RESET_PMQAP by the number of released Qos(s).
@{PM_Counters_SA_Call_and_voiceCall_Release_Due_to_ngcFlex_disabled}
...    NRCELL-1:${NG_FLOW_REL_GNB_NG_RESET_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0

${X2_UEREL_INCOMING_RESET}    M55110C00019
${X2_UEREL_INC_PARTIAL_RESET}    M55110C00027
@{X2_UEREL_INC_PARTIAL_RESET_and_Incoming_Reset}
...    NRBTS-1:${X2_UEREL_INCOMING_RESET}=2
...    NRBTS-1:${X2_UEREL_INC_PARTIAL_RESET}=0

@{cuUeIdToLinkMappingUpdateDelay}    NRBTS:cuUeIdToLinkMappingUpdateDelay=500ms
@{PARAMS_IN_SCF_CU}
...    @{cuUeIdToLinkMappingUpdateDelay}
...    @{forPMPCounterCalc}
...    @{actNSASlice}
...    @{forXNHOandRRE}
@{PARAMS_IN_SCF_DU1}    @{actNSASlice_of_du}    @{forPMPCounterCalc_DU}
@{PARAMS_IN_SCF_DU2}    @{actNSASlice_of_du}    @{forPMPCounterCalc_DU}

@{forPMPCounterCalc}
...    NRBTS:actNrpmqapProfiles=true
...    NRBTS/NRDRB-5:actDddsReduction=false
...    NRBTS/NRDRB-5:actLostPduFastRetx=false
...    NRBTS/NRDRB-5:discardTimer=20ms
...    NRBTS/NRDRB-5:dlFlowControlAlgo=none
...    NRBTS/NRDRB-5:dscp=0
...    NRBTS/NRDRB-5:durationThresDiscardDl=50
...    NRBTS/NRDRB-5:endMarkerTimer=2000
...    NRBTS/NRDRB-5:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-5:maxTransferDelayGbr=20
...    NRBTS/NRDRB-5:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-5:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-5:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-5:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-5:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-5:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-5:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-5:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-5:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-5:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-5:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-5:numSduDiscard=1
...    NRBTS/NRDRB-5:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-5:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-5:resType=GBR
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:rlcMode=RLC_UM
...    NRBTS/NRDRB-5:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-5:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-5:volThresDiscardDl=100
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    NRBTS/NRDRB_PDCP-3:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-3:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgArpRange=${EMPTY}
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgQciRange=${EMPTY}
...    NRBTS/SERVEDAMF-2:administrativeState=Unlocked
...    NRBTS/SERVEDAMF-2:amfIPAddress=10.0.11.2
...    NRBTS/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgInterfaceNrpmqap=5min
...    NRCELL:actVoNR=true

@{forPMPCounterCalc_DU}    NRBTS:actNrpmqapProfiles=true
...    NRCELL:actVoNR=true
...    NRBTS/NRDRB-5:discardTimer=20ms
...    NRBTS/NRDRB-5:dlFlowControlAlgo=none
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-5:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-5:resType=GBR
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:rlcMode=RLC_UM
...    NRBTS/NRDRB-5:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-5:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-5:schedulWeight=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulBSD=20ms
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgProfType=both

@{actNSASlice}
...    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:s1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-4/IPADDRESSV4-1
...    NRBTS/NRNWSLICE_NSA-1:f1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1

@{actNSASlice_of_du}
...    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:f1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1

@{forXNHOandRRE}    @{XNHO}    @{rrcReestabTypeSAEqualSameGNB}
@{XNHO}
...    NRBTS:actIncXn=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=35
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=0
...    NRBTS/NRADJNRCELL-1:physCellId=48
...    NRBTS/NRADJNRCELL-1:ssbFrequency=636576
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=36
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=36
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-1:gNbId=35
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:handoverAllowedSA=allowed
...    NRCELL/NRREL-1:lcrId=1
...    NRCELL/NRREL-1:removeNotAllowed=false
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.12.11
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled

@{ngcFlexDisabled}    NRBTS:actNgcFlexSaMode=false    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
@{ngcFlexEnabled}    NRBTS:actNgcFlexSaMode=true    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min

${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D
...    220624FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840
...    A12DF3F33BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077
...    F1FF000330014001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A020002188150785000
...    18280002988100900A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C
...    631BFFFE000138036002800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020
...    080220800402008410008040188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA0200007
...    2CB2801A83D5D2AAAA0F174AA283839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C07
...    0079BF01C070079BF01C070079BF01C0700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400
...    700A01201802001C0380180800301200A02801041C0080180100300400A0080103801001004002004004010001AB06020721252627287
...    70000000361781C06000601A

*** Test Cases ***
CB008926-SR-A-B2_ET_01_13_CPIF triggered partial reset via disable ng-c flex function in AiC
    [Tags]
    [Documentation]
    Clear Counter and Set Test Variable for CaseB2-013
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=1    ue_id_end_before=11    shallRecordUELocationOfAMF=True
    ADD QosFlow For AMF2 UEs
    Delta Commission Parameters Cu    ${ngcFlexDisabled}
    sleep    10s    waiting for UE released completed
    Checking UEs in AMF2 shall be Released and corresponding counter shall be updated
    Should Not Be Empty    ${UEIDs_IN_AMF2}    there should be one UEs created at AMF2 at least.
    Release Ues    ue_type=all

CB008926-SR-A-B1_ET_01_01_vDU triggered F1 partial reset for NSA UE when the used QCI is removed for NSA Slice update in AiC
    [Tags]
    [Documentation]    for QCI testing
    Set X2 Link Up
    Create two NSA calls and two SA calls and set ueID as Test Variables
    Delta Commission Parameters Du2    NRBTS:actNsaSlice=false
    sleep    10s    checking F1 partical reset message
    Delta Commission Parameters Du2    NRBTS:actNsaSlice=true
    Set Test Variable     @{expecte_active_ue_list}    1    2    31    32
    Checking UEs status should be active    ${expecte_active_ue_list}
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_A-B1-01${/}a2a.ini    wait_string=procedureCode: id-Reset::6
    Release Ues    ue_type=all

CB008926-SR-A-B3_ET_01_02_Enb triggered X2 reset for NSA UE in AiC
    [Tags]
    Set X2 Link Up
    Clear Counter Files Cu Aic
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    Trigger X2 Link reset
    Set X2 Link Up
    Check Counters Cu Aic    ${X2_UEREL_INC_PARTIAL_RESET_and_Incoming_Reset}
    Release Ues    ue_type=all

CB008926-SR-B-B4_ET_01_05_Xn Handover can be done after RRC reestablishment in AiC
    [Tags]
    Set XN Link Up
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=1
    UE RRE to cell shall be successful    ue_id=1    cell_id=1
    UE RRE fallback to cell shall be successfully    ue_id=2    cell_id=2
    Trigger UE1 and UE2 XN HO to simgNB successfully
    sleep    60s    wait for the origin uecontext of UE2 before RRE fallback release by RLF to aviod hanging resource checking failure
    Release Ues    ue_type=all


*** Keywords ***
Checking UEs in AMF2 shall be Released and corresponding counter shall be updated
    Should Not Be Empty    ${UEIDs_IN_AMF2}    there should be one UEs created at AMF2 at least.
    ${expected_5QIC1_counter}    Evaluate    len(${UEIDs_IN_AMF2})
    ${expected_NG_RESET_PMQAP_counter}    Evaluate    2 * len(${UEIDs_IN_AMF2})
    @{PM_Counters_SA_Call_and_voiceCall_Release_Due_to_ngcFlex_disabled}    Create List
    ...    NRCELL-2:${NG_FLOW_REL_GNB_NG_RESET_5QI1}=${expected_5QIC1_counter}
    ...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=${expected_NG_RESET_PMQAP_counter}
    Check Counters Cu Aic    ${PM_Counters_SA_Call_and_voiceCall_Release_Due_to_ngcFlex_disabled}

Clear Counter and Set Test Variable for CaseB2-013
    Clear Counter Files Cu Aic
    ${UECONTEXT_IN_AMF2}    Create List
    Set Test Variable    \${UECONTEXT_IN_AMF2}
    ${UEIDs_IN_AMF2}    Create List
    Set Test Variable    \${UEIDs_IN_AMF2}

Create two NSA calls and two SA calls and set ueID as Test Variables
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=2
    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=2
    ${nsa1_enb_x2apId}    ${nsa1_gnb_x2apid}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=2
    ${nsa2_enb_x2apId}    ${nsa2_gnb_x2apid}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=2
    Set Test Variable    \${nsa1_enb_x2apId}
    Set Test Variable    \${nsa1_gnb_x2apid}
    Set Test Variable    \${nsa2_enb_x2apId}
    Set Test Variable    \${nsa2_gnb_x2apid}

UE RRE to cell shall be successful
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    ...    pass_regexp=UE${ue_id}: NR RRC Reestablishment suc

UE RRE fallback to cell shall be successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
    ...    pass_regexp=Initial Context Setup Successful for UE

Trigger UE1 and UE2 XN HO to simgNB successfully
    [Arguments]    ${ue_id1}=1    ${ue_id2}=2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id1} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=10 phycell_id=48 nrsrp_nr=90 nrsrq_nr=34
    ...    pass_regexp=NgLink::OnReceivePathSwitchRequest
    Execute Egate Command    ue_measurement_send_nr id=${ue_id2} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=10 phycell_id=48 nrsrp_nr=90 nrsrq_nr=34
    ...    pass_regexp=NgLink::OnReceivePathSwitchRequest

Set X2 Link Up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up    timeout=120

Trigger X2 Link reset
    Execute Egate Command    link_x2_reset from=1 to=2     pass_regexp=Bearer-type change from SCG-split to MCG is successful    timeout=2

Set XN Link Up
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    pass_regexp=GNB-3: XnAP Link with GNB-2

NSA UE ICS and setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    [Return]    ${MeNB_x2apIDList[0]}    ${sgNB_x2apIDList[0]}
    UE Attach To ENB    ${ue_id}
    ${command}    catenate
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ${output}    Execute Egate Command    ${command}    pass_regexp=SgNBAdditionRequestAcknowledge
    ${MeNB_x2apIDList}    Get Regexp Matches    ${output}    value UE-X2AP-ID : (\\d+)    1
    ${sgNB_x2apIDList}    Get Regexp Matches    ${output}    value SgNB-UE-X2AP-ID : (\\d+)    1

Trigger NG reset for UE1
    Execute Egate Command    link_ng_reset by=amf:1 ue=1 ue_ngap_id_type=amf    pass_regexp=NgLink::OnReceiveNgResetAcknowledge

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}    ${shallRecordUELocationOfAMF}=False
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        ${amf_index}    ${sa_ueID}    ${amf_ngap_id}    Register For Normal Call and create PDU Successfully    ${ue_id}    ${cell_id}
        Run keyword If    ${shallRecordUELocationOfAMF} and ${amf_index}==2    Append To list    ${UECONTEXT_IN_AMF2}    ${sa_ueID}
        Run keyword If    ${shallRecordUELocationOfAMF} and ${amf_index}==2    Append To list    ${UEIDs_IN_AMF2}    ${ue_id}

    END

Modify Cfg Aic
    Set QCI and Qos in WTS
    Set Bear in WTS
    Enable VoiceOverNRSupported in Uecapability for SA UE
    Set Sim gNB
    Set Second Sim AMF

Enable VoiceOverNRSupported in Uecapability for SA UE
    FOR    ${ue_id}    IN RANGE    1    30
        Update Cfg Aic    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
	END

Set QCI and Qos in WTS
    Update Cfg Aic    set_qosflow id=1 5qi=5 default=on
    Update Cfg Aic    set_qosflow id=2 5qi=6 default=off
    Update Cfg Aic    set_qosflow id=3 5qi=1
    Update Cfg Aic    enb_param id=1 drb_id_begin=3 endc_capable_qci=98
    Update Cfg Aic    qci_set qci=98 gbr=no priority=9 delay=300


Set Bear in WTS
    ${bearSetting1}    catenate
    ...    set_bearer id=2 ue=31 qci=98 pdn=1 ip=4.7.254.208 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting2}    catenate
    ...    set_bearer id=2 ue=32 qci=98 pdn=1 ip=4.7.254.209 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting3}    catenate
    ...    set_bearer id=2 ue=33 qci=98 pdn=1 ip=4.7.254.210 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting4}    catenate
    ...    set_bearer id=2 ue=34 qci=98 pdn=1 ip=4.7.254.211 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting5}    catenate
    ...    set_bearer id=2 ue=35 qci=98 pdn=1 ip=4.7.254.212 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg Aic    ${bearSetting1}
    Update Cfg Aic    ${bearSetting2}
    Update Cfg Aic    ${bearSetting3}
    Update Cfg Aic    ${bearSetting4}
    Update Cfg Aic    ${bearSetting5}

Set Sim gNB
    ${v1}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 ng=10.0.11.10 gnb_id=0x01:22 daemon=10.0.2.1:22222 xn=10.0.12.10
    ...    s1u=10.0.1.210 x2=10.0.1.10:36422 x2u=10.0.1.210 x2_peers=none amf=1-2
    ${v2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.12 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.12.11 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1-2

    Update Cfg Aic    ${v1}
    Update Cfg Aic    ${v2}
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    ${cfg_cmd_3}    catenate
    ...    set_cell id=1 gnb=3 pci=16:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg Aic    ${cfg_cmd_3}
    Update Cfg Aic    amf_ng_setup_param id=1 gnb=2 action=Respond_in_active_state ntimes=indefinite nth=1
    Update Cfg Aic    amf_ng_setup_param id=2 gnb=2 action=Respond_in_active_state ntimes=indefinite nth=1

Set Second Sim AMF
    ${v1}    catenate
    ...    amf_param id=2 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept full_nas_auth=on
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    Update Cfg Aic    set_amf_region id=2 tac_list=200,280,300,400,500,600 plmn=311:489,311:490,311:491
    Update Cfg Aic    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.11.2:38412 region=2 set_id=1 pointer=1
    Update Cfg Aic    ${v1}
    Update Cfg Aic    set_backup_amf main=1 backup_amfs=2
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:13714341 amf=1-2 default=on ue=all

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

UE Register To GNB
    [Arguments]    ${ue_id}
    [Return]    ${matchecd_groups}[0][0]    ${matchecd_groups}[0][1]    ${matchecd_groups}[0][2]
    ${output}    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    ${filter_string}    catenate
    ...    AMF-(\\d+): UE with RAN UE NGAP ID (\\d+) and AMF UE NGAP ID (\\d+) is now Registered
    ${matchecd_groups}    Get Regexp Matches    ${output}    ${filter_string}    1    2    3
    log    ${matchecd_groups}[0][0]
    log    ${matchecd_groups}[0][1]
    log    ${matchecd_groups}[0][2]

Register For Normal Call and create PDU Successfully
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=2
    [Return]    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}    UE Register To GNB    ${ue_id}
    UE PDU Session Setup    ${ue_id}    ${ue_id}

Checking UEs status should be active
    [Arguments]    ${expecte_active_ue_list}
    ${active_ue_list}    get_active_ue
    Lists Should Be Equal    ${active_ue_list}    ${expecte_active_ue_list}

ADD QosFlow For AMF2 UEs
    FOR    ${ue_id}    IN    @{UEIDs_IN_AMF2}
        Execute Egate Command     ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    QoS Routing Table
	END
