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
...         CB008379-E_a
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
...         [21.03.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup
...    intra_gnb_ho=${True}
...    admission_control=${True}
...    f1ap=${True}

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua

${PMQAP_INTERVAL}=       30min
${SKIP_COUNTERS}=        ${FALSE}

*** Test Cases ***
CB008379-E-a_15_TDD GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters
    [Tags]    E_a-15
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  E_a-15. TDD GBR load reporting - incoming HO rejected by maxNumOfGBRBearersSA - counters verififcation
    ...  GBR load reporting - maxNumOfGBRBearersSA reduced to 1 on target cell, and exhausted with background UE
    ...  with one 5QI GBR bearer. UE under test with non-VoNR GBR bearer is attached to source cell.
    ...  UE under test tries to HO to target cell, but is rejected. maxNumOfGBRBearersSA on target cell is
    ...  increased to 10, and HO is retried, and results in successful HO.
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRBTS-1.actIntraFreqHoSA = true
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-2.actNonVoNRGbrService = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-2.actCDrx = false
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-2.maxNumOfGBRBearersSA = 1
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-2.actGBRAdmissionControl = 'GBRService'
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_CP_IF_NTW_4978
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC, F1AP
    ...  == CONTACTS ==
    ...  Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-E US2 Unsuccessful PDU Session Resource Setup due to number of GBR QoS flows in UE exceeded
    ...  HISTORY:
    ...  - 21.03.2022 - Testcase created

    [Setup]  Prepare test environment E_a-15

    Omit when SKIP_COUNTERS present
    ...         Wait until PM counters file is ready and saved

    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE1, UE2 and 5QI2
	# Counters per test (5QI2):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE3, UE4 and 5QI3
	# Counters per test (5QI3):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE5, UE6 and 5QI4
	# Counters per test (5QI4):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE1, UE2 and 5QI71
	# Counters per test (5QI 71):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE3, UE4 and 5QI72
	# Counters per test (5QI 72):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE5, UE6 and 5QI76
	# Counters per test (5QI 76):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0

    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE1, UE2 and 5QI128
	# Counters per test (5QI 128):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE3, UE4 and 5QI212
	# Counters per test (5QI 212):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE5, UE6 and 5QI254
	# Counters per test (5QI 254):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 2, QFI_SETUP_SUCC 2, QFI_REL 2, QFI_REL_NORMAL 0


    Omit when SKIP_COUNTERS present
    ...  Wait until PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 6, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 18, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Cleanup after test E_a-15
