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
...            CB008379-C_b
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
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
...         [09.02.2022] - Create Test Suite
...         [11.02.2022] - Execution done for all 5QIs including -B part
...         [14.03.2022] - All TCs passed after AP correction (4.0.20075) for PR637817

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Keywords
...  Run Setup
...  AND  Set UE IDLE timers on gNB: drbInactivityTimerSA=600 srbInactivityTimerSA=600

Test Teardown  Run Test Teardown

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008379-C-b_1 Modification of PDU Session with addition of GBR VoNR and release non VoNR GBR
    [Tags]    C_b-1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS w/ session (default nonGBR + GBR), start traffic GBR, add VoNR, start traffic VoNR, verify
    ...  traffic GBR, delete GBR, verify traffic VoNR
    ...  == Precondition ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIK + ABIL) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14806, 5G_RAN_USR_RRM_14808, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-C1 Multiple UEs with single additional GBR bearer /Voice+additional GBR

    Wait until PM counters file is ready and saved

    Run Keyword And Continue On Failure    Repeat UE1 PDU1: ICS with PDU session with GBR [2], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE2 PDU1: ICS with PDU session with GBR [3], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE3 PDU1: ICS with PDU session with GBR [4], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE4 PDU1: ICS with PDU session with GBR [71], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE5 PDU1: ICS with PDU session with GBR [72], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE6 PDU1: ICS with PDU session with GBR [76], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE7 PDU1: ICS with PDU session with GBR [128], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE8 PDU1: ICS with PDU session with GBR [212], add VoNR, delete GBR
    Run Keyword And Continue On Failure    Repeat UE9 PDU1: ICS with PDU session with GBR [254], add VoNR, delete GBR

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


CB008379-C-b_2 Setup and release second PDU session with GBR VoNR while non VoNR GBR is active on UE
    [Tags]    C_b-2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS w/o session, setup PDU session (default nonGBR + GBR), start traffic GBR, add VoNR in second
    ...  PDU session (default nonGBR + VoNR), start traffic VoNR, verify traffic and delete VoNR (release
    ...  second PDU session), verify traffic GBR
    ...  == Precondition ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIK + ABIL) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14806, 5G_RAN_USR_RRM_14808, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-C1 Multiple UEs with single additional GBR bearer /Voice+additional GBR
    ...  - USBasicCall-B#B1: PDU Session Resource Release for one or multiple PDU sessions (at least one PDU session remains)

    Wait until PM counters file is ready and saved

    Run Keyword And Continue On Failure  Repeat UE1: ICS w/o session, setup session GBR [2], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE2: ICS w/o session, setup session GBR [3], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE3: ICS w/o session, setup session GBR [4], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE4: ICS w/o session, setup session GBR [71], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE5: ICS w/o session, setup session GBR [72], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE6: ICS w/o session, setup session GBR [76], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE7: ICS w/o session, setup session GBR [128], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE8: ICS w/o session, setup session GBR [212], add VoNR in second session, release second session
    Run Keyword And Continue On Failure  Repeat UE9: ICS w/o session, setup session GBR [254], add VoNR in second session, release second session

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 18
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

CB008379-C-b_3 Setup PDU session with GBR VoNR and other GBR then release GBR and addition of GBR in second PDU session then release all sessions
    [Tags]    C_b-3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS w/o session, setup PDU session (default nonGBR + VoNR + GBR), start traffic GBR and VoNR, verify
    ...  traffic VoNR, delete VoNR, add VoNR, verify traffic GBR, delete GBR, add GBR in second PDU session,
    ...  start traffic GBR and VoNR, verify traffic GBR and VoNR, release all PDU sessions
    ...  == Precondition ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIK + ABIL) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14806, 5G_RAN_USR_RRM_14808, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-C1 Multiple UEs with single additional GBR bearer /Voice+additional GBR
    ...  - USBasicCall-B#B1: PDU Session Resource Release for one or multiple PDU sessions

    Wait until PM counters file is ready and saved

    Run Keyword And Continue On Failure  Repeat UE1: ICS w/o session,setup VoNR and GBR [2],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE2: ICS w/o session,setup VoNR and GBR [3],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE3: ICS w/o session,setup VoNR and GBR [4],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE4: ICS w/o session,setup VoNR and GBR [71],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE5: ICS w/o session,setup VoNR and GBR [72],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE6: ICS w/o session,setup VoNR and GBR [76],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE7: ICS w/o session,setup VoNR and GBR [128],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE8: ICS w/o session,setup VoNR and GBR [212],delete GBR,add GBR in second session,release sessions
    Run Keyword And Continue On Failure  Repeat UE9: ICS w/o session,setup VoNR and GBR [254],delete GBR,add GBR in second session,release sessions

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 18
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


CB008379-C-b_4 Setup PDU session with default nonGBR and GBR then swap existing QoS flow to new nonGBR and GBR pair
    [Tags]    C_b-4
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS w/o session, setup default nonGBR + GBR QosFlow
    ...  send modification with addition of GBR flow and new default nonGBR flow and release old
    ...  nonGBR+GBR pair (swap old QoS flows to new ones)
    ...  == Precondition ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actVoNR = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIK + ABIL) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14806, 5G_RAN_USR_RRM_14808, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-C1 Multiple UEs with single additional GBR bearer /Voice+additional GBR
    ...  - USBasicCall-B#B1: PDU Session Resource Release for one or multiple PDU sessions

    Wait until PM counters file is ready and saved

    Run Keyword And Continue On Failure  Repeat UE1: ICS w/o session, setup nonGBR+GBR [2], swap old QoS flows to new nonGBR+GBR [3] pair
    Run Keyword And Continue On Failure  Repeat UE2: ICS w/o session, setup nonGBR+GBR [3], swap old QoS flows to new nonGBR+GBR [4] pair
    Run Keyword And Continue On Failure  Repeat UE3: ICS w/o session, setup nonGBR+GBR [4], swap old QoS flows to new nonGBR+GBR [71] pair
    Run Keyword And Continue On Failure  Repeat UE4: ICS w/o session, setup nonGBR+GBR [71], swap old QoS flows to new nonGBR+GBR [72] pair
    Run Keyword And Continue On Failure  Repeat UE5: ICS w/o session, setup nonGBR+GBR [72], swap old QoS flows to new nonGBR+GBR [76] pair
    Run Keyword And Continue On Failure  Repeat UE6: ICS w/o session, setup nonGBR+GBR [76], swap old QoS flows to new nonGBR+GBR [128] pair
    Run Keyword And Continue On Failure  Repeat UE7: ICS w/o session, setup nonGBR+GBR [128], swap old QoS flows to new nonGBR+GBR [212] pair
    Run Keyword And Continue On Failure  Repeat UE8: ICS w/o session, setup nonGBR+GBR [212], swap old QoS flows to new nonGBR+GBR [254] pair
    Run Keyword And Continue On Failure  Repeat UE9: ICS w/o session, setup nonGBR+GBR [254], swap old QoS flows to new nonGBR+GBR [2] pair

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
