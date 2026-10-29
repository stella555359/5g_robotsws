*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...     owner-selena.ye    team-SG2    release-5G22R2    CB008015    SBTS00
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}    @{5GC001390}    @{CB006138}    @{CB008015}    @{SNSSAI}    @{TRACKINGAREA}    @{OPEN_BEAMFORMING}

@{5GC001390}    NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
${CA_SUPPORT_LIST}    ca_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa
@{CB008015}
...    delete:NRCELL-1:configuredEpsTac
...    delete:NRCELL-2:configuredEpsTac
...    delete:NRCELL-11:configuredEpsTac
...    delete:NRCELL-12:configuredEpsTac
...    delete:NRCELL-13:configuredEpsTac
...    delete:NRCELL-14:configuredEpsTac
...    delete:NRCELL-1:trackingAreaDN
...    delete:NRCELL-2:trackingAreaDN
...    delete:NRCELL-11:trackingAreaDN
...    delete:NRCELL-12:trackingAreaDN
...    delete:NRCELL-13:trackingAreaDN
...    delete:NRCELL-14:trackingAreaDN
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
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:lcrId=2
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:nrDcAllowed=false
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-4:gNbId=1
...    NRCELL-13/NRREL-4:gNbIdLength=22
...    NRCELL-13/NRREL-4:lcrId=2
...    NRCELL-13/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-4:removeNotAllowed=false
...    NRCELL-13/NRREL-4:nrDcAllowed=false
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:lcrId=2
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:nrDcAllowed=false
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
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
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
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
...    NRBTS-1/NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=10
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=126750
...    NRBTS-1/NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=122
...    NRBTS-1/NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=2
...    NRBTS-1/NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
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

...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=125
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=111
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=111
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=115
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=25
...    MRBTS-1/NRBTS-1/NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    MRBTS-1/NRBTS-1/NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=85
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    MRBTS-1/NRBTS-1/NRCELL-13:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=35
...    MRBTS-1/NRBTS-1/NRCELL-13:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=72

...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1/NRCELL-13/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}
...    MRBTS-1/NRBTS-1/NRCELL-13/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-11/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_3}
...    MRBTS-1/NRBTS-1/NRCELL-11/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    MRBTS-1/NRBTS-1/NRCELL-12/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    MRBTS-1/NRBTS-1/NRCELL-12/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-14/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    MRBTS-1/NRBTS-1/NRCELL-14/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100

...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-3:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-3:mnc=403
...    MRBTS-1/NRBTS-1/NRPLMN-3:mncLength=3
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true

...    MRBTS-1/NRBTS-1:actHoOptimizationCa=true
...    MRBTS-1/NRBTS-1:actRanSharing=true
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1/NRCELL-14/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    MRBTS-1/NRBTS-1/NRCELL-14/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-12/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    MRBTS-1/NRBTS-1/NRCELL-12/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-11/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_3}
...    MRBTS-1/NRBTS-1/NRCELL-11/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-13/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_2}
...    MRBTS-1/NRBTS-1/NRCELL-13/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_2}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=200

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


@{TRACKINGAREA}
...    MRBTS-1/NRBTS-1/TRACKINGAREA-100:snssaiList:snssaiDN=${SNSSAIDNLIST}
...    MRBTS-1/NRBTS-1/TRACKINGAREA-100:fiveGsTac=100
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=${SNSSAIDNLIST}
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:fiveGsTac=200
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:snssaiList:snssaiDN=${SNSSAIDNLIST}
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:fiveGsTac=300

@{SNSSAI}
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_3}    MRBTS-1/NRBTS-1/NRPLMN-1, MRBTS-1/NRBTS-1/NRPLMN-3
${NRPLMNDNLIST}
...    SEPARATOR=,
...    MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRPLMN-3
${SNSSAIDNLIST}    MRBTS-1/NRBTS-1/SNSSAI-1

@{DELTA_PARAS_C09}
...    NRBTS-1/NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRBTS-1/NRCELL-12/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRBTS-1/NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-12/NRHOIF-1:ssbFrequency=633216
...    NRCELL-2/NRREL-2:nrDcAllowed=false
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

*** Test Cases ***
CB008015-ET-C09_C_B4_SA CA mobility exploring testing interworking with RAN sharing
    [Documentation]
    ...    1. The purpose of this test case is to Mobility based on rsrp involving two TDD cells with different coverage-configuration 2
    ...       UE 81: support n66+n71; n71+n41; n66+n41; n66+n78; n41+n78; n71+n78; n66+n66+n71 CA.
    ...       SCell(s) selection order:Cell 1 > Cell 2 > (Cell 11+ Cell 13) > cell 13 > cell 11.
    ...       Cell11 assigned to PLMNSET_SA1(TAC1->slice1) and PLMNSET_SA3(TAC1->slice1) including PLMN1 and PLMN3
    ...       Cell12,2 assigned to PLMNSET_SA1(TAC1->slice1) including PLMN1
    ...       Cell13,1 assigned to PLMNSET_SA2(TAC1->slice1) including PLMN2
    ...       SCell(s) selection order with PLMN:Cell 2 > Cell 11.
    ...    2. Test Case Steps:
    ...         step1. Make SA UE-81 attach to cell 12 , start data transfer , check A1 meas config in RRC Reconfig.
    ...         step2. A1 measurement report based SCell addition is triggered, check A1 meas config in RRC Reconfig.
    ...               rsrp > a1ThresholdSCellAddSsbRsrpTDD.
    ...         Expected Results: Cell 2 is added as scell, because cell1 is PLMN2
    ...         step3. A1 measurement report for Pcell switch is triggered for cell 12,
    ...               rsrp > a1ThresholdPCellSwitchSsbRsrp
    ...         Expected Results: Pcell switch, IFHO trigger from Cell 12 to cell 2
    ...                           scell addition trigger, as A1 measurement report for cell2 RSRP higher than a1ThresholdSCellAddSsbRsrpTDD
    ...                           Cell12 is added as scell, because cell1 is PLMN2
    ...         step4. trigger A2 scell Release, check A1 meas config in RRC Reconfig
    ...                rsrp < a2MeasSCellRelSsbRsrp
    ...         Expected Results: scell cell 12 release.
    ...         step5. A1 measurement report based SCell addition is triggered, check A1 meas config in RRC Reconfig
    ...                rsrp > a1ThresholdSCellAddSsbRsrpFDD
    ...         Expected Results: Cell 12 is added as scell, because cell1 is PLMN2
    ...         step6. A2 measurement report for Pcell switch is triggered for cell 2
    ...                rsrp < a2ThresholdPCellSwitchSsbRsrp.
    ...         Expected Results: Pcell switch, IFHO trigger from Cell 2 to cell 12
    ...                           scell addition trigger, as A2 measurement report for cell2 include measurement result for scell cell12
    ...                           a1ThresholdSCellAddSsbRsrpTDD > RSRP > a1ThresholdSCellAddSsbRsrpFDD
    ...                           Cell2 is added as scell, because cell1 is PLMN2
    ...         step7. trigger A2 scell Release, check A1 meas config in RRC Reconfig.
    ...         Expected Results: scell cell 2 release.
    ...         step8. release the call for SA UE-1.
    [Tags]    QC_128183    Ye Selena
    OnlineParamChange     ${DELTA_PARAS_C09}
    SA UE Attach to cell12    1    1
    Scell_2 Added Based On high Rsrp
    Pcell switch from Cell12 to Cell2 by A1 and add scell_12
    Release Scell    12
    Scell_12 Added Based On high Rsrp
    Pcell switch from Cell2 to Cell12 by A2 and add scell_2
    Release Scell    2
    Release call


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489,311:402,311:403

Scell_2 Added Based On high Rsrp
    Triggered Scell Addition by A1 Event    12    120    51
    Verify Throuput

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

Pcell switch from Cell12 to Cell2 by A1 and add scell_12
    [Arguments]    ${scell_pci}=61    ${ue_id}=81    ${rrc_log_tag}=C09_scell_A1
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     2
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${Pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
     ...    scell=1 scell_rsrp=127 scell_rsrq=0
    ${ret1}=    Execute Egate Command    ${Pcell_switch_by_A1}    pass_regexp=SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.2 performed
    Should Contain    ${ret1}    sCellToAddModList    physCellId ${scell_pci}

Scell_12 Added Based On high Rsrp
    Triggered Scell Addition by A1 Event    2    120    61
    Verify Throuput

Pcell switch from Cell2 to Cell12 by A2 and add scell_2
    [Arguments]    ${scell_pci}=51    ${ue_id}=81    ${rrc_log_tag}=C09_scell_A2
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     2
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${Pcell_switch_by_A2}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
     ...    scell=1 scell_rsrp=123 scell_rsrq=55
    ${ret2}=    Execute Egate Command    ${Pcell_switch_by_A2}    pass_regexp=SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret2}    sCellToReleaseList
    Should Contain    ${ret2}    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.12 performed
    Should Contain    ${ret2}    sCellToAddModList    physCellId ${scell_pci}

SA UE Attach To Cell12
    [Arguments]    ${pdu_id}    ${gw_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1
    Check Pcell triffice    ${pdu_id}

Check Pcell triffice
    [Arguments]    ${pdu_id}    ${ue_id}=81
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Triggered Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${srsrp_nr}    ${scell_pci}=51    ${ue_id}=81    ${rrc_log_tag}=C09_scell_A1
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Start RRC Log    ${rrc_log_tag}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=0
    ...                      activated successfully at airphone
    Rrc Should Contain    sCellToAddModList    physCellId ${scell_pci}

Release Scell
    [Arguments]    ${scell_id}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

Verify Throuput
    [Arguments]    ${scell_idx}=1    ${ue_id}=81    ${pdu_id}=1    ${sleep_time}=30s    ${target_dl_throuput}=135
    sleep    ${sleep_time}    sleep for Tput stable
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_idx}
        ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${target_dl_throuput}


Release call
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off        UE${ue_id}: detached
