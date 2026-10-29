*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-shelly.song    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    @{Switch_NRBTS}
...    @{Switch_NRCELL}
...    @{Switch_NRDU}
...    @{DRB}
...    @{CELL11_12_13}
...    @{CELL_NRREL}
...    @{CELL_NRHOIF}
...    @{732_F014_update}
@{732_F014_update}
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-12:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:sMeasConfigSsbRsrp=1
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly

...    NRBTS:actDrbDrx=true
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRBTS/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4


...    NRBTS/NRDRX-1:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-1:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-1:drxInactivityTimer=40ms
...    NRBTS/NRDRX-1:drxLongCycle=80ms
...    NRBTS/NRDRX-1:drxOnDurationTimer=20ms
...    NRBTS/NRDRX-1:drxPriority=32
...    NRBTS/NRDRX-1:drxRetransTimerDl=16slot
...    NRBTS/NRDRX-1:drxRetransTimerUl=16slot

...    NRBTS/NRDRX-4:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-4:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-4:drxInactivityTimer=40ms
...    NRBTS/NRDRX-4:drxLongCycle=40ms
...    NRBTS/NRDRX-4:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-4:drxPriority=10
...    NRBTS/NRDRX-4:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-4:drxRetransTimerUl=0slot

@{Switch_NRBTS}
...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1:drbInactivityTimerSA=7200

...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actRohc=true
...    NRPMRNL-1:miNrRelReportCu=15min

@{Switch_NRCELL}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:n310VoNR=n3
...    NRCELL:t310VoNR=500ms
...    NRCELL:maxGBRTrafficLimit=75


@{Switch_NRDU}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

@{CELL11_12_13}
...    NRCELL-11:actEmergencyCall=true
...    NRCELL-11:emergencyCallLimServ=true
...    NRCELL-11:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-11:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-11:arpPrioEmergencyCall=1
...    NRCELL-11:actCDrxVoNR=true
...    NRCELL-11:actVoNR=true
...    NRCELL-11:n310VoNR=n10
...    NRCELL-11:t310VoNR=100ms
...    NRCELL-11:maxGBRTrafficLimit=75
...    NRCELL-11:actEnhancedVoNR=true
...    NRCELL-11:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-11:actVoipPacketAggr=true
...    NRCELL-11:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-11:actCDrx=true
#...    NRCELL-11:drxProfile1:drxInactivityTimer=40ms
#...    NRCELL-11:drxProfile1:drxLongCycle=80ms
#...    NRCELL-11:drxProfile1:drxOnDurationTimer=20ms
#...    NRCELL-11:drxProfile1:drxRetransTimerDl=16slot
#...    NRCELL-11:drxProfile1:drxRetransTimerUl=16slot
#...    NRCELL-11:drxProfile2:drxInactivityTimer=40ms
#...    NRCELL-11:drxProfile2:drxLongCycle=40ms
#...    NRCELL-11:drxProfile2:drxOnDurationTimer=10ms
#...    NRCELL-11:drxProfile2:drxRetransTimerDl=0slot
#...    NRCELL-11:drxProfile2:drxRetransTimerUl=0slot


...    NRCELL-11:gapOffset=7
...    NRCELL-11:ifhoSsbSmtcOffset=8
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=45
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:a2MeasRedirectEnabled=rsrq
...    NRCELL-11:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-11:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-11:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480

...    NRCELL-12:actEmergencyCall=true
...    NRCELL-12:emergencyCallLimServ=true
...    NRCELL-12:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-12:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-12:arpPrioEmergencyCall=1
...    NRCELL-12:maxGBRTrafficLimit=75
...    NRCELL-12:actVoNR=true
...    NRCELL-12:actCDrxVoNR=true
...    NRCELL-12:actEnhancedVoNR=true
...    NRCELL-12:actVoipPacketAggr=true
...    NRCELL-12:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-12:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-12:n310VoNR=n10
...    NRCELL-12:t310VoNR=100ms
...    NRCELL-12:actCDrx=true

#...    NRCELL-12:drxProfile1:drxInactivityTimer=40ms
#...    NRCELL-12:drxProfile1:drxLongCycle=80ms
#...    NRCELL-12:drxProfile1:drxOnDurationTimer=20ms
#...    NRCELL-12:drxProfile1:drxRetransTimerDl=16slot
#...    NRCELL-12:drxProfile1:drxRetransTimerUl=16slot
#...    NRCELL-12:drxProfile2:drxInactivityTimer=20ms
#...    NRCELL-12:drxProfile2:drxLongCycle=40ms
#...    NRCELL-12:drxProfile2:drxOnDurationTimer=20ms
#...    NRCELL-12:drxProfile2:drxRetransTimerDl=0slot
#...    NRCELL-12:drxProfile2:drxRetransTimerUl=0slot

...    NRCELL-12:gapOffset=7
...    NRCELL-12:ifhoSsbSmtcOffset=8
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=32
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms80
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=64ms
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=35
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=95
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms64
...    NRCELL-12:a2MeasRedirectEnabled=rsrq
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-12:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=10
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=64ms

...    NRCELL-13:n310VoNR=n3
...    NRCELL-13:t310VoNR=500ms
...    NRCELL-13:maxGBRTrafficLimit=75
...    NRCELL-13:actEnhancedVoNR=true
...    NRCELL-13:actGBRAdmissionControl=EnhancedVoNR

@{DRB}
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:l2OHFactorDl=16
...    NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15

@{CELL_NRREL}
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=12
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=13
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=1
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=13
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

@{CELL_NRHOIF}
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=30 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=6
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=5
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms0
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=30 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=633216
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=5
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=5
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms40

@{PM_COUNTER_CHECK}
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-12:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-12:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-11:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-12:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-12:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SA_DU_ADMISSION_REQ}=1
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SA_DU_ADMISSION_SUCC}=1
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REQ}=3
...    NRCELL-12:${SGNB_SA_DU_NGBR_DRB_REQ}=2
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_SUCC}=3
...    NRCELL-12:${SGNB_SA_DU_NGBR_DRB_SUCC}=2
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REL}=3
...    NRCELL-12:${SGNB_SA_DU_NGBR_DRB_REL}=2
...    NRCELL-11:${REESTAB_ACC_VONR}=1
...    NRCELL-12:${REESTAB_ACC_VONR}=1
...    NRCELL-11:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-12:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-11:${SA_DU_GBR_DRB_REQ}=3
...    NRCELL-12:${SA_DU_GBR_DRB_REQ}=2
...    NRCELL-11:${SA_DU_GBR_DRB_SUCC}=3
...    NRCELL-12:${SA_DU_GBR_DRB_SUCC}=2
...    NRCELL-11:${SA_DU_GBR_DRB_REL}=3
...    NRCELL-12:${SA_DU_GBR_DRB_REL}=2
#...    NRCELL-11:${AVE_AVAIL_SA_5QI1_GBR_RES}>0
#...    NRCELL-12:${AVE_AVAIL_SA_5QI1_GBR_RES}>0
#...    NRCELL-11:${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}>0
#...    NRCELL-12:${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}>0
#...    NRCELL-11:${LOW_PEAK_SA_5QI1_GBR_RES}>0
#...    NRCELL-12:${LOW_PEAK_SA_5QI1_GBR_RES}>0
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    ${NE1CS_ROHC_DRB_CTX_REQ_SENT}=25
...    ${NE1CS_ROHC_DRB_CTX_RESP_RECD}=25


# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
# The number of successful RRC Reestablishment procedures when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
# The number of admission controls triggered in CU by RRC reestablishment procedure
${REESTAB_ADMISSION_CTRL}    M55124C00519
# The number of RRC reconfiguration succeeded in RRC reestablishment procedure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
# The number of radio admission requests for SA user. Updated in the DU when RRC resources are requested
${SGNB_SA_DU_ADMISSION_REQ}    M55139C00001
# The number of admitted radio admission requests for SA user. Updated in the DU when RRC resources are admitted
${SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002
# The number of non-GBR DRB radio admission requests for SA user in DU.
# Updated in DU whenever an admission is requested for a non-GBR DRB due to Initial Context Setup
# or PDU session addition or due to PDU session modification.
${SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003
# The number of non-GBR DRB successful radio admissions for SA user. Updated in DU whenever a request for a non-GBR DRB
# is successfully admitted in Initial Context Setup or PDU session addition or due to PDU session modification.
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
#The number of non-GBR DRB radio admission releases for SA user in DU.
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012
#The number of successful RRC Reestablishment procedures for VONR for all reestablishment causes
${REESTAB_ACC_VONR}    M55124C00518
#The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${RRC_REESTAB_ATT_VONR}    M55124C00520
#The number of GBR DRB radio admission requests in DU for SA user.
${SA_DU_GBR_DRB_REQ}    M55139C00501
#The number of GBR DRB successful radio admissions for SA user.
${SA_DU_GBR_DRB_SUCC}    M55139C00502
#The number of GBR DRB radio admission releases for SA user in DU.
${SA_DU_GBR_DRB_REL}    M55139C00509
#Number of RoHC contexts configured for the DRBs for which RoHC compression is requested by gNB-CU-CP from gNB-CU-UP.
${NE1CS_ROHC_DRB_CTX_REQ_SENT}    M55135C01001
#Number of RoHC contexts configured for the DRBs for which RoHC compression is requested by gNB-CU-CP from gNB-CU-UP.
${NE1CS_ROHC_DRB_CTX_RESP_RECD}    M55135C01002
#The average number of estimated available radio resources for 5QI-1 users. The counter counts resources per UE
#and is based defined cell level maximum GBR capacity and used capacity per UE
${AVE_AVAIL_SA_5QI1_GBR_RES}    M55139C00510
#Denominator for AVE_AVAIL_SA_5QI1_GBR_RES
${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}    M55139C00511
#Lowest peak number of radio resources available for 5QI-1 GBR users.
${LOW_PEAK_SA_5QI1_GBR_RES}    M55139C00512



&{CELLS_CARRIER_FREQ}
...     11=424090
...     12=126750
...     13=427970

${SA_UE_ID}    82

*** Test Cases ***
5GC000732-ET-F014_RRC_loop_reestablish_succ_with_6112_with_ROHC_from_1167_meas_DRX_enabled_A2_meas_to_new_1167_meas_DRX_enabled
    [Documentation]    F014 combine with F098:RRC_reestablish_from_VONR_call_to_EC_call
    ...    Reestablish from VoNR, meas, DRX, CA(FFF) to new cell(FFF) with DRX and no meas with VoNR
    ...    preconditions:
    ...        1. ROHC(774) is opened and VoNR(6112)
    ...        2. configure CA F+F+F(cell 11+cell 12+ cell 13) for 1167 covBasedA1 with DRX,measconfig VoNR
    ...        3. configure CA F+F+F(cell 12+cell 11+ cell 13) for new cell with new DRX,measconfig with VONR
    ...    Case steps:
    ...        1.Setup CA(FDD+FDD+FDD)(cell 11+ cell 12+cell 13) and CA(FDD+FDD+FDD)(cell 12+ cell 11+cell 13) successfully
    ...        2.Trigger VoNR call with cell 11
    ...        3.Trgger RRC reestablish from cell 11 to cell 12, RRC reestablish successfully
    ...        4.Trigger RRC reestablish from cell 12 to cell 11,RRC reestablish successfully
    ...        5.check VoNR successfully , drx setup successfully and meas config not missing in RRCReestablish procedure
    ...        6.Check counters:
    ...          RRC_REESTAB_OTHER_FAILURE_DU: If reestablishmentCause IE is otherFailure (Counter ID: M55127C00503)
    ...          RRC_REESTAB_OTHER_FAILURE: If reestablishmentCause IE is otherFailure (Counter ID: M55124C00505)
    ...          REESTAB_ACC_OTHER_FAIL_DU: If reestablishmentCause IE is otherFailure (Counter ID: M55127C00512)
    ...          REESTAB_RRCRECONFIG_SUCC: Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...          (Counter ID: M55124C00516)
    ...          REESTAB_ACC_VONR: (Counter ID: M55124C00518)
    ...          RRC_REESTAB_ATT_VONR: (Counter ID: M55124C00520)
    ...          REESTAB_ADMISSION_CRTL: (Counter ID: M55124C00519)
    ...          NE1CS_ROHC_DRB_CTX_REQ_SENT:M55135C01001
    ...          NE1CS_ROHC_DRB_CTX_RESP_RECD:M55135C01002
    ...          EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ: M55139C00001
    ...          EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC:M55139C00002
    ...          EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ:M55139C00003
    ...          EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC:M55139C00004
    ...          EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL:M55139C00012
    ...          EPmCounterId_5G_SA_DU_GBR_DRB_REQ:M55139C00501
    ...          EPmCounterId_5G_SA_DU_GBR_DRB_SUCC:M55139C00502
    [Tags]    QC_46921
    Clear Counter Files    wait=${False}
    Start VoNR Call To Cell_11 and Start Traffic
    Check Scell_12 and Scell_13 Addition and Check Traffic
    Reestablish from Cell_11 to Cell_12 and Check Traffic
    Check Scell_11 and Scell_13 Addition and Check Traffic
    Add ARP and Setup Emergency Call
    Reestablish from Cell_12 to Cell_11 and Check Traffic
    Check Scell_12 and Scell_13 Addition After RRCRES and Check Traffic
    Stop Traffic and UE Detach
    Check Counters    ${PM_COUNTER_CHECK}


*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    ue_param id=${SA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full_enable_ROHC_powersaving}

Start VoNR Call To Cell_11 and Start Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu_id}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...                      pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ...                      pass_regexp=QoS Routing Table
    Send Traffic    ${ue_id}    ${pdu_id}
    Check Traffic    ue_id=${ue_id}    cell_num=1    min_dl_tput=4    min_ul_tput=4

Send Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=5 trf_id=1
    ...                      pass_regexp=UE ${ue_id}: UDP DL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=5 trf_id=1
    ...                      pass_regexp=UE ${ue_id}: UDP UL TRF

Check Traffic
    [Arguments]    ${ue_id}     ${cell_num}    ${min_dl_tput}    ${min_ul_tput}
    Sleep    15s    sleep for Tput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 >= 0
    END
    Should Be True    ${dl_throuput}/1000 >= ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 >= ${min_ul_tput}

Add Scell_12 and Scell_13 and Check Traffic
    [Arguments]    ${ue_id}    ${pcell_id}
    Start RRC Log    scell_addition
    Trigger Scell Addition by A1 Event    ue_id=${ue_id}    pcell_id=${pcell_id}    scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62
    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=4    min_ul_tput=4

Trigger Scell Addition by A1 Event
    [Arguments]    ${ue_id}    ${pcell_id}    ${scell_num}
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    pass_regexp=sCellIndex 2
    Check Scell Number    ${ue_id}    expected_scell_num=${scell_num}

Check Scell Number
    [Arguments]    ${ue_id}    ${expected_scell_num}
    ${meas_obj}     Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length      ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers     ${expected_scell_num}    ${real_scell_num}

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${ue_id}    ${tgt_cell_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE${ue_id}: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Check Scell_12 and Scell_13 Addition and Check Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pcell_id}=11
    Add Scell_12 and Scell_13 and Check Traffic    ${ue_id}    ${pcell_id}
#    Check Wireshark Log    ${CURDIR}/a2a_F014/a2a_vonr_call.ini    wait_string=UEContextModificationResponse::28

Reestablish from Cell_11 to Cell_12 and Check Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Start To Capture Wireshark Log    rrcres_1
    Trigger UE RRC Reestablish to Cell    ${ue_id}    tgt_cell_id=12
    Check Traffic    ${ue_id}    cell_num=1    min_dl_tput=4    min_ul_tput=4

Check Scell_11 and Scell_13 Addition and Check Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pcell_id}=12
    Add Scell_11 and Scell_13 and Check Traffic    ${ue_id}    ${pcell_id}
#    Check Wireshark Log    ${CURDIR}/a2a_F014/a2a_rrcres_1.ini    name=rrcres_1    wait_string=UEContextModificationResponse::18

Add Scell_11 and Scell_13 and Check Traffic
    [Arguments]    ${ue_id}    ${pcell_id}
    Start RRC Log    scell_addition
    Trigger Scell Addition by A1 Event    ue_id=${ue_id}    pcell_id=${pcell_id}    scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62
    Check Traffic    ue_id=${ue_id}    cell_num=3    min_dl_tput=4    min_ul_tput=4

Add ARP and Setup Emergency Call
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Start To Capture Wireshark Log    ec_call
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Execute Egate Command    qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=2 request_type=initial-emergency-request
    ...    pass_regexp=QoS Routing Table.*Protocol:TCP QFI:1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf
    ...    pass_regexp=QoS Routing Table.*Protocol:UDP QFI:2.*Protocol:TCP QFI:1
#    Check Wireshark Log    ${CURDIR}/a2a_F014/a2a_ec_call.ini    name=ec_call    wait_string=UEContextModificationResponse::8

Reestablish from Cell_12 to Cell_11 and Check Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Start To Capture Wireshark Log    rrcres_2
    Trigger UE RRC Reestablish to Cell    ${ue_id}    tgt_cell_id=11
    Check Traffic    ${ue_id}    cell_num=1    min_dl_tput=4    min_ul_tput=4

Check Scell_12 and Scell_13 Addition After RRCRES and Check Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pcell_id}=11
    Add Scell_12 and Scell_13 and Check Traffic    ${ue_id}    ${pcell_id}
#    Check Wireshark Log    ${CURDIR}/a2a_F014/a2a_rrcres_2.ini    name=rrcres_2    wait_string=UEContextModificationResponse::18

Stop Traffic and UE Detach
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached
#    Check Wireshark Log    ${CURDIR}/a2a_F014/a2a_rrcres_2.ini    name=rrcres_2    wait_string=UEContextReleaseComplete::4
