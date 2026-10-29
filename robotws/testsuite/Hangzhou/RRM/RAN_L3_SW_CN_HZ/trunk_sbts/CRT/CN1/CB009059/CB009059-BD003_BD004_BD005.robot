*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    owner-zora.wang    owner-ha.zheng    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_NRREL}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CA}
...    @{Inter_RAT_Handover}
...    @{PARAMS_FOR_Handover}
...    @{FDD_DLMIMO}

${CaSup}    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl

@{FDD_DLMIMO}
...    NRCELL:actGbrRacTdEnhResourcePriority=true
...    NRCELL:actGBRAdmissionControl=off
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL:fPdcchMonOccsnPo=2
...    NRCELL-1:maxNumOfCaUsersNRCell=60
...    NRCELL-1:maxNumOfUsersPerNRCell=90
...    NRCELL-1:msg1FrequencyStart=1
...    NRCELL-2:maxNumOfCaUsersNRCell=60
...    NRCELL-2:maxNumOfUsersPerNRCell=90
...    NRCELL-2:msg1FrequencyStart=1
...    NRCELL-3:maxNumOfCaUsersNRCell=120
...    NRCELL-3:maxNumOfUsersPerNRCell=190
...    NRCELL-3:msg1FrequencyStart=10
...    NRCELL-11:maxNumOfUsersPerNRCell=160
...    NRCELL-11:maxNumOfCaUsersNRCell=160
...    NRCELL-12:maxNumOfUsersPerNRCell=160
...    NRCELL-12:maxNumOfCaUsersNRCell=160
...    NRCELL-13:maxNumOfUsersPerNRCell=160
...    NRCELL-13:maxNumOfCaUsersNRCell=160
...    NRCELL-14:maxNumOfUsersPerNRCell=160
...    NRCELL-14:maxNumOfCaUsersNRCell=160
...    NRCELL:maxNumOfSCellAlloc=90
...    NRCELL:maxNumOfUsersPerCell=90
...    NRCELL:maxNumOfRrcSA=90
...    NRCELL:maxNumOfNrDcSnUsers=90

@{PARAMS_FOR_9059}
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS/NRDRB-12:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-12:rlcMode=RLC_UM

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:actAperCsi=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{CA_NRREL}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-3:increasePUSCHPrepTimeULCA=true
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
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

...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-12:lcrId=13
...    NRCELL-11/NRREL-12:nrDcAllowed=false
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3

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

...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:gNbId=1
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRREL-11:nrDcAllowed=false
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-13:gNbId=1
...    NRCELL-3/NRREL-13:gNbIdLength=22
...    NRCELL-3/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-13:lcrId=13
...    NRCELL-3/NRREL-13:nrDcAllowed=false
...    NRCELL-3/NRREL-13:removeNotAllowed=false
...    NRCELL-3/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-13:gnbPlmn:mncLength=3

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
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
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
...    NRBTS/NRDRB_PDCP-1:maxCidAllowed=4
...    NRBTS/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=4
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

@{PM_Counters_BD003}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=4
...    NRCELL-3:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=4
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=3
...    NRCELL-3:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=3

@{PM_Counters_BD005}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-3:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-3:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0

@{QFI6_7check}
...    Qfi mapping fiveQi 6 qfi 1
...    Qfi mapping fiveQi 7 qfi 2
...    rrcReconfigurationComplete

@{check_DL_5CC_UL_2CC_FDD}
...    pcid:52, scellIdx:3] configure_1_1
...    pcid:52, scellIdx:3] configure_0_1
...    pcid:51, scellIdx:2] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:62, scellIdx:4] configure_1_1
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{check_DL_5CC_UL_2CC_TDD}
...    pcid:60, scellIdx:3] configure_1_1
...    pcid:60, scellIdx:3] configure_0_1
...    pcid:51, scellIdx:2] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:0] configure_1_1
...    pcid:52, scellIdx:0] configure_0_1
...    pcid:62, scellIdx:4] configure_1_1
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.

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

@{BD05}
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-13:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-13:rlcMode=RLC_UM

@{BD05_recover}
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    delete:NRBTS/NRDRB-13:nrDrbRlcUmDN
...    NRBTS/NRDRB-13:rlcMode=RLC_AM

@{5QI67_BD05}
...    PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
...    PduId 1 Created FiveQi:Qfi mapping fiveQi 7 qfi 2
...    a1-Threshold rsrp : 70
...    a3-Offset rsrp : 3
...    a2-Threshold rsrp : 20
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    rrcReconfigurationComplete

@{5QI7_BD05}
...    Ue 82 PduId 1 Created FiveQi:Qfi mapping fiveQi 7 qfi 1
...    a3-Offset rsrp : 3
...    a2-Threshold rsrp : 20
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    rrcReconfigurationComplete
...    QoS Routing Table

@{5QI6_DEL}
...    Ue 81 PduId 1 Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    QoS Routing Table
...    sCellToReleaseList

@{5QI68_BD05}
...    PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
...    PduId 1 Created FiveQi:Qfi mapping fiveQi 8 qfi 2
...    a1-Threshold rsrp : 70
...    a3-Offset rsrp : 3
...    rrcReconfigurationComplete

@{5QI78_BD05}
...    PduId 1 Created FiveQi:Qfi mapping fiveQi 7 qfi 1
...    PduId 1 Created FiveQi:Qfi mapping fiveQi 8 qfi 2
...    a1-Threshold rsrp : 70
...    a3-Offset rsrp : 3
...    rrcReconfigurationComplete

@{5QI8_DEL}
...    Ue 84 PduId 1 Removed FiveQi:Qfi mapping fiveQi 8 qfi 2
...    QoS Routing Table
...    sCellToReleaseList

@{5QI6_ADD}
...    Ue 82 PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 2
...    QoS Routing Table

@{BD04_1}
...    NRBTS/NRDRB-12:rlcMode=RLC_AM
...    delete:NRBTS/NRDRB-12:nrDrbRlcUmDN

@{BD04_2}
...    NRBTS/NRDRB-12:rlcMode=RLC_UM
...    NRBTS/NRDRB-12:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1

@{PM_Counters_BD004}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1

@{QFI6_8check}
...    Qfi mapping fiveQi 6 qfi 1
...    Qfi mapping fiveQi 8 qfi 2
...    rrcReconfigurationComplete

*** Test Cases ***
CB009059-ET-BD003_Multi_CC_CA_UE_New_PDU_setup_FR1_CA_incompatible_DRB_covBasedA1_CA_release_5CC_FDD_PCELL
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      This user scenario validates that for a UE with a CA eligible DRB and CA is activated, if a new DRB is setup
    ...      which is CA incompatible, CA is released. Here UE is attached to a cell during initial context setup (ICS)
    ...      and at least one FR1 CA eligible DRB is established and at least one UM RLC mode non-GBR DRB configured as
    ...      Not FR1 CA eligible is established. UE is configured with CA.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR UM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-11 and DRB-1 DRB-2 during the UE context setup then sent Throughput
    ...         Step B. UE82 attaches to Cell-3 and DRB-1 DRB-2 during the UE context setup then sent Throughput
    ...         Step C. UE81 sent A1 MR
    ...         Step D. UE82 sent A1 MR
    ...         Step E. UE81 setup DRB-3 with PDU2,UE82 setup DRB-3 with PDU2
    ...         Step F. UE81 delete PDU2,UE82 delete PDU2
    ...         Step G. UE81/UE82 sent A1 MR
    ...         Step H. Repeat step E to step G
    ...         Step I. Released all UE and check counters
    ...    3. Expected Results:
    ...         Step A: UE81 Registration successfully The TP only in PCELL
    ...         Step B: UE82 Registration successfully The TP only in PCELL
    ...         Step C: UE81 Configuration DL 5CC(FTTTF) UL 2CC(FT)
    ...         Step D. UE82 Configuration DL 5CC(TTTFF) UL 2CC(TF)
    ...         Step E. UE81 UE82 DRB-3 setup successful ALL CC released
    ...         Step F. UE81 UE82 DRB-3 delete successful GNB configuration A1
    ...         Step G. UE81 Configuration DL 5CC(FTTTF) UL 2CC(FT),UE82 Configuration DL 5CC(TTTFF) UL 2CC(TF)
    ...         Step H. The results are as expected
    ...         Step I .Released all UE and check counters successful
    [Tags]    BD003    DL_CA_LABEL-FTTTF(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41+100Mhz_TDD_n77+10Mhz_FDD_n71)    Tingjian.Mao
    ...    DL_CA_LABEL-TTTFF(60Mhz_TDD_n41+60Mhz_TDD_n41+100Mhz_TDD_n77+10Mhz_FDD_n71+10Mhz_FDD_n71)    QC_348344    
    ...    UL_CA_LABEL-TF(60Mhz_TDD_n41+10Mhz_FDD_n71)    UL_CA_LABEL-FT(10Mhz_FDD_n71+60Mhz_TDD_n41)
    clear counter files    wait=${False}
    UE PDU Session Setup with multiple Qosflows    cell_id=11
    UE PDU Session Setup with multiple Qosflows    ue_id=82    cell_id=3    gw=2
    A1 DL 5CC UL 2CC    pass_regexp=${check_DL_5CC_UL_2CC_FDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC
    A1 DL 5CC UL 2CC    ue_id=82    cellfreq=632736    pass_regexp=${check_DL_5CC_UL_2CC_TDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC    ue_id=82    Tput_dl=600
    repeat keyword    3 times    Verify UE States ADD and DEL incompatible DRB with new PDU
    Release UEs    ue_type=all
    check counters    pm_counters_expression=${PM_Counters_BD003}

CB009059-ET-BD004_Multiple_UE_scenario_when_covBasedA1
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      In this user scenario, multiple UEs attach to a cell during initial context setup (ICS) with multiple DRBs
    ...      configured for them differently. The gNB takes care of configuring or not configuring the UEs with CA based
    ...      on their individual configuration of feature flag NRBTS.actDrbProfileForCellAggrLevel.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-11 and DRB-1 DRB-2 during the UE context setup then sent Throughput
    ...         Step B. UE82 attaches to Cell-11 and DRB-2 during the UE context setup then sent Throughput
    ...         Step C. UE81 sent A1 MR
    ...         Step D. UE81 delete DRB-1
    ...         Step E. UE82 add DRB-1
    ...         Step F. UE82 sent A1 MR
    ...         Step G. UE2 Scell release
    ...         Step H. UE83 attaches to Cell-11 and DRB-1 DRB-3 during the UE context setup then sent Throughput
    ...         Step I. Released all UE and check counters
    ...    3. Expected Results:
    ...         Step A: UE81 Registration successfully, A1 scell addition measconfig to UE.
    ...         Step B: UE82 Registration successfully, no A1 scell addition measconfig to UE.
    ...         Step C: UE81 Configuration DL 5CC(FTTTF) UL 2CC(FT)
    ...         Step D. UE81 DRB-1 delete successful ALL CC released
    ...         Step E. UE82 DRB-1 add successful GNB configuration A1
    ...         Step F. UE82 Configuration DL 5CC(FTTTF) UL 2CC(FT)
    ...         Step G. UE82 release 1 scell, change to 4CC
    ...         Step H. UE83 Registration successfully, no A1 scell addition measconfig to UE.
    ...         Step I .Released all UE and check counters successful
    [Tags]    BD004    DL_CA_LABEL-FTTTF(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41+100Mhz_TDD_n77+10Mhz_FDD_n71)    ha.zheng
    ...    DL_CA_LABEL-TTTFF(60Mhz_TDD_n41+60Mhz_TDD_n41+100Mhz_TDD_n77+10Mhz_FDD_n71+10Mhz_FDD_n71)    QC_348342  
    ...    UL_CA_LABEL-TF(60Mhz_TDD_n41+10Mhz_FDD_n71)    UL_CA_LABEL-FT(10Mhz_FDD_n71+60Mhz_TDD_n41)
    clear counter files    wait=${False}
    OnlineParamChange    ${BD04_1}
    UE PDU Session Setup with multiple Qosflows    cell_id=11
    UE PDU Session Setup with Qosflow    ue_id=82    cell_id=11    qos_id=2    fail_regexp=eventA1
    UE81 scell add then DRB1 delete
    UE82 DRB1 add then A1 scell add and A2 scell release
    UE PDU Session Setup with multiple Qosflows    ue_id=83    qos_id=3    pass_regexp=${QFI6_8check}    fail_regexp=eventA1
    Release UEs    ue_type=all
    check counters    pm_counters_expression=${PM_Counters_BD004}
    [Teardown]    case recover BD004

CB009059-ET-BD005_Multiple_UE_scenario_with_mix_of_AM_RLC_and_UM_RLC_DRBs_coeBasedA1_4CC
    [Documentation]
    ...    The purpose of this test case is to check following scenarios: multiple UEs attach to a cell during initial context setup with
    ...    multiple DRBs configured for them differently.The gNB takes care of configuring or not configuring the UEs with CA based on
    ...    their individual configuration of feature flag NRBTS.actDrbProfileForCellAggrLevel.5G_RAN_USR_RRM_22306
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR UM 1:Not FR1 CA eligible
    ...          3 non-GBR UM 0:FR1 CA eligible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81 3CC PCELL(cell-11) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...     a.UE81 attaches to Cell-11 and setup DRB-1 DRB-2 during the UE context setup then sent traffic.A1 scell addition measconfig to UE.
    ...     b.UE82 attaches to Cell-11 and setup DRB-2 during the UE context setup then sent traffic.No A1 scell addition measconfig to UE.
    ...     c.UE81 A1 scell add.DL 5CC UL 2CC add successfully.check traffic should be ok.
    ...     d.UE81 DRB1 delete successfully.check UE81 traffic should be ok. scell release and No A1 scell addition measconfig to UE
    ...     e.UE82 DRB1 add successfully.check UE82 qfi2 traffic send,A1 scell add.DL 5CC UL 2CC add successfully,traffic should be ok.Then A2 scell
    ...      release 1 scell, change to 4CC.check traffic should be ok.
    ...     f.UE83 attaches to Cell-3 and setup DRB-1 DRB-3 during the UE context setup then sent traffic.A1 scell addition measconfig to UE.
    ...      UE83 A1 scell add.DL 5CC UL 2CC add successfully.check traffic should be ok.
    ...     g.UE84 attaches to Cell-3 and setup DRB-2 DRB-3 during the UE context setup then sent traffic.A1 scell addition measconfig to UE.
    ...     UE84 A1 scell add.DL 5CC UL 2CC add successfully.check traffic should be ok.then delete DRB3,No A1 scell addition measconfig to UE.
    [Tags]    BD005    DL_CA_LABEL-FTTTF(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41+100Mhz_TDD_n77+10Mhz_FDD_n71)    zora.wang
    ...    DL_CA_LABEL-TTTFF(60Mhz_TDD_n41+60Mhz_TDD_n41+100Mhz_TDD_n77+10Mhz_FDD_n71+10Mhz_FDD_n71)    QC_46744    
    ...    UL_CA_LABEL-TF(60Mhz_TDD_n41+10Mhz_FDD_n71)    UL_CA_LABEL-FT(10Mhz_FDD_n71+60Mhz_TDD_n41)    AP_REG
    OnlineParamChange    ${BD05}
    clear counter files
    UE PDU Session Setup with multiple Qosflows    cell_id=11    qos_id=2    pass_regexp=${5QI67_BD05}
    UE PDU Session Setup with Qosflow    ue_id=82    cell_id=11    qos_id=2    pass_regexp=${5QI7_BD05}    fail_regexp=a1-Threshold rsrp : 70
    UE81 scell add then DRB1 delete
    UE82 DRB1 add then A1 scell add and A2 scell release
    UE83 DRB1 and DRB3 add and A1 scell add
    UE84 DRB2 and DRB3 add and A1 scell add then delete DRB3
    check counters    pm_counters_expression=${PM_Counters_BD005}
    [Teardown]    case recover BD005

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Modify Cfg
    Update Cfg    ue_param id=81,82,83,84 ue_nr_capabilities=${SA_Capa_3T3F} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=1-6 amf=1

UE PDU Session Setup with multiple Qosflows
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${default_qos_id}=1    ${qos_id}=2    ${gw}=1    ${pass_regexp}=${QFI6_7check}
    ...    ${fail_regexp}=none    ${times}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=${default_qos_id} default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Sent Throughput    ue_id=${ue_id}    times=${times}
    Sent Throughput    ue_id=${ue_id}    qfi_id=2    times=${times}
    Execute Egate Command    smf_param id=1 reset

DEL incompatible DRB with new PDU
    [Arguments]    ${ue_id}=81    ${pass_regexp}=rrcReconfigurationComplete
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=amf
    ...    pass_regexp=${pass_regexp}

ADD incompatible DRB with new PDU
    [Arguments]    ${ue_id}=81    ${qos_id}=1    ${gw}=3    ${pass_regexp}=rrcReconfigurationComplete
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ue_id} nwslice=1 gw=${gw}
    ...    pass_regexp=${pass_regexp}
    Sent Throughput    ue_id=${ue_id}    pdu_id=2

A1 DL 5CC UL 2CC
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${pass_regexp}=${check_DL_5CC_UL_2CC_FDD}
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=${pass_regexp}

Sent Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${times}=3
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=${I}    UE ${ue_id}: UDP DL
    END
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput pcell and scells 5CC
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=300    ${Tput_ul}=50    ${cell_num}=4
    ${scell_t}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${str_index}    type=pdsch    rate_type=ave
#         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${Tput_dl}
    ${scell0_tput_u}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_tput_u}/1000 > 0
    ${scell3_tput_u}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pusch    rate_type=ave
    Should Be True    ${scell3_tput_u}/1000 > 0
    Should Be True    (${scell0_tput_u}+${scell3_tput_u})/1000>${Tput_ul}

Verify no Scell
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${Tput_dl}=10    ${Tput_ul}=7
    ${dl_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[2]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[3]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[4]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify UE States ADD and DEL incompatible DRB with new PDU
    ADD incompatible DRB with new PDU
    Wait Until Keyword Succeeds    40s    5s    Verify no Scell
    ADD incompatible DRB with new PDU    ue_id=82    gw=4
    Wait Until Keyword Succeeds    40s    5s    Verify no Scell    ue_id=82
    DEL incompatible DRB with new PDU
    A1 DL 5CC UL 2CC    pass_regexp=${check_DL_5CC_UL_2CC_FDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC
    DEL incompatible DRB with new PDU    ue_id=82
    A1 DL 5CC UL 2CC    ue_id=82    cellfreq=632736    pass_regexp=${check_DL_5CC_UL_2CC_TDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC    ue_id=82    Tput_dl=600

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

case recover BD005
    Release UEs    ue_type=all
    OnlineParamChange    ${BD05_recover}
    Common Test Teardown And Stop Capture Logs

UE PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${qos_id}=1    ${gw}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Execute Egate Command    smf_param id=1 reset
    Sent Throughput    ue_id=${ue_id}

ADD QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Delete QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

trigger A2 MR to release scell
    [Arguments]    ${ue_id}=82    ${carrierfreq}=504990    ${scell_index}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret2}    sCellToReleaseList

UE81 scell add then DRB1 delete
    A1 DL 5CC UL 2CC    ue_id=81    pass_regexp=${check_DL_5CC_UL_2CC_FDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC
    Delete QOS in same pdu    qos_id=1    pass_regexp=${5QI6_DEL}    fail_regexp=a1-Threshold rsrp : 70
    Wait Until Keyword Succeeds    40s    5s    Verify no Scell

UE82 DRB1 add then A1 scell add and A2 scell release
    ADD QOS in same pdu    ue_id=82    qos_id=1    pass_regexp=${5QI6_ADD}
    Sent Throughput    ue_id=82    qfi_id=2
    A1 DL 5CC UL 2CC    ue_id=82    pass_regexp=${check_DL_5CC_UL_2CC_FDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC    ue_id=82
    trigger A2 MR to release scell    ue_id=82
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 4CC    ue_id=82

UE83 DRB1 and DRB3 add and A1 scell add
    UE PDU Session Setup with multiple Qosflows    ue_id=83    cell_id=3    qos_id=3    pass_regexp=${5QI68_BD05}    times=7
    A1 DL 5CC UL 2CC    ue_id=83    cellfreq=632736    pass_regexp=${check_DL_5CC_UL_2CC_TDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC    ue_id=83    Tput_dl=800

UE84 DRB2 and DRB3 add and A1 scell add then delete DRB3
    UE PDU Session Setup with multiple Qosflows    ue_id=84    cell_id=3    default_qos_id=2    qos_id=3    pass_regexp=${5QI78_BD05}    times=7
    A1 DL 5CC UL 2CC    ue_id=84    cellfreq=632736    pass_regexp=${check_DL_5CC_UL_2CC_TDD}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell and scells 5CC    ue_id=84    qfi_id=2    Tput_dl=400    Tput_ul=25
    Delete QOS in same pdu    ue_id=84    qos_id=3    pass_regexp=${5QI8_DEL}    fail_regexp=a1-Threshold rsrp : 70
    Release UEs    ue_type=all

Verify Throughput pcell and scells 4CC
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=300    ${Tput_ul}=50    ${cell_num}=4
    ${scell_t}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    2    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${str_index}    type=pdsch    rate_type=ave
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    Should Be True    ${total_dl_tput}/1000 > ${Tput_dl}
    ${scell0_tput_u}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_tput_u}/1000 > 0
    ${scell3_tput_u}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pusch    rate_type=ave
    Should Be True    ${scell3_tput_u}/1000 > 0
    Should Be True    (${scell0_tput_u}+${scell3_tput_u})/1000>${Tput_ul}

case recover BD004
    Release UEs    ue_type=all
    OnlineParamChange    ${BD04_2}
    Common Test Teardown And Stop Capture Logs
