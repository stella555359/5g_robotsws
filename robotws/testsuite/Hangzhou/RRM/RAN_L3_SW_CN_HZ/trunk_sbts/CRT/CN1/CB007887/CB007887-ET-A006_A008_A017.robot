*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_TDD  CRT  CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD  team-SG2
...               owner-Dan.Liu  release-22R3
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{Mobility}
...    @{SNSSAI}
...    @{Bearer}
...    @{fixed_relation_error}
...    @{NRREL}
...    NRCELL:gscnOrSsPbchArfcn=1587
...    NRCELL:actARPBasedAC=handovers
...    NRCELL/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    delete:fiveGsTac
...    delete:trackingAreaDN
...    NRCELL:n310VoNR=n3
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL:maxGBRTrafficLimit=75
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:t310VoNR=500ms
...    NRBTS:actConflictConfiguration=true
...    NRBTS:integrityProtPrefL:nia0=1
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=9
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIncXn=true

...    NRBTS:xnLinkReestabTmr=180
...    NRBTS:actTrsSepaSARanSharing=false
...    NRBTS:actRanSharing=true
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS:drbInactivityTimerSA=7200
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1/NRPLMN-1:mcc=311
...    NRBTS-1/NRPLMN-1:mnc=489
...    NRBTS-1/NRPLMN-1:mncLength=3
...    NRBTS-1/NRPLMN-3:mcc=460
...    NRBTS-1/NRPLMN-3:mnc=02
...    NRBTS-1/NRPLMN-3:mncLength=3
...    NRBTS-1/NRPLMN-2:mcc=311
...    NRBTS-1/NRPLMN-2:mnc=402
...    NRBTS-1/NRPLMN-2:mncLength=3
@{Mobility}
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a5MeasEnabled=rsrp
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
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
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
@{Bearer}
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:nrDrbId=16
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:nrDrbId=15
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
@{SNSSAI}
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    delete:NRBTS-1/SNSSAI-2:ngUplane:ipV4AddressDN1
...    delete:NRBTS-1/SNSSAI-3:ngUplane:ipV4AddressDN1
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS-1/SNSSAI-3:sst=1
...    NRBTS-1/SNSSAI-3:sd=13714342
...    NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3

@{NRREL}
...  NRADJNRCELL-1:cellDepType=SA
...  NRADJNRCELL-1:fiveGsTac=788
...  NRADJNRCELL-1:gNbId=35
...  NRADJNRCELL-1:gNbIdLength=22
...  NRADJNRCELL-1:lcrId=1
...  NRADJNRCELL-1:nrarfcn=126900
...  NRADJNRCELL-1:physCellId=381
...  NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...  NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-10:gNbId=35
...  NRCELL-1/NRREL-10:gNbIdLength=22
...  NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...  NRCELL-1/NRREL-10:lcrId=1
...  NRCELL-1/NRREL-10:removeNotAllowed=false
...  NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
...  NRADJNRCELL-2:cellDepType=SA
...  NRADJNRCELL-2:fiveGsTac=0
...  NRADJNRCELL-2:gNbId=36
...  NRADJNRCELL-2:gNbIdLength=22
...  NRADJNRCELL-2:lcrId=3
...  NRADJNRCELL-2:nrarfcn=126900
...  NRADJNRCELL-2:physCellId=48
...  NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...  NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-1:gNbId=36
...  NRCELL-1/NRREL-1:gNbIdLength=22
...  NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...  NRCELL-1/NRREL-1:lcrId=3
...  NRCELL-1/NRREL-1:removeNotAllowed=false
...  NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
@{fixed_relation_error}
...    NRBTS:timerXnDataFwdGuard=250
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN
...    NRCELL:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=30|a2TimeToTriggerhoSsbRsrq=ms480
...    delete:NRCELL:configuredEpsTac
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB_5QI-7:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
@{Online_Param_A006}
...    NRCELL:actARPBasedAC=handovers
...    NRCELL:pduHoSliceRelease=true
@{Online_Param_A008}
...    NRCELL:actARPBasedAC=handovers
...    NRCELL:pduHoSliceRelease=true
@{Online_Param_A017}
...    NRCELL:actARPBasedAC=off
...    NRCELL:pduHoSliceRelease=false
${UE_nr_sa_capability}  SEPARATOR=
...  21A01000010980200004600002681001C4600000000713400000801808D0137FD555540B00C000A070300F0600B00F000D03C0100000000000
...  0000040140622A001000000000000100400C0A8010008010020010040084A00008C35A
@{PM_COUNTERS_A006}
...    NRBTS-1:${HO_PDU_SES_NOT_ADMI_RECD_SLICE}=2
...    NRBTS-1:${HO_REQ_PDU_SESS_RES_SENT_SLICE}=3
...    NRCELL-1:${NF1CC_UECTXT_STP_REQSENT}=2
...    NRCELL-1:${NF1CC_UECTXT_STP_RESPRECD}=2
...    NRCELL-1:${SUCC_OG_INTER_GNB_HO_SA_PLMN}=1
...    NRCELL-1:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=1
...    NRCELL-1:${TOT_INTRA_FREQ_HO_DECISION_A3S}=1
...    NRCELL-1:${NNGCC_PDUSESMODREQ_RECD}=1
...    NRBTS-1/NRDU-1:${NF1CD_UECTXT_STP_REQRECD}=2
...    NRBTS-1/NRDU-1:${NF1CD_UECTXT_REL_CMDRECD}=1
...    NRBTS-1/NRDU-1:${NF1CD_UECTXT_REL_CMPSENT}=1
@{PM_COUNTERS_A008}
...    NRCELL-1:${NNGCC_PDUSESMODREQ_RECD}=1
${HO_PDU_SES_NOT_ADMI_RECD_SLICE}    M55149C02003
${HO_REQ_PDU_SESS_RES_SENT_SLICE}    M55149C02004
${NF1CC_UECTXT_STP_REQSENT}     M55113C01001
${NF1CC_UECTXT_STP_RESPRECD}    M55113C01002
${NF1CD_UECTXT_STP_REQRECD}    M55117C01001
${NF1CD_UECTXT_REL_CMDRECD}    M55117C01009
${NF1CD_UECTXT_REL_CMPSENT}    M55117C01010
${SUCC_OG_INTER_GNB_HO_SA_PLMN}    M55145C00342
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
${TOT_INTRA_FREQ_HO_DECISION_A3S}    M55147C00001
${NNGCC_PDUSESMODREQ_RECD}     M55125C03501

*** Test Cases ***
CB007887-ET-A006_Verify_Successful_Inter_gnb_HO_with_partial_admission_with_EC_PDU_session_gnbsim_as_target
    [Documentation]
    ...    1. The purpose of this test case is to verify successful inter gnb ho with partial admission,
    ...       pduHoSliceRelease enabled and cell setting below:
    ...       ENB1 CELL1: support both standard slice and  non-standard slice.
    ...       ENB3 CELL1: only support standard slice. ---  Better signal.
    ...    2. Test Case Steps:
    ...         a. UE-1 setup call with 3 pdu sessions: EC_standardSlice, 5QI7_nonstandardSlice, 5QI5_nonstandardSlice
    ...         b. Setup pdu to release for target sim gnb.
    ...         c. UE-1 perform HO with 2 target cells.
    ...    3. Expected Results:
    ...         UE-1 HO to ENB3 CELL1 with non standard pdu session releases.
    ...    Wireshark log check:
    ...    HandoverRequestAcknowledge：PDU session admit 1, not admit 2.
    ...    RRCReconfiguration: Drb release 6,7
    ...    PM Counter check:
    ...    --per Slice per PLMN current function is not ready
    ...    M55149C02003==2  HO_PDU_SES_NOT_ADMI_RECD_SLICE
    ...    M55149C02004==3  HO_REQ_PDU_SESS_RES_SENT_SLICE
    [Tags]    QC_81696    owner-Dan.LiU   A006
    Setup Xn and online parameters    Online_Param=${Online_Param_A006}    ue_id=1
    UE register   ue_id=1     ue_sa_capabilities=${UE_nr_sa_capability}
    Setup 3 PDU sessions     ue_id=1    pdu_id_1st=1    pdu_id_2nd=2    pdu_id_3rd=3
    set Xn HO prep param to trigger partial HO     gnb_id=3    Rej_pdu_id_1=2    Rej_pdu_id_2=3
    Inter-gNB HO and patial AC     ue_id=1
    check counters     ${PM_COUNTERS_A006}
    check wireshark log  ${CURDIR}${/}A2A_A_006${/}a2a.ini
    release ues    ue_type=all

CB007887-ET-A008_Verify_Successful_Inter_gnb_HO_with_partial_admission_with_EC_and_normal_voice_PDU_session_gnbsim_as_target
    [Documentation]
    ...    1. The purpose of this test case is to verify  successful inter gnb ho with partial admission,
    ...       pduHoSliceRelease enabled and settings as below:
    ...       ENB1 CELL1: support both standard slice and  non-standard slice.
    ...       ENB3 CELL1: only support standard slice. ---  Better signal.
    ...    2. Test Case Steps:
    ...         a. UE-1 setup call with 3 pdu sessions: EC,5QI5Only_standardSlice, VONR_nonstandardSlice
    ...         b. Setup pdu to release for target sim gnb.
    ...         c. UE-1 perform HO with 2 target cells.
    ...    3. Expected Results:
    ...         UE-1 HO to ENB3 CELL1 with non standard pdu session releases.
    ...    Wireshark log check:
    ...    HandoverRequestAcknowledge：PDU session admit 1, not admit 1.
    ...    RRCReconfiguration: Drb release 6
    [Tags]    QC_81698    owner-Dan.LiU   A008
    Setup Xn and online parameters    Online_Param=${Online_Param_A008}    ue_id=2
    UE register   ue_id=2     ue_sa_capabilities=${UE_nr_sa_capability}
    Setup emegency call PDU session    ue_id=2     pdu_ses_id=4    req_type=initial-emergency-request
    Setup Normal PDU session with 5QI-5 with priority 15    ue_id=2       pdu_ses_id=5    gw_id=5
    ADD Qosflow to exist PDU session   ue_id=2      pdu_ses_id=5    qos_flow_id=2
    set Xn HO prep param to trigger partial HO     gnb_id=3    Rej_pdu_id_1=5    Rej_pdu_id_2=6
    Inter-gNB HO to gNB3 and patial AC     ue_id=2
    check counters     ${PM_COUNTERS_A008}
    check wireshark log  ${CURDIR}${/}A2A_A_008${/}a2a.ini
    release ues    ue_type=all

CB007887-ET-A017_Verify_Successful_Inter_gnb_HO_with_EC_PDU_session_source_not_allowed_partial_admission_gnbsim_as_target
    [Documentation]
    ...    1. The purpose of this test case is to verify  successful inter gnb ho with partial admission,
    ...       with pduHoSliceRelease disabled and cell setting below:
    ...       ENB1 CELL1: support both standard slice and  non-standard slice.
    ...       ENB3 CELL1: only support standard slice. ---  Better signal.
    ...    2. Test Case Steps:
    ...         a. UE-1 setup call with 3 pdu sessions: EC_standardSlice, 5QI7_nonstandardSlice, 5QI5_nonstandardSlice
    ...         b. UE-1 perform HO with 2 target cells.
    ...    3. Expected Results:
    ...         UE-1 HO to ENB1 CELL1.
    ...    Wireshark log check:
    ...    HandoverRequestAcknowledge：nr-rrc.physCellId == 48 (enb1.1) and not 381 (enb3.1)
    [Tags]    QC_81705    owner-Dan.LiU   A017
    Setup Xn and online parameters    Online_Param=${Online_Param_A017}    ue_id=3
    UE register   ue_id=3     ue_sa_capabilities=${UE_nr_sa_capability}
    Setup 3 PDU sessions     ue_id=3    pdu_id_1st=6    pdu_id_2nd=7    pdu_id_3rd=8
    Inter-gNB HO to gNB5 and patial AC     ue_id=3
    check wireshark log  ${CURDIR}${/}A2A_A_017${/}a2a.ini
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=7
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-4 qos_flows=1,2,3,4 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1 qos_flows=1,2,3,4 qos_rules=1,2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xFFFFFF ue=1-6 amf=1 qos_flows=1,2,3,4 qos_rules=1,2
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1 amf=1
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-10 nr_usage_setting=voice_centric ue_nr_capabilities=${UE_nr_sa_capability}
    Update Cfg    set_amf_region id=2 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=4 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=5 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    set_amf_region id=6 tac_list=0,100,258,788 plmn=311:489
    Update Cfg    amf_param id=1 ims_voice_3gpp=on full_nas_auth=on nia=null nea=null
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=10.12.2.1/24 ngu=10.0.1.1
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc voice_fallback=off ims_voice_3gpp=on
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc voice_fallback=off ims_voice_3gpp=on
    Update Cfg    amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc voice_fallback=off ims_voice_3gpp=on
    Update Cfg    amf_param id=5 full_nas_auth=on nia=null+zuc nea=null+zuc voice_fallback=off ims_voice_3gpp=on
    Update Cfg    amf_param id=6 full_nas_auth=on nia=null+zuc nea=null+zuc voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.10:38412 region=3 set_id=2 pointer=2
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.11:38412 region=4 set_id=2 pointer=2
    Update Cfg    set_amf id=5 daemon=10.0.2.1:22222 ng=10.0.1.12:38412 region=5 set_id=2 pointer=2
    Update Cfg    set_amf id=6 daemon=10.0.2.1:22222 ng=10.0.1.13:38412 region=6 set_id=2 pointer=2
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.0.7 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.0.8 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    FOR    ${ue_id}    IN RANGE    1    10
       ${ue_V}    catenate
    ...    set_ue simulated id=${ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540${ue_id} mode=nr enb=2 cell=1
       Update Cfg    ${ue_V}
    END
    FOR    ${ue_id}    IN RANGE    10   31
       ${ue_V}    catenate
    ...    set_ue simulated id=${ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:0216454${ue_id} mode=nr enb=2 cell=1
       Update Cfg    ${ue_V}
    END
    ${SIM-GNB3}  catenate  set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...  nssai=0x01:0xFFFFFF amf=1
    Update Cfg    ${SIM-GNB3}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=40
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=136100:126900 gscn=1587
    ${SIM-GNB5}  catenate  set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.122
    ...  nssai=0x01:0xFFFFFF,0x1:0xd143a5,0x1:0xd143a6,0x1:0xd143a8 amf=1
    Update Cfg    ${SIM-GNB5}
    Update Cfg    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x03 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
    Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false
    ${GNB2}  catenate  set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22 daemon=10.0.2.1:22222
    ...  xn=10.0.1.2 x2_peers=none amf=1-3
    Update Cfg    ${GNB2}
    ${GNB2_cell}  catenate  set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 eci=0x000021f tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888
    ...  nr_arfcn=136100:126900 gscn=1587
    Update Cfg    ${GNB2_cell}

Setup Xn and online parameters
   [Arguments]  ${Online_Param}    ${ue_id}
   Xn link SETUP and Recovery
   OnlineParamChange      ${Online_Param}
   clear counter files
   before UE register    ${ue_id}

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be OnAir

before UE register
    [Arguments]   ${ue_id}=1
    Execute Egate Command     ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command     ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=5 time_ue_stayed_in_cell=97
    Execute Egate Command     ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=97
    Execute Egate Command     ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command     ue_enb_param id=${ue_id} ue_history_list=${ue_id}

UE register
    [Arguments]   ${ue_id}=1    ${ue_sa_capabilities}=1
    Execute Egate Command     qosflow_modify qos_flow=1 default=on
    Execute Egate Command     ue_register id=${ue_id} ue_nr_capabilities=${ue_sa_capabilities}    UE performed Registration

Setup 3 PDU sessions
    [Arguments]   ${ue_id}=1    ${pdu_id_1st}=1    ${pdu_id_2nd}=1    ${pdu_id_3rd}=1
    Setup emegency call PDU session    ue_id=${ue_id}     pdu_ses_id=${pdu_id_1st}    req_type=initial-emergency-request
    ADD Qosflow to exist PDU session   ue_id=${ue_id}       pdu_ses_id=${pdu_id_1st}    qos_flow_id=2
    Setup Normal PDU session with 5QI-7    ue_id=${ue_id}       pdu_ses_id=${pdu_id_2nd}    gw_id=${pdu_id_2nd}
    Setup Normal PDU session with 5QI-5    ue_id=${ue_id}       pdu_ses_id=${pdu_id_3rd}    gw_id=${pdu_id_3rd}

Setup emegency call PDU session
    [Arguments]   ${ue_id}=1    ${pdu_ses_id}=1    ${req_type}=initial-emergency-request
    Execute Egate Command     qosflow_modify qos_flow=1 priority=1
    Execute Egate Command     qosflow_modify qos_flow=2 priority=1
    Execute Egate Command     qosflow_modify qos_flow=1 default=on
    Execute Egate Command     set_pdu_param ue=${ue_id} pdu=${pdu_ses_id} trf_type=internal
    ${ret}   Execute Egate Command     ue_pdu_session_setup pdu=${pdu_ses_id} ue=${ue_id} nwslice=3 gw=${pdu_ses_id} request_type=${req_type}
    ...    pass_regexp=Initial Context Setup Successful
    Should Contain    ${ret}    PduId ${pdu_ses_id} Created FiveQi:Qfi mapping fiveQi 5 qfi 1


ADD Qosflow to exist PDU session
    [Arguments]   ${ue_id}=1    ${pdu_ses_id}=1    ${qos_flow_id}=2
    ${ret}   Execute Egate Command     ue_pdu_session_modify ue=${ue_id} pdu=${pdu_ses_id} qosflows_to_add=${qos_flow_id} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with .* handled successfully
    Should Contain    ${ret}    AMF-1: Added QosFlow with QFI:${qos_flow_id} 5QI:1

Setup Normal PDU session with 5QI-7
    [Arguments]   ${ue_id}=1    ${pdu_ses_id}=1    ${gw_id}=2
    Execute Egate Command     qosflow_modify qos_flow=1 priority=15
    Execute Egate Command     qosflow_modify qos_flow=2 priority=15
    Execute Egate Command     qosflow_modify qos_flow=3 default=on
    Execute Egate Command     set_pdu_param ue=${ue_id} pdu=${pdu_ses_id} trf_type=internal
    ${ret1}   Execute Egate Command     ue_pdu_session_setup pdu=${pdu_ses_id} ue=${ue_id} nwslice=1 gw=${gw_id}
    ...    pass_regexp=Pdu Session Resource Setup Response Message with .* handled successfully
    Should Contain    ${ret1}    PduId ${pdu_ses_id} Created FiveQi:Qfi mapping fiveQi 7 qfi 1
    Should Contain    ${ret1}    AMF-1: Setup QosFlow with QFI:1 5QI:7

Setup Normal PDU session with 5QI-5 with priority 15
    [Arguments]   ${ue_id}=1    ${pdu_ses_id}=1    ${gw_id}=2
    Execute Egate Command     qosflow_modify qos_flow=1 priority=15
    Execute Egate Command     qosflow_modify qos_flow=2 priority=15
    Execute Egate Command     qosflow_modify qos_flow=1 default=on
    Execute Egate Command     set_pdu_param ue=${ue_id} pdu=${pdu_ses_id} trf_type=internal
    ${ret1}   Execute Egate Command     ue_pdu_session_setup pdu=${pdu_ses_id} ue=${ue_id} nwslice=1 gw=${gw_id}
    ...    pass_regexp=Pdu Session Resource Setup Response Message with .* handled successfully
    Should Contain    ${ret1}    PduId ${pdu_ses_id} Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    Should Contain    ${ret1}    AMF-1: Setup QosFlow with QFI:1 5QI:5

Setup Normal PDU session with 5QI-5
    [Arguments]   ${ue_id}=1    ${pdu_ses_id}=1    ${gw_id}=3
    Execute Egate Command     qosflow_modify qos_flow=1 default=on
    Execute Egate Command     set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    ${ret1}   Execute Egate Command     ue_pdu_session_setup pdu=${pdu_ses_id} ue=${ue_id} nwslice=1 gw=${gw_id}
    ...    pass_regexp=Pdu Session Resource Setup Response Message with .* handled successfully
    Should Contain    ${ret1}   PduId ${pdu_ses_id} Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    Should Contain    ${ret1}   AMF-1: Setup QosFlow with QFI:1 5QI:5

set Xn HO prep param to trigger partial HO
    [Arguments]   ${gnb_id}=3   ${Rej_pdu_id_1}=2    ${Rej_pdu_id_2}=3
    Execute Egate Command     gnb_xn_handover_preparation_param id=${gnb_id} reset
    Execute Egate Command     smf_param id=1 ran_removed_pdu_action=internal_release
    Execute Egate Command     gnb_param id=${gnb_id} pdu_to_reject=${Rej_pdu_id_1}
    Execute Egate Command     gnb_param id=${gnb_id} pdu_to_reject=${Rej_pdu_id_2}

Inter-gNB HO and patial AC
    [Arguments]   ${ue_id}=1    ${targetGnb}=3
    ${meas_id}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${a3_cmd}    catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=30
    ...  nrsrq_nr=30 phycell_id=48 nrsrp_nr=25 nrsrq_nr=25
    Execute Egate Command     ${a3_cmd}     Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Execute Egate Command     gnb_xn_handover_preparation_param id=${targetGnb} reset
    ${meas_id_tgt}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126990    event_type=A3    threshold=choice=1
    ${a3_cmd_tgt}  catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_tgt} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=60 nrsrp_nr=30
     ...  nrsrq_nr=30
    Execute Egate Command     ${a3_cmd_tgt}    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

Inter-gNB HO to gNB3 and patial AC
    [Arguments]   ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${a3_cmd}  catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=30
    ...  nrsrq_nr=30 phycell_id=48 nrsrp_nr=25 nrsrq_nr=25
    Execute Egate Command     ${a3_cmd}     Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Execute Egate Command     ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${meas_id_tgt}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126990    event_type=A3    threshold=choice=1
    ${a3_cmd_tgt}  catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_tgt} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=60 nrsrp_nr=30
    ...  nrsrq_nr=30
    Execute Egate Command     ${a3_cmd_tgt}    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

Inter-gNB HO to gNB5 and patial AC
    [Arguments]   ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126990    event_type=A3
    ${a3_cmd}  catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=30
    ...  nrsrq_nr=30 phycell_id=48 nrsrp_nr=25 nrsrq_nr=25
    Execute Egate Command     ${a3_cmd}     Inter-eNB handover from EXT_ENB-2.1 to ENB-5.1 performed
    Execute Egate Command     ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${meas_id_tgt}    get nr meas id for specific type and frequency   ue_id=${ue_id}    carrierfreq=126990    event_type=A3    threshold=choice=1
    ${a3_cmd_tgt}  catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_tgt} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=60 nrsrp_nr=30
    ...  nrsrq_nr=30
    Execute Egate Command     ${a3_cmd_tgt}     Inter-eNB handover from ENB-5.1 to EXT_ENB-2.1 performed

Xn link SETUP and Recovery
    Execute Egate Command    gnb_param id=5 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=5 reset
    Execute Egate Command    gnb_xn_setup_param id=5 reset
    Execute Egate Command    gnb_xn_link_up gnb=5 target=2    GNB-5: XnAP Link with GNB-2 .* is up
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=3 reset
    Execute Egate Command    gnb_xn_setup_param id=3 reset
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2 .* is up
