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
...         [12.04.2021] - Create Test Suite

Resource    ./resources/5GC001756-EA_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot
Resource    ./resources/5GC001756-verify_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=     ${CURDIR}/config/SA_egate_2c_tdd_LO.lua

*** Test Cases ***
5GC001756-EA PCMD for SA - PDU session release one success and one fail due to lack of RRC ReconfigurationComplete
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure:
    ...     - Successful PDU Session Resource Release for not all PDU sessions for UE  - at least one PDU session remains
    ...     - Unsuccessful PDU session release - UE doesn't respond with RRC Reconfiguration Complete
    ...
    ...  PCMD reports:
    ...     - gNB-CU reports PDU Session Info Record after successful PDU session release
    ...     - gNB-CU DOES NOT report PDU Session Info Record after unsuccessful PDU session release
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU and DU:
    ...  -    TCE is configured in MNL/TCEADM/TCE
    ...  -    NRBTS/actPCMDReport is set to True
    ...  -    NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  -    NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  -    Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  -    NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU/actPcmdReporting is set to True
    ...  -    NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU/NRRESOURCEDU is created for considered NRCELL
    ...  -    Max number of traced UE/Cell is not reached on gNB-DU (NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU/cellMaxActiveUEsTraced)
    ...
    ...  -  Simulated UE1 is configured not to send RRC Reconfiguration Complete during second PDU session release procedure
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
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
    ...  - 5GC001756-EA-B104 gNB-CU PDU Session Info Record for Pdu Session Resource Release
    ...     - User Scenario#1 Successful PDU Session Resource Release for not all PDU sessions for UE  - at least one PDU session remains
    ...     - User Scenario#4 Unsuccessful PDU Session Resource Release
    ...
    ...  == HISTORY ==
    ...         [07.06.2021]  - Created TC

    [Setup]  Prepare test environment C7
    [Tags]  C7    GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 1 PDU Sessions
    EXPECT FLOW: AMF1 NGAP uERadioCapabilityInfoIndication is sent
    EXPECT FLOW: UE_1 NR-RRC UECapabilityEnquiry is sent
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Attach UE1 to cell1 gNB2

    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 1 PDU Sessions
    PASS FLOW: AMF1 NGAP uERadioCapabilityInfoIndication is sent
    PASS FLOW: UE_1 NR-RRC UECapabilityEnquiry is sent
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

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

    Verify first and second PduSessionResourceInfoTraceRecord in testC7

    Clear already collected PCMD reports        # need to clear only records, leaving saved fields

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceRelease with 1 PDU session(s) - one session still remains
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Trigger release first PDU session for UE1

    PASS FLOW: AMF1 NGAP pDUSessionResourceRelease with 1 PDU session(s) - one session still remains
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

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

    Run keyword and Continue on Failure
    ...     Verify third PduSessionResourceInfoTraceRecord in testC7

#    Verify that CU PDU Session Info Record is sent correctly:
#            - "trigger" set to "pduSessionResourceReleaseOperation"
#            - "result" is set to "success"
#            List of successfully released PDU Session with
#                - PDU Session Id
#                - S-NSSAI

    Reset PCMD database

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceRelease with 1 PDU session(s) - one session still remains
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete not sent
    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to radio-connection-with-ue-lost

    Trigger release second PDU session for UE1

    PASS FLOW: AMF1 NGAP pDUSessionResourceRelease with 1 PDU session(s) - one session still remains
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete not sent
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to radio-connection-with-ue-lost

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceRelease
    ...     message=PDUSessionResourceReleaseCommand
    ...     list_name=PDUSessionResourceToReleaseListRelCmd
    ...     element_num=1

    Verify that AMF1 UEContextReleaseRequest contains cause=radio-connection-with-ue-lost

    Run keyword and Continue on Failure
    ...     Verify fourth PduSessionResourceInfoTraceRecord in testC7

    [Teardown]  Run keywords
    ...         Cleanup after test C7   AND
    ...         Reset PCMD database

