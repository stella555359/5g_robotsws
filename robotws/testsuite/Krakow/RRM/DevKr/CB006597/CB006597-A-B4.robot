*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB006597: UE Power Saving - UE Assistance Inforamtion for UE preferred RRC state
...         This feature introduces the support of RRC UE Assistance Information in gNB, for the UE preferred RRC state
...         for UEs with according capabilities (3GPP Rel-16). gNB checks the UE capabilities, before to configure the
...         UAI message trigger, in particular:
...          - If UE reports the following capability:
...            - PowSav-Parameters-r16/powSav-ParametersCommon-r16/releasePreference-r16 = supported
...         gNB configures such UEs in the RRC Connection Reconfiguration accordingly, in particular gNB will configure
...         the UE to report its preferred RRC state in the UAI, by sending following information's during RRC reconfiguration:
...          - ReleasePreferenceConfig-r16 to setup
...          - releasePreferenceProhibitTimer-r16 to the value configured by the operator
...         If UE will prefer to use another RRC state, then it will report the following IE in the UE Assistance Information
...         message preferredRRC-State-r16
...
...      == TEST SET NAME ==
...         CB006597 - UE Power Saving - UE Assistance Inforamtion for UE preferred RRC state
...
...      == TESTING SPLIT ==
...         CB006597-A-B1: Activation of UE Assistance Information to report preference on the RRC state
...         CB006597-A-B2: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'idle'
...         CB006597-A-B3: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'inactive'
...         CB006597-A-B4: gNB restarts RRC inactivity timer of UE when UE reports an RRC preferred state of 'Connected'
...         CB006597-A-B5: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'outOfConnected'
...         CB006597-A-B6: Online Change of setting of feature flag for UE Assistance Information to report preference on the RRC state
...         CB006597-A-B8: Handover to enabled/disable reporting UE Assistance Information for releasePreference
...         CB006597-A-E1: UAI ignore when UE is not capable of preference or feature flag is not TRUE
...
...      == CONTACTS ==
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...
...      == REFERENCES ==
...         CB006597 CFAM
...
...      == HISTORY ==
...         [17.05.2022] - TC Create
...         [31.05.2022] - Review fix

Resource    ./resources/CB006597_common_keywords.robot
Resource    ../resources/yaml_config_paths.robot

Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run setup

*** Variables ***
${common_timeout}=        20
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SA_1gNBsim_5QI1.lua
${SKIP_COUNTERS}=         ${FALSE}

@{yaml_paths_to_configure}=  ${feature_activation_yaml}  ${inter_gnb_intra_freq_ho_yaml_path}  ${GBR_5QI_yaml_path}

*** Test Cases ***
CB006597-5G-A-B4-1 Reset RRC inactivity timer due to UE reports an RRC preferred state of Connected
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior when it receives UAI (UE Assistance Information) for an RRC preferred state of 'Connected'
    ...   and performs restarting RRC inactivity timer.
    ...   This is first variant with enter cell by attach.
    ...
    ...   Assumptions: srbInactivityTimerSA is restarted at the end of 'original timer', not at the moment of UAI reception
    ...   1. Enter cell by attach.
    ...   2. Check that single report resets timer once.
    ...   3. Check that multiple reports reset timer more than once.
    ...   4. Check counters.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1, UE_2, UE_11 - Airphone simulator
    ...        UE_1, UE_2 support UE assistance information for releasePreference
    ...        and releasePreference-r16 is set to supported in theirs UE-NR-Capability,
    ...        UE_11 does NOT support UE assistance information for releasePreference.
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...  - NRBTS/srbInactivityTimerSA > NRBTS/drbInactivityTimerSA
    ...  - NRBTS/srbInactivityTimerSA = 20
    ...  - NRBTS/drbInactivityTimerSA = 10
    ...
    ...  == Postconditions ==
    ...   - srbInactivityTimerSA is restarted once
    ...   - 5G-UE stays in RRC connected state, not be released before srbInactivityTimerSA (default 60 seconds) even no traffic ongoing.
    ...   - UAI_PREF_CONN_REP = 1, UAI_INTIME_RES_PREF_CONN = 1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15505
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-5325 USCB006597-A#B4: gNB restarts RRC inactivity timer of UE when UE reports an RRC preferred state of 'Connected'
    ...
    ...  == HISTORY ==
    ...     [17.05.2022] - TC Create
    ...     [31.05.2022] - Review fix

    [Setup]  Prepare test environment CB006597-A-B4_1
    [Tags]  A-B4_1

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Log To Console
    ...  1 - UE1 Check that single report reset the timer once

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup

    Verify that in UECapabilityInformation for UE_1 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_1 releasePreference parameters are present

    # Waiting is implemented using timeouts
    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 5s and send UAI with RRC preferred state of connected
    Sleep  5
    Trigger UE1 to send UAI with RRC preferred state of connected
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to connected

    Log To Console  Wait 20s in total and check if UE1 is not released - due to timer srbInactivityTimerSA reset
    FAIL FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 10s (more than 25s in total) and check if UE1 is released - due to timer srbInactivityTimerSA expiration
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE1 and kill if failed

    Log To Console
    ...  2 - UE2 Check that multiple reports reset timer more than once (twice) - every UAI with connected state reception should trigger
    ...  reset the timer

    Attach UE2 to gNB2 cell1 with ICS during PDU session setup

    Verify that in UECapabilityInformation for UE_2 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_2 releasePreference parameters are present

    # Waiting is implemented using timeouts
    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 5s and send UAI with RRC preferred state of connected
    Sleep  5
    Trigger UE2 to send UAI with RRC preferred state of connected
    Verify that in UEAssistanceInformation for UE_2 preferredRRC-State-r16 is set to connected
    Log To Console  Wait 10s and send second UAI with RRC preferred state of connected
    Sleep  10
    #second report
    Trigger UE2 to send UAI with RRC preferred state of connected
    Verify that in UEAssistanceInformation for UE_2 preferredRRC-State-r16 is set to connected

    Log To Console  Wait 20s in total and check if UE2 is not released - due to timer srbInactivityTimerSA reset
    FAIL FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 10s (more than 30s in total) and check if UE2 is not released - due to timer srbInactivityTimerSA reset second time
    FAIL FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 10s (more than 35s in total) and check if UE2 is released - due to timer srbInactivityTimerSA expiration
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE2 and kill if failed

    Log To Console
    ...  3 - UE11 Check if UE does NOT support UE assistance information for releasePreference reports does not prolong the timer

    Attach UE11 to gNB2 cell1 with ICS during PDU session setup

    Verify that in uERadioCapabilityInfoIndication for UE_11 releasePreference-r16 is not present
    Verify that in RRCReconfiguration for UE_11 releasePreference parameters are not present

    Try to trigger UE11 to send UAI with RRC preferred state of connected and fail

    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait more than 20s in total and check if UE11 is released - due to timer srbInactivityTimerSA expiration - it is not prolonged
    PASS FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE11 and kill if failed

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 3
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 60 - 70
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 0, UAI_RRC_REL_IDLE_PREF_INACT 0, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 3
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 0, NG_FLOW_REL_GNB_UAI 0, NG_FLOW_REL_GNB_UAI_5QI1 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NG_FLOW_REL_ABNORMAL_5QI1 0

    [Teardown]  Cleanup after test CB006597-A-B4_1

CB006597-5G-A-B4-2 Reset RRC inactivity timer due to UE reports an RRC preferred state of Connected
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior when it receives UAI (UE Assistance Information) for an RRC preferred state of 'Connected'
    ...   and performs restarting RRC inactivity timer.
    ...   This is second variant with enter cell by handover.
    ...
    ...   Assumptions: srbInactivityTimerSA is restarted at the end of 'original timer', not at the moment of UAI reception
    ...   1. Enter cell by handover.
    ...   2. Check that single report prolongs timer once.
    ...   3. Check counters.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_4 - Airphone simulator
    ...        UE_4 supports UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...  - NRBTS/srbInactivityTimerSA > NRBTS/drbInactivityTimerSA
    ...  - NRBTS/srbInactivityTimerSA = 20
    ...  - NRBTS/drbInactivityTimerSA = 10
    ...
    ...  == Postconditions ==
    ...   - srbInactivityTimerSA is restarted once
    ...   - 5G-UE stays in RRC connected state, not be released before srbInactivityTimerSA (default 60 seconds) even no traffic ongoing.
    ...   - UAI_PREF_CONN_REP = 1, UAI_INTIME_RES_PREF_CONN = 1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15505
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-5325 USCB006597-A#B4: gNB restarts RRC inactivity timer of UE when UE reports an RRC preferred state of 'Connected'
    ...
    ...  == HISTORY ==
    ...     [17.05.2022] - TC Create
    ...     [31.05.2022] - Review fix

    [Setup]  Prepare test environment CB006597-A-B4_2
    [Tags]  A-B4_2

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE4 with one PDU session without traffic to real gNB then HO to sim gNB3 with 1 nonGBR and 1 GBR 5QI1 QoS flow

    Verify that in UECapabilityInformation for UE_4 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_4 releasePreference parameters are present

    Log to console    Trigger HO with 5QI1 QoS flow to UE4 and expecting success...
    UE4 triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A5 measurement id=5

#    Waiting is implemented using timeouts
    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 5s and send UAI with RRC preferred state of connected
    Sleep  5
    Trigger UE4 to send UAI with RRC preferred state of connected
    Verify that in UEAssistanceInformation for UE_4 preferredRRC-State-r16 is set to connected

    Log To Console  Wait 20s in total and check if UE4 is not released - due to timer srbInactivityTimerSA reset
    FAIL FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 10s (more than 25s in total) and check if UE4 is released - due to timer srbInactivityTimerSA expiration
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE4 and kill if failed

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 25 - 35
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 0, UAI_RRC_REL_IDLE_PREF_INACT 0, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 0, NG_FLOW_REL_GNB_UAI 0, NG_FLOW_REL_GNB_UAI_5QI1 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: NG_FLOW_REL_ABNORMAL_5QI1 0

    [Teardown]  Cleanup after test CB006597-A-B4_2

*** Keywords ***
Prepare test environment CB006597-A-B4_1
    Configure  ${feature_activation_yaml}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '20', 'drbInactivityTimerSA': '10'}

Cleanup after test CB006597-A-B4_1
    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Deregister UE3 and kill if failed
    Configure  ${feature_deactivation_yaml}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '600'}

Prepare test environment CB006597-A-B4_2
    Log To Console  Prepare test environment CB006597-A-B4_2
    Configure  ${yaml_paths_to_configure}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '20', 'drbInactivityTimerSA': '10'}
    Configure  {'MOC': 'NRCELL', 'actVoNR': 'true'}

Cleanup after test CB006597-A-B4_2
    Deregister UE4 and kill if failed
    Configure  ${feature_deactivation_yaml}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '600'}
    Configure  {'MOC': 'NRCELL', 'actVoNR': 'false'}
