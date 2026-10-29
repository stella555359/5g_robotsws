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
...         [23.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=861135)

Resource    ./resources/CB006597_common_keywords.robot

Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run keywords
...          Run setup
...          AND  Configure  ${yaml_paths_to_configure}

*** Variables ***
${common_timeout}=        20
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SA_1gNBsim_with_lte_cell.lua

@{yaml_paths_to_configure}=  ${feature_activation_yaml}  ${inter_rat_ho_yaml_path}
*** Test Cases ***
CB006597-A-B2_2 Activation of UE Assistance Information to report preference on the RRC state - Inter-RAT HO
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies if gNB handles to enable reporting UE Assistance Information for
    ...   releasePreference after inter RAT handover.
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - gNB-3 is setup with fake LTE cell for testing purposes
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
    ...    REQUIREMENTS IN SCOPE: 5G_CP_MM_3467, 5G_RAN_USR_RRM_15578, 5G_RAN_USR_RRM_15507
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
    ...     [15.06.2022] - TC Create
    ...     [23.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=861135)

    [Setup]  Prepare test environment CB006597-A-B2_2
    [Tags]  A-B2
    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Prepare UE_1 to interRAT HO
    UE1 triggers successful inter RAT handover from simulated_eNB to real_gNB

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE1 to send UAI with RRC preferred state of inactive
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to inactive

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

    [Teardown]  Cleanup after test CB006597-A-B2_2

*** Keywords ***
Prepare test environment CB006597-A-B2_2
    Log To Console  Prepare test environment CB006597-A-B2_2

Cleanup after test CB006597-A-B2_2
    Deregister UE1 and kill if failed
    Configure  ${feature_deactivation_yaml}

Prepare UE_${ue_id} to interRAT HO
    Execute egate command  cmd=ue_register id=${ue_id}
    ...  pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    Execute egate command  cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...  pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID=${ue_id}
    Sleep  1
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=19 srsrq_nr=10 phycell_id=11 nrsrp_nr=85 nrsrq_nr=31
    Sleep  1
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=B2 srsrp_nr=19 srsrq_nr=10 phycell_id=11 nrsrp_nr=85 nrsrq_nr=31
    ...  pass_regexp=UE${ue_id}: Successful handover from EXT_ENB-2.1 to ENB-1.1
    Sleep  2

UE${ue_id} triggers successful inter RAT handover from simulated_eNB to real_gNB
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease

    Trigger inter RAT handover from LTE to 5G for UE${ue_id}

    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverNotification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease
