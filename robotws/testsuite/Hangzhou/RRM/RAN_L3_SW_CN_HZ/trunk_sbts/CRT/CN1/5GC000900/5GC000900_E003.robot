*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-SG02    owner-yige.g.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    release-SBTS22R1
...    STATE_CONFIGURED    RAN_5G

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{ET_E003}

@{ET_E003}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-1:msg1FrequencyStart=15
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-2:msg1FrequencyStart=15
...    MRBTS-1/NRBTS-1/NRCELL-3:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-3:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRCELL-3:msg1FrequencyStart=15
...    MRBTS-1/NRBTS-1/NRCELL-4:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-4:msg1FrequencyStart=15
...    MRBTS-1/NRBTS-1/NRCELL-11:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-11:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-12:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-12:trackingAreaDN
...    delete:MRBTS-1/NRBTS-1/NRCELL-12:ranAC
...    delete:MRBTS-1/NRBTS-1/NRCELL-3:ranAC
...    MRBTS-1/NRBTS-1:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:fiveGsTac=100
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:trackingAreaId=300
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

${ue_nr_capabilities}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E
...    3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238
...    F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B
...    0381C3C17003FF001C00FFC000B000E0571F11B582308682041F280C2AB64C55850E7C471E300000000000000000000000009FFF000007FFC00
...    0002C003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C000
...    0042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B8
...    50001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A00
...    1C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C289
...    13639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF8112040
...    81B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F824008000000040000080200000001
...    00000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C0100001400800
...    00B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901
...    000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B965250400032594901
...    00003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A05028140A05028140A05028140A05028
...    140A0502800304040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018
...    030080600C0201803040400802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${ue_eutra_capabilities}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000000
...    2C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C04180
...    9A26002E41E24E8913639F0E24E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8300820000804040
...    08020100C01840001008080100202018030C0002010100C01804030060100C018400010080801004020040100000000

@{PARAMS_DELETE_CELL1}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-1
...    delete:NRCELLGRP-0
...    NRBTS/NRDU-1:refNrCellGroup=1,2,3,4,5

@{PARAMS_DELETE_CELL3}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-3
...    delete:NRCELLGRP-2
...    NRBTS/NRDU-1:refNrCellGroup=1,3,4,5
...    MRBTS-1/NRBTS-1/NRCELL-3:msg1FrequencyStart=15
@{PARAMS_DELETE_CELL4}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-4
...    delete:NRCELL-4/NRREDRT-1
...    delete:NRCELL-4/NRREL-1
...    delete:NRCELLGRP-3
...    NRBTS/NRDU-1:refNrCellGroup=1,4,5

@{PARAMS_DELETE_CELL11}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-11
...    delete:NRCELL-11/NRCELL_FDD-1
...    delete:NRCELLGRP-4
...    NRBTS/NRDU-1:refNrCellGroup=1,5

@{PARAMS_DELETE_CELL12}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-12
...    delete:NRCELL-12/NRCELL_FDD-1
...    delete:NRCELLGRP-5
...    NRBTS/NRDU-1:refNrCellGroup=1

@{PAPAMS_ADD_CELL1}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1:actAsiDistMimoNr=false
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    NRCELL-1:a2MeasRedirectEnabled=none
...    NRCELL-1:absThreshSsbRsrpConsolidation=0
...    NRCELL-1:absThreshSsbRsrqConsolidation=10
...    NRCELL-1:actAdaptiveSr=false
...    NRCELL-1:actDl256Qam=true
...    NRCELL-1:actEnhancedVoNR=false
...    NRCELL-1:actGBRAdmissionControl=off
...    NRCELL-1:actVoNR=false
...    NRCELL-1:configuredEpsTac=777
...    NRCELL-1:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:dlMuLowSinrThreshold=-60
...    NRCELL-1:dlMuMaxNumPairedUEs=8
...    NRCELL-1:dlMuNeighborThreshold=80
...    NRCELL-1:dlMuPairingThreshold=5
...    NRCELL-1:dlQam256PowerBackoffAbove6=40
...    NRCELL-1:dlQam256PowerBackoffSub6=30
...    NRCELL-1:drxWactDlEnabled=false
...    NRCELL-1:drxWactUlEnabled=false
...    NRCELL-1:duratScgFailures=0ms
...    NRCELL-1:emergencyFBMode=redirection
...    NRCELL-1:enDcSyncStatus=synchronous
...    NRCELL-1:expectedCellSize=5km
...    NRCELL-1:gscnOrSsPbchArfcn=7840
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:initialPreambleReceivedTargetPower=-150
...    NRCELL-1:lteToNrTimeOffset=30
...    NRCELL-1:maxNumPuschAllocationPerSlot=4
...    NRCELL-1:mcsIndexForArtificialLoad=0
...    NRCELL-1:measGapSelectionSA=balancedChoice
...    NRCELL-1:mgta=ms0
...    NRCELL-1:msg1FrequencyStart=15
...    NRCELL-1:nrOfScgFailures=0
...    NRCELL-1:nrarfcn=633000
...    NRCELL-1:nrofHARQProcessesForPDSCH=16
...    NRCELL-1:pMaxNROwnCell=23
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:pagingTargetRate=MCS8_SF1
...    NRCELL-1:physCellId=50
...    NRCELL-1:prachConfigurationIndex=96
...    NRCELL-1:preambleTransMax=n200
...    NRCELL-1:pucchDataDtxNumOfSamples=30
...    NRCELL-1:puschDataDtxNumOfSamples=30
...    NRCELL-1:raResponseWindow=sl20
...    NRCELL-1:ranAC=0
...    NRCELL-1:reqMinNumPuschPrb=235
...    NRCELL-1:rloConsecDtxThreshold=2
...    NRCELL-1:rloDtxRatioThreshold=50
...    NRCELL-1:rloPathLossThreshold=130
...    NRCELL-1:rloSinrThreshold=-45
...    NRCELL-1:rlpDetDlHarqThreshold=500
...    NRCELL-1:rsrpThresholdSSB=37
...    NRCELL-1:sCellBadChannelQualityThreshold=14
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:sCellGoodChannelQualityThreshold=18
...    NRCELL-1:ssPbchBlockPower=-4
...    NRCELL-1:t300=600ms
...    NRCELL-1:targetTotalLoad=0
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-1:type0CoresetConfigurationIndex=12
...    NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRCELL-1:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-1:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-1:ullaDeltaSinrMin=-150
...    NRCELL-1:voiceFBMode=redirection
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-1:actCsiResAllocOptList=disabled
...    NRCELL-1:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-10
...    NRCELL-1:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-1:csirsForTracking:firstRE=0
...    NRCELL-1:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-1:dlPtrs:dlPtrsFreqDensityThresNrb0=3
...    NRCELL-1:dlPtrs:dlPtrsFreqDensityThresNrb1=3
...    NRCELL-1:drxProfile1:drxInactivityTimer=80ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-1:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-1:fPdcchMonOccsnPo=0
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-1:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-1:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-1:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-1:ulPowerControlCommon:p0NominalSrs=-96
...    NRCELL-1:ulPtrs:ulPtrsFreqDensityThresNrb0=3
...    NRCELL-1:ulPtrs:ulPtrsFreqDensityThresNrb1=3
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-1:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-1:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-1:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-1:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-1:a1MeashoSsbRsrp=${EMPTY}
...    NRCELL-1:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-1:a1MeashoSsbRsrq=${EMPTY}
...    NRCELL-1:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-1:a2MeasRedirectSsbRsrp=${EMPTY}
...    NRCELL-1:a2MeasRedirectSsbRsrq=${EMPTY}
...    NRCELL-1:a2MeasReleaseSsbRsrp=${EMPTY}
...    NRCELL-1:a2MeasReleaseSsbRsrq=${EMPTY}
...    NRCELL-1:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-1:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrp=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrq=${EMPTY}
...    NRCELL-1:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-1:a3MeasSsbRsrp=${EMPTY}
...    NRCELL-1:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-1:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-1:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-1:a5MeasSsbRsrp=${EMPTY}
...    NRCELL-1:a5MeasSsbRsrq=${EMPTY}
...    NRCELL-1:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-1:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-1:cellCsiImLocationList=${EMPTY}
...    NRCELL-1:cellCsiRsLocationList=${EMPTY}
...    NRCELL-1:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-1:drxProfile2=${EMPTY}
...    NRCELL-1:drxProfileNrAnr=${EMPTY}
...    NRCELL-1:eirpControl=${EMPTY}
...    NRCELL-1:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-1:emergencyAreaIdList=${EMPTY}
...    NRCELL-1:emergencyCallRestrictions=${EMPTY}
...    NRCELL-1:fiveQiDrbDrxList=${EMPTY}
...    NRCELL-1:infTddFrameStructure=${EMPTY}
...    NRCELL-1:lcsToGcsTranslate=${EMPTY}
...    NRCELL-1:nGRanAccessPointPosition=${EMPTY}
...    NRCELL-1:nrhoirDNList=${EMPTY}
...    NRCELL-1:pciExcludeList=${EMPTY}
...    NRCELL-1:pdcchAutoConfig=${EMPTY}
...    NRCELL-1:pdschHrLaConfig=${EMPTY}
...    NRCELL-1:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-1:puschHrLaConfig=${EMPTY}
...    NRCELL-1:srsForBeamMgmt=${EMPTY}
...    NRCELL-1:srsForSubbandBm=${EMPTY}
...    NRCELL-1:uacAcCatList=${EMPTY}
...    NRCELL-1:uacAcContParSetList=${EMPTY}
...    NRCELL-1:ulBler=${EMPTY}
...    NRCELL-1:wbSbSrsSwitch=${EMPTY}
...    NRCELL-1:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-1:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-1:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-1:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-1:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-1:mMimoAntArrayMode=${EMPTY}
...    NRCELL-1:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-1:n310VoNR=${EMPTY}
...    NRCELL-1:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-1:srPeriodicityMin=${EMPTY}
...    NRCELL-1:t310VoNR=${EMPTY}
...    NRCELL-1:vonrReservation=${EMPTY}
...    NRCELLGRP-0:scs=30 KHz
...    NRCELLGRP-0:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-0:nrCellList=1

@{PAPAMS_ADD_CELL3}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3:actAsiDistMimoNr=false
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1

...    NRCELL-3:a2MeasRedirectEnabled=none
...    NRCELL-3:absThreshSsbRsrpConsolidation=0
...    NRCELL-3:absThreshSsbRsrqConsolidation=10
...    NRCELL-3:actAdaptiveSr=false
...    NRCELL-3:actDl256Qam=true
...    NRCELL-3:actEnhancedVoNR=false
...    NRCELL-3:actGBRAdmissionControl=off
...    NRCELL-3:actVoNR=false
...    NRCELL-3:cellDepType=NSA
...    NRCELL-3:cellReselectionPriority=4
...    NRCELL-3:chBw=80MHz
...    NRCELL-3:configuredEpsTac=777
...    NRCELL-3:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:dlMuLowSinrThreshold=-60
...    NRCELL-3:dlMuMaxNumPairedUEs=8
...    NRCELL-3:dlMuNeighborThreshold=80
...    NRCELL-3:dlMuPairingThreshold=5
...    NRCELL-3:dlQam256PowerBackoffAbove6=40
...    NRCELL-3:dlQam256PowerBackoffSub6=30
...    NRCELL-3:drxWactDlEnabled=false
...    NRCELL-3:drxWactUlEnabled=false
...    NRCELL-3:duratScgFailures=0ms
...    NRCELL-3:emergencyFBMode=redirection
...    NRCELL-3:enDcSyncStatus=synchronous
...    NRCELL-3:expectedCellSize=5km
...    NRCELL-3:freqBandIndicatorNR=41
...    NRCELL-3:gscnOrSsPbchArfcn=6351
...    NRCELL-3:ifhoSsbSmtcOffset=0
...    NRCELL-3:initialPreambleReceivedTargetPower=-150
...    NRCELL-3:lcrId=3
...    NRCELL-3:lteToNrTimeOffset=30
...    NRCELL-3:maxNumPuschAllocationPerSlot=4
...    NRCELL-3:mcsIndexForArtificialLoad=0
...    NRCELL-3:measGapSelectionSA=balancedChoice
...    NRCELL-3:mgta=ms0
...    NRCELL-3:msg1FrequencyStart=15
...    NRCELL-3:nrOfScgFailures=0
...    NRCELL-3:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-3
...    NRCELL-3:nrarfcn=508020
...    NRCELL-3:nrofHARQProcessesForPDSCH=16
...    NRCELL-3:pMaxNROwnCell=23
...    NRCELL-3:pagingOffset=1
...    NRCELL-3:pagingTargetRate=MCS8_SF1
...    NRCELL-3:physCellId=52
...    NRCELL-3:prachConfigurationIndex=96
...    NRCELL-3:preambleTransMax=n200
...    NRCELL-3:pucchDataDtxNumOfSamples=30
...    NRCELL-3:puschDataDtxNumOfSamples=30
...    NRCELL-3:raResponseWindow=sl20
...    NRCELL-3:reqMinNumPuschPrb=197
...    NRCELL-3:rloConsecDtxThreshold=2
...    NRCELL-3:rloDtxRatioThreshold=50
...    NRCELL-3:rloPathLossThreshold=130
...    NRCELL-3:rloSinrThreshold=-45
...    NRCELL-3:rlpDetDlHarqThreshold=500
...    NRCELL-3:rsrpThresholdSSB=37
...    NRCELL-3:sCellBadChannelQualityThreshold=14
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:sCellGoodChannelQualityThreshold=18
...    NRCELL-3:ssPbchBlockPower=-4
...    NRCELL-3:t300=600ms
...    NRCELL-3:targetTotalLoad=0
...    NRCELL-3:type0CoresetConfigurationIndex=12
...    NRCELL-3:type0SearchSpaceConfigurationIndex=5
...    NRCELL-3:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-3:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-3:ullaDeltaSinrMin=-150
...    NRCELL-3:voiceFBMode=redirection
...    NRCELL-3:weightForSCellSelection=60
...    NRCELL-3:actCsiResAllocOptList=disabled
...    NRCELL-3:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-3:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-11
...    NRCELL-3:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-3:csirsForTracking:firstRE=0
...    NRCELL-3:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-3:dlPtrs:dlPtrsFreqDensityThresNrb0=3
...    NRCELL-3:dlPtrs:dlPtrsFreqDensityThresNrb1=3
...    NRCELL-3:drxProfile1:drxInactivityTimer=80ms
...    NRCELL-3:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-3:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-3:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-3:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-3:fPdcchMonOccsnPo=0
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-3:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-3:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-3:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-3:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-3:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-3:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-3:ulPowerControlCommon:p0NominalSrs=-96
...    NRCELL-3:ulPtrs:ulPtrsFreqDensityThresNrb0=3
...    NRCELL-3:ulPtrs:ulPtrsFreqDensityThresNrb1=3
...    NRCELL-3:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-3:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-3:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-3:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-3:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-3:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-3:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-3:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-3:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-3:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-3:a1MeashoSsbRsrp=${EMPTY}
...    NRCELL-3:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-3:a1MeashoSsbRsrq=${EMPTY}
...    NRCELL-3:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-3:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-3:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-3:a2MeasRedirectSsbRsrp=${EMPTY}
...    NRCELL-3:a2MeasRedirectSsbRsrq=${EMPTY}
...    NRCELL-3:a2MeasReleaseSsbRsrp=${EMPTY}
...    NRCELL-3:a2MeasReleaseSsbRsrq=${EMPTY}
...    NRCELL-3:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-3:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-3:a2MeashoSsbRsrp=${EMPTY}
...    NRCELL-3:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-3:a2MeashoSsbRsrq=${EMPTY}
...    NRCELL-3:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-3:a3MeasSsbRsrp=${EMPTY}
...    NRCELL-3:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-3:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-3:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-3:a5MeasSsbRsrp=${EMPTY}
...    NRCELL-3:a5MeasSsbRsrq=${EMPTY}
...    NRCELL-3:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-3:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-3:cellCsiImLocationList=${EMPTY}
...    NRCELL-3:cellCsiRsLocationList=${EMPTY}
...    NRCELL-3:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-3:drxProfile2=${EMPTY}
...    NRCELL-3:drxProfileNrAnr=${EMPTY}
...    NRCELL-3:eirpControl=${EMPTY}
...    NRCELL-3:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-3:emergencyAreaIdList=${EMPTY}
...    NRCELL-3:emergencyCallRestrictions=${EMPTY}
...    NRCELL-3:fiveQiDrbDrxList=${EMPTY}
...    NRCELL-3:infTddFrameStructure=${EMPTY}
...    NRCELL-3:lcsToGcsTranslate=${EMPTY}
...    NRCELL-3:nGRanAccessPointPosition=${EMPTY}
...    NRCELL-3:nrhoirDNList=${EMPTY}
...    NRCELL-3:pciExcludeList=${EMPTY}
...    NRCELL-3:pdcchAutoConfig=${EMPTY}
...    NRCELL-3:pdschHrLaConfig=${EMPTY}
...    NRCELL-3:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-3:puschHrLaConfig=${EMPTY}
...    NRCELL-3:srsForBeamMgmt=${EMPTY}
...    NRCELL-3:srsForSubbandBm=${EMPTY}
...    NRCELL-3:uacAcCatList=${EMPTY}
...    NRCELL-3:uacAcContParSetList=${EMPTY}
...    NRCELL-3:ulBler=${EMPTY}
...    NRCELL-3:wbSbSrsSwitch=${EMPTY}
...    NRCELL-3:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-3:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-3:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-3:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-3:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-3:mMimoAntArrayMode=${EMPTY}
...    NRCELL-3:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-3:n310VoNR=${EMPTY}
...    NRCELL-3:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-3:srPeriodicityMin=${EMPTY}
...    NRCELL-3:t310VoNR=${EMPTY}
...    NRCELL-3:vonrReservation=${EMPTY}
...    NRCELLGRP-2:scs=30 KHz
...    NRCELLGRP-2:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-2:nrCellList=3

@{PAPAMS_ADD_CELL4}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4:actAsiDistMimoNr=false
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-4:a2MeasRedirectEnabled=none
...    NRCELL-4:absThreshSsbRsrpConsolidation=0
...    NRCELL-4:absThreshSsbRsrqConsolidation=10
...    NRCELL-4:actAdaptiveSr=false
...    NRCELL-4:actDl256Qam=true
...    NRCELL-4:actEnhancedVoNR=false
...    NRCELL-4:actGBRAdmissionControl=off
...    NRCELL-4:actVoNR=false
...    NRCELL-4:cbraPreamblesPerSsb=n60
...    NRCELL-4:ccLoadThreshold=50
...    NRCELL-4:cellReselectionPriority=5
...    NRCELL-4:chBw=80MHz
...    NRCELL-4:configuredEpsTac=777
...    NRCELL-4:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:dlQam256PowerBackoffAbove6=40
...    NRCELL-4:drxWactDlEnabled=false
...    NRCELL-4:drxWactUlEnabled=false
...    NRCELL-4:emergencyFBMode=redirection
...    NRCELL-4:freqBandIndicatorNR=41
...    NRCELL-4:gscnOrSsPbchArfcn=6582
...    NRCELL-4:lcrId=4
...    NRCELL-4:maxNumPuschAllocationPerSlot=4
...    NRCELL-4:measGapSelectionSA=balancedChoice
...    NRCELL-4:mgta=ms0
...    NRCELL-4:msg1FrequencyStart=15
...    NRCELL-4:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-4
...    NRCELL-4:nrarfcn=526020
...    NRCELL-4:nrofHARQProcessesForPDSCH=16
...    NRCELL-4:pMaxNROwnCell=23
...    NRCELL-4:pagingTargetRate=MCS8_SF1
...    NRCELL-4:physCellId=53
...    NRCELL-4:prachConfigurationIndex=96
...    NRCELL-4:raResponseWindow=sl20
...    NRCELL-4:reqMinNumPuschPrb=197
...    NRCELL-4:rloConsecDtxThreshold=1
...    NRCELL-4:rloDtxRatioThreshold=1
...    NRCELL-4:rloPathLossThreshold=100
...    NRCELL-4:rloSinrThreshold=-45
...    NRCELL-4:sCellBadChannelQualityThreshold=14
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellGoodChannelQualityThreshold=18
...    NRCELL-4:t301=600ms
...    NRCELL-4:targetTotalLoad=0
...    NRCELL-4:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-4:type0CoresetConfigurationIndex=12
...    NRCELL-4:type0SearchSpaceConfigurationIndex=5
...    NRCELL-4:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-4:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-4:zeroCorrelationZoneConfig=15
...    NRCELL-4:actCsiResAllocOptList=disabled
...    NRCELL-4:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    NRCELL-4:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-4:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-11
...    NRCELL-4:csirsForTracking:firstRE=0
...    NRCELL-4:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-4:dlPtrs:actDlPtrs=false
...    NRCELL-4:drxProfile1:drxInactivityTimer=10ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-4:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-4:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-4:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-4:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-4:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-4:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-4:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-4:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-4:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-4:ulPowerControlCommon:p0NominalSrs=-96
...    NRCELL-4:ulPtrs:actUlPtrs=true
...    NRCELL-4:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-4:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-4:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-4:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-4:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-4:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-4:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-4:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-4:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-4:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-4:a1MeashoSsbRsrp=${EMPTY}
...    NRCELL-4:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-4:a1MeashoSsbRsrq=${EMPTY}
...    NRCELL-4:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-4:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-4:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-4:a2MeasRedirectSsbRsrp=${EMPTY}
...    NRCELL-4:a2MeasRedirectSsbRsrq=${EMPTY}
...    NRCELL-4:a2MeasReleaseSsbRsrp=${EMPTY}
...    NRCELL-4:a2MeasReleaseSsbRsrq=${EMPTY}
...    NRCELL-4:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-4:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-4:a2MeashoSsbRsrp=${EMPTY}
...    NRCELL-4:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-4:a2MeashoSsbRsrq=${EMPTY}
...    NRCELL-4:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-4:a3MeasSsbRsrp=${EMPTY}
...    NRCELL-4:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-4:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-4:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-4:a5MeasSsbRsrp=${EMPTY}
...    NRCELL-4:a5MeasSsbRsrq=${EMPTY}
...    NRCELL-4:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-4:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-4:cellCsiImLocationList=${EMPTY}
...    NRCELL-4:cellCsiRsLocationList=${EMPTY}
...    NRCELL-4:csirsBeamMgmt=${EMPTY}
...    NRCELL-4:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-4:drxProfile2=${EMPTY}
...    NRCELL-4:drxProfileNrAnr=${EMPTY}
...    NRCELL-4:eirpControl=${EMPTY}
...    NRCELL-4:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-4:emergencyAreaIdList=${EMPTY}
...    NRCELL-4:emergencyCallRestrictions=${EMPTY}
...    NRCELL-4:fPdcchMonOccsnPo=${EMPTY}
...    NRCELL-4:fiveQiDrbDrxList=${EMPTY}
...    NRCELL-4:infTddFrameStructure=${EMPTY}
...    NRCELL-4:lcsToGcsTranslate=${EMPTY}
...    NRCELL-4:nGRanAccessPointPosition=${EMPTY}
...    NRCELL-4:nrhoirDNList=${EMPTY}
...    NRCELL-4:pciExcludeList=${EMPTY}
...    NRCELL-4:pdcchAutoConfig=${EMPTY}
...    NRCELL-4:pdschHrLaConfig=${EMPTY}
...    NRCELL-4:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-4:puschHrLaConfig=${EMPTY}
...    NRCELL-4:srsForBeamMgmt=${EMPTY}
...    NRCELL-4:srsForSubbandBm=${EMPTY}
...    NRCELL-4:uacAcCatList=${EMPTY}
...    NRCELL-4:uacAcContParSetList=${EMPTY}
...    NRCELL-4:ulBler=${EMPTY}
...    NRCELL-4:wbSbSrsSwitch=${EMPTY}
...    NRCELL-4:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-4:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-4:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-4:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-4:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-4:ifhoSsbSmtcOffset=${EMPTY}
...    NRCELL-4:mMimoAntArrayMode=${EMPTY}
...    NRCELL-4:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-4:measGapSelection=${EMPTY}
...    NRCELL-4:n310VoNR=${EMPTY}
...    NRCELL-4:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-4:sMeasConfigSsbRsrp=${EMPTY}
...    NRCELL-4:srPeriodicityMin=${EMPTY}
...    NRCELL-4:t310VoNR=${EMPTY}
...    NRCELL-4:vonrReservation=${EMPTY}
...    NRCELLGRP-3:scs=30 KHz
...    NRCELLGRP-3:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-3:nrCellList=4


@{PAPAMS_ADD_CELL11}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11:actAsiDistMimoNr=false
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4:resourceDN=${EMPTY}

...    NRCELL-11:a2MeasRedirectEnabled=none
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:absThreshSsbRsrqConsolidation=10
...    NRCELL-11:actAdaptiveSr=false
...    NRCELL-11:actDl256Qam=true
...    NRCELL-11:actEnhancedVoNR=false
...    NRCELL-11:actGBRAdmissionControl=off
...    NRCELL-11:actVoNR=false
...    NRCELL-11:cellDepType=SA
...    NRCELL-11:cellTechnology=FDD
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:dlMuLowSinrThreshold=-60
...    NRCELL-11:dlMuMaxNumPairedUEs=8
...    NRCELL-11:dlMuNeighborThreshold=80
...    NRCELL-11:dlMuPairingThreshold=5
...    NRCELL-11:dlQam256PowerBackoffAbove6=40
...    NRCELL-11:dlQam256PowerBackoffSub6=30
...    NRCELL-11:dllaIniMcs=13
...    NRCELL-11:drxWactDlEnabled=false
...    NRCELL-11:drxWactUlEnabled=false
...    NRCELL-11:duratScgFailures=0ms
...    NRCELL-11:emergencyFBMode=redirection
...    NRCELL-11:enDcSyncStatus=synchronous
...    NRCELL-11:expectedCellSize=5km
...    NRCELL-11:freqBandIndicatorNR=66
...    NRCELL-11:gscnOrSsPbchArfcn=5300
...    NRCELL-11:ifhoSsbSmtcOffset=0
...    NRCELL-11:initialPreambleReceivedTargetPower=-150
...    NRCELL-11:lcrId=11
...    NRCELL-11:lteToNrTimeOffset=30
...    NRCELL-11:maxNumPuschAllocationPerSlot=4
...    NRCELL-11:mcsIndexForArtificialLoad=0
...    NRCELL-11:measGapSelectionSA=balancedChoice
...    NRCELL-11:mgta=ms0
...    NRCELL-11:msg1FrequencyStart=13
...    NRCELL-11:nrOfScgFailures=0
...    NRCELL-11:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-11
...    NRCELL-11:nrarfcn=633372
...    NRCELL-11:nrofHARQProcessesForPDSCH=16
...    NRCELL-11:pMax=190
...    NRCELL-11:pMaxNROwnCell=23
...    NRCELL-11:pagingOffset=1
...    NRCELL-11:pagingTargetRate=MCS9_SF0
...    NRCELL-11:physCellId=60
...    NRCELL-11:prachConfigurationIndex=13
...    NRCELL-11:preambleTransMax=n200
...    NRCELL-11:pucchDataDtxNumOfSamples=30
...    NRCELL-11:puschDataDtxNumOfSamples=30
...    NRCELL-11:raResponseWindow=sl20
...    NRCELL-11:ranAC=0
...    NRCELL-11:reqMinNumPuschPrb=96
...    NRCELL-11:rloConsecDtxThreshold=2
...    NRCELL-11:rloDtxRatioThreshold=50
...    NRCELL-11:rloPathLossThreshold=130
...    NRCELL-11:rloSinrThreshold=-45
...    NRCELL-11:rlpDetDlHarqThreshold=500
...    NRCELL-11:rsrpThresholdSSB=37
...    NRCELL-11:sCellBadChannelQualityThreshold=14
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellGoodChannelQualityThreshold=18
...    NRCELL-11:siChangeIndDuration=2
...    NRCELL-11:ssPbchBlockPower=15
...    NRCELL-11:ssbScs=15KHz
...    NRCELL-11:t300=600ms
...    NRCELL-11:targetTotalLoad=0
...    NRCELL-11:timingAdvanceOffset=n0
...    NRCELL-11:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-11:type0CoresetConfigurationIndex=7
...    NRCELL-11:type0SearchSpaceConfigurationIndex=5
...    NRCELL-11:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-11:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-11:ulSchedTimeInterval=2000
...    NRCELL-11:ullaDeltaSinrMin=-150
...    NRCELL-11:voiceFBMode=redirection
...    NRCELL-11:weightForSCellSelection=45
...    NRCELL-11:actCsiResAllocOptList=disabled
...    NRCELL-11:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-11:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-11:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33
...    NRCELL-11:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-11:csirsForTracking:firstRE=0
...    NRCELL-11:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-11:dlPtrs:dlPtrsFreqDensityThresNrb0=3
...    NRCELL-11:dlPtrs:dlPtrsFreqDensityThresNrb1=3
...    NRCELL-11:drxProfile1:drxInactivityTimer=80ms
...    NRCELL-11:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-11:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-11:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-11:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-11:fPdcchMonOccsnPo=0
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-11:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-11:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-11:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-11:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-11:ulPowerControlCommon:p0NominalSrs=-96
...    NRCELL-11:ulPtrs:ulPtrsFreqDensityThresNrb0=3
...    NRCELL-11:ulPtrs:ulPtrsFreqDensityThresNrb1=3
...    NRCELL-11:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-11:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrp=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrq=${EMPTY}
...    NRCELL-11:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeasRedirectSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasRedirectSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeasReleaseSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasReleaseSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrp=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrq=${EMPTY}
...    NRCELL-11:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-11:a3MeasSsbRsrp=${EMPTY}
...    NRCELL-11:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-11:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-11:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-11:a5MeasSsbRsrp=${EMPTY}
...    NRCELL-11:a5MeasSsbRsrq=${EMPTY}
...    NRCELL-11:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-11:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-11:beamSet=${EMPTY}
...    NRCELL-11:cellCsiImLocationList=${EMPTY}
...    NRCELL-11:cellCsiRsLocationList=${EMPTY}
...    NRCELL-11:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-11:drxProfile2=${EMPTY}
...    NRCELL-11:drxProfileNrAnr=${EMPTY}
...    NRCELL-11:eirpControl=${EMPTY}
...    NRCELL-11:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-11:emergencyAreaIdList=${EMPTY}
...    NRCELL-11:emergencyCallRestrictions=${EMPTY}
...    NRCELL-11:fiveQiDrbDrxList=${EMPTY}
...    NRCELL-11:lcsToGcsTranslate=${EMPTY}
...    NRCELL-11:nGRanAccessPointPosition=${EMPTY}
...    NRCELL-11:infTddFrameStructure=${EMPTY}
...    NRCELL-11:ulBler=${EMPTY}
...    NRCELL-11:nrhoirDNList=${EMPTY}
...    NRCELL-11:pciExcludeList=${EMPTY}
...    NRCELL-11:pdcchAutoConfig=${EMPTY}
...    NRCELL-11:pdschHrLaConfig=${EMPTY}
...    NRCELL-11:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-11:puschHrLaConfig=${EMPTY}
...    NRCELL-11:srsForBeamMgmt=${EMPTY}
...    NRCELL-11:srsForSubbandBm=${EMPTY}
...    NRCELL-11:tddFrameStructure=${EMPTY}
...    NRCELL-11:uacAcCatList=${EMPTY}
...    NRCELL-11:uacAcContParSetList=${EMPTY}
...    NRCELL-11:wbSbSrsSwitch=${EMPTY}
...    NRCELL-11:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-11:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-11:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-11:chBw=${EMPTY}
...    NRCELL-11:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-11:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-11:mMimoAntArrayMode=${EMPTY}
...    NRCELL-11:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-11:n310VoNR=${EMPTY}
...    NRCELL-11:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-11:slotLAUseHighBlerAckNack=${EMPTY}
...    NRCELL-11:slotLAUseLowBlerAckNack=${EMPTY}
...    NRCELL-11:srPeriodicityMin=${EMPTY}
...    NRCELL-11:t310VoNR=${EMPTY}
...    NRCELL-11:vonrReservation=${EMPTY}
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELLGRP-4:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-4:nrCellList=11


@{PAPAMS_ADD_CELL12}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12:actAsiDistMimoNr=false
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-1:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-1:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-4:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-6/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-4:resourceDN=${EMPTY}
...    NRCELL-12:a2MeasRedirectEnabled=none
...    NRCELL-12:absThreshSsbRsrpConsolidation=0
...    NRCELL-12:absThreshSsbRsrqConsolidation=10
...    NRCELL-12:actAdaptiveSr=false
...    NRCELL-12:actDl256Qam=true
...    NRCELL-12:actEnhancedVoNR=false
...    NRCELL-12:actGBRAdmissionControl=off
...    NRCELL-12:actVoNR=false
...    NRCELL-12:cellDepType=NSA
...    NRCELL-12:cellTechnology=FDD
...    NRCELL-12:configuredEpsTac=777
...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:dlMuLowSinrThreshold=-60
...    NRCELL-12:dlMuMaxNumPairedUEs=8
...    NRCELL-12:dlMuNeighborThreshold=80
...    NRCELL-12:dlMuPairingThreshold=5
...    NRCELL-12:dlQam256PowerBackoffAbove6=40
...    NRCELL-12:dlQam256PowerBackoffSub6=30
...    NRCELL-12:dllaIniMcs=13
...    NRCELL-12:drxWactDlEnabled=false
...    NRCELL-12:drxWactUlEnabled=false
...    NRCELL-12:duratScgFailures=0ms
...    NRCELL-12:emergencyFBMode=redirection
...    NRCELL-12:enDcSyncStatus=synchronous
...    NRCELL-12:expectedCellSize=5km
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1584
...    NRCELL-12:ifhoSsbSmtcOffset=0
...    NRCELL-12:initialPreambleReceivedTargetPower=-150
...    NRCELL-12:lcrId=12
...    NRCELL-12:lteToNrTimeOffset=30
...    NRCELL-12:maxNumPuschAllocationPerSlot=4
...    NRCELL-12:mcsIndexForArtificialLoad=0
...    NRCELL-12:measGapSelectionSA=balancedChoice
...    NRCELL-12:mgta=ms0
...    NRCELL-12:msg1FrequencyStart=13
...    NRCELL-12:nrOfScgFailures=0
...    NRCELL-12:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-12
...    NRCELL-12:nrarfcn=633372
...    NRCELL-12:nrofHARQProcessesForPDSCH=16
...    NRCELL-12:pMax=190
...    NRCELL-12:pMaxNROwnCell=23
...    NRCELL-12:pagingOffset=1
...    NRCELL-12:pagingTargetRate=MCS9_SF0
...    NRCELL-12:physCellId=61
...    NRCELL-12:prachConfigurationIndex=14
...    NRCELL-12:preambleTransMax=n200
...    NRCELL-12:pucchDataDtxNumOfSamples=30
...    NRCELL-12:puschDataDtxNumOfSamples=30
...    NRCELL-12:raResponseWindow=sl20
...    NRCELL-12:reqMinNumPuschPrb=96
...    NRCELL-12:rloConsecDtxThreshold=2
...    NRCELL-12:rloDtxRatioThreshold=50
...    NRCELL-12:rloPathLossThreshold=130
...    NRCELL-12:rloSinrThreshold=-45
...    NRCELL-12:rlpDetDlHarqThreshold=500
...    NRCELL-12:rsrpThresholdSSB=37
...    NRCELL-12:sCellBadChannelQualityThreshold=14
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellGoodChannelQualityThreshold=18
...    NRCELL-12:siChangeIndDuration=2
...    NRCELL-12:ssPbchBlockPower=15
...    NRCELL-12:ssbScs=15KHz
...    NRCELL-12:t300=600ms
...    NRCELL-12:targetTotalLoad=0
...    NRCELL-12:timingAdvanceOffset=n0
...    NRCELL-12:type0CoresetConfigurationIndex=7
...    NRCELL-12:type0SearchSpaceConfigurationIndex=5
...    NRCELL-12:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-12:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-12:ulSchedTimeInterval=2000
...    NRCELL-12:ullaDeltaSinrMin=-150
...    NRCELL-12:voiceFBMode=redirection
...    NRCELL-12:weightForSCellSelection=40
...    NRCELL-12:actCsiResAllocOptList=disabled
...    NRCELL-12:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-12:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-12:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-34
...    NRCELL-12:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-12:csirsForTracking:firstRE=0
...    NRCELL-12:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-12:dlPtrs:dlPtrsFreqDensityThresNrb0=3
...    NRCELL-12:dlPtrs:dlPtrsFreqDensityThresNrb1=3
...    NRCELL-12:drxProfile1:drxInactivityTimer=80ms
...    NRCELL-12:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-12:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-12:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-12:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-12:fPdcchMonOccsnPo=0
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-12:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-12:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-12:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-12:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-12:ulPowerControlCommon:p0NominalSrs=-96
...    NRCELL-12:ulPtrs:ulPtrsFreqDensityThresNrb0=3
...    NRCELL-12:ulPtrs:ulPtrsFreqDensityThresNrb1=3
...    NRCELL-12:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-12:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=35
...    NRCELL-12:a1MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-12:a1MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-12:a1MeasSCellAddSsbRsrp=${EMPTY}
...    NRCELL-12:a1MeasSCellAddSsbRsrq=${EMPTY}
...    NRCELL-12:a1MeashoPrefNRLayerSsbRsrp=${EMPTY}
...    NRCELL-12:a1MeashoPrefNRLayerSsbRsrpSA=${EMPTY}
...    NRCELL-12:a1MeashoPrefNRLayerSsbRsrq=${EMPTY}
...    NRCELL-12:a1MeashoPrefNRLayerSsbRsrqSA=${EMPTY}
...    NRCELL-12:a1MeashoSsbRsrp=${EMPTY}
...    NRCELL-12:a1MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-12:a1MeashoSsbRsrq=${EMPTY}
...    NRCELL-12:a1MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-12:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-12:a2MeasPCellSwitchSsbRsrq=${EMPTY}
...    NRCELL-12:a2MeasRedirectSsbRsrp=${EMPTY}
...    NRCELL-12:a2MeasRedirectSsbRsrq=${EMPTY}
...    NRCELL-12:a2MeasReleaseSsbRsrp=${EMPTY}
...    NRCELL-12:a2MeasReleaseSsbRsrq=${EMPTY}
...    NRCELL-12:a2MeasSCellRelSsbRsrp=${EMPTY}
...    NRCELL-12:a2MeasSCellRelSsbRsrq=${EMPTY}
...    NRCELL-12:a2MeashoSsbRsrp=${EMPTY}
...    NRCELL-12:a2MeashoSsbRsrpSA=${EMPTY}
...    NRCELL-12:a2MeashoSsbRsrq=${EMPTY}
...    NRCELL-12:a2MeashoSsbRsrqSA=${EMPTY}
...    NRCELL-12:a3MeasSsbRsrp=${EMPTY}
...    NRCELL-12:a3MeasSsbRsrq=${EMPTY}
...    NRCELL-12:a4PeriodicMeasControlNSA=${EMPTY}
...    NRCELL-12:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-12:a5MeasSsbRsrp=${EMPTY}
...    NRCELL-12:a5MeasSsbRsrq=${EMPTY}
...    NRCELL-12:a6MeasSCellSwapSsbRsrp=${EMPTY}
...    NRCELL-12:a6MeasSCellSwapSsbRsrq=${EMPTY}
...    NRCELL-12:beamSet=${EMPTY}
...    NRCELL-12:cellCsiImLocationList=${EMPTY}
...    NRCELL-12:cellCsiRsLocationList=${EMPTY}
...    NRCELL-12:dlInterferenceAvoidance=${EMPTY}
...    NRCELL-12:drxProfile2=${EMPTY}
...    NRCELL-12:drxProfileNrAnr=${EMPTY}
...    NRCELL-12:eirpControl=${EMPTY}
...    NRCELL-12:eirpControlPowerReductionFactorList=${EMPTY}
...    NRCELL-12:emergencyAreaIdList=${EMPTY}
...    NRCELL-12:emergencyCallRestrictions=${EMPTY}
...    NRCELL-12:fiveQiDrbDrxList=${EMPTY}
...    NRCELL-12:infTddFrameStructure=${EMPTY}
...    NRCELL-12:lcsToGcsTranslate=${EMPTY}
...    NRCELL-12:nGRanAccessPointPosition=${EMPTY}
...    NRCELL-12:nrhoirDNList=${EMPTY}
...    NRCELL-12:pciExcludeList=${EMPTY}
...    NRCELL-12:pdcchAutoConfig=${EMPTY}
...    NRCELL-12:pdschHrLaConfig=${EMPTY}
...    NRCELL-12:plmnIndvSelAssisInfoList=${EMPTY}
...    NRCELL-12:puschHrLaConfig=${EMPTY}
...    NRCELL-12:srsForBeamMgmt=${EMPTY}
...    NRCELL-12:srsForSubbandBm=${EMPTY}
...    NRCELL-12:tddFrameStructure=${EMPTY}
...    NRCELL-12:uacAcCatList=${EMPTY}
...    NRCELL-12:uacAcContParSetList=${EMPTY}
...    NRCELL-12:ulBler=${EMPTY}
...    NRCELL-12:wbSbSrsSwitch=${EMPTY}
...    NRCELL-12:adaptiveSrBlockingMinimization=${EMPTY}
...    NRCELL-12:adaptiveSrLoadThresholdDown=${EMPTY}
...    NRCELL-12:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-12:chBw=${EMPTY}
...    NRCELL-12:idleMMEnDcSteeringPercentageOfUes=${EMPTY}
...    NRCELL-12:idleMMSteeringWRREnabled=${EMPTY}
...    NRCELL-12:mMimoAntArrayMode=${EMPTY}
...    NRCELL-12:maxGBRTrafficLimit=${EMPTY}
...    NRCELL-12:n310VoNR=${EMPTY}
...    NRCELL-12:preferredVoNrSrPeriod=${EMPTY}
...    NRCELL-12:slotLAUseHighBlerAckNack=${EMPTY}
...    NRCELL-12:slotLAUseLowBlerAckNack=${EMPTY}
...    NRCELL-12:srPeriodicityMin=${EMPTY}
...    NRCELL-12:t310VoNR=${EMPTY}
...    NRCELL-12:vonrReservation=${EMPTY}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELLGRP-5:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-5:nrCellList=12

@{PAPAMS_Recover_Cells_11}
...    @{PAPAMS_ADD_CELL11}
...    NRBTS/NRDU-1:refNrCellGroup=1,4

@{PAPAMS_Recover_Cells_3}
...    @{PAPAMS_ADD_CELL3}
...    NRBTS/NRDU-1:refNrCellGroup=1,2,4

@{PAPAMS_Recover_Cells_1}
...    @{PAPAMS_ADD_CELL1}
...    NRBTS/NRDU-1:refNrCellGroup=0,1,2,4

@{PAPAMS_Recover_Cells_4_12}
...    @{PAPAMS_ADD_CELL4}
...    @{PAPAMS_ADD_CELL12}
...    NRBTS/NRDU-1:refNrCellGroup=0,1,2,3,4,5

*** Test Cases ***
5GC000900_ET003_Verify_Classical_Both_TDD_cmWave_detail_SA_and_both_cell
    [Documentation]
    ...    1.Purpose
    ...      This case is to verify the cell setup when cell is configured for both (SA and NSA) access.
    ...    2. Test Case Steps:
    ...    Step 1. delete Cell1 SA+NSA, Cell3 NSA, Cell4 SA+NSA, Cell11 SA and Cell12 NSA, UEs attach Cell2 SA
    ...         2. add cell11,UEs attach Cell11 and check UEs stauts on the Cell2
    ...         2. add cell3, UEs attach Cell3 and check UEs stauts on the Cell2_Cell11
    ...         3. add cell1, UEs attach Cell3 and check UEs stauts on the Cell2_Cell11_Cell1
    ...         4. add cell4 and cell12, UEs attach Cell4_Cell12 and check UEs stauts on the Cell3_Cell2_Cell11_Cell1
    [Tags]    QC_86992
    Delte 5 cells
    Recover Cell_11 and Check UEs attach to cell11_cell2
    Recover Cell_3 and Check UEs attach to cell11_cell2_cell3
    Recover Cell_1 and Check UEs attach to cell11_cell2_cell3_cell1
    Recover Cell_4_12 and Check UEs attachto cell11_cell2_cell3_cell1_cell4_cell12
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

SA UE attach successful
    [Arguments]    ${id}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Register
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=${pdu} nwslice=${nwslice} gw=${id}    ${cmd_pdu_regexp}

SA UE already active
    [Arguments]    ${id}    ${cmd_regexp}=already active
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}

SA UE attach to NSA cell failed
    [Arguments]    ${id}    ${cmd_regexp}=MIB or SIB1 not recieved
    execute_egate_command    ue_register id=${id}    ${cmd_regexp}

NSA UE attach fail again
    [Arguments]    ${id}    ${cell_id}    ${cmd_regexp}=Dual connectivity trigger failure!
    execute_egate_command     ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg

NSA UE already attach successful
    [Arguments]    ${id}    ${cell_id}    ${cmd_regexp}=already an EN-DC bearer
    execute_egate_command     ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg

NSA UE attach successful
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

NSA UE attach to SA cell failed
    [Arguments]    ${id}    ${cell_id}    ${cmd_regexp}=Dual connectivity trigger failure!
    execute_egate_command    ue_attach id=${id}    UE IS ACTIVE    timeout=20s
    execute_egate_command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    ${cmd_regexp}

Modify Cfg
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-4 amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-4 amf=1
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=32 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=33 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=34 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=35 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=36 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}

Delte 5 cells
    delta commission parameters    ${PARAMS_DELETE_CELL1}
    delta commission parameters    ${PARAMS_DELETE_CELL3}
    delta commission parameters    ${PARAMS_DELETE_CELL4}
    delta commission parameters    ${PARAMS_DELETE_CELL11}
    delta commission parameters    ${PARAMS_DELETE_CELL12}
    wait until keyword succeeds    3 min    10 sec    cells should be on air    cell_id=2    check_sib=True
    NSA UE attach to SA cell failed    32    2
    SA UE attach successful    82    2    1

Recover Cell_11 and Check UEs attach to cell11_cell2
    delta commission parameters    ${PAPAMS_Recover_Cells_11}
    wait until keyword succeeds    3 min    10 sec    cells should be on air    cell_id=11    check_sib=True
    NSA UE attach to SA cell failed    35    11
    SA UE attach successful    85    5    1
    NSA UE attach fail again    32    2
    SA UE already active    82

Recover Cell_3 and Check UEs attach to cell11_cell2_cell3
    delta commission parameters    ${PAPAMS_Recover_Cells_3}
    wait until keyword succeeds    3 min    10 sec    cells should be on air    cell_id=3    check_sib=False
    NSA UE already attach successful    35    11
    SA UE already active     85
    NSA UE attach fail again    32    2
    SA UE already active     82
    NSA UE attach successful    33    3
    SA UE attach to NSA cell failed    83

Recover Cell_1 and Check UEs attach to cell11_cell2_cell3_cell1
    delta commission parameters    ${PAPAMS_Recover_Cells_1}
    wait until keyword succeeds    3 min    10 sec    cells should be on air    cell_id=1    check_sib=True
    NSA UE already attach successful    35    11
    SA UE already active     85
    NSA UE attach fail again    32    2
    SA UE already active     82
    NSA UE already attach successful    33    3
    SA UE attach to NSA cell failed    83
    NSA UE attach successful    31    1
    SA UE attach successful    81    1    1

Recover Cell_4_12 and Check UEs attachto cell11_cell2_cell3_cell1_cell4_cell12
    delta commission parameters    ${PAPAMS_Recover_Cells_4_12}
    wait until keyword succeeds    3 min    10 sec    cells should be on air    cell_id=4    check_sib=True
    wait until keyword succeeds    3 min    10 sec    cells should be on air    cell_id=12    check_sib=False
    NSA UE already attach successful    35    11
    SA UE already active     85
    NSA UE attach fail again    32    2
    SA UE already active     82
    NSA UE already attach successful    33    3
    SA UE attach to NSA cell failed    83
    NSA UE already attach successful    35    11
    SA UE already active    81
    NSA UE attach successful    34    4
    SA UE attach successful    84    4    1
    NSA UE attach fail again    31    1
    SA UE already active    81




