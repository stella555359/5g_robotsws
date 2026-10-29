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
${egate_config}=    ${CURDIR}/config/setup_AWEUB_3cells_2UEs.cfg
${scfc}=            ${CURDIR}/config/SCFC_AWEUB_3cells.xml
${iphy}=            ${CURDIR}/config/AP_AWEUB_3cells.xml

*** Test Cases ***
CB009211_D_B1_Ping-pong_handover_detection_(intra-gNB)
    CB009211 feature enable
    Configure intrafreq A3 RSRP HO exploratory
    Configure tPingPong    ms=10000
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actIntraNRMRO': 'true'}
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Get UE RNTI    UE_ID=1
    #### Start MRO_PING_PONG_HO ###
    Start observer for intragNB HO    ue_id=1
    Trigger measurement with first HO    ue_id=1    event_type=A3    physcell_id=51
    Verify UE is on cell    ue_id=1    cell_id=2

    Setup sleep lower than tPingPong

    Start observer for intragNB HO    ue_id=1
    Trigger measurement with second HO    ue_id=1    event_type=A3    physcell_id=50

    Verify UE is on cell    ue_id=1    cell_id=1
    #### end MRO_PING_PONG_HO ###
    #### Start MRO_EARLY_HO_RSRP ###
    Get UE RNTI    UE_ID=1
    Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause    ue_id=1    cause_type=handoverFailure
    Start observer for RRCReestablishment message    ue_id=1
    Trigger measurement    ue_id=1    event_type=A3    physcell_id=51

    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=handoverFailure
    Verify UE is on cell    ue_id=1    cell_id=1
    #### end MRO_EARLY_HO_RSRP ###
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actIntraNRMRO': 'false'}
    #### Start MRO_WRONG_CELL_HO_RSRP ###
    Get UE RNTI    UE_ID=1
    Configure itemB RRCRestablishment after RRCReconfiguration in A3 measurement with cause    ue_id=1    cause_type=handoverFailure
    Start observer for RRCReestablishment message    ue_id=1
    Trigger measurement    ue_id=1    event_type=A3    physcell_id=51

    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=handoverFailure
    Verify UE is on cell    ue_id=1    cell_id=3
    #### end MRO_WRONG_CELL_HO_RSRP ###
    #### Start MRO_LATE_HO_LATE_EXEC_RSRP ###
    Get UE RNTI    UE_ID=1
    Trigger RRCRestablishment    ue_id=1
    Start observer for RRCReestablishment message    ue_id=1

    Verify RRCReestablishment message    physcell_id=52    reestablishment_cause=otherFailure
    Verify UE is on cell    ue_id=1    cell_id=1
    #### end MRO_LATE_HO_LATE_EXEC_RSRP ###

    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actIntraNRMRO': 'true'}
    Register UE    UE_ID=2    CELL_ID=1
    Establish PDU session    UE_ID=2    PDU_ID=1    GW_ID=1    RRC_CHECK=True
    Get UE RNTI    UE_ID=2
    #### Start MRO_PING_PONG_HO ###
    Start observer for intragNB HO    ue_id=2
    Trigger measurement with first HO    ue_id=2    event_type=A3    physcell_id=51
    Verify UE is on cell    ue_id=2    cell_id=2

    Setup sleep lower than tPingPong

    Start observer for intragNB HO    ue_id=2
    Trigger measurement with second HO    ue_id=2    event_type=A3    physcell_id=50

    Verify UE is on cell    ue_id=2    cell_id=1
    #### end MRO_PING_PONG_HO ###
    #### Start MRO_EARLY_HO_RSRP ###
    Get UE RNTI    UE_ID=2
    Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause    ue_id=2    cause_type=handoverFailure
    Start observer for RRCReestablishment message    ue_id=2
    Trigger measurement    ue_id=2    event_type=A3    physcell_id=51

    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=handoverFailure
    Verify UE is on cell    ue_id=2    cell_id=1
    #### end MRO_EARLY_HO_RSRP ###
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actIntraNRMRO': 'false'}
    #### Start MRO_WRONG_CELL_HO_RSRP ###
    Get UE RNTI    UE_ID=2
    Configure itemB RRCRestablishment after RRCReconfiguration in A3 measurement with cause    ue_id=2    cause_type=handoverFailure
    Start observer for RRCReestablishment message    ue_id=2
    Trigger measurement    ue_id=2    event_type=A3    physcell_id=51

    Verify RRCReestablishment message    physcell_id=50    reestablishment_cause=handoverFailure
    Verify UE is on cell    ue_id=2    cell_id=3
    #### end MRO_WRONG_CELL_HO_RSRP ###
    #### Start MRO_LATE_HO_LATE_EXEC_RSRP ###
    Get UE RNTI    UE_ID=2
    Trigger RRCRestablishment    ue_id=2
    Start observer for RRCReestablishment message    ue_id=2

    Verify RRCReestablishment message    physcell_id=52    reestablishment_cause=otherFailure
    Verify UE is on cell    ue_id=2    cell_id=1
    #### end MRO_LATE_HO_LATE_EXEC_RSRP ###
    ${pm_counters}=    Wait for next pm interval and get counters
    Run keyword and continue on failure    Verify last counters in file
    ...    M55142C00531    2    MRO_EARLY_HO_RSRP
    ...    M55142C00535    2    MRO_PING_PONG_HO
    ...    M55142C00533    0    MRO_WRONG_CELL_HO_RSRP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Run keyword and continue on failure    Verify last counters in file
    ...    M55142C00529    0    MRO_LATE_HO_LATE_EXEC_RSRP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

    Run keyword and continue on failure    Verify nrrel mro counters    counter=M55200C00005    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                          filepath=${pm_counters}    value=2    nrrel=1
    Run keyword and continue on failure    Verify nrrel mro counters    counter=M55200C00009    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                          filepath=${pm_counters}    value=2    nrrel=1
    Run keyword and continue on failure    Verify nrrel mro counters    counter=M55200C00007    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                          filepath=${pm_counters}    value=0    nrrel=1
    Run keyword and continue on failure    Verify nrrel mro counters    counter=M55200C00003    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...                          filepath=${pm_counters}    value=0    nrrel=1

    [Teardown]    Run keywords
                  ...    Deregister UE    UE_ID=1
                  ...    AND    Deregister UE    UE_ID=2

*** Keywords ***
Start observer for intragNB HO
    [Arguments]    ${ue_id}
    Expect message flow
    ...    UE_${ue_id}:NR-RRC_MeasurementReport
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB2:F1AP_UEContextModificationResponse
    ...    UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...    UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB2:F1AP_UEContextModificationResponse
    ...    UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...    UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...    alias=IntragNB_handover  overall_timeout=10

Trigger measurement with first HO
    [Arguments]    ${ue_id}    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp= UE${ue_id}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed   timeout=10

    Flow occurred as expected  alias=IntragNB_handover

Trigger measurement with second HO
    [Arguments]    ${ue_id}    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp= UE${ue_id}: Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed   timeout=10

    Flow occurred as expected  alias=IntragNB_handover

Setup sleep lower than tPingPong
    Sleep    5s

Configure tPingPong
    [Arguments]    ${ms}
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'tPingPong': '${ms}'}

Configure RRCRestablishment after RRCReconfiguration in A3 measurement with cause
    [Arguments]    ${ue_id}    ${cause_type}
    Execute egate command     cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish cause=${cause_type}

Configure itemB RRCRestablishment after RRCReconfiguration in A3 measurement with cause
    [Arguments]    ${ue_id}    ${cause_type}
    Execute egate command     cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish cell=3 gnb=2 cause=${cause_type}

Trigger measurement
    [Arguments]    ${ue_id}    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp=UE-${ue_id} PDU SESSION ID-1 setup/reestablishment complete    timeout=10

Trigger RRCRestablishment
    [Arguments]    ${ue_id}
    Execute egate command     cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=otherFailure

Configure intrafreq A3 RSRP HO exploratory
    Configure    ${CURDIR}/config/exploratory_intra_gNB_intra_freq_A3_RSRP_based_HO.yaml


Start observer for RRCReestablishment message
    [Arguments]    ${ue_id}
    Expect message flow
    ...    UE_${ue_id}:NR-RRC_RRCReestablishmentRequest as RRCReestablishmentRequest
    ...    UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...    alias=RRCReestablishment_procedure    overall_timeout=10

Verify RRCReestablishment message
    [Arguments]    ${physcell_id}    ${reestablishment_cause}
    Flow occurred as expected    alias=RRCReestablishment_procedure
    Verify That Message Has Fields    c-RNTI eq ${crnti_UE}
    ...                               physCellId eq ${physcell_id}
    ...                               reestablishmentCause eq '${reestablishment_cause}'
    ...                               message_alias=RRCReestablishmentRequest
    ...                               flow_alias=RRCReestablishment_procedure
