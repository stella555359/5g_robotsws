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
...         [04.04.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup
...    f1ap=${True}
...    intra_gnb_ho=${True}
...    admission_control=${True}
...    gbr_mixed_mode=${False}

*** Variables ***
${LUA_CFG}=                     ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${SKIP_COUNTERS}=               ${True}

*** Test Cases ***
CB008379-E-a_09_TDD GBR load reporting-too low UL capacity during incoming HO with GBR-background UEs released
    [Tags]    E_a-9
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  9. TDD GBR load reporting - not enough UL capacity during incoming HO with GBR, backgorund UEs
    ...  released. NRCELL-2.maxGBRTrafficLimit is reduced to around 25% of cell bandwidth capacity, and
    ...  bandwidth is exhausted with background UEs with non-VoNR GBR traffic running. UE under test
    ...  attaches to NRCELL-1 and sets up PDU session with 1 non-GBR and 1 non-VoNR GBR bearers, and
    ...  then tries to handover to NRCELL-2, but is rejected due to lack of available bandwidth. Some
    ...  background UEs are released, which results in freeing bandwidth. UE under test once again
    ...  tries to handover to NRCELL-2, and handover is successful.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRBTS-1.actIntraFreqHoSA = true
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-2.actNonVoNRGbrService = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-2.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-2.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 90% (default)
    ...  - NRCELL-2.maxGBRTrafficLimit = ~25%
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
    ...  NGAP, NR-RRC, F1AP
    ...  == CONTACTS ==
    ...  Cezary Dudek <cezary.dudek@nokia.com>
    ...  == NOTES ==
    ...  There are comments after some test iterations, indicating issues with some parameter sets which may cause
    ...  problems when running test.
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-65770 US#1 Unsuccessful PDU Session Resource Setup due to guaranteedFlowBitRate exceeded
    ...  HISTORY:
    ...  - 04.04.2022 - Testcase created

    [Setup]  Prepare test environment E_a-9

    Omit when SKIP_COUNTERS present
    ...    Start collecting counters

    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE1 and 5QI2
	# Counters per test (5QI2):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE2 and 5QI3
	# Counters per test (5QI3):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE3 and 5QI4
    # this iteration has tendency to fail HO when traffic on bkg_UEs is set to around 13Mbps each
	# Counters per test (5QI4):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0

    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE1 and 5QI71

	# Counters per test (5QI 71):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
	Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE2 and 5QI72
	# Counters per test (5QI 72):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE3 and 5QI76
    # this iteration has tendency to fail attach of last bkg_UE when traffic on bkg_UEs is set to 20Mbps each
	# Counters per test (5QI 76):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0

    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE1 and 5QI128
	# Counters per test (5QI 128):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE2 and 5QI212
	# Counters per test (5QI 212):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background Ues released for UE3 and 5QI254
	# Counters per test (5QI 254):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 5, QFI_SETUP_SUCC 5, QFI_REL 5, QFI_REL_NORMAL 0

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 15, QFI_SETUP_SUCC 15, QFI_REL 15, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 15, QFI_SETUP_SUCC 15, QFI_REL 15, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 15, QFI_SETUP_SUCC 15, QFI_REL 15, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 45, QFI_SETUP_SUCC 45, QFI_REL 45, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Cleanup after test E_a-9
