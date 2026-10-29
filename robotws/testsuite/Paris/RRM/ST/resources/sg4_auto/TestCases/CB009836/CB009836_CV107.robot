*** Settings ***
Documentation
...     The purpose of this suite is to Provide a series of Tools for SyVe SG04

...     AUTHOR (I&V-4):
...         Stephane Croquet

suite setup      Actions Suite Setup
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
Resource    taf/rfrl/bts/robot/common/gnb_log.robot
Resource    ../../Resources/keywords_common.robot
Resource    CB009836MyKeywords.robot

*** Variables ***
${timerTeardown}        30
${SnapshotOnTeardown}        ${False}
${logPath}   /home/localuser/LogAuto
@{nrCellId}       0   1   2
@{nrCellGrplId}   0   1   2
${nbCellCsiRsGrp}   3
${mrbts}      MRBTS-107
${nrbts}      NRBTS-23169
@{counterstocheck}   M55308C00001   M55308C10001   M55308C10003   M55308C10005

${myDataSet}         /mnt/MNRAN_PZNPS/TL/CV107/myDataSet.csv

${alias_0}            UE_1
${capabilities_0}     REAL_UE_1
${alias_1}            UE_2
${capabilities_1}     REAL_UE_2
${alias_2}            UE_3
${capabilities_2}     REAL_UE_3
@{ueList}             0  1  2
&{dlTput}             0=900   1=900   2=900
&{expectedDlTput}     0=100   1=100    2=100
&{ueMapping}          107=0   108=1    109=2
${duration}           180s

${protocol}           udp
${Packet_Size}        1000
${qci_dl}             9

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

&{5GC001116_0_inf_fs}  infFrameStructureType=tdLte
    ...     infGuardPeriodLength=4Symbols
    ...     infLteToNrFrameShift=0ms
    ...     infScs=30 KHz
    ...     infTddFrameMutingBiAgreement=true
    ...     infTdLteUlDlConfig=tdLteConfig2
    ...     infUlDlDataSlotRatio=1/4

&{5GC001116_3_inf_fs}  infFrameStructureType=tdLte
    ...     infGuardPeriodLength=4Symbols
    ...     infLteToNrFrameShift=3ms
    ...     infScs=30 KHz
    ...     infTddFrameMutingBiAgreement=true
    ...     infTdLteUlDlConfig=tdLteConfig2
    ...     infUlDlDataSlotRatio=1/4

&{5GC001208_inf_fs}  infFrameStructureType=semiStatic
    ...     infGuardPeriodLength=2Symbols
    ...     infScs=30 KHz
    ...     infTddFrameMutingBiAgreement=true
    ...     infUlDlDataSlotRatio=1/4


${syslog}              SYSLOG_1.LOG
${syslog_folder}       /tmp/btslog2

#POSTCONDITIONS
##MANDATORY FLAGS
${actDlMuMimoEnh}       true
${actUlMuMimo}          true
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
${actUeCsirsCoexistCellCsirs}       true
${actCsirsBeamPowerBalance}         true
${actPowerSavingBWP}                true   #CB00937
${frameStructure}                   5GC001116_3
@{bwp0}                             ${mrbts}/${nrbts}/BWP_PROFILE-8         ${mrbts}/${nrbts}/BWP_PROFILE-8     ${mrbts}/${nrbts}/BWP_PROFILE-8
@{bwp1}                             ${mrbts}/${nrbts}/BWP_PROFILE-87        ${mrbts}/${nrbts}/BWP_PROFILE-87    ${mrbts}/${nrbts}/BWP_PROFILE-87
@{prach}                            98      98      98
@{beamSet}                          beamSet_8       beamSet_8       beamSet_8
@{beams}                            8 beams     8 beams     8 beams
@{chBw}                             100MHz          100MHz          100MHz
@{bwpChBwPowerSaving}               40MHz           40MHz           40MHz
&{cSrs}   30MHz=20
    ...   40MHz=25
    ...   50MHz=33
    ...   60MHz=42
    ...   70MHz=45
    ...   80MHz=51
    ...   90MHz=56
    ...   100MHz=60
&{reqMinNumPuschPrb}   30MHz=68
    ...   40MHz=90
    ...   50MHz=133
    ...   60MHz=142
    ...   70MHz=169
    ...   80MHz=197
    ...   90MHz=225
    ...   100MHz=231
@{csiReportPeriodicity}             slots320        slots320        slots320
@{nrCellType}                       8DL8UL      8DL8UL      8DL8UL
@{dlMimoMode}                       8x4 Closed Loop Spatial Multiplexing      8x4 Closed Loop Spatial Multiplexing
...      8x4 Closed Loop Spatial Multiplexing  #70:8x4 Closed Loop Spatial Multiplexing  40:4x4 or 4x2 Closed Loop Spatial Multiplexing
@{msg1FrequencyStart}               42      42      42
@{csirsNbWithinReportPeriod_Set1}   1   1   1
${rbAllocation}                     BWP   #BWP
${csirsTrackingPeriod}              80ms
@{maxCsirsNumber}                   4    4    4
${actBlankDlSymbBorderCoord}        false
@{actNonVoNRGbrService}             false   false    false
@{actGBRAdmissionControl}           EnhancedVoNR    EnhancedVoNR   EnhancedVoNR
@{pagingOffset}                     1   1   1
@{fPdcchMonOccsnPo}                 2   2   2
${actPerCsiReportBundlingTddFr1}        true
${nbLoop}             10
${CheckPRB}           ${False}   # include PRB check in test
${ngbr}        ${True}        # launch traffic ngbr
${gbr}         ${False}        # launch traffic gbr
${restoreSCF}        ${False}         # restore initial scf in Suite teardown

*** Test Cases ***
01_CB009836_A01_01_5GC001116_0_6ssb_40sl
    [tags]  CB009836  CB009836_part1  01
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   ${actUeCsirsCoexistCellCsirs}            false
    set test variable   ${actCsirsBeamPowerBalance}         false
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots160   slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   @{pagingOffset}                     1   1   1
    set test variable   @{fPdcchMonOccsnPo}                 2   2   2
    myKw Main test 2

02_CB009836_A01_02_5GC001116_0_6ssb_80sl
    [tags]  CB009836  CB009836_part1  02   two
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   ${actUeCsirsCoexistCellCsirs}            false
    set test variable   ${actCsirsBeamPowerBalance}         false
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80    slots160   slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

03_CB009836_A01_03_5GC001116_0_6ssb_160sl
    [tags]  CB009836  CB009836_part1  03  two
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   2   1
    set test variable   ${actExplicitCsirsPoolSolution}   false
    myKw Main test 2

04_CB009836_A01_04_5GC001116_0_6ssb_320sl
    [tags]  CB009836  CB009836_part1  04
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

05_CB009836_A01_05_5GC001116_0_6ssb_80sl
    [tags]  CB009836  CB009836_part1  05
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    myKw Main test 2

06_CB009836_A01_06_5GC001116_3_6ssb_40sl
    [tags]  CB009836  CB009836_part1  06  one
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    #set test variable   @{chBw}      100MHz  90MHz  80MHz
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

07_CB009836_A01_07_5GC001116_3_6ssb_80sl
    [tags]  CB009836  CB009836_part1  07
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 2

08_CB009836_A01_08_5GC001116_3_6ssb_160sl
    [tags]  CB009836  CB009836_part1  08
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

09_CB009836_A01_09_5GC001116_3_6ssb_320sl
    [tags]  CB009836  CB009836_part1  09
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 2

10_CB009836_A01_10_5GC001116_3_6ssb_80sl
    [tags]  CB009836  CB009836_part1  10  2nd
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

11_CB009836_A01_11_5GC001208_6ssb_40sl
    [tags]  CB009836  CB009836_part1  11  one  cv107
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 2

12_CB009836_A01_12_5GC001208_6ssb_80sl
    [tags]  CB009836  CB009836_part1  12  cv107
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

13_CB009836_A01_13_5GC001208_6ssb_160sl
    [tags]  CB009836  CB009836_part1  13  cv107
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 2

14_CB009836_A01_14_5GC001208_6ssb_320sl
    [tags]  CB009836  CB009836_part1  14  cv107
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

15_CB009836_A01_15_5GC001208_6ssb_80sl
    [tags]  CB009836  CB009836_part1  15  cv107
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    myKw Main test 2

16_CB009836_A01_16_5GC001070_6ssb_40sl
    [tags]  CB009836  CB009836_part1  16  one
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-67
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    BWP
    # log to console  ${tl}
    # fail
    myKw Main test 2

17_CB009836_A01_17_5GC001070_6ssb_80sl
    [tags]  CB009836  CB009836_part1  17
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 2

18_CB009836_A01_18_5GC001070_6ssb_160sl
    [tags]  CB009836  CB009836_part1  18
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

19_CB009836_A01_19_5GC001070_6ssb_320sl
    [tags]  CB009836  CB009836_part1  19  2nd
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 2

20_CB009836_A01_20_5GC001070_6ssb_80sl
    [tags]  CB009836  CB009836_part1  20
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061  ${mrbts}/${nrbts}/BWP_PROFILE-10061
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2


21_CB009836_A01_21_5GC001208_4ssb_80sl
    [tags]  CB009836    21  one
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051
    set test variable   @{beamSet}   beamSet_4  beamSet_4  beamSet_4
    set test variable   @{beams}     4 beams  4 beams  4 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    myKw Main test 2

22_CB009836_A01_22_5GC001116_3_8ssb_160sl
    [tags]  CB009836    22  one
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   3   3   3
    set test variable   @{maxCsirsNumber}                   2   2   2
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

23_CB009836_A01_23_5GC001116_3_8ssb_320sl
    [tags]  CB009836    23  one
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-87
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081  ${mrbts}/${nrbts}/BWP_PROFILE-10081
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   4   4   4
    set test variable   @{maxCsirsNumber}                   1   1   1
    myKw Main test 2

26_CB009836_A01_26_5GC001208_CSIRS_TRS_Cellspecific_allocation_Pooling
    [tags]  CB009836    26  one  cv_107
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-57
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051  ${mrbts}/${nrbts}/BWP_PROFILE-10051
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   ${rbAllocation}    52RB
    myKw Main test 2

28_CB009836_A01_28_CB010513_Disabled
    [tags]  CB009836  28  one  2nd
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actBbPoolExtensionTddFr1}   false
    set test variable   ${actExplicitCsirsPoolSolution}   false
    myKw Main test 2

29_CB009836_A01_29_CB011028_Enabled
    [tags]  CB009836  29  one
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actBbPoolTddFr1Enh}   true
    myKw Main test 2

30_CB009836_A01_30_CB009836_Disabled-CB010513_CSIRS_Mode
    [tags]  CB009836  30  one
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actTddCsirsAllocOptimization}   false
    set test variable   ${actExplicitCsirsPoolSolution}   true
    myKw Main test 2

31_CB009836_A01_31_CB009836_Disabled-CB008940_CSIRS_Mode
    [tags]  CB009836  31  one
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actTddCsirsAllocOptimization}   false
    set test variable   ${actExplicitCsirsPoolSolution}   false
    myKw Main test 2

34_CB009836_A01_34_PeakTput_CsiRs160_320_CsiRsMode_8940_vs_9836
    [tags]  CB009836  34  one
    set test variable   @{ueList}   2
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1

    append to file  ${resultFile}  \n****** STEP1 ******\n
    set test variable   ${actTddCsirsAllocOptimization}   false  #a garder
    set test variable   ${actExplicitCsirsPoolSolution}   false  #a ajouter
    myKw Log config in result file
    myKw Activate config
    myKw Check TRS CSI-RS allocation
    myKw Check cell specific CSI-RS allocation

    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step1.log
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 1  ${ue}
    END
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 2  ${ue}
    END
    sleep   10s
    ${tPutStep1}  myTTI

    FOR   ${ue}   IN   @{ueList}
        Run keyword and ignore error    ue.Stop Data Transfer  dt_name=dt_UE_${ue}_dl
        Run keyword and ignore error    ue.detach_ue    ue_alias=${alias_${ue}}
    END

    append to file  ${resultFile}  \n\n****** STEP2 ******\n
    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_orig.xml   connection=coam_admin
    set test variable   ${actTddCsirsAllocOptimization}   true   #a ajouter
    set test variable   ${actExplicitCsirsPoolSolution}   true   #a enlever
    myKw Log config in result file
    myKw Activate config
    myKw Check TRS CSI-RS allocation
    myKw Check cell specific CSI-RS allocation
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step2.log

    ${status}   Run Keyword And Return Status   ue.attach_ue       ue_alias=${alias_${ue}}
    run keyword if   '${status}' == 'False'     ue.attach_ue       ue_alias=${alias_${ue}}
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 2  ${ue}
    END
    sleep   10s
    ${tPutStep2}  myTTI

    append to file  ${resultFile}   \n\n***************\n\n
    ${res}   Evaluate  ${tPutStep2} < ${tPutStep1}
    run keyword if    ${res}   run keywords
    ...   Run Keyword And Continue On Failure   Fail   Lower expected Tput
    ...   AND  append to file  ${resultFile}   Lower expected Tput\n
    ...   ELSE  append to file  ${resultFile}   Expected Tput\n

35_CB009836_A01_35_PeakTput_CsiRs40_80_CsiRsMode_10513_vs_9836
    [tags]  CB009836  35  one
    set test variable   @{ueList}   2
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1

    append to file  ${resultFile}  \n****** STEP1 ******\n
    set test variable   ${actTddCsirsAllocOptimization}   false  #a garder
    #set test variable   ${actExplicitCsirsPoolSolution}   false  #a ajouter
    myKw Log config in result file
    myKw Activate config
    myKw Check TRS CSI-RS allocation
    myKw Check cell specific CSI-RS allocation

    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step1.log
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 1  ${ue}
    END
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 2  ${ue}
    END
    sleep   10s
    ${tPutStep1}  myTTI

    FOR   ${ue}   IN   @{ueList}
        Run keyword and ignore error    ue.Stop Data Transfer  dt_name=dt_UE_${ue}_dl
        Run keyword and ignore error    ue.detach_ue    ue_alias=${alias_${ue}}
    END

    append to file  ${resultFile}  \n\n****** STEP2 ******\n
    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_orig.xml   connection=coam_admin
    set test variable   ${actTddCsirsAllocOptimization}   true   #a ajouter
    set test variable   ${actExplicitCsirsPoolSolution}   false   #a enlever
    myKw Log config in result file
    myKw Activate config
    myKw Check TRS CSI-RS allocation
    myKw Check cell specific CSI-RS allocation
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step2.log

    ${status}   Run Keyword And Return Status   ue.attach_ue       ue_alias=${alias_${ue}}
    run keyword if   '${status}' == 'False'     ue.attach_ue       ue_alias=${alias_${ue}}
    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch UE part sub 2  ${ue}
    END
    sleep   10s
    ${tPutStep2}  myTTI

    append to file  ${resultFile}   \n\n***************\n\n
    ${res}   Evaluate  ${tPutStep2} < ${tPutStep1}
    run keyword if    ${res}   run keywords
    ...   Run Keyword And Continue On Failure   Fail   Lower expected Tput
    ...   AND  append to file  ${resultFile}   Lower expected Tput\n
    ...   ELSE  append to file  ${resultFile}   Expected Tput\n

38_CB009836_A01_30_Pooling_Counters
    [tags]   CB009836_1   38  mycounter
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   ${actUeCsirsCoexistCellCsirs}            false
    set test variable   ${actCsirsBeamPowerBalance}         false
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071  ${mrbts}/${nrbts}/BWP_PROFILE-10071
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80    slots160   slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{bwpChBwPowerSaving}      70MHz    70MHz   70MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Log config in result file
    myKw Activate config
    MyKw Launch UE part for counters

39_CB009836-SR-B_02_USR2_IWK_5GC002516_FS_1208_1116_0ms_CNI-74648_disabled_RS4_40slots_bs6_WBTRS
    [tags]  CB009836    39  one
    set test variable   ${frameStructure}   5GC001208
    set test variable  ${actInfTddFrameMuting}   true
    set test variable   ${infTddframeStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-9  ${mrbts}/${nrbts}/BWP_PROFILE-9  ${mrbts}/${nrbts}/BWP_PROFILE-9
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-97  ${mrbts}/${nrbts}/BWP_PROFILE-97  ${mrbts}/${nrbts}/BWP_PROFILE-97
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10054  ${mrbts}/${nrbts}/BWP_PROFILE-10054  ${mrbts}/${nrbts}/BWP_PROFILE-10054
    #FS 1208 : BWP 5/57 has been changed to BWP 9/97 because the content is different when actInfTddFrameMuting equal true
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{bwpChBwPowerSaving}      70MHz    70MHz   70MHz
    set test variable   @{prach}      87  87  87
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   1   2   4
    set test variable   ${rbAllocation}    BWP
    set test variable   ${actBlankDlSymbBorderCoord}        false
    myKw Main test 2

40_CB009836-SR-B_03_USR2_IWK_5GC002516_FS_1208_1116_3ms_CNI-74648_enabled_RS4_80slots_bs4_NBTRS
    [tags]  CB009836    40  one
    set test variable   ${frameStructure}   5GC001208
    set test variable  ${actInfTddFrameMuting}   true
    set test variable   ${infTddframeStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-9  ${mrbts}/${nrbts}/BWP_PROFILE-9  ${mrbts}/${nrbts}/BWP_PROFILE-9
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-97  ${mrbts}/${nrbts}/BWP_PROFILE-97  ${mrbts}/${nrbts}/BWP_PROFILE-97
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10054  ${mrbts}/${nrbts}/BWP_PROFILE-10054  ${mrbts}/${nrbts}/BWP_PROFILE-10054
    #FS 1208 : BWP 5/57 has been changed to BWP 9/97 because the content is different when actInfTddFrameMuting equal true
    set test variable   @{beamSet}   beamSet_4  beamSet_4  beamSet_4
    set test variable   @{beams}     4 beams  4 beams  4 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{bwpChBwPowerSaving}      70MHz    70MHz   70MHz
    set test variable   @{prach}      87  87  87
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   @{maxCsirsNumber}                   1   2   4
    set test variable   ${rbAllocation}    52RB
    set test variable   ${actBlankDlSymbBorderCoord}        true
    myKw Main test 2

41_CB009836-SR-B_04_USR2_IWK_5GC002516_FS_1116_0ms_1208_CNI-74648_disabled_RS4_320slots_bs2_WBTRS
    [tags]  CB009836    41  one
    set test variable   ${frameStructure}   5GC001116_0
    set test variable  ${actInfTddFrameMuting}   true
    set test variable   ${infTddframeStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-10  ${mrbts}/${nrbts}/BWP_PROFILE-10  ${mrbts}/${nrbts}/BWP_PROFILE-10
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-107  ${mrbts}/${nrbts}/BWP_PROFILE-107  ${mrbts}/${nrbts}/BWP_PROFILE-107
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10074  ${mrbts}/${nrbts}/BWP_PROFILE-10074  ${mrbts}/${nrbts}/BWP_PROFILE-10074
    #FS 1116_0ms : BWP 7/77 has been changed to BWP 10/107 because the content is different when actInfTddFrameMuting equal true
    set test variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2
    set test variable   @{beams}     2 beams  2 beams  2 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{bwpChBwPowerSaving}      70MHz    70MHz   70MHz
    set test variable   @{prach}      97  97  97
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   1   2   4
    set test variable   ${rbAllocation}    BWP
    set test variable   ${actBlankDlSymbBorderCoord}        false
    myKw Main test 2

42_CB009836-SR-B_05_USR2_IWK_5GC002516_FS_1116_0ms_1208_CNI-74648_enabled_RS4_80slots_bs6_NBTRS
    [tags]  CB009836    42  one
    set test variable   ${frameStructure}   5GC001116_0
    set test variable  ${actInfTddFrameMuting}   true
    set test variable   ${infTddframeStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-10  ${mrbts}/${nrbts}/BWP_PROFILE-10  ${mrbts}/${nrbts}/BWP_PROFILE-10
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-107  ${mrbts}/${nrbts}/BWP_PROFILE-107  ${mrbts}/${nrbts}/BWP_PROFILE-107
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10074  ${mrbts}/${nrbts}/BWP_PROFILE-10074  ${mrbts}/${nrbts}/BWP_PROFILE-10074
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{bwpChBwPowerSaving}      70MHz    70MHz   70MHz
    set test variable   @{prach}      97  97  97
    set test variable   @{csirsNbWithinReportPeriod_Set1}   3   3   3
    set test variable   @{maxCsirsNumber}                   1   2   4
    set test variable   ${rbAllocation}    52RB
    set test variable   ${actBlankDlSymbBorderCoord}        true
    myKw Main test 2

43_CB009836-SR-B_06_USR2_IWK_5GC002516_FS_1116_3ms_1208_CNI-74648_disabled_RS4_160slots_bs8_WBTRS
    [tags]  CB009836    43  one
    set test variable   ${frameStructure}   5GC001116_3
    set test variable  ${actInfTddFrameMuting}   true
    set test variable   ${infTddframeStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-11  ${mrbts}/${nrbts}/BWP_PROFILE-11  ${mrbts}/${nrbts}/BWP_PROFILE-11
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-117  ${mrbts}/${nrbts}/BWP_PROFILE-117  ${mrbts}/${nrbts}/BWP_PROFILE-117
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10084  ${mrbts}/${nrbts}/BWP_PROFILE-10084  ${mrbts}/${nrbts}/BWP_PROFILE-10084
    #FS 1116_3ms : BWP 8/87 has been changed to BWP 11/117 because the content is different when actInfTddFrameMuting equal true
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{prach}      97  97  97
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   1   2   4
    set test variable   ${rbAllocation}    BWP
    set test variable   ${actBlankDlSymbBorderCoord}        false
    myKw Main test 2

44_CB009836-SR-B_07_USR2_IWK_5GC002516_FS_1116_3ms_1208_CNI-74648_enabled_RS4_320slots_bs2_NBTRS
    [tags]  CB009836    44  one
    set test variable   ${frameStructure}   5GC001116_3
    set test variable  ${actInfTddFrameMuting}   true
    set test variable   ${infTddframeStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-11  ${mrbts}/${nrbts}/BWP_PROFILE-11  ${mrbts}/${nrbts}/BWP_PROFILE-11
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-117  ${mrbts}/${nrbts}/BWP_PROFILE-117  ${mrbts}/${nrbts}/BWP_PROFILE-117
    set test variable   @{bwp2}   ${mrbts}/${nrbts}/BWP_PROFILE-10084  ${mrbts}/${nrbts}/BWP_PROFILE-10084  ${mrbts}/${nrbts}/BWP_PROFILE-10084
    set test variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2
    set test variable   @{beams}     2 beams  2 beams  2 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{bwpChBwPowerSaving}      70MHz    70MHz   70MHz
    set test variable   @{prach}      97  97  97
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   1   2   4
    set test variable   ${rbAllocation}    52RB
    set test variable   ${actBlankDlSymbBorderCoord}        true
    myKw Main test 2

#FS 1208 : BWP 5/57 changed to BWP 9/97 because the content is different when actInfTddFrameMuting equal true

