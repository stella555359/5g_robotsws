*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB006597: UE Power Saving - UE Assistance Information for UE preferred RRC state
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
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == REFERENCES ==
...         CB006597 CFAM
...
...      == HISTORY ==
...         [16.05.2022] - TC Create
...         [20.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=859322)

Resource    ./resources/CB006597_common_keywords.robot

Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run keywords
...    Run setup
...    AND  Configure    ${pmqap_config}

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SA.lua
${pmqap_config}=          ${CURDIR}/config/yaml_config/pmqap_profile_cfg.yaml

*** Test Cases ***
CB006597-5G-A-B6-1 Online Change of feature flag
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior during online change of NRBTS/actRrcReleasePreference parameter
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - UE - Airphone simulator
    ...        UE1-5 supports UE assistance information for releasePreference
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = false (feature flag)
    ...  - NRBTS/srbInactivityTimerSA > NRBTS/drbInactivityTimerSA
    ...  - NRBTS/srbInactivityTimerSA = 60
    ...  - NRBTS/drbInactivityTimerSA = 600
    ...
    ...  == Postconditions ==
    ...   - With feature disbaled, UE1 new call should not have feature configured even with proper capabiliy
    ...         - UAI messages should not be sent
    ...
    ...   - With feature enabled, new UE2-4 should have feature configured and UAI should be accepted
    ...         - for UE1 (from step 1) UAI should still not be sent
    ...
    ...  - Attach UE5 should be configured with feature, then disable flag
    ...         - UE5 should stay configured but all UAIs should be ignored (USCB006597-A#EC1 cases)
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15503
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB006597-A#B6: Online Change of setting of feature flag for
    ...         UE Assistance Information to report preference on the RRC state Description
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [20.06.2022] - Review closed ()

    [Setup]  Prepare test environment CB006597-A-B6-1
    [Tags]  AB6_1

    Log to console      actRrcReleasePreference=false; attach UE1 and send UAI

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that in uERadioCapabilityInfoIndication for UE_1 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_1 releasePreference parameters are not present

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Idle and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Inactive and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Connected and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease


    Log to console      actRrcReleasePreference=true; send UAI for UE1

    Configure  ${feature_activation_yaml}

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Idle and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Inactive and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Connected and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE1 and kill if failed


    Log to console      actRrcReleasePreference=true; attach UE2 and send UAI with RRC preferred state of RRC Idle

    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_2 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_2 releasePreference parameters are present

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE2 to send UAI with RRC preferred state of idle
    Verify that in UEAssistanceInformation for UE_2 preferredRRC-State-r16 is set to idle
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified


    Log to console      actRrcReleasePreference=true; attach UE3 and send UAI with RRC preferred state of RRC connected

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '20', 'drbInactivityTimerSA': '10'}

    Attach UE3 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_3 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_3 releasePreference parameters are present

    # Waiting is implemented using timeouts
    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 5s and send UAI with RRC preferred state of connected
    Sleep  5
    Trigger UE3 to send UAI with RRC preferred state of connected
    Verify that in UEAssistanceInformation for UE_3 preferredRRC-State-r16 is set to connected

    Log To Console  Wait 20s in total and check if UE1 is not released - due to timer srbInactivityTimerSA reset
    FAIL FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 10s (more than 25s in total) and check if UE3 is released - due to timer srbInactivityTimerSA expiration
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease


    Log to console      actRrcReleasePreference=true; attach UE4 and send UAI with RRC preferred state of RRC Inactive

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '600'}

    Attach UE4 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_4 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_4 releasePreference parameters are present

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE4 to send UAI with RRC preferred state of inactive
    Verify that in UEAssistanceInformation for UE_4 preferredRRC-State-r16 is set to inactive
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified

    Deregister UE2 and kill if failed
    Deregister UE3 and kill if failed
    Deregister UE4 and kill if failed


    Log to console      actRrcReleasePreference=true; attach UE5; actRrcReleasePreference=false; send UAI for UE5

    Attach UE5 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_5 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_5 releasePreference parameters are present

    Configure  ${feature_deactivation_yaml}

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE5 to send UAI with RRC preferred state of idle
    Verify that in UEAssistanceInformation for UE_5 preferredRRC-State-r16 is set to idle
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE5 to send UAI with RRC preferred state of inactive
    Verify that in UEAssistanceInformation for UE_5 preferredRRC-State-r16 is set to inactive
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE5 to send UAI with RRC preferred state of connected
    Verify that in UEAssistanceInformation for UE_5 preferredRRC-State-r16 is set to connected
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE5 and kill if failed


    Log to console      Verify counters

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 2, UAI_PREF_INACT_REP 2, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 2
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 80 - 100
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 1, UAI_RRC_REL_IDLE_PREF_INACT 1, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 2, NG_FLOW_REL_GNB_UAI 2, NG_FLOW_REL_GNB_UAI_5QI1 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: NG_FLOW_REL_GNB_UAI_PMQAP 2


    [Teardown]  Cleanup after test CB006597-A-B6-1

CB006597-5G-A-B6-2 Online Change of feature flag with HO
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior during online change of NRBTS/actRrcReleasePreference parameter with Handover
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - UE - Airphone simulator
    ...        UE1-5 supports UE assistance information for releasePreference
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = false (feature flag)
    ...  - NRBTS/srbInactivityTimerSA > NRBTS/drbInactivityTimerSA
    ...  - NRBTS/srbInactivityTimerSA = 60
    ...  - NRBTS/drbInactivityTimerSA = 600
    ...
    ...  == Postconditions ==
    ...   - With feature disble, UE1 new call should not have feature configured even with proper capability after handover
    ...         - UAI messages should not be sent
    ...
    ...   - With feature re-enabled, new UE2-4 should have feature configured and after handover UAI should be accepted
    ...         - UE1 (from step 1) UAI should not be sent after handover
    ...
    ...  - Attach UE5 should be configured with feature enable then feature flag is change to disable
    ...         - after handover for UE5 UAI messages should not be sent
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15505;CB_FIM_27576
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  USCB006597-A#B6: Online Change of setting of feature flag for
    ...         UE Assistance Information to report preference on the RRC state Description
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [20.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=859322)

    [Setup]  Prepare test environment CB006597-A-B6-2
    [Tags]  AB6_2

    Log to console      Attach UE1 with proper capability and feature disabled

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that in uERadioCapabilityInfoIndication for UE_1 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_1 releasePreference parameters are not present

    Perform intra-gNB handover from cell1 to cell2 for UE1

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Idle and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Inactive and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Connected and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Configure  ${feature_activation_yaml}

    Perform intra-gNB handover from cell2 to cell1 for UE1

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Idle and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Inactive and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE1 to send UAI with RRC preferred state of Connected and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE1 and kill if failed


    Log to console      actRrcReleasePreference=true; attach UE2 and send UAI with RRC preferred state of RRC idle

    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_2 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_2 releasePreference parameters are present

    Perform intra-gNB handover from cell1 to cell2 for UE2

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE2 to send UAI with RRC preferred state of idle
    Verify that in UEAssistanceInformation for UE_2 preferredRRC-State-r16 is set to idle
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified


    Log to console      actRrcReleasePreference=true; attach UE3 and send UAI with RRC preferred state of RRC connected

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '20', 'drbInactivityTimerSA': '10'}

    Attach UE3 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_3 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_3 releasePreference parameters are present

    Perform intra-gNB handover from cell1 to cell2 for UE3

    # Waiting is implemented using timeouts
    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 5s and send UAI with RRC preferred state of connected
    Sleep  5
    Trigger UE3 to send UAI with RRC preferred state of connected
    Verify that in UEAssistanceInformation for UE_3 preferredRRC-State-r16 is set to connected

    Log To Console  Wait 20s in total and check if UE1 is not released - due to timer srbInactivityTimerSA reset
    FAIL FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Log To Console  Wait 10s (more than 25s in total) and check if UE3 is released - due to timer srbInactivityTimerSA expiration
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease


    Log to console      actRrcReleasePreference=true; attach UE4 and send UAI with RRC preferred state of RRC Inactive

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '600'}

    Attach UE4 to gNB2 cell1 with ICS during PDU session setup
    Verify that in UECapabilityInformation for UE_4 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_4 releasePreference parameters are present

    Perform intra-gNB handover from cell1 to cell2 for UE4

    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE4 to send UAI with RRC preferred state of inactive
    Verify that in UEAssistanceInformation for UE_4 preferredRRC-State-r16 is set to inactive
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified

    Deregister UE2 and kill if failed
    Deregister UE3 and kill if failed
    Deregister UE4 and kill if failed


    Log to console      Attach UE5 with proper capability and feature re-disabled

    Attach UE5 to gNB2 cell1 with ICS during PDU session setup

    Verify that in UECapabilityInformation for UE_5 releasePreference-r16 is set to supported
    Verify that in UECapabilityInformation for UE_5 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_5 releasePreference parameters are present

    Configure  ${feature_deactivation_yaml}

    Perform intra-gNB handover from cell1 to cell2 for UE5

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE5 to send UAI with RRC preferred state of Idle and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE5 to send UAI with RRC preferred state of Inactive and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Try to trigger UE5 to send UAI with RRC preferred state of Connected and fail
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Deregister UE5 and kill if failed


    Log to console      Verify counters

#NRCELL-2
    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Counters on tgt_cell: UAI_PREF_IDLE_REP 1, UAI_PREF_INACT_REP 1, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Counter on tgt_cell: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 30 - 50
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Counters on tgt_cell: UAI_RRC_REL_IDLE_PREF_IDLE 1, UAI_RRC_REL_IDLE_PREF_INACT 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Counters on tgt_cell: UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Counters on tgt_cell: SA_UE_CTX_REL_UAI 2, NG_FLOW_REL_GNB_UAI 2, NG_FLOW_REL_GNB_UAI_5QI1 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: NG_FLOW_REL_GNB_UAI_PMQAP 2

#NRCELL-1
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 0, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 0, UAI_RRC_REL_IDLE_PREF_INACT 0, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 0, NG_FLOW_REL_GNB_UAI 0, NG_FLOW_REL_GNB_UAI_5QI1 0


    [Teardown]  Cleanup after test CB006597-A-B6-2

*** Keywords ***
Prepare test environment CB006597-A-B6-1
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

Prepare test environment CB006597-A-B6-2
    Configure  ${feature_deactivation_yaml}
    Configure       ${intra_gNB_handover}
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

Cleanup after test CB006597-A-B6-1
    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Deregister UE3 and kill if failed
    Deregister UE4 and kill if failed
    Deregister UE5 and kill if failed
    Configure  ${feature_deactivation_yaml}

Cleanup after test CB006597-A-B6-2
    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Deregister UE3 and kill if failed
    Deregister UE4 and kill if failed
    Deregister UE5 and kill if failed
    Configure  ${feature_deactivation_yaml}

Counters on tgt_cell: UAI_PREF_IDLE_REP ${uai_i}, UAI_PREF_INACT_REP ${uai_in}, UAI_PREF_OUTCONN_REP ${uai_o}, UAI_PREF_CONN_REP ${uai_c}
    Verify any counters in file
    ...    M55124C08502     ${uai_i}    UAI_PREF_IDLE_REP
    ...    M55124C08503     ${uai_in}    UAI_PREF_INACT_REP
    ...    M55124C08505     ${uai_o}    UAI_PREF_OUTCONN_REP
    ...    M55124C08504     ${uai_c}    UAI_PREF_CONN_REP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTERS}

Counter on tgt_cell: ACC_UAI_RRC_REL_PREF_CONF_UES is in range ${lower} - ${higher}
    verify_if_any_pm_counter_is_in_range_of_given_values
    ...    M55124C08501     ${lower}    ${higher}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    filepath=${PM_COUNTERS}

Counters on tgt_cell: UAI_RRC_REL_IDLE_PREF_IDLE ${i}, UAI_RRC_REL_IDLE_PREF_INACT ${in}
    Verify any counters in file
    ...    M55124C08506     ${i}    UAI_RRC_REL_IDLE_PREF_IDLE
    ...    M55124C08507     ${in}    UAI_RRC_REL_IDLE_PREF_INACT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTERS}

Counters on tgt_cell: UAI_RRC_REL_IDLE_PREF_OUTCON ${o}, UAI_INTIME_RES_PREF_CONN ${c}
    Verify any counters in file
    ...    M55124C08508     ${o}    UAI_RRC_REL_IDLE_PREF_OUTCON
    ...    M55124C08509     ${c}    UAI_INTIME_RES_PREF_CONN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTERS}

Counters on tgt_cell: SA_UE_CTX_REL_UAI ${normal}, NG_FLOW_REL_GNB_UAI ${Qos_F}, NG_FLOW_REL_GNB_UAI_5QI1 ${5QI_1}
    Verify any counters in file
    ...    M55125C12001     ${normal}    SA_UE_CTX_REL_UAI
    ...    M55125C12004     ${Qos_F}    NG_FLOW_REL_GNB_UAI
    ...    M55125C12005     ${5QI_1}    NG_FLOW_REL_GNB_UAI_5QI1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTERS}
