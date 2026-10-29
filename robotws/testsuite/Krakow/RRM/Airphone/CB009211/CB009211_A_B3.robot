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
CB009211_A_B3_Too_Early_handover_detection_during_intra-gNB_handover_execution
    CB009211 feature enable
    Configure intrafreq A3 RSRP HO
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Get UE RNTI    UE_ID=1

    Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause    cause_type=handoverFailure
    Start observer for RRCReestablishment message
    Trigger measurement    event_type=A3    physcell_id=51

    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=handoverFailure

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55200C00006    0    MRO_EARLY_HO_RSRQ_NB
    ...    M55142C00532    0    MRO_EARLY_HO_RSRQ
    ...    M55200C00005    1    MRO_EARLY_HO_RSRP_NB
    ...    M55142C00531    1    MRO_EARLY_HO_RSRP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55124C00504    1    RRC_REESTAB_HO_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Deregister UE    UE_ID=1
    Set feature flag NRBTS-1/actIntraNRMRO to false
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Get Ue RNTI    UE_ID=1

    Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause    cause_type=handoverFailure
    Start observer for RRCReestablishment message
    Trigger measurement    event_type=A3    physcell_id=51

    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=handoverFailure

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55200C00006    0    MRO_EARLY_HO_RSRQ_NB
    ...    M55142C00532    0    MRO_EARLY_HO_RSRQ
    ...    M55200C00005    0    MRO_EARLY_HO_RSRP_NB
    ...    M55142C00531    0    MRO_EARLY_HO_RSRP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55124C00504    1    RRC_REESTAB_HO_FAILURE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Deregister UE    UE_ID=1
    Set feature flag NRPMRNL-1/miNrNeighborNrNrCuSa to disabled
    Set feature flag NRPMRNL-1/miNrMobilityReport to disabled

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify if pm counter does not exist    counter_id=MRO_EARLY_HO_RSRQ_NB
    ...                                    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${pm_counters}
    Verify if pm counter does not exist    counter_id=MRO_EARLY_HO_RSRQ
    ...                                    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${pm_counters}
    Verify if pm counter does not exist    counter_id=MRO_EARLY_HO_RSRP_NB
    ...                                    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${pm_counters}
    Verify if pm counter does not exist    counter_id=MRO_EARLY_HO_RSRP
    ...                                    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${pm_counters}

    [Teardown]    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause
    [Arguments]    ${cause_type}
    Execute egate command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cause=${cause_type}

Trigger measurement
    [Arguments]    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp=UE-1 PDU SESSION ID-1 setup/reestablishment complete    timeout=10
