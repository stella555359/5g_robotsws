*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB006597: UE Power Saving - UE Assistance Inforamtion for UE preferred RRC state
...         This feature introduces the support of RRC UE Assistance Information in gNB, for the UE preferred RRC state
...         for UEs with according capabilities (3GPP Rel-16). gNB checks the UE capabilities, before to configure the
...         UAI message trigger, in particular
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
...         CB006597-5G-A-B1: Activation of UE Assistance Information to report preference on the RRC state
...         CB006597-5G-A-B2: Activation of UE Assistance Information to report preference on the RRC state - Inter-gNB HO
...         CB006597-5G-A-B4: Reset RRC inactivity timer due to UE reports an RRC preferred state of "Connected"
...         CB006597-5G-A-B6: Online Change of feature flag
...         CB006597-5G-A-B3: RRC Connection release due to UE Assistance Information
...         CB006597-5G-B UE Power Saving: Cloud supporting - Cloud supporting in vRAN2.0
...
...      == CONTACTS ==
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...
...      == REFERENCES ==
...         CB006597 CFAM
...
...      == HISTORY ==
...         [13.05.2022] - TC Create
...         [14.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858861)

Resource    ./resources/CB006597_common_keywords.robot

Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run keywords
...    Run setup
...    AND  Configure    ${pmqap_config}

*** Variables ***
${common_timeout}=        20
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SA.lua
${pmqap_config}=          ${CURDIR}/config/yaml_config/pmqap_profile_cfg.yaml

*** Test Cases ***
CB006597-A-B3_1 gNB releases the RRC connection of UE when UE reports an RRC preferred state of idle
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior when UE reports an RRC preferred state of 'idle'.
    ...   gNB releases UE's context. UE performs successful transition from RRC-CONNECTED to RRC-IDLE
    ...   triggered by UAI (UE Assistance Information).
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator
    ...        UE_1 supports UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - UE_11 - Airphone simulator
    ...        UE_11 does NOT support UE assistance information for releasePreference.
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...
    ...  == Postconditions ==
    ...   - UE_1 context is released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15507
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B2: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'idle'
    ...
    ...  == HISTORY ==
    ...     [13.05.2022] - TC Create
    ...     [14.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858861)

    [Setup]  Prepare test environment CB006597-A-B3_1
    [Tags]  A-B3-1    CDRT    SKIPRUN
    Omit when SKIP_COUNTERS present
    ...         start collecting counters
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_1 releasePreference-r16 is set to supported

    Verify that in RRCReconfiguration for UE_1 releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_1 releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_1 connectedReporting is set to true

    EXPECT FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Trigger UE1 to send UAI with RRC preferred state of idle
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to idle

    PASS FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified
    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 1, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 1 - 10
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 1, UAI_RRC_REL_IDLE_PREF_INACT 0, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 1, NG_FLOW_REL_GNB_UAI 1, NG_FLOW_REL_GNB_UAI_5QI1 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: NG_FLOW_REL_GNB_UAI_PMQAP 1

    [Teardown]  Cleanup after test

CB006597-A-B3_2 gNB releases the RRC connection of UE when UE reports an RRC preferred state of inactive
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior when UE reports an RRC preferred state of 'inactive'.
    ...   gNB releases UE's context. UE performs successful transition from RRC-CONNECTED to RRC-IDLE
    ...   triggered by UAI (UE Assistance Information).
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator
    ...        UE_1 supports UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - UE_11 - Airphone simulator
    ...        UE_11 does NOT support UE assistance information for releasePreference.
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...
    ...  == Postconditions ==
    ...   - UE_1 context is released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15506
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B3: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'inactive'
    ...
    ...  == HISTORY ==
    ...     [13.05.2022] - TC Create
    ...     [14.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858861)

    [Setup]  Prepare test environment CB006597-A-B3_2
    [Tags]  A-B3-2
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_1 releasePreference-r16 is set to supported

    Verify that in RRCReconfiguration for UE_1 releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_1 releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_1 connectedReporting is set to true

    EXPECT FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Trigger UE1 to send UAI with RRC preferred state of inactive
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to inactive

    PASS FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 1, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 1 - 10
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 0, UAI_RRC_REL_IDLE_PREF_INACT 1, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 1, NG_FLOW_REL_GNB_UAI 1, NG_FLOW_REL_GNB_UAI_5QI1 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: NG_FLOW_REL_GNB_UAI_PMQAP 1

    [Teardown]  Cleanup after test

CB006597-A-B3_3 gNB releases the RRC connection of UE when UE reports an RRC preferred state of outOfConnected
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior when UE reports an RRC preferred state of 'outOfConnected'.
    ...   gNB releases UE's context. UE performs successful transition from RRC-CONNECTED to RRC-IDLE
    ...   triggered by UAI (UE Assistance Information).
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator
    ...        UE_1 supports UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - UE_11 - Airphone simulator
    ...        UE_11 does NOT support UE assistance information for releasePreference.
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...
    ...  == Postconditions ==
    ...   - UE_1 context is released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15504
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B5: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'outOfConnected'
    ...
    ...  == HISTORY ==
    ...     [13.05.2022] - TC Create
    ...     [14.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858861)

    [Setup]  Prepare test environment CB006597-A-B3_3
    [Tags]  A-B3-3
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_1 releasePreference-r16 is set to supported

    Verify that in RRCReconfiguration for UE_1 releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_1 releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_1 connectedReporting is set to true

    EXPECT FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Trigger UE1 to send UAI with RRC preferred state of outOfConnected
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to outOfConnected

    PASS FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 1, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 1 - 10
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 0, UAI_RRC_REL_IDLE_PREF_INACT 0, UAI_RRC_REL_IDLE_PREF_OUTCON 1, UAI_INTIME_RES_PREF_CONN 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 1, NG_FLOW_REL_GNB_UAI 1, NG_FLOW_REL_GNB_UAI_5QI1 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: NG_FLOW_REL_GNB_UAI_PMQAP 1

    [Teardown]  Cleanup after test

*** Keywords ***
Prepare test environment CB006597-A-B3_1
    Configure  ${feature_activation_yaml}

Prepare test environment CB006597-A-B3_2
    Configure  ${feature_activation_yaml}

Prepare test environment CB006597-A-B3_3
    Configure  ${feature_activation_yaml}

Cleanup after test
    Configure  ${feature_deactivation_yaml}
    Deregister UE1 and kill if failed

