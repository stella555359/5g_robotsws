*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    PY311
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com
...              :testsuite description: The feature 5GC000770 provides the UE location information at cell level. It can be provided
...              by the gNB to the AMF through different messages and on demand after AMF request (Location Reporting Control
...              message). The feature can be enabled/disabled per gNB by an activation flag.

Resource    5GC000770_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...             AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_a3_activation.json
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Perform Parameter Commissioning    parameter=actLocationReportingSA  value=true
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1-6
...              AND            Add Scout External Execution ID To Reporting Portal
...              AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords  Roll Delta Back
...                                initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                                delta_scf_filename=delta_a3_activation.json
...               AND           Perform Parameter Commissioning    parameter=actLocationReportingSA  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000770_C_A_B5_1_Successful_Location_Reporting_Cancel_Procedure_Change_Cell
    [Documentation]  This test case checks successful cancellation of Location Reporting procedure for the UE
    ...              with Event Type IE change-of-serving-cell and cancel-location-reporting-for-the-ue. gNB-CU-CP gets
    ...              Location Reporting Request with Event Type IE set to cancel-location-reporting-for-the-ue and then
    ...              cancels Location Reporting. Location Report is not sent to AMF after hanover.
    ...              Requirement covered: 5G_RAN_USR_RRM_1985
    Attach UE  ue_id=4
    Trigger Location Reporting After ICS  ue_id=4  event_type=change-of-serving-cell
    Establish PDU Session  ue_id=4    pdu_id=4    gw_id=4
    Trigger Location Reporting  ue_id=4  event_type=cancel-location-reporting-for-the-ue
    Wait For Location Reporting Control To Be Processed
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=4  cell_id=2  phycell_id=51  nrsrp_nr=40  srsrp_nr=30
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...                              timeout=7
    Verify Ngap Messages  packet_filter=${ICS_LOCATION_REPORTING_IE_CHANGE_CELL}  number_of_messages=1
    Verify Ngap Messages  packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CANCEL_REPORTING}  number_of_messages=1
    Verify Ngap Messages  packet_filter=${NGAP_LOCATION_REPORT_ULI}  number_of_messages=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C06504   +1    NNGCC_UE_CTXT_STP_REQ_LOC_REQ
    ...    M55125C06501   +1    NNGCC_LOC_REPORT_CTRL_RECD
    ...    M55125C06502   +1    NNGCC_LOC_REPORT_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

5GC000770_C_A_B7_1_Successful_Location_Reporting_Stop_Procedure_For_UE_Presence
    [Documentation]  This test case checks successful stop of Location Reporting upon Area Of Interest with Event Type IE
    ...              change-of-serving-cell, ue-presence-in-area-of-interest and stop-ue-presence-in-area-of-interest.
    ...              When gNB-CU-CP gets Location Reporting Request Type IE with Event Type IE set to
    ...              stop-ue-presence-in-the-area-of-interest then it stops Location Reporting for UE when presence in
    ...              the area of interests changes. In the end, location is reported only after a change of serving cell.
    ...              Requirement covered: 5G_RAN_USR_RRM_1987
    Attach UE  ue_id=5
    Configure Area Of Interest IEs
    Trigger Location Reporting Upon AOI After ICS  ue_id=5
    Establish PDU Session  ue_id=5    pdu_id=5    gw_id=5
    Trigger Location Reporting  ue_id=5  event_type=change-of-serving-cell
    Stop Location Reporting Upon AOI  ue_id=5  reference_to_stop=1
    Wait For Location Reporting Control To Be Processed
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=5  cell_id=2  phycell_id=51  nrsrp_nr=40  srsrp_nr=30
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...                              timeout=7
    Wait For Location Reporting Control To Be Processed
    Verify Ngap Messages  packet_filter=${ICS_LOCATION_REPORTING_IE_AOI}  number_of_messages=1
    Verify Ngap Messages  packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_STOP_AOI}  number_of_messages=1
    Verify Ngap Messages  packet_filter=${NGAP_LOCATION_REPORT_ULI}  number_of_messages=4
