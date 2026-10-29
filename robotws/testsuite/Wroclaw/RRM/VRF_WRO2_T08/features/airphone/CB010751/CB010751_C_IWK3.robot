*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :contact: marcin.plawny@nokia.com

Resource    CB010751_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_10751_no_ransharing.json    skip_relation_errors=False
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_redcap.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml

Suite Teardown    Run Keywords    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2  operation=delete  parameter=ranAC  value=11
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_10751_no_ransharing.json

Test Teardown    Run Keywords    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2  operation=delete  parameter=ranAC  value=11
...              AND             Area Of Interest Configuration Reset
...              AND             Add Scout Scf Id To Test Data
...              AND             Stop Default Logging
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB010751_C_IWK3_4_LRC_Change_Of_Serve_Cell_And_AoI_For_RedCap_UE_In_RRC_INACTIVE_During_RNA_Update_To_Cell_Without_RANAC
    [Documentation]    This user scenario describes the location reporting when the UE moves to a different cell (Location reporting event type
    ...                is change in cell) which is in the Area of Interest (location reporting event type is area of interest) but RANAC
    ...                for this cell isnt configured.
    ...                5G_RAN_USR_RRM_24512

    [Setup]    Run Keywords    Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
    ...        AND             Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386
    ...        AND             Area Of Interest Configuration    object_id=3    plmn=311:489    nrci=16387
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=4
    Attach UE    ue_id=4
    Establish PDU Session    ue_id=4    gw_id=4    pass_regexp=UE4: Is INACTIVE    timeout=14
    Set Parameters For UE RRC Resume Request    ue_id=4    gnb_id=2    cell_nr=2    msg=resume_request    cause=rna_Update
    UE Send Location Reporting Control    ue=4    event_type=change-of-serving-cell
    UE Send Location Reporting Control    ue=4    event_type=ue-presence-in-area-of-interest
    ...    object_id=1 location_reporting_reference_id=1    object_id=2 location_reporting_reference_id=2
    Trigger RRC Resume    ue_id=4
    Wait For Location Report Message    number_of_messages=2
    Wait For RRC Release Message Without Suspend Config    number_of_messages=1
    Deregister UE    ue_id=4
    Sleep    1s    reason=Wait for deregistration to be processed

    Change UE Location    ue_id=4    dst_enb=2    dst_cell=1
    Attach UE    ue_id=4
    Establish PDU Session    ue_id=4    gw_id=4    pass_regexp=UE4: Is INACTIVE    timeout=14
    Set Parameters For UE RRC Resume Request    ue_id=4    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    UE Send Location Reporting Control    ue=4    event_type=stop-change-of-serving-cell
    UE Send Location Reporting Control    ue=4    event_type=stop-ue-presence-in-area-of-interest
    ...    location_reporting_reference_id_to_be_cancelled=1
    UE Send Location Reporting Control    ue=4    event_type=direct
    Wait For Location Report Message    number_of_messages=3
    Set Parameters For UE RRC Resume Request    ue_id=3    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Deregister UE    ue_id=4
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_AOI}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_STOP_AOI}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_STOP_CHANGE_CELL}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_ULI}    number_of_messages=3
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_WITH_TIMESTAMP}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_1}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_CAUSE_RNA_UPDATE_CELL_2}

    [Teardown]    Run Keywords    Area Of Interest Configuration Reset
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

CB010751_C_IWK3_5_LRC_Change_Of_Serving_Cell_For_RedCap_UE_In_RRC_INACTIVE_During_RNA_Update_Different_RANAC_On_Cells
    [Documentation]    This user scenario describes the gNB behaviour associated with successful location reporting procedure for RedCap UE
    ...                being in RRC_INACTIVE state, when the ue changes from one cell to another which have different RANAC configured.
    ...                5G_RAN_USR_RRM_24512

    [Setup]    Run Keywords    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2  operation=update  parameter=ranAC  value=11
    ...        AND             Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
    ...        AND             Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386
    ...        AND             Set PDU Param Internal Traffic    ue_id=3    pdu_id=1
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3    gw_id=3    pass_regexp=UE3: Is INACTIVE    timeout=14
    Set Parameters For UE RRC Resume Request    ue_id=3    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=rna_Update
    UE Send Location Reporting Control    ue=3    event_type=change-of-serving-cell
    Trigger RRC Resume    ue_id=3
    Wait For Location Report Message    number_of_messages=2

    Wait For RRC Release Message With Suspend Config    number_of_messages=2
    Set Parameters For UE RRC Resume Request    ue_id=3    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=rna_Update
    UE Send Location Reporting Control    ue=3    event_type=ue-presence-in-area-of-interest
    ...    object_id=1 location_reporting_reference_id=1    object_id=2 location_reporting_reference_id=2
    UE Send Location Reporting Control    ue=3    event_type=stop-change-of-serving-cell
    Trigger RRC Resume    ue_id=3
    Wait For Location Report Message    number_of_messages=4

    Set Parameters For UE RRC Resume Request    ue_id=3    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Wait For RRC Release Message With Suspend Config    number_of_messages=3
    Deregister UE    ue_id=3

    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_AOI}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_STOP_CHANGE_CELL}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_ULI}    number_of_messages=4
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_WITH_TIMESTAMP}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_RNA_UPDATE_CELL_1}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_RNA_UPDATE_CELL_2}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MO_SIGNALING_CELL_1}

CB010751_C_IWK3_7_LRC_Sent_Three_Times_With_Different_EventTypes_For_RedCap_UE_In_RRC_INACTIVE_When_EventType_Direct_Causes_Resume_To_Other_Cell
    [Documentation]    This user scenario describes the location reporting with the event type with direct, change of serving cell,
    ...                UE presence in the area of interest.
    ...                5G_RAN_USR_RRM_24512

    [Setup]    Run Keywords    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2  operation=update  parameter=ranAC  value=11
    ...        AND             Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
    ...        AND             Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386
    ...        AND             Set PDU Param Internal Traffic    ue_id=2    pdu_id=1
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    gw_id=2    pass_regexp=UE2: Is INACTIVE    timeout=37
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    UE Send Location Reporting Control    ue=2    event_type=ue-presence-in-area-of-interest
    ...    object_id=1 location_reporting_reference_id=1    object_id=2 location_reporting_reference_id=2
    Start DL Traffic    ue_id=2    pdu_id=1
    Wait For Location Report Message    number_of_messages=2

    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    Wait For RRC Release Message With Suspend Config    number_of_messages=2
    Start DL Traffic    ue_id=2    pdu_id=1
    Wait For Location Report Message    number_of_messages=3

    Wait For RRC Release Message With Suspend Config    number_of_messages=3
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    UE Send Location Reporting Control    ue=2    event_type=change-of-serving-cell
    UE Send Location Reporting Control    ue=2    event_type=direct
    Wait For Location Report Message    number_of_messages=7
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    Wait For RRC Release Message With Suspend Config    number_of_messages=4
    UE Send Location Reporting Control    ue=2    event_type=direct
    Wait For Location Report Message    number_of_messages=8
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    Wait For RRC Release Message With Suspend Config    number_of_messages=5
    Start DL Traffic    ue_id=2    pdu_id=1
    Set Parameters For UE RRC Resume Request    ue_id=3    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Deregister UE    ue_id=2

    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_AOI}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL}
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_ULI}    number_of_messages=10
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_WITH_TIMESTAMP}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_1}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_2}    number_of_messages=3
