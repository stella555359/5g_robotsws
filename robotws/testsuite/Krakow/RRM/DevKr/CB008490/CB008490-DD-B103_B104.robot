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
...      CB008490-SR-DD#B103 - UE Activity/Inactivity detection for multiple PDU Sessions (one is offloaded)
...      1. CB008490-SR-DD-B103_1 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to ue
...      2. CB008490-SR-DD-B103_2 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to drb
...      3. CB008490-SR-DD-B103_3 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition
...                                 and activityNotificationLevelSA set to ue
...      4. CB008490-SR-DD-B103_4 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition
...                                 and activityNotificationLevelSA set to drb
...      5. CB008490-SR-DD-B103_5 - UE activity resumption - second PDU is active during PSCell Addition and activityNotificationLevelSA set to drb
...      6. CB008490-SR-DD-B104_2 - IWK with CB008120 - proper timer value used on SN according to NRDRB and SNSSAI profiles
...      7. CB008490-SR-DD-B104_3 - IWK with CB008120 - activityNotificationLevelSA set to ue
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek 			<tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=698
...
...      == HISTORY ==
...      [29.08.2024] - Create Test Suite
...      [29.08.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)
...      [20.09.2024] - Merged testcases

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run keywords
...            Run setup
...    AND     Configure  {'MOC': 'NRCELL', 'ID': '1', 'a4PeriodicMeasControlSA': [{'a4RetryTimer': '1'}]}    bts_id=1

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
${yaml_inactivity}=       ${CURDIR}/config/yaml/inactivity.yaml
${B104_2}=                ${CURDIR}/config/yaml/DD_B104_2_SN.yaml
${B104_3}=                ${CURDIR}/config/yaml/DD_B104_3_SN.yaml
${B104_default}=          ${CURDIR}/config/yaml/DD_B104_default_SN.yaml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7

*** Test Cases ***
CB008490-SR-DD-B103-CRT
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Merged testcases:
    ...    - CB008490-SR-DD-B103_1 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to ue
    ...    - CB008490-SR-DD-B103_2 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to drb
    ...    - CB008490-SR-DD-B103_3 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition and
    ...         activityNotificationLevelSA set to ue
    ...    - CB008490-SR-DD-B103_4 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition and
    ...         activityNotificationLevelSA set to drb
    ...    - CB008490-SR-DD-B103_5 - UE activity resumption - second PDU is active during PSCell Addition and activityNotificationLevelSA set to drb
    ...
    ...  == PRECONDITION ==
    ...  See preconditions for corresponding testcases
    ...
    ...  == POSTCONDITION ==
    ...  See postconditions for corresponding testcases
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25463; 5G_RAN_USR_RRM_25464
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - main scenario
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - ALT#1
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - ALT#2
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - ALT#3
    ...  - US CB008490-DD#B3: UE inactivity detection (activity resumption) ALT#1
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)
    ...  [20.09.2024] - Merged testcases

    [Setup]    Prepare test environment CB008490-DD-B103_1

    # CB008490-SR-DD-B103_1 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to ue
    Log To Console    Start CB008490-SR-DD-B103_1
    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 10 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start_1
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    TC1: Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Trigger UE1 to send deregister request


    # CB008490-SR-DD-B103_3 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition and activityNotificationLevelSA set to ue
    Log To Console    Start CB008490-SR-DD-B103_3
    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE2 second PDU session after ICS
    Run 10Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE2 PDU1 QFI2 and wait 0 seconds
    Run 10Mbps DL traffic on UE2 PDU2 QFI1 and wait 10 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE2, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE2 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE2, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Stop 10Mbps DL traffic on UE2 PDU2 QFI1
    set_time_reference_point    time_alias=MN_DRB_inact_start_2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    TC2: Verify that inactivity occurred after 10 seconds for MN gNB2 with single E1AP inactivity message

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE2 PDU1 QFI1
    Stop 10Mbps DL traffic on UE2 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start_2
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    TC2: Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Trigger UE2 to send deregister request


    # CB008490-SR-DD-B103_2 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to drb
    Log To Console    Start CB008490-SR-DD-B103_2
    Configure inactivity on MN gNB: SRB=5, DRB=10, NotificationLevel=drb

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    set_time_reference_point    time_alias=MN_DRB_inact_start_3
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    TC3: Verify that inactivity occurred after 10 seconds for MN gNB2 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that 2 out of 3 DRBs are active for MN gNB2

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start_3
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    TC3: Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Trigger UE1 to send deregister request


    # CB008490-SR-DD-B103_4 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition and
    # activityNotificationLevelSA set to drb
    Log To Console    Start CB008490-SR-DD-B103_4
    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE2 second PDU session after ICS
    Add to UE2 PDU2 session QoS flows with 5QI from list [170] and delete QoS flows with 5QI from list [] via amf
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Run 10Mbps DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE2 PDU1 QFI2 and wait 0 seconds
    Run 10Mbps DL traffic on UE2 PDU2 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE2 PDU2 QFI2 and wait 10 seconds
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE2, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE2 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE2, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Set expected messages flows for SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE2 PDU1 QFI1
    Stop 10Mbps DL traffic on UE2 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start_4
    Verify expected messages flows for SN inactivity with single E1AP inactivity message
    TC4: Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3

    Stop 10Mbps DL traffic on UE2 PDU2 QFI1
    Stop 10Mbps DL traffic on UE2 PDU2 QFI2
    set_time_reference_point    time_alias=MN_DRB_inact_start_4
    Set expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 10s
    Set expected messages flows for SNode and UE release due to MN inactivity
    Verify expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for SNode and UE release due to MN inactivity
    TC4: Verify that inactivity occurred after 10 seconds for MN gNB2 with multiple E1AP inactivity messages
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 4 DRBs are active for MN gNB2
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 4 DRBs are active for MN gNB2
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Trigger UE2 to send deregister request


    # CB008490-SR-DD-B103_5 - UE activity resumption - second PDU is active during PSCell Addition and activityNotificationLevelSA set to drb
    Log To Console    Start CB008490-SR-DD-B103_5
    Configure inactivity on MN gNB: SRB=40, DRB=10, NotificationLevel=ue
    Configure inactivity on SN gNB: SRB=600, DRB=5, NotificationLevel=drb

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    Add to UE1 PDU2 session QoS flows with 5QI from list [170] and delete QoS flows with 5QI from list [] via amf
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU2 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU2 QFI2 and wait 10 seconds
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to drb for SN gNB3
    Verify in BearerContextSetupRequest that DRBs [4,5] has dRB-Inactivity-Timer set to [5,5] for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    Stop 10Mbps DL traffic on UE1 PDU2 QFI1
    Stop 10Mbps DL traffic on UE1 PDU2 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start_5
    set_time_reference_point    time_alias=MN_DRB_inact_start_5

    Set expected messages flows for SNode and UE release due to MN inactivity
    Set expected messages flows for SN inactivity with multiple E1AP inactivity messages
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for SN inactivity with multiple E1AP inactivity messages
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 2 DRBs are active for SN gNB3
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 2 DRBs are active for SN gNB3
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2
    TC5: Verify that inactivity occurred after 5 seconds for SN gNB3 with multiple E1AP inactivity messages
    TC5: Verify that inactivity occurred after 10 seconds for MN gNB2 with single E1AP inactivity message
    Verify messages flows for SNode and UE release not occurred due to MN inactivity

    Set expected messages flows for SN inactivity with single E1AP inactivity message
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Verify expected messages flows for SN inactivity with single E1AP inactivity message

    Verify in BearerContextInactivityNotification that 1 out of 2 DRBs are active for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to re-activated for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    Verify in BearerContextInactivityNotification that 0 out of 2 DRBs are active for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Trigger UE1 to send deregister request

    [Teardown]    Basic cleanup


CB008490-SR-DD-B104-CRT
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Merged testcases:
    ...    - CB008490-SR-DD-B104_2 - IWK with CB008120 - proper timer value used on SN according to NRDRB and SNSSAI profiles
    ...    - CB008490-SR-DD-B104_3 - IWK with CB008120 - activityNotificationLevelSA set to ue
    ...
    ...  == PRECONDITION ==
    ...  See preconditions for corresponding testcases
    ...
    ...  == POSTCONDITION ==
    ...  See postconditions for corresponding testcases
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25468
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#IWK2: UE inactivity detection
    ...    (interaction with per-DRB and per-slice inactivity timer setting on SN and MN (the latter during takeback)) - main scenario
    ...  - US CB008490-DD#IWK2: UE inactivity detection
    ...    (interaction with per-DRB and per-slice inactivity timer setting on SN and MN (the latter during takeback)) - ALT#1
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)
    ...  [20.09.2024] - Merged testcases

    [Setup]    Prepare test environment CB008490-DD-B104_2

    # CB008490-SR-DD-B104_2 - IWK with CB008120 - proper timer value used on SN according to NRDRB and SNSSAI profiles
    Log To Console    Start CB008490-SR-DD-B104_2
    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 2 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to drb for SN gNB3
    Verify in BearerContextSetupRequest that DRBs [4,5] has dRB-Inactivity-Timer set to [10,15] for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start_1
    Set expected messages flows for SNode and UE release due to SN inactivity with multiple E1AP inactivity messages
    Verify expected messages flows for SNode and UE release due to SN inactivity with multiple E1AP inactivity messages
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 2 DRBs are active for SN gNB3
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 2 DRBs are active for SN gNB3
    TC1: Verify that inactivity occurred after 15 seconds for SN gNB3 with multiple E1AP inactivity messages
    Verify delay between bearerContextInactivityNotification messages is equal 5 seconds for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1
    Trigger UE1 to send deregister request


    # CB008490-SR-DD-B104_3 - IWK with CB008120 - activityNotificationLevelSA set to ue
    Log To Console    Start CB008490-SR-DD-B104_3
    Configure    ${B104_3}    bts_id=2

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 2 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start_2

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    TC2: Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    CB008490-DD-B104_2 cleanup


CB008490-SR-DD-B103_1 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to ue
    [Tags]  SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour related to inactivity detection and handling when UE has configured 2 PDU sessions
    ...  and one of them is offloaded. MN NRBTS.activityNotificationLevelSA is set to 'ue'.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 5
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - SN gNB - NRBTS.srbInactivityTimerSA = 600
    ...  - SN gNB - NRBTS.drbInactivityTimerSA = 5
    ...  - SN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...
    ...  == POSTCONDITION ==
    ...    UE1 is released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25463
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - main scenario
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B103_1

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 10 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    Basic cleanup


CB008490-SR-DD-B103_3 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition and activityNotificationLevelSA set to ue
    [Tags]  SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour related to inactivity detection and handling when UE has configured 2 PDU sessions
    ...  and one of them is offloaded. Non-NR-DC eligible PDU session is active during PSCell Addition and MN NRBTS.activityNotificationLevelSA
    ...  is set to 'ue'.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 5
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - SN gNB - NRBTS.srbInactivityTimerSA = 600
    ...  - SN gNB - NRBTS.drbInactivityTimerSA = 5
    ...  - SN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...
    ...  == POSTCONDITION ==
    ...    UE1 is released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25463
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - ALT#2
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B103_1

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU2 QFI1 and wait 10 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU2 QFI1
    set_time_reference_point    time_alias=MN_DRB_inact_start
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify that inactivity occurred after 10 seconds for MN gNB2 with single E1AP inactivity message

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    Basic cleanup


CB008490-SR-DD-B103_2 - UE inactivity detection with multiple PDU sessions - activityNotificationLevelSA set to drb
    [Tags]  SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour related to inactivity detection and handling when UE has configured 2 PDU sessions
    ...  and one of them is offloaded. MN NRBTS.activityNotificationLevelSA is set to 'drb'.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 5
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'drb'
    ...  - SN gNB - NRBTS.srbInactivityTimerSA = 600
    ...  - SN gNB - NRBTS.drbInactivityTimerSA = 5
    ...  - SN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...
    ...  == POSTCONDITION ==
    ...    UE1 is released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25463
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - ALT#1
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B103_2

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    set_time_reference_point    time_alias=MN_DRB_inact_start
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify that inactivity occurred after 10 seconds for MN gNB2 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that 2 out of 3 DRBs are active for MN gNB2

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    Basic cleanup


CB008490-SR-DD-B103_4 - UE inactivity with multiple PDU - second PDU is active during PSCell Addition and activityNotificationLevelSA set to drb
    [Tags]  SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour related to inactivity detection and handling when UE has configured 2 PDU sessions
    ...  and one of them is offloaded. Non-NR-DC eligible PDU session is active during PSCell Addition and
    ...  MN NRBTS.activityNotificationLevelSA is set to 'drb'.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 5
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'drb'
    ...  - SN gNB - NRBTS.srbInactivityTimerSA = 600
    ...  - SN gNB - NRBTS.drbInactivityTimerSA = 5
    ...  - SN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...
    ...  == POSTCONDITION ==
    ...    UE1 is released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25463
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#B2: UE inactivity detection (multiple PDU sessions) - ALT#3
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B103_2

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    Add to UE1 PDU2 session QoS flows with 5QI from list [170] and delete QoS flows with 5QI from list [] via amf
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU2 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU2 QFI2 and wait 10 seconds
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Set expected messages flows for SN inactivity with single E1AP inactivity message
    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start
    Verify expected messages flows for SN inactivity with single E1AP inactivity message
    Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU2 QFI1
    Stop 10Mbps DL traffic on UE1 PDU2 QFI2
    set_time_reference_point    time_alias=MN_DRB_inact_start
    Set expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 10s
    Set expected messages flows for SNode and UE release due to MN inactivity
    Verify expected messages flows for 2*BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for SNode and UE release due to MN inactivity
    Verify that inactivity occurred after 10 seconds for MN gNB2 with multiple E1AP inactivity messages
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 4 DRBs are active for MN gNB2
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 4 DRBs are active for MN gNB2
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    Basic cleanup


CB008490-SR-DD-B103_5 - UE activity resumption - second PDU is active during PSCell Addition and activityNotificationLevelSA set to drb
    [Tags]  SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour related to activity resumption when UE has configured 2 PDU sessions
    ...  and one of them is offloaded. Non-NR-DC eligible PDU session is active during PSCell Addition
    ...  and SN NRBTS.activityNotificationLevelSA is set to 'drb'.
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 40
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - SN gNB - NRBTS.srbInactivityTimerSA = 600
    ...  - SN gNB - NRBTS.drbInactivityTimerSA = 5
    ...  - SN gNB - NRBTS.activityNotificationLevelSA = 'drb'
    ...
    ...  == POSTCONDITION ==
    ...    UE1 is released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25464
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#B3: UE inactivity detection (activity resumption) ALT#1
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B103_5

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Add to UE1 second PDU session after ICS
    Add to UE1 PDU2 session QoS flows with 5QI from list [170] and delete QoS flows with 5QI from list [] via amf
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU2 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU2 QFI2 and wait 10 seconds
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify BearerContextInactivityNotification not occurred for MN gNB2 after 10s
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to drb for SN gNB3
    Verify in BearerContextSetupRequest that DRBs [4,5] has dRB-Inactivity-Timer set to [5,5] for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    Stop 10Mbps DL traffic on UE1 PDU2 QFI1
    Stop 10Mbps DL traffic on UE1 PDU2 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start
    set_time_reference_point    time_alias=MN_DRB_inact_start

    Set expected messages flows for SNode and UE release due to MN inactivity
    Set expected messages flows for SN inactivity with multiple E1AP inactivity messages
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify expected messages flows for SN inactivity with multiple E1AP inactivity messages
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 2 DRBs are active for SN gNB3
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 2 DRBs are active for SN gNB3
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2
    Verify that inactivity occurred after 5 seconds for SN gNB3 with multiple E1AP inactivity messages
    Verify that inactivity occurred after 10 seconds for MN gNB2 with single E1AP inactivity message
    Verify messages flows for SNode and UE release not occurred due to MN inactivity

    Set expected messages flows for SN inactivity with single E1AP inactivity message
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Verify expected messages flows for SN inactivity with single E1AP inactivity message

    Verify in BearerContextInactivityNotification that 1 out of 2 DRBs are active for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to re-activated for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message

    Verify in BearerContextInactivityNotification that 0 out of 2 DRBs are active for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    Basic cleanup


CB008490-SR-DD-B104_2 - IWK with CB008120 - proper timer value used on SN according to NRDRB and SNSSAI profiles
    [Tags]  SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the SN gNB related to inactivity detection and handling in
    ...  interworking with CB008120 (Additional standard slices support).
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 5
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - SN gNB - NRBTS.srbInactivityTimerSA = 600
    ...  - SN gNB - NRBTS.drbInactivityTimerSA = 7200
    ...  - SN gNB - NRBTS.activityNotificationLevelSA = 'drb'
    ...  - SN gNB - NRBTS.actAdditionalSliceSupport = 'true'
    ...  - SN gNB - NRBTS.NRDRB.drbInactivityTimerSA = 10
    ...  - SN gNB - NRBTS.SNSSAI.drbInactivityTimerSA = 15
    ...
    ...  == POSTCONDITION ==
    ...    UE1 is released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25468
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#IWK2: UE inactivity detection
    ...    (interaction with per-DRB and per-slice inactivity timer setting on SN and MN (the latter during takeback)) - main scenario
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B104_2

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 2 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to drb for SN gNB3
    Verify in BearerContextSetupRequest that DRBs [4,5] has dRB-Inactivity-Timer set to [10,15] for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start
    Set expected messages flows for SNode and UE release due to SN inactivity with multiple E1AP inactivity messages
    Verify expected messages flows for SNode and UE release due to SN inactivity with multiple E1AP inactivity messages
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify in 2*BearerContextInactivityNotification_1 that 1 out of 2 DRBs are active for SN gNB3
    Verify in 2*BearerContextInactivityNotification_2 that 0 out of 2 DRBs are active for SN gNB3
    Verify that inactivity occurred after 15 seconds for SN gNB3 with multiple E1AP inactivity messages
    Verify delay between bearerContextInactivityNotification messages is equal 5 seconds for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    CB008490-DD-B104_2 cleanup


CB008490-SR-DD-B104_3 - IWK with CB008120 - activityNotificationLevelSA set to ue
    [Tags]  SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the SN gNB related to inactivity detection and handling in
    ...  interworking with CB008120 (Additional standard slices support).
    ...
    ...  == PRECONDITION ==
    ...  - Common preconditions to all CB008490-DD User Scenarios (5G_RAN_USR_RRM_25447)
    ...  - MN gNB - NRBTS.srbInactivityTimerSA = 5
    ...  - MN gNB - NRBTS.drbInactivityTimerSA = 10
    ...  - MN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - SN gNB - NRBTS.srbInactivityTimerSA = 600
    ...  - SN gNB - NRBTS.drbInactivityTimerSA = 5
    ...  - SN gNB - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - SN gNB - NRBTS.actAdditionalSliceSupport = 'true'
    ...  - SN gNB - NRBTS.NRDRB.drbInactivityTimerSA = 10
    ...  - SN gNB - NRBTS.SNSSAI.drbInactivityTimerSA = 15
    ...
    ...  == POSTCONDITION ==
    ...    UE1 is released due to inactivity
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25468
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DD#IWK2: UE inactivity detection
    ...    (interaction with per-DRB and per-slice inactivity timer setting on SN and MN (the latter during takeback)) - ALT#1
    ...
    ...  == HISTORY ==
    ...  [29.08.2024] - Create Test Suite
    ...  [29.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=917731)

    [Setup]    Prepare test environment CB008490-DD-B104_3

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Run 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 10Mbps DL traffic on UE1 PDU1 QFI2 and wait 2 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected messages flows for BearerContextInactivityNotification for MN gNB2 after 10s
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for MN gNB2
    Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ue for SN gNB3
    Verify in BearerContextSetupRequest that Inactivity-Timer is set to 5 for SN gNB3

    Stop 10Mbps DL traffic on UE1 PDU1 QFI1
    Stop 10Mbps DL traffic on UE1 PDU1 QFI2
    set_time_reference_point    time_alias=SN_DRB_inact_start

    Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    Verify that inactivity occurred after 5 seconds for SN gNB3 with single E1AP inactivity message
    Verify in BearerContextInactivityNotification that uE-Activity eq not-active and dRB-Activity-List is not present for SN gNB3
    Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to inactive for SN gNB3
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:user-inactivity, gNB2
    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:user-inactivity for MN AMF1

    [Teardown]    CB008490-DD-B104_2 cleanup


*** Keywords ***
Set expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=10]: gNB3 XNAP activityNotification
    EXPECT FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease

Verify expected messages flows for SNode and UE release due to SN inactivity with single E1AP inactivity message
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=10]: gNB3 XNAP activityNotification
    PASS FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease

Set expected messages flows for SNode and UE release due to SN inactivity with multiple E1AP inactivity messages
    EXPECT FLOW[timeout=20]: gNB3 E1AP 2*bearerContextInactivityNotification
    EXPECT FLOW[timeout=20]: gNB3 XNAP activityNotification
    EXPECT FLOW[timeout=20]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=20]: AMF1 NGAP uEContextRelease

Verify expected messages flows for SNode and UE release due to SN inactivity with multiple E1AP inactivity messages
    PASS FLOW[timeout=20]: gNB3 E1AP 2*bearerContextInactivityNotification
    PASS FLOW[timeout=20]: gNB3 XNAP activityNotification
    PASS FLOW[timeout=20]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=20]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=20]: AMF1 NGAP uEContextRelease

Set expected messages flows for SNode and UE release due to MN inactivity
    EXPECT FLOW[timeout=12]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=12]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=12]: AMF1 NGAP uEContextRelease

Verify expected messages flows for SNode and UE release due to MN inactivity
    PASS FLOW[timeout=12]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=12]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=12]: AMF1 NGAP uEContextRelease

Verify messages flows for SNode and UE release not occurred due to MN inactivity
    FAIL FLOW[timeout=12]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    FAIL FLOW[timeout=12]: AMF1 NGAP uEContextReleaseRequest
    FAIL FLOW[timeout=12]: AMF1 NGAP uEContextRelease

Set expected messages flows for SN inactivity with single E1AP inactivity message
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=10]: gNB3 XNAP activityNotification

Verify expected messages flows for SN inactivity with single E1AP inactivity message
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=10]: gNB3 XNAP activityNotification

Set expected messages flows for SN inactivity with multiple E1AP inactivity messages
    EXPECT FLOW[timeout=10]: gNB3 E1AP 2*bearerContextInactivityNotification
    EXPECT FLOW[timeout=10]: gNB3 XNAP activityNotification

Verify expected messages flows for SN inactivity with multiple E1AP inactivity messages
    PASS FLOW[timeout=10]: gNB3 E1AP 2*bearerContextInactivityNotification
    PASS FLOW[timeout=10]: gNB3 XNAP activityNotification

Verify delay between bearerContextInactivityNotification messages is equal ${time} seconds for ${opt:MN|SN} gNB${gnb_id}
    Log  Verify delay between bearerContextInactivityNotification messages for ${opt}
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextInactivityNotification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    verify_delay_between_messages
    ...    reference_flow_alias=${flow_alias}
    ...    reference_message_alias=BearerContextInactivityNotification_1
    ...    flow_alias=${flow_alias}
    ...    message_alias=BearerContextInactivityNotification_2
    ...    expected_diff_time=${time}
    ...    tolerance=0.3

TC${tc_id}: Verify that inactivity occurred after ${time} seconds for ${opt:MN|SN} gNB${gnb_id} with single E1AP inactivity message
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextInactivityNotification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    verify_message_delay_from_message_to_time_point
    ...    flow_alias=${flow_alias}
    ...    message_alias=BearerContextInactivityNotification
    ...    time_alias=${opt}_DRB_inact_start_${tc_id}
    ...    expected_diff_time=${time}
    ...    tolerance=1.0

TC${tc_id}: Verify that inactivity occurred after ${time} seconds for ${opt:MN|SN} gNB${gnb_id} with multiple E1AP inactivity messages
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextInactivityNotification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    verify_message_delay_from_message_to_time_point
    ...    flow_alias=${flow_alias}
    ...    message_alias=BearerContextInactivityNotification_2
    ...    time_alias=${opt}_DRB_inact_start_${tc_id}
    ...    expected_diff_time=${time}
    ...    tolerance=1.0
