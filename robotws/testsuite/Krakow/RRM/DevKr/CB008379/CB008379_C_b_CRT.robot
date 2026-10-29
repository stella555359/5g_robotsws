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
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
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
...         [18.01.2023] - Switch to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Keywords
...  Run Setup
...  AND  Set UE IDLE timers on gNB: drbInactivityTimerSA=600 srbInactivityTimerSA=600

Test Teardown  Run Test Teardown

*** Variables ***
${SKIP_COUNTERS}=        ${FALSE}
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_FDD_2c_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008379-C-b_CRT GBR and VoNR different cplane procedures coexistence
    [Tags]    C_b-1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  ICS w/ session (default nonGBR + GBR), start traffic GBR, add VoNR, start traffic VoNR, verify
    ...  traffic GBR, delete GBR, verify traffic VoNR
    ...  == Precondition ==
    ...  - gNB2 up and running with two SA cells OnAir
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
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_14806, 5G_RAN_USR_RRM_14808, 5G_PM_261, 5G_PM_262, 5G_PM_196, 5G_PM_274, 5G_PM_193
    ...  == REQUIRED LOGS ==
    ...    NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-C1 Multiple UEs with single additional GBR bearer /Voice+additional GBR

    Omit when SKIP_COUNTERS present     start collecting counters
    Log to console      1/11
    Run Keyword And Continue On Failure    Repeat UE1 PDU1: ICS with PDU session with GBR [2], add VoNR, delete GBR
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC  0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    Log to console      2/11
    Run Keyword And Continue On Failure    Repeat UE1: ICS w/o session, setup session GBR [2], add VoNR in second session, release second session
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2
    Log to console      3/11
    Run Keyword And Continue On Failure    Repeat UE1: ICS w/o session,setup VoNR and GBR [2],delete GBR,add GBR in second session,release sessions
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2
    Log to console      4/11
    Run Keyword And Continue On Failure    Repeat UE2: ICS w/o session, setup session GBR [3], add VoNR in second session, release second session
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2
    Log to console      5/11
    Run Keyword And Continue On Failure    Repeat UE3: ICS w/o session,setup VoNR and GBR [4],delete GBR,add GBR in second session,release sessions
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2

    Log to console      6/11
    Run Keyword And Continue On Failure    Repeat UE4 PDU1: ICS with PDU session with GBR [71], add VoNR, delete GBR
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC  0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    Log to console      7/11
    Run Keyword And Continue On Failure    Repeat UE5: ICS w/o session, setup session GBR [72], add VoNR in second session, release second session
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2
    Log to console      8/11
    Run Keyword And Continue On Failure    Repeat UE6: ICS w/o session,setup VoNR and GBR [76],delete GBR,add GBR in second session,release sessions
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2

    Log to console      9/11
    Run Keyword And Continue On Failure    Repeat UE7: ICS w/o session,setup VoNR and GBR [128],delete GBR,add GBR in second session,release sessions
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2
    Log to console      10/11
    Run Keyword And Continue On Failure    Repeat UE8: ICS w/o session, setup session GBR [212], add VoNR in second session, release second session
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 2
    Log to console      11/11
    Run Keyword And Continue On Failure    Repeat UE9 PDU1: ICS with PDU session with GBR [254], add VoNR, delete GBR
    #    NRPMQAP-1: AVE_NUMBER_OF_SA_RRC  0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1
    #    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 1

    Omit when SKIP_COUNTERS present         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 15, QFI_SETUP_SUCC 15, QFI_REL 15, QFI_REL_NORMAL 11
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 7, QFI_REL 7, QFI_REL_NORMAL 4
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 2
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 2
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 19, QFI_SETUP_SUCC 19, QFI_REL 19, QFI_REL_NORMAL 19
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
