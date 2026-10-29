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
...            CB008379-A_c
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
...         [10.01.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup

*** Variables ***
${ON_FAILURE}=           CONTINUE
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
...                      CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua

*** Test Cases ***
CB008379-A-c_2_TDD ICS without PDU session then PDU sesssion setup and release - no SRB2 release
    [Tags]    A_c-2
    ...    GQC_PLAN:FEATURE:CB008379
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without session, Setup PDU session with nongbr, add gbr, then release session, SRB2 is not released,
    ...  PDU session setup with nongbr + GBR (SRB already present and not set-up)
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 90%
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_RAN_UP_34618
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request - Basic scenario
    ...  HISTORY:
    ...  [10.01.2022] - Test Case created

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE10 and 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE11 and 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE12 and 5QI4

    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE10 and 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE11 and 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE12 and 5QI76

    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE10 and 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE11 and 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE12 and 5QI254

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    # QFI_REL = detach + PDU session release with cause normal
    # QFI_REL_NORMAL =  PDU session release with cause normal
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


    [Teardown]  Cleanup after test A_b-2
