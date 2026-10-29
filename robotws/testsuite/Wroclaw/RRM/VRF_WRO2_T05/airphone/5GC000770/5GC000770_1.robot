*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    PY311
...           CONFIGURED    5G_RAN_TDD    5G_RAN   SBTS00    RAN_5G    RAN_5G_TDD
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Ewa Wrzesinska,Katarzyna Wisniewska
...              :contact: ewa.wrzesinska@nokia.com,katarzyna.wisniewska@nokia.com
...              :testsuite description: The feature 5GC000770 provides the UE location information at cell level. It can be provided
...              by the gNB to the AMF through different messages and on demand after AMF request (Location Reporting Control
...              message). The feature can be enabled/disabled per gNB by an activation flag.

Resource    5GC000770_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_xn_and_a5_activation.json
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2gNB_2c_tdd_2c_fdd_sansa.lua
...            AND             Wait For Xn Link Status Value Change    xn_link_id=10    value=available    timeout=60
...            AND             Perform Parameter Commissioning    parameter=actLocationReportingSA    value=true
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords  Roll Delta Back
...                                initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                                delta_scf_filename=delta_xn_and_a5_activation.json
...               AND           Perform Parameter Commissioning    parameter=actLocationReportingSA  value=false
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000770_A_B4_1_Successful_Location_Reporting_After_Inter_gNB_Handover_Via_XnAP_UE_Presence_And_Change_Cell
    [Documentation]   This test case checks successful UE Location Reporting procedure after Inter-gNB handover via XnAP.
    ...               Location Reporting Information IE in XnAP is set to change-of-serving-cell and stored in UE
    ...               Context. Handover is triggered based on A5 measurement and it is triggered twice as we need
    ...               to check the real gNB behavior (handover from real gNB to simulated and then back again to the
    ...               real gNB). UE History Information List is needed for Airphone to proceed with the procedure.
    ...               After handover completion gNB-CU-CP shall send a Location Report to AMF.
    ...               Test case covers requirement: 5G_RAN_USR_RRM_1984

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Attach Ue    ue_id=1
        ...    AND             Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1

    Configure Area Of Interest IEs
    Trigger Location Reporting    ue_id=1  event_type=change-of-serving-cell
    Trigger Location Reporting Upon AOI    ue_id=1
    Wait For Location Reporting Control To Be Processed
    Send Custom UE Measurement NR  id=1 meas_id=1 index=0 nrs_result=50:56:0 event=A5 phycell_id=52 nrsrp_nr=50 srsrp_nr=56
    ...                            pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ...                            timeout=10
    Add Item To UE History Information List    gnb_id=3
    Configure Area Of Interest IEs
    Trigger Location Reporting    ue_id=1  event_type=change-of-serving-cell
    Trigger Location Reporting Upon AOI    ue_id=1
    Wait For Location Reporting Control To Be Processed
    Send Custom UE Measurement NR  id=1 meas_id=1 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=50
    ...                            pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...                            timeout=20
    Wait For Location Reporting Control To Be Processed
    Verify Egate Content    expected_pattern=${AOI_IN_HANDOVER_REQUEST}    occurrence=1
    Verify Egate Content    expected_pattern=${AOI_REPORT_AFTER_HANDOVER}    occurrence=4
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL}  number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_AOI}  number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORT_ULI}  number_of_messages=4
    Verify Tcpdump Log    packet_filter=${XNAP_WITH_LOCATION_REPORTING_ELEMENT}  number_of_messages=2

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000770_B_Successful_Location_Reporting
    [Documentation]   This TC checks the gNB behavior for reporting User Location Information IE (ULI)
    ...               in following messages when feature flag is activated:
    ...               PDU Session Resource Modify Response
    ...               PDU Session Resource Release
    ...               UE Context Release Complete
    ...               UE Context Modification Complete
    ...               Requirement covered: 5G_RAN_USR_RRM_1991, 5G_RAN_USR_RRM_1990, 5G_RAN_USR_RRM_1993, 5G_RAN_USR_RRM_1992

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_fallback_activation.json
    ...        AND             Attach Ue    ue_id=2

    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Modify PDU Session    ue_id=2    pdu_id=2    qos_to_add=2
    Release PDU Session    ue_id=2    pdu_id=2    initiator=ue
    Deregister UE    ue_id=2
    Attach Ue    ue_id=3
    Establish PDU Session    ue_id=3    pdu_id=3    gw_id=3
    Set Emergency Fallback On
    Trigger Emergency Fallback
    Verify Ngap Messages    packet_filter=${ULI_IN_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}
    Verify Ngap Messages    packet_filter=${ULI_IN_PDU_SESSION_RESOURCE_RELEASE_RESPONSE}
    Verify Ngap Messages    packet_filter=${ULI_IN_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${ULI_IN_UE_CONTEXT_MODIFICATION_RESPONSE}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=2-3
    ...           AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_fallback_default.json
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
