*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-SG2    owner-baijie.zhu    release-5G22R3    CB008001
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_A1ScellAddition}
...    @{MixedMode_CA}
...    @{CASupportList}
...    @{enable_bcs}
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
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp

@{MixedMode_CA}
...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
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
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3


${casl_value}
...    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{CASupportList}
...    NRDU-1:carrierAggregationSupportList=${casl_value}

@{enable_bcs}
...    NRBTS-1:actBcsCheck=enabled_FR1


@{PARAMS_TO_MODIFY_8001_A05}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed

...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=13
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed

...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=12
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:nrDcAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed

@{allowUnsuppBcOrBcs_0}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check

@{allowUnsuppBcOrBcs_2}
...    NRCELL:allowUnsuppBcOrBcs=accept unknown BCSs


@{scell_pci_ue81_1}
...    60                                  # cell11 pci is 60
...    62                                  # cell13 pci is 62

@{scell_pci_ue81_2}
...    61                                  # cell12 pci is 61
...    62                                  # cell13 pci is 62


#UE 81: support n41A+n66(2A)(known), n78A+n66(2A)(known), n41A+n78A(known), supportedBandwidthCombinationSet to BCS4(Unknown)
${Capa_UE81}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A081074824
...    06D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B26
...    2AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C
...    788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE36236B04610D04083E50480AAD931561439F11C78C000000000
...    00000000000E1E027FFC00001FFF00000110001C00158B850001C41000E208000020B7C4000000001C0468051013602086A01100C4810206
...    C73E00050119E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010000
...    08008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019C
...    A9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA480
...    80002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574A
...    AAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A0500060808
...    0600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040
...    300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680


#UE 81_2: support n41A+n66A+n71A(known), n66A+n71A+n78A(known), n41A+n78A(known), supportedBandwidthCombinationSet to BCS3(Unknown)
${Capa_UE81_2}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF88E3D03
...    3EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0003801C0A83620EB04610D04083C40232B64C55890E7D813E238F1891C790E7D47
...    3E618F28581C0E1E13FB000000FEC0000003801C0AA3626EB04610D04083A40230B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00
...    FFC007003FF0001C00E0541B11B582308682041E201195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000001C00E
...    000AC5C28000E208007118000010586200E0234028809B010415088062408103639F0002808CF40B00F000A070300E0600A80E000C0480080C07C1
...    20040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000400200
...    0024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A08
...    0000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA4808000
...    5CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F14045E02540A05028140A05028
...    140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C0
...    2004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C
...    1680


${ue_id_81}    81


&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=124850

*** Test Cases ***
CB008001-ET-A005_Verify_BC_Accepted_when_UE_report_known_interBand2CC_with_unknown_BCS_after_allowUnsuppBcOrBcs_onlineChanged_2UE_SA_based
    [Documentation]
    ...    [CB008001-A05]
    ...    1. The purpose of this test case is to check 3CC CA successful when allowUnsuppBcOrBcs online change
    ...       and UE report Contiguous interBand with unknown BCs
    ...       UE 81: support n41A+n66(2A)(known), n78A+n66(2A)(known), n41A+n78A(known), supportedBandwidthCombinationSet to BCS4(Unknown)
    ...    2. Test Configuration:
    ...       NRCELL-1(TDD, n41A, 60M)
    ...       NRCELL-1/NRREL-1(cell11: FDD, n66A, 10M)
    ...       NRCELL-1/NRREL-2(cell12: FDD, n71A, 15M)
    ...       NRCELL-1/NRREL-3(cell13: FDD, n66A, 20M)
    ...    3. Test Case Steps:
    ...         step1. set actBcsCheck=enabled_FR1 and allowUnsuppBcOrBcs=complete BCS check
    ...                Make SA UE-81 attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:no A1 meas config in RRC Reconfig since unknown BCS
    ...         step2. Release SA UE-81
    ...         Expected Results:Call release successfully
    ...         step3. set allowUnsuppBcOrBcs=accept unknown BCSs
    ...                Make SA UE-81 attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig
    ...         step4. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell11 and Cell13 are added as scell. Cell1+cell11+cell13 n41A+n66(2A) 3CC CA successful
    ...         step5. Release SA UE-81
    ...         Expected Results:Call release successfully
    ...    [CB008001-A12]
    ...    1. The perpose of this test case is to check 3CC CA not successful when actBcsCheck enabled_FR1
    ...       and UE report known interBand3CC with unknown BCS
    ...       UE 81: support n41A+n66A+n71A(known), n66A+n71A+n78A(known), n41A+n78A(known), supportedBandwidthCombinationSet to BCS3(Unknown)
    ...       n41A+n66A+n71A's bcs has supported 4 and 5 from 3GPP 38.101-1 documents.
    ...    2. Test Configuration:
    ...       NRCELL-1(TDD, n41A, 60M)
    ...       NRCELL-1/NRREL-1(cell11: FDD, n66A, 10M)
    ...       NRCELL-1/NRREL-2(cell12: FDD, n71A, 15M)
    ...       NRCELL-1/NRREL-3(cell13: FDD, n66A, 20M)
    ...    3. Test Case Steps:
    ...         step1. follow A05, set actBcsCheck=enabled_FR1 and allowUnsuppBcOrBcs=accept unknown BCSs
    ...                Make SA UE-81 attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig
    ...         step2. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell12 and Cell13 are added as scell. Cell1+cell12+cell13 n41A+n71A+n66A 3CC CA successful
    ...         step3. Release SA UE-81
    ...         Expected Results:Call release successfully
    ...         step4. set allowUnsuppBcOrBcs=complete BCS check
    ...                Make SA UE attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:no A1 meas config in RRC Reconfig since unknown BCS
    ...         step5. Release SA UE-81
    ...         Expected Results:Call release successfully
    [Tags]    CB008001-A05    QC_134688
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_8001_A05}
    Check No A1 Meas Config When Complete BCS Check    ue_id=${ue_id_81}    pcell_id=1
    Check A1 Meas Config And Scell Addtion When Accept Unknown BCSs    ue_id=${ue_id_81}    pcell_id=1    scell_pci=${scell_pci_ue81_1}
    Update UE Capa And Check A1 Meas Config For Different AllowUnsuppBcOrBcs Settings
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Param    set_cell id=12 gnb=2 nr_arfcn=134020:124820 gscn=1561
    Update Cfg Param    set_cell id=14 gnb=2 nr_arfcn=136380:127180 gscn=1589
    ${ue81_cmd}=    Catenate    set_ue simulated id=${ue_id_81} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645481 enb=2 cell=11 mode=nr
    Update Cfg    ${ue81_cmd}
    Update Cfg    ue_param id=${ue_id_81} ue_nr_capabilities=${Capa_UE81}

Change UE Location
    [Arguments]    ${ue_id}    ${target_cell}
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}    location
    Should Contain Any    ${ret}    location updated    already there

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

Check No A1 Meas Config
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    fail_regexp=EventA1

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

Check No A1 Meas Config When Complete BCS Check
    [Arguments]    ${ue_id}    ${pcell_id}
    Delta Commission Parameters    ${allowUnsuppBcOrBcs_0}
    Change UE Location    ue_id=${ue_id}    target_cell=${pcell_id}
    UE Attach and Start L3 Call    ue_id=${ue_id}
    Check No A1 Meas Config    ue_id=${ue_id}
    Release Ues    ue_id=${ue_id}

Check A1 Meas Config And Scell Addtion When Accept Unknown BCSs
    [Arguments]    ${ue_id}    ${pcell_id}    ${scell_pci}
    Delta Commission Parameters    ${allowUnsuppBcOrBcs_2}
    Change UE Location    ue_id=${ue_id}    target_cell=${pcell_id}
    UE Attach and Start L3 Call    ue_id=${ue_id}
    Check A1 Meas Config And Scell Addtion    ue_id=${ue_id}    pcell_id=${pcell_id}    scell_pci=${scell_pci}
    Release Ues    ue_id=${ue_id}

Update UE Capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Update UE Capa And Check A1 Meas Config For Different AllowUnsuppBcOrBcs Settings
    Update UE Capa    ${Capa_UE81_2}
    Check A1 Meas Config And Scell Addtion When Accept Unknown BCSs    ue_id=${ue_id_81}    pcell_id=1    scell_pci=${scell_pci_ue81_2}
    Check No A1 Meas Config When Complete BCS Check    ue_id=${ue_id_81}    pcell_id=1


