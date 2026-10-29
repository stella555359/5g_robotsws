*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    4452    1898    6280
@{PARAMS_IN_SCF}
...    @{CA_NRREL}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CA}
...    @{Inter_RAT_Handover}
...    @{PARAMS_FOR_Handover}
...    @{8311_enable}
...    @{FDD_DLMIMO}
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRBTS:actEcpriPhase2=true
...    NRBTS:actEcpriPhase3=true

@{FDD_DLMIMO}
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:dlMimoMode=2x2 Closed Loop Spatial Multiplexing

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{CA_NRREL}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-2:lcrId=11
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly

@{PARAMS_FOR_Handover}
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS/NRCELL-3:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-3:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=40
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=80ms
...    NRCELL-11:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=40
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=80ms
...    NRCELL-11:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=45
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=640ms
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:scs=15 KHz
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=127450
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=20
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=60
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=110
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms5120
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrp=10
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrq=10
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11:a1MeashoEnabled=rsrp
...    NRCELL-11:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-11:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-11:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a2MeashoEnabled=rsrp
...    NRCELL-11:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-11:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-11:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=20|a2TimeToTriggerhoSsbRsrpSA=ms64

...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=20|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=632736
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=11
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{Inter_RAT_Handover}
...    NRBTS:tNgRelocExecDeltL=5000
...    NRBTS:nonContentRachAcFullConfigHo=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRBTS:actRohc=true
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:actInterRatHoSA=true
...    NRBTS/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS/NRHOIR-1:b2MeashoEnabled=rsrp
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS/NRHOIR-1:earfcnValue=1
...    NRBTS/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS/NRCELL-11:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRBTS/NRADJECELL-8:eNodeBId=18
...    NRBTS/NRADJECELL-8:ePSTrackingAreaCode=0
...    NRBTS/NRADJECELL-8:earfcnValue=1
...    NRBTS/NRADJECELL-8:lcrId=1
...    NRBTS/NRADJECELL-8:physCellId=11
...    NRBTS/NRADJECELL-8:ecgiPlmn:mcc=311
...    NRBTS/NRADJECELL-8:ecgiPlmn:mnc=489
...    NRBTS/NRADJECELL-8:ecgiPlmn:mncLength=3
...    NRBTS/NRADJECELL-8:enbPlmn:mcc=311
...    NRBTS/NRADJECELL-8:enbPlmn:mnc=489
...    NRBTS/NRADJECELL-8:enbPlmn:mncLength=3
...    NRCELL-11/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-11/NRRELE-1:eNodeBId=18
...    NRCELL-11/NRRELE-1:eutranCellExcluded=false
...    NRCELL-11/NRRELE-1:lcrId=1
...    NRCELL-11/NRRELE-1:removeNotAllowed=false
...    NRCELL-11/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-11/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-11/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-12/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-12/NRRELE-1:eNodeBId=18
...    NRCELL-12/NRRELE-1:eutranCellExcluded=false
...    NRCELL-12/NRRELE-1:lcrId=1
...    NRCELL-12/NRRELE-1:removeNotAllowed=false
...    NRCELL-12/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-12/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-12/NRRELE-1:ecgiPlmn:mncLength=3

@{PM_Counters_BC005}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=12
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-3:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=9
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-3:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=4
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=4
...    NRCELL-11:${DL_RRC_FSCELL_REL_ATT_SA}=4
...    NRCELL-11:${DL_RRC_FSCELL_REL_SUC_SA}=4

@{QFI6_7check}
...    Qfi mapping fiveQi 6 qfi 1
...    Qfi mapping fiveQi 7 qfi 2
...    rrcReconfigurationComplete

@{QFI6_8check}
...    Qfi mapping fiveQi 6 qfi 1
...    Qfi mapping fiveQi 8 qfi 2
...    rrcReconfigurationComplete

@{check_handover_11}
...    handover from EXT_ENB-2.12 to EXT_ENB-2.11
...    rrcReconfigurationComplete

@{check_3CC}
...    pcid:51, scellIdx:2
...    pcid:50, scellIdx:1
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete

@{check_2CC}
...    pcid:60, scellIdx:1
...    pcid:52, scellIdx:0
...    rrcReconfigurationComplete

@{check_del_6}
...    QoS Routing Table
...    Removed FiveQi:Qfi mapping fiveQi 6 qfi 1

@{check_del_8}
...    QoS Routing Table
...    Removed FiveQi:Qfi mapping fiveQi 8 qfi 2

@{check_add_6}
...    Added QosFlow with QFI:1 fiveQI:6
...    QoS Routing Table

@{check_add_8}
...    Added QosFlow with QFI:2 fiveQI:8
...    QoS Routing Table

@{sCellAdditionMethod_blind}
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a2MeashoEnabledSA=rsrp
...    NRCELL-3:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=20|a2TimeToTriggerhoSsbRsrpSA=ms64


${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
#This counter measures the number of SCells to be released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037
#This counter measures the number of SCells released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.



${SA_Capa_3T3F}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B2ABB08873E238F11C7A06
...    7D813E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C0000000000000000
...    0040E1E027FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000
...    E208000010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0A
...    C5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC
...    5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E
...    1617593850001C28000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E208000
...    0A0B0102F07118000050580817838980000242C040803808D00A202640411740101150B428913639F0E14489B1CF870A244D8E7C3851226C
...    73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081
...    B1CF811204081B1CF810A040D8E7C09502040810206CB5E1C8810204081B2D78722040810206CB5E1C089B1CF870206C00004081B0000102
...    06C0000001F1618C6318C6318C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E09002000000010000020080000000
...    400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500
...    200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED03410000096524040000659494100002
...    96525040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E59494100
...    00C96524040000C594900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A050
...    28140A05028140A050281400282020180300801002101002008040300610080100202018030080600C10100C018040300610080100202018
...    030080100220100C01804030060100C018202004010080100440100200404008010100C018040300601002004802004008080600C0201803
...    0080600C020040080040080300080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828705A0

*** Test Cases ***
CB009059-ET-BC005_Interaction_with_intra_gnb_mobility_buffer_based_SCell_Addition
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      This user scenario describes CB009059 interaction with UE mobility cases when the SCell Addition method is
    ...      blind and buffer based SCell Addition is activated.
    ...      This user scenario describes CB009059 interaction with UE mobility cases when a CA is disallowed DRB configuration
    ...      is established during the HO procedure.
    ...      This user scenario describes CB009059 interaction with incoming HO from LTE connected to ECP (5GC000711) when
    ...      the SCell Addition method is blind.
    ...      This user scenario describes CB009059 interaction with incoming HO from LTE connected to ECP (5GC000711) when
    ...      the SCell Addition method is blind and buffer based SCell Addition is activated.
    ...      This user scenario describes CB009059 interaction with incoming HO from LTE connected to ECP (5GC000711) when
    ...      a CA is disallowed DRB configuration is established during the HO procedure.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...    2.Test Case Steps:
    ...         Step A. UE attaches to Cell-12 and DRB-1 DRB-2 during the UE context setup then sent Throughput
    ...         Step B. A3 handover to cell-11 then delete Add DRB-1
    ...         Step C. A2/A3 handover to cell-3
    ...         Step D. A2 pcell switch to cell-11 then released then UE
    ...         Step E. UE attaches to Cell-11,A2/B2 inter Rat handover to LTE
    ...         Step F. Trigger UE LTE handover to 5G then released then UE
    ...         Step G. Repeat step A to step F use DRB-1 and DRB-3
    ...         Step H. ONline change sCellAdditionMethod to blind
    ...         Step I .Repeat step A to step G
    ...    3. Expected Results:
    ...         Step A: UE Registration successfully The TP only in PCELL
    ...         Step B: Intra frequency handover successfully trigger A1 3CC,CA release when delete DRB-1,trigger A1 3CC when add DRB-1
    ...         Step C: Inter frequency handover successfully trigger A1 2CC
    ...         Step D. Pcell switch successfully trigger A1 3CC then UE released successful
    ...         Step E. UE Registration successfully trigger A1 3CC then UE inter Rat handover successful
    ...         Step F. UE LTE handover to 5G successful trigger A1 3CC
    ...         Step G. The results are as expected
    ...         Step H. ONline change successfully NO PDL alarm
    ...         Step I .The results are as expected
    [Tags]    QC_46741    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files    false
    covBasedA1 Verify UE State after kinds handover
    OnlineParamChange    ${sCellAdditionMethod_blind}
    Blind Verify UE State after kinds handover
    Check Wireshark Log    ${CURDIR}${/}A2A_BC005${/}a2a.ini    wait_string=UEContextReleaseComplete::44
    check counters    pm_counters_expression=${PM_Counters_BC005}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Modify Cfg
    Update Cfg    ue_param id=81,82 ue_nr_capabilities=${SA_Capa_3T3F} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=1-6 amf=1
    ${C_1}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.138 daemon=10.0.2.1:22222 gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${C_2}    catenate
    ...    set_cell id=1 gnb=4 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12219 nrci=0x01
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    gnb_param id=4 x2_listening_socket=1 measEvent=A3

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}


UE PDU Session Setup with multiple Qosflows
    [Arguments]    ${ue_id}=81    ${cell_id}=12    ${qos_id}=2    ${pass_regexp}=${QFI6_7check}    ${fail_regexp}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0
    Sent Throughput
    Sent Throughput    qfi_id=2

A3 handover to cell11
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${pass_regexp}=${check_handover_11}    ${fail_regexp}=none
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11 phycell_id=60 nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

DEL DRB
    [Arguments]    ${ue_id}=81    ${qos_id}=1    ${pass_regexp}=${check_del_6}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

ADD DRB
    [Arguments]    ${ue_id}=81    ${qos_id}=1    ${pass_regexp}=${check_add_6}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

A1 3CC in cell11
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${pass_regexp}=${check_3CC}
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=${pass_regexp}

A2 A3 handover to cell3
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${cellfreq2}=632736    ${fail_regexp}=none
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11 phycell_id=52 nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.3    fail_regexp=${fail_regexp}

A2 A3 handover to cell11
    [Arguments]    ${ue_id}=81    ${cellfreq}=632736    ${cellfreq2}=127450
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11 phycell_id=60 nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.11

A1 2CC in cell3
    [Arguments]    ${ue_id}=81    ${cellfreq}=632736    ${pass_regexp}=${check_2CC}
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=${pass_regexp}

A2 pcell switch from cell3 to cell11
    [Arguments]    ${ue_id}=81    ${cellfreq}=632736
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=0 srsrq_nr=0 scell=1 scell_rsrp=115 scell_rsrq=95
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.11

A2 B2 handover to LTE and Back to 5G
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    ${B2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    event_type=B2    carrierfreq=1    carrierfreq_rat=EUTRAN
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${B2} event=B2 srsrp_nr=11 srsrq_nr=11 phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Successful handover from EXT_ENB-2.11 to ENB-4.1
    sleep    5s    # wait ue out Handovering State
    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=11 plmn=311:489
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Sent Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=30 trf_id=1    pass_regexp=Started Uplink

Verify Throughput pcell and scells 3CC
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=200    ${Tput_ul}=10    ${sleep_time}=20s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0

Verify Throughput pcell and scells 2CC
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=50    ${Tput_ul}=7    ${sleep_time}=20s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0

Verify no Scell
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=10    ${Tput_ul}=7    ${sleep_time}=20s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[2]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

covBasedA1 Verify UE State after intra frequency handover with Not FR1 CA eligible DRB DEL ADD CA eligible
    UE PDU Session Setup with multiple Qosflows
    Verify no Scell    Tput_dl=15    Tput_ul=13
    A3 handover to cell11
    A1 3CC in cell11
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    DEL DRB
    Verify no Scell    qfi_id=2
    ADD DRB
    Sent Throughput
    A1 3CC in cell11

covBasedA1 Verify UE State after inter frequency handover pcell switch with Not FR1 CA eligible DRB
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    A2 A3 handover to cell3
    A1 2CC in cell3
    Verify Throughput pcell and scells 2CC    Tput_dl=150    Tput_ul=20
    A2 pcell switch from cell3 to cell11
    A1 3CC in cell11
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    Release UEs    ue_type=all

covBasedA1 Verify UE State after inter Rat handover with Not FR1 CA eligible DRB
    UE PDU Session Setup with multiple Qosflows    cell_id=11
    A1 3CC in cell11
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    A2 B2 handover to LTE and Back to 5G
    A1 3CC in cell11
    Sent Throughput
    Sent Throughput    qfi_id=2
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    Release UEs    ue_type=all

covBasedA1 Verify UE State after intra frequency handover with incompatible DRB DEL ADD
    UE PDU Session Setup with multiple Qosflows    qos_id=3    pass_regexp=${QFI6_8check}    fail_regexp=eventA1
    Verify no Scell
    A3 handover to cell11    fail_regexp=eventA1
    Verify no Scell
    DEL DRB    qos_id=3    pass_regexp=${check_del_8}
    A1 3CC in cell11
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=15
    ADD DRB    qos_id=3    pass_regexp=${check_add_8}
    Verify no Scell

covBasedA1 Verify UE State after inter frequency and inter rat handover with incompatible DRB
    A2 A3 handover to cell3    fail_regexp=eventA1
    Verify no Scell    Tput_dl=150    Tput_ul=10
    Release UEs    ue_type=all
    UE PDU Session Setup with multiple Qosflows    cell_id=11    qos_id=3    pass_regexp=${QFI6_8check}
    A2 B2 handover to LTE and Back to 5G
    Verify no Scell    Tput_dl=15    Tput_ul=10
    Release UEs    ue_type=all

Blind Verify UE State after intra frequency handover with Not FR1 CA eligible DRB DEL ADD CA eligible
    UE PDU Session Setup with multiple Qosflows
    Verify no Scell    Tput_dl=15    Tput_ul=10
    A3 handover to cell11
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    DEL DRB
    Verify no Scell    qfi_id=2    Tput_dl=15    Tput_ul=10
    ADD DRB
    Sent Throughput
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10

Blind Verify UE State after inter frequency handover with Not FR1 CA eligible DRB
    A2 A3 handover to cell3
    Verify Throughput pcell and scells 2CC    Tput_dl=150    Tput_ul=15
    A2 A3 handover to cell11
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    Release UEs    ue_type=all

Blind Verify UE State after intra frequency handover with Not FR1 CA eligible DRB DEL ADD incompatible DRB
    UE PDU Session Setup with multiple Qosflows    qos_id=3    pass_regexp=${QFI6_8check}
    Verify no Scell
    A3 handover to cell11
    Verify no Scell
    DEL DRB    qos_id=3    pass_regexp=${check_del_8}
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    ADD DRB    qos_id=3    pass_regexp=${check_add_8}
    Sent Throughput
    Verify no Scell

Blind Verify UE State after inter frequency handover with incompatible DRB
    A2 A3 handover to cell3
    Verify no Scell    Tput_dl=250    Tput_ul=15
    A2 A3 handover to cell11
    Verify no Scell    Tput_dl=20    Tput_ul=15
    Release UEs    ue_type=all

Blind Verify UE State after inter rat handover with incompatible DRB and Not FR1 CA eligible DRB
    UE PDU Session Setup with multiple Qosflows    cell_id=11
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    A2 B2 handover to LTE and Back to 5G
    Verify Throughput pcell and scells 3CC    Tput_dl=250    Tput_ul=10
    Release UEs    ue_type=all
    UE PDU Session Setup with multiple Qosflows    cell_id=11    qos_id=3    pass_regexp=${QFI6_8check}
    Verify no Scell    Tput_dl=15    Tput_ul=10
    A2 B2 handover to LTE and Back to 5G
    Verify no Scell    Tput_dl=15    Tput_ul=10
    Release UEs    ue_type=all

covBasedA1 Verify UE State after kinds handover
    covBasedA1 Verify UE State after intra frequency handover with Not FR1 CA eligible DRB DEL ADD CA eligible
    covBasedA1 Verify UE State after inter frequency handover pcell switch with Not FR1 CA eligible DRB
    covBasedA1 Verify UE State after inter Rat handover with Not FR1 CA eligible DRB
    covBasedA1 Verify UE State after intra frequency handover with incompatible DRB DEL ADD
    covBasedA1 Verify UE State after inter frequency and inter rat handover with incompatible DRB

Blind Verify UE State after kinds handover
    Blind Verify UE State after intra frequency handover with Not FR1 CA eligible DRB DEL ADD CA eligible
    Blind Verify UE State after inter frequency handover with Not FR1 CA eligible DRB
    Blind Verify UE State after intra frequency handover with Not FR1 CA eligible DRB DEL ADD incompatible DRB
    Blind Verify UE State after inter frequency handover with incompatible DRB
    Blind Verify UE State after inter rat handover with incompatible DRB and Not FR1 CA eligible DRB
