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
...         [31.03.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup       Run Setup     admission_control=${True}
*** Variables ***
${LUA_CFG}=                            ${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
${FAIL_TIMEOUT}=        2

${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          3s

${SKIP_COUNTERS}=        ${FALSE}

&{maxGBRTrafficLimit_per_test}      E_a-17=90  # TDD DL/ UL
&{gfbr_per_test}                    E_a-17=12
&{traffic_per_test}                 E_a-17=20


*** Test Cases ***

CB008379-E-a_17_FDD GBR load reporting-ICS with GBR rejected by by too high GFBR and AMF GFBR value change-PM counters
    [Tags]    E_a-17
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform unsuccessful ICS. ICS procedure should be rejected
    ...     due to too high requested GFBR value for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254.
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRDRB.maxDataRateGbrDl = 10 Mb/s
    ...  - NRDRB.maxDataRateGbrUl = 10 Mb/s
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 % (~ 108Mb/s)
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_CP_IF_NTW_4978
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  HISTORY:
    ...  [31.03.2022] - Create Test Case

    [Setup]  Set GBR admission control parameters for E_a-17

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI2
    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE2 and 5QI3
    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE3 and 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0

    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI71
    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE2 and 5QI72
    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE3 and 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0

    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE1 and 5QI128
    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE2 and 5QI212
    Run Keyword And Continue On Failure
    ...   Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE3 and 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
