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
...         [11.02.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup       Run Setup
...  admission_control=${True}
...  gbr_mixed_mode=${False}
Suite Teardown    Run Keyword When Not In UTE    Restore maxGbrTrafficLimit=90%, maxNumOfGBRBearersSA=10, GFBR=6Mbps and MFBR=9Mbps for all 5QIs

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
${SKIP_COUNTERS}=                   ${FALSE}
${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          3s
${wait_until_resources_allocated}   20
${wait_until_resources_released}    40

${E_a_7_traffic_nonGBR_DL}          120
${E_a_7_traffic_GBR_DL}             25
${E_a_7_traffic_nonGBR_UL}          65
${E_a_7_traffic_GBR_UL}             25

&{maxGBRTrafficLimit_per_test}      E_a-1=30    # FDD DL
...                                 E_a-3=20    # FDD UL
...                                 E_a-7=90    # nonGBR FDD DL UL
...                                 E_a-8=30    # FDD DL ICS
...                                 E_a-10=30   # FDD DL pdu sm a/d

&{gfbr_per_test}                    E_a-1=6
...                                 E_a-3=10
...                                 E_a-7=30
...                                 E_a-8=6
...                                 E_a-10=6

&{traffic_per_test}                 E_a-1=5
...                                 E_a-3=5
...                                 E_a-7=30
...                                 E_a-8=5
...                                 E_a-10=5

*** Test Cases ***

CB008379-E-a_01_FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released-PM counters
    [Tags]    E_a-1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Multiple GBR UEs occupying bandwidth (with same or different QFIs), not enough capacity in DL to admin
    ...  new QFI (UL is fine), rejected, some UEs released, request comes and it is accepted + check PMQAP Setup
    ...  Att/Succ counters for failure case from B_c item
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 30 %
    ...  - NRDRB-XX.maxDataRateGbrDl = 6 Mb/s
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
    ...  [11.02.2022] - Create Test Case

    [Setup]  Set GBR admission control parameters for E_a-1

    Log to console    1/11 Start collecting counters
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 1 2 3 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 4 5 6 5QI3
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 7 8 9 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 10 11 12 5QI71
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 13 14 15 5QI72
    	#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 16 17 18 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 19 20 21 5QI128
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 22 23 24 5QI212
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: 25 26 27 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
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

    [Teardown]  Detach and kill UEs from 1 to 27

CB008379-E-a_03_FDD GBR load reporting-too low UL capacity during Qos Flow Addition-background UEs released
    [Tags]    E_a-3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Multiple GBR UEs occupying bandwidth (with same or different QFIs), not enough capacity in UL to admin
    ...  new QFI (DL is fine), rejected,
    ...  some UEs released, request comes and it is accepted
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 10 %
    ...  - NRDRB-XX.maxDataRateGbrDl = 6 Mb/s
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
    ...  [11.02.2022] - Create Test Case

    [Setup]  Set GBR admission control parameters for E_a-3

    Log to console    1/11 Start collecting counters
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 1 2 3 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 4 5 6 5QI3
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 7 8 9 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 10 11 12 5QI71
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 13 14 15 5QI72
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 16 17 18 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 19 20 21 5QI128
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 22 23 24 5QI212
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: 25 26 27 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
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

    [Teardown]  Detach and kill UEs from 1 to 27

CB008379-E-a_07_FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success
    [Tags]    E_a-7
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Multiple GBR Ues occupying bandwidth but only with nonGBR, enough capacity in DL to admin new QFI,
    ...  request comes and it is accepted
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 % (~ 115Mb/s DL, ~ 18Mb/s UL)
    ...  - NRDRB-XX.maxDataRateGbrDl = 30 Mb/s
    ...  - NRDRB-XX.maxDataRateGbrUl = 30 Mb/s
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14841; 5G_RAN_USR_RRM_14783
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [11.02.2022] - Create Test Case

    [Setup]  Set GBR admission control parameters for E_a-7

    Log to console    1/11 Start collecting counters
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 1, 2 and 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 3, 4 and 5QI3
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 5, 6 and 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 7, 8 and 5QI71
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 9, 10 and 5QI72
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 11, 12 and 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 13, 14 and 5QI128
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 15, 16 and 5QI212
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: 17, 18 and 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 4

    Log to console    11/11 Checking counters
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 45, QFI_SETUP_SUCC 45, QFI_REL 45, QFI_REL_NORMAL 36
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Detach and kill UEs from 1 to 18

CB008379-E-a_08_FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released-PM counters
    [Tags]    E_a-8
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Multiple GBR UEs occupying bandwidth (with same or different QFIs), not enough capacity in DL to admin
    ...  new QFI (UL is fine) during ICS, rejected, some UEs released, request comes and it is accepted + check
    ...  PMQAP Setup Att/Succ counters for failure case from B_c item
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 10 % (~ 10Mb/s)
    ...  - NRDRB-XX.maxDataRateGbrDl = 6 Mb/s
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
    ...  [11.02.2022] - Create Test Case

    [Setup]  Set GBR admission control parameters for E_a-8
    Omit when SKIP_COUNTERS present
    ...   start collecting counters

    Log to console    1/11 Start collecting counters
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 1 2 3 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 4 5 6 5QI3
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 7 8 9 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 10 11 12 5QI71
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 13 14 15 5QI72
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 16 17 18 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 19 20 21 5QI128
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 22 23 24 5QI212
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: 25 26 27 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Log to console    11/11 Checking counters
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 27, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Detach and kill UEs from 1 to 27

CB008379-E-a_10_FDD GBR load reporting-too low DL capacity during via a-d session modification and background UEs have GBR released
    [Tags]    E_a-10
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Multiple GBR UEs occupying DL bandwidth (with same or different QFIs), not enough capacity during
    ...  PDU session modification with simultaneous GBR QoS addition and deletion, rejected, background UEs
    ...  have their GBR released also via PDU session modification with simultaneous GBR QoS addition and
    ...  deletion, request comes and it is accepted.
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 5 % (~ 6Mb/s)
    ...  - NRDRB-XX.maxDataRateGbrDl = 6 Mb/s
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
    ...  [11.02.2022] - Create Test Case

    [Setup]  Set GBR admission control parameters for E_a-10

    Log to console    1/11 Start collecting counters
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 1 2 3 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 4 5 6 5QI3
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 7 8 9 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 10 11 12 5QI71
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 13 14 15 5QI72
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 16 17 18 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 19 20 21 5QI128
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 22 23 24 5QI212
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: 25 26 27 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 4, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 5, QFI_REL_NORMAL 0

    Log to console    11/11 Checking counters
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 9, QFI_REL 12, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 9, QFI_REL 12, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 9, QFI_REL 12, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 27, QFI_SETUP_SUCC 27, QFI_REL 45, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Detach and kill UEs from 1 to 27

CB008379-E-a_13_FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA-PM counters
    [Tags]    E_a-13
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Multiple GBR UEs (with same or different QFIs), enough capacity in DL to admin new QFI, PDU setup
    ...  comes, rejected due to maxNumOfGBRBearersSA, change maxNumOfGBRBearersSA, request comes and it is
    ...  accepted + check PMQAP Setup Att/Succ counters for failure case from B_c item
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 1
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14762; 5G_RAN_USR_RRM_14841
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request - Basic scenario
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [11.02.2022] - Create Test Case
    Omit when SKIP_COUNTERS present
    ...    start collecting counters

    Log to console    1/11 Start collecting counters
    Omit when SKIP_COUNTERS present
    ...  start collecting counters

    Log to console    2/11 Checking 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 1, 2 and 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    3/11 Checking 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 3, 4 and 5QI3
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    4/11 Checking 5QI4
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 5, 6 and 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Log to console    5/11 Checking 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 7, 8 and 5QI71
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    6/11 Checking 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 9, 10 and 5QI72
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    7/11 Checking 5QI76
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 11, 12 and 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Log to console    8/11 Checking 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 13, 14 and 5QI128
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    9/11 Checking 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 15, 16 and 5QI212
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Log to console    10/11 Checking 5QI254
    Run Keyword And Continue On Failure
    ...  Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: 17, 18 and 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Log to console    11/11 Checking counters
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Detach and kill UEs from 1 to 18
