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
...            CB008379-A_g
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
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

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua


${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          3s

*** Test Cases ***

CB008379-A-g_1 Feature flag interaction with GBR addition
    [Tags]    A_g-1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS with nonGBR, NRBTS/NRCELL.actNonVoNRGBRService is disabled, try to establish GBR via modification, it fails.
    ...  Enable flag, retry GBR addition and it succeeds. Disable NRBTS/NRCELL.actNonVoNRGBRService.
    ...  Add second PDU session with nonGBR + GBR, addition fails, change flag again, addition of new session is successful.
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14767
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-A/B#EC2: Unsuccessful setup of GBR bearer due to feature not being activated
    ...  HISTORY:
    ...  [11.02.2022] - Create Test Case

    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE1 and 5QI2 ViNR
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE2 and 5QI3
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE3 and 5QI4

    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE4 and 5QI71
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE5 and 5QI72
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE6 and 5QI76

    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE7 and 5QI128
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE8 and 5QI212
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE9 and 5QI254

    [Teardown]  Cleanup after test A_g-1

CB008379-A-g_2 Feature flag interaction with attach with GBR
    [Tags]    A_g-2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS with nonGBR, add GBR, NRBTS/NRCELL.actNonVoNRGBRService is disbaled, go to idle, try to attach with nonGBR + GBR, it fails.
    ...  Enable flag, retry attach with nonGBR + GBR and it succeeds.
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14767
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-A/B#EC2: Unsuccessful setup of GBR bearer due to feature not being activated
    ...  HISTORY:
    ...  [11.02.2022] - Create Test Case

    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE11 and 5QI2 ViNR
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE12 and 5QI3
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE13 and 5QI4

    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE14 and 5QI71
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE15 and 5QI72
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE16 and 5QI76

    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE17 and 5QI128
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE18 and 5QI212
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE19 and 5QI254

    [Teardown]  Cleanup after test A_g-2
