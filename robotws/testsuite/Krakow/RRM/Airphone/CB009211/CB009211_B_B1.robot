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
CB009211_B_B1_Intra_gNB_Handover_to_Wrong_cell_detection_during_handover_execution
    CB009211 feature enable
    Configure intrafreq A3 RSRP HO B_B1
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Get UE RNTI    UE_ID=1

    Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause    cause_type=handoverFailure
    Start observer for RRCReestablishment message
    Trigger measurement    event_type=A3    physcell_id=51

    Run keyword and continue on failure    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=handoverFailure
    Verify UE is on cell    ue_id=1    cell_id=3

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55142C00534    0    MRO_WRONG_CELL_HO_RSRQ
    ...    M55142C00533    1    MRO_WRONG_CELL_HO_RSRP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Verify nrrel mro counters    counter=M55200C00008    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                          filepath=${pm_counters}    value=0    nrrel=1
    Verify nrrel mro counters    counter=M55200C00007    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                          filepath=${pm_counters}    value=1    nrrel=1
    Verify nrrel mro counters    counter=M55200C00008    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                          filepath=${pm_counters}    value=0    nrrel=2
    Verify nrrel mro counters    counter=M55200C00007    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                          filepath=${pm_counters}    value=0    nrrel=2

    Verify last counters in file
    ...    M55124C00504    1    RRC_REESTAB_HO_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}
    Verify last counters in file
    ...    M55124C00504    0    RRC_REESTAB_HO_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Verify last counters in file
    ...    M55124C00504    0    RRC_REESTAB_HO_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    [Teardown]    Run keywords
                  ...    Deregister UE    UE_ID=1
                  ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause
    [Arguments]    ${cause_type}
    Execute egate command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=3 gnb=2 cause=${cause_type}

Trigger measurement
    [Arguments]    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp=UE-1 PDU SESSION ID-1 setup/reestablishment complete    timeout=10
