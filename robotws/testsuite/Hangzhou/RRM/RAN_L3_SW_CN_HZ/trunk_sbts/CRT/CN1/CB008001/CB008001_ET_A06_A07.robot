*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...    team-SG2    owner-baijie.zhu    owner-jianfen.shen    release-5G22R3    CB008001
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_A1ScellAddition}
...    @{MixedMode_CA}
...    @{2T4F_N71_2A}
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
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent

@{MixedMode_CA}
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
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
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
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

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
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
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
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
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
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=14
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
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

@{2T4F_N71_2A}
...    NRCELL-12:gscnOrSsPbchArfcn=1561
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124820
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134020
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1589
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136380
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz

${casl_value}
...    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
@{CASupportList}
...    NRDU-1:carrierAggregationSupportList=${casl_value}

@{allowUnsuppBcOrBcs_1}
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
@{allowUnsuppBcOrBcs_2}
...    NRCELL:allowUnsuppBcOrBcs=accept unknown BCSs
@{enable_bcs}
...    NRBTS-1:actBcsCheck=enabled_FR1

@{scell_pci_ue81_1}
...    62                                  # cell13 pci is 62
@{scell_pci_ue81_2}
...    63                                  # cell14 pci is 63
@{scell_pci_ue82_1}
...    51                                  # cell2 pci is 51
...    60                                  # cell11 pci is 60
@{scell_pci_ue82_2}
...    50                                  # cell1 pci is 50
...    61                                  # cell12 pci is 61

#UE 81: support n66(2A)(known), n71(2A)(known), supportedBandwidthCombinationSet to BCS3(Unknown)
${Capa_UE81}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000
...    0B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD9315
...    62439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE0000016001C00258788C001C4600000616F880000002C3C41000E208000030B7C4000000001C046
...    8051013602083A0D80A14489B1C8810A040D8E440003810C60F413003C00281C1401C0C01D00E000C0480080C07C12004000000020000040100000000800001004000010
...    0200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14
...    AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB2920
...    2000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F14141
...    78095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100202018030080600C10100C018040300610080100202018
...    030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

#UE 82: support n41A+n66A+n78A(known), n41A+n71A+n78A(known), supportedBandwidthCombinationSet to BCS3(Unknown)
${Capa_UE82}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000
...    0B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571B11B582308682041F280C2AB64C5
...    5850E7C471E300000000000000000006387809FFF000007FFC000002C0038004B17134003882001C2800000816F880000002C5C4D000E2300070A00000205BE200000000
...    0E0234028809B01041D07C051204081B1CF811204081B1CF80001C086307A09801E00140E0A00E0600E80700060240040603E09002000000010000020080000000400000
...    802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000812048020000300CE5
...    4D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040
...    001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A935
...    55078A0A0BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080108080100402018030804008010100C018040300608080600C020180308040
...    08010100C018040080110080600C02018030080600C10100200804008021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${ue_id_81}    81
${ue_id_82}    82

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=124850

*** Test Cases ***
CB008001-ET-A006_Verify_BC_Accepted_when_UE_report_known_nonContiguous_intraBand2CC_with_unknownBCS_after_allowUnsuppBcOrBcs_Changed_SA_based
    [Documentation]
    ...    1. The purpose of this test case is to 2CC CA successful when actBcsCheck enable
    ...       and UE report nonContiguous intraBand with unknown BCS
    ...       UE 81: support n66(2A)(known), n71(2A)(known), supportedBandwidthCombinationSet to BCS3(Unknown)
    ...    2. Test Configuration:
    ...       NRCELL-11(FDD, n66A, 10M)
    ...       NRCELL-11/NRREL-2(cell13: FDD, n66A, 20M)
    ...       NRCELL-11/NRREL-10(cell2: TDD, n78A, 50M)
    ...       NRCELL-11/NRREL-1(cell1: TDD, n41A, 60M)
    ...       NRCELL-11/NRREL-3(cell12: FDD, n71A, 10M)
    ...       NRCELL-12(FDD, n71A, 10M)
    ...       NRCELL-12/NRREL-3(cell14: FDD, n71A, 10M)
    ...       NRCELL-12/NRREL-10(cell2: TDD, n78A, 50M)
    ...       NRCELL-12/NRREL-1(cell1: TDD, n41A, 60M)
    ...       NRCELL-12/NRREL-2(cell11: FDD, n66A, 10M)
    ...    3. Test Case Steps:
    ...         step1. set allowUnsuppBcOrBcs=accept unknown band combinations
    ...                Make SA UE-81 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:no A1 meas config in RRC Reconfig since unknown BCS
    ...         step2. Release SA UE-81
    ...         Expected Results:Call release successfully
    ...         step3. set allowUnsuppBcOrBcs=accept unknown BCSs
    ...                Make SA UE-81 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig
    ...         step4. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell13 is added as scell. Cell11+cell13 n66(2A) 2CC CA successful
    ...         step5. Release SA UE-81
    ...         Expected Results:Call release successfully
    ...         step6. set allowUnsuppBcOrBcs=accept unknown band combinations
    ...                Make SA UE-81 attach to cell 12, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:no A1 meas config in RRC Reconfig since unknown BCS
    ...         step7. Release SA UE-81
    ...         Expected Results:Call release successfully
    ...         step8. set allowUnsuppBcOrBcs=accept unknown BCSs
    ...                Make SA UE-81 attach to cell 12, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig
    ...         step9. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell14 is added as scell. Cell12+cell14 n71(2A) 2CC CA successful
    ...         step10. Release SA UE-81
    ...         Expected Results:Call release successfully
    [Tags]    CB008001-A06    QC_134694
    Delta Commission Parameters    ${enable_bcs}
    Check No A1 Meas Config When Accept Unknown Band Combinations    ue_id=${ue_id_81}    pcell_id=11
    Check A1 Meas Config And Scell Addtion When Accept Unknown BCSs    ue_id=${ue_id_81}    pcell_id=11    scell_pci=${scell_pci_ue81_1}
    Check No A1 Meas Config When Accept Unknown Band Combinations    ue_id=${ue_id_81}    pcell_id=12
    Check A1 Meas Config And Scell Addtion When Accept Unknown BCSs    ue_id=${ue_id_81}    pcell_id=12    scell_pci=${scell_pci_ue81_2}
    Release Ues    ue_type=all

CB008001-ET-A007_Verify_BC_Accepted_when_UE_report_known_interBand3CC_after_allowUnsuppBcOrBcs_onlineChanged_SA_based
    [Documentation]
    ...    1. The purpose of this test case is to 3CC CA successful when actBcsCheck enabled_FR1
    ...       and UE report known interBand 3CC Combination
    ...       UE 82: support n41A+n66A+n78A(known), n41A+n71A+n78A(known), supportedBandwidthCombinationSet to BCS3(Unknown)
    ...    2. Test Configuration:
    ...       NRCELL-1(TDD, n41A, 60M)
    ...       NRCELL-1/NRREL-1(cell2: TDD, n78A, 50M)
    ...       NRCELL-1/NRREL-2(cell11: FDD, n66A, 10M)
    ...       NRCELL-2(TDD, n78A, 50M)
    ...       NRCELL-2/NRREL-1(cell1: TDD, n41A, 60M)
    ...       NRCELL-2/NRREL-2(cell12: FDD, n71A, 10M)
    ...    3. Test Case Steps:
    ...         step1. set allowUnsuppBcOrBcs=accept unknown BCSs
    ...                Make SA UE-82 attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig since band combinations
    ...         step2. Release SA UE-82
    ...         Expected Results:Call release successfully
    ...         step3. set allowUnsuppBcOrBcs=accept unknown band combinations
    ...                Make SA UE-82 attach to cell 1, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:No A1 meas config in RRC Reconfig Since BCS is unknown
    ...         step4. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell2 and cell11 are added as scell. Cell1+cell2+cell11 n41A+n78A+n66A 3CC CA successful
    ...         step5. Release SA UE-82
    ...         Expected Results:Call release successfully
    ...         step6. set allowUnsuppBcOrBcs=accept unknown BCSs
    ...                Make SA UE-82 attach to cell 2, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:A1 meas config in RRC Reconfig
    ...         step7. Release SA UE-82
    ...         Expected Results:Call release successfully
    ...         step8. set allowUnsuppBcOrBcs=accept unknown band combinations
    ...                Make SA UE-82 attach to cell 2, start data transfer, check A1 meas config in RRC Reconfig
    ...         Expected Results:No A1 meas config in RRC Reconfig Since BCS is unknown
    ...         step9. A1 measurement report based SCell addition is triggered
    ...         Expected Results:Cell1 and cell12 are added as scell. Cell2+cell1+cell12 n78A+n41A+n71A 3CC CA successful
    ...         step10. Release SA UE-82
    ...         Expected Results:Call release successfully
    [Tags]    CB008001-A07    QC_134695
    Delta Commission Parameters    ${enable_bcs}
    Check A1 Meas Config And Scell Addtion When Accept Unknown BCSs    ue_id=${ue_id_82}    pcell_id=1    scell_pci=${scell_pci_ue82_1}
    Check No A1 Meas Config When Accept Unknown Band Combinations    ue_id=${ue_id_82}    pcell_id=1
    Check A1 Meas Config And Scell Addtion When Accept Unknown BCSs    ue_id=${ue_id_82}    pcell_id=2    scell_pci=${scell_pci_ue82_2}
    Check No A1 Meas Config When Accept Unknown Band Combinations    ue_id=${ue_id_82}    pcell_id=2
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

Check No A1 Meas Config When Accept Unknown Band Combinations
    [Arguments]    ${ue_id}    ${pcell_id}
    Delta Commission Parameters    ${allowUnsuppBcOrBcs_1}
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
