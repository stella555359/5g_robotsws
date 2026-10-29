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
...            CB008379-E_a
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
...         [03.03.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup      admission_control=${True}

*** Variables ***
&{TOPOLOGY_TO_LUA}=      CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD=${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
...                      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_1c_1gNBsim.lua
...                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD= ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${LUA_CFG}=              ${CURDIR}/config/SA_FDD_1c_1eNBsim_1gNBsim.lua
${SKIP_COUNTERS}         ${True}

*** Test Cases ***
CB008379-E-a_05 GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released
    [Tags]    E_a-5
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  5. FDD GBR load reporting - not enough DL capacity during QoS Flow Addition,
    ...  background Ues have their GBR released. NRCELL-1.maxGBRTrafficLimit is reduced to around 75%
    ...  of cell bandwidth capacity, and bandwidth is exhausted with background UEs with non-VoNR GBR traffic
    ...  running. UE under test attaches to cell with InitialContextSetup without PDU sessions, and then tries
    ...  to setup PDU session with 1 non-GBR bearer and 1 non-VoNR GBR bearer by sending PDU Session Setup,
    ...  but setup is rejected due to lack of resources. Some background UEs have their GBR bearers released,
    ...  which results in freeing bandwidth. UE under test once again tries to set up new PDU session with
    ...  non-VoNR GBR bearer, and setup is successful. PMQAP counters are checked.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 75%
    ...  - NRDRB-XX.maxDataRateGbrDl = 30 Mb/s
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_IF_NTW_4978
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-258 US#1 Single GBR 5QI2/3/4 DRB admission
    ...  HISTORY:
    ...  - 03.03.2022 - Testcase created

    [Setup]  Prepare test environment E_a-5

    Omit when SKIP_COUNTERS present
    ...  Start collecting counters

    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE1 and 5QI2
	# Counters per test (5QI2):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE2 and 5QI3
	# Counters per test (5QI3):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE3 and 5QI4
	# Counters per test (5QI4):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0

    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE1 and 5QI71
	# Counters per test (5QI 71):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE2 and 5QI72
	# Counters per test (5QI 72):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE3 and 5QI76
	# Counters per test (5QI 76):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0

    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE1 and 5QI128
	# Counters per test (5QI 128):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE2 and 5QI212
	# Counters per test (5QI 212):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
    Run keyword and continue on failure
    ...    Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE3 and 5QI254
	# Counters per test (5QI 254):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 7, QFI_SETUP_SUCC 6, QFI_REL 6, QFI_REL_NORMAL 0

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 21, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 21, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 21, QFI_SETUP_SUCC 18, QFI_REL 18, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 63, QFI_SETUP_SUCC 54, QFI_REL 54, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Cleanup after test E_a-5
