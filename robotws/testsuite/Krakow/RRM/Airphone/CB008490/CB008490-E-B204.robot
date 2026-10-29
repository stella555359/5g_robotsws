*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE context release. UE should be transmit
...      from RRC-CONNECTED to RRC_IDLE state after procedure.
...
...      == TEST SET NAME ==
...      CB008490-E UE context release
...
...      == TESTING SPLIT ==
...      CB008490-E#B1 - UE Context Release - RRC Reestablishment
...      CB008490-E#B2 - UE Context Release - due to preemption
...      CB008490-E#B3 - UE Context Release - due to failure in AMF reselection
...      CB008490-E#B4 - UE Context Release - due to Xn-U Error (UP Error Indication from SN gNB-CU-UP to MN gNB-DU)
...
...      == TESTING SCOPE ==
...      CB008490-E#B2 - UE Context Release - due to preemption
...
...      == CONTACTS ==
...         - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...         - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1038
...
...      == HISTORY ==
...      [22.03.2024] - Create Test Suite
...      [25.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906037)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=SN    sim_gNB=MN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n257_simMN.lua
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_3cells_n257_1xAWEUB_simMN.xml

*** Test Cases ***
CB008490-E-B204_UE_Context_release_SN_exception_UeContextRelease_not_received
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior for transition of the UE with established inter-gNB NR-DC
    ...  connection (with established SN-terminated split bearer) to RRC IDLE triggered by preemption.
    ...  During release procedure ContextReleaseGuardTimer expires in SN gNB-CU-CP.
    ...
    ...  == PRECONDITION ==
    ...  - USR_RRM_23633 - Common text (Precondition) to all CB008490-E User Scenarios
    ...  - NRBTS.actUserPreemption = 'true'
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
    ...  UE1 is in RRC-IDLE state
    ...  All resources related to UE1 are released successfully
    ...  UE2 is in ACTIVE state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_MN
    ...  - gNB classical BTS in SA mode as SN - gNB_SN
    ...  - gNB module SN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - *depending on AP deliveries possible TC will be executed with simulated_MN/SN at CRT stage
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23639
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-E#B2 - UE Context Release - due to preemption
    ...                     - Exception3: contextReleaseGuardTimer expires in SN gNB-CU-CP
    ...
    ...  == HISTORY ==
    ...  [22.03.2024] - Create Test Suite
    ...  [25.04.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906037)

    [Setup]  Prepare test environment CB008490-E-B204

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counters file is ready and saved for NRBTS-3

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Add to UE1 initial PDU session on sim gNB with ICS and indexToRFSP equal 1
    Run 50Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
    Set expected messages flows for SNodeAddition for SN gNB3
    UE1 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition for SN gNB3
    Set expected message flows for UE1 Context Release, SN gNB3 with AMF1
    Deregister UE1
    Verify expected message flows for UE1 Context Release without UEContextRelease, SN gNB3 with AMF1

    Verify that XNAP:SNodeReleaseRequestAcknowledge contains pduSessionID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'drb-ID', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'rLC-Mode', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'qfi', gNB3
    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for SN gNB3
    Verify that F1AP:UEContextReleaseCommand does NOT contain RRC-Container for SN gNB3
    Verify that F1AP:UEContextReleaseCommand does NOT contain SRB-ID for SN SN gNB3
    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:normal-release for SN gNB3
    Verify that E1AP:BearerContextReleaseComplete contains RetainabilityMeasurementsInfo:dRB-Released-In-Session:released-in-session for SN gNB3

    Attach UE2 without ICS to MN gNB2 NRCELL-1

    Add to UE2 initial PDU session on sim gNB with ICS and indexToRFSP equal 1
    Run 50Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 5 seconds
    Set expected messages flows for SNodeAddition for SN gNB3
    UE2 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition for SN gNB3
    Set expected message flows for UE1 normal Context Release, SN gNB3 with AMF1
    Deregister UE2
    Verify expected message flows for UE1 normal Context Release, SN gNB3 with AMF1
    Verify that E1AP:BearerContextReleaseComplete contains RetainabilityMeasurementsInfo:dRB-Released-In-Session:released-in-session for SN gNB3
    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for SN gNB3
    Sleep    5

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counters file is ready and saved for NRBTS-3

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55125C00052 - NG_FLOW_REL_NRDC_NOR_INS equals 2
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55163C00532 - NG_FLOW_REL_NRDC_NOR_INS_PMQAP equals 2


    [Teardown]  CB008490-E-B204 cleanup


*** Keywords ***
Set expected message flows for UE${ue_id:\d+} Context Release, SN gNB${sn_gnb_id:\d+} with AMF${amf_id:\d+}
    Log    Set expected message flows for UE${ue_id} Context Release, SN gNB${sn_gnb_id} with AMF${amf_id}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=60]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=60]: gNB${sn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release without UEContextRelease, SN gNB${sn_gnb_id:\d+} with AMF${amf_id:\d+}
    Log    Verify expected message flows for UE${ue_id} Context Release without UEContextRelease, SN gNB${sn_gnb_id} with AMF${amf_id}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} E1AP 2*bearerContextModification
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=60]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=60]: gNB${sn_gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} normal Context Release, SN gNB${sn_gnb_id:\d+} with AMF${amf_id:\d+}
    Log    Set expected message flows for UE${ue_id} Context Release, SN gNB${sn_gnb_id} with AMF${amf_id}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=60]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=60]: gNB${sn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} normal Context Release, SN gNB${sn_gnb_id:\d+} with AMF${amf_id:\d+}
    Log    Verify expected message flows for UE${ue_id} Context Release without UEContextRelease, SN gNB${sn_gnb_id} with AMF${amf_id}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=60]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=60]: gNB${sn_gnb_id} E1AP bearerContextRelease
