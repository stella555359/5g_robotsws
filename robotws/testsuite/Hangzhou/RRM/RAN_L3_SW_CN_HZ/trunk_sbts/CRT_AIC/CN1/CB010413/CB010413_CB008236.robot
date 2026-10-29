*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT    vDUCNF00
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    owner-jianfen.shen    release-5G24R3    team-DevHZ5_SG02

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
@{PARAMS_IN_SCF_CU}
...    @{CB006112_CU}
...    @{PARAMS_FOR_5QI6_CU}
...    @{PARAMS_FOR_5QI5_CU}
...    @{PARAMS_FOR_5QI1_CU}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_HO_CU}
...    @{CA_COMMON}

@{PARAMS_IN_SCF_DU1}
...    @{CB008236_DU}
...    @{CB006112_DU}
...    @{5GC000545_DU}
...    @{PARAMS_FOR_5QI6_DU}
...    @{PARAMS_FOR_5QI5_DU}
...    @{PARAMS_FOR_5QI1_DU}
...    @{PARAMS_FOR_HO_DU}
...    @{CA_COMMON}

@{CA_COMMON}
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:actConnectedModeMobilityCA=true


@{CB008236_DU}
...    NRCELL-3:actUlSlotAgg=Enabled_VoNr
...    NRCELL-3:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-3:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-3:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-3:maxHarqBundlesUlSlotAgg=10
...    NRCELL-3:minTbsUlSlotAgg=384
...    NRCELL-4:actUlSlotAgg=Disabled
...    NRCELL-4:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL-4:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL-4:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL-4:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL-4:maxHarqBundlesUlSlotAgg=10
...    NRCELL-4:minTbsUlSlotAgg=384

@{CB006112_CU}
...    NRDRX-5:drxInactivityTimer=6ms
...    NRDRX-5:drxLongCycle=40ms
...    NRDRX-5:drxOnDurationTimer=6ms
...    NRDRX-5:drxRetransTimerDl=0slot
...    NRDRX-5:drxRetransTimerUl=0slot
...    NRCELL-3:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-5
...    NRCELL-4:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-5

...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3:actCDrx=true
...    NRCELL-3:actVoNR=true

...    NRCELL-4:actEnhancedVoNR=true
...    NRCELL-4:actCDrxVoNR=true
...    NRCELL-4:actCDrx=true
...    NRCELL-4:actVoNR=true


@{CB006112_DU}
...    NRCELL-3:actEnhancedVoNR=true
...    NRCELL-3:actCDrxVoNR=true
...    NRCELL-3:actCDrx=true
...    NRCELL-3:actVoNR=true
...    NRCELL-3:srPeriodicity=slots40
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-3:actAdaptVoipTbs=true
...    NRCELL-3:actVoipPacketAggr=true
...    NRCELL-4:actEnhancedVoNR=true
...    NRCELL-4:actCDrxVoNR=true
...    NRCELL-4:actCDrx=true
...    NRCELL-4:actVoNR=true
...    NRCELL-4:srPeriodicity=slots40
...    NRCELL-4:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-4:actAdaptVoipTbs=true
...    NRCELL-4:actVoipPacketAggr=true

...    NRDRX-4:drxLongCycle=40ms
...    NRDRX-4:drxOnDurationTimer=10ms
...    NRDRX-4:drxInactivityTimer=80ms
...    NRDRX-5:drxInactivityTimer=6ms
...    NRDRX-5:drxLongCycle=40ms
...    NRDRX-5:drxOnDurationTimer=6ms
...    NRDRX-5:drxRetransTimerDl=0slot
...    NRDRX-5:drxRetransTimerUl=0slot
...    NRCELL-3:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-5
...    NRCELL-4:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-5

@{5GC000545_DU}
...    NRCELL-3:actUlDftSOfdm=true
...    NRBTS:actTdraFallback=false
...    NRCELL-3:pucchModeSelect=longPucch
...    NRCELL-3:puschMappingType=TypeB
...    NRCELL-3:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-3:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180
...    NRCELL-4:actUlDftSOfdm=true
...    NRCELL-4:pucchModeSelect=longPucch
...    NRCELL-4:puschMappingType=TypeB
...    NRCELL-4:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL-4:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180

@{PARAMS_FOR_5QI6_CU}
...    NRBTS/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS/NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-2:xxFlowControlProfForCuIdx=1

@{PARAMS_FOR_5QI6_DU}
...    NRBTS/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS/NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=1
...    NRBTS/NRDRB_MAC-2:schedulPrio=12
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:dlTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-2:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-2:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-2:ulTProhib=ms15

@{PARAMS_FOR_5QI5_CU}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB-10:discardTimerUl=infinity

@{PARAMS_FOR_5QI5_DU}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB-10:rlcPduDelayThCa=30
...    NRBTS/NRDRB-10:discardTimerUl=infinity
...    NRBTS/NRDRB-10:schedulWeight=1
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4
...    NRBTS/NRDRB_MAC-3:schedulBSD=50ms

@{PARAMS_FOR_5QI1_CU}
...    NRCELL-3:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20

@{PARAMS_FOR_5QI1_DU}
...    NRCELL-3:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_MAC-4:schedulBSD=50ms
...    NRBTS/NRDRB_RLC_AM-1:dlTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-1:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-1:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-1:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-1:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20

@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0

@{PARAMS_FOR_HO_CU}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-3:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-3:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:absThreshSsbRsrpConsolidation=10
...    NRCELL-3:absThreshSsbRsrqConsolidation=10
...    NRCELL-3:sMeasConfigSsbRsrp=10
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:lcrId=4
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:lcrId=3
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-4:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-4:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-4:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-4:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-4:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-4:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-4:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-4:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-4:a2MeashoEnabled=rsrp
...    NRCELL-4:a1MeashoEnabled=rsrp
...    NRCELL-4:a3MeasEnabled=rsrp
...    NRCELL-4:a1MeashoEnabledSA=rsrp
...    NRCELL-4:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-4:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-4:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-4:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-4:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-4:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-4:a2MeashoEnabledSA=rsrp
...    NRCELL-4:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-4:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-4:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=34
...    NRCELL-4:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-4:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-4:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-4:absThreshSsbRsrpConsolidation=10
...    NRCELL-4:absThreshSsbRsrqConsolidation=10
...    NRCELL-4:sMeasConfigSsbRsrp=10


@{PARAMS_FOR_HO_DU}
...    NRCELL-3/NRREL-1
...    NRCELL-4/NRREL-1
...    NRCELL-3:maxNumPdschAllocationPerSlot=4
...    NRCELL-3:maxNumPuschAllocationPerSlot=4
...    NRCELL-4:maxNumPdschAllocationPerSlot=4
...    NRCELL-4:maxNumPuschAllocationPerSlot=4

###N5_N78_N66_N41###
###enabled ue support dynamic betaoffsets and non-SharedSpectrumChAccess-r16###
${SA_Capa_Support_SAG}    SEPARATOR=
...    E9A09000575F5A13560003C428005801400000806024C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E7C471E819F604F8
...    C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001
...    FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D809AC1184341020F1068
...    032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C00F78789A001C4100000216020541E140007010000008581587808001C41000
...    006160561E14000710400000858158789A001C04000002160562E0200071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800701000
...    38080000082C0AC5C28000E20800701000001058158B850001C41000E208000020B02B17134003882001C04000004160562E1400070100038080000082C0AC5C4D000E0200070
...    A0000020581587808001C04000006160401C004805101360208BA005D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08
...    902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F417001E00140E0
...    A00E0601280380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008004000000100001
...    000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B
...    29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AA
...    AA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50B00BC04A8140A05028140A05028140A05028140A05028140A000C10100C0180400801080801004020180308
...    04008010100C018040300608080600C02018030804008010100C018040080110080600C02018030080600C10100200804008021AA1F000102030406070A0B0C0D101112131418
...    191B1C1D1F2125262728292A2D2F414182D

@{TP_activate_check}
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    criticalExtensions rrcReconfigurationComplete

@{TP_and_SAg_activate_check_after_add_5QI1}
...    Adding QosFlow with QFI:3 5QI:1
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    drx-Config setup
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}

@{semiStatic_BetaOffsets_values}
...    betaOffsetACK-Index1 11
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 13
...    betaOffsetCSI-Part2-Index2 13

@{moderate_BetaOffsets_values}
...    betaOffsetACK-Index1 10
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 15
...    betaOffsetCSI-Part2-Index2 12

@{optimistic_BetaOffsets_values}
...    betaOffsetACK-Index1 13
...    betaOffsetACK-Index2 12
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 12
...    betaOffsetCSI-Part2-Index2 13

@{default_BetaOffsets_values}
...    betaOffsetACK-Index1 11
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6
...    betaOffsetCSI-Part1-Index1 13
...    betaOffsetCSI-Part1-Index2 13
...    betaOffsetCSI-Part2-Index1 13
...    betaOffsetCSI-Part2-Index2 13

@{HO_check_disabled_8236}
...    criticalExtensions rrcReconfiguration
...    eventId eventA3
...    transformPrecoder disabled
...    betaOffsets semiStatic
...    @{semiStatic_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 release : NULL
...    Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.4 performed
...    drx-Config setup
...    transformPrecoder enabled
...    criticalExtensions rrcReconfigurationComplete

@{HO_check_enabled_8236}
...    criticalExtensions rrcReconfiguration
...    eventId eventA3
...    transformPrecoder enabled
...    betaOffsets dynamic
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}
...    tp-pi2BPSK enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.4 performed
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms40
...    drx-InactivityTimer ms6
...    drx-SlotOffset 0
...    criticalExtensions rrcReconfigurationComplete

@{change_actUlSlotAgg_to_enabled_in_cell4_DU}
...    NRCELL-4:actUlSlotAgg=Enabled_VoNr

${ACC_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00025    #Accumulated number of PUSCH Repetition Type A capable UEs
${MAX_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00026    #Maximum number of PUSCH Repetition Type A capable UEs
${UE_CAP_DEN}    M55139C00027    #UE capability denominator

@{PM_Counters_Check_DU}
...    NRCELL-3:RSADU:${ACC_PUSCH_REP_TYPE_A_CAP_UE}>15
...    NRCELL-4:RSADU:${ACC_PUSCH_REP_TYPE_A_CAP_UE}>=13
...    NRCELL-3:RSADU:${MAX_PUSCH_REP_TYPE_A_CAP_UE}=1
...    NRCELL-4:RSADU:${MAX_PUSCH_REP_TYPE_A_CAP_UE}=1
...    last NRCELL-3:RSADU:${UE_CAP_DEN}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    last NRCELL-4:RSADU:${UE_CAP_DEN}=${60*${PM_COUNTER_INTERVAL[:-3]}}

*** Test Cases ***
CB010413_CB008236_ET_B006_Verify_Intra_gnb_Handover_of_VoNR_UE_in_SAg_mode_Slot_Aggregation_continues_at_Target_Cell
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    This case is migration from classical case: CB008236_ET_B006
    ...    This scenario describes gNB behavior when a UE with a 5QI1 DRB in poor RF coverage while in Slot Aggregation mode, is handed over to a
    ...    neighbor cell with CB008236 feature enabled
    ...    gNB continues to remain in slot aggregation eligible state on the target cell.
    ...    Upon completion of handover, target cell sets up DRX profile2 at the UE with DRX sleep off state.
    ...    Handover may be intra-gNB or inter-gNB.
    ...    Requirement Coverage:
    ...    5G_PM_1076, 5G_RAN_USR_RRM_19896, fully covered
    ...    2.Test Case Steps:
    ...         Step A.UE Register on cell3 and Add Pdu with Default 5QI5
    ...         Step B.PDU Add QoSFlow 5QI6
    ...         Step C.UE moves towards cell edge
    ...         Step D.PDU Add QoSFlow 5QI1
    ...         Step E.trigger gNB source cell3 initiates handover to target cell4
    ...         Step F.release UE
    ...         Step G.Check PUSCH Repetition related counters
    ...         Step H.wireshark logs check
    ...    3. Expected Results:
    ...         Step A: UE Register on cell3 and Add Pdu with Default 5QI5 is successfully
    ...         Step B: PDU Add QoSFlow 5QI6 is succefflly
    ...         Step C:
    ...          1)UE Transform Precoder enabled
    ...          2)gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          3)pusch-TimeDomainAllocationListDCI-0-1-r16 is setup
    ...         Step D:
    ...          1)PDU Add QoSFlow 5QI1 is successfully
    ...          2)gNB initiates RRCReconfiguration procedure to perform User Reconfiguration
    ...          3)UE Transform Precoder enabled
    ...          4)gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...          5)UE is configured with DRX Sleep Off, onDurationTimer equal to drx-LongCycle length
    ...         Step E.
    ...          1)Source cell includes UE capability for PUSCH repetition and TP enabled state info in HandoverPreparationInformation
    ...          2)
    ...          a)Target cell gNB-DU-CP configures Rel16 TDRA table in RRCReconfiguration to UE as part of Handover Command
    ...          b)gNB-DU-CP configures Rel16 TDRA table (pusch-TimeDomainAllocationListDCI-0-1-r16) in PUSCH-Config as part of uplinkBWPConfig for
    ...          each of the dedicated BWP's to be configured (UplinkConfig -> uplinkBWP-ToAddModList -> #BWP-Uplink -> bwp-Dedicated)
    ...          Note: due to delta configuration, target cell gNB-DU-CP may choose to not include the IE as mentioned above, if the IE is already
    ...          configured at the UE as indicated by PUSCH-Config received from source cell in HandoverPreparationInformation
    ...          c)The Rel15 TDRA table PUSCH-TimeDomainAllocationList is not configured if Rel16 IE is configured
    ...          d)gNB configures UE with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...          3)UE sends RRCReconfigurationComplete to target cell gNB and as per legacy behavior, the Handover procedure is completed
    ...          4)NB-DU enters Slot Aggregation eligible state
    ...          5)gNB sets up VoNR DRX profile2 with DRX Sleep Off
    ...         Step F.UE is release successfully
    ...         Step G: ALL PUSCH Repetition related counters is update is correct
    ...         Step H: wireshark logs check passed
    [Tags]    QC_347872    CA_LABEL-FF(20MHz_FDD_n5+20MHz_FDD_n5)
    Online changes the actUlSlotAgg to enabled in cell4
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=3
    PDU Add QoSFlow 5QI6    ue_id=3
    Trigger UE Transform Precoder enabled    ue_id=3
    PDU Add QoSFlow 5QI1    ue_id=3
    IntraFre A3 Handover to cell3 with 8236 enabled    ue_id=3
    Release UEs    ue_type=all
    Check Counters Du Aic    ${PM_Counters_Check_DU}


*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    ue_param id=3 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg Aic    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    ${set_ue}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645500 mode=nr enb=2 cell=3
    Update Cfg Aic    ${set_ue}
    Update Cfg Aic    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg Aic    set_qosflow id=1 5qi=5 default=on
    Update Cfg Aic    set_qosflow id=2 5qi=1
    Update Cfg Aic    set_qosflow id=3 5qi=6 default=off
    Update Cfg Aic    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg Aic    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg Aic    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2,3 default=on ue=1-6 amf=1

OnlineParamChangeDU
    [Arguments]    ${Online_Param}
    Delta Commission Parameters Du    ${Online_Param}
    Cells Should Be Onair Du

Clear Counter Files
#    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

UE Register And Add Pdu With Default 5QI5
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

PDU Add QoSFlow 5QI6
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:6
    Run Traffic    ue_id=${ue_id}

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=${TP_and_SAg_activate_check_after_add_5QI1}

Run Traffic
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=10 dir=ul
    Verify Throughput    ue_id=${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}    ${Tput_ul}=8    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger UE Transform Precoder enabled
    [Arguments]    ${ue_id}
    Execute Egate Command     ul_sinr_testmode_nr profile_id=2 pathloss=118
    Execute Egate Command     ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=2 action=activate    pass_regexp=${TP_activate_check}

IntraFre A3 Handover to cell3 with 8236 disabled
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 phycell_id=61    pass_regexp=${HO_check_disabled_8236}

IntraFre A3 Handover to cell3 with 8236 enabled
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 phycell_id=61    pass_regexp=${HO_check_enabled_8236}
    sleep    10s    #wait counter update and check UE not release

Online changes the actUlSlotAgg to enabled in cell4
    OnlineParamChangeDU    ${change_actUlSlotAgg_to_enabled_in_cell4_DU}
