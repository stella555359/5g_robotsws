*** Settings ***
Documentation
...    author: Zhou Lingyan
...    contact: lingyan.zhou@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-lingyan.zhou    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

@{PARAMS_IN_SWCONFIG}
...    @{DUrdMaxActiveIncomingCaRelFlexSCellSelect}
...    @{DUrdMaxIncomingCaRel}
...    @{CUrdMaxActiveIncomingCaRelFlexSCellSelect}
...    @{CUrdMaxActiveOutgoingCaRelFlexSCellSelect}

@{DUrdMaxIncomingCaRel}
...    0x5901D2=10
@{DUrdMaxActiveIncomingCaRelFlexSCellSelect}
...    0x59021E=10

@{CUrdMaxActiveIncomingCaRelFlexSCellSelect}
...    0x89006C=3
@{CUrdMaxActiveOutgoingCaRelFlexSCellSelect}
...    0x89006D=4


@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_8950}

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
...    NRBTS:actSaUeBasedAnrNr=false
...    NRANR-1:actAutoNrNbRemoval=false

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{PARAMS_FOR_8950}
...    NRBTS:actFlexSCellSelectFr1=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:sCellActivationMethod=blind
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
...    NRCELL-3/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-17:gNbId=1
...    NRCELL-3/NRREL-17:gNbIdLength=22
...    NRCELL-3/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-17:lcrId=17
...    NRCELL-3/NRREL-17:nrDcAllowed=false
...    NRCELL-3/NRREL-17:removeNotAllowed=false
...    NRCELL-3/NRREL-17:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-17:isRplCellForPSCell=true
...    NRCELL-5/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-5/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-5/NRREL-17:gNbId=1
...    NRCELL-5/NRREL-17:gNbIdLength=22
...    NRCELL-5/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-5/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-5/NRREL-17:lcrId=17
...    NRCELL-5/NRREL-17:nrDcAllowed=false
...    NRCELL-5/NRREL-17:removeNotAllowed=false
...    NRCELL-5/NRREL-17:sCellAdditionMethod=blind
...    NRCELL-5/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-5/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-5/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-5/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-5/NRREL-17:isRplCellForPSCell=true
...    NRCELL-6/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-6/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-6/NRREL-17:gNbId=1
...    NRCELL-6/NRREL-17:gNbIdLength=22
...    NRCELL-6/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-6/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-6/NRREL-17:lcrId=17
...    NRCELL-6/NRREL-17:nrDcAllowed=false
...    NRCELL-6/NRREL-17:removeNotAllowed=false
...    NRCELL-6/NRREL-17:sCellAdditionMethod=blind
...    NRCELL-6/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-6/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-6/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-6/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-6/NRREL-17:isRplCellForPSCell=true
...    @{PARAMS_FOR_CA}
...    @{PARAMS_8290_related}
...    NRCELL-6:maxNumOfSCellAlloc=250

@{PARAMS_FOR_8950_NRREL_scelladd_scellope}
...    NRBTS:actFlexSCellSelectFr1=true
...    NRCELL-1/NRREL-6:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-6:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-17:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-17:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-5/NRREL-17:sCellAdditionMethod=blind
...    NRCELL-5/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-6/NRREL-17:sCellAdditionMethod=blind
...    NRCELL-6/NRREL-17:sCellOperationalMode=dlOnly

@{PARAMS_FOR_8950_NRREL_scelladd_scellope_delete}
...    NRBTS:actFlexSCellSelectFr1=false
...    delete:NRCELL-1/NRREL-6:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-6:sCellOperationalMode
...    delete:NRCELL-1/NRREL-13:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-13:sCellOperationalMode
...    delete:NRCELL-1/NRREL-17:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-17:sCellOperationalMode
...    delete:NRCELL-3/NRREL-17:sCellAdditionMethod
...    delete:NRCELL-3/NRREL-17:sCellOperationalMode
...    delete:NRCELL-5/NRREL-17:sCellAdditionMethod
...    delete:NRCELL-5/NRREL-17:sCellOperationalMode
...    delete:NRCELL-6/NRREL-17:sCellAdditionMethod
...    delete:NRCELL-6/NRREL-17:sCellOperationalMode

@{PARAMS_FOR_NRCELL-6-setscelluserslimitto1}
...    NRCELL-6:maxNumOfSCellAlloc=1


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

@{PARAMS_FOR_sCellExcludelistTimerA2Fr1_only_leave_one_scell_candidate}
...    NRBTS:sCellExcludelistTimerA2Fr1=300
...    delete:NRCELL-1/NRREL-2:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-2:sCellOperationalMode
...    delete:NRCELL-1/NRREL-4:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-4:sCellOperationalMode
...    delete:NRCELL-1/NRREL-5:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-5:sCellOperationalMode
...    delete:NRCELL-1/NRREL-6:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-6:sCellOperationalMode
...    delete:NRCELL-1/NRREL-11:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-11:sCellOperationalMode
...    delete:NRCELL-1/NRREL-12:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-12:sCellOperationalMode
...    delete:NRCELL-1/NRREL-13:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-13:sCellOperationalMode
...    delete:NRCELL-1/NRREL-15:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-15:sCellOperationalMode
...    delete:NRCELL-1/NRREL-19:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-19:sCellOperationalMode
...    delete:NRCELL-1/NRREL-20:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-20:sCellOperationalMode

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


@{2cc_expect_UE3}
...    pcid:52, scellIdx:0] configure_0_1
...    pcid:52, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone


@{2cc_expect_UE4}
...    pcid:54, scellIdx:0] configure_0_1
...    pcid:54, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{2cc_expect_UE5}
...    pcid:55, scellIdx:0] configure_0_1
...    pcid:55, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

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


@{scellchange_unexpect_UE1_1st}
...    pcid:54, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone


@{scellchange_expect_regexp_UE1_2nd}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:54, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{UE_swap_check_common}
...    sCellToReleaseList
...    activated successfully at airphone


@{UE1_swap_to68}
...    sCellToReleaseList
...    pcid:68, scellIdx:1] configure_1_1
...    activated successfully at airphone

@{UE1_swap_to66}
...    sCellToReleaseList
...    pcid:66, scellIdx:2] configure_1_1
...    activated successfully at airphone

@{2cc_expect_UE6}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone



@{Restore_D005}
...    NRCELL-6:maxNumOfSCellAlloc=250
...    NRBTS:sCellExcludelistTimerA2Fr1=0
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
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-6:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-6:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-15:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-19:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-20:sCellOperationalMode=dlOnly

*** Test Cases ***
CB008950-ET-D005_FR1_SA_CA_scell_change_scell_swap_incoming-outgoing_does_not_exceed_the_CU_limit_intragNB
    [Documentation]
    ...    1. This user scenario validates that scell change and scell swap when exceed incoming-outgoing limit
    ...    2. Configuration
    ...    6TDD12FDD cells detail:
    ...                  band  PCI  gscn  ssb        nrcellid   chbw
    ...       NRCELL_1    41   50    1     517710    16385       100M
    ...       NRCELL_2    41   51    1               16386       100M
    ...       NRCELL_3    41   52    1     517710    16387       100M
    ...       NRCELL_4    41   53    1     xxxxxx    16388       100M
    ...       NRCELL_5    77   54    1     655968    16389       100M
    ...       NRCELL_6    77   55    1     649920    16390       100M
    ...   NRCELL_11-12    66  60-61 5300   424090    16395-96    10M
    ...       NRCELL_13   66   62   5313   425070    16397       10M
    ...       NRCELL_14   66   63   5313   425070    16398       20M
    ...   NRCELL_15-16    66  64-65 5397   431790    16399-40    10M
    ...   NRCELL_17-20    71  66-69 1572   125790    16401-04    10M
    ...   NRCELL_21-22    71  70-71 1603   128210    16405-06    10M
    ...    2. Test Case Steps:
    ...           a. UE1 UE2 attach to PCI 50, trigger A1 MR to add 4 scells.55-62-64-66
    ...           b. UE2 A2 scell release 55, then want to trigger A6 scell swap and scell change failed as maxoutgoing limit
    ...              UE2 P 50, S 62/64/66.
    ...           c. UE1 2 A2 scells release then UE2 can scell change and UE2 scell swap
    ...              UE1 P 50, S 64/68, UE2, P 50, S 54
    ...           d. UE3/4/5 add PCI 66 as scell and UE1 try to scell swap from 68 to 66 failed as incoming limit
    ...              then UE3 release, UE1 can scell swap to 66.
    ...               UE4 P 54, S 66, UE5 P 55, S 66, UE1 P 50, S 64/66
    [Tags]    D005    QC_46936    CA_LABEL-TTFFF(100M_TDD_n41+100M_TDD_n77+10M_FDD_n66+10M_FDD_n66+10M_FDD_n71)
    Steps to add 5CC UE1-UE2 with Pcell50Scells55-62-64-66
    Steps to trigger UE2 A2 scell release and then UE2 scell change and scell swap failed as outgoingmax
    Steps to UE1 A2 release 2scells and UE2 scell change and UE1 swap can work
    Steps to test PCI66 incomingmax and UE1 scell swap failed after UE3 Release then UE1 can scell swap
    Steps to test EDA PR804138 sCellExcludelistTimerA2Fr1
    [Teardown]    Test teardown for D005

*** Keywords ***
Steps to test EDA PR804138 sCellExcludelistTimerA2Fr1
    OnlineParamChange    ${PARAMS_FOR_sCellExcludelistTimerA2Fr1_only_leave_one_scell_candidate}
    UE attach and Scell added coverbase     ue_id=6    CC_num=2    expect_regexp=${2cc_expect_UE6}
    trigger A2 MR to release scell    carrierfreq=125790    scell_index=1    ue_id=6
    UE Send A1 Trigger Scell Addition    ue_id=6    cellfreq=517710    expect_regexp=${2cc_expect_UE6}
    trigger A2 MR to release scell    carrierfreq=125790    scell_index=1    ue_id=6
    UE Send A1 Trigger Scell Addition    ue_id=6    cellfreq=517710    expect_regexp=${2cc_expect_UE6}

Steps to add 5CC UE1-UE2 with Pcell50Scells55-62-64-66
    OnlineParamChange    ${PARAMS_FOR_8950_NRREL_scelladd_scellope_delete}
    OnlineParamChange    ${PARAMS_FOR_8950_NRREL_scelladd_scellope}
    UE attach and No Scell added    ue_id=1
    Check Throughput For UE1 And trigger A1 CA Scell Addition    ue_id=1
    UE attach and Scell added coverbase     ue_id=2    CC_num=5    expect_regexp=${5DL1UL_expect_regexp_UE2}

Steps to trigger UE2 A2 scell release and then UE2 scell change and scell swap failed as outgoingmax
    trigger A2 MR to release scell    carrierfreq=649920    scell_index=1    ue_id=2
    OnlineParamChange    ${PARAMS_FOR_NRCELL-6-setscelluserslimitto1}
    UE Send A1 Trigger Scell Addition    ue_id=2    cellfreq=517710    expect_regexp=${EMPTY}    fail_reg_ca=${scellchange_unexpect_UE1_1st}
    Trigger A6swap_scell234    ue_id=2    carrierfreq=125790    scell_index=4    phycell_id=68
    ...    pass_regexp=${EMPTY}    fail_regexp=${UE1_swap_to68}

Steps to UE1 A2 release 2scells and UE2 scell change and UE1 swap can work
    trigger A2 MR to release scell    carrierfreq=649920    scell_index=1    ue_id=1
    UE Send A1 Trigger Scell Addition    ue_id=2    cellfreq=517710    expect_regexp=${scellchange_expect_regexp_UE1_2nd}
    Trigger A6swap    ue_id=1    carrierfreq=125790    scell_index=4    phycell_id=68
    ...    pass_regexp=${EMPTY}    fail_regexp=${UE1_swap_to68}
    trigger A2 MR to release scell    carrierfreq=425070    scell_index=2    ue_id=1
    Trigger A6swap    ue_id=1    carrierfreq=125790    scell_index=4    phycell_id=68    pass_regexp=${UE1_swap_to68}

Steps to test PCI66 incomingmax and UE1 scell swap failed after UE3 Release then UE1 can scell swap
    UE attach and Scell added blind    ue_id=3    CC_num=2    cell_id=3    pass_regexp=${2cc_expect_UE3}
    UE attach and Scell added blind    ue_id=4    CC_num=2    cell_id=5    pass_regexp=${2cc_expect_UE4}
    UE attach and Scell added blind    ue_id=5    CC_num=2    cell_id=6    pass_regexp=${2cc_expect_UE5}
    Trigger A6swap    ue_id=1    carrierfreq=125790    scell_index=1    phycell_id=66
    ...     pass_regexp=${EMPTY}    fail_regexp=${UE_swap_check_common}
    Release Ues    ue_id=3
    Trigger A6swap    ue_id=1    carrierfreq=125790    scell_index=1    phycell_id=66    pass_regexp=${UE1_swap_to66}


Test teardown for D005
    OnlineParamChange    ${Restore_D005}
    Common Test Teardown And Stop Capture Logs

Trigger A6swap
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125790    ${scell_index}=4    ${phycell_id}=68
                   ...    ${pass_regexp}=${UE_swap_check_common}    ${fail_regexp}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A6    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A6 meas_id=${meas_id} srsrp_nr=60 srsrq_nr=60
    ...    scell=${scell_index} scell_rsrp=10 scell_rsrq=10 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Check Throughput with Type_withSwap    ue_id=${ue_id}

Trigger A6swap_scell234
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125790    ${scell_index}=4    ${phycell_id}=68
                   ...    ${pass_regexp}=${UE_swap_check_common}    ${fail_regexp}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A6    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A6 meas_id=${meas_id} srsrp_nr=60 srsrq_nr=60
    ...    scell=${scell_index} scell_rsrp=10 scell_rsrq=10 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Check Throughput with Type_withSwap_scell234    ue_id=${ue_id}

Check Throughput with Type_withSwap_scell234
    [Arguments]    ${ue_id}=2
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${scell4_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=4    type=pdsch    rate_type=ave
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    ${all_tput}    Evaluate    ${scell0_tput}+${scell4_tput}+${scell2_tput}+${scell3_tput}
    Should Be True    ${all_tput}/1000>405
    ${scell_ultput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_ultput}/1000 > 3


Check Throughput with Type_withSwap
    [Arguments]    ${ue_id}=2
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Be True    ${dl_throughput}/1000>0
    ${scell_ultput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_ultput}/1000 > 3


trigger A2 MR to release scell
    [Arguments]    ${carrierfreq}=125310    ${scell_index}=3    ${ue_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret2}    sCellToReleaseList


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
    [Arguments]    ${ue_id}=1    ${CC_num}=5    ${cell_id}=1    ${expect_regexp}=${5DL1UL_expect_regexp_UE2}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${n41A-n66(2A)-n71A-n77A}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}    cell_id=${cell_id}
    UE Send A1 Trigger Scell Addition    ${ue_id}    517710    expect_regexp=${expect_regexp}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=200    CC_num=${CC_num}    type=pdsch

UE attach and Scell added blind
    [Arguments]    ${ue_id}=1    ${CC_num}=2    ${cell_id}=15    ${pass_regexp}=${2cc_expect_UE3}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${n41A-n66(2A)-n71A-n77A}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}    cell_id=${cell_id}    pass_regexp=${pass_regexp}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=200    CC_num=${CC_num}    type=pdsch



Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${pass_regexp}=PDU SESSION ID-1 setup/reestablishment complete
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${expect_regexp}=${5DL1UL_expect_regexp_UE1}    ${fail_reg_ca}=${EMPTY}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${expect_regexp}
    ...    fail_regexp=${fail_reg_ca}

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=50    UE ${ue_id}: UDP UL

Traffic Send For UE2
    [Arguments]    ${ue_id}=2
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=80    UE ${ue_id}: UDP UL

Check Throughput For UE1 And trigger A1 CA Scell Addition
    [Arguments]    ${ue_id}=2    ${expect_regexp}=${5DL1UL_expect_regexp_UE2}
    Traffic Send For UE2    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput For UE2    ue_id=${ue_id}
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=517710    expect_regexp=${expect_regexp}
    Check Throughput with Type UE2    ue_id=${ue_id}    Tput_expect=270    CC_num=5    type=pdsch

Check Throughput For UE2
    [Arguments]    ${ue_id}=2
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 72
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 270

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${Tput_expect}=80    ${Tput_ULexp}=10    ${CC_num}=2    ${type}=pdsch
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${Tput_ULexp}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${id}    ${type}    rate_type=ave
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}


Check Throughput with Type UE2
    [Arguments]    ${ue_id}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
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




