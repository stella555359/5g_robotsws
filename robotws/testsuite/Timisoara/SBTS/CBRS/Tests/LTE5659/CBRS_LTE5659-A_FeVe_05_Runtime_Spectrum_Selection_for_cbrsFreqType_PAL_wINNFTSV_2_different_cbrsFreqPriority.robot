*** Settings ***
Documentation
...    = Author =
...    justyna.durak@nokia.com
...    = Maintainer =
...    justyna.durak@nokia.com
...    = Reviewer =
...    katarzyna.olszewska@nokia.com
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    jakub.klein@nokia.com
...    aleksandra.chudzik@nokia.com

*** Keywords ***
CBRS_LTE5659-A_FeVe_05_Runtime_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2_different_cbrsFreqPriority
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.376 Purpose: This test case verify whether CBSD assign
    ...                channel to cells on runtime phase when there is grant with operation state AUTHORIZED or GRANTED
    ...                and there are also cells on not in service state and cbrsFreqPriority is configured to different
    ...                value for each cell.

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}

    Log To Console    Step 1. Preconditions
    Replace Variables In File    ${CURDIR}/Data/FeVe_05/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_05/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

    Wait Until Keyword Succeeds    5x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/precondition_delta.json    connection=${alias}

    Log To Console    Step 2. Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Disable CBRS Feature On eNB
    Log To Console    Step 3. Start SAS
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process
    ...                                default
    ...                                4433
    ...                                ${CURDIR}/Data/FeVe_05/SAS_Sim.conf

    ${time_start_1_cell_on_air}   Get Time
    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Step 4. Part 1 - waiting until 1 cell become onAir, while others are disabled
    Wait Until Keyword Succeeds    10x    20s    Check If Cell State Is Reached
    ...                                          cell_id=4
    ...                                          state=operationalState
    ...                                          state_value=Enabled

    ${time_stop_1_cell_on_air}   Get Time

    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start_1_cell_on_air}
    ...                                          date_stop=${time_stop_1_cell_on_air}

    ${grantId_4_SAS_log}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                     data_type=heartbeatResponse
    ...                                                     parameter=grantId

    Log To Console    Step 5. Part 2 - waiting until all cells become onAir
    ${time_start_all_cells_on_air}   Get Time
    Wait For All Cells To Be OnAir
    ${time_stop_all_cells_on_air}   Get Time

    Log To Console    Step 6. Read channel types and grant IDs from Infomodel
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3
    ${grantChannelType_cell_4}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=4

    Should Be Equal    ${grantChannelType_cell_1}    GAA
    Should Be Equal    ${grantChannelType_cell_2}    GAA
    Should Be Equal    ${grantChannelType_cell_3}    PAL
    Should Be Equal    ${grantChannelType_cell_4}    PAL

    ${grant_cell_id_1}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=1
    ${grant_cell_id_2}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=2
    ${grant_cell_id_3}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=3
    ${grant_cell_id_4}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=4

    Log To Console    Step 7. SAS_Sim.log analysis in order to read grant IDs from grantRequest
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start_all_cells_on_air}
    ...                                          date_stop=${time_stop_all_cells_on_air}

    ${operationFrequencyRange}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                            data_type=grantRequest
    ...                            parameter=operationFrequencyRange

    ${grant_list_SAS_Sim_log}   Create list

    FOR    ${item}    IN    @{operationFrequencyRange}
        ${low_freq}    Get From Dictionary    ${item}    lowFrequency
        ${high_freq}   Get From Dictionary    ${item}    highFrequency
        ${grant_id}    Catenate    SEPARATOR=_    ${low_freq}    ${high_freq}
        Append To List    ${grant_list_SAS_Sim_log}    ${grant_id}
    END
    Log    ${grant_list_SAS_Sim_log}

    Append To List    ${grant_list_SAS_Sim_log}    @{grantId_4_SAS_log}
    Log    ${grant_list_SAS_Sim_log}

    Log To Console    Step 8. Comparing grant list from infomodel with grant list from grantRequest
    ${grant_list_infomodel}   Create List    ${grant_cell_id_1}    ${grant_cell_id_2}    ${grant_cell_id_3}    ${grant_cell_id_4}
    List Should Contain Sublist    ${grant_list_SAS_Sim_log}    ${grant_list_infomodel}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
    ...        delta_file=${OUTPUT_DIR}/postcondition_delta.json    connection=${alias}    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}
