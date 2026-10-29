*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD
...               team-DevHZ5_SG1    owner-pei.han    release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB_CONFIG}    fdd_sansa_cmwv/6cells
@{PARAMS_IN_VENDOR}
...    guaranteedResourceRatioPerCell=5
...    maxNumPucchF1SRPerSlotL1Pool=1
@{PARAMS_IN_SWCONFIG}
...    @{rdSrLoadThresholdDownHysteresis}
...    @{rdL1PoolSrLoadAdjustFactor}
...    @{rdSrReconfigurationsInterval}
@{rdSrLoadThresholdDownHysteresis}
...    0x59015E=0
@{rdL1PoolSrLoadAdjustFactor}
...    0x590161=18
@{rdSrReconfigurationsInterval}
...    0x59015C=5000
@{PARAMS_IN_SCF}
...    @{5GC002426}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{VONR}
...    @{Emergency}
...    @{5GC000732}
...    @{Others}
...    @{5GC002426-C}
...    @{5GC002271}
@{5GC002426}
...    NRBTS:actConnRrcPooling=true    NRBTS:actScheUePooling=true
...    EQM-1/APEQM-1/CABINET-1/BBMOD-1:fddNrCellConfigTradeoff=max cells
...    NRCELL:pucchModeSelect=longPucch
@{Others}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
@{5GC002426-C}
...    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL:maxNumOfCaUsersNRCell=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfUsersPerCell=20
...    NRCELL:maxNumOfNrDcSnUsers=20
@{Emergency}
...    NRCELL:actEmergencyCall=false
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=12
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
@{NRREL}
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=427970
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-2/NRREL-10:gNbId=2
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=3
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:gNbId=2
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:lcrId=4
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:gNbId=2
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=1
...    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=126290
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-10:sCellOperationalMode=dlOnly
@{Mobillity}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRPMRNL-1:miNrMobilityReport=5min
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=8
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=126290
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=36
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=1
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489|mncLength=3
...    delete:NRCELL-1/NRREL-3:sCellAdditionMethod
@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=${EMPTY}
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS/NRDRB-15:discardTimer=1500ms
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
@{5GC000732}
...    NRBTS:rrcReestabTypeSA=sameGNB
@{5GC002271}
...    NRCELL-1:srPeriodicity=slots20
...    NRCELL-2:srPeriodicity=slots20
...    NRCELL-5:srPeriodicity=slots40
...    NRCELL-6:srPeriodicity=slots40
...    NRCELL-5:actAdaptiveSr=true
...    NRCELL-6:actAdaptiveSr=true
...    NRCELL-5:adaptiveSrBlockingMinimization=0
...    NRCELL-6:adaptiveSrBlockingMinimization=0
...    NRCELL-5:adaptiveSrLoadThresholdDown=40
...    NRCELL-6:adaptiveSrLoadThresholdDown=40
...    NRCELL-5:adaptiveSrLoadThresholdUp=60
...    NRCELL-6:adaptiveSrLoadThresholdUp=60
...    NRCELL-5:vonrReservation=0
...    NRCELL-6:vonrReservation=0
...    NRCELL-5:preferredVoNrSrPeriod=slots20
...    NRCELL-6:preferredVoNrSrPeriod=slots20
...    NRCELL-5:srPeriodicityMin=slots5
...    NRCELL-6:srPeriodicityMin=slots5
...    NRCELL-5:lowLatencyReservation=0
...    NRCELL-6:lowLatencyReservation=0
@{OnlineParam_Cell_Locked}
...    NRCELL-5:administrativeState=Locked    NRCELL-6:administrativeState=Locked
@{OnlineParam_Cell_Unlocked}
...    NRCELL-5:administrativeState=Unlocked    NRCELL-6:administrativeState=Unlocked
${wait_for_SIB}    15s

*** Test Cases ***
5GC002426-L_ET_01_01_Upgrade Cells SR pool to pool N directly if L1Pools SR load is high
    [Documentation]
    ...    This case is to verify:
    ...    When UE attach to different cells,
    ...    the different L1Pools SR load to trigger the different srPeriodicity reallocation for UEs.
    [Tags]
    OnlineParamChange
    Set UE Parameters Before Attach
    NSA UE Attach and establish EN-DC    ue_id_start=31    ue_id_end=32    target_cell=1
    NSA UE Attach and establish EN-DC_rrc_should_contain    ue_id=32    target_cell=5
    ...    rrc_contain_1=sl5    rrc_contain_2=sl10
    NSA UE Release EN-DC    ue_id=32
    NSA UE Attach and establish EN-DC_rrc_should_not_contain    ue_id=33    target_cell=6
    ...    rrc_contain=sl5    rrc_not_contain=sl10
    NSA UE Attach and establish EN-DC    ue_id_start=34    ue_id_end=35   target_cell=1
    NSA UE Attach and establish EN-DC_rrc_should_not_contain    ue_id=35    target_cell=5
    ...    rrc_contain=sl40    rrc_not_contain=sl10
    NSA UE Release EN-DC    ue_id=35
    NSA UE Attach and establish EN-DC_rrc_should_contain    ue_id=36   target_cell=6
    ...    rrc_contain_1=sl10    rrc_contain_2=sl40

5GC002426-L_ET_02_01_Select SR Pool N for new UE regardless of main pool if L1Pools SR load is high
    [Documentation]
    ...    This case is to verify:
    ...    When L1Pools SR load is over SrLoadThresholdUp, UEs attach to different cells,
    ...    the different srPeriodicity reallocation for UEs.
    [Tags]
    OnlineParamChange
    Set UE Parameters Before Attach
    NSA UE Attach and establish EN-DC    ue_id_start=31    ue_id_end=39    target_cell=1
    NSA UE Attach and establish EN-DC_rrc_should_not_contain    ue_id=39    target_cell=5
    ...    rrc_contain=sl40    rrc_not_contain=sl5
    NSA UE Release EN-DC    ue_id=39
    NSA UE Attach and establish EN-DC_rrc_should_not_contain    ue_id=40    target_cell=6
    ...    rrc_contain=sl40    rrc_not_contain=sl20

5GC002426-L_ET_04_01_Select Pool N for UE when VONR call release if L1Pools SR load is high
    [Documentation]
    ...    This case is to verify:
    ...    srPeriodicity reallocation for VONR UE when L1Pools SR load is high.
    [Tags]
    OnlineParamChange
    Set UE Parameters Before Attach    target_cell=5
    SA Normal UE Register and PDU Session Setup
    NSA UE Attach and establish EN-DC    ue_id_start=31    ue_id_end=35    target_cell=1
    UE PDU Session Modify to Add
    UE PDU Session Modify to Del

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

Modify Cfg
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_1}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890
    ...    earfcn=2000:20000 mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_1}
    ${Update_Cfg_2}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127
    ...    x2u=10.0.1.137 type=simulated x2_peers=none
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_3}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_3}
    ${Update_Cfg_4}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.124 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2=10.0.1.125:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=135580:126380 gscn=1579
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=6
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosflow id=5 5qi=8
    Update Cfg    set_qosflow id=6 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-30 amf=1
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    ${Update_Cfg_7}    catenate    SEPARATOR=
    ...    ue_param id=1-30 nr_usage_setting=voice_centric ue_nr_capabilities=E9A09000575F5A13160003C320016093170019C3D0
    ...    9009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581
    ...    C0E1E0B8002F800E000BE00088000E0741B13703582308682041D2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F0
    ...    9FD817C007F605F00044000702A0D88DAC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FE00000
    ...    03F800000022000381506C41D608C21A0810788240656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F02AAAA9FC0AAA
    ...    AA110001C00650388C080000240A838280388C000004240AC3C28000C2300008240AC1C28080006020EB0F0A00030500004010750B882
    ...    001C41000E230000050907007011A014400080821A010C0D0276C73E1C29D3B639F0E1449DB1CF870226C73E1C2893B639F0E2400D8E7
    ...    C37A09801E00140E0A00E0601280380030120020301F04801000000008000010040000000200000401000004008000030040000200200
    ...    001401000802008020000180100000E008004000000100001000800009004002018060080000A004000058020010240900400006019CA
    ...    9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA4
    ...    8080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292018A5
    ...    5574AAAA9545D2A8AA0B1540E2A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05
    ...    000500080F00C1010020000403006080801004020180000040600208080100402004000804030060100C01804030061AA1F0001020304
    ...    06070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F41410781C060006010
    Update Cfg    ${Update_Cfg_7}
    FOR    ${SA_id}    IN RANGE    1    31
        Update Cfg    set_pdu_gateway id=${SA_id} ue_nat_ip=72.23.0.${SA_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    FOR    ${NSA_id}    IN RANGE    31    61
        Update Cfg    set_bearer id=3 ue=${NSA_id} qci=8 pdn=1 default=off
    END
    ${Update_Cfg_8}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 xn=10.0.1.2:38422
    ...    gnb_id=0x2:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${Update_Cfg_8}

Set UE Parameters Before Attach
    [Arguments]    ${ue_id}=1    ${target_cell}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}

NSA UE establish EN-DC
    [Arguments]    ${ue_id}=31   ${target_cell}=1
    Start RRC Log     NSA_UE_establish_EN-DC_${ue_id}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA
    Get RRC Log

NSA UE Attach and establish EN-DC
    [Arguments]    ${ue_id_start}=31    ${ue_id_end}=32    ${target_cell}=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end}
        Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
        NSA UE establish EN-DC    ue_id=${ue_id}    target_cell=${target_cell}
    END

NSA UE Attach and establish EN-DC_rrc_should_contain
    [Arguments]    ${ue_id}=31    ${target_cell}=1    ${rrc_contain_1}=sl5    ${rrc_contain_2}=sl40
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Start RRC Log     NSA_UE_establish_EN-DC_${ue_id}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA    sleep_time=5
    rrc should contain    periodicityAndOffset ${rrc_contain_1}
    rrc should contain    periodicityAndOffset ${rrc_contain_2}

NSA UE Attach and establish EN-DC_rrc_should_not_contain
    [Arguments]    ${ue_id}=31    ${target_cell}=1    ${rrc_contain}=sl5    ${rrc_not_contain}=sl40
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Start RRC Log     NSA_UE_establish_EN-DC_${ue_id}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA    sleep_time=5
    rrc should contain    periodicityAndOffset ${rrc_contain}
    rrc should not contain    periodicityAndOffset ${rrc_not_contain}

NSA UE Release EN-DC
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_dc_release_enb ue=${ue_id} by=enb cause=RN_mCG_Mobility
    ...    Bearer-type change from SCG-split to MCG is successful

SA Normal UE Register To GNB
    [Arguments]    ${ue_id_start}=1    ${ue_id_end}=2
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end}
        Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state
    END

SA Normal UE PDU Session Setup
    [Arguments]    ${pdu}=1    ${fiveQi}=5    ${ue_id_start}=1    ${ue_id_end}=2
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end}
        Start RRC Log    PDU_Session_Setup_${ue_id}
        ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
        ...  pass_regexp=QoS Routing Table    sleep_time=5
        Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
        Get RRC Log
    END

SA Normal UE Register and PDU Session Setup
    [Arguments]    ${ue_id_start}=1    ${ue_id_end}=2
    SA Normal UE Register To GNB    ue_id_start=${ue_id_start}    ue_id_end=${ue_id_end}
    SA Normal UE PDU Session Setup    ue_id_start=${ue_id_start}    ue_id_end=${ue_id_end}

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1
    Start RRC Log    PDU_Session_Modify_to_Add
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
    ...    pass_regexp=QoS Routing Table    sleep_time=5
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 2
    rrc should not contain    periodicityAndOffset sl5
    rrc should not contain    periodicityAndOffset sl40

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1
    Start RRC Log    PDU_Session_Modify_to_Del
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf
    ...    rrcReconfigurationComplete    sleep_time=5
    Should Contain    ${ret1}    Removed FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 2
    rrc should not contain    periodicityAndOffset sl5
    rrc should contain    periodicityAndOffset sl40

OnlineParamChange
    [Arguments]
    Delta Commission Parameters    ${OnlineParam_Cell_Locked}
    Delta Commission Parameters    ${OnlineParam_Cell_Unlocked}
    Cells Should Be Onair    check_sib=${True}
    Sleep    ${wait_for_SIB}
