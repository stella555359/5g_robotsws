*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    artur.czainski@nokia.com
...    = Summary =
...    The purpose of this test is to verify whether Grant procedure fullfills requirements stated by WInnForum
...    Technical Specification version 2.0. This scenario implies the presence of both cbsdFrequencyGuidance
...    and featureDataExchange paramenters.

*** Keywords ***
CBRS_LTE5703_FeVe_13_Grant_Procedure_with_cbsdFrequencyGuidance_and_featureDataExchange_present
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.296

    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${num_of_cells}   Get Number of Cells    ${enb_id}

    ${is_AEQM_present}   Run Keyword And Return Status    Query Infomodel
    ...                    query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]
    ...                    timeout=30    alias=${alias}

    # max EIRP will be set to 23.1 for AEQM and 14.1 for AZQC
    ${max_eirp}   Set Variable If    '${is_AEQM_present}'=='True'    23.1    14.1

    IF  ${1} < ${num_of_cells} < ${5}
        Log To Console    ${num_of_cells} cells detected
    ELSE
        Fail    Configuration with ${num_of_cells} cell(s) not supported by this scenario
    END

    # assign proper SAS Simulator configuration file, based on test line configuration
    # 4x guidance: 3550-3590MHz
    # 3x guidance: 3550-3580MHz
    # 2x guidance: 3550-3570MHz
    FOR  ${i}  IN RANGE  ${2}    ${5}
        Continue For Loop If    '${num_of_cells}' != '${i}'
        ${SAS_config_name}   Set Variable    SAS_Sim_${num_of_cells}_CBSD_cells
    END

    #NEW SAS SIM SYNTAX FIX IFOLOGY
    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${SAS_config_name}   Set Variable    ${SAS_config_name}
    ELSE
        ${SAS_config_name}   Catenate    SEPARATOR=    ${SAS_config_name}    _oldbranch
    END
    #NEW SAS SIM SYNTAX FIX IFOLOGY

    ${allowed_low_frequencies}   Create List
    FOR    ${i}    IN RANGE    ${num_of_cells}
        # generate low frequency for each cell (10MHz spacing), starting from 3550MHz
        ${calculated_low_freq}   Evaluate    3550000000+10000000*${i}
        Append To List    ${allowed_low_frequencies}    ${calculated_low_freq}
    END

    # prepare and send precondition plan
    Restore Supported Spectrum    bts_id=${enb_id}

    Wait Until BTS Is Not Busy
    Create Generic Delta And Perform Commissioning    enb_id=${enb_id}
    ...    delta_file_tmp=${CURDIR}/Data/feve13/Precondition_delta_${num_of_cells}_CBSD_cells_tmp.json
    ...    delta_file_final=${CURDIR}/Data/feve13/Precondition_delta_${num_of_cells}_CBSD_cells.json

    Disable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/feve13/${SAS_config_name}.conf
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection
    ${time_stop}   Get Time

    Check If Grant Request is TS2.0 Compliant    alias=${alias}
    ...                                          time_start=${time_start}
    ...                                          time_stop=${time_stop}
    ...                                          sas_log_path=${sas_logs_dir}
    ...                                          numberOfCells=${num_of_cells}
    ...                                          allowed_low_frequencies=${allowed_low_frequencies}
    ...                                          exp_max_eirp=${max_eirp}
    Check If Number Of Feature Data Exchanges Is Correct    alias=${alias}
    ...                                                     time_start=${time_start}
    ...                                                     time_stop=${time_stop}
    ...                                                     sas_log_path=${sas_logs_dir}
    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes
