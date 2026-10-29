*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-Delun.Li    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

@{PARAMS_IN_SWCONFIG}
...    @{rdMaxActiveIncomingCaRelFlexSCellSelect}
...    @{rdMaxIncomingCaRel}

@{rdMaxIncomingCaRel}
...    0x5901D2=2
@{rdMaxActiveIncomingCaRelFlexSCellSelect}
...    0x59021E=4

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_8950_1}

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:isRplCellForPSCell=true
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:nrDcAllowed=false
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:isRplCellForPSCell=true
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-5:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-5:lcrId=5
...    NRCELL-1/NRREL-5:nrDcAllowed=false
...    NRCELL-1/NRREL-5:removeNotAllowed=false
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:isRplCellForPSCell=true
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:nrDcAllowed=false
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:isRplCellForPSCell=true
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:isRplCellForPSCell=true
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-15:gNbId=1
...    NRCELL-1/NRREL-15:gNbIdLength=22
...    NRCELL-1/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-15:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-15:lcrId=15
...    NRCELL-1/NRREL-15:nrDcAllowed=false
...    NRCELL-1/NRREL-15:removeNotAllowed=false
...    NRCELL-1/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-15:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-15:isRplCellForPSCell=true
...    NRCELL-15:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-19:gNbId=1
...    NRCELL-1/NRREL-19:gNbIdLength=22
...    NRCELL-1/NRREL-19:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-19:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-19:lcrId=19
...    NRCELL-1/NRREL-19:nrDcAllowed=false
...    NRCELL-1/NRREL-19:removeNotAllowed=false
...    NRCELL-1/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-19:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-19:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-19:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-19:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-19:isRplCellForPSCell=true
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-20:gNbId=1
...    NRCELL-1/NRREL-20:gNbIdLength=22
...    NRCELL-1/NRREL-20:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-20:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-20:lcrId=20
...    NRCELL-1/NRREL-20:nrDcAllowed=false
...    NRCELL-1/NRREL-20:removeNotAllowed=false
...    NRCELL-1/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-20:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-20:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-20:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-20:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-20:isRplCellForPSCell=true
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-19:actK1Opt=intra-gNB
...    NRCELL-20:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-17:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-5:sCellPrio=1
...    NRCELL-1/NRREL-15:sCellPrio=3
...    NRCELL-1/NRREL-2:sCellPrio=5
...    NRCELL-1/NRREL-4:sCellPrio=6
...    NRCELL-1/NRREL-11:sCellPrio=2
...    NRCELL-1/NRREL-12:sCellPrio=12
...    NRCELL-1/NRREL-19:sCellPrio=19
...    NRCELL-1/NRREL-20:sCellPrio=20
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_FOR_other}
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:srbInactivityTimerSA=60
...    NRCELL:filterCoeffSsbRsrq=fc4
...    NRBTS/NRSCTP-1:sctpProfile:sctpRtoInit=30000

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{PARAMS_FOR_8950}
...    NRBTS:actFlexSCellSelectFr1=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:sCellActivationMethod=blind

@{PARAMS_FOR_8950_1}
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-6:gNbId=1
...    NRCELL-1/NRREL-6:gNbIdLength=22
...    NRCELL-1/NRREL-6:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-6:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-6:lcrId=6
...    NRCELL-1/NRREL-6:nrDcAllowed=false
...    NRCELL-1/NRREL-6:removeNotAllowed=false
...    NRCELL-1/NRREL-6:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-6:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-6:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-6:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-6:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-6:isRplCellForPSCell=true
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:nrDcAllowed=false
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-13:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-17:gNbId=1
...    NRCELL-1/NRREL-17:gNbIdLength=22
...    NRCELL-1/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-17:lcrId=17
...    NRCELL-1/NRREL-17:nrDcAllowed=false
...    NRCELL-1/NRREL-17:removeNotAllowed=false
...    NRCELL-1/NRREL-17:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-17:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:sCellPrio=4
...    NRCELL-1/NRREL-6:sCellPrio=7
...    NRCELL-1/NRREL-13:sCellPrio=13
...    @{PARAMS_FOR_CA}

@{PARAMS_FOR_8950_disable}
...    delete:NRCELL-1/NRREL-13
...    delete:NRCELL-1/NRREL-17
...    delete:NRCELL-1/NRREL-6
...    NRBTS:actFlexSCellSelectFr1=false

@{PARAMS_FOR_A014}
...    NRBTS:actFlexSCellSelectFr1=false
...    @{PARAMS_OUT_SCELL_NRCELL1}
...    @{PARAMS_8290_related}

@{PARAMS_8290_related}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:weightForSCellSelection=50
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67

@{PARAMS_OUT_SCELL_NRCELL1}
...    NRCELL:maxNumScellsDlFr1=4
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:nrDcAllowed=false
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:isRplCellForPSCell=false
...    NRCELL-14/NRREL-1:sCellPrio=2
...    NRCELL-17/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-17/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-17/NRREL-1:gNbId=1
...    NRCELL-17/NRREL-1:gNbIdLength=22
...    NRCELL-17/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-17/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-17/NRREL-1:lcrId=1
...    NRCELL-17/NRREL-1:nrDcAllowed=false
...    NRCELL-17/NRREL-1:removeNotAllowed=false
...    NRCELL-17/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-17/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-17/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-17/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-17/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-17/NRREL-1:isRplCellForPSCell=false
...    NRCELL-17/NRREL-1:sCellPrio=2
...    NRCELL-18:a1MeasSCellAddEnabled=rsrp
...    NRCELL-18:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-18:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-18:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-18/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-18/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-18/NRREL-1:gNbId=1
...    NRCELL-18/NRREL-1:gNbIdLength=22
...    NRCELL-18/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-18/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-18/NRREL-1:lcrId=1
...    NRCELL-18/NRREL-1:nrDcAllowed=false
...    NRCELL-18/NRREL-1:removeNotAllowed=false
...    NRCELL-18/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-18/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-18/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-18/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-18/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-18/NRREL-1:isRplCellForPSCell=false
...    NRCELL-18/NRREL-1:sCellPrio=2
...    NRCELL-5:a1MeasSCellAddEnabled=rsrp
...    NRCELL-5:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-5:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-5:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-6:a1MeasSCellAddEnabled=rsrp
...    NRCELL-6:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-6:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-6:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-5/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-5/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-5/NRREL-1:gNbId=1
...    NRCELL-5/NRREL-1:gNbIdLength=22
...    NRCELL-5/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-5/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-5/NRREL-1:lcrId=1
...    NRCELL-5/NRREL-1:nrDcAllowed=false
...    NRCELL-5/NRREL-1:removeNotAllowed=false
...    NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-5/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-5/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-5/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-5/NRREL-1:isRplCellForPSCell=false
...    NRCELL-5/NRREL-1:sCellPrio=2
...    NRCELL-6/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-6/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-6/NRREL-1:gNbId=1
...    NRCELL-6/NRREL-1:gNbIdLength=22
...    NRCELL-6/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-6/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-6/NRREL-1:lcrId=1
...    NRCELL-6/NRREL-1:nrDcAllowed=false
...    NRCELL-6/NRREL-1:removeNotAllowed=false
...    NRCELL-6/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-6/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-6/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-6/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-6/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-6/NRREL-1:isRplCellForPSCell=false
...    NRCELL-6/NRREL-1:sCellPrio=2

@{A014_para_recover}
...    NRBTS:actFlexSCellSelectFr1=true
...    delete:NRCELL-14/NRREL-1
...    delete:NRCELL-17/NRREL-1
...    delete:NRCELL-18/NRREL-1
...    delete:NRCELL-5/NRREL-1
...    delete:NRCELL-6/NRREL-1
...    delete:NRCELL:maxNumScellsDlFr1

${n41A-n66(2A)-n71A-n77A}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C8000E00365FFFE5FFFE0541B10758636869315020F2CA4D1
...    068032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B90001C006D2AAA92AAA80AA3626EB04610D040
...    83A41A00B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FFC00170000381506C18D608CA1A0810796526CA0D00656
...    C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001720003800DA555525555015C6C25D608C21A0810748340
...    1B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8002E0000702A8D899AC1184341020E906802CB64C
...    550D0E7C471E819F604F8C73E618F28581C0E1E05C00FFC007003FF0005C0000E0541B11B582308682041F28340195B262AC4873E238F604F
...    8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000005C0000E00A3C3C41000E230000000B0102F0F09400389A0000042C040BC5C2800
...    0E2080071180000105808178F830001C41000E20800711800001858087EF0F0A000389A0000102C040B83C28000E208000050B0102F0F1040
...    0388C0000182C040BC3C41000E268000070B0102F170A0003882001C41000010160205E2E14000711800388C0000242C040BC5C41000E2080
...    071180000505808178B882001C46000E2300000B0B0102F0F11800389A0000302C040BC7C18000E20800711800388C0000342C044FBC7C410
...    00E2600071300038980000382C040BC5C41000E2680071340000785808178F882001C41000E2680071340000805808140385000004400F1F0
...    60003830001C41000E2300000D0B0102F27104003882001C46000E14000713000009058081009011A014404D808301305D004040C290A244D
...    8E7C3851226C73E1C4891226C73E1C68912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7
...    C38912244D8E7C38912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E01B0C3811A040810
...    3639F0E4408102040D9EFCB074506318C6318C6318C6318C6318C7A0B800F000A070500703009401C0018090010180F818008000000040000
...    08020000080100000600800004004000028020000180100000E0080000800400004802000028010000160080000C033829795179317933783
...    3783178337953793379293A2978393A5140B06000000600018000101801060000806000180003018000600010060001800050180006000180
...    6000180007018000600020060001800090180006000280600018000B0180002FC160BE5545F2682F91C17C1A0BE0D05F0682F95417C960BE8
...    B45F07827A54002C009001A05000904140080180A013016028140080180A013016028202010020080200420100400804008010100200460A0
...    0400C0500980B0140A00400C0500980B0140A00400C0500980B0140A00400C0500980B01410100600C0401002080802004020040084040200
...    40100200420200400808020042010040080400801010020044020080100801002020040088140080180A013016028140080180A0130160281
...    40080180A01301602840A00400C0500980B0140A00400C0500980B0140A00400C0500980B014101002004040100218280100301402602C050
...    280100301402602C050280100301402602C050280100301402602C050C0C0080180700206020014010020300600E024018180300701200C40
...    201C008080900602024018C04038010100E00404048030101200C0020080110140080180A013016028140080180A013016028140080180A01
...    3016028140100280C01701A030140100280C01701A0306A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD0
...    5060B4

@{5DL1UL_expect_regexp_UE2}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:55, scellIdx:1] configure_1_1
...    pcid:62, scellIdx:2] configure_1_1
...    pcid:64, scellIdx:3] configure_1_1
...    pcid:66, scellIdx:4] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{5DL1UL_expect_regexp_UE1}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:54, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    pcid:64, scellIdx:3] configure_1_1
...    pcid:66, scellIdx:4] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{5DL1UL_expect_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:54, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    pcid:64, scellIdx:3] configure_1_1
...    pcid:68, scellIdx:4] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{A001_PM_Counters_Check}
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=3
...    NRCELL-1:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-15:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-17:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=3
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=3
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=3
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=3

${GNB_SCELL_4_ADMI_SUCC_SA}    M55138C00049
#GNB_SCELL_4_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 4 SCells
#before the CA configuration on RRC
${UE_PCELL_4_CONF_SCELL_DL_SA}    M55118C02016
#UE_PCELL_4_CONF_SCELL_DL_SA    The total number of CA UEs in the current cell configured as a PCell that have exactly 4
#configured SCells in DL in SA mode
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
#UE_SCELL_4_CONF_SCELL_DL_SA    The sum of samples for the total number of CA UEs in the current cell configured as an
#SCell while pegged in the secondary cell that has four configured SCells in DL in SA mode.
${GNB_DU_SCELL_4_ADMI_REQ_SA}    M55139C00023
#GNB_DU_SCELL_4_ADMI_REQ_SA    This counter describes the number of radio admission requests for exactly 4 SCells before
#the CA configuration on RRC.
${GNB_DU_SCELL_4_ADMI_SUCC_SA}    M55139C00024
#GNB_DU_SCELL_4_ADMI_SUCC_SA    This counter describes the number of successful radio admission requests for exactly 4
#SCells before the CA configuration on RRC
${RRC_RECONF_ADD4DLSCELL_ATT_SA}    M55118C02015
#RRC_RECONF_ADD4DLSCELL_ATT_SA    This counter indicates the total number of RRC Reconfiguration attempts for 4 SCells
#Addition in DL for SA mode
${RRC_RECONF_ADD4DLSCELL_SUCC_SA}    M55118C02014
#RRC_RECONF_ADD4DLSCELL_SUCC_SA    This counter indicates the total number of successful RRC Reconfiguration attempts for
#4 SCells Addition in DL for SA mode.

@{PM_Counters_Check_A014}
...    NRCELL-14:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-14:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-14:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-14:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=1
...    NRCELL-14:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=1
...    NRCELL-14:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-17:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-17:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-17:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-17:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=1
...    NRCELL-17:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=1
...    NRCELL-17:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-18:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=2
...    NRCELL-18:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-18:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-18:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=1
...    NRCELL-18:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=1
...    NRCELL-18:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-5:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=2
...    NRCELL-5:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}=0
...    NRCELL-5:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-5:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=0
...    NRCELL-5:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=0
...    NRCELL-5:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=0
...    NRCELL-6:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=3
...    NRCELL-6:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=3
...    NRCELL-6:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=3
...    NRCELL-6:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=3
...    NRCELL-6:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=3
...    NRCELL-6:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
# This counter indicates the number of successful radio admission requests for exactly 1 SCell before the CA configuration on RRC.
# It's measured in PCell in SA mode only.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as a PCell with 1 configured SCell in DL.
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
# This counter indicates the number of radio admission requests for exactly 1 SCell before the CA configuration on RRC.
# It's measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter indicates the number of successful radio admission requests for exactly 1 SCell before the CA configuration on RRC.
# It's measured in PCell in SA mode in DU only.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
# Sum of CA UEs in the current cell configured as an SCell with 1 configured SCell in DL.
${RRC_RECONF_ADD1DLSCELL_ATT_SA}    M55118C05505
# This counter indicates the total number of RRC reconfiguration attempts for 1 SCell addition in DL in SA mode.
${RRC_RECONF_ADD1DLSCELL_SUCC_SA}    M55118C05506
# This counter indicates the total number of successful RRC reconfiguration attempts for 1 SCell addition in DL in SA mode.

*** Test Cases ***
CB008950-ET-A001-A006-B1B4-Configure_11_incoming_and_outgoing_CA_relation_3or2scells_samefre_total_7_freq_covbased_intragNB_SA
    [Documentation]
    ...    1. This user scenario validates the activation and deactivation of "Increased number of NR FR1 CA relations"
    ...    feature via NRBTS/actFlexSCellSelectFr1 and the configuration of the maximum supported 11 outgoing and 11
    ...    incoming CA relations in case of intra-gNB CA.
    ...    And this TA case including A001(activation CB008950 feature) and A006 (deactivation CB008950 feature).
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-6    Cell-13    Cell-15    Cell-17
    ...    Technology                    TDD      FDD       FDD         FDD         FDD
    ...          Band                    n41      n77       n66         n66         n71
    ...           Pci                     50       55       62          64          66
    ...     Bandwidth                    100      100       10          10          15
    ...         Arfcn                   517800    650000    425100     432000      126000
    ...        LCELNR                   DL/UL     DL        DL          DL          DL
    ...    maxNumOfUsersPerNRCell     all cells are 275
    ...    maxNumOfSCellAlloc         all cells are 250
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...           a. UE2 attach to cell-1, setup PDU session.
    ...           b. Enable CB008950 featrue and add three NRRELs(Cell-6, Cell-13 and Cell-17) of Cell1.
    ...           c. UE2 start traffic and trigger A1 CA scell addition.
    ...           d. UE1 attach to cell-1, setup PDU session and trigger CA scell add then start traffic.
    ...           e. Disable CB008950 featrue and delete three NRRELs of Cell-1.
    ...           f. UE2 detach from cell-1
    ...           g. UE2 attach to cell-1, setup PDU session.
    ...           h. UE2 start traffic and trigger A1 CA scell addition.

    ...    4. Expected Results:
    ...           a. UE2 PDU session setup successfully.
    ...           b. Enable CB008950 featrue and add three NRRELs.
    ...           c. UE2 traffic to be as expect and trigger A1 CA scell(new NRRELs added) addition successfully.
    ...           d. UE1 attach to cell-1, PDU session setup, scell add and start traffic as expect.
    ...           e. Disable CB008950 featrue and delete three NRRELs of Cell-1 successfully.
    ...           f. UE2 detach successfully.
    ...           g. UE2 attach to cell-1, setup PDU session successfully.
    ...           h. UE2 start traffic and trigger A1 CA scell addition successfully.

    [Tags]    A001    QC_47171    CA_LABEL-TTFFF(100M_TDD_n41+100M_TDD_n77+10M_FDD_n66+10M_FDD_n66+10M_FDD_n71)
    UE attach and No Scell added    ue_id=2
    OnlineParamChange    ${PARAMS_FOR_8950}
    Check Throughput For UE2 And trigger A1 CA Scell Addition    ue_id=2
    UE attach and Scell added coverbase     ue_id=1    CC_num=5
    OnlineParamChange    ${PARAMS_FOR_8950_disable}
    UE Detach    ue_id=2
    UE attach and No Scell added    ue_id=2
    Check Throughput For UE2 And trigger A1 CA Scell Addition    ue_id=2    expect_regexp=${5DL1UL_expect_regexp}
    Check Counters    ${A001_PM_Counters_Check}

CB008950_A014_B6_Configure_max_incoming_CA_then_actFlexSCellSelectFr1_false
    [Documentation]
    ...    1. This user scenario validates that, when CB0008950 is deactivated and the number of incoming CA relations for a cell is
    ...       beyond the supported limit, gNB-DU rejects to add that cell as SCell for a UE only if this would require the creation of
    ...       another incoming CA relation. Use RD flag rdMaxActiveIncomingCaRelFlexSCellSelect=4 and rdMaxIncomingCaRel=2 to set the
    ...       max number of incoming CA relation for GNB is '4' when CB0008950 is actived, and limit '2' when CB0008950 is deactivated.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-5    Cell-6    Cell-14    Cell-17    Cell-18
    ...    Technology                    TDD       TDD       TDD        FDD        FDD       FDD
    ...          Band                    n41       n77       n77        n66        n71       n71
    ...           Pci                     50       54        55         63         66        67
    ...     Bandwidth                    100       100       100        20         15        15
    ...         Arfcn                  517800    656000     650000    424380     126000     126000
    ...        LCELNR                     DL      DL/UL      DL/UL      DL/UL      DL/UL      DL/UL
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...           a. UE1 attach to cell-14, setup PDU session and blind add scell cell1 successfully, then start traffic.
    ...           b. UE2 attach to cell-17, setup PDU session and blind add scell cell1 successfully, then start traffic.
    ...           c. UE3 attach to cell-18, setup PDU session and trigger A1 MR but add scell cell1 failed, because when CB0008950 is deactivated
    ...              the number of incoming CA relation beyond the supported limit '2', then start traffic.
    ...           d. Online modify CB0008950 flag NRBTS:actFlexSCellSelectFr1=true.
    ...           e. UE3 trigger A1 MR again, and scell cell1 is added successfully.
    ...           f. UE4 attach to cell-6, setup PDU session and trigger A1 MR, scell cell1 is added successfully.
    ...           g. UE5 attach to cell-5, setup PDU session and trigger A1 MR, scell cell1 is added failed, because when CB0008950 is activated
    ...              the number of incoming CA relation beyond the supported limit '4', then start traffic.
    ...           h. UE6 attach to cell-6, setup PDU session and trigger A1 add scell cell1 successfully (CA relation is existing),
    ...              then start traffic, check traffic is ok and release UE6.
    ...           i. Online modify CB0008950 flag NRBTS:actFlexSCellSelectFr1=false.
    ...           j. Check Throughput for UE1~5, traffic is OK.
    ...           k. UE5 trigger A1 MR again, and scell cell1 is still added failed for now 2 different CA relation are existing.
    ...           l. UE6 attach to cell-6, setup PDU session and trigger A1 add scell cell1 successfully(CA relation is existing),
    ...              then start traffic, check traffic is ok and release UE6.
    [Tags]    QC_325411    A014    CA_LABEL-TT(100M_TDD_n77+100M_TDD_n41)    CA_LABEL-FT(20M_FDD_n66+100M_TDD_n41)
    ...       CA_LABEL-FT(10M_FDD_n71+100M_TDD_n41)
    [Setup]    Preconfiguration for case A014    ${PARAMS_FOR_A014}
    Clear Counter files    True
    UE1-2 register and create two incoming CA relation
    UE attach and trigger A1 covBased Scell addition failed    ue_id=3    cell=18    gw=3    freq=125790
    OnlineParamChange    NRBTS:actFlexSCellSelectFr1=true
    Create other two incoming CA relation for UE3-4
    UE attach and trigger A1 covBased Scell addition failed    ue_id=5    cell=5    gw=5    freq=655968
    UE register and add scell with existing incoming CA relation successfully    ue_id=6    cell=6    gw=6    freq=649920
    Deactivate actFlexSCellSelectFr1 and check all UEs
    UE Send A1 Trigger Scell Addition failed    ue_id=5    cellfreq=655968    fail_reg=SCellIndex 1 activated successfully
    UE register and add scell with existing incoming CA relation successfully    ue_id=6    cell=6    gw=6    freq=649920
    Check wireshark log And Counters
    [Teardown]    A014 Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/18cells_6T12F

Modify Cfg
    ${V_1}    catenate
    ...    set_uec id=1 ip=$DAEMON_IP:$DAEMON_PORT pdn=1 devtype=tun addr=72.22.0.1/26
    ...    peer=$DAEMON_IP:2152 gtpu=off retries=unlimited ctrl_conn_timeout=150000
    Update Cfg    ${V_1}

UE attach and No Scell added
    [Arguments]    ${ue_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${n41A-n66(2A)-n71A-n77A}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}

UE attach and Scell added coverbase
    [Arguments]    ${ue_id}=1    ${CC_num}=5
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${n41A-n66(2A)-n71A-n77A}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}
    UE Send A1 Trigger Scell Addition    ${ue_id}    517710    expect_regexp=${5DL1UL_expect_regexp_UE1}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=810    CC_num=${CC_num}    type=pdsch

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=PDU SESSION ID-1 setup/reestablishment complete

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${expect_regexp}=${5DL1UL_expect_regexp_UE1}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${expect_regexp}

UE Send A1 Trigger Scell Addition failed
    [Arguments]    ${ue_id}    ${cellfreq}    ${fail_reg}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52    fail_regexp=${fail_reg}

Start Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=3 mbps=15    UE ${ue_id}: UDP UL

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=80    UE ${ue_id}: UDP UL

Traffic Send For UE2
    [Arguments]    ${ue_id}=2
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=80    UE ${ue_id}: UDP UL

Check Throughput For UE2 And trigger A1 CA Scell Addition
    [Arguments]    ${ue_id}=2    ${expect_regexp}=${5DL1UL_expect_regexp_UE2}
    Traffic Send For UE2    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput For UE2    ue_id=2
    UE Send A1 Trigger Scell Addition    ue_id=2    cellfreq=517710    expect_regexp=${expect_regexp}
    Check Throughput with Type UE2    ue_id=${ue_id}    Tput_expect=270    CC_num=5    type=pdsch

Check Throughput For UE2
    [Arguments]    ${ue_id}=2
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 72
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 270

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=80    ${Tput_ULexp}=72    ${CC_num}=2    ${type}=pdsch
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${Tput_ULexp}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    #Should Be True    ${scell_tput}/1000 > 0

Check Throughput with Type UE2
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 72
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check UE2    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}

Scell Throughput Check UE2
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=600

Preconfiguration for case A014
    [Arguments]    ${Online_Param}
    Common Test Setup And Start To Capture Logs
    OnlineParamChange    ${Online_Param}

UE1-2 register and create two incoming CA relation
    UE attach and Scell added blindly    ue_id=1    cell=14    gw=1
    UE attach and Scell added blindly    ue_id=2    cell=17    gw=2

Create other two incoming CA relation for UE3-4
    UE Send A1 Trigger Scell Addition    ue_id=3    cellfreq=125790    expect_regexp=PhysCellId: 50] SCellIndex 1 activated successfully
    Execute Egate Command    data_trf_start ue=3 pdu=1 qfi=1 dir=dl trf_id=2 mbps=100    UE 3: UDP DL
    Execute Egate Command    data_trf_start ue=3 pdu=1 qfi=1 dir=ul trf_id=4 mbps=15    UE 3: UDP UL
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=3    Tput_expect=162    Tput_ULexp=27    CC_num=2    type=pdsch
    UE attach and trigger A1 covBased Scell addition    ue_id=4    cell=6    gw=4    freq=649920

UE register and add scell with existing incoming CA relation successfully
    [Arguments]    ${ue_id}=6    ${cell}=14    ${gw}=6    ${freq}=655968    ${CA_regexp}=PhysCellId: 50] SCellIndex 1 activated successfully
    UE Setup PDU Session And Check CA Addition    ue_id=${ue_id}    cell_id=${cell}    gateway=${gw}    PDU_regexp=QoS Routing Table
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=${freq}    expect_regexp=${CA_regexp}
    Start Traffic    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=270    Tput_ULexp=13    CC_num=2    type=pdsch
    Release Ues    ue_id=${ue_id}

deactivate actFlexSCellSelectFr1 and check all UEs
    OnlineParamChange    NRBTS:actFlexSCellSelectFr1=false
    Check Throughput for UEs

UE attach and Scell added blindly
    [Arguments]    ${ue_id}=1    ${cell}=1    ${gw}=1    ${CA_regexp}=PhysCellId: 50] SCellIndex 1 activated successfully
    UE Setup PDU Session And Check CA Addition    ue_id=${ue_id}    cell_id=${cell}    gateway=${gw}    PDU_regexp=${CA_regexp}
    Start Traffic    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=270    Tput_ULexp=13    CC_num=2    type=pdsch

UE Setup PDU Session And Check CA Addition
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${gateway}=1    ${pass_regexp}=NG RM Register    ${PDU_regexp}=SCellIndex 1 activated successfully
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${PDU_regexp}

UE attach and trigger A1 covBased Scell addition
    [Arguments]    ${ue_id}=1    ${cell}=1    ${gw}=1    ${freq}=655968    ${CA_regexp}=PhysCellId: 50] SCellIndex 1 activated successfully
    UE Setup PDU Session And Check CA Addition    ue_id=${ue_id}    cell_id=${cell}    gateway=${gw}    PDU_regexp=QoS Routing Table
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=${freq}    expect_regexp=${CA_regexp}
    Start Traffic    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=270    Tput_ULexp=13    CC_num=2    type=pdsch

UE attach and trigger A1 covBased Scell addition failed
    [Arguments]    ${ue_id}=1    ${cell}=1    ${gw}=1    ${freq}=655968    ${CA_regexp}=PhysCellId: 50] SCellIndex 1 activated
    UE Setup PDU Session And Check CA Addition    ue_id=${ue_id}    cell_id=${cell}    gateway=${gw}    PDU_regexp=QoS Routing Table
    UE Send A1 Trigger Scell Addition failed    ue_id=${ue_id}    cellfreq=${freq}    fail_reg=${CA_regexp}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=80    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=3 mbps=15    UE ${ue_id}: UDP UL
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=72    Tput_ULexp=13    CC_num=1    type=pdsch

Check Throughput for UEs
    Check Throughput with Type    ue_id=1    Tput_expect=270    Tput_ULexp=13    CC_num=2    type=pdsch
    Check Throughput with Type    ue_id=2    Tput_expect=270    Tput_ULexp=13    CC_num=2    type=pdsch
    Check Throughput with Type    ue_id=3    Tput_expect=180    Tput_ULexp=27    CC_num=2    type=pdsch
    Check Throughput with Type    ue_id=4    Tput_expect=270    Tput_ULexp=13    CC_num=2    type=pdsch
    Check Throughput with Type    ue_id=5    Tput_expect=72    Tput_ULexp=13    CC_num=1    type=pdsch

Check wireshark log And Counters
    #Check WireShark Log    ${CURDIR}${/}A2A_A014${/}a2a.ini    wait_string=UEContextRelease::24
    Check Counters    ${PM_Counters_Check_A014}
    Release UEs    ue_type=all

A014 Teardown
    OnlineParamChange    ${A014_para_recover}
    Common Test Teardown And Stop Capture Logs

UE Detach
    [Arguments]    ${ue_id}=2
    Execute Egate Command  ue_deregister id=${ue_id} ue_deregister_type=switch_off
