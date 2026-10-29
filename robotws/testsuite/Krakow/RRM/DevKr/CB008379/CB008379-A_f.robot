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
...         CB008379-A_f
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [03.02.2022] - Create Test Suite
...         [18.01.2023] - Switch to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...         [25.01.2023] - Review closed

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup

*** Variables ***
${ON_FAILURE}=           CONTINUE
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008379-A-f_1 Successful modification of GBR is sent while only 1 GBR is established
    [Tags]    A_f-1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  nonGBR + Only 1 GBR is established during ICS, then modification of DL and/or UL GFBR
    ...  is sent in PDUSessionResourceModify and is successful
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 %
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_UP_34618
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP
    ...  == CONTACTS ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - USCB008379-A/B#B2: Successful setup of GBR Bearer with Initial Context Setup Request - Basic scenario
    ...  - USCB008379-A/B#B6: Successful Modification of GFBR initiated by AMF for an existing GBR QoS Flow
    ...  == HISTORY ==
    ...  [14.02.2022] - created TC
    ...  [21.02.2023] - Review closed

    start collecting counters
    Log to console      1/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE1 and 5QI2
    Log to console      2/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE2 and 5QI3
    Log to console      3/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE3 and 5QI4

    Log to console      4/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE1 and 5QI71
    Log to console      5/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE2 and 5QI72
    Log to console      6/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE3 and 5QI76

    Log to console      7/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE1 and 5QI128
    Log to console      8/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE2 and 5QI212
    Log to console      9/9
    Run Keyword and Continue on Failure
    ...    Repeat Successful modification of GBR is sent while only 1 GBR is established for UE3 and 5QI254

    Wait until aggreagted PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]    Cleanup after test A_f-1
