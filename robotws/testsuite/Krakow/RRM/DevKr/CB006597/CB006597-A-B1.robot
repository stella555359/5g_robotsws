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
...         CB006597-5G-A-B1-1 Activation of UE Assistance Information to report preference on the RRC state
...         CB006597-5G-A-B2-1 Activation of UE Assistance Information to report preference on the RRC state - Inter-gNB HO
...         CB006597-5G-A-B3-1 RRC Connection release due to UE Assistance Information
...         CB006597-5G-A-B4-1 Reset RRC inactivity timer due to UE reports an RRC preferred state of Connected
...         CB006597-5G-A-B6-1 Online Change of feature flag
...         CB006597-5G-A-B6-2 Online Change of feature flag with HO
...         CB006597-5G-B-1 UE Power Saving Cloud supporting - Cloud supporting in vRAN2.0
...
...      == CONTACTS ==
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB006597 CFAM
...
...      == HISTORY ==
...         [11.05.2022] - TC Create
...         [31.05.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858590)

Resource    ./resources/CB006597_common_keywords.robot

Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run setup

*** Variables ***
${common_timeout}=        20
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SA.lua

*** Test Cases ***
CB006597-A-B1_1 Activation of UE Assistance Information to report preference on the RRC state - ICS optimized
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior during successful activation of UE Assistance Information to report preference
    ...   on the RRC state in a capable 5G-UE during attach with optimized ICS and PDU session setup.
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
    ...   - UE_1 is enabled to provide UE Assistance Information for ReleasePreference to the gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15476
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B1: Activation of UE Assistance Information to report preference on the RRC state
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [31.05.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858590)

    [Setup]  Prepare test environment CB006597-A-B1_1
    [Tags]  A-B
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS and PDU session setup after ICS

    Verify that in uERadioCapabilityInfoIndication for UE_1 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_1 releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_1 releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_1 connectedReporting is set to true
    Sleep  20  #To verify counters
    Deregister UE1 and kill if failed

    Attach UE11 to gNB2 cell1 with ICS and PDU session setup after ICS

    Verify that in uERadioCapabilityInfoIndication for UE_11 releasePreference-r16 is not present
    Verify that in RRCReconfiguration for UE_11 releasePreferenceConfig-r16 is not present
    Verify that in RRCReconfiguration for UE_11 releasePreferenceProhibitTimer-r16 is not present
    Verify that in RRCReconfiguration for UE_11 connectedReporting is not present

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 19 - 29

    [Teardown]  Cleanup after test

CB006597-A-B1_2 Activation of UE Assistance Information to report preference on the RRC state - ICS not optimized
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior during successful activation of UE Assistance Information to report preference
    ...   on the RRC state in a capable 5G-UE during attach with not optimized ICS and PDU session setup.
    ...   UE Capabilites are not included in ICS.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIB + ABIO
    ...  - NR cell is p and connected to AMF1
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
    ...   - UE_1 is enabled to provide UE Assistance Information for ReleasePreference to the gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15476
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B1: Activation of UE Assistance Information to report preference on the RRC state
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [31.05.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858590)

    [Setup]  Prepare test environment CB006597-A-B1_2
    [Tags]  A-B1
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup

    Verify that in UECapabilityInformation for UE_1 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_1 releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_1 releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_1 connectedReporting is set to true
    Sleep  30  #To verify counters
    Deregister UE1 and kill if failed

    Attach UE11 to gNB2 cell1 with ICS during PDU session setup

    Verify that in UECapabilityInformation for UE_11 releasePreference-r16 is not present
    Verify that in RRCReconfiguration for UE_11 releasePreferenceConfig-r16 is not present
    Verify that in RRCReconfiguration for UE_11 releasePreferenceProhibitTimer-r16 is not present
    Verify that in RRCReconfiguration for UE_11 connectedReporting is not present

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 29 - 49

    [Teardown]  Cleanup after test

CB006597-A-B1_3 Activation of UE Assistance Information to report preference on the RRC state - ICS not optimized without PDU session
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior during successful activation of UE Assistance Information to report preference
    ...   on the RRC state in a capable 5G-UE during attach with not optimized ICS and without PDU session setup.
    ...   UE Capabilites are not included in ICS. PDU session is setup after ICS
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIB + ABIO
    ...  - NR cell is p and connected to AMF1
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
    ...   - UE_1 is enabled to provide UE Assistance Information for ReleasePreference to the gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15476
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B1: Activation of UE Assistance Information to report preference on the RRC state
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [31.05.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858590)

    [Setup]  Prepare test environment CB006597-A-B1_3
    [Tags]  A-B1

    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Attach UE1 to gNB2 cell1 with ICS without PDU session

    FAIL FLOW: UE_1 NR-RRC RRCReconfiguration
    FAIL FLOW: UE_1 NR-RRC RRCReconfigurationComplete
    Verify that in UECapabilityInformation for UE_1 releasePreference-r16 is set to supported

    Add to UE1 initial PDU session after ICS

    Verify that in RRCReconfiguration for UE_1 releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_1 releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_1 connectedReporting is set to true

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    EXPECT FLOW: UE_11 NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_11 NR-RRC RRCReconfigurationComplete

    Attach UE11 to gNB2 cell1 with ICS without PDU session

    FAIL FLOW: UE_11 NR-RRC RRCReconfiguration
    FAIL FLOW: UE_11 NR-RRC RRCReconfigurationComplete
    Verify that in UECapabilityInformation for UE_11 releasePreference-r16 is not present

    Add to UE11 initial PDU session after ICS

    Verify that in RRCReconfiguration for UE_11 releasePreferenceConfig-r16 is not present
    Verify that in RRCReconfiguration for UE_11 releasePreferenceProhibitTimer-r16 is not present
    Verify that in RRCReconfiguration for UE_11 connectedReporting is not present

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES eq 300

    [Teardown]  Cleanup after test

*** Keywords ***
Prepare test environment CB006597-A-B1_1
    Configure  ${feature_activation_yaml}

Prepare test environment CB006597-A-B1_2
    Configure  ${feature_activation_yaml}

Prepare test environment CB006597-A-B1_3
    Configure  ${feature_activation_yaml}

Cleanup after test
    Deregister UE1 and kill if failed
    Deregister UE11 and kill if failed
    Configure  ${feature_deactivation_yaml}
