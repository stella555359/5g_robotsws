*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG2    owner-yili.chen@nokia-sbell.com    release-5G22R2    CB008015
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{CB008015}    @{5GC001390}    @{CB006138}    @{CB002}

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa

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
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly

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
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
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
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly

...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actFdmScheduling=true

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=1 beam

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
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
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
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
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
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
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
...    NRCELL-13/NRREL-10:sCellOperationalMode=dlOnly

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
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
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
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
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
...    NRCELL-12/NRREL-10:sCellOperationalMode=dlOnly
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
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly

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

@{CB002}
...    MRBTS-1/NRBTS-1/NRCELL:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL:a1MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL:a2MeasSCellRelEnabled=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL:a1MeasSCellAddEnabled=rsrpCombined
...    MRBTS-1/NRBTS-1/NRCELL:a2MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL:a1MeasPCellSwitchEnabled=rsrpCombined
...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    MRBTS-1/NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    MRBTS-1/NRBTS-1:actInterFreqIntraGnbMobilityNSA=true

...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrp=30
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:a5MeasEnabled=none

...    NRCELL-12/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-3:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-12/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-3:ssbFrequency=518910
...    NRCELL-12/NRHOIF-3:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-3:thresholdPCellSwitchTargetRsrp=30
...    NRCELL-12/NRHOIF-3:thresholdPCellSwitchTargetRsrq=30

*** Test Cases ***
CB008015-ET-CB02_CB_B1_NSA Mobility based on rsrpCombined involving two TDD cells with same coverage
    [Documentation]
    ...    1. The purpose of this test case is to verify  Mobility based on rsrp involving two TDD cells with same coverage -NSA
    ...       - Mixed mode of FDD-FR1 TDD CA and FDD-FDD CA
    ...       UE 81-83: support n66+n71; n71+n41; n66+n41; n66+n78; n41+n78; n71+n78; n66+n66+n71 CA (FullCap)
    ...       Final selection order in cell 1 > cell 2 > (cell 12 + cell 13) > cell 13 > cell 12
    ...    2. Test Case Steps:
    ...         Precondition: NRCELL-12: a1MeasSCellAddEnabled: rsrpCombined
    ...         Step 1. Attach NSA UE-1 to the LTE cell and initiates EN-DC toward the NR Cell.
    ...         Expected Result:  NSA call setup in  cell 12 successfully
    ...         Step 2. NSA UE-1 A1 measurement report based SCell addition triggered, rsrp value higher than ThresholdSCellAddSsbRsrpTDD,
    ...                 RSRQ value lower than a1ThresholdSCellAddSsbRsrq
    ...         Expected Result:  no scell addition trigger
    ...         Step 3. NSA UE-1 A1 measurement report based SCell addition triggered, rsrp value higher than ThresholdSCellAddSsbRsrpTDD.
    ...                 RSRQ value higher than a1ThresholdSCellAddSsbRsrq for NSA UE-1
    ...         Expected Result: NSA UE-1 will add cell 1 for FDD-TDD 2CC CA
    ...         Step 4. NSA UE-1 A1 measurement report for Pcell switch to Cell 1 is triggered, rsrp value higher than a1ThresholdPCellSwitchSsbRsrp,
    ...                 RSRQ value lower than a1ThresholdSCellAddSsbRsrq
    ...         Expected Result: no Pcell switch trigger
    ...         Step 5. NSA UE-1 A1 measurement report for Pcell switch to Cell 1 is triggered, rsrp value higher than a1ThresholdPCellSwitchSsbRsrp.
    ...                 RSRQ value higher than a1ThresholdSCellAddSsbRsrq
    ...         Expected Result: Pcell switch, IFHO trigger from Cell 12 to cell 1
    ...                          Scell addition trigger, as A1 measurement report for RSRP higher than a1ThresholdSCellAddSsbRsrpTDD,
    ...                          it is used for Scell addition directly.
    ...         Expected Result: Scell addition cell 2 successfullly.
    ...         Step 7. Cell 1 A2 measurement report for mobility is triggered
    ...         Expected Result: measurement gap setup
    ...         Step8. Release the call.
    ...         Expected Result: SA call release successfully
    [Tags]    QC_128185
    Ue Register And ENDC Setup At FDD Cell-12
    scell addition failure due to RSRQ value too low
    scell addition
    Pcell switch failure due to RSRQ value too low
    Pcell switch
    measurement gap setup and detach UE

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Ue Register And ENDC Setup At FDD Cell-12
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

scell addition failure due to RSRQ value too low
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=2 event=A1 srsrp_nr=115 srsrq_nr=110    timeout=5s
    Should Not Contain    ${ret1}    SCellIndex 9 activated successfully at airphone

scell addition
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=2 event=A1 srsrp_nr=115 srsrq_nr=125
    ...    SCellIndex 9 activated successfully at airphone
    Should Contain    ${ret1}    physCellId 50
    Send And Verify Throuput

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=3    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=4    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=5    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=30s

Verify Throuput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>190

Pcell switch failure due to RSRQ value too low
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
	${a1_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=518910    event_type=A1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 event=A1 meas_id=${a1_measid} srsrp_nr=0 srsrq_nr=0 scell=9 scell_rsrp=115 scell_rsrq=35    timeout=5s
    Should Not Contain    ${ret1}    SCellIndex 9 activated successfully at airphone

Pcell switch
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
	${a1_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=518910    event_type=A1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 event=A1 meas_id=${a1_measid} srsrp_nr=0 srsrq_nr=0 scell=9 scell_rsrp=115 scell_rsrq=125
    ...    SCellIndex 9 activated successfully at airphone
    Should Contain    ${ret1}    physCellId 51
    Verify Throuput    sleep_time=30s

measurement gap setup and detach UE
    Execute Egate Command    ue_meas_cfg_disp id=91 meas_obj_type=nr    NR MEASUREMENT IDENTITIES
    Execute Egate Command    ue_enb_param id=91 measurement_gap=gp0:12 gap_trigger=gnb_triggered
	${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=518910    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${a2_measid} event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0    Sending SgNB Modification Confirm
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    measGapConfig setup
    Execute Egate Command    ue_detach id=91    detached
