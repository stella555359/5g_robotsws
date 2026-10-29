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
...         [18.01.2023] - Switch to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup

*** Variables ***
${ON_FAILURE}=           CONTINUE
${SKIP_COUNTERS}=        ${FALSE}
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua

${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          3s

*** Test Cases ***
CB008379-A-g Feature flag interaction with attach and GBR addition
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
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_CP_ARC_ALG_5047; 5G_RAN_USR_RRM_14841; 5G_CP_IF_NTW_4978; CB_FIM_4088; CB_FIM_4098
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  USCB008379-A/B#EC2: Unsuccessful setup of GBR bearer due to feature not being activated
    ...  HISTORY:
    ...  [11.02.2022] - Create Test Case

    Omit when SKIP_COUNTERS present     start collecting counters
    Log to console      1/11 Checking 5QI2
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE11 and 5QI2 ViNR
    Log to console      2/11 Checking 5QI2
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE1 and 5QI2 ViNR
    Log to console      3/11 Checking 5QI3
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE2 and 5QI3
    Log to console      4/11 Checking 5QI4
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE13 and 5QI4

    Log to console      5/11 Checking 5QI71
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE4 and 5QI71
    Log to console      6/11 Checking 5QI72
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE15 and 5QI72
    Log to console      7/11 Checking 5QI76
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE6 and 5QI76


    Log to console      8/11 Checking 5QI128
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE17 and 5QI128
    Log to console      9/11 Checking 5QI128
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE7 and 5QI128
    Log to console      10/11 Checking 5QI212
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with attach with GBR for UE18 and 5QI212
    Log to console      11/11 Checking 5QI254
    Run Keyword And Continue On Failure  Repeat Feature flag interaction with GBR addition for UE9 and 5QI254

    Omit when SKIP_COUNTERS present
    ...     Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...     Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...     Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...     Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 10, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...     Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 12, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...     Run Keyword And Continue On Failure
    ...     Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 22, QFI_SETUP_SUCC 17, QFI_REL 17, QFI_REL_NORMAL 0
    # QFI_SETUP_ATT: 5*2+6*2 = 22
    Omit when SKIP_COUNTERS present
    ...     Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Cleanup after test A_g-1
