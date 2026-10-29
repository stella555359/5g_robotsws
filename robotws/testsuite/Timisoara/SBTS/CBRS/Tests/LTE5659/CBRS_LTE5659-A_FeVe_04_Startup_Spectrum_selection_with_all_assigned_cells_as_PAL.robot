*** Settings ***
Documentation
...    = Author =
...    justyna.durak@nokia.com
...    = Maintainer =
...    justyna.durak@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    jakub.klein@nokia.com
...    aleksandra.chudzik@nokia.com

*** Keywords ***
CBRS_LTE5659-A_FeVe_04_Startup_Spectrum_selection_with_all_assigned_cells_as_PAL
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.375 Purpose: This test case verify when CBSD assign PAL
    ...                channel to cells and no more cells are unasigned and cbrsFreqPriority is configured
    ...                to different value for each cell.

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST

    Log To Console    Preconditions
    Replace Variables In File    ${CURDIR}/Data/FeVe_04/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_04/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

    Wait Until Keyword Succeeds    5x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/precondition_delta.json    connection=${alias}

    Log To Console    Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Log To Console    Step 1. Start SAS, pal_reserved_channels: 3580,3590,3600,3610
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe_04/SAS_Sim.conf

    ${time_start}   Get Time
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    Log To Console    Step 2. Read channel types and grant IDs from Infomodel
    ${grantChannelType_cell_1}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=1
    ${grantChannelType_cell_2}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=2
    ${grantChannelType_cell_3}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=3
    ${grantChannelType_cell_4}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=4

    Should Be Equal    ${grantChannelType_cell_1}    PAL
    Should Be Equal    ${grantChannelType_cell_2}    PAL
    Should Be Equal    ${grantChannelType_cell_3}    PAL
    Should Be Equal    ${grantChannelType_cell_4}    PAL

    ${grant_cell_id_1}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=1
    ${grant_cell_id_2}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=2
    ${grant_cell_id_3}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=3
    ${grant_cell_id_4}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=4
    ${time_stop}   Get Time

    Log To Console    Step 3. SAS_Sim.log analysis in order to read grant IDs from grantRequest
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}

    ${operationFrequencyRange}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                           data_type=grantRequest
    ...                                                           parameter=operationFrequencyRange

    ${grant_list_SAS_Sim_log}   Create list

    FOR    ${item}    IN    @{operationFrequencyRange}
        ${low_freq}    Get From Dictionary    ${item}    lowFrequency
        ${high_freq}   Get From Dictionary    ${item}    highFrequency
        ${grant_id}    Catenate    SEPARATOR=_    ${low_freq}    ${high_freq}
        Append To List    ${grant_list_SAS_Sim_log}    ${grant_id}
    END
    Log    ${grant_list_SAS_Sim_log}

    Log To Console    Step 4. Comparing grant list from infomodel with grant list from grantRequest
    ${grant_list_infomodel}   Create List    ${grant_cell_id_1}    ${grant_cell_id_2}    ${grant_cell_id_3}    ${grant_cell_id_4}
    List Should Contain Sublist    ${grant_list_SAS_Sim_log}    ${grant_list_infomodel}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
    ...                               delta_file=${OUTPUT_DIR}/postcondition_delta.json    connection=${alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}
