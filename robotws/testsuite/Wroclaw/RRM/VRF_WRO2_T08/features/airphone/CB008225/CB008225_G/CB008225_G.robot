*** Settings ***
Force Tags    SBTS00    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska, Joachim Otto
...              :contact: katarzyna.wisniewska@nokia.com, joachim.otto@nokia.com
...
...              This feature introduces the RRC Inactive state, including RRC state transitions to/from other states under the same gNB,
...              for 5G UEs operating in 3GPP NR Standalone (SA) mode.

Resource    CB008225_G_Keywords_And_Variables.robot
Resource    ../CB008225_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach OnAir    lua_cfg=testsuite/Wroclaw/RRM/resources/airphone/egate_2c_tdd_2c_fdd_sansa_null.lua
...             AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8225_G.json    skip_relation_errors=False
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_8225_G.json
Test Teardown    Run Keywords     Deregister UE Without Confirmation   ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB008225_G_B1_LRC_direct_for_UE_in_RRC_INACTIVE_triggers_successful_RAN_Paging_RRCResume_and_LocationReport
    [Documentation]
    ...  DESCRIPTION:
    ...     UE attaches to NRCELL-1 and goes to inactive state. AMF sends LoCationReportingControl with event-type direct
    ...     which casuses Paging, for which UE responds with RRCResumeRequest1 with cause mt-access and sends it to NRCELL-1.
    ...     After sucessfull resume procedure, gNB sends to AMF LocationReport with NRCELL-1 location and NO timestamp.
    ...     In the second case,  UE attaches to NRCELL-1 and goes to inactive state. AMF sends LoCationReportingControl with event-type direct
    ...     which casuses Paging, for which UE responds with RRCResumeRequest1 with cause mt-access, but UE sends it to NRCELL-2
    ...     (which is in the same ranac). After successfull resume procedure, LocationReport contains NRCELL-2 as UE location and
    ...     NO timestamp.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.rrcInactLocationReportEnabled = true (CB008225)
    ...     - NRBTS.drbRrcInactInactivityTimerSA = 5 (CB008225)
    ...     - NRBTS.actLocationReportingSA = true (5GC000770)
    ...     - NRBTS.actAdditionalSliceSupport = true (CB008120)
    ...     - NRBTS.tRanPagingGuard = 5 (s)
    ...     - NRDRB_QCI-1.qciValueList = [5]
    ...     - NRDRB_QCI-1.nrDrbDN = 'MRBTS-1/NRBTS-1/NRDRB-2'
    ...     - NRDRB-2.drbRrcInactInactivityTimerSA = 5 (s)
    ...     - UE-NR-Capability-v1530.inactiveState = supported
    ...
    ...  POSTCONDITION:
    ...     - Successful RAN Paging procedure.
    ...     - UE is in RRC_CONNECTED state.
    ...     - NGAP:LocationReport is sent to AMF with UserLocationInformation IE (including NRCGI+TAI) for concerned UE (AMF UE NGAP ID)
    ...       for event type: direct

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Configure Max Paging Retries    max_paging_retries=10
        ...    AND             Configure Paging Delay    ue_id=1    paging_delay=1s
        ...    AND             Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=1
        ...    AND             Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
        ...    AND             Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386
        ...    AND             Set Internal Traffic Type For Ue    ue=1    pdu=1

    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Start UL And DL Traffic    ue_id=1    pdu_id=1
    Wait For RRC Release Message With Suspend Config
    Set Parameters For UE RRC Resume Request    ue_id=1    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    UE Send Location Reporting Control    ue=1    event_type=direct
    Wait For Location Report Message
    Start UL And DL Traffic    ue_id=1    pdu_id=1
    Wait For RRC Release Message With Suspend Config    number_of_messages=2
    Set Parameters For UE RRC Resume Request    ue_id=1    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    UE Send Location Reporting Control    ue=1    event_type=direct
    Wait For Location Report Message    number_of_messages=2
    Start UL And DL Traffic    ue_id=1    pdu_id=1

    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_PAGING}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_1}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_2}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_ULI}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_WITH_TIMESTAMP}    number_of_messages=0

CB008225_G_B3_LR_sent_more_than_once_CRT
    [Documentation]
    ...  DESCRIPTION:
    ...  NRBTS.rrcInactLocationReportEnabled = true (CB008225)
    ...  NRBTS.actLocationReportingSA = true (5GC000770)
    ...  NRBTS/NRCELL-1.ranAC = 1
    ...  NRBTS/NRCELL-2.ranAC = 1

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Configure Max Paging Retries    max_paging_retries=10
        ...    AND             Configure Paging Delay    ue_id=2    paging_delay=1s
        ...    AND             Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
        ...    AND             Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
        ...    AND             Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386
        ...    AND             Area Of Interest Configuration    object_id=3    plmn=311:489    nrci=16387
        ...    AND             Set Internal Traffic Type For Ue    ue=2    pdu=2

    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Wait For RRC Release Message With Suspend Config
    UE Send Location Reporting Control    ue=2    event_type=ue-presence-in-area-of-interest    object_id=2    location_reporting_reference_id=2
    UE Send Location Reporting Control    ue=2    event_type=change-of-serving-cell
    Wait For Location Report Message    number_of_messages=2
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    Trigger RRC Resume    ue_id=2
    Wait For Location Report Message    number_of_messages=4
    Start UL And DL Traffic    ue_id=2    pdu_id=2
    Trigger UE Assistance    ue_id=2
    Wait For RRC Release Message With Suspend Config    number_of_messages=2
    UE Send Location Reporting Control    ue=2    event_type=direct
    Wait For Location Report Message    number_of_messages=5
    Start UL And DL Traffic    ue_id=2    pdu_id=2
    Wait For RRC Release Message With Suspend Config    number_of_messages=3
    UE Send Location Reporting Control    ue=2    event_type=stop-change-of-serving-cell
    UE Send Location Reporting Control    ue=2    event_type=stop-ue-presence-in-area-of-interest
    ...    location_reporting_reference_id_to_be_cancelled=2
    UE Send Location Reporting Control    ue=2    event_type=ue-presence-in-area-of-interest    object_id=3    location_reporting_reference_id=3
    Wait For Location Report Message    number_of_messages=6
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    Trigger RRC Resume    ue_id=2
    Sleep    1s    reason=Wait for procedure finish
    Start UL And DL Traffic    ue_id=2    pdu_id=2
    UE Send Location Reporting Control    ue=2    event_type=direct
    Wait For Location Report Message    number_of_messages=7
    Start UL And DL Traffic    ue_id=2    pdu_id=2
    Wait For RRC Release Message With Suspend Config    number_of_messages=4
    UE Send Location Reporting Control    ue=2    event_type=direct
    Wait For Location Report Message    number_of_messages=8
    Deregister UE    ue_id=2
    Sleep    1s    reason=Wait for procedure finish
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Wait For RRC Release Message With Suspend Config    number_of_messages=5
    UE Send Location Reporting Control    ue=2    event_type=ue-presence-in-area-of-interest
    ...    object_id=1 location_reporting_reference_id=1    object_id=2 location_reporting_reference_id=2
    UE Send Location Reporting Control    ue=2    event_type=change-of-serving-cell
    Wait For Location Report Message    number_of_messages=10
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    UE Send Location Reporting Control    ue=2    event_type=direct
    Wait For Location Report Message    number_of_messages=13

    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_AOI}    number_of_messages=3
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}    number_of_messages=4
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_STOP_AOI}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_STOP_CHANGE_CELL}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_ULI}    number_of_messages=13
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_WITH_TIMESTAMP}    number_of_messages=5
    Verify Tcpdump Log    packet_filter=${F1AP_PAGING}    number_of_messages=3
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_1}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_2}    number_of_messages=3

CB008225_G_B3_1_2_LR_ue_presence_in_the_area_of_interest_and_change_of_serve_cell_during_resume_procedure_CRT
    [Documentation]
    ...  DESCRIPTION:
    ...  This test scenario describes the gNB behavior for successful location reporting procedure after transition of suspended UE1
    ...  from RRC_INACTIVE to RRC_CONNECTED state to different cell within the same gNB (by XXXX). The gNB should send
    ...  NGAP: Location Report (with NRCGI, TAI).
    ...  As a precondition when UE1 is in RRC-INACTIVE state AMF sends NGAP: LocationReportingControl with 'AOI' to gNB for UE1.
    ...  Then RRCResume procedure is triggered by starting traffic.
    ...  - The same procedure is then performed for UE2 but transition from RRC_INACTIVE to RRC_CONNECTED state is made to the same cell within the
    ...  the same gNB. In this situation the gNB should not send NGAP: Location Report.
    ...  - At the end is made intra-frequency intra-gNB handover for UE2 to different cell. In this situation The gNB should send
    ...  NGAP: Location Report (with NRCGI, TAI).
    ...
    ...  PRECONDITION:
    ...     - NRBTS.rrcInactLocationReportEnabled = true (CB008225)
    ...     - NRBTS.drbRrcInactInactivityTimerSA = 5 (CB008225)
    ...     - NRBTS.actLocationReportingSA = true (5GC000770)
    ...     - NRBTS.actAdditionalSliceSupport = true (CB008120)
    ...     - NRBTS.tRanPagingGuard = 4 (s)
    ...     - NRDRB_QCI-1.qciValueList = [5]
    ...     - NRDRB_QCI-1.nrDrbDN = 'MRBTS-1/NRBTS-1/NRDRB-2'
    ...     - NRDRB-2.drbRrcInactInactivityTimerSA = 5 (s)
    ...     - UE-NR-Capability-v1530.inactiveState = supported
    ...
    ...  POSTCONDITION:
    ...     - RRCResume procedure is started
    ...     - UE1 and UE2 are in RRC_CONNECTED state
    ...     - NGAP:LocationReport is sent to AMF with UserLocationInformation IE (including NRCGI+TAI) for concerned UEs (AMF UE NGAP ID):
    ...       -  for UE1 after starting traffic with change of serving cell
    ...       -  for UE2 after handover to second cell


    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Configure Max Paging Retries    max_paging_retries=10
        ...    AND             Configure Paging Delay    ue_id=3    paging_delay=1s
        ...    AND             Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
        ...    AND             Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
        ...    AND             Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386

    Attach UE    ue_id=3
    Establish PDU With Gateway-1 And Wait For Inactive State For UE3
    Trigger Location Reporting    ue_id=3    event_type=change-of-serving-cell
    Trigger RRCResume Procedure For UE3 By Running DL Traffic Towards NRCELL-2 PDU1
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=4
    Attach UE    ue_id=4
    Establish PDU With Gateway-2 And Wait For Inactive State For UE4
    Trigger Location Reporting    ue_id=4    event_type=change-of-serving-cell
    Trigger RRCResume Procedure For UE4 By Running DL Traffic Towards NRCELL-1 PDU1
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=4  cell_id=2  phycell_id=51  nrsrp_nr=40  srsrp_nr=30
    ...                                                     pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...                                                     timeout=7
    Start UL And DL Traffic    ue_id=4    pdu_id=1
    Deregister Ue Without Confirmation    ue_id=3
    Deregister Ue Without Confirmation    ue_id=4
    Sleep    1s    reason=Wait for procedure finish
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
    Attach UE    ue_id=3
    Establish PDU With Gateway-3 And Wait For Inactive State For UE3
    UE Send Location Reporting Control    ue=3    event_type=ue-presence-in-area-of-interest    object_id=1    location_reporting_reference_id=1
    Trigger RRCResume And Wait For Inactive State For UE3
    Send Location Report For UE3 And Perfrom Intra-eNB HO Without Display Option
    Deregister Ue Without Confirmation    ue_id=3

    Verify Ngap Messages    packet_filter=${LOCAL_REPORT_WITH_NRCELL_2_IDENTITY}    number_of_messages=4
    Verify Ngap Messages    packet_filter=${CORRECT_PLMN_IN_ULI}    number_of_messages=3    relation_symbol= >=
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}
    Verify Ngap Messages    packet_filter=${CHANGE_OF_SERVING_CELL_LOCATION_REPORT}    number_of_messages=4
    Verify Tcpdump Log      packet_filter=${AREACODE_1}    number_of_messages=2    relation_symbol= >=
    Verify Ngap Messages    packet_filter=${LOCAL_REPORT_WITH_NRCELL_1_IDENTITY}    number_of_messages=4
    Verify Ngap Messages    packet_filter=${LOCATION_REPORT_WITH_NRCELL1_IN_AOI}    relation_symbol= >=
    Verify Ngap Messages    packet_filter=${CORRECT_PLMN_IN_AOI}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${UE_PRESENCE_IN_LOCATION_REPORT}
    Verify Ngap Messages    packet_filter=${REFERENCE_ID_IN_LOCATION_REPORT}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${LOCATION_REPORT_WITH_NRCELL2_IN_AOI}


CB008225_G_B4_LRC_ue_presence_in_the_area_of_interest_and_change_of_serve_cell_received_in_connected_LR_rrcInactLocationReportEnabled_disabled_CRT

    [Documentation]
    ...  DESCRIPTION:
    ...  This test scenario describes the gNB behavior for location reporting
    ...  after successful transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED to different cell within same gNB.
    ...
    ...  PRECONDITION:
    ...  NRBTS.rrcInactLocationReportEnabled = false (CB008225)
    ...  NRBTS.actLocationReportingSA = true (5GC000770)
    ...
    ...  POSTCONDITION:
    ...  Location Report is sent to AMF.
    ...  For EventType IE set to "change of serving cell", NGAP: LocationReport is sent to AMF with UserLocationInformation IE.
    ...  For EventType IE set to “UE presence in the area of interest”, NGAP: LocationReport is sent to AMF with UserLocationInformation IE.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Perform Parameter Commissioning    parameter=rrcInactLocationReportEnabled    value=false
        ...    AND             Configure Max Paging Retries    max_paging_retries=10
        ...    AND             Configure Paging Delay    ue_id=5    paging_delay=1s
        ...    AND             Set Internal Traffic Type For Ue    ue=5    pdu=5
        ...    AND             Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=5
        ...    AND             Configure 8 Areas of Interest

    Attach UE    ue_id=5
    Establish PDU Session    ue_id=5    pdu_id=5    gw_id=5
    Ue Send Location Reporting Control    ue=5    event_type=change-of-serving-cell
    Wait For Location Report Message
    Wait For RRC Release Message With Suspend Config
    Trigger RRCResume Procedure For UE5 By Running DL Traffic Towards NRCELL-2 PDU5
    Stop DL    ue_id=5    pdu_id=5
    Wait For Location Report Message    number_of_messages=2
    Ue Send Location Reporting Control    ue=5    event_type=stop-change-of-serving-cell
    Wait For RRC Release Message With Suspend Config    number_of_messages=2
    Trigger RRCResume Procedure For UE5 By Running DL Traffic Towards NRCELL-1 PDU5
    Stop DL    ue_id=5    pdu_id=5
    Deregister UE    ue_id=5
    Sleep    1s    reason=Wait for procedure finish
    Attach UE    ue_id=5
    Establish PDU Session    ue_id=5    pdu_id=5    gw_id=5
    Start Traffic    ue_id=5    pdu_id=5
    Send 8 Location Reporting Control Objects    ue_id=5
    Wait For Location Report Message AOI With 8 Items Cell1
    Wait For Location Report Message AOI With 8 Items Cell2
    Wait For Location Report Message AOI With 8 Items Cell3
    Stop Traffic    ue_id=5    pdu_id=5
    Wait For RRC Release Message With Suspend Config    number_of_messages=3
    Set Parameters For UE RRC Resume Request    ue_id=5    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    Trigger RRC Resume    ue_id=5
    Start UL And DL Traffic    ue_id=5    pdu_id=5
    Wait For Location Report Message AOI With 8 Items Cell1    number_of_messages=2
    Wait For Location Report Message AOI With 8 Items Cell2    number_of_messages=2
    Wait For Location Report Message AOI With 8 Items Cell3    number_of_messages=2
    Send UE Measurement NR    ue_id=5    meas_id=1    event=A3    srsrp_nr=18    phycell_id=50    nrsrp_nr=85
    Wait For Location Report Message AOI With 8 Items Cell1    number_of_messages=3
    Wait For Location Report Message AOI With 8 Items Cell2    number_of_messages=3
    Wait For Location Report Message AOI With 8 Items Cell3    number_of_messages=3
    Start UL And DL Traffic    ue_id=5    pdu_id=5

    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL}    number_of_messages=1
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_STOP_CHANGE_CELL}    number_of_messages=1
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_ULI}    number_of_messages=5
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_1}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_2}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${UE_PRESENCE_IN_AOI_IE}    number_of_messages=4
