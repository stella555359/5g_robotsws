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
...            CB008379-E_d
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
...         [14.04.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup
...    admission_control=${True}
...    gbr_mixed_mode=${False}

*** Variables ***
${LUA_CFG}=                     ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${SKIP_COUNTERS}=               ${True}

*** Keywords ***
Prepare test environment E_d-1
    Configure  [{'MOC':'NRCELL', 'maxGBRTrafficLimit':'16'}, {'MOC':'NRBTS', 'drbInactivityTimerSA':'300', 'srbInactivityTimerSA':'300'}]
    Discover bts    bts_id=1
    Set test variable    ${background_ues}     11,12,13,14,15,16,17,18

Cleanup after test E_d-1
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

    Detach and kill UE10
    Execute egate command  cmd=smf_param id=1 reset
    Stop 20Mbps UL traffic and kill background UEs[${background_ues}]

Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE${ue_id} and 5QI${5qi}
    Log to console    === Testcase E_d-1, parameterized with UE${ue_id} and 5QI${5qi} ===

    Execute egate command    cmd=smf_param id=1 reset

    ${current_gw_id}=           Evaluate      50
    Set test variable    ${current_gw_id}

    Modify DL and UL GFBR=3000 and MFBR=30000 for 5QI${5qi}
    Attach UE10 with 1 nonGBR and 1 GBR 5QI${5QI} to gNB2 cell1 with ICS without PDU session setup
    Run 3MBps UL traffic on UE10 PDU1 QFI2 and wait 5 seconds

    Modify DL and UL GFBR=20000 and MFBR=30000 for 5QI${5qi}
    Setup background UEs[${background_ues}] on gNB2 cell1 with DL 10Mbps traffic on 5QI${5qi}

    Log to console    Attaching UE under test and adding 5QI${5qi} QoS flow...
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup

    Sleep  20
    Log to console    Adding 5QI${5qi} QoS Flow for UE${ue_id} and expecting PDU session modification failure...
    Try to add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Log to console    Changing GFBR values and traffic for background UEs...
    Free bandwidth resources by changing UL and DL GFBR to 6000kbit on 5QI${5qi} Qos Flow by amf on background UEs[${background_ues}]

    Run 3Mbps DL traffic on UE11 PDU1 QFI2 and wait 1 seconds
    Run 3Mbps DL traffic on UE12 PDU1 QFI2 and wait 1 seconds

    Fail
    Log to console    Waiting for traffic reporting...
    Sleep  120  # Giving more time for traffic reporting to kick in

    Log to console    Adding 5QI${5qi} QoS Flow for UE${ue_id} and expecting PDU session modification success...
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run 15Mbps DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    Verify 15Mbps DL traffic on PDU-1 QFI-2 for UE${ue_id}
    Stop 15Mbps DL traffic on UE${ue_id} PDU1 QFI2

    Stop 10Mbps DL traffic and kill background UEs[${background_ues}]
    Detach and kill UE${ue_id}


Free bandwidth resources by changing UL and DL GFBR to ${kbitrate:\d+}kbit by ${by:(amf|ue)} on 5QI${5qi:\d+} Qos Flow on background UEs[${bkg_ues}]
    @{background_ues_list}=    Split to list    ${bkg_ues}

    FOR  ${bkg_ue}   IN   @{background_ues_list}
        Modify existing 5QI${5qi} for UE${bkg_ue} initial PDU session by ${by} - set DL and UL GFBR to ${kbitrate}kbps
#        Run 10Mbps DL traffic on UE${bkg_ue} PDU1 QFI2 and wait 5 seconds
    END


Prepare test environment E_d-1b
    Configure  [{'MOC':'NRCELL', 'maxGBRTrafficLimit':'12'}, {'MOC':'NRBTS', 'drbInactivityTimerSA':'300', 'srbInactivityTimerSA':'300'}]
    Discover bts    bts_id=1
    Set test variable    ${background_ues}     11,12,13

Cleanup after test E_d-1b
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Execute egate command  cmd=smf_param id=1 reset
    Stop 20Mbps UL traffic and kill background UEs[${background_ues}]

bRepeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE${ue_id} and 5QI${5qi}
    Log to console    === Testcase E_d-1, parameterized with UE${ue_id} and 5QI${5qi} ===

    Execute egate command    cmd=smf_param id=1 reset
    Modify DL and UL GFBR=20000 and MFBR=30000 for 5QI${5qi}

    Setup background UEs[${background_ues}] on gNB2 cell1 with DL 10Mbps traffic on 5QI${5qi}

    Log to console    Attaching UE under test and adding 5QI${5qi} QoS flow...
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup

    Log to console    Adding 5QI${5qi} QoS Flow for UE${ue_id} and expecting PDU session modification failure...
    Try to add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Log to console    Changing GFBR values for background UEs...
    bFree bandwidth resources by changing UL and DL GFBR to 10000kbit on 5QI${5qi} Qos Flow by amf on background UEs[${background_ues}]
    Run 5Mbps DL traffic on UE11 PDU1 QFI2 and wait 1 seconds
    Run 5Mbps DL traffic on UE12 PDU1 QFI2 and wait 1 seconds

    Log to console    Waiting for traffic reporting...
    Sleep  20  # Giving more time for traffic reporting to kick in

    Log to console    Adding 5QI${5qi} QoS Flow with old GFBR for UE${ue_id} and expecting PDU session modification success...
    Modify DL and UL GFBR=15000 and MFBR=30000 for 5QI${5qi}
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run 15Mbps DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    Verify 15Mbps DL traffic on PDU-1 QFI-2 for UE${ue_id}
    Stop 15Mbps DL traffic on UE${ue_id} PDU1 QFI2

    Stop 15Mbps DL traffic and kill background UEs[${background_ues}]
    Detach and kill UE${ue_id}


bFree bandwidth resources by changing UL and DL GFBR to ${kbitrate:\d+}kbit on 5QI${5qi:\d+} Qos Flow by ${by:(amf|ue)} on background UEs[${bkg_ues}]
    @{bkg_ues_list}=   Split to list    ${bkg_ues}

    FOR  ${bkg_ue}  IN  @{bkg_ues_list}
        Modify existing 5QI${5qi} for UE${bkg_ue} initial PDU session by ${by} - set DL and UL GFBR to ${kbitrate}kbps
    END

*** Test Cases ***
single_E_d-1
    [Tags]    single
    [Setup]  Prepare test environment E_d-1
    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE1 and 5QI3
    [Teardown]  Cleanup after test E_d-1

single_E_d-1b
    [Tags]    singleb
    [Setup]  Prepare test environment E_d-1b
    bRepeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE1 and 5QI3
    [Teardown]  Cleanup after test E_d-1b

single_E_a-9
    [Tags]    single9
    [Setup]  Prepare test environment E_a-9
    Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background UEs released for UE2 and 5QI3
    [Teardown]  Cleanup after test E_a-9

CB008379-E-d_1_TDD GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GFBR modified by AMF
    [Tags]    E_d-1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  1. TDD GBR load reporting - not enough DL capacity during Qos Flow Addition, background UEs
    ...  have GFBR modification by AMF. NRCELL-1.maxGBRTrafficLimit is reduced to around 12% of cell bandwidth capacity,
    ...  and bandwidth is exhausted with background UEs with non-VoNR GBR traffic running. UE under test
    ...  attaches to NRCELL-1 and sets up PDU session with 1 non-GBR, then tries to perform GBR QoS Flow addition,
    ...  but fails due to lack of available bandwidth. Background UEs have their GFBR lowered, which allows
    ...  UE under test to perform GBR QoS Flow addition successfully.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - NRBTS-1.actIntraFreqHoSA = true
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = ~12%
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_IF_NTW_4978, 5G_RAN_USR_RRM_14746
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379-65770 US#1 Unsuccessful PDU Session Resource Setup due to guaranteedFlowBitRate exceeded
    ...  HISTORY:
    ...  - 14.04.2022 - Testcase created

    [Setup]  Prepare test environment E_a-11

    Omit when SKIP_COUNTERS present
    ...    Start collecting counters

    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE1 and 5QI2
	# Counters per test (5QI2):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE2 and 5QI3
	# Counters per test (5QI3):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE3 and 5QI4
	# Counters per test (5QI4):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0

    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE1 and 5QI71

	# Counters per test (5QI 71):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
	Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE2 and 5QI72
	# Counters per test (5QI 72):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE3 and 5QI76
	# Counters per test (5QI 76):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0

    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE1 and 5QI128
	# Counters per test (5QI 128):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE2 and 5QI212
	# Counters per test (5QI 212):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
    Run Keyword And Continue On Failure
    ...    Repeat GBR load reporting-too low DL capacity during Qos Flow Addition-background UEs have GFBR modified by AMF for UE3 and 5QI254
	# Counters per test (5QI 254):
		#    NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
		#    NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0
		#    NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 4, QFI_SETUP_SUCC 4, QFI_REL 4, QFI_REL_NORMAL 0

    Omit when SKIP_COUNTERS present
    ...    Wait until aggreagted PM counters file is ready and saved

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
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 36, QFI_SETUP_SUCC 36, QFI_REL 36, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0

    [Teardown]  Cleanup after test E_a-11
