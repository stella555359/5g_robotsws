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
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [10.01.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup      admission_control=${True}       fdm_scheduling_for_load_reporting=${True}

*** Variables ***
&{maxGBRTrafficLimit_per_test}      E_a-14=25
&{gfbr_per_test}                    E_a-14=6
&{traffic_per_test}                 E_a-14=5
${wait_until_kw_succ_rep}           1x
${wait_until_kw_succ_time}          3s
${wait_until_resources_allocated}   20
${wait_until_resources_released}    20


${SKIP_COUNTERS}=        ${FALSE}
${PMQAP_INTERVAL}=       5min
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua

*** Test Cases ***
CB008379-E-a_14_TDD GBR load reporting-ICS with GBR rejected by maxNumOfGBRBearersSA-PM counters
    [Tags]    E-a_14    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    The purpose of this test is to show that ICS with GBR 5QI can be rejected by maxNumOfGBRBearersSA
    ...    for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254. Counters are verified.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_IF_NTW_4978
    ...
    ...  == REQUIRED LOGS ==
    ...  - NR-RRC, NGAP, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-67899 - USCB008379-E#AC1: GBR Load reporting for GBR Radio Admission Control
    ...  == HISTORY ==
    ...

    [Setup]  Set GBR admission control parameters for E_a-14

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    ${background_ue_5QI}    Create dictionary
    ...                                 1=2
    ...                                 2=4
    ...                                 3=71
    ...                                 4=128
    Log to console      1/10 Checking 5QI2
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 10 with 5QI2
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console      2/10 Checking 5QI3
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 11 with 5QI3
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console      3/10 Checking 5QI3
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 12 with 5QI4
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0

    ${background_ue_5QI}    Create dictionary
    ...                                 1=3
    ...                                 2=72
    ...                                 3=76
    ...                                 4=212
    Log to console      4/10 Checking 5QI71
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 13 with 5QI71
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console      5/10 Checking 5QI72
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 14 with 5QI72
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console      6/10 Checking 5QI76
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 15 with 5QI76
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console      7/10 Checking 5QI128
    ${background_ue_5QI}    Create dictionary
    ...                                 1=2
    ...                                 2=3
    ...                                 3=4
    ...                                 4=254
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 16 with 5QI128
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console      8/10 Checking 5QI212
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 17 with 5QI212
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Log to console      9/10 Checking 5QI254
    Run Keyword And Continue On Failure
    ...     Repeat GBR load reporting (${background_ue_5QI}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: 18 with 5QI254
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0


    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 24, QFI_SETUP_SUCC 21, QFI_REL 21, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 15, QFI_SETUP_SUCC 12, QFI_REL 12, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 15, QFI_SETUP_SUCC 12, QFI_REL 12, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...     Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 54, QFI_SETUP_SUCC 45, QFI_REL 45, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


    [Teardown]  Detach and kill UEs from 1 to 18
