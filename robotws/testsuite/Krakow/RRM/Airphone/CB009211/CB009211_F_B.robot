*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com

Resource      resources/CB009211_resources.robot

Suite Setup    Prepare NR-DC suite environment Setup

Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=     ${CURDIR}/config/SCFC_gNB1_MN_FR1_NRDC.xml
${SCF_gnb3_SN}=     ${CURDIR}/config/SCFC_gNB2_SN_FR2_NRDC.xml
${AP_XML}=          ${CURDIR}/config/AP_MN_FR1_SN_FR2_NRDC.xml

*** Test Cases ***
CCB009211_B_B2_ALT18_intra_gNB_Handover_to_Wrong_cell_detection_after_successful_handover_NR-DC_configuration
    CB009211 feature enable NR-DC configuration
    Configure intrafreq A5 RSRQ HO NR-DC configuration
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Configure ICS param for AMF
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Start observer for intragNB HO
    Trigger measurement    event_type=A5    physcell_id=52
    Verify A4 measurement installed after HO

    Start observer for SNodeAddition
    UE1 sends A4 measurement for NR-DC PSCell addition
    Verify NR-DC setup correctly
    Verify UE is on cell    ue_id=1    cell_id=2
    Get UE RNTI    UE_ID=1
    Start observer for RRCReestablishment message
    Configure RRCRestablishment after succesfull handover with cause    cause_type=otherFailure
    Verify RRCReestablishment message    physcell_id=52    reestablishment_cause=otherFailure

    Verify dc state    ue_id=1    state=INACTIVE

    Verify UE is on cell    ue_id=1    cell_id=3

    ${pm_counters}=    Wait for next pm interval and get counters
    Run keyword and continue on failure    Verify last counters in file
    ...    M55200C00008    1    MRO_WRONG_CELL_HO_RSRQ_NB
    ...    M55142C00534    1    MRO_WRONG_CELL_HO_RSRQ
    ...    M55200C00007    0    MRO_WRONG_CELL_HO_RSRP_NB
    ...    M55142C00533    0    MRO_WRONG_CELL_HO_RSRP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55124C00505    1    RRC_REESTAB_OTHER_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-3
    ...    file_path=${pm_counters}
    Verify last counters in file
    ...    M55124C00505    0    RRC_REESTAB_OTHER_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
    ...    file_path=${pm_counters}
    Verify last counters in file
    ...    M55124C00505    0    RRC_REESTAB_OTHER_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-2
    ...    file_path=${pm_counters}

    [Teardown]    Run keywords
                  ...    Deregister UE    UE_ID=1
                  ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Start observer for intragNB HO
    Expect message flow
    ...    UE_1:NR-RRC_MeasurementReport
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB2:F1AP_UEContextModificationResponse
    ...    UE_1:NR-RRC_RRCReconfiguration
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB2:F1AP_UEContextModificationResponse
    ...    UE_1:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    alias=IntragNB_handover  overall_timeout=10

Verify A4 measurement installed after HO
    Verify That Message Has Fields    eventA4 is present
    ...                               message_alias=RRCReconfiguration
    ...                               flow_alias=IntragNB_handover

Start observer for SNodeAddition
    Expect message flow
    ...    gNB3:XNAP_SNodeAdditionRequest
    ...    gNB3:XNAP_SNodeAdditionRequestAcknowledge
    ...    gNB2:E1AP_BearerContextModificationRequest
    ...    gNB2:E1AP_BearerContextModificationResponse
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB2:F1AP_UEContextModificationResponse
    ...    gNB3:XNAP_XnUAddressIndication
    ...    UE_1:NR-RRC_RRCReconfiguration
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB3:XNAP_SNodeReconfigurationComplete
    ...    gNB2:F1AP_UEContextModificationResponse
    ...    alias=NR-DC_flow  overall_timeout=5

UE1 sends A4 measurement for NR-DC PSCell addition
    Expect message flow
    ...    UE_1:NR-RRC_MeasurementReport as A4_MeasurementReport
    ...    alias=A4_measurement  overall_timeout=10
    ${command}    Catenate    ue_measurement_send_nr id=1 meas_id=2 event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=54 nrsrp_nr=85 nrsrq_nr=31 index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    Flow occurred as expected  alias=A4_measurement
    Verify That Message Fulfills Query
    ...     measResultNeighCells contains ((resultsSSB-Cell is present) and (rsIndexResults is present))
    ...     message_alias=A4_MeasurementReport
    ...     flow_alias=A4_measurement

Verify NR-DC setup correctly
    Run keyword and continue on failure    Flow occurred as expected  alias=NR-DC_flow
    Verify dc state    ue_id=1    state=ACTIVE

Configure ICS param for AMF
    Execute egate command     cmd=amf_ue_ics_param id=1 ue=1 indexToRFSP=1

Configure RRCRestablishment after succesfull handover with cause
    [Arguments]    ${cause_type}
    Execute egate command     cmd=ue_rrc_reestablish id=1 gnb=2 cell=3 cause=${cause_type}

Trigger measurement
    [Arguments]    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_meas_cfg_disp id=1
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp= UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed   timeout=10

    Flow occurred as expected  alias=IntragNB_handover
