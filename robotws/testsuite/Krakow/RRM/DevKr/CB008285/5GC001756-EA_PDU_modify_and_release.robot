*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         5GC001756: PCMD for SA
...         PCMD records provide per call measurements/statistics data.
...         PCMD provides a "summary" of the UE experience in the signaling, user plane, and RF domains.
...         Feature is mainly aimed at increasing PCMD fields to cover SA scenarios.
...
...      == TEST SET NAME ==
...         5GC001756
...
...      == TESTING SPLIT==
...            5GC001756-B
...            5GC001756-B-B101 Reporting SINR related gNB-DU UP PCMD
...            5GC001756-B-B102 Reporting Timing Advance related gNB-DU UP PCMD
...            5GC001756-B-B201 Reporting gNB-DU UP PCMDs - UP internal changes in deployment
...            5GC001756-D
...            5GC001756-D-B101 Reporting Timing Advance in contention-based RA gNB-DU UP PCMD
...            5GC001756-D-B102 Reporting gNB-DU UP PCMDs - SA user scenarios for legacy PCMDs
...            5GC001756-D-B103 Reporting SINR related gNB-DU UP PCMD in SA mode
...            5GC001756-EA
...            5GC001756-EA-B101 gNB-CU PDU Session Info Record for Initial Context Setup
...            5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
...            5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
...            5GC001756-EA-B104 gNB-CU PDU Session Info Record for Pdu Session Resource Release
...            5GC001756-EA-B106 gNB-CU PDU Session Info Record for Intra-gNB mobility
...            5GC001756-EA-B107 gNB-CU PDU Session Info Record for Inter-gNB mobility
...            5GC001756-EA-B113 gNB-CU UeDuConnectivity Record for Intra-gNB Inter-DU Handover
...            5GC001756-EA-B114 gNB-CU UeDuConnectivity Record for Inter-gNB Handover (Target gNB)
...            5GC001756-EA-B116 gNB-CU UeDuConnectivity Record for RRC Re-establishment with the same gNB-DU
...            5GC001756-EA-B118 gNB-CU UeDuConnectivity Record for Initial Context Setup
...            5GC001756-EA-B119 gNB-CU UeDuConnectivity Record for PDU Session Resource Setup
...            5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
...            5GC001756-EA-B122 gNB-CU UE Setup Record for Intra-gNB mobility
...            5GC001756-EA-B123 gNB-CU UE Setup Record for Inter-gNB mobility
...            5GC001756-EA-B124 gNB-CU UE Setup Record for miscellaneous cases
...            5GC001756-EA-B125 gNB-CU Bearer Record for Initial Context Setup
...            5GC001756-EA-B126 gNB-CU Bearer Record for PDU Session Resource Setup
...            5GC001756-EA-B127 gNB-CU Bearer Record for PDU Session Resource Modification
...            5GC001756-EA-B128 gNB-CU Bearer Record for PDU Session Resource Release
...            5GC001756-EA-B129 gNB-CU Bearer Record for Intra-gNB mobility
...            5GC001756-EA-B130 gNB-CU Bearer Record for Inter-gNB mobility
...            5GC001756-EA-B201 DU UE context setup record reporting - Initial Context Setup
...            5GC001756-EA-B202 DU UE context setup record reporting - Intra/Inter gNB Inter DU HO target
...            5GC001756-EA-B203 DU UE context setup record reporting - Intra gNB Intra DU HO target
...            5GC0017656-G-B1 Uplane - Multiple Bearers reporting
...
...      == AUTHORS ==
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         5GC001756 CFAM
...
...      == HISTORY ==
...         [12.05.2021] - Create Test Suite

Resource    ./resources/5GC001756-EA_PDU_modify_release_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot
Resource    ./resources/5GC001756-verify_keywords.robot

Force Tags    SKIPRUN

#Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R3
#    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    ...    PY36

Suite Setup  Run Setup     #vonr=${True}

*** Variables ***
${LUA_CFG}=     /home/ute/egate_5GC001756_FR2.lua

*** Test Cases ***
# Test commented to disable dry run
#5GC001756-EA PCMD for SA - PDU session modification nonGBR only
#    [Documentation]
#    ...  == DESCRIPTION ==
#    ...  == Info==
#    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
#    ...  Procedure: Successful PDU Session Modification
#    ...             Failure PDU Session Modification
#    ...             Successful PDU Session Release
#    ...
#    ...  PCMD reports:
#    ...     - gNB-CU reports CU PDU Session Info Record after successful PDU Session Modification (Successful QoS Flow addition/deletion)
#    ...     - gNB-CU reports CU PDU Session Info Record after failure PDU Session Modification due to lack of RRC: Reconfiguration Complete
#    ...     - gNB-CU reports CU PDU Session Info Record after successful PDU Session Resource Release
#    ...
#    ...  == Precondition: ==
#    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
#    ...  - UE - Airphone simulator
#    ...  - gNB2 up and running with one SA cell OnAir
#    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU:
#    ...  - TCE is configured in MNL/TCEADM/TCE
#    ...  - NRBTS/actPCMDReport is set to True
#    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
#    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
#    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
#    ...
#    ...  == TESTING TOOLS ==
#    ...  - AirPhone, EPCSIM, UTE
#    ...
#    ...  == TEST ENVIRONMENT ==
#    ...  - gNB classicBTS in SA mode
#    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
#    ...  - UE - Airphone simulator
#    ...
#    ...  == REQUIREMENTS COVERAGE ==
#    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
#    ...
#    ...  == REQUIRED LOGS ==
#    ...    UU, NGAP, NRRRC, PCAP
#    ...
#    ...  == CONTACTS ==
#    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
#    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
#    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
#    ...
#    ...  == REFERENCES ==
#    ...  - Related CFAM US:
#    ...     - 5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
#    ...         - User Scenario#11 PDU Session Resource Modification - QoS Flow Addition - RRC: Reconfiguration Failures
#    ...     - 5GC001756-EA-B104 gNB-CU PDU Session Info Record for Pdu Session Resource Release
#    ...         - User Scenario#2 Successful PDU Session Resource Release for all PDU session(s) for UE
#    ...
#    ...  == HISTORY ==
#    ...         [14.05.2021]  - Created TC
#
#    [Setup]  Prepare test environment EA1
#    [Tags]  EA1     GQC_PLAN:FEATURE:5GC001756
#
#    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
#    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
#    EXPECT FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
#    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
#
#    Attach UE1 to cell1 gNB2
#
#    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
#    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
#    FAIL FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
#    PASS FLOW: UE_1 NR-RRC RRCReconfiguration
#
#    Verify that AMF1 InitialContextSetupRequest contains UERadioCapability
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=initialContextSetup
#    ...     message=InitialContextSetupRequest
#    ...     list_name=PDUSessionResourceSetupListCxtReq
#    ...     element_num=1
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=initialContextSetup
#    ...     message=InitialContextSetupResponse
#    ...     list_name=PDUSessionResourceSetupListCxtRes
#    ...     element_num=1
#
#    Verify in RRCReconfiguration that UE1 1 DRBs were added
#
#    Run keyword and Continue on Failure
#    ...     Verify first PduSessionResourceInfoTraceRecord in test EA1 during ICS procedure
#
#    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS
#
#    Perform command to drop RRC: Reconfiguration Complete message
#
#    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
#    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition but not acknowledged by UE
#    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete not sent
#
#    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list []
#
#    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
#    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition but not acknowledged by UE
#    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete not sent
#
#    Verify in RRCReconfiguration that UE1 1 DRBs were added
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceModify
#    ...     message=PDUSessionResourceModifyRequest
#    ...     list_name=QosFlowAddOrModifyRequestList
#    ...     element_num=1
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceModify
#    ...     message=PDUSessionResourceModifyResponse
#    ...     list_name=PDUSessionResourceFailedToModifyListModRes
#    ...     element_num=1
#
#    Run keyword and Continue on Failure
#    ...     Verify second PduSessionResourceInfoTraceRecord in test EA1 during QoS flow additon
#
#    Reset PCMD database
#
#    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
#    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
#    EXPECT FLOW[timeout=15]: UE_2 NR-RRC UECapabilityEnquiry in optimized ICS procedure
#    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration
#
#    Attach UE2 to cell1 gNB2
#
#    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
#    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
#    FAIL FLOW[timeout=15]: UE_2 NR-RRC UECapabilityEnquiry in optimized ICS procedure
#    PASS FLOW: UE_2 NR-RRC RRCReconfiguration
#
#    Verify that AMF1 InitialContextSetupRequest contains UERadioCapability
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=initialContextSetup
#    ...     message=InitialContextSetupRequest
#    ...     list_name=PDUSessionResourceSetupListCxtReq
#    ...     element_num=1
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=initialContextSetup
#    ...     message=InitialContextSetupResponse
#    ...     list_name=PDUSessionResourceSetupListCxtRes
#    ...     element_num=1
#
#    Verify in RRCReconfiguration that UE2 1 DRBs were added
#
#    Run keyword and Continue on Failure
#    ...     Verify third PduSessionResourceInfoTraceRecord in test EA1 during UE2 ICS procedure
#
#    Clear PCMD records     # must not Reset PCMD database because it deletes saved data
#
#    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
#    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration with DRB addition
#    EXPECT FLOW: UE_2 NR-RRC RRCReconfigurationComplete
#
#    Add to UE2 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list []
#
#    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
#    PASS FLOW: UE_2 NR-RRC RRCReconfiguration with DRB addition
#    PASS FLOW: UE_2 NR-RRC RRCReconfigurationComplete
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceModify
#    ...     message=PDUSessionResourceModifyRequest
#    ...     list_name=QosFlowAddOrModifyRequestList
#    ...     element_num=1
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceModify
#    ...     message=PDUSessionResourceModifyResponse
#    ...     list_name=qosFlowAddOrModifyResponseList
#    ...     element_num=1
#
#    Run keyword and Continue on Failure
#    ...     Verify fourth PduSessionResourceInfoTraceRecord in test EA1 during QoS flow additon
#
#    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS
#
#    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with single QoS flow release
#    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion
#
#    Add to UE2 PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [8]
#
#    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with single QoS flow release
#    PASS FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceModify
#    ...     message=PDUSessionResourceModifyRequest
#    ...     list_name=QosFlowListWithCause
#    ...     element_num=1
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceModify
#    ...     message=PDUSessionResourceModifyResponse
#    ...     list_name=PDUSessionResourceModifyListModRes
#    ...     element_num=1
#
#    Verify in RRCReconfiguration that UE2 1 DRBs were released
#
#    Run keyword and Continue on Failure
#    ...     Verify fifth PduSessionResourceInfoTraceRecord in test EA1 during QoS flow release
#
#    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS
#
#    EXPECT FLOW: AMF1 NGAP pDUSessionResourceRelease with PDU session release
#    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion
#
#    Remove PDU session for UE2
#
#    PASS FLOW: AMF1 NGAP pDUSessionResourceRelease with PDU session release
#    PASS FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion
#
#    Verify in RRCReconfiguration that UE2 1 DRBs were released
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceRelease
#    ...     message=PDUSessionResourceReleaseCommand
#    ...     list_name=PDUSessionResourceToReleaseListRelCmd
#    ...     element_num=1
#
#    Verify number of elements on the list within NGAP message
#    ...     amf_id=1
#    ...     procedure_name=pDUSessionResourceRelease
#    ...     message=PDUSessionResourceReleaseResponse
#    ...     list_name=PDUSessionResourceReleasedListRelRes
#    ...     element_num=1
#
#    Run keyword and Continue on Failure
#    ...     Verify sixth PduSessionResourceInfoTraceRecord in test EA1 during PDU session release
#
#    [Teardown]  Cleanup after test EA1
