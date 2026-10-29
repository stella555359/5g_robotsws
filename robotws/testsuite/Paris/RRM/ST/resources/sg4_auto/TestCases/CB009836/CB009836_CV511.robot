*** Settings ***
Documentation
...     The purpose of this suite is to Provide a series of Tools for SyVe SG04

...     AUTHOR (I&V-4):
...         Stephane Croquet

suite setup  Actions Suite Setup
suite teardown   Actions Suite Teardown
test setup       Actions Test Setup
test teardown    Actions Test Teardown


Library     DateTime
Library     Process
Library	    OperatingSystem
Library	    taf.ue                                  WITH NAME    ue
Library	    taf.sbts.oam.coam.admin    		        WITH NAME    coam
Library	    taf.transport.ssh          		        WITH NAME    ssh
Library	    taf.collectors.btslog      		        WITH NAME    btslog
Library     taf.config.scf                          WITH NAME    scf
Library     XML    True

Library     myTtiParserScro.py
Library     myScriptPythonScro.py

Resource    ../../Resources/keywords_common.robot
Resource    CB009836MyKeywords.robot

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/common/gnb_log.robot


*** Variables ***
${timerTeardown}  30
${logPath}        /home/localuser/LogAuto
@{nrCellId}       1  2  3
@{nrCellGrplId}   0   1   2

${nbCellCsiRsGrp}   3
${mrbts}      MRBTS-511
${nrbts}      NRBTS-23363
@{counterstocheck}   M55308C00001   M55308C10001   M55308C10003   M55308C10005
@{countersDesc}      M55308C00001: Sum of DL Data slots
    ...              M55308C10001: Number of PRBs used for PDSCH
    ...              M55308C10003: Number of PRBs available for PDSCH
    ...              M55308C10005: Number of PRBs available for PDSCH with L1 PRB Pooling
${targetVersion}     SBTS00_ENB_9999_240605_000009
${myDataSet}         /mnt/MNRAN_PZNPS/TL/CV511/myDataSet.csv

${alias_0}            UE_1
${capabilities_0}     REAL_UE_1
${alias_1}            UE_2
${capabilities_1}     REAL_UE_2
${alias_2}            UE_3
${capabilities_2}     REAL_UE_3
@{ueList}             0  1  2
&{dlTput}             0=600   1=600   2=600
&{expectedDlTput}     0=400   1=400    2=400

#&{ueMapping}          101=2   103=1    105=0
&{ueMapping}          512=2   513=1    511=0
#Exemple of output : rntiPci: {'51985': '513', '47833': '512', '38426': '511'}


${duration}           120s
${protocol}           udp
${Packet_Size}        1000
${qci_dl}             9

#Input pour test 34 35
${errorOk}            5
${pciId}              101
${nbLoop}             10

&{5GC001116_0_fs}  frameStructureType=tdLte
    ...     guardPeriodLength=4Symbols
    ...     lteToNrFrameShift=0ms
    ...     tdLteUlDlConfig=tdLteConfig2
    ...     ulDlDataSlotRatio=1/4

&{5GC001116_3_fs}   frameStructureType=tdLte
    ...     guardPeriodLength=4Symbols
    ...     lteToNrFrameShift=3ms
    ...     tdLteUlDlConfig=tdLteConfig2
    ...     ulDlDataSlotRatio=1/4

&{5GC001208_fs}     frameStructureType=semiStatic
    ...     guardPeriodLength=2Symbols
    ...     ulDlDataSlotRatio=1/4

&{5GC001070_fs}      frameStructureType=semiStatic
    ...     guardPeriodLength=2Symbols
    ...     ulDlDataSlotRatio=3/7

&{cSrs}   30MHz=20
    ...   40MHz=25
    ...   50MHz=33
    ...   60MHz=42
    ...   70MHz=45
    ...   80MHz=51
    ...   90MHz=56
    ...   100MHz=60


${syslog}              SYSLOG_CV511.LOG
${syslog_folder}       /tmp/btslog2

#POSTCONDITIONS
##MANDATORY FLAGS
${actDlMuMimoEnh}       true    #changed from true to false for CV511
${actUlMuMimo}          true    #changed from true to false for CV511
${actSuperCell}         false
${actVoNR}              true
${actEnhancedVoNR}      true

${actBbPoolTddFr1}                  true   #CB008940
${actBbPoolExtensionTddFr1}         true   #CB010513
${actBbPoolTddFr1Enh}               false  #CB011028
${actBbPoolTddFr1AlgEnh}            true   #LBT - New Pooling Algo
${actExplicitCsirsPoolSolution}     true   #LBT - CSI-RS Config  ******
${actTddCsirsAllocOptimization}     true  #CB009836   DOIT ETRE MIS A TRUE + DECOMMENTER
${actTddCsirsOpt}                   false  #CB012269
${actSlowPrbPooling}                false
${actSpatialStreamPooling}          false
${actDlSrsBm}                       true
${actBeamforming}                   true
${actCsirsMultiplexing}             true                    #
${actCellCsirsTddOnSsbBf}           false
${actCellCsiRsImTddNonBf}           false
${actAdaptiveReTxResMcs}            true
${actFdmEnhancedScheduling}         true
${actInfTddFrameMuting}             false
${frameStructure}                   5GC001116_3
@{bwp0}                             ${mrbts}/${nrbts}/BWP_PROFILE-8         ${mrbts}/${nrbts}/BWP_PROFILE-8     ${mrbts}/${nrbts}/BWP_PROFILE-8
@{bwp1}                             ${mrbts}/${nrbts}/BWP_PROFILE-87        ${mrbts}/${nrbts}/BWP_PROFILE-87    ${mrbts}/${nrbts}/BWP_PROFILE-87
@{prach}                            98      98      98
@{beamSet}                          beamSet_8       beamSet_8       beamSet_8
@{beams}                            8 beams     8 beams     8 beams
@{chBw}                             100MHz          100MHz          100MHz
@{csiReportPeriodicity}             slots320        slots320        slots320
@{nrCellType}                       8DL8UL      8DL8UL      8DL8UL
@{dlMimoMode}                       8x4 Closed Loop Spatial Multiplexing      8x4 Closed Loop Spatial Multiplexing
...      8x4 Closed Loop Spatial Multiplexing  #70:8x4 Closed Loop Spatial Multiplexing  40:4x4 or 4x2 Closed Loop Spatial Multiplexing
@{msg1FrequencyStart}               36      36      36
@{csirsNbWithinReportPeriod_Set1}   1   1   1
${rbAllocation}                     BWP   #BWP
${csirsTrackingPeriod}              80ms
@{maxCsirsNumber}                   4    4    4
${actUeCsirsCoexistCellCsirs}       true
${actCsirsBeamPowerBalance}         true
${actBlankDlSymbBorderCoord}        false
#@{actNonVoNRGbrService}             true   true    true
@{actNonVoNRGbrService}             false   false    false
@{actGBRAdmissionControl}           EnhancedVoNR   EnhancedVoNR        EnhancedVoNR  #   GBRService
@{pagingOffset}                     1   1   1
@{fPdcchMonOccsnPo}                 2   2   2
&{reqMinNumPuschPrb}   30MHz=68
    ...   40MHz=90
    ...   50MHz=133
    ...   60MHz=142
    ...   70MHz=169
    ...   80MHz=197
    ...   90MHz=225
    ...   100MHz=231
${SnapshotOnTeardown}        ${False}
${actPerCsiReportBundlingTddFr1}        true
${CheckPRB}           ${True}   # include PRB check in test
${ngbr}        ${True}        # launch traffic ngbr
${gbr}         ${False}        # launch traffic gbr
${gbr_port}        6003
${ul}        ${False}        # launch traffic ul
${dl}        ${True}
${restoreSCF}        ${False}
${cb012605}        ${False}
${cellsToLock}     []

*** Test Cases ***
00_Upgrade
    [Tags]  00  upgrade  CB009836
    myKw Upgrade gNB


01_CB009836_A01_01_5GC001116_0_6ssb_40sl
    [tags]  CB009836    cv_101  regression  A01_01
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-76
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots160   slots320
    set test variable   @{chBw}      100MHz  100MHz  90MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   @{actGBRAdmissionControl}           EnhancedVoNR   EnhancedVoNR   EnhancedVoNR
    set test variable   ${actTddCsirsAllocOptimization}     true

    myKw Main test 3

01_CB009836_A01_01_5GC001116_0_6ssb_40sl_CNI-127661
    [tags]  CB009836    cv_101  regression  A01_01
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-76
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots160   slots320
    set test variable   @{chBw}      100MHz  100MHz  90MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   @{actGBRAdmissionControl}           EnhancedVoNR   EnhancedVoNR   EnhancedVoNR
    set test variable   ${actTddCsirsAllocOptimization}     true
    Set Test Variable    ${duration}    300s
    set test variable         ${skipFileCreation}     ${True}
    Set Test Variable    ${collectSnap}        ${True}
    myKw Main test 3bis

24_CB009836_A01_24_5GC001106_0_CSIRS_TRS_Cellspecific_allocation_Pooling
    [tags]  CB009836    cv_101  regression  A01_24
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   &{expectedDlTput}  0=400   1=400    2=400
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-76
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  100MHz  90MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   ${rbAllocation}    52RB
    set test variable   @{prach}      96  96  96
    set test variable   ${gbr}       ${True}
    set test variable   ${actBlankDlSymbBorderCoord}        false
    myKw Main test 3

40_CB009836-SR-B_03_USR2_IWK_5GC002516_FS_1208_1116_3ms_CNI-74648_enabled_RS4_80slots_bs4_NBTRS
    [tags]  CB009836    cv_101  regression  B_03
    set test variable   ${frameStructure}   5GC001208
    set test variable  ${actInfTddFrameMuting}   true
    set test variable   ${infTddframeStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-9  ${mrbts}/${nrbts}/BWP_PROFILE-9  ${mrbts}/${nrbts}/BWP_PROFILE-9
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-97  ${mrbts}/${nrbts}/BWP_PROFILE-97  ${mrbts}/${nrbts}/BWP_PROFILE-96
    #FS 1208 : BWP 5/57 has been changed to BWP 9/97 because the content is different when actInfTddFrameMuting equal true
    set test variable   @{beamSet}   beamSet_4  beamSet_4  beamSet_4
    set test variable   @{beams}     4 beams  4 beams  4 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{bwpChBwPowerSaving}      100MHz    100MHz   90MHz
    set test variable   @{prach}      98  98  98
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   @{maxCsirsNumber}                   1   2   4
    set test variable   ${rbAllocation}    52RB
    set test variable   ${actBlankDlSymbBorderCoord}        true
    myKw Main test 3

UEs_Only
    MyKw Launch UE part

