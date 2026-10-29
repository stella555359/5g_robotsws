*** Settings ***
Documentation
...     The purpose of this suite is to Provide a series of Tools for SyVe SG04

...     AUTHOR (I&V-4):
...         Alberto Fernandez

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

Library     ../CB009836/myTtiParserScro.py
Library     ../CB009836/myScriptPythonScro.py

Resource    ../../Resources/keywords_common.robot
Resource    ../CB009836/CB009836MyKeywords.robot

#Resource    taf/rfrl/bts/robot/gnb.robot
#Resource    taf/rfrl/bts/robot/common/gnb_log.robot


*** Variables ***
${timerTeardown}  30
${logPath}        /home/localuser/LogAuto
#@{nrCellId}       0   1   2
#@{nrCellGrplId}   0   1   2

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
&{dlTput}             0=1000   1=1000   2=1000        #0=400   1=800   2=1500
&{ulTput}             0=200   1=200   2=200
#RSE &{expectedDlTput}     0=400   1=400    2=400
&{expectedDlTput}     0=200   1=200    2=200
&{expectedUlTput}     0=200   1=200    2=200
&{ueMapping}          101=2   103=1    105=0   102=2   104=1    106=0

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
${actDlMuMimoEnh}       false
${actUlMuMimo}          false
${actSuperCell}         false
${actVoNR}              true
${actEnhancedVoNR}      true

${actBbPoolTddFr1}                  false   #CB008940
${actBbPoolExtensionTddFr1}         false   #CB010513
${actBbPoolTddFr1Enh}               false  #CB011028 Set to True after upgrade to SBTS00_ENB_9999_240821_000008
${actBbPoolTddFr1AlgEnh}            false   #LBT - New Pooling Algo
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
${bbHwVariant}        ABIP
${1PoolType}        NR_L1Pool_Thor_TDD_FR1_eCPRI_7_2e
${CheckPRB}           ${True}   # include PRB check in test
${ngbr}        ${True}        # launch traffic ngbr
${gbr}         ${False}        # launch traffic gbr
${ul}        ${False}        # launch traffic ul
${dl}        ${True}        # launch traffic dl
${gbr_port}        6003        # port for gbr traffic in the iperf command
${ul_gbr_port}        5004        # port for gbr traffic in the iperf command
${restoreSCF}        ${False}         # restore initial scf in Suite teardown
${cb012605}        ${True}        #Use PRB check for CB012605
@{cellsToLock}                    ${1}     ${3}     ${5}
${skipFileCreation}        ${True}



*** Test Cases ***

myKw test lists
    ${cellsNumber}       Get Cells Number OAM
    ${nrCellIx}          Evaluate    list(range(${cellsNumber}))
    Lock Cells        ${cellsToLock}
    ${nrCellIx}    Evaluate    [d for d in ${nrCellIx} if d not in ${cellsToLock}]
    ${nrCellId_all}            Get Cells List OAM
    ${nrCellId}    Create List
    FOR   ${cell}    IN    @{nrCellIx}
        Append To List    ${nrCellId}    ${nrCellId_all[${cell}]}
    END
    log to console    ${nrCellId}
CB009836-SR-Empty
    Fail    Empty test case

#00_Upgrade
#    [Tags]  00  upgrade  CB009836
#    myKw Upgrade gNB

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
    FOR     ${cell}    IN     ${sequence}
        ${abscell}    Evaluate    ${cell}[1:]    cell=${cell}
        Run Keyword If        ${cell}<0     Delete And Check Cells        ${cell}     ${numofcells}
        ...    ELSE        Create And Check Cell    ${cell}    ${numofcells}       /tmp/scf_delta_${abscell}.xml
        Run Keyword If        ${cell}<0     coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_after_deletion.xml
	...   connection=coam_admin
        Run Keyword If        ${cell}<0     scf.calculate_delta_scf     /tmp/scf_before_deletion.xml
	...     /tmp/scf_after_deletion_${cell}.xml     /tmp/scf_delta_${abscell}.xml
        Run Keyword If        ${cell}<0     Remove RPGRP from Delta scf     /tmp/scf_delta.xml
    END

Test_TTI
    ${date}         Set Variable        20241105_16_21
    ${suiteLogPath}     set variable        /home/localuser/LogAuto/CB012605_CV101_20241105_16_21
    set suite variable  ${suiteLogPath}    ${suiteLogPath}
    set suite variable  ${resultFile}    ${suiteLogPath}/result.txt
    set suite variable  ${csiRsFile}    ${suiteLogPath}/resultCsiRs.txt
    ${directory}        replace string      ${TEST NAME}_${date}    ${SPACE}    _
    ${testLogPath}      joinpath        ${suiteLogPath}     CB012605-SR-C_003_L1SubpoolPrbPooling_low_PRB_Demand_100MHz_20241105_16_22
    set test variable   ${testLogPath}     ${testLogPath}/
    OperatingSystem.Run  command=gzip -d ${testLogPath}*.gz
    myKw PRB check

Test_attach
    set test variable   ${gbr}   ${True}
    set test variable   &{dlTput}             0=200   1=200   2=200
    set test variable   &{ulTput}             0=200   1=200   2=200
    set test variable   ${ue}             1

    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${800}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${400}
#    Run keyword if  ${ul} and ${gbr}
#    ...     Wait until keyword succeeds  120s  5s    Launch UL GBR traffic        ue=${ue}     duration=${duration}  throughput=${ulTput['${ue}']}
#    ...    protocol=${protocol}	  packet_size=${Packet_Size}  port=${ul_gbr_port}
#    Run keyword if  ${ul} and ${gbr}
#    ...     Wait until keyword succeeds  120s  5s          Launch UL GBR traffic        throughput=${ulTput['${ue}']}
#    ...        ue=${ue}        duration=${duration}   #protocol=${protocol}  packet_size=${Packet_Size}  port=${ul_gbr_port}
    MyKw Launch UE part One UE PC

CB012605-C_Test_Launch_TTI
    [tags]  01  CB012605  upgrade  5GC001116_0

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    MyKw Launch And Convert TTI    suffixe=${EMPTY}       duration=5

CB012605-C_001_Feature_Activation
    [tags]  01  CB012605  upgrade  5GC001116_0
    set test variable   ${frameStructure}   5GC001116_0
    set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-7
    set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-77
    set test variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6  beamSet_6  beamSet_6  beamSet_6
    set test variable   @{beams}     6 beams  6 beams  6 beams  6 beams  6 beams  6 beams
    set test variable   @{csiReportPeriodicity}     slots40   slots160   slots320
    set test variable   @{chBw}      100MHz  100MHz  100MHz  100MHz  100MHz  100MHz
    set test variable   @{prach}      96  96  96  96  96  96
    set test variable   @{csirsNbWithinReportPeriod_Set1}   1   1   1  1  1  1
    set test variable   @{maxCsirsNumber}                   4   4   4  4  4  4
    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    Wait Until Keyword Succeeds    2x        1s     myKw Main test 4

CB012605-SR-C_003_L1SubpoolPrbPooling_low_PRB_Demand_100MHz
    [tags]  03  CB012605
    set test variable   ${gbr}   ${True}
    set test variable   &{dlTput}             0=200   1=200   2=200
    set test variable   &{ulTput}             0=200   1=200   2=200
    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${800}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${400}
#    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${1092}


    ${vendorElement1}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     DL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpDl}
    ${vendorElement2}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     UL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpUl}
    ${MaxSpPRB}     Create List       ${vendorElement1}        ${vendorElement2}

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    Set Test Variable       ${MaxSpPRB}
    myKw Activate cb012605 in vendor file     ${MaxSpPRB}

    myKw Main test 4

CB012605-Launch_UL
    [tags]  03  CB012605
    set test variable   &{dlTput}             0=200   1=200   2=200
    set test variable   &{ulTput}             0=200   1=200   2=200
    Set Test Variable        ${ngbr}        ${False}        # launch traffic ngbr
    Set Test Variable        ${gbr}         ${True}        # launch traffic gbr
    Set Test Variable        ${ul}        ${True}        # launch traffic ul
    Set Test Variable        ${dl}        ${False}        # launch traffic ul
    MyKw Launch UE part

CB012605-SR-D_003_L1SubpoolPrbPooling_low_PRB_Demand_100MHz
    [tags]  03  CB012605
    set test variable   &{dlTput}             0=200   1=200   2=200
    set test variable   &{ulTput}             0=600   1=200   2=200
    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${800}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${275}
    Set Test Variable        ${ngbr}        ${False}        # launch traffic ngbr
    Set Test Variable        ${gbr}         ${False}        # launch traffic gbr
    Set Test Variable        ${ul}        ${True}        # launch traffic ul
    Set Test Variable    @{ueList}    0

#    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${1092}


    ${vendorElement1}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     DL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpDl}
    ${vendorElement2}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     UL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpUl}
    ${MaxSpPRB}     Create List       ${vendorElement1}        ${vendorElement2}

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    Set Test Variable       ${MaxSpPRB}
    myKw Activate cb012605 in vendor file     ${MaxSpPRB}

    myKw Main test 4

CB012605-SR-D_006_Maximum_UL_Potential_Resources_Per_L1SubPool _BW_50Mhz_ABIP_Q
    [tags]  03  CB012605
    set test variable   &{dlTput}             0=200   1=200   2=200
    set test variable   &{ulTput}             0=300   1=300   2=200
    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${800}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${238}
    Set Test Variable        ${ngbr}        ${False}        # launch traffic ngbr
    Set Test Variable        ${gbr}         ${False}        # launch traffic gbr
    Set Test Variable        ${ul}        ${True}        # launch traffic ul
    Set Test Variable    @{ueList}    0        1

#    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${1092}


    ${vendorElement1}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     DL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpDl}
    ${vendorElement2}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     UL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpUl}
    ${MaxSpPRB}     Create List       ${vendorElement1}        ${vendorElement2}

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    Set Test Variable       ${MaxSpPRB}
    myKw Activate cb012605 in vendor file     ${MaxSpPRB}

    myKw Main test 4

CB012605-SR-D_007_UL_Inter_Intra_L1_subpool_PRB_Pooling_Low_Non_GBR_PRB_Demand_ABIP_Q
    [tags]  03  CB012605
    set test variable   &{dlTput}             0=200   1=200   2=200
    set test variable   &{ulTput}             0=50   1=50   2=50
    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${700}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${400}
    Set Test Variable        ${ngbr}        ${True}        # launch traffic ngbr
    Set Test Variable        ${gbr}         ${True}        # launch traffic gbr
    Set Test Variable        ${ul}        ${True}        # launch traffic ul
    Set Test Variable    @{ueList}    0        1        2

#    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${1092}


    ${vendorElement1}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     DL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpDl}
    ${vendorElement2}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     UL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpUl}
    ${MaxSpPRB}     Create List       ${vendorElement1}        ${vendorElement2}

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    Set Test Variable       ${MaxSpPRB}
    myKw Activate cb012605 in vendor file     ${MaxSpPRB}

    myKw Main test 4

CB012605-SR-D_009_USC#1_UL_Inter_Intra_L1_subpool_PRB_Pooling_High_GBR_PRB_Demand_ABIP_Q
    [tags]  03  CB012605
    set test variable   &{dlTput}             0=200   1=200   2=200
    set test variable   &{ulTput}             0=150   1=50   2=10
    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${400}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${200}
    Set Test Variable        ${ngbr}        ${True}        # launch traffic ngbr
    Set Test Variable        ${gbr}         ${True}        # launch traffic gbr
    Set Test Variable        ${ul}        ${True}        # launch traffic ul
    Set Test Variable        ${dl}        ${True}        # launch traffic ul
    Set Test Variable    @{ueList}    0        1        2

#    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${1092}


    ${vendorElement1}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     DL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpDl}
    ${vendorElement2}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     UL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpUl}
    ${MaxSpPRB}     Create List       ${vendorElement1}        ${vendorElement2}

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    Set Test Variable       ${MaxSpPRB}
    myKw Activate cb012605 in vendor file     ${MaxSpPRB}

    myKw Main test 4

CB012605-SR-D_009_USC#1_UL_Inter_Intra_L1_subpool_PRB_Pooling_High_GBR_PRB_Demand_ABIP_Q_CNI-127661
    [tags]  03  CB012605
    set test variable   &{dlTput}             0=1200   1=1200   2=1200
    set test variable   &{ulTput}             0=200   1=200   2=200
    set test variable   &{expectedDlTput}     0=100   1=100    2=100
    set test variable   &{expectedUlTput}     0=200   1=200    2=200
    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${2184}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${1092}
    Set Test Variable        ${ngbr}        ${True}        # launch traffic ngbr
    Set Test Variable        ${gbr}         ${True}        # launch traffic gbr
    Set Test Variable        ${ul}        ${False}        # launch traffic ul
    Set Test Variable        ${dl}        ${True}        # launch traffic ul
    Set Test Variable    @{ueList}    0        1        2
    Set Test Variable    ${duration}    300s
    Set Test Variable    ${collectSnap}        ${True}

#    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${1092}

    SetFlagOnSwConfig        0x5809C1        0
    ${vendorElement1}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     DL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpDl}
    ${vendorElement2}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     UL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpUl}
    ${MaxSpPRB}     Create List       ${vendorElement1}        ${vendorElement2}

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    myKw Activate cb012605 in vendor file     ${MaxSpPRB}

    myKw Main test 4bis

CB012605-SR-E_026_USC#10_MaxCellLayerPRBs_with_CB006878
    [tags]  03  CB012605
    set test variable   &{dlTput}             0=1100   1=200   2=200
    Set Test Variable            &{expectedDlTput}     0=0   1=0    2=0
    set test variable   &{ulTput}             0=50   1=250   2=50
    Set Test Variable       ${maxNumLayerPrbL1SpDl}       ${400}
    Set Test Variable       ${maxNumLayerPrbL1SpUl}       ${600}
    Set Test Variable        ${ngbr}        ${True}        # launch traffic ngbr
    Set Test Variable        ${gbr}         ${False}        # launch traffic gbr
    Set Test Variable        ${ul}        ${True}        # launch traffic ul
    Set Test Variable        ${dl}        ${False}        # launch traffic ul
    Set Test Variable    @{ueList}    0        1        2

    ${param_list}    Create List
#    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${1092}


    ${vendorElement1}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     DL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpDl}
    ${vendorElement2}        Create Dictionary
    ...       bbHwVariant     ${bbHwVariant}
    ...       csSize      48      direction     UL
    ...       l1PoolType      ${1PoolType}
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1SpUl}
    ${MaxSpPRB}     Create List       ${vendorElement1}        ${vendorElement2}

    coam.get_current_scf_file       local_dir_path=${testLogPath}     file_name=scf_modif.xml   connection=coam_admin

    Set Test Variable       ${MaxSpPRB}
    Log To Console    Step 1
    coam.create delta
    ${cellsList}       Get Cells list OAM
    FOR     ${CellId}   IN     @{cellsList}
        coam.Append parameter update to delta        ${CellId}    actDynUlResAlloc    false

	END

    myKw Activate cb012605 in vendor file     ${MaxSpPRB}

    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True  connection=coam_admin

    myKw Main test 4

    Rename Files Adding substring        ${testLogPath}    ${syslog[:-4]}    Step1
    Rename Files Adding Substring    ${testLogPath}    traceTTI    Step1

    Log To Console    Step 2
    Run Keyword And Ignore Error             coam.Unblock all cells        rat=NR        connection=coam_admin

    coam.create delta
    FOR     ${CellId}   IN     @{cellsList}
        coam.Append parameter update to delta        ${CellId}    actDynUlResAlloc    true

	END
    FOR   ${ue}   IN   @{ueList}
        Run keyword and ignore error    ue.Stop Data Transfer  dt_name=dt_UE_${ue}_ul
        Run keyword and ignore error    ue.detach_ue    ue_alias=${alias_${ue}}
    END
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True  connection=coam_admin


    myKw Main test 4
    Rename Files Adding substring        ${testLogPath}    ${syslog[:-4]}    Step2
    Rename Files Adding Substring    ${testLogPath}    traceTTI    Step2
