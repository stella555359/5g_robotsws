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
...         CB008379-D_d
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
...         [17.02.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD

Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=                            ${CURDIR}/config/SA_TDD_1c_1gNBsim_with_lte_cell.lua

*** Test Cases ***
CB008379-D-d_1 Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of this test is to perform successful inter-RAT B2 based handover from 5G to LTE
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254
    ...
    ...  == Precondition: ==
    ...     - gNB2 up and running with one SA cell OnAir
    ...     - measurements A1, A2 and B2 are configured on gNB
    ...     - NRCELL-1.actNonVoNRGbrService = true
    ...     - NRCELL-1.actVoNR = true
    ...     - NRCELL-1.actCDrx = false
    ...     - NRBTS-1.actInterRatHoSA = true
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    - 5G_RAN_CP_12360506; 5G_CP_MM_2997; CB_FIM_4084
    ...
    ...  == REQUIRED LOGS ==
    ...    - NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...     - USCB008379-D1#B2: Successful Inter-Rat handover to eNB for UEs configured with GBR bearers based on B2 measurements
    ...
    ...  HISTORY:
    ...     [17.02.2022] - Create Test Suite
    [Tags]    D_d-1
    [Setup]    Prepare test environment D-d

    Run Keyword And Continue On Failure  Repeat UE1: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI2
    Run Keyword And Continue On Failure  Repeat UE2: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI3
    Run Keyword And Continue On Failure  Repeat UE3: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI4

    Run Keyword And Continue On Failure  Repeat UE4: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI71
    Run Keyword And Continue On Failure  Repeat UE5: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI72
    Run Keyword And Continue On Failure  Repeat UE6: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI76

    Run Keyword And Continue On Failure  Repeat UE7: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI128
    Run Keyword And Continue On Failure  Repeat UE8: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI212
    Run Keyword And Continue On Failure  Repeat UE9: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI254


CB008379-D-d_2 Failed inter-RAT B2 based handover from 5G to LTE with GBR bearer
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of this test is to perform unsuccessful inter-RAT B2 based handover from 5G to LTE
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254
    ...
    ...  == Precondition: ==
    ...     - gNB2 up and running with one SA cell OnAir
    ...     - measurements A1, A2 and B2 are configured on gNB
    ...     - NRCELL-1.actNonVoNRGbrService = true
    ...     - NRCELL-1.actVoNR = true
    ...     - NRCELL-1.actCDrx = false
    ...     - NRBTS-1.actInterRatHoSA = true
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    - 5G_RAN_CP_12360506; 5G_CP_MM_2997
    ...
    ...  == REQUIRED LOGS ==
    ...    - NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...     - USCB008379-D1#B2: Successful Inter-Rat handover to eNB for UEs configured with GBR bearers based on B2 measurements
    ...         - Alternate Scenario: All Inter-RAT HO Scenarios based on 5GC000707 shall be tested for UE configured with GBR bearers
    ...
    ...  HISTORY:
    ...     [17.02.2022] - Create Test Suite
    [Tags]    D_d-2
    [Setup]    Prepare test environment D-d

    Run Keyword And Continue On Failure  Repeat UE1: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI2
    Run Keyword And Continue On Failure  Repeat UE2: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI3
    Run Keyword And Continue On Failure  Repeat UE3: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI4

    Run Keyword And Continue On Failure  Repeat UE4: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI71
    Run Keyword And Continue On Failure  Repeat UE5: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI72
    Run Keyword And Continue On Failure  Repeat UE6: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI76

    Run Keyword And Continue On Failure  Repeat UE7: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI128
    Run Keyword And Continue On Failure  Repeat UE8: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI212
    Run Keyword And Continue On Failure  Repeat UE9: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI254
