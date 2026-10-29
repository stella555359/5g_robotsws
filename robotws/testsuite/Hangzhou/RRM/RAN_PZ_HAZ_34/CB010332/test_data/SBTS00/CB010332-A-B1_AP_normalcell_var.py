AEQE_BSR_NAME = "BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001"
# ############################## for PARAMS_IN_SCF ##############################
SRSforBEAM_NRCELL1 = [
    # NRCELL1 beamforming has been enabled in SCFC_1.xml
    # enable SRS beamforming
    "NRCELL-1:actDlSrsBm=true",
    "NRCELL-1:actUlSrsBm=true",
    "NRCELL-1:dftBeamDiffThresholdH=15",
    "NRCELL-1:dftBeamDiffThresholdV=15",
    "NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing",
    "NRCELL-1:mMimoAntArrayMode=Full 64TRX Array (4x8x2)",
    "NRCELL-1:srsForBeamMgmt:bSRS=0",
    "NRCELL-1:srsForBeamMgmt:comb=comb2",
    "NRCELL-1:srsForBeamMgmt:cSRS=13",
    "NRCELL-1:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200",
    "NRCELL-1:srsForBeamMgmt:srsPowerThresholdForUlBm=-132",
    "NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook",
    "NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40",
    # custom bsr must be set otherwise cell can't up
    "NRBTS:actCustomBsr=true",
    f"NRBTS/NRCELL-1:beamSet:customBeamSetName={AEQE_BSR_NAME}"
    ]

beamforming_enable_NRCELL2 = [
    "NRCELL-2:actBeamforming=true",
    # 8DL4UL cellmapping
    "NRCELL-2:nrCellType=8DL4UL",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX",  # under MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=TX",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=TX",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=RX",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX",
    "LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-2",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX",
    "LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1",
    # other setting
    "NRCELL-2:beamSet:basicBeamSet=beamSet_6",
    "delete:NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1",
    "delete:NRCELL-2:periodicCsiAcquisition:csirsPower",
    "delete:NRCELL-2:periodicCsiAcquisition:maxCsirsNumber",
    "NRCELL-2:msg1FrequencyStart=16",
    "NRCELL-2:nrofHARQProcessesForPDSCH=16",
    "NRCELL-2:openLoopScheme=NoPrecoding",
    "NRCELL-2:type0SearchSpaceConfigurationIndex=5",
    "NRCELL-2:zeroCorrelationZoneConfig=13",
    "NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams",
    "NRBTS:actFdmEnhancedScheduling=true",
    "NRCELL-2:dlMimoMode=2x2 Open Loop Spatial Multiplexing",
    "NRCELL-2:numOfSubSectors=0sub-sector",
    "NRCELL-2:numberOfRxBeamforming=4Rx"]

SRSforBEAM_NRCELL2 = beamforming_enable_NRCELL2 + [
    "NRCELL-2:actDlSrsBm=true",
    "NRCELL-2:actUlSrsBm=true",
    "NRCELL-2:dftBeamDiffThresholdH=15",
    "NRCELL-2:dftBeamDiffThresholdV=15",
    "NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing",
    "NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)",
    "NRCELL-2:srsForBeamMgmt:bSRS=0",
    "NRCELL-2:srsForBeamMgmt:comb=comb2",
    "NRCELL-2:srsForBeamMgmt:cSRS=13",
    "NRCELL-2:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200",
    "NRCELL-2:srsForBeamMgmt:srsPowerThresholdForUlBm=-132",
    "NRCELL-2:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook",
    "NRCELL-2:srsForBeamMgmt:srsUePeriodicity=slots40",
    # custom bsr must be set otherwise cell can't up
    "NRBTS:actCustomBsr=true",
    f"NRBTS/NRCELL-2:beamSet:customBeamSetName={AEQE_BSR_NAME}"
]

PARAMS_IN_SCF = [
    # 10356/10332 disabled
    "NRCELL:actHPPosMethodOptList=disabled",
    # nGRanAccessPointPosition mapping to subcell
    "NRCELL:nGRanAccessPointPosition:confidence=100|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLatitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLongitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:directionOfAltitude=Height|altitude=0",
    "NRCELL:nGRanAccessPointPosition:latitudeSign=North|altitude=0",
    "NRCELL:nGRanAccessPointPosition:orientationOfMajorAxis=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintyAltitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMajor=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMinor=0|altitude=0",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",
    # NRPOSINFO mapping to subcell
    "NRCELL/NRPOSINFO-1",
] + \
    SRSforBEAM_NRCELL1 + \
    SRSforBEAM_NRCELL2

# ############################## for delta commission ##############################
DISABLE_10332_IN_ALL_CELLS = "NRCELL:actHPPosMethodOptList=disabled"
ENABLE_10332_NRCELL3 = "NRCELL-3:actHPPosMethodOptList=UL-TDOA"
ENABLE_10332_NRCELL4 = "NRCELL-4:actHPPosMethodOptList=UL-TDOA"
ENABLE_10332_NRCELL5 = "NRCELL-5:actHPPosMethodOptList=UL-TDOA"
ENABLE_10332_NRCELL6 = "NRCELL-6:actHPPosMethodOptList=UL-TDOA"
ENABLE_10332_NRCELL7 = "NRCELL-7:actHPPosMethodOptList=UL-TDOA"
ENABLE_10332_NRCELL8 = "NRCELL-8:actHPPosMethodOptList=UL-TDOA"
ENABLE_10332_NRCELL9 = "NRCELL-9:actHPPosMethodOptList=UL-TDOA"
ENABLE_10332_NRCELL10 = "NRCELL-10:actHPPosMethodOptList=UL-TDOA"

ENABLE_10332_NRCELL3_10 = [
    ENABLE_10332_NRCELL3,
    ENABLE_10332_NRCELL4,
    ENABLE_10332_NRCELL5,
    ENABLE_10332_NRCELL6,
    ENABLE_10332_NRCELL7,
    ENABLE_10332_NRCELL8,
    ENABLE_10332_NRCELL9,
    ENABLE_10332_NRCELL10,
]
LOCK_ALL_NRCELLS = "NRCELL:administrativeState=Locked"
UNLOCK_ALL_NRCELLS = "NRCELL:administrativeState=Unlocked"
UNLOCK_NRCELL1_2 = [
    "NRCELL-1:administrativeState=Unlocked",
    "NRCELL-2:administrativeState=Unlocked"
]

UNLOCK_NRCELL3_10 = []
for cell_id in range(3, 11):
    UNLOCK_NRCELL3_10.append("NRCELL-{}:administrativeState=Unlocked".format(cell_id))

pdcch_searchspace = "PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon"

Frame_1208_and_SRS = [
    # frame 1208
    "NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4",
    "NRCELL:tddFrameStructure:frameStructureType=semiStatic",
    "NRCELL:tddFrameStructure:guardPeriodLength=2Symbols",
    # fix fault7516
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:duration=3|periodicity=sl5",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:duration=1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:searchSpaceId=2|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:searchSpaceType=Type1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:duration=3|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:searchSpaceId=3|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:searchSpaceType=Type2|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:slotOffset=5|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:duration=3|periodicity=sl5",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:duration=1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:searchSpaceId=5|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:searchSpaceType=Type1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:duration=3|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:searchSpaceId=6|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:searchSpaceType=Type2|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:slotOffset=5|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:duration=3|periodicity=sl5",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:duration=1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:searchSpaceId=5|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:searchSpaceType=Type1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:duration=3|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:searchSpaceId=6|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:searchSpaceType=Type2|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:slotOffset=5|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:duration=3|periodicity=sl5",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:duration=1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:searchSpaceId=2|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:searchSpaceType=Type1|periodicity=sl1",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:duration=3|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:searchSpaceId=3|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:searchSpaceType=Type2|periodicity=sl20",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:slotOffset=5|periodicity=sl20",
    "NRCELL-1:maxNumOfCaUsersNRCell=213",
    "NRCELL:pagingOffset=3",
    "NRCELL:ssPbchBlockPower=0",
    "NRCELL-1:pdcchAutoConfig:pucchSize=30",
    "NRCELL-2:pdcchAutoConfig:pucchSize=",
    "NRCELL-3:pdcchAutoConfig:pucchSize=",
    "NRCELL-4:pdcchAutoConfig:pucchSize=2",
    "NRCELL-5:pdcchAutoConfig:pucchSize=",
    "NRCELL-6:pdcchAutoConfig:pucchSize=26",
    "NRCELL-7:pdcchAutoConfig:pucchSize=",
    "NRCELL-8:pdcchAutoConfig:pucchSize=26",
    "NRCELL-9:pdcchAutoConfig:pucchSize=",
    "NRCELL-10:pdcchAutoConfig:pucchSize=26",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",
    # srs pooling
    "NRBTS:allowSlowPrbPoolingStatNdmSrs=true",
]

Frame_1070_and_SRS = [
    # frame 1070
    "NRCELL:tddFrameStructure:ulDlDataSlotRatio=3/7",
    "NRCELL:tddFrameStructure:frameStructureType=semiStatic",
    "NRCELL:tddFrameStructure:guardPeriodLength=2Symbols",
    "NRCELL:fPdcchMonOccsnPo=2",
    # fix fault7516
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:duration=2|searchSpaceId=1",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:duration=1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:periodicity=sl1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:searchSpaceType=Type1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:duration=2|searchSpaceId=3",
    f"NRBTS/BWP_PROFILE-5/{pdcch_searchspace}:searchSpaceType=Type2|searchSpaceId=3",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:duration=2|searchSpaceId=4",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:duration=1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:periodicity=sl1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:searchSpaceType=Type1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:duration=2|searchSpaceId=6",
    f"NRBTS/BWP_PROFILE-54/{pdcch_searchspace}:searchSpaceType=Type2|searchSpaceId=6",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:duration=2|searchSpaceId=4",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:duration=1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:periodicity=sl1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:searchSpaceType=Type1|searchSpaceId=5",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:duration=2|searchSpaceId=6",
    f"NRBTS/BWP_PROFILE-55/{pdcch_searchspace}:searchSpaceType=Type2|searchSpaceId=6",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:duration=2|searchSpaceId=1",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:duration=1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:periodicity=sl1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:searchSpaceType=Type1|searchSpaceId=2",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:duration=2|searchSpaceId=3",
    f"NRBTS/BWP_PROFILE-6/{pdcch_searchspace}:searchSpaceType=Type2|searchSpaceId=3",
    "NRCELL:maxNumOfCaUsersNRCell=192",
    "NRCELL:pagingOffset=1",
    "NRCELL:pdcchAutoConfig:pucchSize=24",
    "NRCELL-1:ssPbchBlockPower=6",
    "NRCELL-2:ssPbchBlockPower=6",
    "NRCELL-3:ssPbchBlockPower=-9",
    "NRCELL-4:ssPbchBlockPower=-9",
    "NRCELL-5:ssPbchBlockPower=-9",
    "NRCELL-6:ssPbchBlockPower=-9",
    "NRCELL-7:ssPbchBlockPower=-9",
    "NRCELL-8:ssPbchBlockPower=-9",
    "NRCELL-9:ssPbchBlockPower=-9",
    "NRCELL-10:ssPbchBlockPower=-9",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb4",
    "NRCELL:srsForPositioning:cSRS=1",
    "NRCELL:srsForPositioning:numberOfCS=2 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots10",
    # srs pooling
    "NRBTS:allowSlowPrbPoolingStatNdmSrs=false",
]

Frame_8406 = [
    "NRCELL:tddFrameStructure:ulDlDataSlotRatio=4/6",
    "NRCELL:tddFrameStructure:frameStructureType=semiStatic",
    "NRCELL:tddFrameStructure:guardPeriodLength=4Symbols",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb4",
    "NRCELL:srsForPositioning:cSRS=63",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots1280",
    # srs pooling
    "NRBTS:allowSlowPrbPoolingStatNdmSrs=true",
]

Frame_1106_0ms = [
    "NRCELL:prachConfigurationIndex=96",
    "NRCELL:tddFrameStructure:frameStructureType=tdLte",
    "NRCELL:tddFrameStructure:guardPeriodLength=4Symbols",
    "NRCELL:tddFrameStructure:lteToNrFrameShift=0ms",
    "NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2",
    "NRCELL:tddFrameStructure:ulDlDataSlotRatio=3/7",
]

Frame_1106_3ms = [
    "NRCELL:prachConfigurationIndex=96",
    "NRCELL:tddFrameStructure:frameStructureType=tdLte",
    "NRCELL:tddFrameStructure:guardPeriodLength=4Symbols",
    "NRCELL:tddFrameStructure:lteToNrFrameShift=3ms",
    "NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2",
    "NRCELL:tddFrameStructure:ulDlDataSlotRatio=3/7",
]

if __name__ == "__main__":
    print(PARAMS_IN_SCF)
