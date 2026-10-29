*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         5GC000281: CPLANE OVERLOAD PROTECTION
...         Feature introduce new functions with gNB support CPLANE overload protection mechanism aimed at
...         critical resource exhaustion and avoiding any software crash in gNB-CU.
...
...      == TEST SET NAME ==
...         5GC000281
...
...      == TESTING SPLIT==
...         5GC000281-B - NSA Counter measures and associated PM Counters and parameters
...         5GC000281-B-a Incoming NSA addition rejections
...         5GC000281-B-b NSA measurement report discards
...         5GC000281-B-c SgNB Modifiaction Request from MeNB for additional E-RAB additions
...         5GC000281-B-d SgNB Modifiaction Request from from Inter LTE HO
...         5GC000281-C - SA Counter measures and associated PM Counters and parameters
...         5GC000281-C-a Incoming SA Call RRC Call Rejection for non-emergency
...         5GC000281-C-b Measurement report discard for non-emergency for SA
...         5GC000281-C-c PDU Session Resource Request for new E-RABs (for non-emergency UEs) for SA
...         5GC000281-C-d XnAP:Handover Request rejection of non-emergency UEs
...         5GC000281-C-e Beam Switch/Port modification Request refusal for both NSA and SA
...
...      == AUTHORS ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - Michał Szymakowski <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         5GC000281 CFAM
...         https://nokia.sharepoint.com/:w:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC0200-5GC0399/5GC000281%20C-plane%20overload%20protection
...         /CP1%20Material/CP1%20CFAM%205GC000281%20ReviewVersion.docx?web=1
...
...      == HISTORY ==
...         [04.01.2021] - Create Test Suite
...         [31.08.2023] - switching test to agent-ca support

Resource    ./resources/5GC000281_C_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup  Prepare test suite

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA/egate_4c_emer.lua
${281_C}=     ${CURDIR}/config/yaml/281_C.yaml
${pcmd_enable_DU_CU_yaml}=      ${CURDIR}/config/yaml/pcmd_enable_DU_CU.yaml
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
...                             ${inter_gNB_handover}               ${pcmd_enable_DU_CU_yaml}
...                             ${281_C}                            ${lo_ap_lo_ho_fix}

*** Test Cases ***
5GC000281-C-1_RRC_Call_Reject_for_non_emergency_UEs_in_cpln_ovl_state
    [Tags]    C1
    ...    GQC_PLAN:FEATURE:5GC000281-C
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlSaRrcRej is TRUE then for gNB in SA mode all incomming
    ...  RRC Setup Requests for new UEs are rejected due to overload.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - gNB2 not in CPLANE overload state
#    ...  - NRBTS-actCuOvlProt is set to TRUE    Parameter removed in 24R2
    ...  - NRBTS-gnbOvlProtMode is set to CLASSICAL
    ...  - NRBTS-ovlSaRrcRej is set to FALSE
    ...  - NRCELL-cellDepType is set to SA
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_CP_12359741 5G_RAN_CP_12360935 5G_RAN_CP_12359171
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP PCAP
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...        5GC000281-C#US1 Incoming SA Call RRC Call Rejection for non-emergency UEs due to overload
    ...  == HISTORY ==
    ...     [04.01.2021] - TC Cerate

    [Setup]  Prepare test environment C1

    UE1 sends RRC Setup Request
    Verify that Establishment Cause IE not set to emergency for UE1
    Verify that UE1 is attached to gNB2

    Perform CPLANE OVL activation via R&D mechanism

    UE2 sends RRC Setup Request
    Verify that Establishment Cause IE not set to emergency for UE2
    Verify that UE2 is attached to gNB2

    Set gNB2 parameter ovlSaRrcRej to TRUE

    UE3 tries to send RRC Setup Request
    Verify that Establishment Cause is not set to emergency for UE3
    Verify that gNBCU send F1AP:UE Context Release Command with cause: miscellaneous cause: control processing overload
    Verify that gNB2 sends RRC Reject to UE3

    Collect PM file
    Verify that M55124C04501 SA_RRC_ESTAB_NEME_FAIL_OVLCP counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55138C00001 SGNB_SA_ADMISSION_REQ counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55138C00006 SGNB_SA_RAC_REJ_DUE_TO_RRC counter is equal 0 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test C1

5GC000281-C-3_PDU_Session_Resource_Setup_and_Modify_rejected_in_CPLN_ovl_state
    [Tags]    C3
    ...    GQC_PLAN:FEATURE:5GC000281-C
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlSaPduRej is TRUE then all incomming from AMF:
    ...  PDU Session Resource Setup Request or PDU Session Resource Modify Request
    ...  for attached UEs are rejected due to overload.
    ...
    ...  == Precondition ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...
    ...  - gNB up and running with one SA cell OnAir
    ...  - gNB not in CPLANE overload state
#    ...  - NRBTS-actCuOvlProt is set to TRUE    Parameter removed in 24R2
    ...  - NRBTS-gnbOvlProtMode is set to CLASSICAL
    ...  - NRBTS-ovlSaPduRej is set to TRUE
    ...  - NRBTS-actCellTraceReport is set to TRUE (Interaction with 5GC001778)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU-actCellTraceReportingCU is set to TRUE
    ...  - MRBTS/MNL/TCEADM/TCE configured
    ...  - gNB established connection to TCE
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_CP_12361485 5G_RAN_CP_12357249
    ...
    ...  == REQUIRED LOGS ==
    ...    NR_RRC PCAP
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...        5GC000281-C#US3 PDU Session Resource Setup/Modify Request (for new QoS Flow for non-emergency UEs) rejections
    ...        5GC000281-C#US7 Transition to Overload OFF - countermeasures are no longer applied
    ...  == HISTORY ==
    ...     [04.01.2021]  - Created TC

    [Setup]  Prepare test environment C3

    Start TCE interface monitoring via Wireshark

    UE1 attach to gNB2
    Verify that Establishment Cause IE not set to emergency for UE1
    Verify that UE1 is attached to gNB2

    Perform CPLANE OVL activation via R&D mechanism

    Try to add to UE1 second PDU session during active OVL
    AMF sends NGAP: PDU Session Resource Setup Request with new PDU session for UE1 during active OVL
    Verify that gNB sends NGAP:PDU Session Resource Setup Response with PDUSessionResourceFailedToSetupListSURes
    Verify that gNB sends NGAP:PDU Session Resource Setup Response with cause: miscellaneous cause: control processing overload
    Verify that UE1 does not recieve RRC Reconfiguration message from gNB

    Verify that NGAP: PDU Session Resource Setup Request is traced with TCE
    Verify that NGAP: PDU Session Resource Setup Response is traced with TCE

    Perform CPLANE OVL deactivation via R&D mechanism

    Add to UE1 second PDU session
    AMF sends NGAP: PDU Session Resource Setup Request with new PDU session for UE1
    Verify that gNB sends RRC Reconfiguration
    Verify that UE1 sends RRC Reconfiguration Complete
    Verify that gNB sends NGAP:PDU Session Resource Setup Response with PDUSessionResourceSetupItemSURes

    Modify UE1 second PDU session
    AMF sends NGAP: PDU Session Resource Modify Request with QoS flow addition in second PDU session for UE1
    Verify that gNB sends RRC Reconfiguration
    Verify that UE1 sends RRC Reconfiguration Complete
    Verify that gNB sends NGAP:PDU Session Resource Modify Response with PDUSessionResourceModifyListModRes

    Perform CPLANE OVL activation via R&D mechanism

    Try to modify UE1 second PDU session
    AMF sends NGAP: PDU Session Resource Modify Request with QoS flow deletion in second PDU session for UE1
    Verify that gNB sends NGAP:PDU Session Resource Modify Response with PDUSessionResourceFailedToModifyListModRes
    Verify that gNB sends NGAP:PDU Session Resource Modify Response with cause: Miscellaneous Cause: Control Processing Overload

    Collect PM file
    Verify that M55125C06001 SA_PDU_SES_NEME_STP_FAIL_OVLCP counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C02505 NNGCC_PDU_SES_STP_RESP_SENT counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C03502 NNGCC_PDUSESMODRSP_SUCC_SENT counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C03503 NNGCC_PDUSESMODRSP_FAIL_SENT counter is equal 1 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test C3

5GC000281-C-4_XnAP_Handover_Request_rejected_in_cpln_ovl_state
    [Tags]    C4
    ...    GQC_PLAN:DESIGNER:sukl
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlSaHoRej is TRUE then all incomming
    ...  XnAP Handover Request without any of QoS Flows with emergency ARP
    ...  for attached UEs are rejected due to overload.
    ...
    ...  == Precondition ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - gNB3 - simulated gNB with nr_cell_1_n78 and nr_cell_2_n7
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - gNB2 not in CPLANE overload state
#    ...  - NRBTS-actCuOvlProt is set to TRUE    Parameter removed in 24R2
    ...  - NRBTS-gnbOvlProtMode is set to CLASSICAL
    ...  - NRBTS-ovlSaHoRej is set to TRUE
    ...  - Xn link is up between gNB2 and gNB3
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     REQUIREMENTS IN SCOPE: 5G_RAN_CP_12361044 5G_RAN_CP_12361047 5G_RAN_CP_12361048 5G_RAN_CP_12359173
    ...
    ...  == REQUIRED LOGS ==
    ...     NR_RRC PCAP
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     - 5GC000281-C#US4 XnAP:Handover Request rejection of non-emergency UEs due to overload
    ...     - 5GC000281-C#US6 Deactivation of C-plane overload protection - countermeasures are no longer applied
    ...  == HISTORY ==
    ...         [05.01.2021]  - Created TC

    [Setup]  Prepare test environment C4

    Perform CPLANE OVL activation via R&D mechanism

    UE1 attach to gNB3

    Try to handover UE1 to gNB2 during active OVL
    Verify that gNB3 sends XNAP: Handover Request to gNB2 for UE1
    Verify that gNB2 sends XNAP: Handover Preparation Failure with cause: miscellaneous cause: control processing overload

    Set gNB2 parameter gnbOvlProtMode to DISABLED

    UE1 triggers handover to gNB2
    Verify that gNB3 sends XNAP: Handover Request to gNB2 for UE1
    Verify that gNB2 sends XNAP: Handover Request Acknowledge to gNB3 for UE1

    Collect PM file
    Verify that M55143C00501 XN_SA_HO_PREP_FAIL_OVLCP counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55143C00008 HO_PREP_FAIL_SENT_AC counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55143C00009 HO_PREP_FAIL_SENT_OTH counter is equal 0 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test C4

5GC000281-C-5_Emergency_UE_handling_in_cpln_ovl_state
    [Tags]    C5    SKIPRUN
    ...    GQC_PLAN:FEATURE:5GC000281-C
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and feature 5GC000784 - Emergency calls handling in SA mode
    ...  is enabled on gNB then countermeasure should not be applied to Emergency UEs.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - gNB3 - simulated gNB with nr_cell_1_n78 and nr_cell_2_n7
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - gNB2 not in CPLANE overload state
#    ...  - NRBTS-actCuOvlProt is set to TRUE    Parameter removed in 24R2
    ...  - NRBTS-gnbOvlProtMode is set to CLASSICAL
    ...  - NRBTS-ovlSaRrcRej is set to TRUE
    ...  - NRBTS-ovlSaMeasDiscard is set to TRUE
    ...  - NRBTS-ovlSaPduRej is set to TRUE
    ...  - NRBTS-ovlSaHoRej is set to TRUE
    ...  - Xn link is up between gNB2 and gNB3
    ...  - gNB2 configured with 5GC000784 - NRCELL-actIMSEmergency is set to TRUE
    ...  - AMF supports Emergency services
    ...  - NRBTS/NRCELL/arpPrioEmergencyCall set to 1
    ...  - UEs are capable of VoNR
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     REQUIREMENTS IN SCOPE: 5G_RAN_CP_12361044 5G_RAN_CP_12361047 5G_RAN_CP_12361048 5G_RAN_CP_12359173
    ...
    ...  == REQUIRED LOGS ==
    ...  - NR_RRC
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     - 5GC000281-C#US1 Incoming SA Call RRC Call Rejection for non-emergency UEs due to overload
    ...     - 5GC000281-C#US2 Measurement report discarding for non-emergency UEs due to overload
    ...     - 5GC000281-C#US3 PDU Session Resource Setup/Modify Request (for new QoS Flow for non-emergency UEs) rejections
    ...     - 5GC000281-C#US4 XnAP:Handover Request rejection of non-emergency UEs due to overload
    ...  == HISTORY ==
    ...     [05.01.2021]  - Created TC

    [Setup]  Prepare test environment C5

    UE1 attach to gNB2
    Verify that Establishment Cause IE not set to emergency for UE1
    Verify that UE1 is attached to gNB2
    Emergency UE2 attach to gNB2
    Verify that Establishment Cause IE set to emergency for UE2
    Verify that UE2 is attached to gNB2

    Perform CPLANE OVL activation via R&D mechanism

    Try to attach UE3 to gNB2 during active OVL
    Verify that Establishment Cause is not set to emergency for UE3
    Verify that gNB2 sends RRC Reject to UE3
    Emergency UE4 attach to gNB2
    Verify that Establishment Cause IE set to emergency for UE4
    Verify that UE4 is attached to gNB2
    AMF sends NGAP: PDU Session Resource Setup Request with Emergency ARP priority equal to 5

    Emergency UE5 attach to gNB3
    Emergency UE5 triggers handover to gNB2
    Verify that gNB3 sends XNAP: Handover Request to gNB2 for UE5
    Verify that gNB2 sends XNAP: Handover Request Acknowledge to gNB3 for UE5
    Verify that Emergency UE5 is successfully handovered to gNB2 in cpln OVL state

    [Teardown]  Cleanup after test C5

5GC000281-C-2_RRC_Measurement_report_discard_in_CPLN_ovl_state
    [Tags]    C2
    ...    GQC_PLAN:FEATURE:5GC000281-C
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info ==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlSaMeasDiscard is TRUE then all incomming SA measurments
    ...  reports for attached UEs are rejected due to overload.
    ...
    ...  == Precondition ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL simulated on AEQE radio module - NR_BAND: n78
    ...  - gNB_tgt - simulated gNB with nr_cell_1_n78 and nr_cell_2_n7
    ...  - UE - Airphone simulator
    ...
    ...  - gNB up and running with one SA cell OnAir
    ...  - gNB not in CPLANE overload state
#    ...  - NRBTS-actCuOvlProt is set to TRUE    Parameter removed in 24R2
    ...  - NRBTS-gnbOvlProtMode is set to CLASSICAL
    ...  - NRBTS-ovlSaRrcRej is set to FALSE
    ...  - NRBTS-ovlSaMeasDiscard is set to TRUE
    ...  - NRBTS-actIntraFreqHoSA is set to TRUE
    ...  - NRBTS-actInterFreqHoSA is set to TRUE
    ...  - NRCELL-a3MeasEnabled
    ...  - Xn link is up between gNB and gNB_tgt
    ...  - NRBTS-actCellTraceReport is set to TRUE (Interaction with 5GC001778)
    ...  - NRBTS/NRCTRLTS/NRMTRACECU-actCellTraceReportingCU is set to TRUE
    ...  - MRBTS/MNL/TCEADM/TCE configured
    ...  - gNB established connection to TCE
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in NSA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     REQUIREMENTS IN SCOPE: 5G_RAN_CP_12359100 5G_RAN_CP_12359175
    ...
    ...  == REQUIRED LOGS ==
    ...     NR_RRC PCAP
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...        5GC000281-C#US2 Measurement report discarding for non-emergency UEs due to overload
    ...  == HISTORY ==
    ...     [04.01.2021]  - Created TC

    [Setup]  Prepare test environment C2

    Attach UE1 to gNB with A3 measurement
    Verify that Establishment Cause IE not set to emergency for UE1
    Verify that UE1 is attached to gNB2

    UE1 sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Verify that inter-gNB intra-frequency handover execution for UE1 succeed

    Start TCE interface monitoring via Wireshark

    Attach UE2 to gNB with A3 measurement
    Verify that Establishment Cause IE not set to emergency for UE2
    Verify that UE2 is attached to gNB2

    Perform CPLANE OVL activation via R&D mechanism

    UE2 sends A3 measResult from gNB_tgt with value above offset defined for PSCell
    Verify that gNB ignores Meas Report and does NOT send XNAP: Handover Request for UE2
    Verify that gNB ignores Meas Report and does NOT send RRC Reconfiguration or RRC Release for UE2

    Wait 5 to collect all PCMD reports

    Verify that ignored measurement report is traced with TCE

    Set gNB2 parameter gnbOvlProtMode to DISABLED

    UE2 sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Verify that inter-gNB intra-frequency handover execution for UE2 succeed

    Collect PM file
    Verify that M55124C04503 NRRCC_SA_MEAS_DISCARD_OVLCP counter is equal 1 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test C2
