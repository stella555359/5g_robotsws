*** Settings ***
Documentation
...    author: Susana Yan
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-lingyan.zhou    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${CaSup}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa

@{PARAMS_IN_SWCONFIG_AP}    0x5C0009=1
@{PARAMS_IN_SCF}
...    NRCELL:maxNumPdschAllocationPerSlot=4

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

@{PARAMS_whitelist_NRREL-26-25-16-11}
...    NRCELL-26:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=true
...    NRCELL-25:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=true
...    NRCELL-16:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=true
...    NRCELL-16:a6MeasSCellSwapSsbRsrq:useAllowedCellListRsrq=true
...    NRCELL-11:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=true
...    NRCELL-16:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6TimeToTrigSCellSwapSsbRsrp=ms256
...    NRCELL-16:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms256
...    NRCELL-16:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6TimeToTrigSCellSwapSsbRsrq=ms256
...    NRCELL-16:a6MeasSCellSwapSsbRsrq:a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms256
...    NRCELL-25:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6TimeToTrigSCellSwapSsbRsrp=ms512
...    NRCELL-25:a6MeasSCellSwapSsbRsrp:a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms512
...    NRCELL-25:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6TimeToTrigSCellSwapSsbRsrq=ms512
...    NRCELL-25:a6MeasSCellSwapSsbRsrq:a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms512


@{Restore_C007}
...    NRCELL-26:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=false
...    NRCELL-25:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=false
...    NRCELL-16:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=false
...    NRCELL-16:a6MeasSCellSwapSsbRsrq:useAllowedCellListRsrq=false
...    NRCELL-11:a6MeasSCellSwapSsbRsrp:useAllowedCellListRsrp=false
...    NRCELL-26:maxNumOfSCellAlloc=250
...    NRCELL-25:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-16:a6MeasSCellSwapEnabled=rsrp
...    delete:NRCELL-26:pciExcludeList
...    delete:NRCELL-25:pciExcludeList

@{PARAMS_Remove-n71_NRRELto9}
...    delete:NRCELL-28/NRREL-31
...    delete:NRCELL-28/NRREL-32
...    delete:NRCELL-28/NRREL-33
...    delete:NRCELL-28/NRREL-34
...    NRCELL-25:a6MeasSCellSwapEnabled=rsrp

@{PARAMS_addback-n71_NRREL-31to10}
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
...    NRCELL-25:a6MeasSCellSwapEnabled=rsrq

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
...    NRCELL-28/NRREL-17:sCellPrio=4
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
...    NRCELL-28/NRREL-18:sCellPrio=5
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
...    NRCELL-28/NRREL-19:sCellPrio=6

@{4DL_expect_regexp_UE1}
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:65, scellIdx:1] configure_1_1
...    pcid:74, scellIdx:2] configure_1_1
...    pcid:75, scellIdx:3] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{UE2_1st_noallowedList_n71}
...    start 71
...    start 72
...    start 73
...    start 60
...    start 61
...    start 62
...    start 63
...    start 64
...    start 69
...    start 70
...    start 79

@{UE1_1st_noallowedList}
...    allowedCellsToAddModList

@{4DL_expect_regexp_UE2}
...    start 66
...    start 67
...    start 68
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:65, scellIdx:1] configure_1_1
...    pcid:74, scellIdx:2] configure_1_1
...    pcid:75, scellIdx:3] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone


@{4DL_expect_regexp_UE2_withallown71}
...    start 66
...    start 67
...    start 68
...    start 71
...    start 72
...    start 73
...    start 60
...    start 61
...    start 62
...    start 63
...    start 64
...    start 69
...    start 70
...    start 79
...    pcid:77, scellIdx:0] configure_0_1
...    pcid:77, scellIdx:0] configure_1_1
...    pcid:65, scellIdx:1] configure_1_1
...    pcid:74, scellIdx:2] configure_1_1
...    pcid:75, scellIdx:3] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{UE_swap_check_common}
...    sCellToReleaseList
...    activated successfully at airphone

@{UE2SwapwithAllowlist}
...    start 61
...    start 62
...    start 63
...    start 64
...    start 69
...    start 70
...    start 75
...    start 79
...    sCellToReleaseList
...    SCellIndex 4 activated successfully at airphone

@{UE2SwapbackwithAllowlist}
...    start 60
...    start 61
...    start 62
...    start 63
...    start 64
...    start 69
...    start 70
...    start 79
...    sCellToReleaseList
...    SCellIndex 3 activated successfully at airphone

*** Test Cases ***
CB008950-ET-C007-B4-white list for scell swap with unique Scellprio for SA_intragNB CA
     [Documentation]
    ...    1. This user scenario validates that gNB configures a white-list for event A6 measurement report when there
    ...       are no more than 8 SCell swap target candidate cells.
    ...       Note. allowedCellsToAddModList IE can only accommodate 8 PCI ranges.
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
    ...               n25: NRCELL-16/17/18/19
    ...               n66:NRCELL-22/23/24/25
    ...               n71: NRCELL-11/12/13/14/15/20/21/26/30/31/32/33/34
    ...               all NRCELLs: a6MeasSCellSwapEnabled=rsrp except NRCELL-25 and NRCELL-16
    ...               NRCELL-25:a6MeasSCellSwapEnabled=rsrq,NRCELL-16:a6MeasSCellSwapEnabled=rsrpAndRsrq
    ...           b. UE1 FFFF 4CC_NRCELL_28_scell_NRCELL_16_25_26, traffic is ok.
    ...           c. online change to configure useAllowedCellListRsrp=true of NRCELL-25,NRCELL-26, NRCELL-11
    ...              useAllowedCellListRsrp=true and useAllowedCellListRsrq=true of NRCELL-16
    ...              UE2 FFFF 4CC_NRCELL_28_scell_NRCELL_16_25_26, traffic is ok.
    ...              UE1 has no effect.
    ...              UE2 measObject of n25(NRCELL-16) has allowedCellsToAddModList with PCIrange from 66-68.
    ...              UE2 measObject of n66(NRCELL-25) has allowedCellsToAddModList with PCIrange from 71-73.
    ...              UE2 measObject of n71(NRCELL-26) has no allowedCellsToAddModList as same freq NRRELs >8.
    ...              UE2 Trigger A6 MR to scell swap from NRCELL-26 to NRCELL-11
    ...              UE2 trigger A6 MR to scell swap from NRCELL-16 to NRCELL-17
    ...              UE2 measObject of n66(NRCELL-17) has no allowedCellsToAddModList as NRCELL-17 isn't enable whitelist.
    ...              UE2 measObject of n71(NRCELL-11) has no allowedCellsToAddModList as same freq NRRELs >8.
    ...           d. Remove same freq of n71 NRREL to 9. Bulk release happend with UE1, UE2.
    ...           e. UE2 FFFF 4CC_NRCELL_28_scell_NRCELL_16_25_26, traffic is ok.
    ...              UE2 measObject of n25(NRCELL-16) has allowedCellsToAddModList with PCIrange from 66-68.
    ...              UE2 measObject of n66(NRCELL-25) has allowedCellsToAddModList with PCIrange from 71-73.
    ...              UE2 measObject of n71(NRCELL-26) has allowedCellsToAddModList with PCIrange 8 cells.
    ...              UE2 Trigger A6 MR to scell swap from NRCELL-26 to NRCELL-11
    ...              UE2 measObject of n71(NRCELL-11) has allowedCellsToAddModList with PCIrange 8 cells.
    ...              UE2 Trigger A6 MR to scell swap from NRCELL-11 to NRCELL-26
    ...              UE2 measObject of n71(NRCELL-26) has allowedCellsToAddModList with PCIrange 8 cells.
    ...           g. Online change to add n71 NRRELs to 10.UE1 FFFF 4CC_NRCELL_28_scell_NRCELL_16_25_26, traffic is ok.
    ...              UE1 measObject of n71(NRCELL-26) has no allowedCellsToAddModList as same freq NRRELs >8.
    [Tags]    C007    QC_47175    CA_LABEL-4F(10Mhz_n71_20Mn66_20M_n25_20M_n25)
    OnlineParamChange    ${PARAMS_ADD_incoming_outgoing_NRRELs}
    UE attach and Scell added coverbase    ue_id=1    CC_num=4    fail_reg_ca=${UE1_1st_noallowedList}
    OnlineParamChange    ${PARAMS_whitelist_NRREL-26-25-16-11}
    UE2 attach with no allowedCellsToAddModList of n71 and A6 swap
    OnlineParamChange    ${PARAMS_Remove-n71_NRRELto9}
    Release UEs    ue_type=all
    UE2 attach with allowedCellsToAddModList of n71 and A6 swap
    OnlineParamChange    ${PARAMS_addback-n71_NRREL-31to10}
    UE1 attach with no allowedCellsToAddModList of n71 and A6 swap
    [Teardown]    Test teardown for C007

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/FS/24cells_16N71_4N25_4N66

Test teardown for C007
    OnlineParamChange    ${Restore_C007}
    Common Test Teardown And Stop Capture Logs

UE1 attach with no allowedCellsToAddModList of n71 and A6 swap
    UE attach and Scell added coverbase    ue_id=1    CC_num=4    expect_regexp=${4DL_expect_regexp_UE1}
    ...    fail_reg_ca=${UE2_1st_noallowedList_n71}
    Trigger A6swap    ue_id=2    carrierfreq=427970    scell_index=2    phycell_id=73    ue_id=1
    Trigger A6swap    ue_id=2    carrierfreq=125310    scell_index=3    phycell_id=80    ue_id=1

UE2 attach with no allowedCellsToAddModList of n71 and A6 swap
    [Arguments]    ${expect_regexp}=${4DL_expect_regexp_UE2}    ${fail_reg_ca}=${UE2_1st_noallowedList_n71}
    UE attach and Scell added coverbase    ue_id=2    CC_num=4    expect_regexp=${expect_regexp}    fail_reg_ca=${fail_reg_ca}
    Trigger A6swap    ue_id=2    carrierfreq=125310    scell_index=3    phycell_id=60    fail_regexp=${UE1_1st_noallowedList}
    Trigger A6swap    ue_id=2    carrierfreq=389790    scell_index=1    phycell_id=66    fail_regexp=${UE1_1st_noallowedList}

UE2 attach with allowedCellsToAddModList of n71 and A6 swap
    [Arguments]    ${expect_regexp}=${4DL_expect_regexp_UE2_withallown71}    ${fail_reg_ca}=${EMPTY}
    UE attach and Scell added coverbase    ue_id=2    CC_num=4    expect_regexp=${expect_regexp}    fail_reg_ca=${fail_reg_ca}
    Trigger A6swap    ue_id=2    carrierfreq=125310    scell_index=3    phycell_id=60    pass_regexp=${UE2SwapwithAllowlist}
    Trigger A6swap    ue_id=2    carrierfreq=125310    scell_index=4    phycell_id=75    pass_regexp=${UE2SwapbackwithAllowlist}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=1200

Trigger A6swap
    [Arguments]    ${ue_id}=1    ${carrierfreq}=125790    ${scell_index}=4    ${phycell_id}=68
                   ...    ${pass_regexp}=${UE_swap_check_common}    ${fail_regexp}=${EMPTY}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=A6    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A6 meas_id=${meas_id} srsrp_nr=60 srsrq_nr=60
    ...    scell=${scell_index} scell_rsrp=10 scell_rsrq=10 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Check Throughput with Type_withSwap    ue_id=${ue_id}

UE attach and Scell added coverbase
    [Arguments]    ${ue_id}=1    ${CC_num}=4    ${expect_regexp}=${4DL_expect_regexp_UE1}    ${fail_reg_ca}=${EMPTY}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}
    UE Send A1 Trigger Scell Addition    ${ue_id}    128210    ${expect_regexp}    ${fail_reg_ca}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=160    CC_num=${CC_num}    type=pdsch
    Check Throughput For UL    ue_id=${ue_id}

SA CA UE Setup PDU Session Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=28
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

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=15    UE ${ue_id}: UDP UL

Check Throughput with Type_withSwap
    [Arguments]    ${ue_id}=2
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Be True    ${dl_throughput}/1000>160
    Should Be True    ${ul_throughput}/1000>13

Check Throughput For UL
    [Arguments]    ${ue_id}=2
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 13

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
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