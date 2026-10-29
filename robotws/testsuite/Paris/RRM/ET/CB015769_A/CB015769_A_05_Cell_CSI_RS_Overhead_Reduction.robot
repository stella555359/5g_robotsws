*** Settings ***
Documentation     Feature: CB015769-A
...               Test Case: [1]CB015769-SR-A_05_Cell_CSI_RS_Overhead_Reduction_FS_1208
...               Test Method: FPB-1518455
...
...               Purpose: Verify Cell CSI-RS overhead reduction behavior on a cell with
...               frame structure semi-static 1208 in following cases:
...               - Case 1: RS4 muted only (cellSpecCsiRsMuteList = RS4)
...               - Case 2: RS2, RS4 muted (cellSpecCsiRsMuteList = RS2,RS4)
...               - Case 3: RS1, RS2, RS4 muted (cellSpecCsiRsMuteList = mute all) # RS1,RS2,RS4
...
...               Test Environment:
...               - Classical BTS, Thor Module: ABIP
...               - TDD 100MHz eCPRI
...               - 6 TDD cells configured
...               - FR1 TDD 8DL4UL with beamforming
...               - Frame Structure: Semi-Static 1208 (1/4)
...
...               Test Automation: Full automation with TTI trace analysis
...
...               Author: Abderrahmane NEZROUK
...               Creation Date: 2026-02-03

Library           OperatingSystem
Library           Collections
Library           String
Library           ./../../../resources/SWENG/python/pytest/GetFiles.py
Library           ./resources/python/analyse_csi_rs_overhead_reduction.py    WITH NAME    csi_rs_analyzer

Resource          ./../../../resources/SWENG/robot/Tools.robot
Resource          ./../../../resources/SWENG/robot/Setup.robot
Resource          ./../../../resources/SWENG/robot/Traffic.robot
Resource          ./../../../resources/SWENG/robot/TtiAnalysisInterface.robot
Resource          ./../../../resources/SWENG/robot/Oam.robot

Resource          ${CURDIR}/resources/robot/CB015769_common_keywords.robot
Resource          ${CURDIR}/resources/robot/CB015769_A_keywords.robot


Suite Setup       CB015769 Suite Setup
Suite Teardown    CB015769 Suite Teardown
Test Setup        CB015769 Test Setup
Test Teardown     CB015769 Test Teardown

*** Variables ***
${GNB_ALIAS}                  gnb_under_test
${SCF_DELTA_PATH}             ${CURDIR}/../config
${BACKUP_LIST}                ${FD_ALL}
${bsr_file}                   BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

${FEATURE_ID}                 CB015769
${TEST_CASE_ID}               CB015769-A-05

# ue
@{SA_UE_ID_List}             1    2    3   4    5    6

# NR BTS Configuration
&{NRBTS_FEATURE_FALGS}       actTddCsiRsOpt=${True}
...                          maxNbMutedTrs=${4}
...                          minCsiRsPeriod=80 ${SPACE}slots

# FRAME_STRUCTURE            1208
&{FRAME_STRUCTURE}           frameStructureType=semiStatic
...                          ulDlDataSlotRatio=1/4
...                          guardPeriodLength=2Symbols

# CSI-RS configuration
${MIN_CSI_RS_PERIOD}              80
${CSI_REPORT_PERIODICITY}         320
${CSI_RS_NUMBER_WITHIN_PERIOD}    1
${DL_MIMO_MODE}                   70

# Cell configuration
&{NRCELL_FEATURE_FALGS}      numOfSubSectors=0sub-sector
# ...                          actCsiRsMultiplexing=${True}
...                          actInfTddFrameMuting=${False}        # feature flag of 5GC002516
...                          actPdcchSharingWithPdsch=${False}    # feature flag of CB008370
...                          actCellCsirsTddOnSsbBf=${False}
...                          actPdschRmCsirsForTracking=${False}   # feature flag of 5GC002538
...                          actPdcchSharingAfterMuting=${False}
...                          actSubTRSRateMatch=${True}
...                          dlMimoMode=8x4 Closed Loop Spatial Multiplexing
# actPdcchSharingAfterMuting to False for better observation of muting effect in TTI trace,
# as PDCCH sharing may cause some CSI-RS to be scheduled in non-muted slots

&{csirsForTracking}        csirsTrackingPeriod=80ms
...                        rbAllocation=25RB

&{periodicCsiAcquisition}    csiReportPeriodicity=${320}
...                          csirsNumberWithinReportPeriod_Set1=${1}

${CELL_1_ID}                 1
${CELL_2_ID}                 2
${CELL_3_ID}                 3
${CELL_1_NAME}               NRCELL-1
${CELL_2_NAME}               NRCELL-2
${CELL_3_NAME}               NRCELL-3
@{CELLS_NAMES}               NRCELL-1    NRCELL-2    NRCELL-3
...                          NRCELL-4    NRCELL-5    NRCELL-6


# CSI-RS muting configurations for each step
@{MUTE_LIST_STEP1}           mute RS4
@{MUTE_LIST_STEP2}           mute RS2    mute RS4
@{MUTE_LIST_STEP3}           mute all
# IF we choose RS1, RS2, RS4 we got this PDL message error: The maximum number of occurrences 2 is exceeded.

# Expected slot offsets (Frame Structure 1208)
# RS4 Only Configuration: Only RS4 symbols are muted
&{RS4_MUTED_SLOTS_0}    muting symbol4 slots=26 27 66 106 107 145 185 186 187 225 226 266 267 305
...                     muting symbol2 slots=${EMPTY}

&{RS4_MUTED_SLOTS_1}    muting symbol4 slots=25 27 65 107 145 185 186 187 225 226 266 267 305
...                     muting symbol2 slots=${EMPTY}

&{RS4_MUTED_SLOTS}    ${0}=&{RS4_MUTED_SLOTS_0}    ${1}=&{RS4_MUTED_SLOTS_1}

# RS2 + RS4 Configuration: Both RS2 and RS4 symbols are muted
&{RS2_RS4_MUTED_SLOTS_0}    muting symbol4 slots=26 27 66 106 107 145 185 186 187 225 226 266 267 305
...                         muting symbol2 slots=67 76 147 156 227 236 265 307 316

&{RS2_RS4_MUTED_SLOTS_1}    muting symbol4 slots=25 27 65 107 145 185 186 187 225 226 266 267 305
...                         muting symbol2 slots=67 76 105 147 156 227 236 265 307 316

&{RS2_RS4_MUTED_SLOTS}    ${0}=&{RS2_RS4_MUTED_SLOTS_0}    ${1}=&{RS2_RS4_MUTED_SLOTS_1}

# RS1 + RS2 + RS4 Configuration: All reference signal symbols are muted
&{RS1_RS2_RS4_MUTED_SLOTS_0}    muting symbol4 slots=26 27 66 106 107 145 185 186 187 225 226 266 267 305
...                             muting symbol2 slots=36 37 67 76 116 117 146 147 156 196 197 227 236 265 276 277 306 307 316

&{RS1_RS2_RS4_MUTED_SLOTS_1}    muting symbol4 slots=25 27 65 107 145 185 186 187 225 226 266 267 305
...                             muting symbol2 slots=36 37 67 76 105 116 117 146 147 156 196 197 227 236 265 276 277 306 307 316

&{RS1_RS2_RS4_MUTED_SLOTS}    ${0}=&{RS1_RS2_RS4_MUTED_SLOTS_0}    ${1}=&{RS1_RS2_RS4_MUTED_SLOTS_1}

# TTI trace events
@{TTI_EVENTS}                csiRsSchedData    dlFdSchedData    dlAllocatedPooledResourcesData

# Traffic configuration
${TRAFFIC_DURATION}          10
${TRAFFIC_TYPE}              DL_UDP_FULL_BUFFER

# Log paths
${LOG_PATH}                   ${EMPTY}
${TTI_TRACE_PATH}             ${EMPTY}

*** Test Cases ***
[1][1.0] CB015769-SR-A_05_Cell_CSI_RS_Overhead_Reduction_FS_1208
    STEP01_Verify_Cell_CSI_RS_Overhead_Reduction_RS4_Muted_Only
    STEP02_Verify_Cell_CSI_RS_Overhead_Reduction_RS2_RS4_Muted
    STEP03_Verify_Cell_CSI_RS_Overhead_Reduction_All_Muted
