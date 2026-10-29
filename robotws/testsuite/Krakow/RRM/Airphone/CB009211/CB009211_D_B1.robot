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
CB009211_D_B1_Ping-pong_handover_detection_(intra-gNB)
    CB009211 feature enable
    Configure intrafreq A3 RSRP HO
    Configure tPingPong    ms=10000
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    RRC_CHECK=True
    Get UE RNTI    UE_ID=1

    Start observer for intragNB HO
    Trigger measurement with first HO    event_type=A3    physcell_id=51
    Verify UE is on cell    ue_id=1    cell_id=2

    Setup sleep lower than tPingPong

    Start observer for intragNB HO
    Trigger measurement with second HO    event_type=A3    physcell_id=50

    Verify UE is on cell    ue_id=1    cell_id=1

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55200C00009    1    MRO_PINGPONG_HO_NB
    ...    M55142C00535    1    MRO_PING_PONG_HO
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

Trigger measurement with first HO
    [Arguments]    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp= UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed   timeout=10

    Flow occurred as expected  alias=IntragNB_handover

Trigger measurement with second HO
    [Arguments]    ${event_type}    ${physcell_id}
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=${event_type} phycell_id=${physcell_id}
    ...    pass_regexp= UE1: Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed   timeout=10

    Flow occurred as expected  alias=IntragNB_handover

Setup sleep lower than tPingPong
    Sleep    5s

Configure tPingPong
    [Arguments]    ${ms}
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'tPingPong': '${ms}'}
