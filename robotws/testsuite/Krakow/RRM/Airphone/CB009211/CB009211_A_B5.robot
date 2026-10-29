*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com

Resource      resources/CB009211_resources.robot

Suite Setup    Run keywords
...    Prepare suite environment
...    scfc=${scfc}
...    egate_config=${egate_config}
...    ap_xml=${iphy}
...    x2=False
...    AND     Create aliases

Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/setup_AWEUC_4cells_TMOUS.cfg
${scfc}=            ${CURDIR}/config/SCFC_AWEUC_4cells_TMOUS.xml
${iphy}=            ${CURDIR}/config/AP_AWEUC_4cells_TMOUS.xml

*** Test Cases ***
CB009211_A_B5_Too_Early_handover_detection_after_successful_intra-gNB_handover_execution
    CB009211 feature enable
    Configure intrafreq A5 RSRQ HO
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Start observer for intragNB HO
    Trigger measurement    event_type=A5    physcell_id=52

    Get UE RNTI    UE_ID=1
    Start observer for RRCReestablishment message
    Configure RRCRestablishment after succesfull handover with cause    cause_type=otherFailure
    Verify RRCReestablishment message    physcell_id=52    reestablishment_cause=otherFailure

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55200C00006    1    MRO_EARLY_HO_RSRQ_NB
    ...    M55142C00532    1    MRO_EARLY_HO_RSRQ
    ...    M55200C00005    0    MRO_EARLY_HO_RSRP_NB
    ...    M55142C00531    0    MRO_EARLY_HO_RSRP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55124C00505    1    RRC_REESTAB_OTHER_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
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
    ...    UE_1:NR-RRC_RRCReconfiguration
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    alias=IntragNB_handover  overall_timeout=10

Configure RRCRestablishment after succesfull handover with cause
    [Arguments]    ${cause_type}
    Execute egate command     cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=${cause_type}

Trigger measurement
    [Arguments]    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp= UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed   timeout=10

    Flow occurred as expected  alias=IntragNB_handover
