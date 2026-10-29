*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-CN3ET    owner-xiujuan.sun    release-SBTS23R4
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/2cells_ecpri_N41_N78
@{PARAMS_IN_SWCONFIG}
...    ${rdPCsiPoolHkfPeriod_min}
...    ${rdHkfMinPCsiResPerSlot}
...    ${rdHkfMinPCsiRepPeriod}
...    ${rdHkfPCsiPoolMaxRCUsFactor}
...    ${uplane_6878}
${rdPCsiPoolHkfPeriod_min}    0x5901A6=1
${rdHkfMinPCsiResPerSlot}    0x5901A7=4
${rdHkfMinPCsiRepPeriod}    0x5901A8=40
${rdHkfPCsiPoolMaxRCUsFactor}    0x5901A9=60
${uplane_6878}    0x5901AB=1

@{PARAMS_IN_SCF}
...    @{beamformingAnd2200}
...    @{CB10596}
...    @{largerInactiveTimer}
# fix relation error
...    NRCELL-2:actCsirsMultiplexing=true

@{largerInactiveTimer}
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:nsaInactivityTimer=600

@{beamformingAnd2200}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=0
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:csirsPower=0
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent

@{CB10596}
...    NRCELL:actLongPucchResourceOpt=true
...    NRCELL:actIncreasedFdmUsersPerSlot=true
...    NRCELL:pucchF1ResOccConf=2-2-0_OCCs
...    NRCELL-1:pucchNumberHarqAnPrbs=2_PRBs
...    NRCELL-2:pucchNumberHarqAnPrbs=4_PRBs

@{CB006878_sharedOCC}
...    @{actMultipleDedicatedBWPs}
...    @{power_saving_BWP}
...    NRCELL:actDynUlResAlloc=true
...    NRCELL-1:reqMinNumPuschPrb=16
...    NRCELL-2:reqMinNumPuschPrb=2
...    NRCELL:srPeriodicity=slots20
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots40    NRBTS:actExplicitCsirsPoolSolution=true
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL:pucchF1ResOccConf=2-2-1_OCCs
...    NRCELL:pucchNumberHarqAnPrbs=Set_by_system

@{CB006878_off_MultiBWP_and_enhancedShowCase}
...    NRCELL:actDynUlResAlloc=false
...    NRCELL:reqMinNumPuschPrb=0
...    NRCELL:srPeriodicity=slots40
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    @{actMultipleDedicatedBWPs}
...    @{power_saving_BWP}

@{CB006878Multi_and_enhancedShowCase}
...    NRCELL:actDynUlResAlloc=true
...    NRCELL:reqMinNumPuschPrb=0
...    NRCELL:srPeriodicity=slots40
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    @{actMultipleDedicatedBWPs}
...    @{power_saving_BWP}

@{CB006878_inactive_and_enhancedShowCase}
...    NRCELL:actDynUlResAlloc=false
...    NRCELL:reqMinNumPuschPrb=0
...    NRCELL-1:pucchNumberHarqAnPrbs=2_PRBs
...    NRCELL-2:pucchNumberHarqAnPrbs=4_PRBs
...    NRCELL:srPeriodicity=slots40
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL:actPowerSavingBWP=false
...    @{inactMultipleDedicatedBWPs}
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-0
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-44

${default_ue_capability}    SEPARATOR=
...    e1a00000074e5a031e000380a03c1260c80008780818806804c020301c032a36146b04050d012cb2898087ad8202020e1de38720c3800206
...    4f1f570004f001c0013c002a36266b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a3626eb04050d01
...    2cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a36276b04050d012cb2898087ad8202020e1de38720c38002064f
...    1f55000005000000108389a00000000404d0103804044f60701800140e020381801c07000683e0000000000000e54d000100000965950034
...    aaa8081c002c000000100200462c4c0004080c1014181c202c4044484c648494989ca128

${default_ue_mrdc_capability}    SEPARATOR=
...    A10CF11A118000203040C081C385000000008723A110003030040C081C385000000408723A11000203060C0081C389A0000080872320D8000
...    203240C5C280000064641A00060640818B8500000108C83400080C9831070A00000291D06800101830700E14000006023F2320D8000203040
...    61C2800000E4641A0006060080C38500000208C826000080038500000248E8160041C2800001404391D08C0C01030206040E1C28000000043
...    91D0880C18300206040E1C2800000204391D06C0C010182060E14000007021C8E83406080C1830070A000005810E46413032040E1C2800001
...    84641203260E01C2800001A460160140000060180384D076BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF871808
...    5B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1C
...    F8710216C73E18150880000000000000000009110000006034800010100004000001000000800020040090000200000080800020000010000
...    400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C00020000018000
...    00602010020046000100000040000020100801002300008080002000000800040080118000400000101000040002004008800020200008000
...    40080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801

${default_ue_nr_capablity}    SEPARATOR=
...    E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C8
...    73E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807
...    BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C0
...    9F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31
...    CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C
...    8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F404
...    78C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8
...    683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7
...    D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC000000580
...    7C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7
...    D0494989CA091520

@{actMultipleDedicatedBWPs}
...    NRBTS:actMultipleDedicatedBWPs=true

@{inactMultipleDedicatedBWPs}
...    NRBTS:actMultipleDedicatedBWPs=false

@{power_saving_BWP}
...    NRCELL-2:actPowerSavingBWP=true
...    NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-45
...    NRCELL-2:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-63
...    NRCELL-2:pdcchAutoConfig:bwpChBwPowerSaving=60MHz
#...    NRCELL-2:pdcchAutoConfig:pucchSize=44
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=n162
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-45/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=150
...    NRBTS/BWP_PROFILE-63:bwpType=powerSaving
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthDl:cRbSizeDl=n162
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthUl:cRbSizeUl=n162
...    NRBTS/BWP_PROFILE-63:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-63/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|periodicity=sl5
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|periodicity=sl1
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=5|periodicity=sl20
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-63/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-2:maxNumOfCaUsersNRCell=96
...    NRCELL-2:maxNumOfNrDcSnUsers=192
...    NRCELL-2:maxNumOfRrcSA=192
...    NRCELL-2:maxNumOfSCellAlloc=192
...    NRCELL-2:maxNumOfUsersPerCell=192
...    NRCELL-2:maxNumOfUsersPerNRCell=192
...    NRCELL-2:msg1FrequencyStart=44

${SYSCOM_FLAG}    true
${WIRESHARK_FLAG}    False
@{REGISTER_FAILED}
...    RRC Reject was received
...    T300 expiration: No response to RRCSetupRequest

*** Test Cases ***
CB010596-SR-C-B2_ET_01_01_pucchF1ResOccConf set with shared 3OCC And Check PUCCH Resource when single BWP with 10M and multiBWP 100M chBW
    [Documentation]    6878 on and shared OCC. 10M only support singleBWP, so just 100M using multiBWP
    ...    LongpucchStartHarq2Prb those parameter can transfer to l2ps only CB008941 is on
    ...    numberF1Resource = HARQPRB(harqf1 in harq area) *cs*occ_quality_in_harq*+HARQprb(harqf1 in sr area)*cs*occ_quality_in_sr
    ...    numberF3Resource = 1 if enhancedshowcase else MIN(PRB(HARQ),8)
    ...    delta PRI=(1,2,5,6) for 10M CELL
    ...    10M cell: PRBSR=2 , P=16, K=2, csiprbperslot=2,HARQPRB=4 ,SR resource capabity =64, no msg4AckNack printed,
    ...    numberF1Resource=60, numberF3Resource=4
    ...    100M cell: PRBSR=4, p=28 HARQPRB=16, csi=14, k =14 ,sr resource capabiliyt= 112. deltaPRI=(2,3,6,7),msg4AckNack =4
    ...    pucchResourceCommonIndex=11. msg4AckNack: 4,numberF1Resource=84, numberF3Resource=8
    [Tags]    CB2-001
    Delta Commission Parameters And Wait Cells Onair    ${CB006878_sharedOCC}
    Check PucchRes Region and DeltaPRI and numberOfF1F3Resource of sharedOCC
    Check UE PucchRes Allocation for 10M Cell of sharedOCC
    Release Ues    ue_type=all
    Check UE PucchRes Allocation for 100M Cell of sharedOCC
    Fm Fault Should Not Exist    fault_id=7516

#CB010596-SR-C-B5_ET_03_01_Check SR and HARQ Resource When enhanced showcase with 10M and 100M When 6878 on in multi BWP
#    [Documentation]    cell-1: chBw=10MHz cell-2: chBw=100MHz
#    ...    CB008847 is inactivated: NRBTS:actBbPoolTddFr1 =false ;
#    ...    CB010596 is activated: NRCELL: actLongPucchResourceOpt=true;
#    ...    Beaforming is enable
#    ...    CB008941 is activated for cell1 and cell2
#    ...    CB006878 is activated for cell1 and cell-2
#    ...    LongpucchStartSR1Prb
#    ...    LongpucchStartHarqPrb
#    ...    LongpucchStartPcsi1Prb
#    ...    LongpucchStartPcsi2Prb
#    ...    LongpucchStartHarq2Prb those parameter can transfer to l2ps only CB008941 is on
#    [Tags]    CB5-003
#    Delta Commission Parameters And Wait Cells Onair    ${CB006878Multi_and_enhancedShowCase}
#    Check PucchRes Region and DeltaPRI and numberOfF1F3Resource for EnhancedShow Case with multiBWP and 6878 on
#    Check UE PucchRes Allocation for 10M Cell in EnhancedShow case with multiBWP and 6878 on
#    Release Ues    ue_type=all
#    Check UE PucchRes Allocation for 100M Cell in EnhancedShow case with multiBWP and 6878 on
#    Fm Fault Should Not Exist    fault_id=7516
#
#CB010596-SR-C-B5_ET_01_01_Check SR and HARQ Resource When enhanced showcase with 10M and 100M When 6878 off in multi BWP
#    [Documentation]    cell-1: chBw=10MHz,cell-2: chBw=100MHz
#    ...    CB008847 is inactivated: NRBTS:actBbPoolTddFr1 =false ;
#    ...    CB010596 is activated: NRCELL: actLongPucchResourceOpt=true;
#    ...    Beaforming is enable
#    ...    CB008941 is activated for cell1 and cell2
#    ...    CB006878 is inactivated for cell1 and cell-2
#    ...    LongpucchStartSR1Prb
#    ...    LongpucchStartHarqPrb
#    ...    LongpucchStartPcsi1Prb
#    ...    LongpucchStartPcsi2Prb
#    ...    LongpucchStartHarq2Prb those parameter can transfer to l2ps only CB008941 is on
#    [Tags]    CB5-001
#    Delta Commission Parameters And Wait Cells Onair    ${CB006878_off_MultiBWP_and_enhancedShowCase}
#    Check PucchRes Region and DeltaPRI and numberOfF1F3Resource for EnhancedShow Case with multiBWP and 6878 off
#    Check UE PucchRes Allocation for 10M Cell in EnhancedShow case
#    Release Ues    ue_type=all
#    Check UE PucchRes Allocation for 100M Cell in EnhancedShow case with multiBWP and 6878 off
#    Fm Fault Should Not Exist    fault_id=7516
#
#
#CB010596-SR-C-B5_ET_02_01_Check SR and HARQ Resource When enhanced showcase with 10M and 100M When 6878 off in single BWP
#    [Documentation]    cell-1: chBw=10MHz,cell-2: chBw=100MHz
#    ...    CB008847 is inactivated: NRBTS:actBbPoolTddFr1 =false ;
#    ...    CB010596 is activated: NRCELL: actLongPucchResourceOpt=true;
#    ...    Beaforming is enable
#    ...    CB008941 is activated for cell1 and cell2
#    ...    CB006878 is inactivated for cell1 and cell-2
#    ...    LongpucchStartSR1Prb
#    ...    LongpucchStartHarqPrb
#    ...    LongpucchStartPcsi1Prb
#    ...    LongpucchStartPcsi2Prb
#    ...    LongpucchStartHarq2Prb those parameter can transfer to l2ps only CB008941 is on
#    [Tags]    CB5-002
#    Delta Commission Parameters And Wait Cells Onair    ${CB006878_inactive_and_enhancedShowCase}
#    Cells Should Be Onair
#    Check PucchRes Region and DeltaPRI and numberOfF1F3Resource for EnhancedShow Case
#    Check UE PucchRes Allocation for 10M Cell in EnhancedShow case
#    Release Ues    ue_type=all
#    Check UE PucchRes Allocation for 100M Cell in EnhancedShow case with singleBWP
#    Fm Fault Should Not Exist    fault_id=7516


*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    Set Multi UEs in WTS
    update UE Capability

update UE Capability
    ${ue_param_cmd}    catenate
    ...    ue_nr_capabilities=${default_ue_nr_capablity} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${default_ue_mrdc_capability}
    FOR    ${ue_id}    IN RANGE    31    61
        Update Cfg    ue_param id=${ue_id} ${ue_param_cmd}
    END

Check PucchRes Region and DeltaPRI and numberOfF1F3Resource for EnhancedShow Case
    Start To Capture Wireshark Log    tag=cellStartup
    Lock And Unlock all Cells to make sure UE position no change
    Set_X2Link_up
    ${waitString}    Set Variable    itf_l2_ps_cell_CellSetupReq_t::2
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_002/cb5_002_cellStartup.ini    wait_string=${waitString}    name=cellStartup
    Check pucch size should be 4

Check PucchRes Region and DeltaPRI and numberOfF1F3Resource for EnhancedShow Case with multiBWP and 6878 on
    [Documentation]    deltaPRI,pucchregion including dyncprb info and f1f3 resource will be checked here.
    Start To Capture Wireshark Log    tag=cellStartup
    Lock And Unlock specific cell to make sure UE position no change    cell_id=1
    Lock And Unlock specific cell to make sure UE position no change    cell_id=2
    Set_X2Link_up
    ${waitString}    Set Variable    itf_l2_ps_cell_CellSetupReq_t::2
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_003/cb5_003_cellStartup.ini    wait_string=${waitString}    name=cellStartup
    Check pucch size should be 4

Check PucchRes Region and DeltaPRI and numberOfF1F3Resource for EnhancedShow Case with multiBWP and 6878 off
    Start To Capture Wireshark Log    tag=cellStartup
    Lock And Unlock specific cell to make sure UE position no change    cell_id=1
    Lock And Unlock specific cell to make sure UE position no change    cell_id=2
    Set_X2Link_up
    ${waitString}    Set Variable    itf_l2_ps_cell_CellSetupReq_t::2
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_001/cb5_001_cellStartup.ini    wait_string=${waitString}    name=cellStartup
    Check pucch size should be 4


Check PucchRes Region and DeltaPRI and numberOfF1F3Resource of sharedOCC
    [Documentation]    deltaPRI,pucchregion including dyncprb info and f1f3 resource will be checked here.
    Start To Capture Wireshark Log    tag=cellStartup
    Lock And Unlock specific cell to make sure UE position no change    cell_id=1
    Lock And Unlock specific cell to make sure UE position no change    cell_id=2
    Set_X2Link_up
    ${waitString}    Set Variable    itf_l2_ps_cell_CellSetupReq_t::2
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB2_001/cb2_001_cellStartup.ini    wait_string=${waitString}    name=cellStartup
    Check pucch size of CELL-1    expected_pucch_size=8
    Check pucch size of cell-2    expected_pucch_size=44

Check pucch size of CELL-1
    [Arguments]    ${expected_pucch_size}
    Object Should Exist    NRCELL-1:pucchConfig:pucchSize=${expected_pucch_size}

Check pucch size of CELL-2
    [Arguments]    ${expected_pucch_size}
    Object Should Exist    NRCELL-2:pucchConfig:pucchSize=${expected_pucch_size}

Check pucch size should be 4
    Object Should Exist    NRCELL:pucchConfig:pucchSize=4

Check UE PucchRes Allocation for 10M Cell in EnhancedShow case
    Start To Capture Wireshark Log    tag=10M
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=1    ue_id_start=31    ue_id_end_before=49
    ${10M_waitString}    Set Variable    SgNBAdditionRequestAcknowledge::18
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_002/cb5_002_l2psUserSetup_10M.ini    wait_string=${10M_waitString}    name=10M
    Check Pucch Resource    a2a_ini_file=${CURDIR}/a2a_file_CB5_002/cb5_002_10M.ini    ue_count=48    tag=10M

Check UE PucchRes Allocation for 10M Cell in EnhancedShow case with multiBWP and 6878 on
    Start To Capture Wireshark Log    tag=10M
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=1    ue_id_start=31    ue_id_end_before=49
    ${10M_waitString}    Set Variable    SgNBAdditionRequestAcknowledge::18
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_003/cb5_003_l2psUserSetup_10M.ini    wait_string=${10M_waitString}    name=10M
    Check Pucch Resource    a2a_ini_file=${CURDIR}/a2a_file_CB5_003/cb5_003_10M.ini    ue_count=48    tag=10M

Check UE PucchRes Allocation for 10M Cell of sharedOCC
    Start To Capture Wireshark Log    tag=10M
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=1    ue_id_start=31    ue_id_end_before=61
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=61    ue_id_end_before=65
    Execute Egate Command    ue_change_location id=65 cell=1
    Execute Egate Command    ue_register id=65    ${REGISTER_FAILED}
    ${10M_waitString}    Set Variable    SgNBAdditionRequestAcknowledge::30
    run keyword and continue on failure    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB2_001/cb2_001_l2psUserSetup_10M.ini
    ...    wait_string=${10M_waitString}    name=10M
    Check Pucch Resource    a2a_ini_file=${CURDIR}/a2a_file_CB2_001/cb2_001_10M.ini    ue_count=64    tag=10M

Check UE PucchRes Allocation for 100M Cell in EnhancedShow case with singleBWP
    Start To Capture Wireshark Log    tag=100M
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=2    ue_id_start=31    ue_id_end_before=49
    ${100M_waitString}    Set Variable    SgNBAdditionRequestAcknowledge::18
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_002/cb5_002_l2psUserSetup_100M.ini    wait_string=${100M_waitString}    name=100M
    Check Pucch Resource    a2a_ini_file=${CURDIR}/a2a_file_CB5_002/cb5_002_100M.ini    ue_count=48    tag=100M

Check UE PucchRes Allocation for 100M Cell in EnhancedShow case with multiBWP and 6878 on
    Start To Capture Wireshark Log    tag=100M
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=2    ue_id_start=31    ue_id_end_before=49
    ${100M_waitString}    Set Variable    SgNBAdditionRequestAcknowledge::18
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_003/cb5_003_l2psUserSetup_100M.ini    wait_string=${100M_waitString}    name=100M
    Check Pucch Resource    a2a_ini_file=${CURDIR}/a2a_file_CB5_003/cb5_003_100M.ini    ue_count=48    tag=100M

Check UE PucchRes Allocation for 100M Cell in EnhancedShow case with multiBWP and 6878 off
    Start To Capture Wireshark Log    tag=100M
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=2    ue_id_start=31    ue_id_end_before=49
    ${100M_waitString}    Set Variable    SgNBAdditionRequestAcknowledge::18
    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB5_001/cb5_001_l2psUserSetup_100M.ini    wait_string=${100M_waitString}    name=100M
    Check Pucch Resource    a2a_ini_file=${CURDIR}/a2a_file_CB5_001/cb5_001_100M.ini    ue_count=48    tag=100M

Check UE PucchRes Allocation for 100M Cell of sharedOCC
    Start To Capture Wireshark Log    tag=100M
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=1    ue_id_end_before=31
    Attach And Set ENDC For Number Of Normal Calls    cell_id=2    ue_id_start=31    ue_id_end_before=61
    ${100M_waitString}    Set Variable    SgNBAdditionRequestAcknowledge::30
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=61    ue_id_end_before=193
    Execute Egate Command    ue_change_location id=193 cell=2
    Execute Egate Command    ue_register id=193    ${REGISTER_FAILED}
    run keyword and continue on failure    Check WireShark Log    a2a_ini_file=${CURDIR}/a2a_file_CB2_001/cb2_001_l2psUserSetup_100M.ini
    ...    wait_string=${100M_waitString}    name=100M
    Check Pucch Resource    a2a_ini_file=${CURDIR}/a2a_file_CB2_001/cb2_001_100M.ini    ue_count=192    tag=100M

Lock And Unlock all Cells to make sure UE position no change
    Lock And Unlock specific cell to make sure UE position no change    cell_id=1
    Lock And Unlock specific cell to make sure UE position no change    cell_id=2

Set_X2Link_up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up    timeout=120

Set Multi UEs in WTS
    ${cfg_cmd_3}    catenate
    ...    uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00
    FOR    ${ue_id}    IN RANGE    61    100
        Update Cfg    set_ue simulated id=${ue_id} ${cfg_cmd_3} suci=0:311:489:0000:0:0:0216454${ue_id} mode=nr enb=2 cell=1
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${default_ue_capability}
    END
    FOR    ${ue_id}    IN RANGE    100    200
        Update Cfg    set_ue simulated id=${ue_id} ${cfg_cmd_3} suci=0:311:489:0000:0:0:021645${ue_id} mode=nr enb=2 cell=1
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${default_ue_capability}
    END

Perform Steps After Onair
    log    do Nothing here

Lock And Unlock specific cell to make sure UE position no change
    [Arguments]    ${cell_id}
    Lock Cell${cell_id}
    Unlock Cell${cell_id}
    Cells Should Be Onair    ${cell_id}

Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    END


Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
    UE Register To GNB    ${ue_id}

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg


Attach And Set ENDC For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC    ${ue_id}    ${cell_id}
    END

UE Attach To ENB And Set ENDC
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    reported successful RA
