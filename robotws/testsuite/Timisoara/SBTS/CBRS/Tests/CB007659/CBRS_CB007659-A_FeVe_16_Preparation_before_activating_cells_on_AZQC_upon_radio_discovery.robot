*** Settings ***
Documentation
...    = Author =
...    _aleksandra.chudzik@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    karol.sadowski@nokia.com
...    katarzyna.kadziela@nokia.com

*** Keywords ***
CBRS_CB007659-A_FeVe_16_Preparation_before_activating_cells_on_AZQC_upon_radio_discovery
    [Documentation]    Tested Requirement: 5G_RAN_USR_COM_16032, 5G_RAN_USR_COM_5595
    ...                Purpose: Test case verifies if eNB BTS executes Pre-Tx Measurement
    ...                and activates cells upon radio discovery in NR-LTE RF Sharing site.
    ...                This automated testcase is designed only for double BTS (LTE-NR) setup with RF sharing.
    [Timeout]    20min

    #Variables setup
    Log To Console    ${\n}Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${gnb_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}
    ${enb_smod_sn}   Get Serial Number Of System Module
    ${gnb_smod_sn}   Get Serial Number Of System Module    alias=RAT_2ND
    &{expected_alarm}   Create Dictionary    fault_id=4773    fault_name=Radio unit reset triggered by peer BTS
    ...                                        severity=Critical

    #Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Log To Console    ${\n}Start a new SAS instance
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe_16/SAS_Sim.conf
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND

    Start Watchdog Alarm Detection
    Start Watchdog Alarm Detection    alias=RAT_2ND

    Log To Console    ${\n}Step 1. Perform RMOD reset
    ${reset_timestamp}   Get Time
    Add Fault To Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    alias=RAT_2ND
    Perform RMOD Reset

    Log To Console    ${\n}Step 2. Check whether Pre-Tx Measurement is performed
    Wait Until Keyword Succeeds    3x    10s    Wait Until Enhanced Measure Finish    listening_timestamp=${reset_timestamp}    wait_time=5min

    Log To Console    ${\n}Step 3. Check if BTSes activate the cells
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    alias=RAT_2ND

    Log To Console    ${\n}Step 4. Check creation of new "locks" for the corresponding frequency blocks
    ${enb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${enb_smod_sn}
    ${gnb_freq_block_id}   Get Freq Block Id For A Given Smod Serial Number    smod_serial_num=${gnb_smod_sn}
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${enb_freq_block_id}
    ...    alias_for_grant_info=RAT_1ST    alias_for_freq_block=RAT_1ST
    Verify Cbrs Frequency Block Inside The Info Model    freq_block_id=${gnb_freq_block_id}
    ...    alias_for_grant_info=RAT_2ND    alias_for_freq_block=RAT_1ST

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    alias=RAT_2ND    AND
    ...    Kill All SAS Processes
