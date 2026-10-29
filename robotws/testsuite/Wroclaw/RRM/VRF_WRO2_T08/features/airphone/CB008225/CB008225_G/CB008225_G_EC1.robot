*** Settings ***
Force Tags    SBTS00    CONFIGURED    RAN_5G_FDD    RAN_5G_TDD    RAN_5G
...           CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Piotr Pinderak
...              :contact: piotr.pinderak@nokia.com
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
CB008225_G_EC1_Paging_timeout_and_disabled_ranac_CRT
    [Documentation]
    ...  DESCRIPTION: This test scenario describes the procedure when UE is in RRC-INACTIVE state and AMF sends NGAP: LocationReportingControl
    ...  to gNB for UE. Feature Flag for Location Reporting in RRC-INACTIVE state is enabled NRBTS.rrcInactLocationReportEnabled = true.
    ...  But after UE goes to RRC-INACTIVE state ranAC is disabled on cell.
    ...  The gNB should respond with NGAP: LocationReport to AMF. Paging and RRCResume procedures are not started for UE after LCR with event
    ...  'direct'. LocationReport with timestamp is sent when ranACs on both cells are the same NRPLMNSET_SA-1.ranAC = 1 because when ranAC
    ...  on one cell is disabled, on other is enabled and gNB triggers paging it this case. UE does not respond to paging and gNB sends
    ...  LocationReport with timestamp according to G-EC1 scenario.
    ...  LocationReport with timestamp is not sent when ranACs on both cells are different Cell-1/NRPLMNSET_SA-1.ranAC = 1
    ...  and Cell-2NRPLMNSET_SA-1.ranAC = 2 because gNB does not trigger paginng it this case.
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
    ...     - NRBTS/NRCELL-1/NRPLMNSET_SA-1.ranAC = 1
    ...     - NRBTS/NRCELL-2/NRPLMNSET_SA-1.ranAC = 1
    ...
    ...  POSTCONDITION:
    ...     - RRCResume procedure is started
    ...     - UE1 is in RRC_CONNECTED state
    ...     - NGAP:LocationReport is not sent to AMF after receiving from AMF NGAP: LocationReportingControl during Feature Flag
    ...       rrcInactLocationReportEnabled disabled
    ...     - NGAP:LocationReport is sent to AMF after receiving from AMF NGAP: LocationReportingControl during Feature Flag
    ...       rrcInactLocationReportEnabled enabled

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Configure Max Paging Retries    max_paging_retries=10
    ...        AND             Configure Paging Delay    ue_id=1    paging_delay=1s
    ...        AND             Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=1
    ...        AND             Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
    ...        AND             Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386

    Attach UE    ue_id=1
    Establish PDU With Gateway-1 And Wait For Inactive State For UE1
    Wait For RRC Release Message With Suspend Config
    Configure Paging Delay    ue_id=1    paging_delay=60s
    Ue Send Location Reporting Control    ue=1    event_type=direct
    Wait For Location Report Message
    Kill Ue    id=1
    Configure Paging Delay    ue_id=2    paging_delay=1s
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
    Attach UE    ue_id=2
    Establish PDU With Gateway-2 And Wait For Inactive State For UE2
    Wait For RRC Release Message With Suspend Config    number_of_messages=2
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=rna_Update
    Trigger RRC Resume    ue_id=2
    Configure Paging Delay    ue_id=2    paging_delay=60s
    Ue Send Location Reporting Control    ue=2    event_type=direct
    Wait For Location Report Message    number_of_messages=2
    Kill Ue    id=2
    Configure Paging Delay    ue_id=3    paging_delay=1s
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
    Attach UE    ue_id=3
    Establish PDU With Gateway-3 And Wait For Inactive State For UE3
    Wait For RRC Release Message With Suspend Config    number_of_messages=4
    Trigger Drop Action In RRC Resume Message For UE3
    Set Parameters For UE RRC Resume Request    ue_id=3    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    Ue Send Location Reporting Control    ue=3    event_type=direct
    Wait For Location Report Message    number_of_messages=3
    Kill Ue    id=3
    Configure Paging Delay    ue_id=4    paging_delay=1s
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=4
    Attach UE    ue_id=4
    Establish PDU With Gateway-4 And Wait For Inactive State For UE4
    Wait For RRC Release Message With Suspend Config    number_of_messages=5
    Set Parameters For UE RRC Resume Request    ue_id=4    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=rna_Update
    Ue Send Location Reporting Control    ue=4    event_type=direct
    Wait For Location Report Message    number_of_messages=4
    Kill Ue    id=4
    Configure Paging Delay    ue_id=5    paging_delay=1s
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=5
    Attach UE    ue_id=5
    Establish PDU With Gateway-5 And Wait For Inactive State For UE5
    Wait For RRC Release Message With Suspend Config    number_of_messages=6
    Verify AreaCodeList Contains Correct AreaCode1    number_of_messages=6
    Ue Send Location Reporting Control    ue=5    event_type=change-of-serving-cell
    Wait For Location Report Message    number_of_messages=5
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1    parameter=ranAC    value=1    operation=delete
    Ue Send Location Reporting Control    ue=5    event_type=change-of-serving-cell
    Wait For Location Report Message    number_of_messages=6
    UE Send Location Reporting Control    ue=5    event_type=ue-presence-in-area-of-interest    object_id=1
    ...                                   location_reporting_reference_id=1    object_id=2    location_reporting_reference_id=2
    Wait For Location Report Message    number_of_messages=7
    Set Parameters For UE RRC Resume Request    ue_id=5    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    Ue Send Location Reporting Control    ue=5    event_type=direct
    Wait For Location Report Message    number_of_messages=8
    Kill Ue    id=5
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1    parameter=ranAC    value=2    operation=update
    Configure Paging Delay    ue_id=6    paging_delay=1s
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=6
    Attach UE    ue_id=6
    Establish PDU With Gateway-6 And Wait For Inactive State For UE6
    Wait For RRC Release Message With Suspend Config    number_of_messages=7
    Verify AreaCodeList Contains Correct AreaCode2
    Ue Send Location Reporting Control    ue=6    event_type=change-of-serving-cell
    Wait For Location Report Message    number_of_messages=9
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1    parameter=ranAC    value=1    operation=delete
    Ue Send Location Reporting Control    ue=6    event_type=change-of-serving-cell
    Wait For Location Report Message    number_of_messages=10
    UE Send Location Reporting Control    ue=6    event_type=ue-presence-in-area-of-interest    object_id=1
    ...                                   location_reporting_reference_id=1    object_id=2    location_reporting_reference_id=2
    Wait For Location Report Message    number_of_messages=11

    Verify Tcpdump Log    packet_filter=${F1AP_PAGING}    number_of_messages=5
    Verify Tcpdump Log    packet_filter=${RRC_PAGING}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}    number_of_messages=5
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL}    number_of_messages=4
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_WITH_TIMESTAMP}    number_of_messages=11
    Verify Tcpdump Log    packet_filter=${LOCATION_REPORT_REFERENCE_ID_AND_NRCELL1_IDENTITY}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${LOCATION_REPORT_REFERENCE_ID_AND_NRCELL2_IDENTITY}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${LOCAL_REPORT_WITH_NRCELL_1_IDENTITY_IN_AREAOFINTERESTLIST}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${LOCAL_REPORT_WITH_NRCELL_2_IDENTITY_IN_AREAOFINTERESTLIST}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_FAILURE}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1}    number_of_messages=3
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_COMPLETE}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_RNA_UPDATE_CELL_1}    number_of_messages=1
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_RNA_UPDATE_CELL_2}    number_of_messages=1
    Verify Tcpdump Log    packet_filter=${LOCAL_REPORT_WITH_NRCELL_1_IDENTITY}    number_of_messages=10
    Verify Tcpdump Log    packet_filter=${LOCAL_REPORT_WITH_NRCELL_2_IDENTITY}    number_of_messages=3
    Verify Tcpdump Log    packet_filter=${CORRECT_PLMN_IN_ULI}    number_of_messages=11
    Verify Tcpdump Log    packet_filter=${CORRECT_PLMN_IN_AOIL}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}   number_of_messages=0
    Verify Tcpdump Log    packet_filter=${LOCATION_REPORT_WITH_NRCELL1_IN_AOICL}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${LOCATION_REPORT_WITH_NRCELL2_IN_AOICL}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${UE_PRESENCE_EQUAL_IN_FOR_REFERENCEID1}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${UE_PRESENCE_EQUAL_OUT_FOR_REFERENCEID2}    number_of_messages=2
