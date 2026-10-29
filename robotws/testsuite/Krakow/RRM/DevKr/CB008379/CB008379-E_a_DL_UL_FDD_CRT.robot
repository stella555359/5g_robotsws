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
...            CB008379-E_a
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
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
...         [11.02.2022] - Create Test Suite
...         [18.01.2023] - Switch to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...         [25.01.2023] - Review closed

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup       Run Setup
...  admission_control=${True}
...  gbr_mixed_mode=${True}
...  fdm_scheduling_for_load_reporting=${True}
...  reset_tl=${True}
#Suite Teardown    Run Keyword When Not In UTE    Restore maxGbrTrafficLimit=90%, maxNumOfGBRBearersSA=10, GFBR=6Mbps and MFBR=9Mbps for all 5QIs

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua

${SKIP_COUNTERS}=                   ${TRUE}
${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          3s

&{wait_until_resources_allocated}        DL=5
...                                      UL=5
&{wait_until_resources_released}         DL=10
...                                      UL=10
${maxGBRTrafficLimit}               30  # TDD DL,UL

&{gfbr_direction}                             DL=25
...                                           UL=10

&{low_gfbr_direction}                         DL=5
...                                           UL=5

&{bg_gfbr_direction}                          DL=10
...                                           UL=10

&{traffic_direction}                          DL=25
...                                           UL=20

&{bg_traffic_direction}                       DL=10
...                                           UL=10

*** Test Cases ***
CB008379-E-a_FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released-PM counters
#CB008379-E-a_02_FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released-PM counters
    [Tags]    E_a-2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Multiple GBR UEs occupying bandwidth (with same or different QFIs), not enough capacity in DL to admin new QFI (UL is fine), rejected,
    ...  some UEs released, request comes and it is accepted + check PMQAP Setup Att/Succ counters for failure case from B_c item
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxDataRateGbrDl = 25 Mb/s
    ...  - NRCELL-1.maxGBRTrafficLimit = 12 %
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14841
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [11.02.2022] - Create Test Case
    ...  [18.02.2023] - Review closed

    [Setup]     Configure  {'MOC': 'NRCELL', 'ID': '1', 'actGBRAdmissionControl': 'GBRService', 'maxGbrTrafficLimit': '${maxGBRTrafficLimit}'}

    Log to console    1/11 Start collecting counters
    Omit when SKIP_COUNTERS present
    ...  start collecting counters
    Log to console    2/11 Checking 5QI2 DL
    Set high parameters for DL for background UEs
    Set low parameters for UL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 1,2,3,4 5QI2
    Teardown repeat keyword if failed
    Log to console    3/11 Checking 5QI2 UL
    Set high parameters for UL for background UEs
    Set low parameters for DL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 1,2,5,6 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Teardown repeat keyword if failed
    Log to console    4/11 Checking 5QI4 DL
    Set high parameters for DL for background UEs
    Set low parameters for UL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 1,2,11,12 5QI4
#    ...   Repeat TDD GBR load reporting-too low DL cap during ICS with GBR-background Ues released for UEs: 1,2,11,12 5QI4
    Teardown repeat keyword if failed
    Log to console    5/11 Checking 5QI4 UL
    Set high parameters for UL for background UEs
    Set low parameters for DL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 1,2,13,14 5QI4
#    ...   Repeat TDD GBR load reporting-too low UL cap during ICS with GBR-background Ues released for UEs: 1,2,13,14 5QI4
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Teardown repeat keyword if failed
    Log to console    6/11 Checking 5QI71 DL
    Set high parameters for DL for background UEs
    Set low parameters for UL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 1,2,15,16 5QI71
    Teardown repeat keyword if failed
    Log to console    7/11 Checking 5QI71 UL
    Set high parameters for UL for background UEs
    Set low parameters for DL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 1,2,17,18 5QI71
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Teardown repeat keyword if failed
    Log to console    8/11 Checking 5QI128 DL
    Set high parameters for DL for background UEs
    Set low parameters for UL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 1,2,27,28 5QI128
    Teardown repeat keyword if failed
    Log to console    9/11 Checking 5QI128 UL
    Set high parameters for UL for background UEs
    Set low parameters for DL
    Run Keyword And Continue On Failure
    ...  Repeat TDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 1,2,29,30 5QI128
    Teardown repeat keyword if failed
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0

    Log to console    11/11 Checking counters
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 27, QFI_SETUP_SUCC 27, QFI_REL 27, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Detach and kill UEs from 1 to 40
