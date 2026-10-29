*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG2    owner-yili.chen@nokia-sbell.com    release-5G22R2    CB008015    CB007873_EA
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{CB008015}    @{5GC001390}    @{CB006138}    @{CB004}

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa
${SOS_REPORT_FLAG}    pass:False,fail:False

@{CB008015}
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-1:actBeamforming=false
...    NRBTS-1/NRCELL-2:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:basicBeamSet=beamSet_1
...    NRBTS-1/NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-2:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-2:actBeamforming=false
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB

...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    NRDU-1:actConnectedModeMobilityCA=true

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false

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
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:removeNotAllowed=false

...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actFdmScheduling=true

...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly

...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
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
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:removeNotAllowed=false

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
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
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
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
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none

@{CB004}
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchEnabled=rsrpAndRsrq
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=35
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2TimeToTriggerPCellSwitchSsbRsrq=480ms
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2ThresholdPCellSwitchSsbRsrq=35
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2HysteresisPCellSwitchSsbRsrq=0
...    NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrq:pCellSwitchOffsetSsbRsrq=0
...    NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrq:a1TimeToTriggerPCellSwitchSsbRsrq=480ms
...    NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrq:a1HysteresisPCellSwitchSsbRsrq=0
...    NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrq:a1ThresholdPCellSwitchSsbRsrq=35
...    NRBTS-1/NRCELL-1:a1MeasPCellSwitchEnabled=rsrpAndRsrq

...    NRCELL-2:weightForSCellSelection=40
...    NRCELL-1:weightForSCellSelection=40

...    NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrq:a1TimeToTriggerPCellSwitchSsbRsrq=480ms
...    NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrq:a1HysteresisPCellSwitchSsbRsrq=0
...    NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrq:a1ThresholdPCellSwitchSsbRsrq=35
...    NRBTS-1/NRCELL-2:a1MeasPCellSwitchEnabled=rsrpAndRsrq

...    NRCELL-13:weightForSCellSelection=100
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a2MeasReleaseEnabled=rsrpAndRsrq

...    NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrq:a1TimeToTriggerPCellSwitchSsbRsrq=480ms
...    NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrq:a1HysteresisPCellSwitchSsbRsrq=0
...    NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrq:a1ThresholdPCellSwitchSsbRsrq=35
...    NRBTS-1/NRCELL-12:a1MeasPCellSwitchEnabled=rsrpAndRsrq

...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ssbFrequency=518910
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true

...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10

...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ssbFrequency=126750
...    NRCELL-1/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=30
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz

@{disable_1765}
...    NRCELL-11:a2MeasSCellRelEnabled=none
...    NRCELL-12:a2MeasSCellRelEnabled=none

*** Test Cases ***
CB008015-ET-CB04_CB_B2_NSA Mobility based on rsrpAndRsrq involving two TDD cells with different coverage
    [Documentation]
    ...    1. The purpose of this test case is to check NSA call Pcell switch is correct
    ...    UE 91
    ...    Final weight order in (cell 11+ cell 13) > cell 1 > cell 2 = cell 13 >cell 11 of cell 12 is P(S) cell
    ...    actHoOptimizationCa=false
    ...    2. Test Case Steps:
    ...       a.Attach NSA UE91 to the LTE cell and initiate EN-DC toward the NR cell.
    ...       b.check A1 meas config in RRC Reconfig
    ...       c.cell12 A1 measurement report based SCell addition is triggered, rsrp value lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...       rsrq value higher than a1ThresholdSCellAddSsbRsrq for NSA UE91,it will base rsrq value select scell
    ...       d.check A1 meas config in RRC Reconfig
    ...       e.cell1 A1 measurement report for Pcell switch is triggered, rsrp value lower than a1ThresholdPCellSwitchSsbRsrp,
    ...       rsrq value higher than a1ThresholdPCellSwitchSsbRsrq
    ...       f.check A1 meas config in RRC Reconfig
    ...       g.cell1 A1 measurement report based SCell addition is triggered, rsrp value higher than ThresholdSCellAddSsbRsrpTDD,
    ...       rsrq value lower than a1ThresholdPCellSwitchSsbRsrq, it will base rsrp value select scell
    ...       h.Verify_Scell_Release_Initial_Setup_No_Response_From_UE
    ...       i.Verify_scell_release_initial_setup_after_1765_disabled
    ...    3. Expected Results:
    ...       Step c: cell1 is added as FDD-FR1 TDD 2CC CA,A1 measurement is deactivated after SCell addition is done
    ...       Step e: Pcell switch is successfully from cell12 to cell1
    ...       Step g: cell2 is added as TDD-FR1 TDD 2CC CA,A1 measurement is deactivated after SCell addition is done
    [Tags]    QC_128186
    cell12 A1 A1 Ue Register And ENDC Setup At FDD Cell-12
    cell12 scell addition when rsrp too lower and rsrq high enough
    cell1 A1 Pcell switch when rsrp too lower and rsrq high enough
    cell1 A1 measurement report based SCell addition
    A2 scell release
    Ue Register And Pdu Session Setup At FDD Cell-11
    Scell addition succeed and release failed
    Ue Register And Pdu Session Setup At FDD Cell-11
    7873 EA04 scell release

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

cell12 A1 A1 Ue Register And ENDC Setup At FDD Cell-12
    Execute Egate Command    ue_attach id=91    UE IS ACTIVE
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=91 target_gnb=2 target_cells=12 bearer=2 type=split_scg    Sending SgNB Modification Confirm
    Should Contain    ${ret1}    value SgNBAdditionRequest
    Should Contain    ${ret1}    value SgNBAdditionRequestAcknowledge
    Should Contain    ${ret1}    rrcConnectionReconfiguration
    Should Contain    ${ret1}    value RRCReconfiguration
    Should Contain    ${ret1}    rrcConnectionReconfigurationComplete
    Should Contain    ${ret1}    value SgNBReconfigurationComplete
    Should Contain    ${ret1}    value SNStatusTransfer

cell12 scell addition when rsrp too lower and rsrq high enough
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=2 event=A1 srsrp_nr=50 srsrq_nr=120    SCellIndex 9 activated successfully at airphone
    Should Contain    ${ret1}    physCellId 50

cell1 A1 Pcell switch when rsrp too lower and rsrq high enough
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    ${a1_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=518910    event_type=A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=91 event=A1 meas_id=${a1_measid} srsrp_nr=0 srsrq_nr=0 scell=9 scell_rsrp=30 scell_rsrq=50
    ...    value SgNBModificationConfirm

cell1 A1 measurement report based SCell addition
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    ${a1_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=518910    event_type=A1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${a1_measid} event=A1 srsrp_nr=120 srsrq_nr=80
    ...    SCellIndex 9 activated successfully at airphone
    Should Contain    ${ret1}    physCellId 51

A2 scell release
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    ${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=633216    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${a2_measid} event=A2 scell=9 scell_rsrp=20 scell_rsrq=20
    ...    Sending SgNB Modification Confirm


Ue Register And Pdu Session Setup At FDD Cell-11
    Execute Egate Command    ue_location_change id=81 enb=2 cell=11
    Execute Egate Command    ue_register id=81    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=81 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=81 pdu=1 gw=2 nwslice=1    pass_regexp=QoS Routing Table

Scell addition succeed and release failed
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    ${a1_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=424090    event_type=A1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${a1_measid} event=A1 srsrp_nr=50 srsrq_nr=120    SCellIndex 2 activated successfully at airphone
    Should Contain    ${ret1}    physCellId 61
    Should Contain    ${ret1}    physCellId 62
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    Execute Egate Command    ue_nr_rrc_reconf_param id=81 if_contains=any action=drop
    ${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=126750    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${a2_measid} event=A2 scell=1 scell_rsrp=40    UE CONTEXT RELEASE COMPLETE
    Should Contain    ${ret1}    physCellId 61
    Should Contain    ${ret1}    Hit on error cases presence=any action=drop
    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off

disable feature 1765
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be OnAir

7873 EA04 scell release
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    sleep    1s
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=2 event=A1 srsrp_nr=50 srsrq_nr=120    SCellIndex 2 activated successfully at airphone
    Should Contain    ${ret1}    physCellId 61
    Should Contain    ${ret1}    physCellId 62
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    sleep    1s
    disable feature 1765    ${disable_1765}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=5 event=A2 scell=1 scell_rsrp=40    rrcReconfigurationComplete
    Should Contain    ${ret1}    physCellId 61
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=6 event=A2 scell=2 scell_rsrp=40    rrcReconfigurationComplete
    Should Contain    ${ret1}    physCellId 62
    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off    detached
