*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == TESTING SPLIT==
...            CB008379-E_b
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Tomasz Pyrek <michal.szymakowski@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [26.04.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup       Run Setup
...  admission_control=${True}
...  gbr_mixed_mode=${False}
...  inter_gnb_intra_freq_ho=${True}
Suite Teardown    Run Keyword When Not In UTE    Restore maxGbrTrafficLimit=90%, maxNumOfGBRBearersSA=10, GFBR=6Mbps and MFBR=9Mbps for all 5QIs

*** Variables ***
${ON_FAILURE}=           CONTINUE
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${SKIP_COUNTERS}=                   ${TRUE}
${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          6s
${wait_until_resources_allocated}   20
${wait_until_resources_released}    20

&{maxGBRTrafficLimit_per_test}      E_b-3=90

&{gfbr_per_test}                    E_b-3=30

&{traffic_per_test}                 E_b-3=30

${E_b_3_addNumOfGBRBearers_high}    50
${E_b_3_addNumOfGBRBearers_low}     5
${E_b_3_addGbrTrafficHo}            0

*** Test Cases ***

CB008379-E-b_3 TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected
    [Tags]    E_b-3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Attach UE with VoNR GBR and run traffic, try to add another UE with VoNR or nonVoNR GBR and - it fails due to high value of parameter
    ...  addNumOfGBRBearers. Perform incoming intra-freq HO from sim-gNB for UE with VoNR GBR and it should be accepted. Set value
    ...  of addNumOfGBRBearers to lower and try again add another UE with VoNR GBR - it should pass then.
    ...  The remaining nonGBR traffic should be lowered or enlarged accordingly
    ...  == Precondition: ==
    ...  - gNB2 and simgNB3 up and running with two SA cells OnAir
    ...  - RLC mode = RLC UM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxDataRateGbrDl = 30 Mb/s
    ...  - NRCELL-1.maxDataRateGbrUl = 30 Mb/s
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 %
    ...  - NRCELL-1.addNumOfGBRBearers = 5
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14841
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [26.04.2022] - Create Test Case

    [Setup]  Prepare test environment E_b-3

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 1 2 3, 5QI2
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 4 5 6, 5QI3
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 7 8 9, 5QI4

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 10 11 12, 5QI71
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 13 14 15, 5QI72
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 16 17 18, 5QI76

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 19 20 21, 5QI128
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 21 22 23, 5QI212
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: 24 25 26, 5QI254

    [Teardown]  Cleanup after test E_b-3

