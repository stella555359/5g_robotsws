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
...            CB008379-A_b
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
...         [10.01.2022] - Create Test Suite
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
CB008379-A-b_1 ICS with PDU session with nonGBR then modify or add PDU session with nonGBR and GBR -maxNumOfGBRBearersSA
    [Tags]    A_b-1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This testcase shows that GBR QoS flows can be added by PDU session modification or by PDU session setup:
    ...  1. ICS with PDU session with nongbr, then PDU session modification with single GBR (SRB setup done
    ...  when first Pdu session added) with NRCELL/maxNumOfGBRBearersSA check.
    ...  2. ICS with PDU session with nongbr only, add second pdu session with second nongbr + gbr.
    ...  Testcases 1. and 2. are run alternately
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 1
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 90%
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_CP_IF_NTW_1188; 5G_L2_IF_560; 5G_RAN_USR_RRM_14766;
    ...     CB_FIM_21279; CB_FIM_4079; CB_FIM_4080
    ...  == REQUIRED LOGS ==
    ...  - NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request - Basic scenario
    ...  == HISTORY ==
    ...  [10.01.2022] - Create Test Case
    ...  [25.01.2023] - Review closed

    [Setup]  Prepare test environment A_b-1
    start collecting counters
    Log to console      1/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE1, UE2 and 5QI2
    Log to console      2/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE7 and 5QI2
    Log to console      3/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE3, UE4 and 5QI3
    Log to console      4/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE8 and 5QI3
    Log to console      5/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE5, UE6 and 5QI4
    Log to console      6/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE9 and 5QI4

    Log to console      7/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE1, UE2 and 5QI71
    Log to console      8/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE7 and 5QI71
    Log to console      9/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE3, UE4 and 5QI72
    Log to console      10/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE8 and 5QI72
    Log to console      11/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE5, UE6 and 5QI76
    Log to console      12/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE9 and 5QI76

    Log to console      13/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE1, UE2 and 5QI128
    Log to console      14/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE7 and 5QI128
    Log to console      15/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE3, UE4 and 5QI212
    Log to console      16/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE8 and 5QI212
    Log to console      17/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE5, UE6 and 5QI254
    Log to console      18/18
    Run Keyword And Continue On Failure
    ...    Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE9 and 5QI254


    Wait until aggreagted PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    # QFI_REL - ICS Fail not counting as rel counter
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 36, QFI_SETUP_SUCC 27, QFI_REL 27, QFI_REL_NORMAL 0
    #  QFI_SETUP_ATT = 18 + 6 for failed ICS
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


    [Teardown]  Cleanup after test A_b-1


CB008379-A-b_2_FDD ICS without PDU session then PDU sesssion setup and release - no SRB2 release
    [Tags]    A_b-2    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without session, Setup PDU session with nongbr, add gbr, then release session, SRB2 is not released,
    ...  PDU session setup with nongbr + GBR (SRB already present and not set-up)
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 90%
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_L2_IF_560
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request - Basic scenario
    ...  == HISTORY ==
    ...  [10.01.2022] - Test Case created
    ...  [25.01.2023] - Review closed


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

CB008379-A-b_3_FDD Reactivation of GBR session in ICS with UE capability
    [Tags]    A_b-3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without session, add nongbr + gbr in single PDU session, go to idle, reactivate session, gbr session in ICS,
    ...  with ue capability with NRCELL/maxNumOfGBRBearersSA check
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 90%
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_L2_IF_560
    ...  == REQUIRED LOGS ==
    ...  - NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request - Basic scenario
    ...  == HISTORY ==
    ...  [27.01.2022] - initial test creation
    ...  [25.01.2023] - Review closed

    [Setup]  Prepare test environment A_b-3
    start collecting counters

    Log to console      1/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE13 and 5QI2
    Log to console      2/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE14 and 5QI3
    Log to console      3/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE15 and 5QI4

    Log to console      4/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE13 and 5QI71
    Log to console      5/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE14 and 5QI72
    Log to console      6/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE15 and 5QI76

    Log to console      7/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE13 and 5QI128
    Log to console      8/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE14 and 5QI212
    Log to console      9/9
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE15 and 5QI254

    Wait until aggreagted PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    # QFI_REL_NORMAL due to release by user-inactivity
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    # QFI_REL_NORMAL due to release by user-inactivity
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


    [Teardown]  Cleanup after test A_b-3

CB008379-A-b_4_FDD Reactivation of GBR session in ICS without UE capability
    [Tags]    A_b-4    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without session, add nongbr + gbr in single PDU session, go to idle, reactivate session,
    ...  gbr session in ICS, without ue capbility
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 90%
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_L2_IF_560
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request - Basic scenario
    ...  == HISTORY ==
    ...  [10.01.2022] - Test Case created
    ...  [25.01.2023] - Review closed

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE16 and 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE17 and 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE18 and 5QI4

    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE16 and 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE17 and 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE18 and 5QI76

    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE16 and 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE17 and 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat Reactivation of GBR session in ICS without UE capability for UE18 and 5QI254

    Wait until PM counters file is ready and saved
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

    [Teardown]  Cleanup after test A_b-4
