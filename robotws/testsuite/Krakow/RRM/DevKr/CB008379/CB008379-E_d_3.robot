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
...            CB008379-E_d
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Tomasz Pyrek <michal.szymakowski@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
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
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup       Run Setup
...  admission_control=${True}
...  gbr_mixed_mode=${False}
...  discard_timer=${True}
Suite Teardown    Run Keyword When Not In UTE    Restore maxGbrTrafficLimit=90%, maxNumOfGBRBearersSA=10, GFBR=6Mbps and MFBR=9Mbps for all 5QIs

*** Variables ***
${ON_FAILURE}=           CONTINUE
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${TOPOLOGY_TO_LUA}[CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD]
${SKIP_COUNTERS}=                   ${TRUE}
${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          6s
${wait_until_resources_allocated}   20
${wait_until_resources_released}    20

${E_d_3_traffic_nonGBR_DL}          120     #Initial traffic value for nonGBR
${E_d_3_traffic_nonGBR_DL_lower}    95      #NonGBR traffic is lower after run 25 GBR traffic with 30 GFBR
${E_d_3_traffic_nonGBR_DL_higher}   115     #NonGBR traffic is higher after change GBFR to lower from 30 to 5
${E_d_3_traffic_GBR_DL}             25      #Initial traffic value for GBR
${E_d_3_traffic_GBR_DL_lower}       4       #GBR traffic is lower after change GBFR to lower from 30 to 5
${E_d_3_traffic_GBR_DL_higher}      25      #GBR traffic is higher after change GBFR back to higher from 5 to 25

${E_d_3_traffic_nonGBR_UL}          60      #Initial traffic value for nonGBR
${E_d_3_traffic_nonGBR_UL_lower}    20      #NonGBR traffic is lower after run 25 GBR traffic with 30 GFBR
${E_d_3_traffic_nonGBR_UL_higher}   60      #NonGBR traffic is higher after change GBFR to lower from 30 to 5
${E_d_3_traffic_GBR_UL}             25      #Initial traffic value for GBR
${E_d_3_traffic_GBR_UL_lower}       10      #GBR traffic is lower after change GBFR to lower from 30 to 5
${E_d_3_traffic_GBR_UL_higher}      25      #GBR traffic is higher after change GBFR back to higher from 5 to 25

${gfbr_lower}                       5       #Set lower GFBR from 30 to 5 Mbps
${gfbr_higher}                      25      #Set higher GFBR from 5 to 25 Mbps

&{maxGBRTrafficLimit_per_test}      E_d-3=90    # nonGBR FDD DL UL

&{gfbr_per_test}                    E_d-3=30

&{traffic_per_test}                 E_d-3=30

*** Test Cases ***

CB008379-E-d_3 Single GBR established DL and_or UL GFBR modification is sent and non-GBR traffic changes accordingly
    [Tags]    E_d-3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Several nonGBR UEs are occupying DL or UL bandwidth and new UE tries to modify GFBR for QoS Flow
    ...  with 5QI 2 or 3 or 4 or 5QI71,72,76 or 5QI128..254 during PDU Session Modification procedure.
    ...  After the modification UE with GBR traffic and also UE with nonGBR traffic are allowed lower
    ...  or higher their traffic. The remaining nonGBR traffic should be lowered or enlarged accordingly
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxDataRateGbrDl = 30 Mb/s
    ...  - NRCELL-1.maxDataRateGbrUl = 30 Mb/s
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 % (~ 115Mb/s DL, ~ 18Mb/s UL)
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_RAN_USR_RRM_14902; 5G_RAN_USR_RRM_14809
    ...  == REQUIRED LOGS ==
    ...  - NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...    - USCB008379-E#AC3: GBR Radio Admission Control with GBR modification
    ...  HISTORY:
    ...  [26.04.2022] - Create Test Case

    [Setup]  Set GBR admission control parameters for E_d-3

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 1 2, 5QI2
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 3 4, 5QI3
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 5 6, 5QI4

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 7 8, 5QI71
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 9 10, 5QI72
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 11 12, 5QI76

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 13 14, 5QI128
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 15 16, 5QI212
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: 17 18, 5QI254

    [Teardown]  Detach and kill UEs from 1 to 18
