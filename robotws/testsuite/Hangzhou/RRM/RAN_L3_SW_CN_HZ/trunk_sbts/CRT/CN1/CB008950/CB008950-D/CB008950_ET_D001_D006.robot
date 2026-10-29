*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-lingyan.zhou    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${CaSup}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa

@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

@{PARAMS_IN_SWCONFIG_AP}    0x5C0009=1

${rdMaxActiveIncomingCaRelFlexSCellSelect}    0x89006C
${rdMaxActiveOutgoingCaRelFlexSCellSelect}    0x89006D


@{PARAMS_IN_SWCONFIG}
...    ${rdMaxActiveIncomingCaRelFlexSCellSelect}=3
...    ${rdMaxActiveOutgoingCaRelFlexSCellSelect}=4

@{PARAMS_FOR_8290_SCellSwap_enable}
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

@{PARAMS_FOR_A1sCellAdd_A2_for_NRCELL}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms




@{PARAMS_ADD_incoming_outgoing_NRRELs}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:maxNumScellsDlFr1=4
...    @{PARAMS_FOR_A1sCellAdd_A2_for_NRCELL}
...    NRBTS:actFlexSCellSelectFr1=true
...    @{PARAMS_FOR_8290_SCellSwap_enable}
...    NRCELL-25:a6MeasSCellSwapEnabled=rsrq
...    NRCELL-16:a6MeasSCellSwapEnabled=rsrpAndRsrq
...    @{13NRRELs_n71_of_NRCELL28}
...    @{4NRRELs_n66_of_NRCELL28}
...    @{4NRRELs_n25_of_NRCELL28}
...    @{Scells_NRCELL28_of_NRCELL16-25-26-24}



@{Scells_NRCELL28_of_NRCELL16-25-26-24}
...    NRCELL-16/NRREL-31:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-16/NRREL-31:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-16/NRREL-31:gNbId=2
...    NRCELL-16/NRREL-31:gNbIdLength=22
...    NRCELL-16/NRREL-31:handoverAllowedSA=allowed
...    NRCELL-16/NRREL-31:handoverAllowedSARedCap=forbidden
...    NRCELL-16/NRREL-31:lcrId=28
...    NRCELL-16/NRREL-31:nrDcAllowed=false
...    NRCELL-16/NRREL-31:removeNotAllowed=false
...    NRCELL-16/NRREL-31:sCellAdditionMethod=covBasedA1
...    NRCELL-16/NRREL-31:sCellOperationalMode=dlOnly
...    NRCELL-16/NRREL-31:gnbPlmn:mcc=311
...    NRCELL-16/NRREL-31:gnbPlmn:mnc=489
...    NRCELL-16/NRREL-31:gnbPlmn:mncLength=3
...    NRCELL-16/NRREL-31:sCellPrio=5
...    NRCELL-25/NRREL-31:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-25/NRREL-31:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-25/NRREL-31:gNbId=2
...    NRCELL-25/NRREL-31:gNbIdLength=22
...    NRCELL-25/NRREL-31:handoverAllowedSA=allowed
...    NRCELL-25/NRREL-31:handoverAllowedSARedCap=forbidden
...    NRCELL-25/NRREL-31:lcrId=28
...    NRCELL-25/NRREL-31:nrDcAllowed=false
...    NRCELL-25/NRREL-31:removeNotAllowed=false
...    NRCELL-25/NRREL-31:sCellAdditionMethod=covBasedA1
...    NRCELL-25/NRREL-31:sCellOperationalMode=dlOnly
...    NRCELL-25/NRREL-31:gnbPlmn:mcc=311
...    NRCELL-25/NRREL-31:gnbPlmn:mnc=489
...    NRCELL-25/NRREL-31:gnbPlmn:mncLength=3
...    NRCELL-25/NRREL-31:sCellPrio=5
...    NRCELL-26/NRREL-28:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-26/NRREL-28:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-26/NRREL-28:gNbId=2
...    NRCELL-26/NRREL-28:gNbIdLength=22
...    NRCELL-26/NRREL-28:handoverAllowedSA=allowed
...    NRCELL-26/NRREL-28:handoverAllowedSARedCap=forbidden
...    NRCELL-26/NRREL-28:lcrId=28
...    NRCELL-26/NRREL-28:nrDcAllowed=false
...    NRCELL-26/NRREL-28:removeNotAllowed=false
...    NRCELL-26/NRREL-28:sCellAdditionMethod=covBasedA1
...    NRCELL-26/NRREL-28:sCellOperationalMode=dlOnly
...    NRCELL-26/NRREL-28:gnbPlmn:mcc=311
...    NRCELL-26/NRREL-28:gnbPlmn:mnc=489
...    NRCELL-26/NRREL-28:gnbPlmn:mncLength=3
...    NRCELL-26/NRREL-28:sCellPrio=1
...    NRCELL-24/NRREL-28:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-24/NRREL-28:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-24/NRREL-28:gNbId=2
...    NRCELL-24/NRREL-28:gNbIdLength=22
...    NRCELL-24/NRREL-28:handoverAllowedSA=allowed
...    NRCELL-24/NRREL-28:handoverAllowedSARedCap=forbidden
...    NRCELL-24/NRREL-28:lcrId=28
...    NRCELL-24/NRREL-28:nrDcAllowed=false
...    NRCELL-24/NRREL-28:removeNotAllowed=false
...    NRCELL-24/NRREL-28:sCellAdditionMethod=covBasedA1
...    NRCELL-24/NRREL-28:sCellOperationalMode=dlOnly
...    NRCELL-24/NRREL-28:gnbPlmn:mcc=311
...    NRCELL-24/NRREL-28:gnbPlmn:mnc=489
...    NRCELL-24/NRREL-28:gnbPlmn:mncLength=3
...    NRCELL-24/NRREL-28:sCellPrio=1

#13NRRELs_n71
@{13NRRELs_n71_of_NRCELL28}
...    NRCELL-26:maxNumOfSCellAlloc=3
...    NRCELL-28/NRREL-26:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-26:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-26:gNbId=2
...    NRCELL-28/NRREL-26:gNbIdLength=22
...    NRCELL-28/NRREL-26:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-26:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-26:lcrId=26
...    NRCELL-28/NRREL-26:nrDcAllowed=false
...    NRCELL-28/NRREL-26:removeNotAllowed=false
...    NRCELL-28/NRREL-26:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-26:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-26:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-26:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-26:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-26:sCellPrio=4
...    NRCELL-28/NRREL-30:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-30:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-30:gNbId=2
...    NRCELL-28/NRREL-30:gNbIdLength=22
...    NRCELL-28/NRREL-30:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-30:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-30:lcrId=30
...    NRCELL-28/NRREL-30:nrDcAllowed=false
...    NRCELL-28/NRREL-30:removeNotAllowed=false
...    NRCELL-28/NRREL-30:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-30:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-30:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-30:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-30:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-30:sCellPrio=5
...    NRCELL-28/NRREL-31:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-31:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-31:gNbId=2
...    NRCELL-28/NRREL-31:gNbIdLength=22
...    NRCELL-28/NRREL-31:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-31:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-31:lcrId=31
...    NRCELL-28/NRREL-31:nrDcAllowed=false
...    NRCELL-28/NRREL-31:removeNotAllowed=false
...    NRCELL-28/NRREL-31:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-31:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-31:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-31:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-31:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-31:sCellPrio=5
...    NRCELL-28/NRREL-32:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-32:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-32:gNbId=2
...    NRCELL-28/NRREL-32:gNbIdLength=22
...    NRCELL-28/NRREL-32:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-32:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-32:lcrId=32
...    NRCELL-28/NRREL-32:nrDcAllowed=false
...    NRCELL-28/NRREL-32:removeNotAllowed=false
...    NRCELL-28/NRREL-32:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-32:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-32:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-32:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-32:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-32:sCellPrio=7
...    NRCELL-28/NRREL-33:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-33:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-33:gNbId=2
...    NRCELL-28/NRREL-33:gNbIdLength=22
...    NRCELL-28/NRREL-33:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-33:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-33:lcrId=33
...    NRCELL-28/NRREL-33:nrDcAllowed=false
...    NRCELL-28/NRREL-33:removeNotAllowed=false
...    NRCELL-28/NRREL-33:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-33:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-33:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-33:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-33:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-33:sCellPrio=8
...    NRCELL-28/NRREL-34:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-34:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-34:gNbId=2
...    NRCELL-28/NRREL-34:gNbIdLength=22
...    NRCELL-28/NRREL-34:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-34:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-34:lcrId=34
...    NRCELL-28/NRREL-34:nrDcAllowed=false
...    NRCELL-28/NRREL-34:removeNotAllowed=false
...    NRCELL-28/NRREL-34:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-34:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-34:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-34:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-34:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-34:sCellPrio=9
...    NRCELL-28/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-11:gNbId=2
...    NRCELL-28/NRREL-11:gNbIdLength=22
...    NRCELL-28/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-11:lcrId=11
...    NRCELL-28/NRREL-11:nrDcAllowed=false
...    NRCELL-28/NRREL-11:removeNotAllowed=false
...    NRCELL-28/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-11:sCellPrio=10
...    NRCELL-28/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-12:gNbId=2
...    NRCELL-28/NRREL-12:gNbIdLength=22
...    NRCELL-28/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-12:lcrId=12
...    NRCELL-28/NRREL-12:nrDcAllowed=false
...    NRCELL-28/NRREL-12:removeNotAllowed=false
...    NRCELL-28/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-12:sCellPrio=11
...    NRCELL-28/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-13:gNbId=2
...    NRCELL-28/NRREL-13:gNbIdLength=22
...    NRCELL-28/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-13:lcrId=13
...    NRCELL-28/NRREL-13:nrDcAllowed=false
...    NRCELL-28/NRREL-13:removeNotAllowed=false
...    NRCELL-28/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-13:sCellPrio=12
...    NRCELL-28/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-14:gNbId=2
...    NRCELL-28/NRREL-14:gNbIdLength=22
...    NRCELL-28/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-14:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-14:lcrId=14
...    NRCELL-28/NRREL-14:nrDcAllowed=false
...    NRCELL-28/NRREL-14:removeNotAllowed=false
...    NRCELL-28/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-14:sCellPrio=13
...    NRCELL-28/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-15:gNbId=2
...    NRCELL-28/NRREL-15:gNbIdLength=22
...    NRCELL-28/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-15:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-15:lcrId=15
...    NRCELL-28/NRREL-15:nrDcAllowed=false
...    NRCELL-28/NRREL-15:removeNotAllowed=false
...    NRCELL-28/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-15:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-15:sCellPrio=14
...    NRCELL-28/NRREL-20:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-20:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-20:gNbId=2
...    NRCELL-28/NRREL-20:gNbIdLength=22
...    NRCELL-28/NRREL-20:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-20:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-20:lcrId=20
...    NRCELL-28/NRREL-20:nrDcAllowed=false
...    NRCELL-28/NRREL-20:removeNotAllowed=false
...    NRCELL-28/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-20:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-20:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-20:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-20:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-20:sCellPrio=19
...    NRCELL-28/NRREL-21:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-21:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-21:gNbId=2
...    NRCELL-28/NRREL-21:gNbIdLength=22
...    NRCELL-28/NRREL-21:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-21:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-21:lcrId=21
...    NRCELL-28/NRREL-21:nrDcAllowed=false
...    NRCELL-28/NRREL-21:removeNotAllowed=false
...    NRCELL-28/NRREL-21:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-21:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-21:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-21:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-21:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-21:sCellPrio=20

#4NRRELs_n66
@{4NRRELs_n66_of_NRCELL28}
...    NRCELL-28/NRREL-22:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-22:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-22:gNbId=2
...    NRCELL-28/NRREL-22:gNbIdLength=22
...    NRCELL-28/NRREL-22:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-22:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-22:lcrId=22
...    NRCELL-28/NRREL-22:nrDcAllowed=false
...    NRCELL-28/NRREL-22:removeNotAllowed=false
...    NRCELL-28/NRREL-22:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-22:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-22:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-22:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-22:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-22:sCellPrio=21
...    NRCELL-28/NRREL-23:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-23:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-23:gNbId=2
...    NRCELL-28/NRREL-23:gNbIdLength=22
...    NRCELL-28/NRREL-23:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-23:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-23:lcrId=23
...    NRCELL-28/NRREL-23:nrDcAllowed=false
...    NRCELL-28/NRREL-23:removeNotAllowed=false
...    NRCELL-28/NRREL-23:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-23:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-23:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-23:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-23:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-23:sCellPrio=19
...    NRCELL-28/NRREL-24:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-24:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-24:gNbId=2
...    NRCELL-28/NRREL-24:gNbIdLength=22
...    NRCELL-28/NRREL-24:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-24:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-24:lcrId=24
...    NRCELL-28/NRREL-24:nrDcAllowed=false
...    NRCELL-28/NRREL-24:removeNotAllowed=false
...    NRCELL-28/NRREL-24:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-24:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-24:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-24:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-24:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-24:sCellPrio=17
...    NRCELL-28/NRREL-25:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-25:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-25:gNbId=2
...    NRCELL-28/NRREL-25:gNbIdLength=22
...    NRCELL-28/NRREL-25:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-25:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-25:lcrId=25
...    NRCELL-28/NRREL-25:nrDcAllowed=false
...    NRCELL-28/NRREL-25:removeNotAllowed=false
...    NRCELL-28/NRREL-25:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-25:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-25:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-25:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-25:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-25:sCellPrio=15

#4NRRELs_n25
@{4NRRELs_n25_of_NRCELL28}
...    NRCELL-28/NRREL-16:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-16:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-16:gNbId=2
...    NRCELL-28/NRREL-16:gNbIdLength=22
...    NRCELL-28/NRREL-16:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-16:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-16:lcrId=16
...    NRCELL-28/NRREL-16:nrDcAllowed=false
...    NRCELL-28/NRREL-16:removeNotAllowed=false
...    NRCELL-28/NRREL-16:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-16:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-16:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-16:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-16:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-16:sCellPrio=3
...    NRCELL-28/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-17:gNbId=2
...    NRCELL-28/NRREL-17:gNbIdLength=22
...    NRCELL-28/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-17:lcrId=17
...    NRCELL-28/NRREL-17:nrDcAllowed=false
...    NRCELL-28/NRREL-17:removeNotAllowed=false
...    NRCELL-28/NRREL-17:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-17:sCellPrio=3
...    NRCELL-28/NRREL-18:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-18:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-18:gNbId=2
...    NRCELL-28/NRREL-18:gNbIdLength=22
...    NRCELL-28/NRREL-18:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-18:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-18:lcrId=18
...    NRCELL-28/NRREL-18:nrDcAllowed=false
...    NRCELL-28/NRREL-18:removeNotAllowed=false
...    NRCELL-28/NRREL-18:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-18:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-18:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-18:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-18:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-18:sCellPrio=3
...    NRCELL-28/NRREL-19:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-28/NRREL-19:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-28/NRREL-19:gNbId=2
...    NRCELL-28/NRREL-19:gNbIdLength=22
...    NRCELL-28/NRREL-19:handoverAllowedSA=allowed
...    NRCELL-28/NRREL-19:handoverAllowedSARedCap=forbidden
...    NRCELL-28/NRREL-19:lcrId=19
...    NRCELL-28/NRREL-19:nrDcAllowed=false
...    NRCELL-28/NRREL-19:removeNotAllowed=false
...    NRCELL-28/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-28/NRREL-19:sCellOperationalMode=dlOnly
...    NRCELL-28/NRREL-19:gnbPlmn:mcc=311
...    NRCELL-28/NRREL-19:gnbPlmn:mnc=489
...    NRCELL-28/NRREL-19:gnbPlmn:mncLength=3
...    NRCELL-28/NRREL-19:sCellPrio=3

@{Params_limit_ScellUsers_NRCELL-16/25/26/24/30}
...    NRCELL-16:maxNumOfSCellAlloc=1
...    NRCELL-25:maxNumOfSCellAlloc=1
...    NRCELL-26:maxNumOfSCellAlloc=1
...    NRCELL-24:maxNumOfSCellAlloc=2
...    NRCELL-17:maxNumOfSCellAlloc=2
...    NRCELL-30:maxNumOfSCellAlloc=2


@{Params_unlimit_ScellUsers_NRCELL-17/25/26}
...    NRCELL-25:maxNumOfSCellAlloc=250
...    NRCELL-26:maxNumOfSCellAlloc=250
...    NRCELL-17:maxNumOfSCellAlloc=250



@{Restore_D006}
...    NRCELL-16:maxNumOfSCellAlloc=250
...    NRCELL-25:maxNumOfSCellAlloc=250
...    NRCELL-26:maxNumOfSCellAlloc=250
...    NRCELL-24:maxNumOfSCellAlloc=250
...    NRCELL-17:maxNumOfSCellAlloc=250
...    NRCELL-30:maxNumOfSCellAlloc=250
...    delete:NRCELL-28/NRREL-19
...    delete:NRCELL-28/NRREL-18
...    delete:NRCELL-28/NRREL-24
...    delete:NRCELL-28/NRREL-25
...    delete:NRCELL-28/NRREL-11
...    delete:NRCELL-28/NRREL-12
...    delete:NRCELL-28/NRREL-13
...    delete:NRCELL-28/NRREL-14
...    delete:NRCELL-28/NRREL-15
...    delete:NRCELL-28/NRREL-20
...    delete:NRCELL-28/NRREL-21
...    delete:NRCELL-28/NRREL-31
...    delete:NRCELL-28/NRREL-32
...    delete:NRCELL-28/NRREL-33
...    delete:NRCELL-28/NRREL-34
...    delete:NRCELL-24/NRREL-28


@{4DL_expect_regexp_UE1}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:65, scellIdx:1] configure_1_1
...    pcid:74, scellIdx:2] configure_1_1
...    pcid:75, scellIdx:3] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone






@{expect_regexp_UE1_4cc_2nd}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    pcid:74, scellIdx:2] configure_1_1
...    pcid:75, scellIdx:3] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone


@{expect_regexp_UE2_2cc}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:73, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE2_2cc_2nd}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    pcid:79, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{expect_regexp_UE3_2cc_2nd}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:79, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE4_3cc_2nd}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:66, scellIdx:1] configure_1_1
...    pcid:79, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone


@{no_scell_UE4_1st}
...    scellIdx:1] configure_1_1

@{no_scell_UE8_1st}
...    scellIdx:1] configure_1_1

@{no_scell_UE7_2nd}
...    scellIdx:1] configure_1_1


@{expect_regexp_UE4_2cc}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:72, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE5_2cc_1st}
...    pcid:65, scellIdx:0] configure_0_1
...    pcid:65, scellIdx:0] configure_1_1
...    pcid:77, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{expect_regexp_UE6_2cc_1st}
...    pcid:74, scellIdx:0] configure_0_1
...    pcid:74, scellIdx:0] configure_1_1
...    pcid:77, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone


@{expect_regexp_UE7_2cc_1st}
...    pcid:75, scellIdx:0] configure_0_1
...    pcid:75, scellIdx:0] configure_1_1
...    pcid:77, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone


@{expect_regexp_UE8_2cc}
...    pcid:73, scellIdx:0] configure_0_1
...    pcid:73, scellIdx:0] configure_1_1
...    pcid:77, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone



*** Test Cases ***
CB008950-ET-D001-D006-D008-D009-FR1_SA_CA covebsedA1_incoming-outgoing_does_not_exceed_the_CU_limit_same_scellPiority_intragNB
     [Documentation]
    ...    1. This user scenario validates that FR1_SA_CA covebsedA1_incoming-outgoing_does_not_exceed_the_CU_limit_
    ...       same_scellPiority_intragNB
    ...    2. Configuration
    ...    24FDD cell detail:
    ...                  Cell-11_15  Cell-16_19  cell1-20_21  cell-22_25  Cell-26_27  Cell-28-29  Cell-30_34
    ...          Band       n71     n25          n71           n66         n71        n71          n71
    ...           Pci      60-64    65_68        69-70        71-74       75-76      77-78         79-83
    ...     Bandwidth       15      20           15            20        15         10           15
    ...          gscn      1566    4872         1566          5350      1566       1603          1566
    ...          ssbfreq   125310   389790      125310        427970    125310     128210        125310
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...           a. actFlexSCellSelectFr1 enable, add 13 NRRELs of n71, 4 NRRELs of n66, 4 NRRELs of n25 of NRCELL-28
    ...               n25: NRCELL-16/17/18/19(same scellpriority)  20M
    ...               n66:NRCELL-22/23/24/25(highpriority:25>24>23>22)  20M
    ...               n71: NRCELL-11/12/13/14/15/20/21/26/30/31/32/33/34(26 highest>30=31)  15M
    ...               NRCELL-16_PCI65_32784:maxNumOfSCellAlloc=1, NRCELL-25_PCI74_32793:maxNumOfSCellAlloc=1,
    ...               NRCELL-26_PCI75_32794:maxNumOfSCellAlloc=1
    ...               NRCELL-17_PCI66_32785:maxNumOfSCellAlloc=2,  NRCELL-24_PCI73_32792:maxNumOfSCellAlloc=2
    ...               NRCELL-30_PCI79_32798:maxNumOfSCellAlloc=2,
    ...           b. UE1 attach to Pcell NRCELL-28, scell adddition to have 4CC(scell NRCELL-16/25/26).
    ...              UE2 and UE3 attach to NRCELL-28 and scell addition to have 2cc(scell NRCELL-24)
    ...           c. UE4 attach to Pcell NRCELL-28 and try to add one scell but failed as NRCELL-28 has reached maxoutgoing limit 4.
    ...           d. UE1 A2 release one scell and UE4 trigger A1 MR again, UE4 can make 2CC CA.
    ...           e. UE5/UE6/UE7 add NRCELL-28 as scell and UE8expect_regexp_UE3_2cc try to add NRCELL-28 as scell but failed as it
     ...              has readhed maxincoming limit 3.
    ...           f. Lock NRCELL-28, then UE1/1/2/3/4/5/6/7 bulk releases. And after NRCELL-28 unlock, UE8 can add NRCELL-28 as scell.
    ...           g. repeat UE1/2/3/4/5/6/7, NRCELL-28 maxoutgoing and maxincoming CU limit is worked.
       [Tags]    D001_D006    QC_347892    CA_LABEL-4F(10Mhz_n71_20Mn66_20M_n25_20M_n25)
    Preconditions for D006
    UE attach and Scell added coverbase    ue_id=1    CC_num=4
    Steps to add UE2-3 with CA and UE4 no CA added as exceed Pcell CU outgoinglimit
    Steps to release one scell of UE1 than UE4 can be CA
    Steps to test NRCELL-28 exceed CU incoming CA with UE8 no scell added
    Lock NRCELL-28 and restore then UE8 can add it as scell
    Steps to add UE1-3 with CA and UE4 no CA added as exceed Pcell CU outgoinglimit
    Steps to release UE2 than UE4 can be CA used same CA relation with UE3 after NRCELL17-25-26 restore then UE9 can 4cc
    Steps to confirm NRCELL-28 incoming limit from CU
    [Teardown]    Test teardown for D006


*** Keywords ***
Preconditions for D006
    OnlineParamChange    ${PARAMS_ADD_incoming_outgoing_NRRELs}
    OnlineParamChange    ${Params_limit_ScellUsers_NRCELL-16/25/26/24/30}

Steps to confirm NRCELL-28 incoming limit from CU
    UE attach and Scell added coverbase    ue_id=5    CC_num=2    expect_regexp=${expect_regexp_UE5_2cc_1st}
    ...    cell_id=16    cellfreq=389790
    UE attach and Scell added coverbase    ue_id=6    CC_num=2    expect_regexp=${expect_regexp_UE6_2cc_1st}
    ...    cell_id=25    cellfreq=427970
    UE attach and Scell added coverbase    ue_id=7    CC_num=1    expect_regexp=${EMPTY}    fail_reg_ca=${no_scell_UE7_2nd}
    ...    cell_id=26    cellfreq=125310


Lock NRCELL-28 and restore then UE8 can add it as scell
    Lock Cell28
    Release Ues    ue_id=1
    Release Ues    ue_id=1,2,3,4
    Release Ues    ue_id=5,6,7
    Unlock_RecoverCell28
    Execute Egate Command    ue_disp
    UE Send A1 Trigger Scell Addition    8   427970    ${expect_regexp_UE8_2cc}    ${empty}

Steps to add UE1-3 with CA and UE4 no CA added as exceed Pcell CU outgoinglimit
    UE attach and Scell added coverbase    ue_id=1    CC_num=4    expect_regexp=${expect_regexp_UE1_4cc_2nd}
    UE attach and Scell added coverbase    ue_id=2    CC_num=2    expect_regexp=${expect_regexp_UE2_2cc_2nd}
    UE attach and Scell added coverbase    ue_id=3    CC_num=2    expect_regexp=${expect_regexp_UE3_2cc_2nd}
    UE attach and Scell added coverbase    ue_id=4    CC_num=1    expect_regexp=${EMPTY}    fail_reg_ca=${no_scell_UE4_1st}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/FS/24cells_16N71_4N25_4N66


Test teardown for D006
    Unlock Cell28
    Cells Should Be Onair    28
    Object Should Exist    MRBTS-2/NRBTS-2/NRCELL-28:administrativeState=Unlocked
    OnlineParamChange    ${Restore_D006}
    Common Test Teardown And Stop Capture Logs


Steps to add UE2-3 with CA and UE4 no CA added as exceed Pcell CU outgoinglimit
    UE attach and Scell added coverbase    ue_id=2    CC_num=2    expect_regexp=${expect_regexp_UE2_2cc}
    UE attach and Scell added coverbase    ue_id=3    CC_num=2    expect_regexp=${expect_regexp_UE2_2cc}
    UE attach and Scell added coverbase    ue_id=4    CC_num=1    expect_regexp=${EMPTY}    fail_reg_ca=${no_scell_UE4_1st}

Steps to release one scell of UE1 than UE4 can be CA
    trigger A2 MR to release scell
    UE Send A1 Trigger Scell Addition    4   128210    ${expect_regexp_UE4_2cc}    ${empty}

Steps to release UE2 than UE4 can be CA used same CA relation with UE3 after NRCELL17-25-26 restore then UE9 can 4cc
    Release Ues    ue_id=2
    UE Send A1 Trigger Scell Addition    4   128210    ${expect_regexp_UE4_3cc_2nd}    ${empty}
    OnlineParamChange    ${Params_unlimit_ScellUsers_NRCELL-17/25/26}
    UE attach and Scell added coverbase    ue_id=9    CC_num=4    expect_regexp=${expect_regexp_UE1_4cc_2nd}


Steps to test NRCELL-28 exceed CU incoming CA with UE8 no scell added
    UE attach and Scell added coverbase    ue_id=5    CC_num=2    expect_regexp=${expect_regexp_UE5_2cc_1st}
    ...    cell_id=16    cellfreq=389790
    UE attach and Scell added coverbase    ue_id=6    CC_num=2    expect_regexp=${expect_regexp_UE6_2cc_1st}
    ...    cell_id=25    cellfreq=427970
    UE attach and Scell added coverbase    ue_id=7    CC_num=2    expect_regexp=${expect_regexp_UE7_2cc_1st}
    ...    cell_id=26    cellfreq=125310
    UE attach and Scell added coverbase    ue_id=8    CC_num=1    expect_regexp=${EMPTY}    fail_reg_ca=${no_scell_UE8_1st}
    ...    cell_id=24    cellfreq=427970

Unlock_RecoverCell28
    Unlock Cell28
    Cells Should Be Onair    28
    Object Should Exist    MRBTS-2/NRBTS-2/NRCELL-28:administrativeState=Unlocked


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}


UE attach and Scell added coverbase
    [Arguments]    ${ue_id}=1    ${CC_num}=4    ${expect_regexp}=${4DL_expect_regexp_UE1}    ${fail_reg_ca}=${EMPTY}    ${cell_id}=28
    ...    ${cellfreq}=128210
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}    cell_id=${cell_id}
    UE Send A1 Trigger Scell Addition    ${ue_id}    ${cellfreq}    ${expect_regexp}    ${fail_reg_ca}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=10    CC_num=${CC_num}    type=pdsch
    Check Throughput For UL    ue_id=${ue_id}

SA CA UE Setup PDU Session Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=28
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=PDU SESSION ID-1 setup/reestablishment complete

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}    ${fail_reg_ca}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}
    ...    fail_regexp=${fail_reg_ca}

trigger A2 MR to release scell
    [Arguments]    ${carrierfreq}=125310    ${scell_index}=3    ${ue_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret2}    sCellToReleaseList



Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=15    UE ${ue_id}: UDP UL


Check Throughput For UL
    [Arguments]    ${ue_id}=2
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 5


Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=${type}    pass_regexp=Average
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
    Should Be True    ${scell_tput}/1000 > 0

