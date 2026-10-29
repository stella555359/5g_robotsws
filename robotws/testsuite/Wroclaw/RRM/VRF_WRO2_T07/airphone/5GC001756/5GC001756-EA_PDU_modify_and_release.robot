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
...       - I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com
...
...      == REFERENCES ==
...         5GC001756 CFAM
...
...      == HISTORY ==
...         [12.05.2021] - Create Test Suite
...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)

Resource    ./resources/5GC001756-EA_PDU_modify_release_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot
Resource    ./resources/5GC001756-verify_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/ScoutMonitor.py

Force Tags    CONFIGURED    CRT    P36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
...           RF50    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup     vonr=${True}

*** Variables ***
${LUA_CFG}=     ${CURDIR}/config/SA_egate_2c_tdd_LO.lua

*** Test Cases ***
5GC001756-EA PCMD for SA - PDU session modification nonGBR only
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful PDU Session Modification
    ...             Failure PDU Session Modification
    ...             Successful PDU Session Release
    ...
    ...  PCMD reports:
    ...     - gNB-CU reports CU PDU Session Info Record after successful PDU Session Modification (Successful QoS Flow addition/deletion)
    ...     - gNB-CU reports CU PDU Session Info Record after failure PDU Session Modification due to lack of RRC: Reconfiguration Complete
    ...     - gNB-CU reports CU PDU Session Info Record after successful PDU Session Resource Release
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
    ...         - User Scenario#11 PDU Session Resource Modification - QoS Flow Addition - RRC: Reconfiguration Failures
    ...     - 5GC001756-EA-B104 gNB-CU PDU Session Info Record for Pdu Session Resource Release
    ...         - User Scenario#2 Successful PDU Session Resource Release for all PDU session(s) for UE
    ...
    ...  == HISTORY ==
    ...         [14.05.2021]  - Created TC
    ...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)

    [Setup]  Prepare test environment EA1
    [Tags]  EA1     GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Attach UE1 to cell1 gNB2

    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    FAIL FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify that AMF1 InitialContextSetupRequest contains UERadioCapability
    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=1

    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Run keyword and Continue on Failure
    ...     Verify first PduSessionResourceInfoTraceRecord in test EA1 during ICS procedure

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

    Perform command to drop RRC: Reconfiguration Complete message

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition but not acknowledged by UE
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete not sent

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition but not acknowledged by UE
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete not sent

    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=PDUSessionResourceFailedToModifyListModRes
    ...     element_num=1

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#	        - "trigger" set to "PDUsessionModifyOperation"
#	        - "result" is set to "failed"
#	        - Failed to Modified PDU Session with
#	            - PDU Session Id
#	            - S-NSSAI
#	            - PDU Session Aggregated Maximum Bit Rate
#	            - List of failed to setup QOS Flows with QFI, Non-dynamic 5QI,
#	            - ARP and GBR QoS Information in case of GBR QoS Flow presence

    Run keyword and Continue on Failure
    ...     Verify second PduSessionResourceInfoTraceRecord in test EA1 during QoS flow additon

    Reset PCMD database

    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW[timeout=15]: UE_2 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration

    Attach UE2 to cell1 gNB2

    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    FAIL FLOW[timeout=15]: UE_2 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    PASS FLOW: UE_2 NR-RRC RRCReconfiguration

    Verify that AMF1 InitialContextSetupRequest contains UERadioCapability
    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=1

    Verify in RRCReconfiguration that UE2 1 DRBs were added

    Run keyword and Continue on Failure
    ...     Verify third PduSessionResourceInfoTraceRecord in test EA1 during UE2 ICS procedure

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration with DRB addition
    EXPECT FLOW: UE_2 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE2 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    PASS FLOW: UE_2 NR-RRC RRCReconfiguration with DRB addition
    PASS FLOW: UE_2 NR-RRC RRCReconfigurationComplete

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=qosFlowAddOrModifyResponseList
    ...     element_num=1

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "PDUsessionModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

    Run keyword and Continue on Failure
    ...     Verify fourth PduSessionResourceInfoTraceRecord in test EA1 during QoS flow additon

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with single QoS flow release
    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion

    5GC001756-common_keywords.Add to UE2 PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [8]

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with single QoS flow release
    PASS FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowListWithCause
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=PDUSessionResourceModifyListModRes
    ...     element_num=1

    Verify in RRCReconfiguration that UE2 1 DRBs were released

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "PDUsessionModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of released QoS Flow with QFI

    Run keyword and Continue on Failure
    ...     Verify fifth PduSessionResourceInfoTraceRecord in test EA1 during QoS flow release

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceRelease with PDU session release
    EXPECT FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion

    Remove PDU session for UE2

    PASS FLOW: AMF1 NGAP pDUSessionResourceRelease with PDU session release
    PASS FLOW: UE_2 NR-RRC RRCReconfiguration with DRB deletion

    Verify in RRCReconfiguration that UE2 1 DRBs were released
    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceRelease
    ...     message=PDUSessionResourceReleaseCommand
    ...     list_name=PDUSessionResourceToReleaseListRelCmd
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceRelease
    ...     message=PDUSessionResourceReleaseResponse
    ...     list_name=PDUSessionResourceReleasedListRelRes
    ...     element_num=1

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "PDUsessionReleaseRequest"
#        - "result" is set to "success"
#	     - List of successfully released PDU Sessions with respective
#	         - PDU Session Id
#	         - S-NSSAI

    Run keyword and Continue on Failure
    ...     Verify sixth PduSessionResourceInfoTraceRecord in test EA1 during PDU session release

    [Teardown]  Run keywords
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal    AND
    ...         Cleanup after test EA1

5GC001756-EA PCMD for SA - PDU session modification with GBR
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful PDU Session Modification
    ...             Successful PDU Session Modification - QoS Flow Modification
    ...             Failure PDU Session Modification
    ...
    ...  PCMD reports:
    ...     - gNB-CU reports CU PDU Session Info Record after successful PDU Session Modification (Successful QoS Flow addition)
    ...     - gNB-CU reports CU PDU Session Info Record after failure PDU Session Modification due to lack of RRC: Reconfiguration Complete
    ...     - gNB-CU reports CU PDU Session Info Record after Successful PDU Session Resource Modification - QoS Flow Modification
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU and DU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - MRBTS/NRBTS/NRCELL.actVoNR is set to 'true' for cell
    ...  - MRBTS/NRBTS/NRDRB_5QI objects are configured for 5QI-1, 5QI-2 and 5QI-5
    ...  - UE1 is VoNR capable in FR1
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
    ...         - User Scenario#2 Successful PDU Session Resource Modification - QoS Flow Modification
    ...         - User Scenario#11 PDU Session Resource Modification - QoS Flow Addition - RRC: Reconfiguration Failures
    ...
    ...  == HISTORY ==
    ...         [14.05.2021]  - Created TC
    ...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)

    [Setup]  Prepare test environment EA2
    [Tags]  EA2     GQC_PLAN:FEATURE:5GC001756
    Execute egate command    cmd=qosflow_modify qos_flow=1 mfbr_dl=100 mfbr_ul=100

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully

    Run keyword and Continue on Failure
    ...     Verify first PduSessionResourceInfoTraceRecord in test EA2 during ICS procedure

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=1
    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=qosFlowAddOrModifyResponseList
    ...     element_num=1

    Verify in NGAP that GBR QoS flow was successfully added to existed PDU session for UE1
    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Run keyword and Continue on Failure
    ...     Verify second PduSessionResourceInfoTraceRecord in test EA2 during GBR QoS Flow addition

    Clear PCMD records

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "PDUsessionModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow MFBR modification
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration with QoS Flow MFBR modification

    Modify existed QoS Flow for UE1 PDU1 session

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow MFBR modification
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration with QoS Flow MFBR modification

    Verify in NGAP that QoS flow was successfully modified for UE1

    Run keyword and Continue on Failure
    ...     Verify third PduSessionResourceInfoTraceRecord in test EA2 during MFBR modification

    Clear PCMD records

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#         - "trigger" set to "PDUsessionModifyOperation"
#         - "result" is set to "success"
#         - Modified PDU Session with
#             - PDU Session Id
#             - S-NSSAI
#             - PDU Session Aggregated Maximum Bit Rate
#             - List of successfully modified QOS Flows with QFI, Non-dynamic 5QI,
#             - ARP and GBR QoS Information in case of GBR QoS Flow presence

    Perform command to drop RRC: Reconfiguration Complete message
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow modification
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration with QoS Flow addition with 5QI2
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [2] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow modification
    PASS FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration with QoS Flow addition with 5QI2
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete

    Verify in NGAP that GBR QoS flow was unsuccessfully added to existed PDU session for UE1 due to lack of RRC: Reconfiguration Complete

    Run keyword and Continue on Failure
    ...     Verify fourth PduSessionResourceInfoTraceRecord in test EA2 during failed GBR QoS Flow addition

#	     - "trigger" set to "PDUsessionModifyOperation"
#	     - "result" is set to "failed"
#	     - Failed to Modified PDU Session with
#	         - PDU Session Id
#	         - S-NSSAI
#	         - PDU Session Aggregated Maximum Bit Rate
#	         - List of failed to setup QOS Flows with QFI, Non-dynamic 5QI,
#	         - ARP and GBR QoS Information in case of GBR QoS Flow prese


    [Teardown]  Run keywords
	...         Cleanup after test EA2    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - PDU session multiple QoS Flows modifications
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful PDU Session Modification with multiple QoS Flows
    ...
    ...  PCMD reports:
    ...     - gNB-CU reports CU PDU Session Info Record after successful PDU Session Resource Modification:
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU and DU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - MRBTS/NRBTS/NRCELL.actVoNR is set to 'true' for cell
    ...  - MRBTS/NRBTS/NRDRB_5QI objects are configured for 5QI-1, 5QI-2 and 5QI-5
    ...  - UE1 is VoNR capable in FR1
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
    ...         - User Scenario#1 Successful PDU Session Resource Modification - Simultaneous QoS Flow Addition and Deletion
    ...
    ...  == HISTORY ==
    ...         [20.05.2021]  - Created TC
    ...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)

    [Setup]  Prepare test environment EA3
    [Tags]  EA3     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully

    Run keyword and Continue on Failure
    ...     Verify first PduSessionResourceInfoTraceRecord in test EA3 during ICS procedure

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

# succ modification with 2 added qos flows

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [8,9] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows addition
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs addition
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=2

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=qosFlowAddOrModifyResponseList
    ...     element_num=2

    Verify in NGAP that 2 QoS flows were successfully added to existed PDU session for UE1
    Verify in RRCReconfiguration that UE1 2 DRBs were added

    Run keyword and Continue on Failure
    ...     Verify second PduSessionResourceInfoTraceRecord in test EA3 during 2 QoS Flows addition

    Clear PCMD records

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "pduSessionResourceModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

# succ modification with 2 deleted qos flows

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [8,9]

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify in NGAP that 2 QoS flows were successfully deleted from existed PDU session for UE1
    Verify in RRCReconfiguration that UE1 2 DRBs were released

    Run keyword and Continue on Failure
    ...         Verify third PduSessionResourceInfoTraceRecord in test EA3 during 2 QoS Flows deletion

    Clear PCMD records

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "pduSessionResourceModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

# succ modification with 2 added and 1 deleted flow

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 1 DRB addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 1 DRB addition
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Run keyword and Continue on Failure
    ...         Verify fourth PduSessionResourceInfoTraceRecord in test EA3 during 1 QoS Flow addition

    Clear PCMD records

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows addition and 1 QoS Flow deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs addition and 1 DRB deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [1,2] and delete QoS flows with 5QI from list [8]

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows addition and 1 QoS Flow deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs addition and 1 DRB deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=2

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=qosFlowAddOrModifyResponseList
    ...     element_num=2

    Verify in NGAP that 2 QoS flows were added and 1 deleted from existed PDU session for UE1
    Verify in RRCReconfiguration that UE1 2 DRBs were added
    Verify in RRCReconfiguration that UE1 1 DRBs were released

    Run keyword and Continue on Failure
    ...     Verify fifth PduSessionResourceInfoTraceRecord in test EA3 during 2 QoS Flows addition and 1 QoS Flow deletion

    Clear PCMD records

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "pduSessionResourceModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

# succ modification with non-gbr and gbr bearer added

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [1,2]

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify in NGAP that 2 QoS flows were successfully deleted from existed PDU session for UE1
    Verify in RRCReconfiguration that UE1 2 DRBs were released

    Run keyword and Continue on Failure
    ...     Verify sixth PduSessionResourceInfoTraceRecord in test EA3 during 2 QoS Flows deletion

    Clear PCMD records

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [1,9] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 2 QoS Flows addition
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRBs addition
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=2

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=qosFlowAddOrModifyResponseList
    ...     element_num=2

    Verify in RRCReconfiguration that UE1 2 DRBs were added

    Run keyword and Continue on Failure
    ...     Verify seventh PduSessionResourceInfoTraceRecord in test EA3 during 2 QoS Flows addition

    Clear PCMD records

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "pduSessionResourceModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

    Perform command to drop RRC: Reconfiguration Complete message

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition and 1 QoS Flow deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 1 DRBs addition and 1 DRB deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [6] and delete QoS flows with 5QI from list [9]

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition and 1 QoS Flow deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 1 DRBs addition and 1 DRB deletion
    FAIL FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=PDUSessionResourceFailedToModifyListModRes
    ...     element_num=1

    Verify in RRCReconfiguration that UE1 1 DRBs were added
    Verify in RRCReconfiguration that UE1 1 DRBs were released

    Run keyword and Continue on Failure
    ...     Verify eighth PduSessionResourceInfoTraceRecord in test EA3 during 1 QoS Flow addition and 1 deletion

    Clear PCMD records

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "pduSessionResourceModifyOperation"
#        - "result" is set to "failure"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

    [Teardown]  Run keywords
    ...         Cleanup after test EA3    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - multiple PDU sessions modification
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Simultaneously add and delete one or more Non-dynamic QoS Flows for more than one PDU sessions
    ...
    ...  PCMD reports:
    ...     -   gNB-CU reports CU PDU Session Info Record after simultaneously add and delete one QoS Flow for more than one PDU sessions
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU and DU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU/actPcmdReporting is set to True
    ...  - NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU/NRRESOURCEDU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-DU (NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU/cellMaxActiveUEsTraced)
    ...  - MRBTS/NRBTS/NRCELL.actVoNR is set to 'true' for cell
    ...  - MRBTS/NRBTS/NRDRB_5QI objects are configured for 5QI-1, 5QI-2 and 5QI-5
    ...  - UE1 is VoNR capable in FR1
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
    ...         - User Scenario#1 Successful PDU Session Resource Modification - Simultaneous QoS Flow Addition and Deletion
    ...             - Alternate Scenario#1 Simultaneously add and delete one or more Non-dynamic QoS Flows for more than one PDU sessions
    ...
    ...  == HISTORY ==
    ...         [20.07.2021]  - Created TC
    ...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)

    [Setup]  Prepare test environment EA4
    [Tags]  EA4     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully
    Run keyword and Continue on Failure         Verify first PduSessionResourceInfoTraceRecord in test EA4 during ICS procedure

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 second PDU session with one QoS flow

    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupRequest
    ...     list_name=PDUSessionResourceSetupListSUReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupResponse
    ...     list_name=PDUSessionResourceSetupListSURes
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupRequest
    ...     list_name=QosFlowSetupRequestList
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupResponse
    ...     list_name=associatedQosFlowList
    ...     element_num=1

    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Run keyword and Continue on Failure
    ...     Verify second PduSessionResourceInfoTraceRecord in test EA4 during second PDU session setup

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition per each PDU session
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Simultaneously add one QoS Flow for more than one PDU sessions for UE

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition per each PDU session
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify that QoS flow was successfully added to multiple PDU sessions for UE1
    Verify in RRCReconfiguration that UE1 2 DRBs were added

    Run keyword and Continue on Failure
    ...         Verify third PduSessionResourceInfoTraceRecord in test EA4 during QoS Flows addition to many PDU sessions

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "PDUsessionModifyOperation"
#        - "result" is set to "success"
#        - Modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition in PDU1 and 1 QoS Flow deletion in PDU2
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Simultaneously add and delete QoS Flows for more than one PDU sessions for UE
    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 1 QoS Flow addition in PDU1 and 1 QoS Flow deletion in PDU2
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify that QoS flow was successfully added and deleted to multiple PDU sessions for UE1
    Verify in RRCReconfiguration that UE1 1 DRBs were added
    Verify in RRCReconfiguration that UE1 1 DRBs were released

    Run keyword and Continue on Failure
    ...         Verify fourth PduSessionResourceInfoTraceRecord in test EA4 during QoS Flows addition to many PDU sessions

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "PDUsessionModifyOperation"
#        - "result" is set to "success"
#        - Successfully modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information
#            - List of released QoS Flow with QFI

    [Teardown]  Run keywords
    ...         Cleanup after test EA    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - PDU session modification failure with Re-establishment
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: PDU Session Modification with RRC Reconfiguration Failure occured during QoS Flow deletion
    ...
    ...  PCMD reports:
    ...     -   gNB-CU reports CU PDU Session Info Record is not reported if RRC Reconfiguration Failure occured during QoS Flow deletion
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU and DU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - MRBTS/NRBTS/NRCELL.actVoNR is set to 'true' for cell
    ...  - MRBTS/NRBTS/NRDRB_5QI objects are configured for 5QI-1, 5QI-2 and 5QI-5
    ...  - UE1 is VoNR capable in FR1
    ...  - NRBTS-1/rrcReestabTypeSA is set to 'viaRRCSetup'
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
    ...         - User Scenario#12 PDU Session Resource Modification - QoS Flow Delete - RRC Reconfiguration Failure with RRC Re-establishment
    ...
    ...  == HISTORY ==
    ...         [26.08.2021]  - Created TC
    ...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)

    [Setup]  Prepare test environment EA5
    [Tags]  EA5     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully

    Run keyword and Continue on Failure
    ...         Verify first PduSessionResourceInfoTraceRecord in test EA5 during ICS procedure

    Clear PCMD records     # must not Reset PCMD database because it deletes saved data from ICS

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow addition
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with DRB addition
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyRequest
    ...     list_name=QosFlowAddOrModifyRequestList
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceModify
    ...     message=PDUSessionResourceModifyResponse
    ...     list_name=qosFlowAddOrModifyResponseList
    ...     element_num=1

    Verify in NGAP that GBR QoS flow was successfully added to existed PDU session for UE1
    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Run keyword and Continue on Failure
    ...         Verify second PduSessionResourceInfoTraceRecord in test EA5 during GBR QoS Flow addition

    Clear PCMD records

    Set command for UE_1 to perform reestablishment with reconfigurationFailure

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with GBR QoS Flow deletion
    EXPECT FLOW: gNB2 E1AP bearerContextModification with GBR QoS Flow deletion
    EXPECT FLOW: gNB2 F1AP uEContextModification with GBR QoS Flow deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with DRB deletion
    EXPECT FLOW: UE_1 NR-RRC RRCReestablishmentRequest as response on DRB deletion
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete
    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due drop of RRCReconfiguration
    start collecting syslog         prefix=reestab
    5GC001756-common_keywords.Add to UE1 PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [1]

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with GBR QoS Flow deletion
    PASS FLOW: gNB2 E1AP bearerContextModification with GBR QoS Flow deletion
    PASS FLOW: gNB2 F1AP uEContextModification with GBR QoS Flow deletion
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with DRB deletion
    PASS FLOW: UE_1 NR-RRC RRCReestablishmentRequest as response on DRB deletion
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due drop of RRCReconfiguration

    Verify that PDU session was not successfully modify for UE1 due to reestablishment
    stop collecting syslog
    Run keyword and Continue on Failure
    ...     Verify third PduSessionResourceInfoTraceRecord in test EA5 during interupted GBR deletion will not occur

#    Verify that gNB-CU PDU Session Info Record is not reported

    [Teardown]  Run Keywords
    ...     Cleanup after test EA5     AND
    ...     Restart Scout Monitoring On Test Line If Needed    AND
    ...     Add Scout External Execution ID To Reporting Portal    AND
    ...     Run keyword and ignore error     Restore AP to usability
