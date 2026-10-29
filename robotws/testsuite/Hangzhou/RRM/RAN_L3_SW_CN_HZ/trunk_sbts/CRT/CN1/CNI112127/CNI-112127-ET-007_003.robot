*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    master_classicalbts_all    STATE_CONFIGURED
...               FR1    CN1    team-CN1ET    owner-jia.pan    release-SBTS24R1
...               CLOUD_5G_I_BOO_AP_LOO
Resource         ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_4T2F
${SYSCOM_FLAG}    ${True}

@{PARAMS_FOR_5QI1}
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_IN_SCF}
...    NRBTS:actEnhancedLinkAdaptation=true
...    @{PARAMS_FOR_5QI1}
...    NRCELL-1:chBw=50MHz
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    @{Change_Golden_Band}
...    @{RedirRat}
...    @{NRCELL-11_enable_vonr}
...    @{NRCELL-1_enable_vonr}

@{NRCELL-11_enable_vonr}
...    NRBTS-1/NRCELL-11:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-11:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-11:drxProfile1:drxOnDurationTimer=10ms
...    NRBTS-1/NRCELL-11:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-11:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-11:t310VoNR=100ms
...    NRBTS-1/NRCELL-11:drxProfile2:drxInactivityTimer=4ms
...    NRBTS-1/NRCELL-11:drxProfile2:drxLongCycle=40ms
...    NRBTS-1/NRCELL-11:drxProfile2:drxOnDurationTimer=6ms
...    NRBTS-1/NRCELL-11:drxProfile2:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-11:drxProfile2:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-11:actCDrxVoNR=true
...    NRBTS-1/NRCELL-11:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-11:actCDrx=true
...    NRBTS-1/NRCELL-11:actVoNR=true
...    NRBTS-1/NRCELL-11:n310VoNR=n10

@{Change_Golden_Band}
...    NRCELL-11:freqBandIndicatorNR=66
...    NRCELL-11:gscnOrSsPbchArfcn=5300
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000

${CA_SUPPORT_LIST}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa

@{online_modify_for_007}
...    NRCELL-11:actBadUplinkRadioRedirect=highUlBlerBased
...    NRCELL-11:badULRedirectDeprioTimer=30min
...    NRCELL-11:ulBler:ulBlerThresholdRedirectData=100
...    NRCELL-11:ulBler:ulBlerThresholdRedirectVoNR=100
...    NRCELL-1:actBadUplinkRadioRedirect=highUlBlerOrUlNackFloodBased
...    NRCELL-1:badULRedirectDeprioTimer=30min
...    NRCELL-1:ulBler:ulBlerThresholdRedirectData=100
...    NRCELL-1:ulBler:ulBlerThresholdRedirectVoNR=100
...    NRBTS-1:actRedirect=true
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1

@{online_recover_for_007}
...    NRCELL-11:actBadUplinkRadioRedirect=disabled
...    NRCELL-1:actBadUplinkRadioRedirect=disabled
...    NRBTS-1:actRedirect=false
...    delete:MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1

@{NRCELL-1_enable_vonr}
...    NRBTS-1/NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-1:t310VoNR=100ms
...    NRBTS-1/NRCELL-1:drxProfile2:drxInactivityTimer=4ms
...    NRBTS-1/NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRBTS-1/NRCELL-1:drxProfile2:drxOnDurationTimer=6ms
...    NRBTS-1/NRCELL-1:drxProfile2:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-1:drxProfile2:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-1:actCDrxVoNR=true
...    NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:actVoNR=true
...    NRBTS-1/NRCELL-1:n310VoNR=n10

@{NRCELL-3_enable_vonr}
...    NRBTS-1/NRCELL-3:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-3:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-3:drxProfile1:drxOnDurationTimer=10ms
...    NRBTS-1/NRCELL-3:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-3:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-3:t310VoNR=100ms
...    NRBTS-1/NRCELL-3:drxProfile2:drxInactivityTimer=4ms
...    NRBTS-1/NRCELL-3:drxProfile2:drxLongCycle=40ms
...    NRBTS-1/NRCELL-3:drxProfile2:drxOnDurationTimer=6ms
...    NRBTS-1/NRCELL-3:drxProfile2:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-3:drxProfile2:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-3:actCDrxVoNR=true
...    NRBTS-1/NRCELL-3:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-3:actCDrx=true
...    NRBTS-1/NRCELL-3:actVoNR=true
...    NRBTS-1/NRCELL-3:n310VoNR=n10

@{NRCELL-4_enable_vonr}
...    NRBTS-1/NRCELL-4:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-4:t310VoNR=100ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxInactivityTimer=4ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxLongCycle=40ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-4:actCDrxVoNR=true
...    NRBTS-1/NRCELL-4:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-4:actCDrx=true
...    NRBTS-1/NRCELL-4:actVoNR=true
...    NRBTS-1/NRCELL-4:n310VoNR=n10

@{NRCELL-3_4_enable_A5event_for_intrafreqHO}
...    NRCELL-4:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5Threshold2SsbRsrp=42
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrp:a5Threshold2SsbRsrp=32
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5Threshold1SsbRsrq=30
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5Threshold2SsbRsrq=40
...    NRBTS-1/NRCELL-4:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrq:a5Threshold1SsbRsrq=30
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrq:a5Threshold2SsbRsrq=35
...    NRBTS-1/NRCELL-3:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0

@{CNI-112127-003}
...    NRCELL-4:actBadUplinkRadioRedirect=highUlBlerOrUlNackFloodBased
...    NRCELL-4:badULRedirectDeprioTimer=10min
...    NRCELL-4:ulBler:ulBlerThresholdRedirectData=40
...    NRCELL-4:ulBler:ulBlerThresholdRedirectVoNR=75
...    NRCELL-3:actBadUplinkRadioRedirect=highUlBlerBased
...    NRCELL-3:badULRedirectDeprioTimer=0min
...    NRCELL-3:ulBler:ulBlerThresholdRedirectData=12
...    NRCELL-3:ulBler:ulBlerThresholdRedirectVoNR=13

@{paramter_003}
...    NRCELL-3:a5MeasEnabled=rsrp
...    NRCELL-4:a5MeasEnabled=rsrp
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:gNbId=1
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-2:gNbId=1
...    NRCELL-4/NRREL-2:gNbIdLength=22
...    NRCELL-4/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-2:lcrId=2
...    NRCELL-4/NRREL-2:removeNotAllowed=false
...    NRCELL-4/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-2:sCellOperationalMode=dlOnly

@{ANR_gnb}
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1
...    NRCELL-3:drxProfileNrAnr:drxControl=intraNRSAintraFreq
...    NRCELL-3:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-3:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-3:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-3:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-3:drxProfileNrAnr:drxRetransTimerUl=0slot

@{act_mobility_profile}
...    NRBTS:actMobilityProfile=true
...    NRBTS:actSPID=true
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=1
...    NRCELL:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=28
...    NRCELL:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    delete:NRBTS/NRMOPR_NSA-1:a5MeasEnabled
...    NRBTS/NRMOPR_NSA-1:a2MeashoEnabled=none
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRBTS-1/NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480

@{RedirRat_003}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1

...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirPrio=1

...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-1:redirPrio=2

...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-1:redirPrio=2

...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-1:redirPrio=1

...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-1:redirFreqNr=424090
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-1:redirSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-1:redirPrio=1

...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqNr=648096
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2

...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirFreqNr=648096
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirPrio=3

...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-2:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-2:redirFreqNr=648096
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-2:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-2:redirPrio=1

...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-2:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-2:redirFreqNr=648096
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-2:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-4/NRREDRT-2:redirPrio=6

...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-2:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-2:redirFreqNr=648096
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-2:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-11/NRREDRT-2:redirPrio=2

...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-2:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-2:redirFreqNr=648096
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-2:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-12/NRREDRT-2:redirPrio=2

...    NRCELL-4:a2MeasRedirectEnabled=rsrp
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL-4:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-4:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:actRedirect=true
...    NRCELL-4:a1MeashoEnabledSA=none
...    NRCELL-4:a2MeashoEnabledSA=none
...    NRBTS/NRMOPR_SA-1:nrMoRedDNList=MRBTS-1/NRBTS-1/NRMORED-1,MRBTS-1/NRBTS-1/NRMORED-2,MRBTS-1/NRBTS-1/NRMORED-3
...    NRBTS/NRMOPR_SA-1:voiceFBMode=redirection
...    NRBTS/NRMOPR_SA-1:a2MeasRedirectEnabled=rsrpCombined
...    NRBTS/NRMORED-1:redirFreqNr=424090
...    NRBTS/NRMORED-1:redirRat=nr
...    NRBTS/NRMORED-1:redirPrio=1
...    NRBTS/NRMORED-2:redirFreqEutra=39750
...    NRBTS/NRMORED-2:redirRat=eutra
...    NRBTS/NRMORED-2:redirPrio=2
...    NRBTS/NRMORED-3:redirFreqNr=648096
...    NRBTS/NRMORED-3:redirRat=nr
...    NRBTS/NRMORED-3:redirPrio=6

@{modify_redirPrio_FDD_TDD_EUTRA}
...    NRBTS/NRMORED-1:redirFreqNr=424090
...    NRBTS/NRMORED-1:redirRat=nr
...    NRBTS/NRMORED-1:redirPrio=1
...    NRBTS/NRMORED-2:redirFreqEutra=39750
...    NRBTS/NRMORED-2:redirRat=eutra
...    NRBTS/NRMORED-2:redirPrio=2
...    NRBTS/NRMORED-3:redirFreqNr=648096
...    NRBTS/NRMORED-3:redirRat=nr
...    NRBTS/NRMORED-3:redirPrio=6

@{modify_redirPrio_TDD_EUTRA_FDD}
...    NRBTS/NRMORED-1:redirFreqNr=424090
...    NRBTS/NRMORED-1:redirRat=nr
...    NRBTS/NRMORED-1:redirPrio=6
...    NRBTS/NRMORED-2:redirFreqEutra=39750
...    NRBTS/NRMORED-2:redirRat=eutra
...    NRBTS/NRMORED-2:redirPrio=2
...    NRBTS/NRMORED-3:redirFreqNr=648096
...    NRBTS/NRMORED-3:redirRat=nr
...    NRBTS/NRMORED-3:redirPrio=1

@{modify_redirPrio_EUTRA_FDD_TDD}
...    NRBTS/NRMORED-1:redirFreqNr=424090
...    NRBTS/NRMORED-1:redirRat=nr
...    NRBTS/NRMORED-1:redirPrio=3
...    NRBTS/NRMORED-2:redirFreqEutra=39750
...    NRBTS/NRMORED-2:redirRat=eutra
...    NRBTS/NRMORED-2:redirPrio=2
...    NRBTS/NRMORED-3:redirFreqNr=648096
...    NRBTS/NRMORED-3:redirRat=nr
...    NRBTS/NRMORED-3:redirPrio=6

@{Precondition_E003_disable_CNI}
...    @{act_mobility_profile}
...    @{RedirRat_003}
...    @{ANR_gnb}
...    @{NRCELL-1_enable_vonr}
...    @{NRCELL-3_enable_vonr}
...    @{NRCELL-4_enable_vonr}
...    @{paramter_003}
...    @{NRCELL-3_4_enable_A5event_for_intrafreqHO}
...    NRCELL-3:actBadUplinkRadioRedirect=disabled
...    NRCELL-4:actBadUplinkRadioRedirect=disabled

@{E003_Recovery}
...    NRBTS:actMobilityProfile=false
...    delete:NRREDRT.*
...    delete:NRREL.*
...    NRCELL-4:a2MeasRedirectEnabled=none
...    NRCELL-1:a2MeasRedirectEnabled=none
...    NRCELL-11:a2MeasRedirectEnabled=none
...    NRCELL-3:actBadUplinkRadioRedirect=disabled
...    NRCELL-4:actBadUplinkRadioRedirect=disabled

${actBadUp_10}    SEPARATOR=
...    itf_l2_ps_cell_CellReconfigurationReq_t.actBadUplinkRadioRedirect == 10 &&
...    itf_l2_ps_cell_BadUplinkRadioRedirectConfig.ulBlerThresholdRedirectData == 12 &&
...    itf_l2_ps_cell_BadUplinkRadioRedirectConfig.ulBlerThresholdRedirectVoNR == 13

${actBadUp_20}    SEPARATOR=
...    itf_l2_ps_cell_CellReconfigurationReq_t.actBadUplinkRadioRedirect == 20 &&
...    itf_l2_ps_cell_BadUplinkRadioRedirectConfig.ulBlerThresholdRedirectData == 40 &&
...    itf_l2_ps_cell_BadUplinkRadioRedirectConfig.ulBlerThresholdRedirectVoNR == 75

@{PM_Counters_Check_003}
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==3
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==0
...     NRCELL-3:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==3
...     NRCELL-4:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==0
...    NRCELL-3:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=1
...    NRCELL-3:NRRCC:${NRRCC_RRC_RELEASE_REDIR_LTE}=1
...    NRCELL-4:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=1
...    NRCELL-4:NRRCC:${NRRCC_RRC_RELEASE_REDIR_LTE}=0
...    NRCELL-3:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=1
...    NRCELL-4:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=1
...    NRCELL-3:${NG_FLOW_REL_GNB_REDIRECT}=4
...    NRCELL-4:${NG_FLOW_REL_GNB_REDIRECT}=3
...    NRCELL-3:NRRCC:${NR_RRC_REL_REDIR_RAD_NR}=1
...    NRCELL-3:NRRCC:${NR_RRC_REL_REDIR_RAD_LTE}=1
...    NRCELL-4:NRRCC:${NR_RRC_REL_REDIR_RAD_NR}=1
...    NRCELL-4:NRRCC:${NR_RRC_REL_REDIR_RAD_LTE}=0

&{CELLS_SSBFREQ}
...     1=632736
...     2=648096
...     3=508110
...     4=508110
...     11=424090
...     12=126750

@{3CC_TTF_CA}
...    pcid:52, scellIdx:0] configure_0_1
...    pcid:52, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${NRRCC_RRC_RELEASE_REDIR_NR}    M55124C01501
#The counter is updated when the RRC RELEASE with redirectedCarrierInfo IE and NR carrier frequency (ARFCN-ValueNR) is sent to UE.
${NG_FLOW_REL_GNB_REDIRECT_5QI1}    M55125C09502    
#Number of 5QI-1 QoS Flows that are associated to PDU Session(s) released via NGAP: UE CONTEXT RELEASE REQUEST message with Cause Group IE 
#set as "Radio Network Layer" and cause value set to "Redirection".
${NG_FLOW_REL_GNB_REDIRECT}    M55125C09002
#Number of QoS Flows that are associated to PDU Session(s) released via an NGAP: UE CONTEXT RELEASE REQUEST message with Cause Group IE 
#set as "Radio Network Layer" and cause value set to "Redirection".
${NR_RRC_REL_REDIR_RAD_NR}    M55124C00521
#This counter provides the total number of RRC RELEASE messages with the redirectedCarrierInfo IE and NR carrier frequency for the redirections 
#initiated due to a bad UL radio condition detection.
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004
${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502
${NR_RRC_REL_REDIR_RAD_LTE}    M55124C00522

@{PM_Counters_Check_007}
...    NRCELL-1:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=1
...    NRCELL-11:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_GNB_REDIRECT}=4
...    NRCELL-11:${NG_FLOW_REL_GNB_REDIRECT}=0
...    NRCELL-1:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=2
...    NRCELL-11:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=0
...    NRCELL-1:NRRCC:${NR_RRC_REL_REDIR_RAD_NR}=2
...    NRCELL-11:NRRCC:${NR_RRC_REL_REDIR_RAD_NR}=0

@{default DRX release}
...    drx-Config release
...    Added QosFlow with QFI:2 5QI:1

@{RedirRat}
...    NRCELL-1:a2MeasRedirectEnabled=rsrp
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-1:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL-11:a2MeasRedirectEnabled=rsrp
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-11:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL-11:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRCELL-11:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS-1:timerRRCGuard=6000

#support ANR
${UE_CAPA}    SEPARATOR=
...    E9A09000075F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608CA1A081070000148340185B262A88873E238F11
...    C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000
...    000000040E1E027FFC00001FFF000001700003801EF0F1340038820000042C05CFFFFFFFA83C28000E230000010B02B0F11800388200000C
...    2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038
...    500000102C0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388
...    C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C04117400BB
...    07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF81120
...    4081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E82E003E00281C
...    1401C0C02500700060240040603E090020000000100000200800000004000008020000080100000600800004004000028020010040100400
...    00300200001C010008000000200002001000012008000030040000500200002C01000812048020000300CE545654D60A5606560CD60AD652
...    D64CD602D606D6025604560ED0341000009652504000040000410000296524040000E5949010000496524040001659490100006965240400
...    01E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2
...    A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403
...    00610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E
...    00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CNI-112127-ET-007_algorithm_HighUplinkBLER_threshold_for_datacall_set_100_UE1_attach_pcell_TDD_UE2_attach_FDD_trigger_ulbler_no_redirect_happen
    [Documentation]
    ...    1. The purpose of this test case is to verify When Cell11-actBadUplinkRadioRedirect is set to highUlBlerBased then gNb-DU will not 
    ...    report high uplink BLER condition and the UE context will not be released.
    ...    When CELL1-actBadUplinkRadioRedirect is set to highUlBlerOrUlNackFloodBased then gNb-DU will release the UE context (with redirection)
    ...    when Nack flooding is observed. High BLER condition will not trigger UE context release.
    ...    2. Test Case Steps:
    ...         step1. UE81 attach datacall only to CELL1 and trigger ULBler
    ...                Nack flooding need trigger large traffic
    ...         Expected Results:
    ...                UE81 will release the UE context (with redirection) when Nack flooding is observed
    ...         step2. UE82 attach datacall only to CELL11 and trigger ULBler.
    ...         Expected Results:
    ...                UE82 will not trigger UE context release.
    ...         step3. UE83 attach Vonr to CELL1 and trigger ULBler.
    ...         Expected Results:
    ...                UE83 will release the UE context (with redirection) when Nack flooding is observed
    ...         step4. UE84 attach Vonr to CELL11 and trigger ULBler.
    ...         Expected Results:
    ...                UE84 will not trigger UE context release.
    [Tags]    007    QC_344649
    OnlineParamChange    ${online_modify_for_007}
    Clear Counter Files
    UE81 attach and trigger ULBler
    UE82 attach and trigger ULBler
    UE83 attach and trigger ULBler
    UE84 attach and trigger ULBler
    Check Wireshark Log    ${CURDIR}${/}A2A_007${/}a2a.ini    wait_string=UEContextRelease::66
    Check Counters    ${PM_Counters_Check_007}
    Check RadioLinkStatus should be BAD_UPLINK_RADIO
    [Teardown]    Teardown for case    ${online_recover_for_007}

CNI-112127-ET-003_pcell_TDD_highUlBlerOrNackFlood_IWK_Mobility profile_UE1_trigger_HighBler_UE2_IWK_Intragnb_intrafreqHO_ANR_trigger_NackFlood
    [Documentation]
    ...    1. This user scenario describes the gNb behaviour when mobilty profile enable and when actBadUplinkRadioRedirect set to
    ...    HighUlBlerOrNackFlood or HighUlBler, data call only UE1 setup, detect ulbler reach the threshold of ulBlerThresholdRedirectData,
    ...    redirect to FDD as high prio. onlinemodify_redirPrio_TDD_EUTRA_FDD, datacall only UE2 setup, then do intragnb intrafreqHO with
    ...    ANR to another cell, then pdu for vonr created, nack flooding detected for UE2, redirect to TDD as high prio.
    ...    onlinemodify_redirPrio_EUTRA_FDD_TDD, setup vonr call UE3, ul bler reached ulBlerThresholdRedirectVoNR detected,
    ...    redirect to eutra as high prio.
    ...    2. Test Case Steps:
    ...         Precondition: OnlineParamChange for act_mobility_profile and RedirRat and disable CNI flag 
    ...                       then online enable CNI to collect the L2ps message
    ...         step1. OnlineParamChange: modify_redirPrio_FDD_TDD_EUTRA
    ...                setup ue81 to pcell cell-3 , ue82 to pcell cell-3
    ...                TTF CA setup blindly. (pcell:nrcell-3 scell: nrcell-2 and nrcell-11). traffic is ok.
    ...                Add UL Bler for UE82, check UE82 is idle as UL bler,
    ...                and redirect to FDD 424090 (cell-3 ulBlerThresholdRedirectData used).
    ...         step2. OnlineParamChange: modify_redirPrio_TDD_EUTRA_FDD
    ...                UE81 do IntraFreq IntragNB HO via ANR to cell-4 (blind add scell nrcell-2)
    ...                setup vonr DRB for the UE81
    ...                trigger nack_flooding for the UE81, check UE81 is idle as nack_flooding
    ...                (cell-4 ulBlerThresholdRedirectVoNR=75 it is high, so nack flooding is easily triggered),
    ...                and redirect to TDD 648096.
    ...         step3. OnlineParamChange: modify_redirPrio_EUTRA_FDD_TDD
    ...                UE83 vonr call UE attach to cell-3
    ...                trigger UL Bler for the UE83, check UE83 is idle as UL_bler
    ...                and redirect to EUTRA 39750. (cell-3 ulBlerThresholdRedirectVoNR used)
    ...         check wireshark and counter.
    [Tags]    003    QC_344647
    [Timeout]    60 min
    OnlineParamChange    ${Precondition_E003_disable_CNI}
    Clear Counter Files
    OnlineParamChange    ${CNI-112127-003}
    Setup_two_data_UE81_82_trigger_Ulbler_for_UE82_RedirRat_FDD
    Add_vonr_UE81_trigger_nack_flooding_RedirRat_TDD
    Setup_vonr_UE83_trigger_Ulbler_RedirRat_EUTRA
    Check Counters    ${PM_Counters_Check_003}
    Check Wireshark Log    ${CURDIR}${/}A2A_003${/}a2a.ini    wait_string=UEContextRelease::54
    check L2PS syscom message
    [Teardown]    Teardown for case    ${E003_Recovery}

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=82 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=83 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=84 voice_over_nr=on:on:off
    Update Cfg    ue_param id=81 ue_nr_capabilities=${UE_CAPA} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=82 ue_nr_capabilities=${UE_CAPA} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=83 ue_nr_capabilities=${UE_CAPA} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=84 ue_nr_capabilities=${UE_CAPA} nr_usage_setting=voice_centric
    ${cell_11}    catenate    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=344000:424000 gscn=5300 mandatory_for_activation=off
    Update Cfg    ${cell_11}

Check RadioLinkStatus should be BAD_UPLINK_RADIO
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_RadioLinkStatusInd_t.ueRlStatus == 3
    should be equal As Numbers    ${number}    2

Teardown for case
    [Arguments]    ${Online_Param}
    Deactivate Bler Testmode    ue_id=81
    Deactivate Bler Testmode    ue_id=82
    Deactivate Bler Testmode    ue_id=83
    Deactivate Bler Testmode    ue_id=84
    OnlineParamChange    ${Online_Param}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE81 attach and trigger ULBler
    UE Attach and L3 data Call
    Start Traffic and verify for T    ue_id=81
    Add UL Bler or Nack_flooding    ue_id=81    
    Wait Until Keyword Succeeds    20min    30sec    Check Specific UE State    ue_id=81    state=IDLE
    Deactivate Bler Testmode    ue_id=81
    sleep    30s    sleep for Bler

UE82 attach and trigger ULBler   
    UE Attach and L3 data Call    ue_id=82    cell_id=11    
    Start Traffic and verify for F    ue_id=82
    Add UL Bler or Nack_flooding    ue_id=82   
    Wait Until Keyword Succeeds    20min    30sec    Check Specific UE State    ue_id=82    state=IDLE
    Deactivate Bler Testmode    ue_id=82
    sleep    30s    sleep for Bler

UE83 attach and trigger ULBler
    UE Attach and L3 VoNR Call
    Start Traffic and verify for T    ue_id=83 
    Add UL Bler or Nack_flooding    ue_id=83
    Wait Until Keyword Succeeds    20min    30sec    Check Specific UE State    ue_id=83    state=IDLE
    Deactivate Bler Testmode    ue_id=83

UE84 attach and trigger ULBler
    UE Attach and L3 VoNR Call    ue_id=84    cell_id=11
    Start Traffic and verify for F    ue_id=84  
    Add UL Bler or Nack_flooding    ue_id=84   
    Wait Until Keyword Succeeds    20min    30sec    Check Specific UE State    ue_id=84    state=IDLE
    Deactivate Bler Testmode    ue_id=84

Add UL Bler or Nack_flooding
    [Arguments]    ${ue_id}=81    ${profile_id}=1  
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} ul_bler=800,800,800,800,800,800,800,800
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler profile_id=${profile_id} action=activate

Deactivate Bler Testmode
    [Arguments]    ${ue_id}=81    ${profile_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler profile_id=${profile_id} action=deactivate
    Sleep    2s    sleep for Bler

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
	END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}

UE Attach and L3 VoNR Call
    [Arguments]    ${ue_id}=83    ${pdu_gw_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Setup VONR Call On New PDU Session    ue_id=${ue_id}

Setup VONR Call On New PDU Session
    [Arguments]    ${ue_id}=81    ${gateway}=2    ${pdu}=2
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf    pass_regexp=${default DRX release}
    Execute Egate Command    qosflow_disp
    Execute Egate Command    smf_param id=1 reset

UE Attach and L3 data Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1    ${cell_id}=1    ${DL_CC}=1    ${UL_CC}=1    ${pass_regexp}=Initial Context Setup Successful
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=${pass_regexp}

Start Traffic and verify for F
    [Arguments]    ${ue_id}    ${pdu_gw_id}=1    ${CC_num}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=150
    ...    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=150 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=150 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    10min    5sec    Check Throughput with Type    ue_id=${ue_id}
    ...    Tput_expect=150    CC_num=${CC_num}    type=pdsch
    Wait Until Keyword Succeeds    10min    5sec    Check Throughput with Type    ue_id=${ue_id}
    ...    Tput_expect=60    CC_num=${CC_num}    type=pusch

Start Traffic and verify for T
    [Arguments]    ${ue_id}    ${pdu_gw_id}=1    ${CC_num}=1    ${DL_TP}=300    ${UL_TP}=60
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=150 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=150 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=150 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=150 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    10min    5sec    Check Throughput with Type    ue_id=${ue_id}
    ...    Tput_expect=${DL_TP}    CC_num=${CC_num}    type=pdsch
    Wait Until Keyword Succeeds    10min    5sec    Check Throughput with Type    ue_id=${ue_id}
    ...    Tput_expect=${UL_TP}    CC_num=1    type=pusch

Start Traffic and verify for CA
    [Arguments]    ${ue_id}    ${pdu_gw_id}=1    ${CC_num}=1    ${DL_TP}=210    ${UL_TP}=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=80 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=150 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    10min    5sec    Check Throughput with Type    ue_id=${ue_id}
    ...    Tput_expect=${DL_TP}    CC_num=${CC_num}    type=pdsch
    Wait Until Keyword Succeeds    10min    5sec    Check Throughput with Type    ue_id=${ue_id}
    ...    Tput_expect=${UL_TP}    CC_num=1    type=pusch

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    Should Be True    ${scell_tput}/1000 >= 0

Setup_two_data_UE81_82_trigger_Ulbler_for_UE82_RedirRat_FDD
    OnlineParamChange    ${modify_redirPrio_FDD_TDD_EUTRA}
    UE Attach and L3 data Call    ue_id=81    pdu_gw_id=1    cell_id=3    pass_regexp=${3CC_TTF_CA}
    Start Traffic and verify for CA    ue_id=81    pdu_gw_id=1    CC_num=3    DL_TP=210    UL_TP=70
    UE Attach and L3 data Call    ue_id=82    pdu_gw_id=3    cell_id=3    pass_regexp=${3CC_TTF_CA}
    Start Traffic and verify for CA    ue_id=82    pdu_gw_id=3    CC_num=3    DL_TP=210    UL_TP=70
    Add UL Bler or Nack_flooding    ue_id=82    profile_id=2
    Wait Until Keyword Succeeds    12min    5sec    Check Specific UE State    82    IDLE
    Deactivate Bler Testmode    ue_id=82    profile_id=2

Add_vonr_UE81_trigger_nack_flooding_RedirRat_TDD
    OnlineParamChange    ${modify_redirPrio_TDD_EUTRA_FDD}
    Wait Until Keyword Succeeds    2min    5sec    Check Throughput with Type    ue_id=81
    ...    Tput_expect=70    CC_num=1    type=pusch
    IntraFreq IntragNB HO    ue_id=81    source_cell=3    target_cell=4    target_phycell_id=53    event=A5
    Execute Egate Command    ue_disp
    Setup VONR Call On New PDU Session    ue_id=81    gateway=2    pdu=2
    Wait Until Keyword Succeeds    2min    5sec    Check Throughput with Type    ue_id=81
    ...    Tput_expect=70    CC_num=1    type=pusch
    Add UL Bler or Nack_flooding    ue_id=81    profile_id=1
    Wait Until Keyword Succeeds    12min    5sec    Check Specific UE State    81    IDLE
    Deactivate Bler Testmode    ue_id=81    profile_id=1

Setup_vonr_UE83_trigger_Ulbler_RedirRat_EUTRA
    OnlineParamChange    ${modify_redirPrio_EUTRA_FDD_TDD}
    UE Attach and L3 data Call    ue_id=83    pdu_gw_id=3    cell_id=3    pass_regexp=${3CC_TTF_CA}
    Setup VONR Call On New PDU Session    ue_id=83    gateway=2    pdu=2
    Start Traffic and verify for CA    ue_id=83    pdu_gw_id=3    CC_num=3    DL_TP=210    UL_TP=70
    Add UL Bler or Nack_flooding    ue_id=83    profile_id=3
    Wait Until Keyword Succeeds    12min    5sec    Check Specific UE State    83    IDLE
    Deactivate Bler Testmode    ue_id=83    profile_id=3

IntraFreq IntragNB HO
    [Arguments]    ${ue_id}    ${source_cell}    ${target_cell}    ${target_phycell_id}    ${event}
    Execute Egate Command    ue_disp
    ${src_cell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${source_cell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${src_cell_ssbfreq}    ${event}
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=90 nrsrq_nr=90
    Execute Egate Command    ${event_cmd}    pass_regexp=Intra-eNB handover    timeout=20

check L2PS syscom message
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_RadioLinkStatusInd_t.ueRlStatus == 3
    should be equal As Numbers    ${number}    3
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${actBadUp_10}
    should be equal As Numbers    ${number}    1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${actBadUp_20}
    should be equal As Numbers    ${number}    1
