*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...      This subfeature is dedicated for detecting user inactivity. For inter-gNB NR-DC MN side cannot control activity
...      of offloaded PDU session on its own. To detect inactivity for NR-DC user with SN-terminated PDU session MN side
...      has to introduce and rely on so called MN activity and SN activity.
...
...      == TEST SET NAME ==
...      CB008490-DD: PSCell Addition (activity / inactivity detection)
...
...      == TESTING SPLIT ==
...      CB008490-SR-DD#B101 - UE Activity/Inactivity detection for single PDU Session on MN gNB
...      CB008490-SR-DD#B102 - UE Activity/Inactivity detection for single PDU Session on SN gNB
...      CB008490-SR-DD#B103 - UE Activity/Inactivity detection for multiple PDU Sessions (one is offloaded)
...      CB008490-SR-DD#B104 - Inactivity detection interworking
...
...      == TESTING SCOPE ==
...      CB008490-SR-DD#B101 - UE Activity/Inactivity detection for single PDU Session on MN gNB
...      1. CB008490-SR-DD-B101_1 - UE inactivity detection during bearer takeback - activityNotificationLevelSA set to ue
...      2. CB008490-SR-DD-B101_2 - UE inactivity detection during bearer takeback - activityNotificationLevelSA set to drb
...      CB008490-SR-DD#B104 - Inactivity detection interworking
...      3. CB008490-SR-DD-B104_1 - IWK with CB010369 - proper timer value used on SN and MN after takeback
...      4. CB008490-SR-DD-B104_4 - IWK with CB008120 - proper timer value used on MN after takeback according to NRDRB and SNSSAI profiles
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek 			<tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=698
...
...      == HISTORY ==
...      [09.09.2024] - Create Test Suite
...      [29.08.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml
${yaml_inactivity}=       ${CURDIR}/config/yaml/inactivity.yaml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7

*** Test Cases ***
CB008490-SR-DD-B101 - UE inactivity detection during bearer takeback
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour related to inactivity detection and handling when UE has
    ...  configured 2 PDU sessions and one of them is offloaded. MN NRBTS.activityNotificationLevelSA is set to:
    ...    - 'ue' for UE1 part
    ...    - 'drb' for UE2 part
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 4
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...
    ...  == POSTCONDITION ==
    ...    UE1 and UE2 are released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25465
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#B4: UE inactivity detection (behavior during bearer takeback) - main scenario and ALT.1
    ...
    ...  == HISTORY ==
    ...  [09.09.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B101

    # ==================== activityNotificationLevelSA set to ue ======================

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf

    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 4 seconds

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2

    Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s

    UE1 sends RRC:SCGFailureInformation to MN gNB2

    Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 1s

    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Set expected messages flows for UE release due to inactivity after 10s
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for UE release due to inactivity after 10s
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    # ==================== activityNotificationLevelSA set to drb ======================

    Set NRBTS-2.activityNotificationLevelSA to drb on bts-1

    Attach UE2 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf

    Run 10Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE2 PDU1 QFI2 and wait 4 seconds

    Set expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB3
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s
    UE2 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB3
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 1s

    Stop 10Mbps DL traffic on UE2 PDU1 QFI1
    Stop 10Mbps DL traffic on UE2 PDU1 QFI2

    Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE2, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s

    UE2 sends RRC:SCGFailureInformation to MN gNB2
    set_time_reference_point    time_alias=MN_DRB_inact_start

    Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE2, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 1s

    Set expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 10s
    Set expected messages flows for UE release due to inactivity after 10s
    Verify expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for UE release due to inactivity after 10s
    Verify that inactivity occurred after 10 seconds for MN gNB2 with multiple E1AP inactivity messages
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 2 DRBs are active for MN gNB2
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 2 DRBs are active for MN gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Verify in BearerContextModificationRequest that DRBs [4,5] has dRB-Inactivity-Timer set to [10,10] for MN gNB2

    [Teardown]    Basic cleanup sim SN


CB008490-SR-DD-B104 - IWK with CB010369 and CB008120 - proper timer value used on MN after takeback
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the MN gNB behaviour during takeback before inactivity detection on SN side in
    ...  interworking with CB010369 (SPID and RFSP based Inactivity timer) and CB008120 (Additional standard slices support).
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'drb'
    ...
    ...  for UE1 part (IWK with CB010369)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 4
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.actSpidRfspInactTimers = 'true'
    ...  - MN gNB - NRBTS.NRRFSP_PROFILE.rfsp = 1
    ...  - MN gNB - NRBTS.NRRFSP_PROFILE.rfspInactivityTimer = 15
    ...
    ...  for UE2 part (IWK with CB008120)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 4
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 5
    ...  - MN gNB - NRBTS.actAdditionalSliceSupport = 'true'
    ...  - MN gNB - NRBTS.NRDRB.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.SNSSAI.drbInactivityTimerSA = 15
    ...
    ...  == POSTCONDITION ==
    ...    UE1 and UE2 are released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25467; 5G_RAN_USR_RRM_25468
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#IWK1: UE inactivity detection (interaction with per-RFSP inactivity timer setting on SN and MN
    ...                         (the latter during takeback)) - ALT#2
    ...  - US CB008490-DD#IWK2: UE inactivity detection (interaction with per-DRB and per-slice inactivity timer setting
    ...                         on SN and MN (the latter during takeback)) - ALT#2
    ...
    ...  == HISTORY ==
    ...  [12.09.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-104

    # ======================================== IWK with CB010369 ==================================================

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf

    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 4 seconds

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 1s

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2

    Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s

    UE1 sends RRC:SCGFailureInformation to MN gNB2
    set_time_reference_point    time_alias=NRRFSP_drb_inact_start

    Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 1s

    Set expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 15s
    Set expected messages flows for UE release due to inactivity after 15s
    Verify expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 15s
    Verify expected messages flows for UE release due to inactivity after 15s
    Verify 2*BearerContextInactivityNotification for gNB2 occured after NRRFSP drbInactivityTimerSA=15s expiry

    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 2 DRBs are active for MN gNB2
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 2 DRBs are active for MN gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Verify in BearerContextModificationRequest that DRBs [4,5] has dRB-Inactivity-Timer set to [15,15] for MN gNB2

    # ======================================== IWK with CB008120 ==================================================

    Prepare CB008490-DD-B104_4 part

    Attach UE2 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf

    Run 10Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE2 PDU1 QFI2 and wait 4 seconds

    Set expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB3
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s
    UE2 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB3
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 1s

    Stop 10Mbps DL traffic on UE2 PDU1 QFI1
    Stop 10Mbps DL traffic on UE2 PDU1 QFI2

    Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE2, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 1s

    UE2 sends RRC:SCGFailureInformation to MN gNB2
    set_time_reference_point    time_alias=NRDRB_drb_inact_start
    set_time_reference_point    time_alias=SNSSAI_drb_inact_start


    Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE2, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 1s

    Set expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 15s
    Set expected messages flows for UE release due to inactivity after 15s
    Verify expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 15s
    Verify expected messages flows for UE release due to inactivity after 15s

    Verify 1 out of 2 BearerContextInactivityNotification for gNB2 occured after NRDRB drbInactivityTimerSA=10s expiry
    Verify 2 out of 2 BearerContextInactivityNotification for gNB2 occured after SNSSAI drbInactivityTimerSA=15s expiry
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 2 DRBs are active for MN gNB2
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 2 DRBs are active for MN gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Verify in BearerContextModificationRequest that DRBs [4,5] has dRB-Inactivity-Timer set to [10,15] for MN gNB2

    [Teardown]    CB008490-DD-104 cleanup

*** Keywords ***
Set expected messages flows for UE release due to inactivity after ${time:\d+}s
    ${timeout} =    Evaluate    ${2} + ${time}
    ${str_timeout}=    Convert To String    ${timeout}
    EXPECT FLOW[timeout=${str_timeout}]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=${str_timeout}]: AMF1 NGAP uEContextRelease

Verify expected messages flows for UE release due to inactivity after ${time:\d+}s
    ${timeout} =    Evaluate    ${2} + ${time}
    PASS FLOW[timeout=${timeout}]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=${timeout}]: AMF1 NGAP uEContextRelease

Verify ${mult:\d+}*BearerContextInactivityNotification for gNB${gnb_id} occured after ${moc} drbInactivityTimerSA=${time:\d+}s expiry
    ${flow_alias}=     Get flow name
    ...     procedure=${mult}*bearerContextInactivityNotification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    verify_message_delay_from_message_to_time_point
    ...    flow_alias=${flow_alias}
    ...    message_alias=BearerContextInactivityNotification_2
    ...    time_alias=${moc}_drb_inact_start
    ...    expected_diff_time=${time}
    ...    tolerance=1.0

Verify ${msg} out of ${all} BearerContextInactivityNotification for gNB${gnb_id} occured after ${moc} drbInactivityTimerSA=${time:\d+}s expiry
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextInactivityNotification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    verify_message_delay_from_message_to_time_point
    ...    flow_alias=${flow_alias}
    ...    message_alias=BearerContextInactivityNotification_${msg}
    ...    time_alias=${moc}_drb_inact_start
    ...    expected_diff_time=${time}
    ...    tolerance=1.0
