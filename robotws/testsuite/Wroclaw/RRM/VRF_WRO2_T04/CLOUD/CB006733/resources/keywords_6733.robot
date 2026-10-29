*** Settings ***
Documentation
...   Feature 6733 keywords for CloudRan

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py

*** Keywords ***
Set Initial Attenuation For A1 measurement
    [Arguments]    ${pcell_id}=10
    Set Attenuation    25    ${ATTENUATOR['NRCELL_${pcell_id}']['ports']}  confirm=${TRUE}
    Set Attenuation    25    ${ATTENUATOR['NRCELL_11']['ports']}  confirm=${TRUE}
    Set Attenuation    ${ATTENUATOR['NRCELL_20']['attenuation']}  ${ATTENUATOR['NRCELL_20']['ports']}
    Set Attenuation    60  ${ATTENUATOR['NRCELL_22']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_30']['attenuation']}  ${ATTENUATOR['NRCELL_30']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_40']['attenuation']}  ${ATTENUATOR['NRCELL_40']['ports']}

Trigger Scell Addition Based On A1 FDD
    [Arguments]    ${pcell_id}=10
    Set Attenuation    10
    ...    ${ATTENUATOR['NRCELL_${pcell_id}']['ports']}  confirm=${TRUE}
    Set Attenuation    10
    ...    ${ATTENUATOR['NRCELL_11']['ports']}  confirm=${TRUE}

Trigger Scell Addition Based On A1 TDD
    [Arguments]    ${pcell_id}=10
    Set Attenuation    0
    ...    ${ATTENUATOR['NRCELL_${pcell_id}']['ports']}  confirm=${TRUE}
    Set Attenuation    0
    ...    ${ATTENUATOR['NRCELL_11']['ports']}  confirm=${TRUE}

Trigger Scell Addition Based On A4
    [Arguments]  ${scell_id}    ${attenuation}
    Set Att For Cell With Id  ${scell_id}    ${attenuation}

Scell Change Performed
    [Arguments]    ${pcap_file}    ${scell_add}    ${scell_index}    ${scell_rel_index}
    Scell Swap Performed    ${pcap_file}    scell_added_id=${scell_add}    scell_added_index=${scell_index}
    ...    scell_released_index=${scell_rel_index}

Trigger Handover From Cell
    [Arguments]    ${src_cell_id}  ${dst_cell_id}
    Gradually Decrease Attenuation    port=${ATTENUATOR['NRCELL_${dst_cell_id}']['ports']}    step=15    interval=1
    ...    init_value=60
    ...    min_value=${ATTENUATOR['NRCELL_${dst_cell_id}']['attenuation']}
    Gradually Increase Attenuation    port=${ATTENUATOR['NRCELL_${src_cell_id}']['ports']}    step=15    interval=1
    ...    init_value=${ATTENUATOR['NRCELL_${src_cell_id}']['attenuation']}
    ...    max_value=60

Check 13684 counters
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55177C00019    ${AHLOB_CELL_10}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55177C00021    ${AHLOB_CELL_10}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55177C00023    ${AHLOB_CELL_10}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55177C00025    ${AHLOB_CELL_10}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55184C00011    ${AHLOB_CELL_10}
    ...    expected_value=1    profile=NRPMQAP-1
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55184C00012    ${AHLOB_CELL_10}
    ...    expected_value=1    profile=NRPMQAP-1
     Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55184C00011    ${AHFII_CELL_20}
    ...    expected_value=1    profile=NRPMQAP-1
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55184C00012    ${AHFII_CELL_20}
    ...    expected_value=1    profile=NRPMQAP-1
