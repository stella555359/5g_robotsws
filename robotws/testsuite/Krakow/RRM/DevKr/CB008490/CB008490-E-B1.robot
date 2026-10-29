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
...      CB008490-E#B1 - UE Context Release - RRC Reestablishment
...
...      == CONTACTS ==
...         - Konrad Krzyzak 		<konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek 			<tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
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
...      [02.03.2024] - Create Test Suite
...      [26.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904554)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490_pm_counters.robot


Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml


*** Test Cases ***
CB008490-E-B1_UE_Context_release_RRC_Reestablishment_AMF_release_context_afterwards
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior for UE with established inter-gNB NR-DC connection (with established
    ...  SN-terminated split bearer) during RRC Reestablishment to serving or unprepared cell.
    ...  During the test, UE has experienced RLF and sends RRC: Reestablishment Request to the same gNB.
    ...  It should successfully retrieve old UE Context for UE with SN-terminated split bearer.
    ...  Next according to US5GC002267-A#B1 Early introduction of RRC connection reestablishment via RRC Setup, procedure
    ...  of Re-establishment via RRC: RRC Setup is successfully performed. Old UE Context is released by gNB.
    ...
    ...  == PRECONDITION ==
    ...  Use common preconditions from AC (https://collab.ext.net.nokia.com/ui#review:id=904554)
    ...  NRBTS.rrcReestabTypeSA is set to 'sameGNB' for MN
    ...  NRBTS.rrcReestabTypeSA is set to 'sameGNB' for SN
    ...  NRCELL/rlpDetCsiBsiThreshold is set to '20' for MN
    ...  NRCELL/rlpDetCsiBsiThreshold is set to '0' for SN
    ...  NRCELL/rlpDetDlHarqThreshold is set to '0' for SN
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23638
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
    ...  Related CFAM US: CB008490-E#B1 - UE Context Release: RRC Reestablishment
    ...
    ...  == HISTORY ==
    ...  [02.03.2024] - Create Test Suite
    ...  [26.04.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904554)
    ...  [02.12.2024]  - change rlpDetDlHarqThreshold on SN to 0

    [Setup]  Prepare test environment CB008490-E-B1

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 100Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2


    Set expected message flows for UE1 Context Release due to UE sends reestablishment to gNB2
    Set expected message flows for optimized UE1 ICS after reestablishment via RRC Setup, gNB2 AMF1
    Set expected message flows for UE1 Context Release due to UE sends reestablishment, MN gNB2 AMF1
    Set expected message flows for UE1 Context Release due to UE sends reestablishment, SN gNB3 AMF1

    UE1 has experienced RLF and sends RRC Reestablishment Request

    Verify expected message flows for UE1 Context Release due to UE sends reestablishment to gNB2
    Verify expected message flows for optimized UE1 ICS after reestablishment via RRC Setup, gNB2 AMF1
    Verify expected message flows for UE1 Context Release due to UE sends reestablishment, MN gNB2 AMF1
    Verify expected message flows for UE1 Context Release due to UE sends reestablishment, SN gNB3 AMF1

    Verify that F1AP:UEContextModificationRequired contains cause:radioNetwork:rl-failure-others, gNB2

    Verify that NGAP:UEContextReleaseRequest contains cause:radioNetwork:radio-connection-with-ue-lost for MN AMF1
    Verify that NGAP:UEContextReleaseCommand contains cause:radioNetwork:radio-connection-with-ue-lost for MN AMF1

    Verify that XnAP:SNodeReleaseRequest contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains pduSessionID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:radio-connection-with-UE-lost, gNB2

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

    Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:unspecified for MN gNB2
    Verify that F1AP:UEContextReleaseCommand does NOT contain RRC-Container for MN gNB2
    Verify that F1AP:UEContextReleaseCommand does NOT contain SRB-ID for SN MN gNB2

    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:unspecified for MN gNB2
    Detach and kill UE1

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Wait until PM counter files are ready and saved for gNBs

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 second PDU session after ICS

    Run 100Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 1 seconds
    Run 100Mbps UL and DL traffic on UE1 PDU2 QFI1 and wait 1 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Sleep    10

    Release UE1 initiedted by AMF with Cause:RN_radio_connection_with_ue_lost

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Wait until PM counter files are ready and saved for gNBs

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55125C00054 - NG_FLOW_REL_NRDC_A_UEL_I equals 1
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55125C00053 - NG_FLOW_REL_NRDC_ABN_INS equals 1
    ...    Verify counter value on NRBTS-3 NRPMQAP-1 for M55163C00534 - NG_FLOW_REL_NRDC_A_UEL_I_PMQAP equals 1
    ...    Verify counter value on NRBTS-3 NRPMQAP-1 for M55163C00533 - NG_FLOW_REL_NRDC_ABN_INS_PMQAP equals 1
    ...    Verify counter value on NRBTS-2 NRCELL-1 for M55125C09027 - NG_FLOW_REL_AMF_UE_LOST_INSESN equals 2
    ...    Verify counter value on NRBTS-2 NRPMQAP-1 for M55163C00015 - NG_FLOW_REL_AMF_UELSTISN_PMQAP equals 2
    ...    Verify counter value on NRBTS-3 NRCELL-2 for M55125C00053 - NG_FLOW_REL_NRDC_ABN_INS equals 1
    ...    Verify counter value on NRBTS-3 NRPMQAP-1 for M55163C00533 - NG_FLOW_REL_NRDC_ABN_INS_PMQAP equals 1

    [Teardown]  CB008490-E-B1 cleanup

*** Keywords ***
Set expected message flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment to gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP initialULRRCMessageTransfer

Verify expected message flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment to gNB${gnb_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP initialULRRCMessageTransfer

Set expected message flows for optimized UE${ue_id:\d+} ICS after reestablishment via RRC Setup, gNB${gnb_id:\d+} AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP dLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialUEMessage
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup

    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected message flows for optimized UE${ue_id:\d+} ICS after reestablishment via RRC Setup, gNB${gnb_id:\d+} AMF${amf_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP dLRRCMessageTransfer
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialUEMessage
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP initialContextSetup

    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected message flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment, MN gNB${mn_gnb_id:\d+} AMF${amf_id:\d+}
    Log    Set expected message flows for UE${ue_id} Context Release due to UE sends reestablishment, MN gNB${mn_gnb_id} AMF${amf_id}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment, SN gNB${sn_gnb_id:\d+} AMF${amf_id:\d+}
    Log    Set expected message flows for UE${ue_id} Context Release due to UE sends reestablishment, SN gNB${sn_gnb_id} AMF${amf_id}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment, MN gNB${mn_gnb_id:\d+} AMF${amf_id:\d+}
    Log    Verify expected message flows for UE${ue_id} Context Release due to UE sends reestablishment, MN gNB${mn_gnb_id} AMF${amf_id}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationRequired
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release due to UE sends reestablishment, SN gNB${sn_gnb_id:\d+} AMF${amf_id:\d+}
    Log    Verify expected message flows for UE${ue_id} Context Release due to UE sends reestablishment, SN gNB${sn_gnb_id} AMF${amf_id}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease
