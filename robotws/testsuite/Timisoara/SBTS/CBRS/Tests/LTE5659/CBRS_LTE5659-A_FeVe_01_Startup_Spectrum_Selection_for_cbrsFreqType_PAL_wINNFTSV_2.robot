*** Settings ***
Documentation
...    = Author =
...    justyna.durak@nokia.com
...    aleksandra.chudzik@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    katarzyna.olszewska@nokia.com
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    jakub.klein@nokia.com

*** Keywords ***
CBRS_LTE5659-A_FeVe_01_Startup_Spectrum_Selection_for_cbrsFreqType_PAL_wINNFTSV_2
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.375.
    ...                Purpose: This test case verify PAL channel assignation to CBSD cells when cbrsFreqType
    ...                is configured as PAL and wINNFTSV is 2.0. If there is no PAL channel and unassigned cell,
    ...                CBSD should assign GAA channel to this cell.

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${num_of_cells}   Get Number of Cells    ${enb_id}
    ${alias}   Set Variable    RAT_1ST

    # check if number of cells in configuration is supported by test scenario
    IF  ${1} < ${num_of_cells} < ${5}
        Log To Console    ${num_of_cells} cells detected
    ELSE
        Fail    Configuration with ${num_of_cells} cell(s) not supported by this scenario
    END

    Modify Bandwidth For All Cbsd Cells    enb_id=${enb_id}    required_chbw=10

	${num_of_pal_channels}   Evaluate    ${num_of_cells}-1
	${SAS_config_name}   Set Variable    SAS_Sim_${num_of_cells}_CBSD_cells

    Log To Console    Preconditions
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_01/precondition_delta.json
    ...    ${OUTPUT_DIR}/precondition_delta.json
    ...    enb_id=${enb_id}
    Replace Variables In File
    ...    ${CURDIR}/Data/FeVe_01/postcondition_delta.json
    ...    ${OUTPUT_DIR}/postcondition_delta.json
    ...    enb_id=${enb_id}

    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...        delta_file=${OUTPUT_DIR}/precondition_delta.json
    ...        connection=${alias}

    Log To Console    Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}
    Disable CBRS Feature On eNB

    Log To Console    Step 1. Starting SAS Simulator (number of PAL channels: ${num_of_pal_channels})
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_01/${SAS_config_name}.conf

    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    Log To Console    Step 2. Read channel types and grant IDs from Infomodel
    ${grantchanneltype_list}   Create List
    FOR    ${i}    IN RANGE    ${1}    ${num_of_cells}+1
        ${channel_type}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=${i}
        Append To List    ${grantchanneltype_list}    ${channel_type}
    END
    # sorting needed to have 'GAA' as the first list element
    Sort List    ${grantchanneltype_list}

    # prepare a list with expected channel types and compare it with current results
    ${required_grantchanneltype_list}   Create List    GAA
    FOR    ${i}    IN RANGE    ${1}    ${num_of_cells}
        Append To List    ${required_grantchanneltype_list}    PAL
    END
    Should Be Equal    ${grantchanneltype_list}    ${required_grantchanneltype_list}

    #get grant IDs from IM
    ${grant_list_infomodel}   Create List
    FOR    ${i}    IN RANGE    ${1}    ${num_of_cells}+1
        ${grant_id}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=${i}
        Append To List    ${grant_list_infomodel}    ${grant_id}
    END
    ${time_stop}   Get Time

    Log To Console    Step 3. Reading grant IDs from grantRequest in SAS_Sim.log
    ${parsed_log_file}   Parse SAS Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}

    ${operationFrequencyRange}   Extract Values From Sas Log
    ...                            log_name=${parsed_log_file}
    ...                            data_type=grantRequest
    ...                            parameter=operationFrequencyRange

    ${grant_list_sas_sim_log}   Create list
    FOR    ${item}    IN    @{operationFrequencyRange}
        ${low_freq}   Get From Dictionary    ${item}    lowFrequency
        ${high_freq}   Get From Dictionary    ${item}    highFrequency
        ${grant_id}   Catenate    SEPARATOR=_    ${low_freq}    ${high_freq}
        Append To List    ${grant_list_sas_sim_log}    ${grant_id}
    END
    Log To Console    List of grants from SAS Sim log: ${grant_list_sas_sim_log}

    Log To Console    Step 4. Comparing grant list from infomodel with grant list from grantRequest
    List Should Contain Sublist    ${grant_list_sas_sim_log}    ${grant_list_infomodel}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
    ...                               delta_file=${OUTPUT_DIR}/postcondition_delta.json    connection=${alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}
