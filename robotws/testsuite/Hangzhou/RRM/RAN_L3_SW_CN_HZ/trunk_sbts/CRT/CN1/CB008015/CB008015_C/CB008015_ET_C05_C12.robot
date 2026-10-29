*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...     owner-selena.ye    team-SG2    release-5G22R2    CB008015    SBTS00
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}    @{5GC001390}    @{CB006138}    @{CB008015}    @{OPEN_BEAMFORMING}

@{5GC001390}    NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
${CA_SUPPORT_LIST}    ca_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa
@{CB008015}
...    NRCELL:actK1Opt=intra-gNB

...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actCDrx=true
...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-2:ssbFrequency=518910
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=60
...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssbFrequency=633216
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    MRBTS-1/NRBTS-1/NRCELL-13:pucchF3ModulationScheme=pi2bpsk
...    MRBTS-1/NRBTS-1/NRCELL-13:pucchF3MaxCodeRate=zeroDot08
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=45
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=42
...    MRBTS-1/NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    MRBTS-1/NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=115
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=95
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=95
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=71
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=72
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=74
...    MRBTS-1/NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    MRBTS-1/NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=45
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=22
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1/NRCELL-14:pucchF3ModulationScheme=pi2bpsk
...    MRBTS-1/NRBTS-1/NRCELL-14:pucchF3MaxCodeRate=zeroDot08
...    MRBTS-1/NRBTS-1/NRCELL-12:pucchF3ModulationScheme=pi2bpsk
...    MRBTS-1/NRBTS-1/NRCELL-12:pucchF3MaxCodeRate=zeroDot08
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=45
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=25
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=32
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    MRBTS-1/NRBTS-1/NRCELL-2:pucchF3ModulationScheme=pi2bpsk
...    MRBTS-1/NRBTS-1/NRCELL-2:pucchF3MaxCodeRate=zeroDot08
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=120
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=111
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=90
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=91
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=93
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=111

...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

@{OPEN_BEAMFORMING}
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_5_1
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-1:beamSet:tiltOffset=0
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_5_1
...    NRCELL-2:beamSet:leftEdgeAngle=60
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:rightEdgeAngle=60
...    NRCELL-2:beamSet:tiltOffset=0
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:nrCellType=4DL2UL
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1


@{DELTA_PARAS_C12}
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=105
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=85
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

*** Test Cases ***
CB008015-ET-C05_C_B3_SA Mobility based on rsrp involving two TDD cells with different coverage_1
    [Documentation]
    ...    1. The purpose of this test case is to check US CB008015-C_B3: Mobility based on rsrp involving two TDD cells
    ...       with different coverage-configuration 1 -SA.
    ...       SA UE 81: support n66+n71;n71+n41;n66+n41;n66+n78; n41+n78;n71+n78;n66+n66+n71 CA
    ...       Final order in cell 1 > cell 2 > cell 11+ cell 13 > cell 12 > cell 13 > cell 11
    ...       Final order in C1 > C2 > C11+ C13 > C12 > C13 > C11
    ...    2. Test Case Steps:
    ...         a. SA UE81 are attached in C12. And covBasedA1 SCell addition is triggered
    ...          rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD(C12) for SA UE81
    ...         expect result: C12 will add C1 for FDD-TDD 2CC CA.
    ...           ue_change_location id=81 enb=2 cell=12
    ...           ue_register id=81
    ...           set_pdu_param ue=81 pdu=1 trf_type=internal
    ...           ue_pdu_session_setup pdu=1 ue=81 nwslice=1 gw=1
    ...           trf_data_start ue=81 pdu=1 qfi=1 dir=ul mbps=20
    ...           trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=100
    ...           bearer_stats ue=81 pdu=1 qfi=1 dir=dl
    ...           bearer_stats ue=81 pdu=1 qfi=1 dir=ul
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=1 srsrp_nr=101
    ...         b. C1 A1 measurement report for Pcell switch is triggered,
    ...         rsrp value higher than a1ThresholdPCellSwitchSsbRsrp(C1)
    ...         expect result: Pcell switch, IFHO trigger from C12 to C1
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=2 scell=1 scell_rsrp=116
    ...           C1 a1ThresholdScellAddssbrsrpTDD < C1 a1ThresholdPCellSwitchSsbRsrp
    ...          C1 add C2 automatically
    ...         c. C2 A2 measurement report for scell release is triggered, rsrp value lower than a2MeasSCellRelSsbRsrp
    ...         expect result: scell C2 release
    ...           command:ue_measurement_send_nr id=81 event=A2 meas_id=5 scell=1 scell_rsrp=20
    ...         d. scell addition trigger, as A1 measurement report for C1 RSRP higher than a1ThresholdSCellAddSsbRsrpFDD.
    ...         expect result: C1 add C12 for TDD-FDD 2CC CA success
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=6 srsrp_nr=96
    ...         e. C1 A2 measurement report for Pcell switch is triggered,
    ...            rsrp value lower than a2ThresholdPCellSwitchSsbRsrp(cell12)
    ...         expect result: Pcell switch, IFHO trigger from C1 to C12
    ...           command:ue_measurement_send_nr id=81 event=A2 meas_id=8 srsrp_nr=11 srsrq_nr=11 scell=1 scell_rsrp=68 scell_rsrq=68
    ...          C12 add C11 C13 automatically
    ...         f. C13 A2 measurement report for scell release is triggered, rsrp value lower than a2MeasSCellRelSsbRsrp
    ...         expect result: scell C13 release
    ...           command:ue_measurement_send_nr id=81 meas_id=12 event=A2 scell=2 scell_rsrp=34
    ...         g. C12 A1 measurement report for scell change is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD
    ...         expect result: scell change from C11 to C1
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=13 srsrp_nr=103
    [Tags]    QC_128182    Ye Selena
    SA UE Attach to Cell    12    1    1
    Scell_1 Added Based On high Rsrp
    PCELL switch from cell12 to cell1 by A1 Based On high Rsrp and add scell_2
    Release Scell    1    2
    Scell_12 Added Based On mid Rsrp
    PCELL switch from cell1 to cell12 by A2 Based On high Rsrp and add scell_11_13
    Release Scell    2    13
    change scell_11 to scell_1 by A1

CB008015-ET-C12_C_B5_SA Mobility based on rsrp involving two TDD cells with different coverage_3
    [Documentation]
    ...    1. The purpose of this test case is to check US CB008015-C_B5: Mobility based on rsrp involving two TDD cells
    ...       with different coverage-configuration 3 -SA.
    ...       SA UE 81: support n66+n71;n71+n41;n66+n41;n66+n78; n41+n78;n71+n78;n66+n66+n71 CA
    ...       Final order in cell 1 > cell 2 > cell 11+ cell 13 > cell 12 > cell 13 > cell 11
    ...       Final order in C1 > C2 > C11+ C13 > C12 > C13 > C11
    ...    2. Test Case Steps:
    ...         a. UE81 are attached in C12. And covBasedA1 SCell addition is triggered
    ...          rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD(C12) for SA UE-1
    ...         expect result: SA UE81 will add C1 for FDD-TDD 2CC CA.
    ...           ue_change_location id=81 enb=2 cell=12
    ...           ue_register id=81
    ...           set_pdu_param ue=81 pdu=1 trf_type=internal
    ...           ue_pdu_session_setup pdu=1 ue=81 nwslice=1 gw=1
    ...           trf_data_start ue=81 pdu=1 qfi=1 dir=ul mbps=20
    ...           trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=100
    ...           bearer_stats ue=81 pdu=1 qfi=1 dir=dl
    ...           bearer_stats ue=81 pdu=1 qfi=1 dir=ul
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=1 srsrp_nr=101
    ...         b. C1 A1 measurement report for Pcell switch is triggered,
    ...         rsrp value higher than a1ThresholdPCellSwitchSsbRsrp(C1)
    ...         expect result: Pcell switch, IFHO trigger from C12 to C1
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=2 scell=1 scell_rsrp=106
    ...           C1 a1ThresholdScellAddssbrsrpFDD < C1 a1ThresholdPCellSwitchSsbRsrp < C1 a1ThresholdScellAddssbrsrpTDD
    ...          C1 add C12 automatically
    ...         c. C4 A1 measurement report for scell change is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD
    ...         expect result: scell change from C12 to C2
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=7 srsrp_nr=112
    ...         d. C2 A2 measurement report for scell release is triggered, rsrp value lower than a2MeasSCellRelSsbRsrp
    ...         expect result: C1 scell C2 release
    ...           command:ue_measurement_send_nr id=81 event=A2 meas_id=8 scell=2 scell_rsrp=89
    ...         e. scell addition trigger, as A1 measurement report for C1 RSRP higher than a1ThresholdSCellAddSsbRsrpFDD
    ...         expect result: C1 scell addition scell C12 successfully
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=9 srsrp_nr=86
    ...         f. C1 A1 measurement report for scell change is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD
    ...         expect result: scell change from C12 to C2
    ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=12 srsrp_nr=112
    ...         g. C2 A2 measurement report for scell release is triggered, rsrp value lower than a2MeasSCellRelSsbRsrp
    ...         expect result: scell C2 release.
    ...           command:ue_measurement_send_nr id=81 event=A2 meas_id=13 scell=2 scell_rsrp=89
    ...         h. C1 A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD,
    ...         lower than a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...         expect result: C1 scell addition scell C12 successfully
     ...           command:ue_measurement_send_nr id=81 event=A1 meas_id=14 srsrp_nr=86
    ...         i. C1 A2 measurement report for Pcell switch is triggered, rsrp value lower than a2ThresholdPCellSwitchSsbRsrp
    ...         expect result: Pcell switch, IFHO trigger from C1 to C12
    ...           command:ue_measurement_send_nr id=81 event=A2 meas_id=16 srsrp_nr=11 srsrq_nr=11 scell=1 scell_rsrp=68 scell_rsrq=68
    ...          C12 add C11 C13 automatically
    ...         j. C12 A2 scell release trigger
    ...         expect result: scell C11 and C13 release one by one
    ...           command:ue_measurement_send_nr id=81 meas_id=20 event=A2 scell=2 scell_rsrp=34
    ...           command:ue_measurement_send_nr id=81 meas_id=19 event=A2 scell=1 scell_rsrp=14
    [Tags]    QC_128184    Ye Selena
    [Timeout]    24h
    OnlineParamChange     ${DELTA_PARAS_C12}
    SA UE Attach to Cell    12    1    1
    Scell_1 Added Based On high Rsrp
    Pcell switch from Cell12 to Cell1 by A1 and add scell_12
    change from scell_12 to scell_2 by A1
    Release Scell    2    2
    Scell_12 Added Based On mid Rsrp
    Repeat scell change
    Pcell switch from Cell1 to Cell12 by A2 and add scell_11_13
    Release Scell    2    13
    Release Scell    1    11
    Release call

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

Repeat scell change
    FOR    ${index}    IN RANGE     1    5
        scell change from Cell12 to Cell2
        Release Scell    2    2
        Scell_12 Added Based On mid Rsrp
    END

Scell_1 Added Based On high Rsrp
    Triggered Scell Addition by A1 Event    12    101    0    50
    Verify Throuput    1    400

PCELL switch from cell12 to cell1 by A1 Based On high Rsrp and add scell_2
    [Arguments]    ${scell_pci}=51    ${ue_id}=81
    ${carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
     ...    scell=1 scell_rsrp=116 scell_rsrq=0
    @{expect_value}    Create List    SCellIndex 1 activated successfully at airphone
    ...    sCellToReleaseList
    ...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.1 performed
    ...    sCellToAddModList    physCellId ${scell_pci}
    ${ret1}=    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=${expect_value}
    Verify Throuput    1    450

PCELL switch from cell1 to cell12 by A2 Based On high Rsrp and add scell_11_13
    [Arguments]    ${ue_id}=81
    ${carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=68 scell_rsrq=68
    @{expect_value}    Create List    SCellIndex 2 activated successfully at airphone
    ...    sCellToReleaseList
    ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.12 performed
    ...    sCellToAddModList    sCellToAddModList    physCellId 60    physCellId 62
    ${ret1}=    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=${expect_value}
    Verify Throuput with two scell    270

change scell_11 to scell_1 by A1
    Triggered Scell Addition by A1 Event    12    103    0    50
    Verify Throuput    2    400

Pcell switch from Cell12 to Cell1 by A1 and add scell_12
    [Arguments]    ${scell_pci}=61    ${ue_id}=81
    ${carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
     ...    scell=1 scell_rsrp=106 scell_rsrq=0
     @{expect_value}    Create List    SCellIndex 1 activated successfully at airphone
    ...    sCellToReleaseList
    ...    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.1 performed
    ...    sCellToAddModList    physCellId ${scell_pci}
    ${ret1}=    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=${expect_value}
    Verify Throuput    1    400

change from scell_12 to scell_2 by A1
    Triggered Scell Addition by A1 Event    1    112    0    51
    Verify Throuput    2    450

Scell_12 Added Based On mid Rsrp
    Triggered Scell Addition by A1 Event    1    96    0    61
    Verify Throuput    1    400

scell change from Cell12 to Cell2
    Triggered Scell Addition by A1 Event    1    112    0    51
    Verify Throuput    2    400


Pcell switch from Cell1 to Cell12 by A2 and add scell_11_13
    [Arguments]    ${ue_id}=81
    ${carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=68 scell_rsrq=68
    @{expect_value}    Create List    SCellIndex 2 activated successfully at airphone
    ...    sCellToReleaseList
    ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.12 performed
    ...    sCellToAddModList    physCellId 60    physCellId 62
    ${ret1}=    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=${expect_value}
    Verify Throuput with two scell    270


SA UE Attach To Cell
    [Arguments]    ${cell_id}    ${pdu_id}    ${gw_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Check Pcell triffice    ${pdu_id}

Check Pcell triffice
    [Arguments]    ${pdu_id}    ${ue_id}=81
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Triggered Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${srsrp_nr}    ${srsrq_nr}    ${scell_pci}=50    ${ue_id}=81    ${rrc_log_tag}=C02_scell_A1
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Start RRC Log    ${rrc_log_tag}
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...                      activated successfully at airphone
    Rrc Should Contain    sCellToAddModList    physCellId ${scell_pci}

Release Scell
    [Arguments]    ${scell_idx}    ${scell_id}    ${ue_id}=81
    ${carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_idx} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

Verify Throuput
    [Arguments]    ${scell_idx}=1    ${target_dl_throuput}=400    ${ue_id}=81    ${pdu_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_idx}
        ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0
    ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 + ${pcell_tput}/1000>${target_dl_throuput}

Verify Throuput with two scell
    [Arguments]    ${target_dl_throuput}=400    ${ue_id}=81    ${pdu_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0
    ...    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    Should Be True    ${scell1_tput}/1000 + ${scell2_tput}/1000 + ${pcell_tput}/1000>${target_dl_throuput}

Release call
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_disp
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off        UE${ue_id}: detached
