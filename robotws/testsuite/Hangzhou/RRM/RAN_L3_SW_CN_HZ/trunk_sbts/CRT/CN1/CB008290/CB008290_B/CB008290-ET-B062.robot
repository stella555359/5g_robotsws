*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-liupei.fang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-2:actSlowPrbPoolingFddFr1Enh=false
...    NRBTS-2:actSlowPrbPooling=false
...    NRBTS-2:cipherPrefL:nea0=8
...    NRBTS-2:cipherPrefL:nea1_128=0
...    NRBTS-2:cipherPrefL:nea2_128=0
...    NRBTS-2:cipherPrefL:nea3_128=0
...    NRBTS-2:integrityProtPrefL:nia0=0
...    NRBTS-2:integrityProtPrefL:nia1_128=0
...    NRBTS-2:integrityProtPrefL:nia2_128=0
...    NRBTS-2:integrityProtPrefL:nia3_128=9
...    MRBTS-1/NRBTS-2/NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRBTS-2/NRULCLPC_PROFILE-1:clpcPucch:targetSinr=16
...    NRCELL:nrUlClpcProfileDN=MRBTS-1/NRBTS-2/NRULCLPC_PROFILE-1
...    NRCELL-1:prachConfigurationIndex=90
...    NRCELL-2:prachConfigurationIndex=90
...    NRBTS-2:sCellActivationMethod=bufferBased
...    NRBTS-2:actLteNrDss=true
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{DSS_BWP_PROFILES}
...    @{DSS_NRSYSINFO_PROFILE}
...    @{DSS_CELL_CONFIG}
...    @{DSS_CELL_NRDSSLTE}
...    @{DSS_XPAP}

${CA_SUPPORT_LIST}    SEPARATOR=,
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Fr1Tdd_Nsa
...    ca_Fr1Tdd_Fdd_Sa
...    ca_Fr1Tdd_Fdd_Nsa
...    ca_Fr1Tdd_Sa
...    ca_Fdd_Fdd
...    ca_Fr1Tdd_Any_Sa
...    ca_Fdd_Any_Sa

@{DSS_BWP_PROFILES}    @{BWP_PROFILE_32}    @{BWP_PROFILE_33}

@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:sCellPrio=1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=13
...    NRCELL-1/NRREL-1:sCellPrio=2
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed

...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellPrio=1
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=14
...    NRCELL-1/NRREL-3:sCellPrio=2
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed

...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=2
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=2
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellPrio=1
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=2
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=13
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellPrio=2
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=2
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-3:lcrId=1
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=2
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:lcrId=2
...    NRCELL-12/NRREL-4:nrDcAllowed=false
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS-2:actCarrierAggregation=true
...    NRBTS-2:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-2:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-2:actSCellSwapFr1=a6BasedSa
...    NRBTS-2:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL:actCDrx=true
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-11:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-13:a6MeasSCellSwapEnabled=rsrq

@{same frequency}
...    MRBTS-1/NRBTS-2/NRCELL-12:gscnOrSsPbchArfcn=1588
...    MRBTS-1/NRBTS-2/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127100
...    MRBTS-1/NRBTS-2/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136300
...    MRBTS-1/NRBTS-2/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-12:type0CoresetConfigurationIndex=6
...    MRBTS-1/NRBTS-2/NRCELL-14:gscnOrSsPbchArfcn=1588
...    MRBTS-1/NRBTS-2/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127100
...    MRBTS-1/NRBTS-2/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136300
...    MRBTS-1/NRBTS-2/NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-14:type0CoresetConfigurationIndex=6

...    MRBTS-1/NRBTS-2/NRCELL-11:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-2/NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-2/NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-2/NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-11:type0CoresetConfigurationIndex=7
...    MRBTS-1/NRBTS-2/NRCELL-13:gscnOrSsPbchArfcn=5300
...    MRBTS-1/NRBTS-2/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-2/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-2/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-2/NRCELL-13:type0CoresetConfigurationIndex=7
...    NRCELL-14:type0SearchSpaceConfigurationIndex=15
...    NRCELL-12:type0SearchSpaceConfigurationIndex=15

@{BWP_PROFILE_32}
...    NRBTS-2/BWP_PROFILE-32:bwpType=initial
...    NRBTS-2/BWP_PROFILE-32:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS-2/BWP_PROFILE-32:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS-2/BWP_PROFILE-32:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-2/BWP_PROFILE-32:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1:alSelection=static
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1:downgradeAL16toAL8=notAllowed
...    delete: NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl80|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=47|searchSpaceId=1
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=2
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl40|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS-2/BWP_PROFILE-32/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=27|searchSpaceId=3

@{BWP_PROFILE_33}
...    NRBTS-2/BWP_PROFILE-33:bwpType=dedicated
...    NRBTS-2/BWP_PROFILE-33:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-2/BWP_PROFILE-33:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-2/BWP_PROFILE-33:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS-2/BWP_PROFILE-33:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS-2/BWP_PROFILE-33/PDSCH-1:pdschId=1
...    NRBTS-2/BWP_PROFILE-33/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:alSelection=dynamic
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dciDedicatedAggregationLevel=AL2
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:aggregationLevelList=AL1_AL2_AL4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiCorrectionUp=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl1=81
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl2=59
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl4=33
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl8=1
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl16=0
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:highOlcCqiOffset=1
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:lowOlcCqiOffset=1
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=160
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureReduction=1
...    delete: NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1/coresetCommon
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl80|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=47|searchSpaceId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=6|searchSpaceId=5
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl40|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=27|searchSpaceId=6
...    delete: NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1/coresetCommon
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=2|searchSpaceId=7
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=8
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=2|searchSpaceId=9
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=6|searchSpaceId=10
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=5|searchSpaceId=11
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=3|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_2|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl10|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=12
...    NRBTS-2/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=9|searchSpaceId=12

@{DSS_XPAP}
...    MNL-1/MNLENT-1/XPAP-1:xpApId=1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:localNeDN=MRBTS-1/NRBTS-2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpAssocMaxRetrans=7
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpDscp=46
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpHeartbeatInterval=20
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpMaxPayloadSize=1395
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMax=30000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMin=1000
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackDelay=200
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackFreq=2
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpWaitTimeInitSeqRetry=240
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1:udpDscp=18
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:ipAddress=10.0.1.1
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:remoteNeType=ENB

@{DSS_CELL_CONFIG}
...    NRCELL-12:nrSysInfoProfileDN=MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-12
...    NRCELL-12:lteNrDssMode=DSS_Phase_3
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-32|cellBwpId=0
...    NRCELL-12:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-33|cellBwpId=1
...    NRCELL-12:dlPtrs:actDlPtrs=false
...    NRCELL-14:nrSysInfoProfileDN=MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-12
...    NRCELL-14:lteNrDssMode=DSS_Phase_3
...    NRCELL-14:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-32|cellBwpId=0
...    NRCELL-14:cellBwpList:bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-33|cellBwpId=1
...    NRCELL-14:dlPtrs:actDlPtrs=false


@{DSS_CELL_NRDSSLTE}
...    NRCELL-12/NRDSSLTE-1:actLteNrDssFastAlloc=false
...    NRCELL-12/NRDSSLTE-1:actLteNrDssLteCatM=false
...    NRCELL-12/NRDSSLTE-1:actRateMatchedCsiIm=false
...    NRCELL-12/NRDSSLTE-1:dssDlTPollRetr=ms80
...    NRCELL-12/NRDSSLTE-1:dssDlTProhib=ms0
...    NRCELL-12/NRDSSLTE-1:dssMaxNumberOfDlDcis=1
...    NRCELL-12/NRDSSLTE-1:dssUlTPollRetr=ms5
...    NRCELL-12/NRDSSLTE-1:dssUlTProhib=ms0
...    NRCELL-12/NRDSSLTE-1:eNodeBId=1
...    NRCELL-12/NRDSSLTE-1:lcrId=1
...    NRCELL-12/NRDSSLTE-1:ltePhyCellId=14
...    NRCELL-12/NRDSSLTE-1:ssbPosition=pos1
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mcc=311
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mnc=489
...    NRCELL-12/NRDSSLTE-1:enbPlmn:mncLength=3
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:dlResourceSharingAlgo=DL PRB load based
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio=100
...    NRCELL-12/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio=30
#...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:maxValue=50
#...    NRCELL-12/NRDSSLTE-1:lteNrDssMbsfnRatio:minValue=50
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:maxNrDssRatio=70
...    NRCELL-12/NRDSSLTE-1:lteNrDssUlRatio:minNrDssRatio=20

...    NRCELL-14/NRDSSLTE-1:actLteNrDssFastAlloc=false
...    NRCELL-14/NRDSSLTE-1:actLteNrDssLteCatM=false
...    NRCELL-14/NRDSSLTE-1:actRateMatchedCsiIm=false
...    NRCELL-14/NRDSSLTE-1:dssDlTPollRetr=ms80
...    NRCELL-14/NRDSSLTE-1:dssDlTProhib=ms0
...    NRCELL-14/NRDSSLTE-1:dssMaxNumberOfDlDcis=1
...    NRCELL-14/NRDSSLTE-1:dssUlTPollRetr=ms5
...    NRCELL-14/NRDSSLTE-1:dssUlTProhib=ms0
...    NRCELL-14/NRDSSLTE-1:eNodeBId=1
...    NRCELL-14/NRDSSLTE-1:lcrId=2
...    NRCELL-14/NRDSSLTE-1:ltePhyCellId=15
...    NRCELL-14/NRDSSLTE-1:ssbPosition=pos1
...    NRCELL-14/NRDSSLTE-1:enbPlmn:mcc=311
...    NRCELL-14/NRDSSLTE-1:enbPlmn:mnc=489
...    NRCELL-14/NRDSSLTE-1:enbPlmn:mncLength=3
...    NRCELL-14/NRDSSLTE-1:lteNrDssDlRatio:dlResourceSharingAlgo=DL PRB load based
...    NRCELL-14/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio=100
...    NRCELL-14/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio=30
#...    NRCELL-14/NRDSSLTE-1:lteNrDssMbsfnRatio:maxValue=50
#...    NRCELL-14/NRDSSLTE-1:lteNrDssMbsfnRatio:minValue=50
...    NRCELL-14/NRDSSLTE-1:lteNrDssUlRatio:maxNrDssRatio=70
...    NRCELL-14/NRDSSLTE-1:lteNrDssUlRatio:minNrDssRatio=20

@{DSS_NRSYSINFO_PROFILE}
...    NRBTS-2/NRSYSINFO_PROFILE-12:nCellChangeMedium=14
...    NRBTS-2/NRSYSINFO_PROFILE-12:systemInformationTargetRate=1
...    NRBTS-2/NRSYSINFO_PROFILE-12:addHystSfHigh=dB-2
...    NRBTS-2/NRSYSINFO_PROFILE-12:addHystSfMedium=dB-2
...    NRBTS-2/NRSYSINFO_PROFILE-12:nCellChangeHigh=16
...    NRBTS-2/NRSYSINFO_PROFILE-12:qHyst=dB0
...    NRBTS-2/NRSYSINFO_PROFILE-12:siWindowLength=s160
...    NRBTS-2/NRSYSINFO_PROFILE-12:tEvaluation=s30
...    NRBTS-2/NRSYSINFO_PROFILE-12:tHystNormal=s30
...    NRBTS-2/NRSYSINFO_PROFILE-12:tReselectionEutra=0
...    NRBTS-2/NRSYSINFO_PROFILE-12:threshServingLowP=0
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType2
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibType=sibType2|sibType=sibType2
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType3
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType4
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType5
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType6
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType6
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType6
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType7
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType7
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType7
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType8
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibPeriodicity=rf64|sibType=sibType8
...    NRBTS-2/NRSYSINFO_PROFILE-12:sibSchedulingList:sibScope=cellSpecific|sibType=sibType8

...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:sIntraSearchP=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRIAFIM-1:tReselectionNr=0
...
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:dlCarrierFreq=127100
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:dssCellsDeployed=false
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:freqBandIndicatorNR=71
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:ssbScs=30 KHz
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXHighP=30
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXLowP=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXHighQ=10
...    NRBTS/NRSYSINFO_PROFILE-12/NRIRFIM-1:threshXLowQ=9
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:carrierFreq=39874
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:cellReselectionPriority=3
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:cellReselectionSubPriority=oDot4
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:pMaxEutra=22
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:presenceAntPort1=true
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:qQualMin=-30
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:qRxLevMin=-67
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXHigh=10
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXHighQ=10
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXLow=9
...    NRBTS/NRSYSINFO_PROFILE-12/NRLIM-1:threshXLowQ=9

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF88E3D033EC09F1891C790E7D473
...    E618F28581C0E1E0B801FF800E000BE0003801C0A83620EB04610D04083C40232B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC0000003801C
...    0AA3626EB04610D04083A40230B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0001C00E0541F11B582308682041E201195B262AC4873E238
...    F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000001C00E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038
...    820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C460000041605
...    62E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160563E268007118003850001C41000
...    00E160561E230007118000018581007011A014404D80820AAF41F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810
...    206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0468102040D8E7C0850206C73E0005C3C6318C6318C6318C63187A058078005038
...    18070300540700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008000000200
...    002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410
...    000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900C
...    D2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A022F012A05028140A05028140A05028140A05028140A05028003840403006010020042020040
...    10080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C020180304040080201002008602004008080600C020040080
...    80600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${list1}    0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,52+14:0,
${list2}    52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,52+29:0,52+30:0,52+31:0,
${list3}    52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,52+48:0,
${list4}    52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,52+63:0,52+64:0,52+65:0,
${list5}    52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52

${pdu_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B062_Verify_successful_scell_swap_IWK_DSS
    [Documentation]
    ...    1. This user scenario Verify successful scell swap with DSS
    ...    2. Configuration:
    ...        set actLteNrDss DSS feature enabled on cell-12 and cell-14 , setup two CA, one is : TTFF(cell-1+cell-2+cell-11+cell-12)
    ...        anothe CA is:FTTF(cell-12+cell-1+cell-2+cell11)
    ...        cell-12 and cell-14 in the same band and the same nrarfcn
    ...        cell-11 and cell-13 in the same band and the same nrarfcn
    ...    2. Test Case Steps:
    ...         a. Attach UE-81 to the TDD NR cell1 and setup non-GBR SA call and trigger A1 scell addition
    ...            Expected result:scell TDD cell2 and FDD cell-11 and cell12 addition successfully, A6 configured for cell-11 and cell-12.
    ...         b. scell swap from cell11 to cell13.
    ...            Expected result:swap successflly and traffic is OK for all serving cells.
    ...         c. scell swap from cell12 to cell14 should successflly
    ...         d. Attach UE-82 to the FDD NR cell-12 and setup non-GBR SA call and trigger A1 scell additon
    ...            Expected result:scell TDD cel1-1 and TDD cell-2 and cell-11 addition successfully, A6 configured.
    ...         e. scell swap from cell11 to cell13 should successfully
    ...         f. release ue
    ...            Expected result: ue release successfully
    ...         f. check no resource leak

    [Tags]    owner-liupei.fang    B062    QC_47037
    CA UEs register and do traffic    ue_id=81
    Trigger ScellSwap should be successfully
    Verify Throuput on Pscell and Scell    ue_id=81     scell_id1=1    scell_id2=3    scell_id3=4
    Trigger ScellSwap should be successfully    carrierfreq=127010    scell_id=3    phycell_id=63
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id1=1    scell_id2=2    scell_id3=4
    CA UEs register and do traffic    ue_id=82     cell_id=12    carrierfreq=127010
    Verify Throuput on Pscell and Scell    ue_id=82
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id1=1    scell_id2=2    scell_id3=4
    Trigger ScellSwap should be successfully     carrierfreq=424090    ue_id=82    scell_id=3    phycell_id=62
    Verify Throuput on Pscell and Scell    ue_id=82     scell_id1=1    scell_id2=2    scell_id3=4
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id1=1    scell_id2=2    scell_id3=4
  #  Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B062${/}a2a.ini    wait_string=UEContextReleaseComplete::5


*** Keywords ***
Modify Cfg
    ${cmd}    Catenate    set_gnb id=2 type=external plmn=311:489 x2=10.0.1.2:36422 ng=10.0.1.2
    ...    gnb_id=0x01:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.2 amf=1
    ...    xp_management=on xp=10.0.1.2:32742 xpu=10.0.1.2:32742
    Update Cfg    ${cmd}
    ${cmd}    Catenate    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off
    ...    proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=136300:127100 gscn=1588 mandatory_for_activation=off
    Update Cfg    ${cmd}
        ${cmd}    Catenate    set_cell id=14 gnb=2 pci=21:0 tac=200 nrci=0x0C tdd_cell=off
    ...    proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=136300:127100 gscn=1588 mandatory_for_activation=off
    Update Cfg    ${cmd}
    ${cmd}    Catenate    set_enb id=1 plmn=311:489 s1=10.0.1.12 enb_id_macro=0x00001
    ...    daemon=10.0.2.1:22222 x2=10.0.1.13 x2u=10.0.1.136 type=simulated x2_peers=none
    ...    xp_management=on xp=10.0.1.1:32742 xpu=10.0.1.1:32742
    Update Cfg    ${cmd}
    ${cmd}    Catenate    set_cell id=1 enb=1 eci=0x0000101 pci=4:2 tac=222
    ...    proxy=10.0.2.1:12219|10.0.2.1:8889 earfcn=68771:133307
    ...    mandatory_for_activation=off bw=10MHz
    Update Cfg    ${cmd}
    ${cmd}    Catenate    set_cell id=2 enb=1 eci=0x0000102 pci=5:0 tac=222
    ...    proxy=10.0.2.1:12220|10.0.2.1:8890 earfcn=68771:133307
    ...    mandatory_for_activation=off bw=10MHz
    Update Cfg    ${cmd}


Perform Steps After WTS Started
    Setup Xp link
    Set LTE NR DSS configuration    id=1    cell_id=1    target_cell=12
    Set LTE NR DSS configuration    id=1    cell_id=2    target_cell=14
    Reserve DSS Cell resource    cell_id=1    tgt_cell=12
    Reserve DSS Cell resource    cell_id=2    tgt_cell=14


Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F


Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=14    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic


Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=40    ${scell_dl}=20    ${ul}=7    ${scell_id1}=1    ${scell_id2}=2    ${scell_id3}=3
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id1}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id2}    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > ${scell_dl}
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id3}    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > ${scell_dl}
    verify UL throughput    ue_id=${ue_id}
    
verify UL throughput
    [Arguments]    ${ue_id}=81    
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput} > 0

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=30    ${ul}=5
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>0


Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=100    ${srsrq_nr}=100    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete


Trigger ScellSwap should be successfully
    [Arguments]    ${event_type}=A6    ${carrierfreq}=424090    ${nrsrp_nr}=100    ${nrsrq_nr}=100    ${ue_id}=81    ${scell_id}=2
    ...    ${phycell_id}=62
   ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete



CA UEs register and do traffic
    [Arguments]     ${ue_id}=81    ${cell_id}=1    ${carrierfreq}=518910
    Update UE capa    ${SA_Capa_perUE_Full}    ue_id=${ue_id}
    UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}
    Send Throuput    ue_id=${ue_id}
    Verify Throuput on Pscell    ue_id=${ue_id}
    Trigger ScellAdd    carrierfreq=${carrierfreq}    ue_id=${ue_id}
    Verify Throuput on Pscell and Scell    ue_id=${ue_id}


Setup Xp link
    Execute Egate Command    sim_trace enb=1 protocol=xp on
    Execute Egate Command    enb_xp_param id=1 xp_peers=none
    Execute Egate Command    enb_xp_param id=1 xp_peers=2
    Execute Egate Command    enb_xp_link_up enb=1 target=2    pass_regexp=is up    sleep_time=120


Set LTE NR DSS configuration
    [Arguments]    ${sleep_time}=5    ${id}=1    ${cell_id}=1    ${target_cell}=12
    Execute Egate Command    enb_dss_param id=${id} feature_flag=on message_sets=DMS3    sleep_time=${sleep_time}
    Execute Egate Command    enb_cell_param id=${cell_id} enb=${id} lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2
    ...    sleep_time=${sleep_time}
    Execute Egate Command    enb_cell_dss_feature enb=${id} id=${cell_id} nr_dl_peak_rate_increase=on    
    ...    sleep_time=${sleep_time}
    Execute Egate Command    enb_cell_dss_feature enb=${id} id=${cell_id} superfast_allocation=off    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_cell_param enb=1 id=${cell_id} dl_resource_sharing_algo=dl_prb_load_based
    ...    sleep_time=${sleep_time}
    Partnership activated on both partners    sleep_time=${sleep_time}    id=${id}    cell_id=${cell_id}    target_cell=${target_cell}   
    
Partnership activated on both partners
    [Arguments]    ${sleep_time}=5    ${id}=1    ${cell_id}=1    ${target_cell}=12
    Execute Egate Command    enb_configure_dss_partnership enb=${id} cell=${cell_id} dss_peer=2:${target_cell}
    ...    pass_regexp=CRM Partnership Creation    sleep_time=${sleep_time}
    ${command1}    catenate
    ...    enb_crm_cell_resource_reservation enb=${id} cell=${cell_id} tgt_enb=2 tgt_cell=${target_cell} assigned_dl_minimum_share_to_nr=30
    ...    assigned_dl_maximum_share_to_nr=100 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70
    ...    assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70
    Execute Egate Command    ${command1}    sleep_time=${sleep_time}
    Execute Egate Command    enb_crm_param id=${id} ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200
    ...    sleep_time=${sleep_time}
    ${command}    catenate    enb_dss_establish_partnership enb=${id} cell=${cell_id} tgt_enb=2 tgt_cell=${target_cell}
    Execute Egate Command    ${command}    pass_regexp=Partnership activated on both partners
    ...    sleep_time=${sleep_time}


Reserve DSS Cell resource
    [Arguments]    ${sleep_time}=5    ${cell_id}=1    ${tgt_cell}=12
    Execute Egate Command    enb_dss_cell_resource_reservation_dl enb=1 cell=${cell_id} reset    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_cell_resource_reservation_ul enb=1 cell=${cell_id} reset    sleep_time=${sleep_time}
    ${cmd1}    catenate    enb_dss_dl_resource_cell_reservation cell=${cell_id} enb=1
    ...     prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    Execute Egate Command    ${cmd1}    sleep_time=${sleep_time}
    ${command2}    catenate
    ...    enb_dss_dl_resource_cell_reservation cell=${cell_id} enb=1
    ...    reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Execute Egate Command    ${command2}    sleep_time=${sleep_time}
    ${cmd2}    catenate    enb_dss_dl_resource_cell_reservation cell=${cell_id} enb=1 min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
    Execute Egate Command    ${cmd2}    sleep_time=${sleep_time}
    CRM Trigger Resource Allocation    sleep_time=${sleep_time}    cell_id=${cell_id}    tgt_cell=${tgt_cell}   
    
  
    
    
    
CRM Trigger Resource Allocation
    [Arguments]    ${sleep_time}=5    ${cell_id}=1    ${tgt_cell}=12
    Execute Egate Command    enb_dss_cell_resource_coordination enb=1 cell=${cell_id} tgt_enb=2 tgt_cell=${tgt_cell} dir=DL
    ...    sleep_time=${sleep_time}
    ${cmd}    catenate    enb_dss_ul_cell_resource_reservation enb=1 cell=${cell_id} minimum_prb_share=30 maximum_prb_share=70
    Execute Egate Command    ${cmd}    sleep_time=${sleep_time}
    Execute Egate Command    enb_dss_cell_resource_coordination enb=1 cell=${cell_id} tgt_enb=2 tgt_cell=${tgt_cell} dir=UL
    ...    sleep_time=${sleep_time}
   # Execute Egate Command    ${Resource_Allocation}    pass_regexp=CRM Trigger Resource Allocation    sleep_time=${sleep_time}
    ${command3}    catenate
    ...    enb_dss_resource_allocation enb=1 cell=${cell_id} tgt_enb=2 tgt_cell=${tgt_cell}
    ...    dir=DL allocation_start_time=immediate
    ...    dl_allocated_normal_subframes=1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111
    ...    dl_prb_area_allocation_list=${list1}${list2}${list3}${list4}${list5}
    Execute Egate Command    ${command3}    pass_regexp=CRM Trigger Resource Allocation    sleep_time=${sleep_time}
    ${command4}    catenate
    ...    enb_dss_resource_allocation enb=1 cell=${cell_id} tgt_enb=2 tgt_cell=${tgt_cell}
    ...    dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,35|49,3
    Execute Egate Command    ${command4}    pass_regexp=CRM Trigger Resource Allocation    sleep_time=${sleep_time}
    Execute Egate Command    enb_crm_status enb=1 cell=${cell_id}    sleep_time=${sleep_time}









