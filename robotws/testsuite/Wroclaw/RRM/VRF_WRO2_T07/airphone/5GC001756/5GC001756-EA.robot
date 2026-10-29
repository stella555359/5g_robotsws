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
...      == CONTACTS ==
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
...         [07.04.2021] - initial creation (Agnieszka Wlodarczyk)
...         [12.04.2021] - Created TC (Agnieszka Wlodarczyk)
...         [20.10.2021] - review done

Resource    ./resources/5GC001756-EA_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot
Resource    ./resources/5GC001756-verify_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/ScoutMonitor.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
...           RF50    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=     ${CURDIR}/config/SA_egate_2c_tdd_LO.lua

*** Test Cases ***
5GC001756-EA PCMD for SA - ICS without PDU session then initial PDU session setup success
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful Initial Context Setup without PDU session
    ...             Successful Initial PDU Session Setup with one subsequent PDU session
    ...
    ...  PCMD reports:
    ...     - gNB-CU doesn't report CU PDU Session Info Record after successful Initial Context Setup without PDU session
    ...     - gNB-CU reports CU PDU Session Info Record after successful Initial PDU Session Setup with one PDU session
    ...     - gNB-CU reports CU UE Setup Record after successful Initial Context Setup without PDU session
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-cellDepType is set to SA
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for CU and DU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - SERVEDAMF-1 has one unique GUAMI - 311:489:1:2:1
    ...
    ...  == Postcondition: ==
    ...  - gNB up and running
    ...  - gNB-CU PDU Session Info Record for the UE1 has not been reported to TCE after UE1 attach without PDU session
    ...  - gNB-CU PDU Session Info Record with PDU Session requested to setup by AMF via NGAP: PDU SESSION RESOURCE
    ...    SETUP REQ has been reported to TCE for the UE1
    ...  - gNB-CU reports to TCE UE Setup Record for the UE1
    ...  - Trace Recording Session for SA UE with possibly others PCMD records is reported to TCE and terminated at end
    ...    of UE call in the cell
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036,5G_RAN_USR_COM_3037
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
    ...     - 5GC001756-EA-B101 gNB-CU PDU Session Info Record for Initial Context Setup
    ...         - User Scenario#1 Initial Context Setup without PDU session
    ...     - 5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
    ...         - User Scenario#1 Successful PDU Session Resource Setup - 5GC requests initial PDU Session to be setup for the UE
    ...     - 5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
    ...         - User Scenario#1 Initial Context Setup without PDU session
    ...
    ...  HISTORY:
    ...         [12.04.2021] - TC Created
    ...         [20.10.2021] - review done
    ...         [07.04.2022] - makielty: VRAN2.0 passed on TL SKA, SW build: vCUCNF22R3_0.250.4303;vDUCNF22R3_0.300.5161

    [Setup]  Prepare test environment C1
    [Tags]  C1    GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    EXPECT FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure

    Attach UE1 without PDU session to gNB2 cell1

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    PASS FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    PASS FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure

    Verify that AMF1 NGAP InitialContextSetup does not contain any PDU session

    Run keyword and Continue on Failure     Verify CuUeSetupTraceRecord in testC1

#    Verify that gNB-CU PDU Session Info Record is not sent

#    Verify that gNB-CU UE Setup Record is sent correctly:
#    	"result" set to "success"
#    	"UE setup reason" set to "other"
#    	RAN UE NGAP ID
#    	AMF UE NGAP ID
#    	Globally Unique AMF ID

    Clear PCMD records

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 initial PDU session with one QoS flow

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

    Run keyword and Continue on Failure        Verify PduSessionResourceInfoTraceRecord in testC1

#    Verify that gNB-CU PDU Session Info Record is sent correctly:
#         - "trigger" set to "PDUsessionSetupRequest"
#         - "result" is set to "success"
#         - Successfully established PDU Session with
#             - PDU Session Id
#             - S-NSSAI
#             - PDU Session Aggregated Maximum Bit Rate
#             - List of successfully setup QOS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information in case of GBR QoS Flow presence

    Detach UE1

    [Teardown]  Run keywords
    ...         Cleanup after test C1   AND
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - ICS with PDU session then subsequent PDU session addition and modification success
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful Initial Context Setup with one or multiple PDU sessions
    ...             Successful PDU Session Setup with one PDU session
    ...             Successful PDU Session Resource Modification (Additional QoS Flow add to PDU session)
    ...
    ...  PCMD reports:
    ...     gNB-CU reports CU PDU Session Info Record after successful Initial Context Setup with one or multiple PDU sessions
    ...     gNB-CU reports CU PDU Session Info Record after successful subsequent PDU Session Setup with one PDU session
    ...     gNB-CU reports CU PDU Session Info Record after add one QoS Flow for PDU session
    ...     gNB-CU reports CU UE Setup Record after successful Initial Context Setup with multiple PDU sessions
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
    ...
    ...  == Precondition: ==
    ...  - gNB up and running
    ...  - gNB-CU PDU Session Info Record for the SA UE1 has been reported to TCE
    ...  - gNB-CU reports to TCE UE Setup Record for the UE1
    ...  - gNB-CU should stop SA UE Trace Recording Session at end of UE1 call in the cell
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036,5G_RAN_USR_COM_3037
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
    ...  - 5GC001756-EA-B101 gNB-CU PDU Session Info Record for Initial Context Setup
    ...         User Scenario#2 Initial Context Setup with one or multiple PDU session(s)
    ...  - 5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
    ...         User Scenario#2 Successful PDU Session Resource Setup - 5GC requests subsequent PDU Session(s) to be setup for the UE
    ...  - 5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
    ...         User Scenario#1 Successful PDU Session Resource Modification (Additional QoS Flow add to PDU session)
    ...  - 5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
    ...         User Scenario#2 Initial Context Setup with one or multiple PDU session(s)
    ...
    ...  == HISTORY ==
    ...         [12.04.2021]  - Created TC
    ...         [20.10.2021] - review done

    [Setup]  Run keywords    Prepare test environment C2
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/testC2
    [Tags]  C2    GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Attach UE1 to cell1 gNB2

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    FAIL FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify that AMF1 InitialContextSetupRequest contains UERadioCapability
    Verify during initialContextSetup that AMF1 initial PDU session with one QoS flow was added successfully
    Verify in RRCReconfiguration that UE1 1 DRBs were added

#    Verify that CU PDU Session Info Record is sent correctly:
#        "trigger" set to "PDUsessionSetupRequest"
#        "result" is set to "success"
#        Successfully established one PDU Session with:
#           PDU Session Id
#           S-NSSAI
#           PDU Session Aggregated Maximum Bit Rate
#           List of successfully setup QOS Flows with QFI, 5QI and ARP

#    Verify that gNB-CU UE Setup Record is sent correctly:
#         - "result" set to "success"
#         - "UE setup reason" set to "other"
#         - RAN UE NGAP ID
#         - AMF UE NGAP ID
#         - Globally Unique AMF ID

    Run keyword and Continue on Failure
    ...     Verify first CuUeSetupTraceRecord,PduSessionResourceInfoTraceRecord PCMD records in testC2

    Reset PCMD database

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

    Run keyword and Continue on Failure        Verify second PduSessionResourceInfoTraceRecord PCMD records in testC2

    Remove all records for verification

    Clear PCMD records                 # must clear record beaucause next record is the same type

#    Verify that CU PDU Session Info Record is sent correctly:
#        "trigger" set to "PDUsessionSetupRequest"
#        "result" is set to "success"
#        Successfully established one PDU Session with:
#           PDU Session Id
#           S-NSSAI
#           PDU Session Aggregated Maximum Bit Rate
#           List of successfully setup QOS Flows with QFI, 5QI and ARP

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with 1 Qos Flow addition
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 QoS flow to second PDU session

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with 1 Qos Flow addition
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

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

    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Run keyword and Continue on Failure        Verify third PduSessionResourceInfoTraceRecord PCMD records in testC2

#    Verify that gNB-CU PDU Session Info Record is sent correctly:
#        "trigger" set to "PDUsessionModifyOperation"
#        "result" is set to "success"
#        Modified PDU Session with
#            PDU Session Id
#            S-NSSAI
#            PDU Session Aggregated Maximum Bit Rate
#            List of successfully setup QOS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information in case of GBR QoS Flow presence

    Reset PCMD database

    EXPECT FLOW[timeout=70]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to inactivity
    PASS FLOW[timeout=70]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to inactivity
    Verify that AMF1 UEContextReleaseRequest contains cause=user-inactivity

    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 2 PDU Sessions
#    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
#    EXPECT FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Trigger UE1 idle mode exit

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 2 PDU Sessions
#    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
#    FAIL FLOW[timeout=15]: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify that AMF1 InitialContextSetupRequest contains UERadioCapability

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=2

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=2

    Verify that for AMF1 in InitialContextSetupResponse 1 QoS flow for first PDU session and 2 QoS flows for second PDU session were created
    Verify in RRCReconfiguration that UE1 3 DRBs were added

    Run keyword and Continue on Failure     Verify fourth PduSessionResourceInfoTraceRecord PCMD records in testC2

#    Verify that CU PDU Session Info Record is sent correctly:
#        "trigger" set to "PDUsessionSetupRequest"
#        "result" is set to "success"
#        Successfully established one PDU Session with:
#           PDU Session Id
#           S-NSSAI
#           PDU Session Aggregated Maximum Bit Rate
#           List of successfully setup QOS Flows with QFI, 5QI and ARP

#    Verify that gNB-CU UE Setup Record is sent correctly:
#         - "result" set to "success"
#         - "UE setup reason" set to "other"
#         - RAN UE NGAP ID
#         - AMF UE NGAP ID
#         - Globally Unique AMF ID

    Detach UE1

    [Teardown]  Run keywords
    ...         Stop Default Logging     output_dirpath=${OUTPUT_DIR}/testC2    check_errors_or_warnings=both     AND
    ...         Cleanup after test C2   AND
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - ICS fail Emergency Fallback
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is verification that gNB-CU and gNB-DU report correctly PCMD reports during below procedures:
    ...  Procedure: Unsuccessful Initial Context Setup
    ...
    ...  PCMD reports:
    ...     gNB-CU reports UE Setup Record after unsuccessful Initial Context Setup (Emergency Fallback Indicator included in ICS)
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
    ...  - MRBTS.NRBTS.actRedirect = true (5GC000708 is enabled)
    ...  - MRBTS.NRBTS.actNormVCFallback = true (5GC000749 is enabled)
    ...  - MRBTS.NRBTS.NRCELL.NRREDRT is configured with redirRat = 1 (EUTRA target)
    ...
    ...  == Postcondition: ==
    ...	 - gNB up and running
    ...	 - gNB-CU UE Setup Record for the SA UE1 have been reported to TCE
    ...	 - gNB-CU should stop SA UE Trace Recording Session at end of UE1 in the cell
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_COM_3037
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
    ...         - 5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
    ...                 User Scenario#15 Unsuccessful Initial Context Setup with PDU Session - UE Capability Check
    ...                 failed during Emergency Fallback
    ...
    ...  == HISTORY ==
    ...         [12.04.2021]  - Created TC
    ...         [20.10.2021] - review done

    [Setup]  Run keywords    Prepare test environment C3
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/testC3
    [Tags]  C3    GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: UE_1 NR-RRC RRCSetupRequest
    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetupFailure optimized version with 1 PDU Sessions and emergency FB
    EXPECT FLOW: AMF1 NGAP uEContextRelease

    Attach UE1 to cell1 gNB2

    PASS FLOW: UE_1 NR-RRC RRCSetupRequest
    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetupFailure optimized version with 1 PDU Sessions and emergency FB
    PASS FLOW: AMF1 NGAP uEContextRelease

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetupFailure
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetupFailure
    ...     message=InitialContextSetupFailure
    ...     list_name=PDUSessionResourceFailedToSetupListCxtFail
    ...     element_num=1

    Verify that UE1 RRCSetupRequest establishmnet cause is set to EMERGENCY
    Verify during initialContextSetupFailure AMF1 NGAP ICS contains Emergency Fallback Indicator IE
    Verify that AMF1 InitialContextSetupFailure is sent with Radio Network Layer cause: Unspecified

    Run keyword and Continue on Failure
    ...     Verify CuUeSetupTraceRecord and PduSessionResourceInfoTraceRecord PCMD records in testC3

#    Verify that gNB-CU UE Setup Record is sent correctly:
#         - "result" set to "miscFailure"
#         - "UE setup reason" set to "other"
#         - RAN UE NGAP ID
#         - AMF UE NGAP ID
#         - Globally Unique AMF ID

    [Teardown]  Run keywords    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/testC3    check_errors_or_warnings=both    AND
    ...         Cleanup after test C3   AND
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - ICS fail lack of RRC ReconfigurationComplete
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Unsuccessful attach - UE doesn't respond with RRC Reconfiguration Complete
    ...
    ...  PCMD reports:
    ...     - gNB-CU reports PDU Session Info Record after unsuccessful Initial Context Setup (lack of RRC Reconfiguration Complete)
    ...     - gNB-CU reports UE Setup Record after unsuccessful Initial Context Setup (lack of RRC Reconfiguration Complete)
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
    ...
    ...  == Postcondition: ==
    ...  - gNB up and running
    ...  - gNB-CU PDU Session Info Record for the UE1 has been reported to TCE
    ...  - gNB-CU UE Setup Record for the SA UE1 have been reported to TCE
    ...  - gNB-CU should stop UE Trace Recording Session at end of UE1 call in the cell
    ...
    ...  - Simulated UE1 is configured to not send RRC Reconfiguration Complete
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036,5G_RAN_USR_COM_3037
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
    ...     - 5GC001756-EA-B101 gNB-CU PDU Session Info Record for Initial Context Setup
    ...         - User Scenario#14 Unsuccessful Initial Context Setup with PDU Session - lack of RRC:ReconfigurationComplete
    ...     - 5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
    ...         - User Scenario#14 Unsuccessful Initial Context Setup with PDU Session - lack of RRC:ReconfigurationComplete
    ...
    ...  == HISTORY ==
    ...         [12.04.2021]  - Created TC
    ...         [20.10.2021] - review done

    [Setup]  Prepare test environment C4
    [Tags]  C4    GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetupFailure optimized version with 1 PDU Sessions
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete
    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to failure-in-radio-interface-procedure

    Attach UE1 to cell1 gNB2

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetupFailure optimized version with 1 PDU Sessions
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to failure-in-radio-interface-procedure

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetupFailure
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetupFailure
    ...     message=InitialContextSetupFailure
    ...     list_name=PDUSessionResourceFailedToSetupListCxtFail
    ...     element_num=1

    Verify that AMF1 NGAP InitialContextSetupFailure contains cause: radioNetwork failure-in-radio-interface-procedure
    Verify that AMF1 UEContextReleaseRequest contains cause=failure-in-radio-interface-procedure

    Run keyword and Continue on Failure
    ...     Verify CuUeSetupTraceRecord and PduSessionResourceInfoTraceRecord PCMD records in testC4

#    Verify that CU PDU Session Info Record is sent correctly:
#        "trigger" set to "PDUsessionSetupRequest"
#        result is set to "miscFailure"
#        Failed to setup one PDU session with:
#            PDU Session Id
#            S-NSSAI
#            PDU Session Aggregated Maximum Bit Rate
#            List of failed to setup QOS Flows with QFI, Non-dynamic 5QI, ARP and
#            GBR QoS Information in case of GBR QoS Flow presence

#    Verify that gNB-CU UE Setup Record is sent correctly:
#         - "result" set to "miscFailure"
#         - "UE setup reason" set to "other"
#         - RAN UE NGAP ID
#         - AMF UE NGAP ID
#         - Globally Unique AMF ID

    [Teardown]  Run keywords
    ...         Cleanup after test C4   AND
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - multiple PDU sessions setup success
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful PDU Session Setup with multiple PDU sessions
    ...
    ...  PCMD reports:
    ...     -   gNB-CU reports CU PDU Session Info Record after successful subsequent PDU Session Setup (multiple PDU sessions)
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
    ...     - 5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
    ...         - User Scenario#2 Successful PDU Session Resource Setup - 5GC requests subsequent PDU Session(s) to be setup for the UE
    ...         - Alternate Scenario#1 Successful PDU Session Resource Setup - 5GC requests more than one subseqent PDU Sessions
    ...           (only with Non-dynamic QoS Flows) to be setup for the UE
    ...
    ...  == HISTORY ==
    ...         [12.04.2021]  - Created TC
    ...         [20.10.2021] - review done

    [Setup]  Prepare test environment C5
    [Tags]  C5    GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    EXPECT FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure

    Attach UE1 without PDU session to gNB2 cell1

    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    PASS FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    PASS FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure

    Verify that AMF1 NGAP InitialContextSetup does not contain any PDU session

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 initial PDU session with one QoS flow

    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 second PDU session with one QoS flow

    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to radio-connection-with-ue-lost reason
    Trigger UE1 to enter idle mode
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to radio-connection-with-ue-lost reason
    Verify that AMF1 UEContextReleaseRequest contains cause=radio-connection-with-ue-lost

    Reset PCMD database
    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    EXPECT FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 2 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRB IDs

    Trigger UE1 idle mode exit

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    PASS FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    PASS FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure
    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 2 PDU session(s)
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with 2 DRB IDs

    Verify that AMF1 NGAP InitialContextSetup does not contain any PDU session

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupRequest
    ...     list_name=PDUSessionResourceSetupListSUReq
    ...     element_num=2

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupResponse
    ...     list_name=PDUSessionResourceSetupListSURes
    ...     element_num=2

    Verify in RRCReconfiguration that UE1 2 DRBs were added

    Run keyword and Continue on Failure     Verify PduSessionResourceInfoTraceRecord and CuUeSetupTraceRecord PCMD records in testC5

#    Verify that gNB-CU PDU Session Info Record is sent correctly:
#        "trigger" set to "PDUsessionSetupRequest"
#        "result" is set to "success"
#        Successfully established PDU Session with
#            PDU Session Id
#            S-NSSAI
#            PDU Session Aggregated Maximum Bit Rate
#            List of successfully setup QOS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information in case of GBR QoS Flow presence

    Detach UE1

    [Teardown]  Run keywords
    ...         Cleanup after test C5   AND
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - PDU session setup fail admission control
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Unsuccessful PDU Session Setup with one PDU session (due to addmission control)
    ...
    ...  PCMD reports:
    ...     -   gNB-CU reports CU PDU Session Info Record after unsuccessful additioan PDU Session Setup (admission control failed):
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
    ...
    ...  - Admission Control is configured to allow setup only one SA UE with one nonGBR bearer:
    ...     - MRBTS-1/NRBTS-1/NRCELL-1 maxNumOfRrcSA = 1
    ...     - MRBTS-1/NRBTS-1/NRCELL-1 maxNumOfNonGBRBearersSA = 1
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
    ...     - 5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
    ...
    ...  == HISTORY ==
    ...         [12.04.2021]  - Created TC
    ...         [20.10.2021] - review done

    [Setup]  Run keywords    Prepare test environment C6
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/testC6
    [Tags]  C6    GQC_PLAN:FEATURE:5GC001756

    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 1 PDU Sessions
    EXPECT FLOW: AMF1 NGAP uERadioCapabilityInfoIndication is sent
    EXPECT FLOW: UE_1 NR-RRC UECapabilityEnquiry is sent
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Attach UE1 to cell1 gNB2

    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 1 PDU Sessions
    PASS FLOW: AMF1 NGAP uERadioCapabilityInfoIndication is sent
    PASS FLOW: UE_1 NR-RRC UECapabilityEnquiry is sent
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Reset PCMD database

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration

    Trigger addtitional PDU session setup for UE1

    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration

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
    ...     list_name=PDUSessionResourceFailedToSetupListSURes
    ...     element_num=1

    Verify that AMF1 PDU session was rejected with cause radioNetwork: radio-resources-not-available

    Run keyword and Continue on Failure
    ...     Verify PduSessionResourceInfoTraceRecord PCMD records in testC6

#    Verify that gNB-CU PDU Session Info Record is sent correctly:
#            "trigger" set to "PDUsessionSetupRequest"
#            "result" is set to "miscFailure"
#            List of Failed to Setup PDU Session(s) with
#                PDU Session Id
#                S-NSSAI
#                PDU Session Aggregated Maximum Bit Rate
#                List of failed to setup QOS Flows with QFI, 5QI, ARP and GBR QoS Information in case of GBR QoS Flow presence

    Detach UE1

    [Teardown]  Run keywords    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/testC6    check_errors_or_warnings=both    AND
    ...         Cleanup after test C6   AND
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

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
    ...         [20.10.2021] - review done

    [Setup]  Prepare test environment C7
    [Tags]  C7    GQC_PLAN:FEATURE:5GC001756    SKIPRUN

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
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal

5GC001756-EA PCMD for SA - PDU session release success - Unknown PDU Session ID in PDU Session Resource to Release List
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure:
    ...     -   Successful PDU Session Resource Release - Unknown PDU Session ID in PDU Session Resource to Release List
    ...
    ...  PCMD reports:
    ...     -   gNB-CU reports PDU Session Info Record after successful PDU session release
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
    ...     - 5GC001756-EA-B104 gNB-CU PDU Session Info Record for Pdu Session Resource Release
    ...         - User Scenario#3 Successful PDU Session Resource Release - Unknown PDU Session ID in PDU Session Resource to Release List
    ...
    ...  == HISTORY ==
    ...         [28.06.2021]  - Created TC
    ...         [20.10.2021] - review done

    [Setup]  Prepare test environment C8
    [Tags]  C8    GQC_PLAN:FEATURE:5GC001756

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

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 second PDU session with one QoS flow

    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 third PDU session with one QoS flow

    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify 3 PduSessionResourceInfoTraceRecords in testC8

    Clear PCMD records                 # must clear record because next record is the same type

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceRelease with 2 PDU session(s) and one unknown PDU session
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Trigger additon of unknown PDU 4 for UE_1 into PDUSessionResourceReleaseRequest
    Trigger release of multiple PDU sessions initial,third for UE1

    PASS FLOW: AMF1 NGAP pDUSessionResourceRelease with 2 PDU session(s) and one unknown PDU session
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceRelease
    ...     message=PDUSessionResourceReleaseCommand
    ...     list_name=PDUSessionResourceToReleaseListRelCmd
    ...     element_num=3

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceRelease
    ...     message=PDUSessionResourceReleaseResponse
    ...     list_name=PDUSessionResourceReleasedListRelRes
    ...     element_num=3

    Run keyword and Continue on Failure
    ...     Verify PduSessionResourceInfoTraceRecord in testC8

#    Verify that CU PDU Session Info Record is sent correctly:
#            - "trigger" set to "PDUsessionReleaseRequest"
#            - "result" is set to "success"
#            List of successfully released PDU Session with
#                - PDU Session Id
#                - S-NSSAI

    Detach UE1

    [Teardown]  Run keywords
    ...         Cleanup after test C8   AND
    ...         Reset PCMD database    AND
    ...         Restart Scout Monitoring On Test Line If Needed    AND
    ...         Add Scout External Execution ID To Reporting Portal
