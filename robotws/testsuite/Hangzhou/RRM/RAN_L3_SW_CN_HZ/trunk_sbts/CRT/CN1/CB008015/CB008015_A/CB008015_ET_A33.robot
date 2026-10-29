*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG2    owner-baijie.zhu    release-5G22R2    CB008015    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008015}
...    @{5GC001390}
...    @{CB006138}

@{5GC001390}
...    NRBTS/NRDU-1:actInterNumerologyCa=true

@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}

${CA_support_list}
...    ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa

@{CB008015}
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRBTS:actNormVCFallback=false
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1:drbInactivityTimerSA=7200

...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS:drbInactivityTimerSA=7200

...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:actCDrx=true
...    NRCELL:n310VoNR=n3
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:maxGBRTrafficLimit=75
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:t310VoNR=500ms
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
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
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false

...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none

...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

@{PARAMS_TO_MODIFY_8015_A33_1}
...    NRCELL-2:weightForSCellSelection=40
...    NRCELL-1:weightForSCellSelection=40
...    NRCELL-13:weightForSCellSelection=100
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50

@{expect_value}
...    sCellToAddModList
...    physCellId 61
...    physCellId 62
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

&{CELLS_CARRIER_FREQ}
...    1=518910
...    2=633216
...    11=424090
...    12=126750
...    13=427970

*** Test Cases ***
CB008015-ET-A33 A_B4_VoNR and Emergency call cross cover
    [Documentation]
    ...    1. The purpose of this test case is to verify SCell selection based on SCell bandwidth for SA call
    ...       - Mixed mode of FDD-FR1 TDD CA and FDD-FDD CA
    ...       UE 81-83: support n66+n71; n71+n41; n66+n41; n66+n78; n41+n78; n71+n78; n66+n66+n71 CA (FullCap)
    ...       Final selection order in (cell 11+ cell 13) > cell 1 > cell 2 = cell 13 >cell 11
    ...    2. Test Case Steps:
    ...         Precondition: NRCELL-12: a1MeasSCellAddEnabled: rsrpCombined
    ...         Step 1. SA UE-81 attach to cell 12 , VONR call setup successfully
    ...                 A1 is triggered, a1ThresholdSCellAddSsbRsrpFDD < rsrp value < a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Result: SA UE add CELL 11 and CELL 13 for FDD-FDD 3CC CA.
    ...         Step 2. A1 is triggered, rsrp value > a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Result: cell11 and cell 13 are better SCell than new SCell candidates: Cell 1 and cell 2.
    ...                          No SCell change is triggered.
    ...         Step 3.Pre-requested UE-101 to UE-110 are attached in CELL 11, and blind SCell addition is triggered.
    ...         Expected Result: cell12+cell13 is added as FDD-FR1 FDD 3CC CA. CELL 11 and CELL 13 load is high.
    ...         Step 4. A1 is triggered, rsrp value > a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Result: SA UE trigger SCell change to CELL 1 for FDD-TDD 2CC CA.
    ...        Loop Step 1-4 for SA UE-82 with ViNR call and SA UE-83 with EC.
    [Tags]    CB008015    QC_128168
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_8015_A33_1}
    UE Attach and Start VoNR Call And CA Verification
    UE Attach and Start VINR Call And CA Verification
    UE Attach and Start EC Call And CA Verification

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    ${UE81}    catenate
    ...    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645481 enb=2 cell=11 mode=nr
    ${UE82}    catenate
    ...    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645482 enb=2 cell=11 mode=nr
    ${UE83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645483 enb=2 cell=11 mode=nr
    ${UE101}    catenate
    ...    set_ue simulated id=101 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645451
    ...    enb=2 cell=11 mode=nr
    ${UE102}    catenate
    ...    set_ue simulated id=102 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645452
    ...    enb=2 cell=11 mode=nr
    ${UE103}    catenate
    ...    set_ue simulated id=103 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645453
    ...    enb=2 cell=11 mode=nr
    ${UE104}    catenate
    ...    set_ue simulated id=104 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645454
    ...    enb=2 cell=11 mode=nr
    ${UE105}    catenate
    ...    set_ue simulated id=105 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645455
    ...    enb=2 cell=11 mode=nr
    ${UE106}    catenate
    ...    set_ue simulated id=106 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645456
    ...    enb=2 cell=11 mode=nr
    ${UE107}    catenate
    ...    set_ue simulated id=107 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645457
    ...    enb=2 cell=11 mode=nr
    ${UE108}    catenate
    ...    set_ue simulated id=108 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645458
    ...    enb=2 cell=11 mode=nr
    ${UE109}    catenate
    ...    set_ue simulated id=109 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645459
    ...    enb=2 cell=11 mode=nr
    ${UE110}    catenate
    ...    set_ue simulated id=110 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645460
    ...    enb=2 cell=11 mode=nr
    Update Cfg    ${UE81}
    Update Cfg    ${UE82}
    Update Cfg    ${UE83}
    Update Cfg    ${UE101}
    Update Cfg    ${UE102}
    Update Cfg    ${UE103}
    Update Cfg    ${UE104}
    Update Cfg    ${UE105}
    Update Cfg    ${UE106}
    Update Cfg    ${UE107}
    Update Cfg    ${UE108}
    Update Cfg    ${UE109}
    Update Cfg    ${UE110}
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=82 ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=83 ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=82 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=83 voice_over_nr=on:on:off
    Update Cfg    ue_param id=101 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=102 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=103 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=104 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=105 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=106 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=107 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=108 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=109 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    ue_param id=110 ue_nr_capabilities=${Capa_FDD}
    Update Cfg    set_pdu_gateway id=81 ue_nat_ip=72.23.80.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=82 ue_nat_ip=72.23.81.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=83 ue_nat_ip=72.23.82.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=101 ue_nat_ip=72.23.100.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=102 ue_nat_ip=72.23.101.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=103 ue_nat_ip=72.23.102.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=104 ue_nat_ip=72.23.103.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=105 ue_nat_ip=72.23.104.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=106 ue_nat_ip=72.23.105.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=107 ue_nat_ip=72.23.106.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=108 ue_nat_ip=72.23.107.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=109 ue_nat_ip=72.23.108.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=110 ue_nat_ip=72.23.109.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=all amf=1

Scell Change With Scell_1 Based On A1 Rsrp Higher Than TDD Threshold
    [Arguments]    ${rrc_log_tag}=scell_1    ${ue_id}=81
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition By A1 Event    ue_id=${ue_id}    rsrp=120    rsrq=20    scell_num=3
    Check Scell Number    ue_id=${ue_id}    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 50

No SCell Change Based On A1 Rsrq Higher Than TDD Threshold
    [Arguments]    ${ue_id}=81
    No Scell Addition by A1 Event    ue_id=${ue_id}    srsrp_nr=120    srsrq_nr=20

Scell_11_13 Added Based On A1 Rsrp Higher Than FDD But Lower Than TDD
    [Arguments]    ${rrc_log_tag}=scell_11_13    ${ue_id}=81
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=50    rsrq=20    scell_num=2
    Check Scell Number    ue_id=${ue_id}    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62

UE Attach and Start VoNR Call And CA Verification
    UE Attach and Start VoNR Call
    Scell_11_13 Added Based On A1 Rsrp Higher Than FDD But Lower Than TDD
    No SCell Change Based On A1 Rsrq Higher Than TDD Threshold
    SA UE Attach At FDD Cell-11 And FDD Scell 12 And 13 Blind Addition
    Scell Change With Scell_1 Based On A1 Rsrp Higher Than TDD Threshold
    Release Ues    ue_type=all

UE Attach and Start VINR Call And CA Verification
    UE Attach and Start VINR Call
    Scell_11_13 Added Based On A1 Rsrp Higher Than FDD But Lower Than TDD    ue_id=82
    No SCell Change Based On A1 Rsrq Higher Than TDD Threshold    ue_id=82
    SA UE Attach At FDD Cell-11 And FDD Scell 12 And 13 Blind Addition
    Scell Change With Scell_1 Based On A1 Rsrp Higher Than TDD Threshold    ue_id=82
    Release Ues    ue_type=all

UE Attach and Start EC Call And CA Verification
    UE Attach and Start EC Call
    Scell_11_13 Added Based On A1 Rsrp Higher Than FDD But Lower Than TDD    ue_id=83
    No SCell Change Based On A1 Rsrq Higher Than TDD Threshold    ue_id=83
    SA UE Attach At FDD Cell-11 And FDD Scell 12 And 13 Blind Addition
    Scell Change With Scell_1 Based On A1 Rsrp Higher Than TDD Threshold    ue_id=83
    Release Ues    ue_type=all

SA UE Attach At FDD Cell-11 And FDD Scell 12 And 13 Blind Addition
    FOR    ${index}    IN RANGE    101    111
        Trigger Pdu Session And Check UE Blind Addition Result    ${index}
    END

Trigger Pdu Session And Check UE Blind Addition Result
    [Arguments]    ${index}=101
    Execute Egate Command    ue_change_location id=${index} enb=2 cell=11
    Execute Egate Command    ue_register id=${index}    NG RM Register
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${index} nwslice=1 gw=${index}
    ...    pass_regexp=${expect_value}    fail_regexp=SCellIndex 3 activated successfully at airphone   timeout=20s

UE Attach and Start VoNR Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1    ${cell}=12
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...    pass_regexp=QoS Routing Table
    Trigger UE 5QI Addition successfully with PDU session modify
    Check Traffic

Trigger UE 5QI Addition successfully with PDU session modify
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1    ${fiveQI}=1    ${qosflows_to_add}=2
    BuiltIn.Log    Trigger UE${ue_id} 5QI${fiveQI} add successfully with PDU session modify...    console=${True}
    ${ret1}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_gw_id} qosflows_to_add=${qosflows_to_add} by=amf
   ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully    timeout=20s
    Execute Egate Command    qosflow_disp    pass_regexp=Configured Qos Flows
    Should Contain    ${ret1}    rrcReconfiguration
    Should Contain    ${ret1}    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

UE Attach and Start VINR Call
    [Arguments]    ${ue_id}=82    ${pdu_gw_id}=2    ${cell}=12
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...    pass_regexp=QoS Routing Table
    Trigger UE 5QI Addition successfully with PDU session modify    ue_id=82    pdu_gw_id=2    fiveQI=1    qosflows_to_add=2
    Trigger UE 5QI Addition successfully with PDU session modify    ue_id=82    pdu_gw_id=2    fiveQI=2    qosflows_to_add=3
    Check Traffic    ue_id=82    pdu_gw_id=2

UE Attach and Start EC Call
    [Arguments]    ${ue_id}=83    ${pdu_gw_id}=3    ${cell}=12
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...    pass_regexp=QoS Routing Table
    Trigger UE 5QI Addition successfully with PDU session modify    ue_id=83    pdu_gw_id=3    fiveQI=1    qosflows_to_add=2
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Check Traffic    ue_id=83    pdu_gw_id=3

Check Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Triggered Scell Addition By A1 Event
    [Arguments]    ${ue_id}=81    ${rsrp}=25    ${rsrq}=120    ${scell_num}=1
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

No Scell Addition by A1 Event
    [Arguments]    ${srsrp_nr}=121    ${srsrq_nr}=110    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    fail_regexp=rrcReconfiguration

Check Scell Number
    [Arguments]    ${ue_id}=81    ${expected_scell_num}=1
    ${meas_obj}    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...    fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length    ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers    ${expected_scell_num}    ${real_scell_num}



