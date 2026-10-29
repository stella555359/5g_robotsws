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
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB006597 CFAM
...
...      == HISTORY ==
...         [13.05.2022] - TC Create
...         [27.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=861137)
...         [10.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858770)

Resource    ./resources/CB006597_common_keywords.robot

Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run keywords
...          Run setup
...          AND  Configure  ${inter_gNB_handover}

*** Variables ***
${common_timeout}=        20
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SA_1gNBsim.lua
*** Test Cases ***
CB006597-A-B2_1 Activation of UE Assistance Information to report preference on the RRC state - Inter-gNB HO
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies if gNB handles to enable/disable reporting UE Assistance Information for
    ...   releasePreference after inter gNB handover.
    ...
    ...   UE_1 performs HO from gNB-3 (source) with feature disabled, to gNB-2 (target) with feature enabled.
    ...   Target gNB should send RRCReconfiguration message with releasePreferenceConfig-r16 set to true
    ...   and releasePreferenceProhibitTimer-r16 set to s0.
    ...   UE_1 should be able to send UEAssistanceInformation to gNB-2 with preferredRRC-State-r16 set to 'idle'
    ...   After sending UAI message UE_1 Context should be released from target gNB.
    ...
    ...   Same scenario is performed for UE_11 which is not supporting releasePreference. HO to target gNB should be
    ...   successful, but in RRCReconfiguration releasePreferenceConfig-r16 and releasePreferenceProhibitTimer-r16
    ...   should NOT be present. UE_11 should not bo able to send UEAssistanceInformation
    ...
    ...   UE_2 performs HO from gNB-3 (source) with feature enabled, to gNB-2 (target) with feature enabled too.
    ...   Target gNB should send RRCReconfiguration message without releasePreferenceConfig-r16 set to true
    ...   and releasePreferenceProhibitTimer-r16 set to s0.
    ...   UE_2 should be able to send UEAssistanceInformation to gNB-2 with preferredRRC-State-r16 set to 'inactive'
    ...   After sending UAI message UE_2 Context should be released from target gNB.
    ...
    ...   Same scenario is performed for UE_12 which is not supporting releasePreference. HO to target gNB should be
    ...   successful, but in RRCReconfiguration releasePreferenceConfig-r16 and releasePreferenceProhibitTimer-r16
    ...   should NOT be present. UE_12 should not bo able to send UEAssistanceInformation
    ...
    ...   UE_3 performs HO from gNB-3 (source) with feature enabled, to gNB-2 (target) with feature disabled.
    ...   Target gNB should send RRCReconfiguration message with releasePreferenceConfig-r16 set to release.
    ...   UE_3 should not be able to send UEAssistanceInformation to gNB-2.
    ...
    ...   Same scenario is performed for UE_13 which is not supporting releasePreference. HO to target gNB should be
    ...   successful, but in RRCReconfiguration releasePreferenceConfig-r16 and releasePreferenceProhibitTimer-r16
    ...   should NOT be present. UE_13 should not bo able to send UEAssistanceInformation
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1, UE_2, UE_3 - Airphone simulator
    ...        UEs support UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - UE_11, UE_12, UE_13 - Airphone simulator
    ...        UEs does NOT support UE assistance information for releasePreference.
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...
    ...  == Postconditions ==
    ...   - UE_1 and UE_2 are enabled to provide UE Assistance Information for ReleasePreference to the gNB
    ...   - UE_3 is no able to provide UE Assistance Information for ReleasePreference to the gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15476, 5G_RAN_USR_RRM_15502
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4993 USCB006597-A#B8: Handover to enabled/disable reporting UE Assistance Information for releasePreference
    ...
    ...  == HISTORY ==
    ...     [13.05.2022] - TC Create
    ...     [10.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858770)

    [Setup]  Prepare test environment CB006597-A-B2_1
    [Tags]  A-B2
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Prepare UE_1 to handover
    UE1 triggers successful XN HO from simulated_gNB to real_gNB

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE1 to send UAI with RRC preferred state of idle
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to idle

    EXPECT FLOW: UE_11 NR-RRC RRCReconfiguration

    Prepare UE_11 to handover
    UE11 triggers successful XN HO from simulated_gNB to real_gNB
    FAIL FLOW: UE_11 NR-RRC RRCReconfiguration

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Fail to trigger UE11 to send UAI with RRC preferred state of idle
    FAIL FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Set sim gNB to support ReleasePreference-r16
    Prepare UE_2 to handover
    UE2 triggers successful XN HO from simulated_gNB to real_gNB

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE2 to send UAI with RRC preferred state of inactive
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified
    Verify that in UEAssistanceInformation for UE_2 preferredRRC-State-r16 is set to inactive

    EXPECT FLOW: UE_12 NR-RRC RRCReconfiguration
    Prepare UE_12 to handover
    FAIL FLOW: UE_12 NR-RRC RRCReconfiguration

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Fail to trigger UE12 to send UAI with RRC preferred state of idle
    FAIL FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Configure  ${feature_deactivation_yaml}
    Prepare UE_3 to handover
    UE3 triggers successful XN HO from simulated_gNB to real_gNB

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Fail to trigger UE3 to send UAI with RRC preferred state of idle
    FAIL FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    EXPECT FLOW: UE_13 NR-RRC RRCReconfiguration
    Prepare UE_13 to handover
    UE13 triggers successful XN HO from simulated_gNB to real_gNB

    FAIL FLOW: UE_13 NR-RRC RRCReconfiguration

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Fail to trigger UE3 to send UAI with RRC preferred state of idle
    FAIL FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 1, UAI_PREF_INACT_REP 1, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 1 - 10
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 1, UAI_RRC_REL_IDLE_PREF_INACT 1, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 2, NG_FLOW_REL_GNB_UAI 2, NG_FLOW_REL_GNB_UAI_5QI1 0

    [Teardown]  Cleanup after test CB006597-A-B2_1

CB006597-A-B2_3 Activation of UE Assistance Information to report preference on the RRC state - Reestablishment
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies if gNB handles to enable reporting UE Assistance Information for
    ...   releasePreference after reestablishment.
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator
    ...        UEs support UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
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
    ...     -  CB006597-5660 USCB006597-A#B1: Activation of UE Assistance Information to report preference on the RRC state
    ...
    ...  == HISTORY ==
    ...     [15.06.2022] - TC Create
    ...     [27.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=861137)

    [Setup]  Prepare test environment CB006597-A-B2_3
    [Tags]  A-B2
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Attach UE1 to gNB2 cell1 with ICS and PDU session setup after ICS

    Verify that in RRCReconfiguration for UE_1 releasePreference parameters are present

    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Trigger reestablishment for UE1

    PASS FLOW: UE_1 NR-RRC RRCReconfiguration
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete
    Verify that in RRCReconfiguration for UE_1 releasePreference parameters are present

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

    Trigger UE1 to send UAI with RRC preferred state of idle
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to idle

    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified

    Attach UE2 to gNB2 cell1 with ICS and PDU session setup after ICS

    Verify that in RRCReconfiguration for UE_2 releasePreference parameters are present

    Configure  ${feature_deactivation_yaml}  #Disable CB006597

    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_2 NR-RRC RRCReconfigurationComplete

    Trigger reestablishment for UE2

    PASS FLOW: UE_2 NR-RRC RRCReconfiguration
    PASS FLOW: UE_2 NR-RRC RRCReconfigurationComplete
    Verify that in RRCReconfiguration for UE_2 releasePreference parameters are not present

    Omit when SKIP_COUNTERS present
    ...         Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_PREF_IDLE_REP 1, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 10 - 100
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: UAI_RRC_REL_IDLE_PREF_IDLE 1, UAI_RRC_REL_IDLE_PREF_INACT 0, UAI_RRC_REL_IDLE_PREF_OUTCON 0, UAI_INTIME_RES_PREF_CONN 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters: SA_UE_CTX_REL_UAI 1, NG_FLOW_REL_GNB_UAI 1, NG_FLOW_REL_GNB_UAI_5QI1 0

    [Teardown]  Cleanup after test CB006597-A-B2_3
*** Keywords ***
Prepare test environment CB006597-A-B2_1
    Log To Console  Prepare test environment CB006597-A-B2_1
    Configure  ${feature_activation_yaml}

Cleanup after test CB006597-A-B2_1
    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Deregister UE3 and kill if failed
    Deregister UE11 and kill if failed
    Deregister UE12 and kill if failed
    Deregister UE13 and kill if failed
    Execute egate command  cmd=xn_handover_gnb_preparation_param id=3 ReleasePreferenceConfig=setup

Prepare test environment CB006597-A-B2_3
    Log To Console  Prepare test environment CB006597-A-B2_1
    Configure  ${feature_activation_yaml}
    Configure  {'MOC': 'NRBTS', 'rrcReestabTypeSA': 'sameGNB'}

Cleanup after test CB006597-A-B2_3
    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Configure  ${feature_deactivation_yaml}

UE${ue_id:\d+} triggers Inter-gNB Handover from simulated gNB${gnb_src} to real gNB${gnb_tgt} by sending ${event_id:A3|A5} measurement
    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=${event_id} srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Sleep  1

Prepare UE_${ue_id} to handover
    Set up inter gNB Handover for UE${ue_id}
    Execute egate command  cmd=ue_change_location id=${ue_id} enb=3 cell=1
    Execute egate command  cmd=ue_register id=${ue_id}
    ...  pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    Execute egate command  cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...  pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID=${ue_id}
