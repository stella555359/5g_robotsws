*** Settings ***
Documentation
...     The purpose of this suite is to Provide a series of Tools for SyVe SG04

...     AUTHOR (I&V-4):
...         Stephane Croquet

Suite Setup  Actions Suite Setup
Suite Teardown    Actions Suite Teardown
Test Setup       Actions Test Setup
Test Teardown    Actions Test Teardown
Test Timeout        45min


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
@{nrCellId}       0   1   2
@{nrCellGrplId}   0   1   2

${nbCellCsiRsGrp}   3
${mrbts}      MRBTS-101
${nrbts}      NRBTS-23143
@{counterstocheck}   M55308C00001   M55308C10001   M55308C10003   M55308C10005
@{countersDesc}      M55308C00001: Sum of DL Data slots
    ...              M55308C10001: Number of PRBs used for PDSCH
    ...              M55308C10003: Number of PRBs available for PDSCH
    ...              M55308C10005: Number of PRBs available for PDSCH with L1 PRB Pooling
${targetVersion}     SBTS00_ENB_9999_240605_000009
${myDataSet}         /mnt/MNRAN_PZNPS/TL/CV101/myDataSet.csv

${alias_0}            UE_1
${capabilities_0}     REAL_UE_1
${alias_1}            UE_2
${capabilities_1}     REAL_UE_2
${alias_2}            UE_3
${capabilities_2}     REAL_UE_3
@{ueList}             0  1  2
#RSE &{dlTput}             0=400   1=400   2=400        #0=400   1=800   2=1500
&{dlTput}             0=200   1=400   2=800        #0=400   1=800   2=1500
&{ulTput}             0=200   1=200   2=200
#RSE &{expectedDlTput}     0=400   1=400    2=400
&{expectedDlTput}     0=100   1=300    2=700
&{expectedUlTput}     0=200   1=200    2=200
&{ueMapping}          101=2   103=1    105=0

${duration}           300s
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
${actBbPoolTddFr1Enh}               true  #CB011028 Set to True after upgrade to SBTS00_ENB_9999_240821_000008
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
#RSE ${actUeCsirsCoexistCellCsirs}       true
#RSE ${actCsirsBeamPowerBalance}         true
${actUeCsirsCoexistCellCsirs}       false
${actCsirsBeamPowerBalance}         false
${actBlankDlSymbBorderCoord}        false
@{actNonVoNRGbrService}             true   true    true
@{actGBRAdmissionControl}           GBRService   GBRService   GBRService
@{pagingOffset}                     1   1   1
@{fPdcchMonOccsnPo}                 2   2   2
# New values for variable &{reqMinNumPuschPrb} following PUCCH configuration guide
&{reqMinNumPuschPrb}   30MHz=66
    ...   40MHz=88
    ...   50MHz=131
    ...   60MHz=140
    ...   70MHz=167
    ...   80MHz=195
    ...   90MHz=223
    ...   100MHz=251
${SnapshotOnTeardown}        ${False}
${actPerCsiReportBundlingTddFr1}        true
${CheckPRB}           ${True}   # include PRB check in test
${ngbr}        ${True}        # launch traffic ngbr
${gbr}         ${False}        # launch traffic gbr
#RSE ${ul}        ${True}        # launch traffic ul
${ul}        ${True}        # launch traffic ul
${gbr_port}        6003        # port for gbr traffic in the iperf command
${restoreSCF}        ${False}         # restore initial scf in Suite teardown


*** Test Cases ***
00_Upgrade
    [Tags]  00  upgrade  CB009836
    myKw Upgrade gNB

Test_l1Sp
    ${output}=        OperatingSystem.Run
    ...    command=cat /tmp/btslog2/SYSLOG_1.LOG | grep CellMappingReq:
    should not be empty                  ${output}

    ${l1spcells}      extract_dll1sp_from_syslog     ${output}
#    Should Not Be Empty     ${l1spcells[1]}
    log to console      ${l1spcells}


Delete and create cells
#    [Setup]     Setup Sequence
#    [Teardown]      Teardown Sequence

    ${dll1spcells}     ${ull1spcells}     Reset Site and check l1Subpools
    set global variable       ${dll1spcells}
    set global variable       ${ull1spcells}
    ${cells}        Get Cells
    ${numofcells}  Get Length     ${cells}
    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_before_deletion.xml   connection=coam_admin
    ${twocells}     Set Variable    ${FALSE}        #Cells will be deleted/created in pairs if TRUE
    ${sequence}        Create List    -1     -2     +1     -3
    FOR     ${cell}    IN     @{sequence}
        ${abscell}    Evaluate    $cell.strip("+-")
        ${celllist}    Create List    ${abscell}
        Run Keyword If        ${cell}<0     Delete And Check Cells        ${celllist}     ${numofcells}
        ...    ELSE        Create And Check Cell    ${cell}    ${numofcells}       /tmp/scf_delta_${abscell}.xml
        Run Keyword If        ${cell}<0     coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_after_deletion.xml
	...   connection=coam_admin
        Run Keyword If   ${cell}<0   scf.calculate_delta_scf   /tmp/scf_before_deletion.xml
	...   /tmp/scf_after_deletion_${abscell}.xml     /tmp/scf_delta_${abscell}.xml
        Run Keyword If        ${cell}<0     Remove RPGRP from Delta scf     /tmp/scf_delta.xml
    END


Test_TTI
    ${date}         Set Variable        20240828_11_38
    ${suiteLogPath}     set variable        /home/localuser/LogAuto/CB009836_CV101_20240828_11_38
    set suite variable  ${suiteLogPath}    ${suiteLogPath}
    set suite variable  ${resultFile}    ${suiteLogPath}/result.txt
    set suite variable  ${csiRsFile}    ${suiteLogPath}/resultCsiRs.txt
    ${directory}        replace string      ${TEST NAME}_${date}    ${SPACE}    _
    ${testLogPath}      joinpath        ${suiteLogPath}
    ...     27_CB009836_A01_27_CSIRS_TRS_Cellspecific_allocation_Pooling_semiStatic37_csirs_320_bs6_20240828_11_38
    set test variable   ${testLogPath}     ${testLogPath}/
    OperatingSystem.Run  command=gzip -d ${testLogPath}*.gz
    myKw PRB check

01_CB009836_A01_01_5GC001116_0_6ssb_40sl
    [tags]  01  CB009836  upgrade  5GC001116_0
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots160   slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    myKw Main test 3

01bis_CB009836_A01_01_5GC001116_0_6ssb_40sl
    [tags]  01bis
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    #set test variable   @{csiReportPeriodicity}     slots40   slots160   slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    #set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    #[TEL] STEP_1
    set test variable   ${actExplicitCsirsPoolSolution}   false
    #[TEL] STEP_2 fait manuellement sur le WebEM
    #[TEL] STEP_3 ne pas oublier de commenter la ligne 198 et la ligne 201 et garder le STEP_1 décommenté
    #set test variable   ${actBbPoolExtensionTddFr1}   false
    #set test variable   @{csiReportPeriodicity}     slots80   slots160   slots320
    #"set test variable   @{csirsNbWithinReportPeriod_Set1}   2   1   1
    set test variable   @{actNonVoNRGbrService}   false  false  false
    set test variable   @{actGBRAdmissionControl}   EnhancedVoNR  EnhancedVoNR  EnhancedVoNR
    #[TEL] STEP_4 ne pas oublier de commenter la ligne 198 et la ligne 201 + Step_3 (total) et garder le STEP_1 décommenté
    set test variable   ${actBbPoolExtensionTddFr1}   false
    set test variable   @{csiReportPeriodicity}     slots80   slots160   slots320
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   3
    myKw Main test 3

02_CB009836_A01_02_5GC001116_0_6ssb_80sl
    [tags]  02  CB009836  5GC001116_0
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80    slots160   slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

03_CB009836_A01_03_5GC001116_0_6ssb_160sl
    [tags]  03  CB009836  upgrade  5GC001116_0
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   2   1
    set test variable   ${actExplicitCsirsPoolSolution}   false
    myKw Main test 3

04_CB009836_A01_04_5GC001116_0_6ssb_320sl
    [tags]  04  CB009836  5GC001116_0
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

05_CB009836_A01_05_5GC001116_0_6ssb_80sl
    [tags]  05  CB009836  5GC001116_0
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    myKw Main test 3

06_CB009836_A01_06_5GC001116_3_8ssb_40sl
    [tags]  06  CB009836  5GC001116_3
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

07_CB009836_A01_07_5GC001116_3_8ssb_80sl
    [tags]  07  CB009836  5GC001116_3
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 3

08_CB009836_A01_08_5GC001116_3_8ssb_160sl
    [tags]  08  CB009836  upgrade  5GC001116_3
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

09_CB009836_A01_09_5GC001116_3_8ssb_320sl
    [tags]  09  CB009836  5GC001116_3
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 3

10_CB009836_A01_10_5GC001116_3_8ssb_80sl
    [tags]  10  CB009836  5GC001116_3
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-85  ${mrbts}/${nrbts}/BWP_PROFILE-83
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

11_CB009836_A01_11_5GC001208_6ssb_40sl
    [tags]  11  CB009836  5GC001208
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{pagingOffset}                     3   3   3
    set test variable   @{fPdcchMonOccsnPo}                 1   1   1
    myKw Main test 3

12_CB009836_A01_12_5GC001208_6ssb_80sl
    [tags]  12  CB009836  5GC001208
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    set test variable   @{pagingOffset}                     3   3   3
    set test variable   @{fPdcchMonOccsnPo}                 1   1   1
    myKw Main test 3

13_CB009836_A01_13_5GC001208_6ssb_160sl
    [tags]  13  CB009836  upgrade  5GC001208
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{pagingOffset}                     3   3   3
    set test variable   @{fPdcchMonOccsnPo}                 1   1   1
    myKw Main test 3

14_CB009836_A01_14_5GC001208_6ssb_320sl
    [tags]  14  CB009836  5GC001208
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    set test variable   @{pagingOffset}                     3   3   3
    set test variable   @{fPdcchMonOccsnPo}                 1   1   1
    myKw Main test 3

15_CB009836_A01_15_5GC001208_6ssb_80sl
    [tags]  15  CB009836  5GC001208
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-53
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   @{pagingOffset}                     3   3   3
    set test variable   @{fPdcchMonOccsnPo}                 1   1   1
    myKw Main test 3

16_CB009836_A01_16_5GC001070_6ssb_40sl
    [tags]  16  CB009836  5GC001070
##   set test variable   &{expectedDlTput}  0=400   1=800    2=1200
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

17_CB009836_A01_17_5GC001070_6ssb_80sl
    [tags]  17  CB009836  5GC001070
#   set test variable   &{expectedDlTput}  0=400   1=800    2=1200
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 3

18_CB009836_A01_18_5GC001070_6ssb_160sl
    [tags]  18  CB009836  upgrade  5GC001070
#   set test variable   &{expectedDlTput}  0=400   1=800    2=1200
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

19_CB009836_A01_19_5GC001070_6ssb_320sl
    [tags]  19  CB009836  5GC001070
#   set test variable   &{expectedDlTput}  0=400   1=800    2=1200
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    myKw Main test 3

20_CB009836_A01_20_5GC001070_6ssb_80sl
    [tags]  20  CB009836  5GC001070
#   set test variable   &{expectedDlTput}  0=400   1=800    2=1200
    set test variable   ${frameStructure}   5GC001070
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-65  ${mrbts}/${nrbts}/BWP_PROFILE-63
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

21_CB009836_A01_21_5GC001208_4ssb_80sl
    [tags]  21  CB009836   set1
    set test variable   &{dlTput}   0=1500   1=1500   2=1500
    set test variable   &{expectedDlTput}  0=900   1=900    2=900
    set test variable   ${frameStructure}   5GC001208
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-5
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-57  ${mrbts}/${nrbts}/BWP_PROFILE-57
    set test variable   @{beamSet}   beamSet_4  beamSet_4  beamSet_4
    set test variable   @{beams}     4 beams  4 beams  4 beams
    set test variable   @{csiReportPeriodicity}     slots80   slots80  slots80
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   2   2   2
    set test variable   @{pagingOffset}                     3   3   3
    set test variable   @{fPdcchMonOccsnPo}                 1   1   1
    myKw Main test 3

22_CB009836_A01_22_5GC001116_3_8ssb_160sl
    [tags]  22  CB009836  upgrade  set1
    set test variable   &{dlTput}   0=1500   1=1500   2=1500
    set test variable   &{expectedDlTput}  0=1000   1=1000    2=1000
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-87
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   3   3   3
    set test variable   @{maxCsirsNumber}                   2   2   2
    set test variable   ${rbAllocation}    52RB
    myKw Main test 3

23_CB009836_A01_23_5GC001116_3_8ssb_320sl
    [tags]  23  CB009836  set1
    set test variable   &{dlTput}   0=1500   1=1500   2=1500
    set test variable   &{expectedDlTput}  0=1000   1=1000    2=1000
    set test variable   ${frameStructure}   5GC001116_3
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-8
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-87  ${mrbts}/${nrbts}/BWP_PROFILE-87
    set test variable   @{beamSet}   beamSet_8  beamSet_8  beamSet_8
    set test variable   @{beams}     8 beams  8 beams  8 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   4   4   4
    set test variable   @{maxCsirsNumber}                   1   1   1
    myKw Main test 3

24_CB009836_A01_24_CSIRS_TRS_Cellspecific_allocation_Pooling_tdLte_0ms_csirs_40_bs6
    [tags]  CB009836    24  one  cv_101
    set test variable   ${frameStructure}   5GC001116_0
#   set test variable   &{expectedDlTput}  0=1000   1=1000    2=1000
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   ${rbAllocation}    52RB
    set test variable   @{prach}      96  96  96
    set test variable   ${gbr}       ${True}
    myKw Main test 3

27_CB009836_A01_27_CSIRS_TRS_Cellspecific_allocation_Pooling_semiStatic37_csirs_320_bs6
    [tags]  CB009836    27  one  cv_101
    set test variable   ${frameStructure}   5GC001070
#   set test variable   &{expectedDlTput}  0=1000   1=1000    2=1000
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6  ${mrbts}/${nrbts}/BWP_PROFILE-6
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-67  ${mrbts}/${nrbts}/BWP_PROFILE-67
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320   slots320  slots320
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   ${rbAllocation}    BWP
    set test variable   ${gbr}       ${True}
    myKw Main test 3

28_CB009836_A01_28_CB010513_Disabled
    [tags]  28  CB009836   set2
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actBbPoolExtensionTddFr1}   false
    set test variable   ${actExplicitCsirsPoolSolution}   false
    set test variable   @{actNonVoNRGbrService}   false  false  false
    set test variable   @{actGBRAdmissionControl}   EnhancedVoNR  EnhancedVoNR  EnhancedVoNR
    myKw Main test 3

29_CB009836_A01_29_CB011028_Enabled
    [tags]  29  CB009836    set2
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actBbPoolTddFr1Enh}   true
    myKw Main test 3

30_CB009836_A01_30_CB009836_Disabled-CB010513_CSIRS_Mode
    [tags]  30  CB009836
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actTddCsirsAllocOptimization}   false
    set test variable   ${actExplicitCsirsPoolSolution}   true
    myKw Main test 3

31_CB009836_A01_31_CB009836_Disabled-CB008940_CSIRS_Mode
    [tags]  31  CB009836    set2
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${actTddCsirsAllocOptimization}   false
    set test variable   ${actExplicitCsirsPoolSolution}   false
    myKw Main test 3

34_CB009836_A01_34_PeakTput_CsiRs160_320_CsiRsMode_8940_vs_9836
    [tags]  34  CB009836    set3

    ${errorOk}  Convert To Integer  ${errorOk}
    ${ue}   set variable  ${ueMapping["${pciId}"]}

    set test variable   &{dlTput}   0=1500   1=1500   2=1500
    set test variable   &{expectedDlTput}  0=800   1=800    2=800
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots160   slots160  slots160
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1

    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch Start Proxy and ADB   ${ue}
        Wait until keyword succeeds  120s  30s  ue.require_ue      ue_alias=${alias_${ue}}      capabilities=${capabilities_${ue}}
    END

    append to file  ${resultFile}  \n****** STEP1 ******\n
    set test variable   ${actTddCsirsAllocOptimization}   false  #On desactive la CB009836
    set test variable   ${actExplicitCsirsPoolSolution}   false  #Et on active 10513 feature and 8940 csi-rs mode
    myKw Main test 3-sub1

    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step1.log

    MyKw Launch UE call loop
    sleep   4s
    @{statStep1}  create list

    FOR  ${loop}  IN RANGE  ${nbLoop}
        ${stats}   run keyword and continue on failure    myTTI v1   _step1
        ${status}   set variable if  $stats is not None   ${True}
        run keyword if  ${status}
        ...  run keyword if   len(${nrCellId}) == len(${stats})   append to list    ${statStep1}   ${stats}
    END
    log   ${statStep1}
    MyKw Stop UE call loop

    append to file  ${resultFile}  \n\n****** STEP2 ******\n
    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_orig.xml   connection=coam_admin
    set test variable   ${actTddCsirsAllocOptimization}   true
    myKw Main test 3-sub1
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step2.log

    MyKw Launch UE call loop
    sleep   4s
    @{statStep2}  create list
    FOR  ${loop}  IN RANGE  ${nbLoop}
        ${stats}   run keyword and continue on failure    myTTI v1   _step2
        ${status}   set variable if  $stats is not None   ${True}
        run keyword if  ${status}
        ...  run keyword if   len(${nrCellId}) == len(${stats})   append to list    ${statStep2}   ${stats}
    END
    log   ${statStep2}
    MyKw Stop UE call loop

    append to file  ${resultFile}  \n\n****** RESULT ******\n
    append to file  ${resultFile}  STEP1\n
    ${averageTputStep1}  tputStat   ${resultFile}     ${statStep1}
    append to file  ${resultFile}  \n\nSTEP2\n
    ${averageTputStep2}  tputStat   ${resultFile}     ${statStep2}

    ${res}   compareValue  ${averageTputStep1}  ${averageTputStep2}  ${errorOk}
    run keyword if    '${res}' == 'notOK'   run keywords
    ...   Run Keyword And Continue On Failure   Fail   Tput should be closer
    ...   AND  append to file  ${resultFile}   \n\nTput should be closer\n
    ...   ELSE  append to file  ${resultFile}   \n\nTput close\n

35_CB009836_A01_35_PeakTput_CsiRs40_80_CsiRsMode_10513_vs_9836
    [tags]  35  CB009836    set3

    ${errorOk}  Convert To Integer  ${errorOk}
    ${ue}   set variable  ${ueMapping["${pciId}"]}

    set test variable   &{dlTput}   0=1500   1=1500   2=1500
    set test variable   &{expectedDlTput}  0=800   1=800    2=800
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40  slots40
    set test variable   @{chBw}      100MHz  100MHz  100MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1

    FOR   ${ue}   IN   @{ueList}
        run keyword and continue on failure   MyKw Launch Start Proxy and ADB   ${ue}
        Wait until keyword succeeds  120s  30s  ue.require_ue      ue_alias=${alias_${ue}}      capabilities=${capabilities_${ue}}
    END

    append to file  ${resultFile}  \n****** STEP1 ******\n
    set test variable   ${actTddCsirsAllocOptimization}   false
    set test variable   ${actExplicitCsirsPoolSolution}   true
    myKw Main test 3-sub1

    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step1.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step1.log

    MyKw Launch UE call loop
    sleep   4s
    @{statStep1}  create list

    FOR  ${loop}  IN RANGE  ${nbLoop}
        ${stats}   run keyword and continue on failure    myTTI v1   _step1
        ${status}   set variable if  $stats is not None   ${True}
        run keyword if  ${status}
        ...  run keyword if   len(${nrCellId}) == len(${stats})   append to list    ${statStep1}   ${stats}
    END
    log   ${statStep1}
    MyKw Stop UE call loop

    append to file  ${resultFile}  \n\n****** STEP2 ******\n
    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_orig.xml   connection=coam_admin
    set test variable   ${actTddCsirsAllocOptimization}   true
    myKw Main test 3-sub1
    OperatingSystem.Run  command=mv ${testLogPath}/scf_modif.xml ${testLogPath}/scf_modif_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_orig.xml ${testLogPath}/scf_orig_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/scf_delta.xml ${testLogPath}/scf_delta_step2.xml
    OperatingSystem.Run  command=mv ${testLogPath}/${syslog} ${testLogPath}/SYSLOG_Step2.log

    MyKw Launch UE call loop
    sleep   4s
    @{statStep2}  create list
    FOR  ${loop}  IN RANGE  ${nbLoop}
        ${stats}   run keyword and continue on failure    myTTI v1   _step2
        ${status}   set variable if  $stats is not None   ${True}
        run keyword if  ${status}
        ...  run keyword if   len(${nrCellId}) == len(${stats})   append to list    ${statStep2}   ${stats}
    END
    log   ${statStep2}
    MyKw Stop UE call loop

    append to file  ${resultFile}  \n\n****** RESULT ******\n
    append to file  ${resultFile}  STEP1\n
    ${averageTputStep1}  tputStat   ${resultFile}     ${statStep1}
    append to file  ${resultFile}  \n\nSTEP2\n
    ${averageTputStep2}  tputStat   ${resultFile}     ${statStep2}

    ${satus}  evaluate   ${averageTputStep2} > ${averageTputStep1}
    run keyword if    not(${satus})   run keywords
    ...   Run Keyword And Continue On Failure   Fail   Tput with CB009836 should be higher than with CB010513
    ...   AND  append to file  ${resultFile}   \n\nTput with CB009836 should be higher than with CB010513\n
    ...   ELSE  append to file  ${resultFile}   \n\nTput with CB009836 is higher than with CB010513\n


38_CB009836_A01_38_Pooling_Counters
    [tags]   38
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots320    slots320   slots320
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   ${rbAllocation}    52RB
    myKw Log config in result file
    myKw Activate config
    MyKw Launch UE part for counters


CB009836-SR-A_24_CSIRS_TRS_Cellspecific_allocation_Pooling_tdLte_0ms_csirs_40_bs6
    [tags]   24
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-75  ${mrbts}/${nrbts}/BWP_PROFILE-73
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots40   slots40
    set test variable   @{chBw}      100MHz  80MHz  60MHz
    set test variable   @{prach}      96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1
    set test variable   @{maxCsirsNumber}                   4   4   4
    set test variable   ${rbAllocation}    52RB
    set test variable   ${actUeCsirsCoexistCellCsirs}       false
    set test variable   ${actCsirsBeamPowerBalance}         false
    myKw Main test 3
