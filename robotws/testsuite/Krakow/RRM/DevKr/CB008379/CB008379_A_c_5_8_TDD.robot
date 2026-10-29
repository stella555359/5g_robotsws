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
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008379
...
...       [25.01.2022] - Created TC
...       [25.01.2022] - Review closed
...       [17.02.2022] - Copy tests 5-8 from A_b FDD suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Run Setup
...  AND  Set UE IDLE timers on gNB: drbInactivityTimerSA=600 srbInactivityTimerSA=600

Test Teardown  Run Test Teardown

*** Variables ***
${ON_FAILURE}=           CONTINUE
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua

*** Test Cases ***
CB008379-A-c_5 Modification of PDU Session with addition of GBR flow and release second nonGBR flow added after ICS
    [Tags]    A_c-5    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS with session with nonGBR, add second nonGBR QosFlow, send modification with addition of GBR flow and release second nonGBR
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
    ...  5G_RAN_USR_RRM_14762, 5G_RAN_USR_RRM_14764, 5G_RAN_USR_RRM_14715, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - USCB008379-A/B#B2: Successful setup of GBR Bearer with Initial Context Setup Request
    ...  - USCB008379-A/B#B3: Successful setup of GBR Bearer with simultaneous add of GBR Bearer
    ...  and Deletion of one or more non-GBR/GBR 5QI QoS Flow(s) with PDU Session Resource Modification Request
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008379
    ...
    ...         [25.01.2022] - Created TC
    ...         [25.01.2022] - Review closed

    # without VoNR active on UE
    Wait until PM counters file is ready and saved

    Run Keyword And Continue On Failure  Repeat UE1 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [2] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE2 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [3] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE3 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [4] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE4 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [71] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE5 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [72] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE6 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [76] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE7 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [128] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE8 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [212] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE9 PDU1 QFI3: without VoNR, add second nonGBR QoS Flow, add GBR [254] flow and release second nonGBR

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    # with VoNR active on UE
    Run Keyword And Continue On Failure  Repeat UE1 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [2] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE2 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [3] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE3 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [4] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE4 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [71] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE5 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [72] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE6 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [76] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE7 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [128] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE8 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [212] flow and release second nonGBR
    Run Keyword And Continue On Failure  Repeat UE9 PDU1 QFI4: with VoNR, add second nonGBR QoS Flow, add GBR [254] flow and release second nonGBR

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


CB008379-A-c_6 Modification of PDU Session with addition of GBR flow and release two nonGBR flows added after ICS
    [Tags]    A_c-6
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS with session with nonGBR, add second and third nonGBR flow,
    ...  send modification with addition of GBR flow and release second and third nonGBR flow
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
    ...  5G_RAN_USR_RRM_14762, 5G_RAN_USR_RRM_14764, 5G_RAN_USR_RRM_14715, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - USCB008379-A/B#B2: Successful setup of GBR Bearer with Initial Context Setup Request
    ...  - USCB008379-A/B#B3: Successful setup of GBR Bearer with simultaneous add of GBR Bearer
    ...  and Deletion of one or more non-GBR/GBR 5QI QoS Flow(s) with PDU Session Resource Modification Request
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008379
    ...
    ...         [25.01.2022] - Created TC
    ...         [25.01.2022] - Review closed

    # without VoNR active on UE
    start collecting counters
    Run Keyword And Continue On Failure  Repeat UE1 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [2] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE2 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [3] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE3 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [4] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE4 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [71] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE5 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [72] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE6 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [76] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE7 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [128] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE8 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [212] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE9 PDU1 QFI4: without VoNR, add 2 nonGBR QoS Flows, add GBR [254] flow and release 2 nonGBR flows

    # with VoNR active on UE
    Run Keyword And Continue On Failure  Repeat UE1 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [2] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE2 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [3] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE3 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [4] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE4 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [71] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE5 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [72] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE6 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [76] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE7 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [128] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE8 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [212] flow and release 2 nonGBR flows
    Run Keyword And Continue On Failure  Repeat UE9 PDU1 QFI5: with VoNR, add 2 nonGBR QoS Flows, add GBR [254] flow and release 2 nonGBR flows

    Wait until aggreagted PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 90, QFI_SETUP_SUCC 90, QFI_REL 90, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0



CB008379-A-c_7 Modification of PDU Session with addition of GBR flow with different 5QI and release first GBR added after ICS
    [Tags]    A_c-7
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS with session with nonGBR + GBR, send modification with addition of GBR flow and release first GBR (GBRs have different 5QI)
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
    ...  5G_RAN_USR_RRM_14763, 5G_RAN_USR_RRM_14764, 5G_RAN_USR_RRM_14715, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request
    ...  - USCB008379-A/B#B3: Successful setup of GBR Bearer with simultaneous add of GBR Bearer
    ...  and Deletion of one or more non-GBR/GBR 5QI QoS Flow(s) with PDU Session Resource Modification Request
    ...  - USCB008379-A/B#B4: Release of GBR Bearers
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008379
    ...
    ...         [25.01.2022] - Created TC
    ...         [25.01.2022] - Review closed

    # without VoNR active on UE
    Wait until PM counters file is ready and saved

    Run Keyword And Continue On Failure  Repeat UE1: ICS without session, setup nonGBR and GBR [2], add next GBR [3] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE2: ICS without session, setup nonGBR and GBR [3], add next GBR [4] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE3: ICS without session, setup nonGBR and GBR [4], add next GBR [71] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE4: ICS without session, setup nonGBR and GBR [71], add next GBR [72] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE5: ICS without session, setup nonGBR and GBR [72], add next GBR [76] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE6: ICS without session, setup nonGBR and GBR [76], add next GBR [128] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE7: ICS without session, setup nonGBR and GBR [128], add next GBR [212] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE8: ICS without session, setup nonGBR and GBR [212], add next GBR [254] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE9: ICS without session, setup nonGBR and GBR [254], add next GBR [2] and release first GBR

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
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    # with VoNR active on UE
    Run Keyword And Continue On Failure  Repeat UE1: ICS without session, setup nonGBR, VoNR and GBR [2], add next GBR [3] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE2: ICS without session, setup nonGBR, VoNR and GBR [3], add next GBR [4] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE3: ICS without session, setup nonGBR, VoNR and GBR [4], add next GBR [71] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE4: ICS without session, setup nonGBR, VoNR and GBR [71], add next GBR [72] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE5: ICS without session, setup nonGBR, VoNR and GBR [72], add next GBR [76] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE6: ICS without session, setup nonGBR, VoNR and GBR [76], add next GBR [128] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE7: ICS without session, setup nonGBR, VoNR and GBR [128], add next GBR [212] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE8: ICS without session, setup nonGBR, VoNR and GBR [212], add next GBR [254] and release first GBR
    Run Keyword And Continue On Failure  Repeat UE9: ICS without session, setup nonGBR, VoNR and GBR [254], add next GBR [2] and release first GBR

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


CB008379-A-c_8 GBR establishment then release it - no other DRBs are left
    [Tags]    A_c-8    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS with session with nonGBR + GBR, release GBR, add GBR, release entire session
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
    ...  5G_RAN_USR_RRM_14762, 5G_RAN_USR_RRM_14764, 5G_RAN_USR_RRM_14765, 5G_RAN_USR_RRM_14715
    ...  5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - USCB008379-A/B#B2: Successful setup of GBR Bearer with Initial Context Setup Request
    ...  - USCB008379-A/B#B4: Release of GBR Bearers
    ...  - USBasicCall-B#B2: PDU Session Resource Release for one or multiple PDU sessions (no PDU session remains)
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008379
    ...
    ...         [25.01.2022] - Created TC
    ...         [25.01.2022] - Review closed

    # without VoNR active on UE
    Wait until PM counters file is ready and saved

    Run Keyword And Continue On Failure  Repeat UE1 PDU1: ICS with session with nonGBR and GBR [2],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE2 PDU1: ICS with session with nonGBR and GBR [3],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE3 PDU1: ICS with session with nonGBR and GBR [4],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE4 PDU1: ICS with session with nonGBR and GBR [71],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE5 PDU1: ICS with session with nonGBR and GBR [72],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE6 PDU1: ICS with session with nonGBR and GBR [76],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE7 PDU1: ICS with session with nonGBR and GBR [128],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE8 PDU1: ICS with session with nonGBR and GBR [212],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE9 PDU1: ICS with session with nonGBR and GBR [254],release GBR,add GBR,release entire session

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    # with VoNR active on UE
    Run Keyword And Continue On Failure  Repeat UE1 PDU1: ICS with session with nonGBR, VoNR and GBR [2],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE2 PDU1: ICS with session with nonGBR, VoNR and GBR [3],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE3 PDU1: ICS with session with nonGBR, VoNR and GBR [4],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE4 PDU1: ICS with session with nonGBR, VoNR and GBR [71],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE5 PDU1: ICS with session with nonGBR, VoNR and GBR [72],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE6 PDU1: ICS with session with nonGBR, VoNR and GBR [76],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE7 PDU1: ICS with session with nonGBR, VoNR and GBR [128],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE8 PDU1: ICS with session with nonGBR, VoNR and GBR [212],release GBR,add GBR,release entire session
    Run Keyword And Continue On Failure  Repeat UE9 PDU1: ICS with session with nonGBR, VoNR and GBR [254],release GBR,add GBR,release entire session

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 3
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 9
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


CB008379-A-b_issue
    [Tags]    ex    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS with session with nonGBR + GBR, release GBR, add GBR, release entire session
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
    ...  5G_RAN_USR_RRM_14762, 5G_RAN_USR_RRM_14764, 5G_RAN_USR_RRM_14765, 5G_RAN_USR_RRM_14715
    ...  5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - USCB008379-A/B#B2: Successful setup of GBR Bearer with Initial Context Setup Request
    ...  - USCB008379-A/B#B4: Release of GBR Bearers
    ...  - USBasicCall-B#B2: PDU Session Resource Release for one or multiple PDU sessions (no PDU session remains)
    ...  == HISTORY ==
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008379
    ...
    ...         [25.01.2022] - Created TC
    ...         [25.01.2022] - Review closed

        # without VoNR active on UE
    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure  Repeat UE9: ICS without session, setup nonGBR and GBR [254], add next GBR [2] and release first GBR

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    # with VoNR active on UE
    Run Keyword And Continue On Failure  Repeat UE9: ICS without session, setup nonGBR, VoNR and GBR [254], add next GBR [2] and release first GBR

    Wait until PM counters file is ready and saved
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
#    Wait until PM counters file is ready and saved
#
#    Attach UE9 with 1 nonGBR and 1 GBR 5QI3 to gNB2 cell1 with ICS without PDU session setup
#
#    Run 5MBps UL and DL traffic on UE9 PDU1 QFI2 and wait 5 seconds
#    Stop and verify 5MBps UL and DL traffic on UE9 PDU1 QFI2
#
#    Add to UE9 PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [3]
#    Add to UE9 PDU1 session QoS flows with 5QI from list [3] and delete QoS flows with 5QI from list []
#    Add to UE9 PDU1 session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []
#    Add to UE9 PDU1 session QoS flows with 5QI from list [71] and delete QoS flows with 5QI from list []
#
#    Run 5MBps UL and DL traffic on UE9 PDU1 QFI2 and wait 5 seconds
#    Stop and verify 5MBps UL and DL traffic on UE9 PDU1 QFI2
#
#    Run 1MBps UL and DL traffic on UE9 PDU1 QFI3 and wait 5 seconds
#    Stop and verify 1MBps UL and DL traffic on UE9 PDU1 QFI3
##    Release initial PDU session for UE9
#
#    Wait until PM counters file is ready and saved
#    Run Keyword And Continue On Failure  Check counters NRPMQAP    1        >0    1    1    0    0
#    Run Keyword And Continue On Failure  Check counters NRPMQAP    2        >0    2    2    1    0
#    Run Keyword And Continue On Failure  Check counters NRPMQAP    3         0    1    1    0    0
