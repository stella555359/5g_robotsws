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
...         [30.07.2021] - Create Test Suite

Resource    ./resources/5GC001756-EA_HO_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-verify_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup
...     f1ap=${True}
...     intra_gnb_ho=${True}

*** Variables ***
${LUA_CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD}=      ${CURDIR}/config/SA_egate_2c_tdd.lua
${LUA_CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD}=     ${CURDIR}/config/SA_egate_2c_tdd_LO.lua
${LUA_CFG}=                ${LUA_CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD}

*** Test Cases ***
5GC001756-EA PCMD for SA - intra gNB inter cell HO success
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is verification that gNB-CU report correctly PCMD reports during below procedures:
    ...  Procedure: Successful Intra-gNB Intra-DU Inter-cell Handover
    ...
    ...  PCMD reports:
    ...     gNB-CU PDU Session Info Record is reported after successful Intra-DU Inter-Cell Handover
    ...     gNB-CU UE Setup Record is sent correctly after successful Intra-DU Inter-Cell Handover
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIB
    ...	 - NRCELL-1 simulated on AHLOA radio module - NR_BAND: n71
    ...	 - NRCELL-2 simulated on AHLOA radio module - NR_BAND: n71
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 and cell2 for CU
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for NRCELL-1 and NRCELL-2
    ...  - Trace Recording Session for SA UE call is reported to TCE
    ...  - Both cell1 and cell2 have NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrp' for all cells
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
    ...  - NRBTS/actInterFreqHoSA is set to 'true'
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIB) with simulated AHLOA radio module - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036,5G_RAN_USR_COM_3037
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B106 gNB-CU PDU Session Info Record for Intra-gNB mobility
    ...         - User Scenario#1 Successful Intra-gNB Intra-DU Inter-cell Handover
    ...     - 5GC001756-EA-B122 gNB-CU UE Setup Record for Intra-gNB mobility
    ...         - User Scenario#2 Successful Inter-cell Intra-DU Handover
    ...
    ...  == HISTORY ==
    ...         [30.07.2021]  - Created TC

    [Setup]  Prepare test environment intraHO EA1
    [Tags]  EA1     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully

    Run keyword and Continue on Failure
    ...         Verify First PduSessionResourceInfoTraceRecord In intra-gNB HO Test EA1 During attach

    Clear PCMD Records

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
    ...         Verify Second PduSessionResourceInfoTraceRecord In intra-gNB HO Test EA1 During second PDU session addition

    Clear PCMD Records

    EXPECT FLOW: UE_1 NR-RRC MeasurementReport triggering intra-gNB HO
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with target cell configuration
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete
    EXPECT FLOW: gNB2 F1AP uEContextModification for HO

    Trigger UE1 to send MeasurementReport with value above offset defined for cell2

    PASS FLOW: UE_1 NR-RRC MeasurementReport triggering intra-gNB HO
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with target cell configuration
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete
    PASS FLOW: gNB2 F1AP uEContextModification for HO
    Verify that UE1 RRCReconfiguration that target PCI: 51 is present

     Run keyword and Continue on Failure
     ...         Verify third PduSessionResourceInfoTraceRecord,CuUeSetupTraceRecord In intra-gNB HO Test EA1 During HO to gNB 1 cell 2

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "handover"
#        - "result" is set to "success"
#        - Successfully modified PDU Session with
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of successfully setup QoS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

#    Verify that gNB-CU reports UE Setup Record with
#        - "result" set to "success"
#        - "UE setup reason" set to "other"
#        - RAN UE NGAP ID
#        - AMF UE NGAP ID
#        - Globally Unique AMF ID

    Detach UE1

    [Teardown]  Cleanup after test intraHO EA1

5GC001756-EA PCMD for SA - intra gNB inter cell HO fail
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is verification that gNB-CU report correctly PCMD reports during below procedures:
    ...  Procedure: Intra-DU Inter-Cell Handover fails after RRC: RRC RECONFIGURATION message is sent
    ...             due to rrcGuardTimer expiry for RRC: RRC RECONFIGURATION COMPLETE
    ...             gNB-CU-CP shall abort Handover and release the call
    ...
    ...  PCMD reports:
    ...     gNB-CU PDU Session Info Record is reported after successful Intra-DU Inter-Cell Handover.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIB
    ...	 - NRCELL-1 simulated on AHLOA radio module - NR_BAND: n71
    ...	 - NRCELL-2 simulated on AHLOA radio module - NR_BAND: n71
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 and cell2 for CU
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - Max number of traced UE/Cell is not reached on gNB-CU (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for NRCELL-1 and NRCELL-2
    ...  - Trace Recording Session for SA UE call is reported to TCE
    ...  - Both cell1 and cell2 have NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrp' for all cells
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
    ...  - NRBTS/actInterFreqHoSA is set to 'true'
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIB) with simulated AHLOA radio module - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
    ...  - Dawid Krawczuk <dawid.krawczuk@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B106 gNB-CU PDU Session Info Record for Intra-gNB mobility
    ...         - User Scenario#10 Unsuccessful Inter-cell Intra-DU Handover - lack of RRC: Reconfiguration Complete
    ...
    ...  == HISTORY ==
    ...         [30.07.2021]  - Created TC

    [Setup]  Prepare test environment intraHO EA2
    [Tags]  EA2     GQC_PLAN:FEATURE:5GC001756

    Attach UE1 with single PDU session in ICS
    Verify that UE1 attach with 1 PDU session was completed successfully

    Run keyword and Continue on Failure
    ...         Verify First PduSessionResourceInfoTraceRecord In intra-gNB HO Test EA2 During attach
    Clear PCMD Records
    
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
    ...         Verify Second PduSessionResourceInfoTraceRecord In intra-gNB HO Test EA2 During second PDU session addition

    Clear PCMD Records

    Perform command to drop RRC: Reconfiguration Complete message

    EXPECT FLOW: UE_1 NR-RRC MeasurementReport triggering intra-gNB HO
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration with target cell configuration
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete
    EXPECT FLOW: gNB2 F1AP uEContextModification for HO

    Trigger UE1 to send MeasurementReport with value above offset defined for cell2

    PASS FLOW: UE_1 NR-RRC MeasurementReport triggering intra-gNB HO
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration with target cell configuration
    FAIL FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete
    PASS FLOW: gNB2 F1AP uEContextModification for HO
    Verify that UE1 RRCReconfiguration that target PCI: 51 is present

    Run keyword and Continue on Failure
    ...         Verify third PduSessionResourceInfoTraceRecord,CuUeSetupTraceRecord In intra-gNB HO Test EA2 During failed HO to gNB 1 cell 2

#    Verify that gNB-CU PDU Session Info Record is sent correctly
#        - "trigger" set to "Handover"
#        - "result" is set to "Failure"
#        - List of failed to Setup PDU Session with respective
#            - PDU Session Id
#            - S-NSSAI
#            - PDU Session Aggregated Maximum Bit Rate
#            - List of failed to setup QOS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information

    Run keyword and ignore error        Detach UE1
    [Teardown]  Cleanup After Test IntraHO EA2
