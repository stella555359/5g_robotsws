*** Settings ***
Documentation
...    author: Zhou Lingyan
...    contact: lingyan.zhou@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-cathy.mao    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F


@{PARAMS_IN_SCF}
...    @{DRB}
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    MRBTS-1/NRBTS-1/NRCELL-1:actVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-1:arpPrioEmergencyCall=1
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=true
...    MRBTS-1/NRBTS-1/NRCELL-1:maxGBRTrafficLimit=75
...    MRBTS-1/NRBTS-1/NRCELL-1:t310VoNR=500ms
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrxVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    MRBTS-1/NRBTS-1/NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    MRBTS-1/NRBTS-1/NRCELL-1:actEmergencyCall=true
...    MRBTS-1/NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    MRBTS-1/NRBTS-1/NRDRX-1:drxInactivityTimer=40ms
...    MRBTS-1/NRBTS-1/NRDRX-1:drxOnDurationTimer=10ms
...    MRBTS-1/NRBTS-1/NRDRX-1:drxRetransTimerDl=16slot
...    MRBTS-1/NRBTS-1/NRDRX-1:drxRetransTimerUl=16slot
...    MRBTS-1/NRBTS-1/NRDRX-1:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRDRX-4:drxInactivityTimer=4ms
...    MRBTS-1/NRBTS-1/NRDRX-4:drxOnDurationTimer=4ms
...    MRBTS-1/NRBTS-1/NRDRX-4:drxRetransTimerDl=0slot
...    MRBTS-1/NRBTS-1/NRDRX-4:drxRetransTimerUl=0slot
...    MRBTS-1/NRBTS-1/NRDRX-4:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallLimServ=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    MRBTS-1/NRBTS-1/NRCELL-1:n310VoNR=n3
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=13
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12:actCDrx=false
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN

...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS-1:rrcReestabTypeSA=sameGNB

...    NRBTS-1/NRDRB_PDCP:maxCidAllowed=4
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms0
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    MRBTS-1/NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=8
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actLocationReportingSA=true

...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250


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
...    NRBTS-1/NRDRB-15:durationThresDiscardDl=40
...    NRBTS-1/NRDRB-15:durationThresDiscardUl=20
...    NRBTS-1/NRDRB-15:volThresDiscardDl=8000
...    NRBTS-1/NRDRB-15:volThresDiscardUl=800
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
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
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


@{Delta_Scf_F017}
...    MRBTS-1/NRBTS-1/NRDRX-1:drxInactivityTimer=80ms
...    MRBTS-1/NRBTS-1/NRDRX-1:drxOnDurationTimer=10ms
...    MRBTS-1/NRBTS-1/NRDRX-1:drxRetransTimerDl=16slot
...    MRBTS-1/NRBTS-1/NRDRX-1:drxRetransTimerUl=16slot
...    MRBTS-1/NRBTS-1/NRDRX-1:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-12:actVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-12:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    MRBTS-1/NRBTS-1/NRCELL-12:actEmergencyCall=true
...    MRBTS-1/NRBTS-1/NRCELL-12:arpPrioEmergencyCall=1
...    MRBTS-1/NRBTS-1/NRCELL-12:emergencyCallLimServ=true
...    MRBTS-1/NRBTS-1/NRDRX-4:drxInactivityTimer=4ms
...    MRBTS-1/NRBTS-1/NRDRX-4:drxOnDurationTimer=4ms
...    MRBTS-1/NRBTS-1/NRDRX-4:drxRetransTimerDl=0slot
...    MRBTS-1/NRBTS-1/NRDRX-4:drxRetransTimerUl=0slot
...    MRBTS-1/NRBTS-1/NRDRX-4:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-12:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    MRBTS-1/NRBTS-1/NRCELL-12:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    MRBTS-1/NRBTS-1/NRCELL-12:actGBRAdmissionControl=EnhancedVoNR
...    MRBTS-1/NRBTS-1/NRCELL-12:actCDrx=true
...    MRBTS-1/NRBTS-1/NRCELL-12:n310VoNR=n3
...    MRBTS-1/NRBTS-1/NRCELL-12:actCDrxVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-12:maxGBRTrafficLimit=75
...    MRBTS-1/NRBTS-1/NRCELL-12:actEnhancedVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-12:t310VoNR=500ms



@{PM_COUNTER_CHECK}
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-12:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-12:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-12:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-12:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-1:${REESTAB_ACC_VONR}=1
...    NRCELL-12:${REESTAB_ACC_VONR}=1
...    NRCELL-1:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-12:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_SUCC}=2
...    NRCELL-12:${SGNB_SA_DU_NGBR_DRB_SUCC}=1
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REL}=2
...    NRCELL-12:${SGNB_SA_DU_NGBR_DRB_REL}=1
...    NRCELL-1:${NNGCC_LOC_REPORT_SENT}=2
...    NRCELL-12:${NNGCC_LOC_REPORT_SENT}=1
...    NRCELL-1:${F1_UE_CTXT_MOD_REQ_SENT}=19
...    NRCELL-12:${F1_UE_CTXT_MOD_REQ_SENT}=6
...    NRCELL-1:${F1_UE_CTXT_MOD_RESP_RECEIVED}=19
...    NRCELL-12:${F1_UE_CTXT_MOD_RESP_RECEIVED}=6
...    NRCELL-1:${NF1CC_DL_RRC_MSG_TRANSFER}=14
...    NRCELL-12:${NF1CC_DL_RRC_MSG_TRANSFER}=3
...    NRCELL-1:${NF1CC_UL_RRC_MSG_TRANSFER}=18
...    NRCELL-12:${NF1CC_UL_RRC_MSG_TRANSFER}=3
...    NRCELL-1:${NRRCC_RRC_RECONF_SENT}=7
...    NRCELL-12:${NRRCC_RRC_RECONF_SENT}=2
...    NRCELL-1:${NRRCC_RRC_RECONF_CMP_RECD}=7
...    NRCELL-12:${NRRCC_RRC_RECONF_CMP_RECD}=2
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SA_DU_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SA_DU_ADMISSION_SUCC}=1




&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750


${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
${REESTAB_ADMISSION_CTRL}    M55124C00519
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012
${REESTAB_ACC_VONR}    M55124C00518
${RRC_REESTAB_ATT_VONR}    M55124C00520





${NNGCC_LOC_REPORT_SENT}    M55125C06502

${F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001
${F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002
${NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501
${NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502
${NRRCC_RRC_RECONF_SENT}    M55124C03001
${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002
${SGNB_SA_DU_ADMISSION_REQ}    M55139C00001
${SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002

*** Test Cases ***
L3_Transversal_Robust_Verify_gNB_works_as_expect_after_operations_done
#old name:
#5GC000732-ET-F017_RRC_loop_reestablish_succ_with_784_to_new_Pcell_old_DRX_enabled_A1_configured_new_1167_blind_DRX_enabled_no_meas
    [Documentation]    This case will combine F026(F026_RRC_reestablish_succ_with_770_to_new_cell)
    ...    preconditions:
    ...        1. Emergency call (784) and ,UE locaiton report(770) is opened
    ...        2. Old cell:TDD cell 1 with DRX, MGAP
    ...        2. New cell:Configure CA F+F+F(cell 12+cell 11+cell 13) for 1167 blind with DRX,no meas
    ...         no measconfig
    ...    Case steps:
    ...        1.Trigger Emergency call with cell 1
    ...        3.Trgger RRC reestablish from cell 1 to cell 12, RRC reestablish successfully
    ...        4.check drx setup successfully and meas config
    ...        6.Check counters:
    ...        RRC_REESTAB_OTHER_FAILURE_DU:If reestablishmentCause IE is otherFailure (Counter ID: M55127C00503)
    ...        RRC_REESTAB_OTHER_FAILURE:If reestablishmentCause IE is otherFailure (Counter ID: M55124C00505)
    ...        REESTAB_ACC_OTHER_FAIL_DU:If reestablishmentCause IE is otherFailure (Counter ID: M55127C00512)
    ...        REESTAB_ACC_OTHER_FAIL:If reestablishmentCause IE is otherFailure (Counter ID: M55124C00512)
    ...        REESTAB_RRCRECONFIG_SUCC:Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...        (Counter ID: M55124C00516)
    ...        REESTAB_ACC_VONR: (Counter ID: M55124C00518)
    ...        RRC_REESTAB_ATT_VONR: (Counter ID: M55124C00520)
    ...        REESTAB_ADMISSION_CRTL: (Counter ID: M55124C00519)
    ...        EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT: M55113C00001
    ...        EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED: M55113C00002
    ...        EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER: M55113C00501
    ...        EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER: M55113C00502
    ...        EPmCounterId_5G_NRRCC_RRC_RECONF_SENT: M55124C03001
    ...        EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD: M55124C03002
    ...        EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ: M55139C00001
    ...        EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC:M55139C00002
    ...        EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ:M55139C00003
    ...        EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC:M55139C00004
    ...        EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL:M55139C00012
    ...        The counter is updated when the NGAP: LOCATION REPORT message is sent to AMF: M55125C06502
    [Tags]    5GC000732    F017    F026    QC_55665
    Before_ue_attach_F017
    UE Attach and Emergency Call
    Verify SA DL and UL Traffic
    Change Serving Cell
    Add Measurement Gap By A2    pcell_id=1
    Reestablish from Cell_1 to Cell_12 and Check Traffic
    Reestablish from Cell_12 to Cell_1 and Check Traffic
    Cancel Location Report
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}/a2a_F017/a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_COUNTER_CHECK}


*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3

Before_ue_attach_F017
    Delta Commission Parameters     ${Delta_Scf_F017}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=1
    Clear Counter Files
    Start RRC Log    F017

Change Serving Cell
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_send_location_reporting_control ue=${ue_id} event_type=change-of-serving-cell
    ...                      pass_regexp=Received Location Report

Cancel Location Report
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_send_location_reporting_control ue=${ue_id} event_type=cancel-location-reporting-for-the-ue

Add Measurement Gap By A2
    [Arguments]    ${pcell_id}    ${ue_id}=81
    Start RRC Log    scell_covA1_addition
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=rrcReconfigurationComplete


UE Attach and Emergency Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Execute Egate Command    qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id} request_type=initial-emergency-request
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=3 by=amf
    ...                      pass_regexp=Added QosFlow with QFI:2 fiveQI:1
    Execute Egate Command    qosflow_disp
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    qosflow_modify qos_flow=3 priority=15
    Start Traffic    ${ue_id}    ${pdu_gw_id}

Start Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=50 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>45

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}    ${ue_id}=81
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE81: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Reestablish from Cell_1 to Cell_12 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=12
    Verify SA DL and UL Traffic

Reestablish from Cell_12 to Cell_1 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=1
    Verify SA DL and UL Traffic
