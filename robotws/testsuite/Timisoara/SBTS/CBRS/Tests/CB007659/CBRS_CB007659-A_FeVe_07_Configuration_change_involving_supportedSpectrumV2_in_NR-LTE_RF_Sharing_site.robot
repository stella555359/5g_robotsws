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
CBRS_CB007659-A_FeVe_07_Configuration_change_involving_supportedSpectrumV2_in_NR-LTE_RF_Sharing_site

    [Documentation]    Tested Requirement: 5G_RAN_USR_COM_5596
    ...                Purpose: Test case verifies successful configuration change which impacts current
    ...                channels by updating parameter CBSD.supportedSpectrumV2 in NR-LTE RF Sharing site.
    ...                This automated testcase is designed only for double BTS (LTE-NR) setup with RF sharing.

    [Timeout]    15min

    #Variables setup
    Log To Console    ${\n}Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${gnb_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}

    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_07/precondition_delta.json
    ...    ${OUTPUT_DIR}/precondition_delta.json    enb_id=${enb_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_07/postcondition_delta.json
    ...    ${OUTPUT_DIR}/postcondition_delta.json    enb_id=${enb_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_07/supportedSpectrumV2_change.json
    ...    ${OUTPUT_DIR}/supportedSpectrumV2_change.json    enb_id=${enb_id}

    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=RAT_1ST

    #Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Check If 5G Cells Are Disabled    gnb_id=${gnb_id}    alias=RAT_2ND

    Log To Console    ${\n}Start a new SAS instance
    ${sas_pid}    ${sas_log} =    Start SAS Process    config=${CURDIR}/Data/FeVe_07/SAS_Sim.conf
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND

    Start Watchdog Alarm Detection
    Start Watchdog Alarm Detection    alias=RAT_2ND

    ${grant_cell_id_1}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=1
    ${grant_cell_id_2}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=2
    ${grant_cell_id_3}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=3

    Log To Console    ${\n}Step 1. Change whole frequency in supportedSpectrumV2
    ${time_start}   Get Time
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/supportedSpectrumV2_change.json    connection=RAT_1ST
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    ${time_stop}   Get Time

    Log To Console    ${\n}Step 2. Checking if eNB deactivated current cells
    ${parsed_log_file}   Parse SAS Log File    log_file_name=/home/ute/SASSim/default/SAS_Sim.log
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}
    ${deregistrationResponse}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                          data_type=deregistrationResponse
    ...                                                          parameter=cbsdId

    Length Should Be    ${deregistrationResponse}    1

    Log To Console    ${\n}Step 3. Checking if eNB aquired new grants
    ${new_grant_cell_id_1}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=1
    ${new_grant_cell_id_2}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=2
    ${new_grant_cell_id_3}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=3

    Should Not Be Equal    {grant_cell_id_1}    {new_grant_cell_id_1}
    Should Not Be Equal    {grant_cell_id_2}    {new_grant_cell_id_2}
    Should Not Be Equal    {grant_cell_id_3}    {new_grant_cell_id_3}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    alias=RAT_2ND    AND
    ...    Kill All SAS Processes
