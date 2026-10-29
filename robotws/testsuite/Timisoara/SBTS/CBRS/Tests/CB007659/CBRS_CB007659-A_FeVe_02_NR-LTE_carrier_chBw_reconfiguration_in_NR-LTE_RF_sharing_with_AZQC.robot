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
CBRS_CB007659-A_FeVe_02_NR-LTE_carrier_chBw_reconfiguration_in_NR-LTE_RF_sharing_with_AZQC
    [Documentation]    Tested Requirement: 5G_RAN_USR_COM_5589
    ...                Purpose: Test case verifies successful LTE carrier reconfiguration after
    ...                chBw parameter update in NR-LTE RF sharing site.
    ...                This automated testcase is designed only for double BTS (LTE-NR) setup with RF sharing
    [Timeout]    15min

    #Variables setup
    Log To Console    ${\n}Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${gnb_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}

    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_02/chbw_change.json
    ...    ${OUTPUT_DIR}/chbw_change.json    enb_id=${enb_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_02/postcondition_delta.json
    ...    ${OUTPUT_DIR}/postcondition_delta.json    enb_id=${enb_id}

    #Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Log To Console    ${\n}Start a new SAS instance
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe_02/SAS_Sim.conf
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND

    Start Watchdog Alarm Detection
    Start Watchdog Alarm Detection    alias=RAT_2ND

    Log To Console    ${\n}Step 1. Change chBw to 20MHz for one cell
    ${chBw_10MHz}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-1/LNCEL_M-1 is [ulChBw=10000000]
    ${time_start}   Get Time
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/chbw_change.json    alias=RAT_1ST
    Wait For Any Cell To Be Dropped

    Log To Console    ${\n}Step 2. Checking if eNB activated target cell
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    ${time_stop}   Get Time
    ${chBw_20MHz}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-1/LNCEL_M-1 is [ulChBw=20000000]

    ${parsed_log_file}   Parse SAS Log File    log_file_name=/home/ute/SASSim/default/SAS_Sim.log
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}
    ${relinquishmentResponse}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                          data_type=relinquishmentResponse
    ...                                                          parameter=cbsdId

    Length Should Be    ${relinquishmentResponse}    1

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    alias=RAT_2ND    AND
    ...    Kill All SAS Processes
