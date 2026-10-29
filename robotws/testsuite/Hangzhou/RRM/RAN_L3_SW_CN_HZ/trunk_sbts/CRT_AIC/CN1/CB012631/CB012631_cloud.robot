*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_Aic    RAN_5G    CRT    team-PZ3_7    owner-dandchen    release-25R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    master_vDU    vDUCNF00
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${ue_info1}    uec=1 release=17 red_cap=true idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
${ue_info2}    nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00

@{PARAMS_IN_SWCONFIG_DU1}    0x58057A=3    0x580582=0x20000
@{PARAMS_IN_SWCONFIG_DU2}    0x58057A=3    0x580582=0x20000

${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/2du/8cells_du1_2T2F_du2_2T2F
@{PARAMS_IN_SCF_CU}    @{NRREL}    @{5GC000704}    @{5GC000732}    @{CU_other}    @{PARAMS_FOR_5QI1_CU}    @{NRHOIF}
...    @{CB008225_CB006597_CU}
...    @{CU_20M_BWP_PROFILE}    @{CU_10M_BWP_PROFILE}

@{PARAMS_IN_SCF_DU1}    @{DU1_NRREL}    @{CB012631_para}    @{PARAMS_FOR_5QI1_DU}    @{DU1_add_small20M}
...    NRBTS-1/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    NRBTS/NRPMRNL-1:miNrCellUtilization=5min
...    @{CB008225_CB006597_DU}
...    @{DU1_add_small20M}
...    NRBTS-1/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRBTS-1/NRDU-1:actInterNumerologyCa=true
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRBTS-1/NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS-1/NRDU-1:actConnectedModeMobilityCA=true
...    @{DU1_add_10M}

@{DU1_add_10M}
...    @{BWP_PROFILE-2}
...    @{BWP_PROFILE-23}
...    NRCELL-3:gscnOrSsPbchArfcn=7881
...    NRCELL-3:nrarfcn=636666
...    NRCELL-3:msg1FrequencyStart=4
...    NRCELL-3:type0CoresetConfigurationIndex=2
...    MRBTS-1/NRBTS-1/NRCELL-3:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-3:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23|cellBwpId=1
...    NRCELL-3:chBw=10MHz
...    NRCELL-3:type0SearchSpaceConfigurationIndex=2

@{PARAMS_IN_SCF_DU2}    @{DU2_NRREL}    @{CB012631_para}    @{PARAMS_FOR_5QI1_DU}    @{DU2_add_small20M}
...    NRBTS-1/NRDU-2:actInterNumerologyCa=true
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    NRBTS/NRPMRNL-1:miNrCellUtilization=5min
...    @{CB008225_CB006597_DU}
...    @{DU2_add_small20M}
...    NRBTS-1/NRDU-2:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRBTS-1/NRDU-2:actInterNumerologyCa=true
...    NRBTS-1/NRDU-2:flexibleCAMode=NumberCellAmount
...    NRBTS-1/NRDU-2:actConnectedModeMobilityCA=true
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations

@{CU_20M_BWP_PROFILE}
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-20
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-21
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-22
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-20
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-21
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-22
...    NRBTS/BWP_PROFILE-20:bwpType=initial
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS-1/BWP_PROFILE-21:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthDl:cRbSizeDl=n273
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthUl:cRbSizeUl=n273
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS-1/BWP_PROFILE-22:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthUl:cRbStartUl=crb0
...    NRCELL-1:nrarfcn=636646
...    NRCELL-2:nrarfcn=636646
...    NRBTS-1:actMultipleDedicatedBWPs=true

@{BWP_PROFILE-20}
...    NRBTS/BWP_PROFILE-20:bwpType=initial
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-20:locationAndBandwidthUl:cRbStartUl=crb0
...    MRBTS/NRBTS/BWP_PROFILE-20/PDCCH-1:alSelection=static
...    MRBTS/NRBTS/BWP_PROFILE-20/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-20/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-20/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-20/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-20/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-20/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

@{BWP_PROFILE-21}
...    NRBTS-1/BWP_PROFILE-21:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS-1/BWP_PROFILE-21:locationAndBandwidthUl:cRbStartUl=sameAsDl

...    NRBTS-1/BWP_PROFILE-21/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1:downgradeAL16toAL8=notAllowed


...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4

...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5

...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120

...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7

...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8


@{BWP_PROFILE-22}
...    NRBTS-1/BWP_PROFILE-22:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS-1/BWP_PROFILE-22:locationAndBandwidthUl:cRbStartUl=sameAsDl

...    NRBTS-1/BWP_PROFILE-22/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1:downgradeAL16toAL8=notAllowed


...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=9

...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10

...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=5|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=11

...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48

...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=12
...    NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=12

...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=13
...    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=13



@{CU_10M_BWP_PROFILE}
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-23
...    NRBTS/BWP_PROFILE-2:bwpType=initial
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS-1/BWP_PROFILE-23:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRCELL-3:nrarfcn=636666
...    NRCELL-3:chBw=10MHz

@{BWP_PROFILE-2}
...    NRBTS/BWP_PROFILE-2:bwpType=initial
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=coreset0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=coreset0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:alSelection=static
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:downgradeAL16toAL8=notAllowed
...    MRBTS/NRBTS/BWP_PROFILE-2/PDCCH-1:downgradeALProactive=false
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3

@{BWP_PROFILE-23}
...    NRBTS-1/BWP_PROFILE-23:bwpType=dedicated
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS-1/BWP_PROFILE-23:locationAndBandwidthUl:cRbStartUl=sameAsDl

...    NRBTS-1/BWP_PROFILE-23/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:alSelection=dynamic
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1:downgradeALProactive=false

#...    delete:BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet
#...    delete:BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:coresetCommon

...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:aggregationLevelList=AL1_AL2_AL4_AL8
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:cqiCorrectionUp=8
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl1=101
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl2=69
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl4=33
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl8=10
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:cqiDciCssAl16=0
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:highOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:lowOlcCqiOffset=1
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=160
...    NRBTS/BWP_PROFILE-23/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureReduction=100

...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4

...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5

...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=24

...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7

...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8

...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=39|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n3|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n3|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=9|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=9
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=1|searchSpaceId=9

...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=10|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=10
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=10

...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=7|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n2|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n2|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n1|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=11|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=11
...    MRBTS-1/NRBTS-1/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=2|searchSpaceId=11

@{DU1_add_small20M}
...    NRCELL-1:gscnOrSsPbchArfcn=7850
...    NRCELL-1:nrarfcn=636646
...    NRCELL-1:msg1FrequencyStart=30
...    NRCELL-1:type0CoresetConfigurationIndex=2
...    NRBTS-1:actMultipleDedicatedBWPs=true
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-20|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-21|cellBwpId=1
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-22|cellBwpId=2
...    @{BWP_PROFILE-20}
...    @{BWP_PROFILE-21}
...    @{BWP_PROFILE-22}

@{DU2_add_small20M}
...    NRCELL-2:gscnOrSsPbchArfcn=7850
...    NRCELL-2:nrarfcn=636646
...    NRCELL-2:msg1FrequencyStart=30
...    NRCELL-2:type0CoresetConfigurationIndex=2
...    NRBTS-1:actMultipleDedicatedBWPs=true
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-20|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-21|cellBwpId=1
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-22|cellBwpId=2
...    @{BWP_PROFILE-20}
...    @{BWP_PROFILE-21}
...    @{BWP_PROFILE-22}

@{CB008225_CB006597_CU}
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:ranPagingCycle=v32
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:t380=5min
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRCELL:ranAC=0

@{CB008225_CB006597_DU}
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:ranPagingCycle=v32
...    NRCELL:ranAC=0

@{CU_other}
...    NRCELL:actCsiMeasEthFlowControl=CSIMeasBasedAllUe
...    NRBTS-1/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRBTS-1/NRDU-2:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRBTS-1/NRDU-1:actInterNumerologyCa=true
...    NRBTS-1/NRDU-2:actInterNumerologyCa=true
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRBTS-1/NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS-1/NRDU-2:flexibleCAMode=NumberCellAmount
...    NRBTS-1/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1/NRDU-2:actConnectedModeMobilityCA=true
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:actVoNR=true
...    NRCELL:actRedCapUeSupport=true
...    NRCELL:maxNumOfRrcSARedCap=20
...    NRCELL:cellBarredRedCap=no barring

@{CB012631_para}
...    NRCELL:actSssgSwitching=eMBB UEs
...    NRBTS-1:sssgSwitching:cqiThreshold=8
...    NRBTS-1:sssgSwitching:dlBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitching:dlBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitching:dlRateThresholdFromSparseSssg=35
...    NRBTS-1:sssgSwitching:dlRateThresholdToSparseSssg=30
...    NRBTS-1:sssgSwitching:measurementDurationFromSparseSssg=40
...    NRBTS-1:sssgSwitching:measurementDurationToSparseSssg=160
...    NRBTS-1:sssgSwitching:ulBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitching:ulBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitching:ulRateThresholdNoVoNRFromSparseSssg=10
...    NRBTS-1:sssgSwitching:ulRateThresholdNoVoNRToSparseSssg=5
...    NRBTS-1:sssgSwitching:ulRateThresholdVoNRFromSparseSssg=35
...    NRBTS-1:sssgSwitching:ulRateThresholdVoNRToSparseSssg=30

...    NRBTS-1:sssgSwitchingRedCap:cqiThreshold=8
...    NRBTS-1:sssgSwitchingRedCap:dlBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitchingRedCap:dlBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitchingRedCap:dlRateThresholdFromSparseSssg=35
...    NRBTS-1:sssgSwitchingRedCap:dlRateThresholdToSparseSssg=30
...    NRBTS-1:sssgSwitchingRedCap:measurementDurationFromSparseSssg=40
...    NRBTS-1:sssgSwitchingRedCap:measurementDurationToSparseSssg=160
...    NRBTS-1:sssgSwitchingRedCap:ulBufferEmptyRatioFromSparseSssg=40
...    NRBTS-1:sssgSwitchingRedCap:ulBufferEmptyRatioToSparseSssg=90
...    NRBTS-1:sssgSwitchingRedCap:ulRateThresholdFromSparseSssg=10
...    NRBTS-1:sssgSwitchingRedCap:ulRateThresholdToSparseSssg=5

...    NRCELL:actRedCapUeSupport=true
...    NRCELL:maxNumOfRrcSARedCap=20
...    NRCELL:cellBarredRedCap=no barring

@{actSssgSwitching_embb_redcap}
...    NRCELL:actSssgSwitching=eMBB and RedCap UEs

@{actSssgSwitching_disabled}
...    NRCELL:actSssgSwitching=disabled

@{actSssgSwitching_embb}
...    NRCELL:actSssgSwitching=eMBB UEs

@{PARAMS_FOR_5QI1_CU}
...    NRCELL:actCDrx=true
...    NRCELL:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20

@{PARAMS_FOR_5QI1_DU}
...    NRCELL:actCDrx=true
...    NRCELL:actVoNR=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_MAC-4:schedulBSD=50ms
...    NRBTS/NRDRB_RLC_AM-1:dlTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-1:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-1:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-1:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-1:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20

@{5GC000732}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tRLFindForDUSA=2000ms
...    NRBTS:tWaitingRlRecoverSA=4000ms
@{NRREL}
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:sCellPrio=1

...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:handoverAllowedSARedCap=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:sCellPrio=1

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellPrio=1

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:sCellPrio=1

@{5GC000704}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=36
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-1:freqBandIndicatorNR
...    NRCELL-1/NRREL-35:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-35:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-35:gNbId=35
...    NRCELL-1/NRREL-35:gNbIdLength=22
...    NRCELL-1/NRREL-35:lcrId=1
...    NRCELL-1/NRREL-35:removeNotAllowed=false
...    NRCELL-1/NRREL-35:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-35:gnbPlmn:mnc=489|mncLength=3

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms480
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=5
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=176210

...    NRCELL-1/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=0
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=0
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms480
...    NRCELL-1/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:scs=30 KHz
...    NRCELL-1/NRHOIF-4:ssbFrequency=636576
...    @{EVENT}

@{EVENT}
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0

...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=95
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0

...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=90
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480

...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=40
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=41

...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

@{DU1_NRREL}
...    NRCELL-1/NRREL-2
...    NRCELL-1/NRREL-11
...    NRCELL-1/NRREL-35
...    NRCELL-11/NRREL-1
...    NRBTS-1/NRADJNRCELL-1
...    @{add_NRHOIF}

@{add_NRHOIF}
...    NRCELL-1/NRHOIF-1
...    NRBTS/NRCELL-1/NRHOIF-1:ssbFrequency=176210
...    NRCELL-1/NRHOIF-4
...    NRBTS/NRCELL-1/NRHOIF-4:ssbFrequency=636576
...    NRCELL-1:measGapSelectionSA=favourUeThroughput

@{DU2_NRREL}
...    NRCELL-2/NRREL-1
...    NRCELL-2/NRREL-12
...    NRCELL-12/NRREL-2
...    NRBTS-1/NRADJNRCELL-1

@{sssg_enable}
...    pcid:50, scellIdx
...    pcid:60, scellIdx
...    searchSpaceId 39
...    monitoringSlotPeriodicityAndOffset sl4
...    searchSpaceId 38
...    searchSpaceSwitchDelay-r17 25

@{sssg_enable_nrcell_11}
...    pcid:60, scellIdx
...    searchSpaceId 39
...    monitoringSlotPeriodicityAndOffset sl4
...    searchSpaceId 38
...    searchSpaceSwitchDelay-r17 25

@{sssg_enable_redcap}
...    pcid:50, scellIdx
...    searchSpaceId 39
...    monitoringSlotPeriodicityAndOffset sl4
...    searchSpaceId 38
...    searchSpaceSwitchDelay-r17 25

@{sssg_not_config}
...    pcid:52, scellIdx

@{HO_cell11}
...    EXT_ENB-2.1 to EXT_ENB-2.11
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    rrcReconfigurationComplete
...    searchSpaceId 39
...    monitoringSlotPeriodicityAndOffset sl4
...    searchSpaceId 38
...    searchSpaceSwitchDelay-r17 25

@{HO_cell2}
...    EXT_ENB-2.1 to EXT_ENB-2.2
...    pcid:51, scellIdx:0
...    rrcReconfigurationComplete
...    searchSpaceId 39
...    monitoringSlotPeriodicityAndOffset sl4
...    searchSpaceId 38
...    searchSpaceSwitchDelay-r17 25

@{HO_cell2_sssg_disable}
...    EXT_ENB-2.1 to EXT_ENB-2.2
...    pcid:51, scellIdx:0
...    rrcReconfigurationComplete

@{HO_cell11_Redcap}
...    EXT_ENB-2.1 to EXT_ENB-2.11
...    pcid:60, scellIdx:0
...    rrcReconfigurationComplete

${ue_nr_capabilities_SA_Capa_perFR_Full}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0080E0040004000000000000541B013582308682041E20D0
...    0656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170020380100010000000000001546C4DD608C21A08
...    10748340165B262A86873E238F40CFB027C639F30C7942C0E070F02E007FE003801FF8002E0040700200020000000000002A0D88DAC118434
...    1020F941A0092D931541439F11C78C00000000000000E1E04FFF800003FFE000002E004070020002000000000000019E1E020007118000000
...    58081787850001C46000002160205E1E14000701000001058081787808001C4D000006160205E1E2680071340000205808178788C001C4D00
...    000A16020401C046805101360020BA002381A14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C305830C631
...    8C6F417001E00140E0A00E060120038120020301F004010000000080000100581B59534010400002594941000019652500540EAA95550B002
...    4006814000A10100200404008010808020040200400840401002010020042020040080802004101004008040100208080100202008010D50F
...    8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680
${ue_redcap}    SEPARATOR=
...    E1A573A040280C078140603808102002039E80D58000F1080016080080C049838004E1E12006341A0138180663839D43C4600D608C21D4810
...    788340105B2A8A018426314B9884CA15092387804FE0380003F80E00002C004200030000000000002A87801AC11843A9020F1068020B65514
...    03084C62973109942A12470F009FC0700007F01C00005800840006000000000000550F007582308752041E20D00416CAA28061098C52E6213
...    2854248E1E013F80E0000FE0380000B00108000C000000000000AA1E016B04610EA4083C41A0082D954500C21318A5CC42650A8491C3C027F
...    01C0001FC07000016002100018000000000001543C04D608C21D4810788340105B2A8A018426314B9884CA15092387804FE0380003F80E000
...    02C004200030000000000002A8780DAC11843A9020F1068020B6551403084C62973109942A12470F009FC0700007F01C00005800840006000
...    000000000550F01F582308752041E20D00416CAA28061098C52E62132854248E1E013F80E0000FE0380000B00108000C000000000000AA1E0
...    5EB04610EA4083C41A0082D954500C21318A5CC42650A8491C3C027E0180001F806000016002100018000000000001543C0CD608C21D48107
...    88340105B2A8A018426314B9884CA15092387804F80200003E00800002C004200030000000000002A8781BAC11843A9020F1068020B655140
...    3084C62973109942A12470F009F00400007C01000005800840006000000000000550F047582308752041E20D00416CAA28061098C52E62132
...    854248E1E013F00C0000FC0300000B00108000C000000000000AA1E09EB04610EA4083C41A0082D954500C21318A5CC42650A8491C3C027F0
...    1C0001FC07000016002100018000000000001543C18D608C21D4810788340105B2A8A018426314B9884CA15092387804FE0380003F80E0000
...    2C004200030000000000002A87833AC11843A9020F1068020B6551403084C62973109942A12470F009FC0700007F01C000058008400060000
...    00000000550F06F582308752041E20D00416CAA28061098C52E62132854248E1E013F80E0000FE0380000B00108000C000000000000AA1E0E
...    EB04610EA4083C41A0082D954500C21318A5CC42650A8491C3C027C0100001F004000016002100018000000000001542C21D608C21D481074
...    8340105B2A8A018426314B9884CA15092387804FC0300003F00C00002C004200030000000000002A8584BAC11843A9020E9068020B6551403
...    084C62973109942A12470F009FC0700007F01C00005800840006000000000000550B09B582308752041D20D00416CAA28061098C52E621328
...    54248E1E013F80E0000FE0380000B00108000C000000000000AA1613EB04610EA4083A41A0082D954500C21318A5CC42650A8491C3C027F01
...    C0001FC07000016002100018000000000001D42C2800D608C21D4810748340105B2A8A018426314B9884CA15092387804EE0380003B80E000
...    02C004200030000000000002A8585FAC11843A9020E9068020B6551403084C62973109942A12470F009FC0700007F01C00005800840006000
...    000000000550F107582308752041E20D00416CAA28061098C52E62132854248E1E013F80E0000FE0380000B00108000C000000000000AA1E2
...    2EB04610EA4083C41A0082D954500C21318A5CC42650A8491C3C027F01C0001FC07000016002100018000000000001542C4CD608C21D48107
...    48340105B2A8A018426314B9884CA15092387804EE0380003B80E00002C004200030000000000002A8589BAC11843A9020E9068020B655140
...    3084C62973109942A12470F009DC0700007701C00005800840006000000000000550B13B582308752041D20D00416CAA28061098C52E62132
...    854248E1E013A80A0000EA0280000B00108000C000000000000AA1E2A6B04610EA4083C41A0082D954500C21318A5CC42650A8491C3C027E0
...    180001F806000016002100018000000000001542C59D608C21D4810748340105B2A8A018426314B9884CA15092387804EE0380003B80E0000
...    2C0042000300000000000000800E2680000000380800000400C04D80082E0001602010009C3F6BA000160014080A00C06012803000301F004
...    0100000000800001005919481D004100000965000400006594000152388A07102C009001A0700008004008010008020041489560940601A00
...    80000496080006
${SSSG_SWITCH_ATT}    M55308C00142
${SSSG_SWITCH_SUCC}    M55308C00143
${SSSG_SWITCH_ATT_REDCAP}    M55308C00146
${SSSG_SWITCH_SUCC_REDCAP}    M55308C00147

${SLOTS_UE_DENSE_SSSG}    M55308C00144
${SLOTS_UE_SPARSE_SSSG}    M55308C00145
${SLOTS_UE_DENSE_SSSG_REDCAP}    M55308C00148
${SLOTS_UE_SPARSE_SSSG_REDCAP}    M55308C00149

@{PM_Counters_Check_embb}
...    NRCELL-1:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-1:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-1:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-1:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG}>0

@{PM_Counters_Check_embb_resume}
...    NRCELL-1:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-1:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-1:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-1:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG}>0

@{PM_Counters_Check_embb_du2}
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
...    NRCELL-12:NCELA:${SSSG_SWITCH_ATT}=0
...    NRCELL-12:NCELA:${SSSG_SWITCH_SUCC}=0
...    NRCELL-12:NCELA:${SLOTS_UE_DENSE_SSSG}=0
...    NRCELL-12:NCELA:${SLOTS_UE_SPARSE_SSSG}=0

@{PM_Counters_Check_embb_du2_disable}
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT}=0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC}=0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG}=0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG}=0

@{PM_Counters_Check_redcap}
...    NRCELL-1:NCELA:${SSSG_SWITCH_ATT_REDCAP}>0
...    NRCELL-1:NCELA:${SSSG_SWITCH_SUCC_REDCAP}>0
...    NRCELL-1:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}>0
...    NRCELL-1:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_ATT_REDCAP}>0
...    NRCELL-11:NCELA:${SSSG_SWITCH_SUCC_REDCAP}>0
...    NRCELL-11:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}>0
...    NRCELL-11:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}>0

@{PM_Counters_Check_redcap_du2}
...    NRCELL-2:NCELA:${SSSG_SWITCH_ATT_REDCAP}>0
...    NRCELL-2:NCELA:${SSSG_SWITCH_SUCC_REDCAP}>0
...    NRCELL-2:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}>0
...    NRCELL-2:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}>0

@{PM_Counters_Check_multiUE}
...    NRCELL-1:NCELA:${SSSG_SWITCH_ATT}>0
...    NRCELL-1:NCELA:${SSSG_SWITCH_SUCC}>0
...    NRCELL-1:NCELA:${SSSG_SWITCH_ATT_REDCAP}>0
...    NRCELL-1:NCELA:${SSSG_SWITCH_SUCC_REDCAP}>0
...    NRCELL-1:NCELA:${SLOTS_UE_DENSE_SSSG}>0
...    NRCELL-1:NCELA:${SLOTS_UE_SPARSE_SSSG}>0
...    NRCELL-1:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}>0
...    NRCELL-1:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}>0

@{PM_Counters_Check_nrcell_3}
...    NRCELL-3:NCELA:${SSSG_SWITCH_ATT}=0
...    NRCELL-3:NCELA:${SSSG_SWITCH_SUCC}=0
...    NRCELL-3:NCELA:${SSSG_SWITCH_ATT_REDCAP}=0
...    NRCELL-3:NCELA:${SSSG_SWITCH_SUCC_REDCAP}=0
...    NRCELL-3:NCELA:${SLOTS_UE_DENSE_SSSG}=0
...    NRCELL-3:NCELA:${SLOTS_UE_SPARSE_SSSG}=0
...    NRCELL-3:NCELA:${SLOTS_UE_DENSE_SSSG_REDCAP}=0
...    NRCELL-3:NCELA:${SLOTS_UE_SPARSE_SSSG_REDCAP}=0

@{default DRX release}
...    drx-Config release
...    Added QosFlow with QFI:2 fiveQI:1

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    UE1: Is INACTIVE

@{resum_success_cell11}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResumeComplete
...    pcid:60, scellIdx:0

#cell-1 633696
#cell-2 633696
#cell-4 636576

*** Test Cases ***
CB012631_ET
    [Documentation]
    ...    This user scenario is to test single or multi embb or redcap UE configured with 2SSSGs. and state change
    ...    between dense and aparse. also IWK with UE HO and CA. and IWK with voNR.
    ...    [configuration]: NRCELL-1: bwp:100M +20M
    ...    [step]:
    ...       a. embb ue attach nrcell-1, blind add nrcell-11, start traffic, then stop traffic, then start traffic
    ...       b. Handover to FDD nrcell-11, blind add, then stop traffic, start traffic, release UE.
    ...       c. embb ue attach nrcell-1+vonr, Handover to interDU nrcell-2, blind add nrcell-12, start/stop traffic. release UE.
    ...       d. redcap UE rrc reestablish to nrcell-1. same step from a to c.
    ...       f. total 30 embb +redcap ue setup on nrcell-1.
    ...       g. embb IWK vonr IWK HO
    ...       h. ue attach nrcell-3 with 10M with 5 search space, ue no sssg configured
    ...       i: embb ue attach and do resume successfully
    [Tags]
    embb UE IWK HO
    redcap UE IWK HO
    MultiUE attach
    embb UE IWK vonr IWK HO to target sssg diable
    emBB and redcap UE attach nrcell-3
    embb ue attach cell-11 and resume successful

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_qosflow id=2 5qi=5
    Update Cfg Aic    set_qosflow id=3 5qi=1
    Update Cfg Aic    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg Aic    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg Aic    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3 qos_rules=1,2,3
    Update Cfg Aic    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg Aic    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg Aic    set_amf_region id=1 tac_list=200,280,300,400,500,600,788 plmn=311:489,311:490,311:491
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3 sib1_period=3000
    ${V_2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.150 ng=10.0.11.12 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2=10.0.12.13:36422
    ...    x2_peers=none xn=10.0.12.14 nssai=0x1:0xd143a5 amf=1
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg Aic    set_ue simulated id=21 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645420 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=22 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645421 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=23 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645422 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=24 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645423 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=25 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645424 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=26 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645425 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=27 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645426 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=28 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645427 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=29 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645428 enb=2 cell=1 mode=nr
    Update Cfg Aic    set_ue simulated id=30 ${ue_info1} ${ue_info2} suci=0:311:489:0000:0:0:021645429 enb=2 cell=1 mode=nr

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach and Setup PDU session
    [Arguments]    ${ue_id}=1    ${cell}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${sssg_enable}
    ...    ${ue_capa}=${ue_nr_capabilities_SA_Capa_perFR_Full}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${ue_capa}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Setup PDU Session    ue_id=${ue_id}    pdu=${pdu}    nwslice=${nwslice}    gw=${gw}    pass_regexp=${pass_regexp}
    Send Traffic SA    ue_id=${ue_id}

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}

Send Traffic SA
    [Arguments]    ${ue_id}=1
    sleep    3s    wait ue in sparse state
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink Internal traffic
    sleep    6s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink Internal traffic
    sleep    6s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput

Setup VONR Call On New PDU Session
    [Arguments]    ${ue_id}=1    ${gateway}=2    ${pdu}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gateway}    pass_regexp=${pass_regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf    pass_regexp=${default DRX release}
    Execute Egate Command    qosflow_disp
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on

A2 A3 handover to cell11
    [Arguments]    ${ue_id}=1    ${cellfreq}=633696    ${cellfreq2}=176210    ${pass_ho}=${HO_cell11}
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11 phycell_id=60 nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=${pass_ho}
    sleep    6s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink Internal traffic
    sleep    6s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput

A3 handover to cell2
    [Arguments]    ${ue_id}=1    ${cellfreq2}=633696    ${pass_ho}=${HO_cell2}
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=5 phycell_id=51 nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=${pass_ho}
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink Internal traffic
    sleep    6s

MultiUE attach
    Clear Counter Files Du Aic
    FOR    ${i}    IN RANGE    1    20
        UE Attach and Setup PDU session    ue_id=${i}    cell=1    pdu=1    nwslice=1    gw=1
    END
    FOR    ${i}    IN RANGE    21    30
        UE Attach and Setup PDU session    ue_id=${i}     cell=1    pdu=1    nwslice=1    gw=1    ue_capa=${ue_redcap}
        ...    pass_regexp=${sssg_enable_redcap}
    END
    Release ues    ue_type=all
    Check Counters Du Aic    ${PM_Counters_Check_multiUE}

embb UE IWK HO
    Delta Commission Parameters Du2    ${actSssgSwitching_embb}
    Delta Commission Parameters Du    ${actSssgSwitching_embb}
    Cells Should Be Onair Du    timeout=30
    Clear Counter Files Du Aic
    Clear Counter Files Du2 Aic
    UE Attach and Setup PDU session    ue_id=1    cell=1    pdu=1    nwslice=1    gw=1
    A2 A3 handover to cell11
    Release Ues    ue_type=all
    UE Attach and Setup PDU session    ue_id=1    cell=1    pdu=1    nwslice=1    gw=1
    Setup VONR Call On New PDU Session
    A3 handover to cell2
    Release Ues    ue_type=all
    Check Counters Du Aic    ${PM_Counters_Check_embb}
    Check Counters Du2 Aic    ${PM_Counters_Check_embb_du2}

redcap UE IWK HO
    Clear Counter Files Du Aic
    Clear Counter Files Du2 Aic
    Delta Commission Parameters Du    ${actSssgSwitching_embb_redcap}
    Delta Commission Parameters Du2    ${actSssgSwitching_embb_redcap}
    Cells Should Be Onair Du    timeout=30
    UE Attach and Setup PDU session    ue_id=21    cell=1    pdu=1    nwslice=1    gw=1    ue_capa=${ue_redcap}
    ...    pass_regexp=${sssg_enable_redcap}
    A2 A3 handover to cell11    ue_id=21    pass_ho=${HO_cell11_Redcap}
    Release Ues    ue_type=all
    UE Attach and Setup PDU session    ue_id=21    cell=1    pdu=1    nwslice=1    gw=1    ue_capa=${ue_redcap}
    ...    pass_regexp=${sssg_enable_redcap}
    Setup VONR Call On New PDU Session    ue_id=21
    A3 handover to cell2    ue_id=21
    Release Ues    ue_type=all
    Check Counters Du Aic    ${PM_Counters_Check_redcap}
    Check Counters Du2 Aic    ${PM_Counters_Check_redcap_du2}

embb UE IWK vonr IWK HO to target sssg diable
    Clear Counter Files Du Aic    ${False}
    Clear Counter Files Du2 Aic    ${False}
    Delta Commission Parameters Du    ${actSssgSwitching_disabled}
    Delta Commission Parameters Du2    ${actSssgSwitching_disabled}
    Delta Commission Parameters Du    ${actSssgSwitching_embb}
    Cells Should Be Onair Du    timeout=30
    UE Attach and Setup PDU session    ue_id=1    cell=1    pdu=1    nwslice=1    gw=1
    A2 A3 handover to cell11
    Release Ues    ue_type=all
    UE Attach and Setup PDU session    ue_id=1    cell=1    pdu=1    nwslice=1    gw=1
    Setup VONR Call On New PDU Session
    A3 handover to cell2    ue_id=1    pass_ho=${HO_cell2_sssg_disable}
    Trigger RRCReestablishment
    Release Ues    ue_type=all
    Check Counters Du Aic    ${PM_Counters_Check_embb}
    Check Counters Du2 Aic    ${PM_Counters_Check_embb_du2_disable}
    Delta Commission Parameters Du    ${actSssgSwitching_embb_redcap}
    Delta Commission Parameters Du2    ${actSssgSwitching_embb_redcap}
    Cells Should Be Onair Du    timeout=30

embb ue attach cell-11 and resume successful
    Clear Counter Files Du Aic    ${False}
    ${core_assis_info}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${core_assis_info}
    UE Attach and Setup PDU session    ue_id=1    cell=1    pdu=1    nwslice=1    gw=1
    A2 A3 handover to cell11
    Trigger UE inactive and resume
    sleep    5s
    Execute Egate Command    data_trf_start ue=1 pdu=1 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink Internal traffic
    sleep    6s
    Execute Egate Command    ue_stats_nr id=1 scell=0-5 type=pdsch    Throughput
    Release Ues    ue_type=all
    Check Counters Du Aic    ${PM_Counters_Check_embb_resume}

Trigger UE inactive and resume
    Trigger UE Inactive by UAI
    Trigger RRC Resume Success    cell_id=11

Trigger UE Inactive by UAI
    [Arguments]    ${ue_id}=1
    Stop traffic
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive    pass_regexp=${INACTIVE_check}    timeout=30s
    #sleep    1s    #sleep for inactive procedure complete

Stop traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    UE ${ue_id}: DL Traffic was stopped
    sleep    5s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput

Trigger RRC Resume Success
    [Arguments]    ${ue_id}=1    ${cell_id}=11    ${pass_regexp}=${resum_success_cell11}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mo_Data
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Trigger RRCReestablishment
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${RRE_check}=reestablishment complete
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure    pass_regexp=${RRE_check}
    sleep    5s    check traffic ready
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput

emBB and redcap UE attach nrcell-3
    Clear Counter Files Du Aic
    Delta Commission Parameters Du    ${actSssgSwitching_embb_redcap}
    Cells Should Be Onair Du    timeout=30
    UE Attach and Setup PDU session    ue_id=1    cell=3    pdu=1    nwslice=1    gw=1    pass_regexp=${sssg_not_config}
    UE Attach and Setup PDU session    ue_id=21    cell=3    pdu=1    nwslice=1    gw=1    pass_regexp=${sssg_not_config}
    ...    ue_capa=${ue_redcap}
    Release ues    ue_type=all
    Check Counters Du Aic    ${PM_Counters_Check_nrcell_3}