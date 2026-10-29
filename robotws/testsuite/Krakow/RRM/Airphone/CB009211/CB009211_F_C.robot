*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com

Resource      resources/CB009211_resources.robot

Suite Setup    Prepare NR-DC suite environment Setup

Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_CB009211_F_C.cfg
${SCF_gnb2_MN}=     ${CURDIR}/config/SCFC_gNB1_MN_FR1_NRDC_CB009211_F_C.xml
${SCF_gnb3_SN}=     ${CURDIR}/config/SCFC_gNB2_SN_FR2_NRDC.xml
${AP_XML}=          ${CURDIR}/config/AP_MN_FR1_SN_FR2_NRDC_CB009211_F_C.xml

*** Test Cases ***
CB009211_C_B3_ALT9_Too_Late_handover_detection_due_to_too_late_measurement_configuration_NR-DC_configuration
    CB009211 feature enable NR-DC configuration
    Configure interfreq A3 RSRP HO NR-DC configuration
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=2
    Configure ICS param for AMF

    Establish PDU session    UE_ID=1    RRC_CHECK=True

    Start observer for SNodeAddition
    UE1 sends A4 measurement for NR-DC PSCell addition
    Verify NR-DC setup correctly
    Verify UE is on cell    ue_id=1    cell_id=2
    Get UE RNTI    UE_ID=1

    Start observer for RRCReestablishment message
    Trigger RRCRestablishment
    Verify RRCReestablishment message    physcell_id=52    reestablishment_cause=otherFailure

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55200C00001    0    MRO_LATE_HO_LATE_MEA_RSRP_NB
    ...    M55142C00527    0    MRO_LATE_HO_LATE_MEA_RSRP
    ...    M55200C00002    0    MRO_LATE_HO_LATE_MEA_RSRQ_NB
    ...    M55142C00528    0    MRO_LATE_HO_LATE_MEA_RSRQ
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-2
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55124C00505    1    RRC_REESTAB_OTHER_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-3
    ...    file_path=${pm_counters}

    [Teardown]    Run keywords
                  ...    Deregister UE    UE_ID=1
                  ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***

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
    ...    alias=NR-DC_flow  overall_timeout=6

UE1 sends A4 measurement for NR-DC PSCell addition
    Expect message flow
    ...    UE_1:NR-RRC_MeasurementReport as A4_MeasurementReport
    ...    alias=A4_measurement  overall_timeout=10
    ${command}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A4 srsrp_nr=19 srsrq_nr=10
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

Trigger RRCRestablishment
    Execute egate command     cmd=ue_rrc_reestablish id=1 gnb=2 cell=3 cause=otherFailure
