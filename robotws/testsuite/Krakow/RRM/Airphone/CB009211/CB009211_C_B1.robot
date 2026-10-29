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
...    AND    Create aliases

Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/setup_AWEUC_4cells_TMOUS.cfg
${scfc}=            ${CURDIR}/config/SCFC_AWEUC_4cells_TMOUS.xml
${iphy}=            ${CURDIR}/config/AP_AWEUC_4cells_TMOUS.xml

*** Test Cases ***
CB009211_C_B1_Too_Late_handover_detection_due_to_too_late_handover_execution_when_Handover_is_NOT_in_progress
    CB009211 feature enable
    Configure intrafreq A5 RSRQ HO
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Get UE RNTI    UE_ID=1

    Trigger RRCRestablishment
    Start observer for RRCReestablishment message

    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=otherFailure
    Verify UE is on cell    ue_id=1    cell_id=3
    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55200C00003    0    MRO_LATE_HO_LATE_EXEC_RSRP_NB
    ...    M55142C00529    0    MRO_LATE_HO_LATE_EXEC_RSRP
    ...    M55200C00004    1    MRO_LATE_HO_LATE_EXEC_RSRQ_NB
    ...    M55142C00530    1    MRO_LATE_HO_LATE_EXEC_RSRQ
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55124C00505    1    RRC_REESTAB_OTHER_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

    [Teardown]    Run keywords
                  ...    Deregister UE    UE_ID=1
                  ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Trigger measurement
    [Arguments]    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp=UE-1 PDU SESSION ID-1 setup/reestablishment complete    timeout=10

Trigger RRCRestablishment
    Execute egate command     cmd=ue_rrc_reestablish id=1 gnb=2 cell=3 cause=otherFailure
