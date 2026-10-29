*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-SG2    owner-baijie.zhu    owner-jianfen.shen    release-5G22R3    CB008001
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_A1ScellAddition}
...    @{MixedMode_CA}
...    @{CASupportList}
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=49|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1

@{CA_A1ScellAddition}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actBcsCheck=enabled_FR1
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp

@{MixedMode_CA}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
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

...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3

${casl_value}
...    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
@{CASupportList}
...    NRDU-1:carrierAggregationSupportList=${casl_value}

@{NRRELA16}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=2
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

@{allowUnsuppBcOrBcs_0}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
@{allowUnsuppBcOrBcs_1}
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations

@{scell_pci_ue81}
...    60                                  # cell11 pci is 60
...    61                                  # cell12 pci is 61
@{scell_pci_ue82}
...    51                                  # cell2 pci is 51
...    61                                  # cell12 pci is 61

#UE 81: n41(2A)+n66A+n71A+n77A(known), supportedBandwidthCombinationSet to BCS0(known)
${Capa_UE81}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000
...    0B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD9315
...    62439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE0000016001C001593882001C28000E1400071180038980000002DF80000000007011A014404D808
...    20E82A0191020408103639F0000A0233D04C00F000A07050070300740380030120020301F048010000000080000100400000002000004010000040080000300400002002
...    00001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B2
...    66B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132
...    CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50505E02540A05028140A05
...    028140A05028140A05028140A05000020080600C0200400808010020201803008010023543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5
...    E828305A

#UE 82: n41A+n66A+n71A+n77A+n78A(unknown), supportedBandwidthCombinationSet to BCS0(known)
${Capa_UE82}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000
...    0B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD9315
...    62439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE0000016001C001593882001C28000E2680071180038980000002DF80000000007011A014404D808
...    20E82A0191020408103639F0000A0233D04C00F000A07050070300740380030120020301F048010000000080000100400000002000004010000040080000300400002002
...    00001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B2
...    66B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132
...    CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50505E02540A05028140A05
...    028140A05028140A05028140A05000020080600C0200400808010020201803008010023543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5
...    E828305A

${ue_id_81}    81
${ue_id_82}    82

&{CELLS_CARRIER_FREQ}
...     1=518910

*** Test Cases ***
CB008001-ET-A016_Verify_BC_Fallback_Accepted_when_UE_report_unknown_interBand5CC_SA_based
    [Documentation]
    ...    1. The purpose of this test case is to 5CC CA fallback to 3CC successful while UE report unknown 5 bands with known BCs
    ...       due to gnb not configurate band n77 and gnb support 3CC at most at currently
    ...       UE 81: n41(2A)+n66A+n71A+n77A(known), supportedBandwidthCombinationSet to BCS0(known)
    ...       UE 82: n41A+n66A+n71A+n77A+n78A(unknown), supportedBandwidthCombinationSet to BCS0(known)
    ...    2. Test Configuration:
    ...       NRCELL-1(TDD, n41A, 60M)
    ...       NRCELL-1/NRREL-1(cell11: FDD, n66A, 10M)
    ...       NRCELL-1/NRREL-2(cell12: FDD, n71A, 15M)
    ...       NRCELL-1/NRREL-3(cell2: TDD, n78A, 50M)
    ...    3. Test Case Steps:
    ...         step1. set actBcsCheck=enabled_FR1 and allowUnsuppBcOrBcs=complete BCS check
    ...                Make SA UE-81 attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig
    ...         step2. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell11 and Cell12 are added as scell. Cell1+cell11+cell12 n41A+n66A+n71A 3CC CA successful
    ...         step3. Release SA UE-81
    ...         Expected Results:Call release successfully
    ...         step4. set allowUnsuppBcOrBcs=accept unknown band combinations
    ...                Make SA UE-82 attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig
    ...         step5. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell2 and Cell12 are added as scell. Cell1+cell2+cell12 n41A+n78A+n71A 3CC CA successful
    ...         step6. Release SA UE-82
    ...         Expected Results:Call release successfully
    [Tags]    CB008001-A16    QC_134691
    Delta Commission Parameters    ${NRRELA16}
    Check A1 Meas Config And Scell Addtion When Complete BCS Check    ue_id=${ue_id_81}    pcell_id=1    scell_pci=${scell_pci_ue81}
    Check A1 Meas Config And Scell Addtion When Accept Unknown Band Combinations    ue_id=${ue_id_82}    pcell_id=1    scell_pci=${scell_pci_ue82}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
    #Debug Enter Into Egate

Modify Cfg
    ${ue81_cmd}=    Catenate    set_ue simulated id=${ue_id_81} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645481 enb=2 cell=11 mode=nr
    Update Cfg    ${ue81_cmd}
    Update Cfg    ue_param id=${ue_id_81} ue_nr_capabilities=${Capa_UE81}
    ${ue82_cmd}=    Catenate    set_ue simulated id=${ue_id_82} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645482 enb=2 cell=11 mode=nr
    Update Cfg    ${ue82_cmd}
    Update Cfg    ue_param id=${ue_id_82} ue_nr_capabilities=${Capa_UE82}

Change UE Location
    [Arguments]    ${ue_id}    ${target_cell}
    ${return1}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}    location
    Should Contain Any    ${return1}    location updated    already there

UE Attach and Start L3 Call
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...                      pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=5
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=5
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic


Check A1 Meas Config And Scell Addtion
    [Arguments]    ${ue_id}    ${pcell_id}    ${scell_pci}
    ${checkA1measconfig}=    Execute Egate Command      ue_meas_cfg_disp id=${ue_id}    NR REPORT CONFIGURATIONS
    Should Contain Any    ${checkA1measconfig}    EventA1: Threshold: RSRP 31    EventA1: Threshold: RSRP 111
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency
    ...           ${ue_id}    carrierfreq=${pcell_carrier_freq}    event_type=A1
    ${addScell}=    Execute Egate Command      ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    SCellIndex 1 activated successfully at airphone
    FOR    ${pci}    IN    @{scell_pci}
        Should Contain    ${addScell}    sCellToAddModList    physCellId ${pci}
    END

Check A1 Meas Config And Scell Addtion When Complete BCS Check
    [Arguments]    ${ue_id}    ${pcell_id}    ${scell_pci}
    Delta Commission Parameters    ${allowUnsuppBcOrBcs_0}
    Change UE Location    ue_id=${ue_id}    target_cell=${pcell_id}
    UE Attach and Start L3 Call    ue_id=${ue_id}
    Check A1 Meas Config And Scell Addtion    ue_id=${ue_id}    pcell_id=${pcell_id}    scell_pci=${scell_pci}
    Release Ues    ue_id=${ue_id}

Check A1 Meas Config And Scell Addtion When Accept Unknown Band Combinations
    [Arguments]    ${ue_id}    ${pcell_id}    ${scell_pci}
    Delta Commission Parameters    ${allowUnsuppBcOrBcs_1}
    Change UE Location    ue_id=${ue_id}    target_cell=${pcell_id}
    UE Attach and Start L3 Call    ue_id=${ue_id}
    Check A1 Meas Config And Scell Addtion    ue_id=${ue_id}    pcell_id=${pcell_id}    scell_pci=${scell_pci}
    Release Ues    ue_id=${ue_id}
