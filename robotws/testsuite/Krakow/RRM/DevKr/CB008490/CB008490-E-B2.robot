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
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_preemption.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_preemption_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
${yaml_E_B2}=             ${CURDIR}/config/E/yaml/E_B2_preemption.yaml

*** Test Cases ***
CB008490-E-B201_UE_Context_release_due_to_preemption_without_UE_redirection
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior for transition of the UE with established inter-gNB NR-DC
    ...  connection (with established SN-terminated split bearer) to RRC IDLE triggered by preemption.
    ...
    ...  == PRECONDITION ==
    ...  - USR_RRM_23633 - Common text (Precondition) to all CB008490-E User Scenarios
    ...  - NRBTS.actUserPreemption = 'true'
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
    ...  NRPMRNL/NRPMQAP profiles are configured for MN NRBTS-2 and SN NRBTS-3:
    ...     NRBTS
    ...       actNrpmqapProfiles: 'true'
    ...       actNrpmqapProfiles: 'true'
    ...     NRPMRNL
    ...       miNrSaCuNrpmqap: '5min'
    ...       miNrMaxCellCuNrpmqap: '5min'
    ...       miNrRSACU: '5min'
    ...       miNrCUCM: '5min'
    ...     NRPMQAP
    ...       actCplaneCounters: 'true'
    ...       cfgProfType: 'SA'
    ...
    ...  UE1 is in RRC-IDLE state
    ...  All resources related to UE1 are released successfully
    ...  UE2 is in ACTIVE state
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
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
    ...
    ...  == HISTORY ==
    ...  [22.03.2024] - Create Test Suite
    ...  [25.04.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906037)

    [Setup]  Prepare test environment CB008490-E-B2

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counter files are ready and saved for gNBs

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55156C00005 - MAX_UE_NRDC_MN_CU equals 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55138C00039 - SUM_UE_NRDC_MN_CU is above 1
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55195C00001 - MAX_UE_NRDC_MN_CU_PMQAP equals 1
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55161C00004 - SUM_UE_NRDC_MN_CU_PMQAP is above 1
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55156C00030 - MAX_UE_NRDC_SN_CU equals 1
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55138C00040 - SUM_UE_NRDC_SN_CU is above 1
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55195C00002 - MAX_UE_NRDC_SN_CU_PMQAP equals 1
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55161C00006 - SUM_UE_NRDC_SN_CU_PMQAP is above 1

    Set expected message flows for UE1 Context Release due to preemption, MN gNB2 with AMF1
    Set expected message flows for UE1 Context Release due to preemption, SN gNB3 with AMF1

    Attach UE2 with QoS flow with higher ARP priority

    Verify expected message flows for UE1 Context Release due to preemption, MN gNB2 with AMF1
    Verify expected message flows for UE1 Context Release due to preemption, SN gNB3 with AMF1

    Verify that F1AP:UEContextReleaseRequest contains cause:radioNetwork:release-due-to-pre-emption for MN gNB2

    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:release-due-to-pre-emption for MN AMF1
    Verify that NGAP:UEContextReleaseCommand contains cause:radioNetwork:release-due-to-pre-emption for MN AMF1

    Verify that XnAP:SNodeReleaseRequest contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains pduSessionID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:unspecified, gNB2

    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains pduSessionID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'drb-ID', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'rLC-Mode', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'qfi', gNB3

    Verify that XNAP:UeContextRelease contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:UeContextRelease contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest

    Verify that E1AP:BearerContextModificationRequest pduSessionID same as in XNAP:SnodeReleaseRequest
    Verify that E1AP:BearerContextModificationRequest cell-Group-To-Modify includes 2 items, gNB3
    Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 0 and dL-TX-Stop eq stop, gNB3
    Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 1 and dL-TX-Stop eq stop, gNB3

    Verify that E1AP:BearerContextModificationResponse pduSessionID same as in E1AP:BearerContextModificationRequest
    Verify that E1AP:BearerContextModificationResponse dRB-ID same as in E1AP:BearerContextModificationRequest

    Verify that F1AP:UEContextModificationRequest TransmissionActionIndicator is set to 'stop' for SN gNB3

    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:unspecified for SN gNB3
    Verify that F1AP:UEContextReleaseCommand does NOT contain RRC-Container for SN gNB3
    Verify that F1AP:UEContextReleaseCommand does NOT contain SRB-ID for SN SN gNB3

    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:unspecified for SN gNB3

    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:release-due-to-pre-emption for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains RRCContainer for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains SRB-ID eq 1 for MN gNB2

    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:release-due-to-pre-emption for MN gNB2

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Wait For Next Full Pm Interval
    ...  Wait until PM counter files are ready and saved for gNBs

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55156C00005 - MAX_UE_NRDC_MN_CU equals 0
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55138C00039 - SUM_UE_NRDC_MN_CU equals 0
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55195C00001 - MAX_UE_NRDC_MN_CU_PMQAP equals 0
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55161C00004 - SUM_UE_NRDC_MN_CU_PMQAP equals 0
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55156C00030 - MAX_UE_NRDC_SN_CU equals 0
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55138C00040 - SUM_UE_NRDC_SN_CU equals 0
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55195C00002 - MAX_UE_NRDC_SN_CU_PMQAP equals 0
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55161C00006 - SUM_UE_NRDC_SN_CU_PMQAP equals 0

    [Teardown]  CB008490-E-B2 cleanup

CB008490-E-B203_UE_Context_release_MN_exception_Error_Indication_received
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior for transition of the UE with established inter-gNB NR-DC connection
    ...  (with established SN-terminated split bearer) to RRC IDLE triggered by preemption. This is exception1 case,
    ...  during procedure NGAP:UEContextReleaseCommand is not received from AMF. In the next step NGAP:ErrorIndication message occurred.
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
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
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
    ...                     - Exception1: NGAP: UEContextReleaseCommand is not received and NGAP guard timer
    ...                       expires or NGAP:ErrorIndication is received
    ...
    ...  == HISTORY ==
    ...  [22.03.2024] - Create Test Suite
    ...  [25.04.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906037)

    [Setup]  Prepare test environment CB008490-E-B2

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Set parameter for AMF1 to respond with ERROR INDICATION in UE CONTEXT RELEASE REQUEST for UE1

    Set expected message flows for UE1 Context Release due to ErrorIndication, MN gNB2 with AMF1
    Set expected message flows for UE1 Context Release due to ErrorIndication, SN gNB3 with AMF1

    Attach UE2 with QoS flow with higher ARP priority

    Verify expected message flows for UE1 Context Release due to ErrorIndication, MN gNB2 with AMF1
    Verify expected message flows for UE1 Context Release due to ErrorIndication, SN gNB3 with AMF1

    Verify that F1AP:UEContextReleaseRequest contains cause:radioNetwork:release-due-to-pre-emption for MN gNB2

    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:release-due-to-pre-emption for MN AMF1

    Verify that XnAP:SNodeReleaseRequest contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains pduSessionID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP SNodeReleaseRequest contains cause:protocol:unspecified, gNB2

    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains pduSessionID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'drb-ID', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'rLC-Mode', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'qfi', gNB3

    Verify that XNAP:UeContextRelease contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:UeContextRelease contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest

    Verify that E1AP:BearerContextModificationRequest pduSessionID same as in XNAP:SnodeReleaseRequest
    Verify that E1AP:BearerContextModificationRequest cell-Group-To-Modify includes 2 items, gNB3
    Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 0 and dL-TX-Stop eq stop, gNB3
    Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 1 and dL-TX-Stop eq stop, gNB3

    Verify that E1AP:BearerContextModificationResponse pduSessionID same as in E1AP:BearerContextModificationRequest
    Verify that E1AP:BearerContextModificationResponse dRB-ID same as in E1AP:BearerContextModificationRequest

    Verify that F1AP:UEContextModificationRequest TransmissionActionIndicator is set to 'stop' for SN gNB3

    Verify that F1AP:UEContextReleaseCommand contains cause:protocol:unspecified for SN gNB3
    Verify that F1AP:UEContextReleaseCommand does NOT contain RRC-Container for SN gNB3
    Verify that F1AP:UEContextReleaseCommand does NOT contain SRB-ID for SN SN gNB3

    Verify that E1AP:BearerContextReleaseCommand contains cause:protocol:unspecified for SN gNB3

    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:release-due-to-pre-emption for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains RRCContainer for MN gNB2
    Verify that F1AP:UEContextReleaseCommand contains SRB-ID eq 1 for MN gNB2

    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:release-due-to-pre-emption for MN gNB2

    [Teardown]  CB008490-E-B2-ErrorIndication cleanup


*** Keywords ***
Verify expected message flows for UE1 Context Release due to preemption, SN gNB${sn_gnb_id:\d+} with AMF1
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release due to preemption, MN gNB${mn_gnb_id:\d+} with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release due to ErrorIndication, MN gNB${mn_gnb_id:\d+} with AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP errorIndication
    FAIL FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease

Verify expected message flows for UE1 Context Release due to ErrorIndication, SN gNB${sn_gnb_id:\d+} with AMF1
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release due to preemption, MN gNB${mn_gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease

Set expected message flows for UE1 Context Release due to preemption, SN gNB${sn_gnb_id:\d+} with AMF1
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release due to ErrorIndication, MN gNB${mn_gnb_id:\d+} with AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP errorIndication
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease

Set expected message flows for UE1 Context Release due to ErrorIndication, SN gNB${sn_gnb_id:\d+} with AMF1
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease
