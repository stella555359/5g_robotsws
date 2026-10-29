*** Settings ***
Documentation
...   Resources for regression testing of feature CB010652
...   author:   Marek Szlapa
...   contact:  marek.szlapa@nokia.com

Library      Collections
Library      taf.config.scf.interface.scf
Library      taf.rfrl.utilities.logger.custom_logger                            WITH NAME    logger
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME    asir
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations              WITH NAME    gnbbbu
Library      taf.rfrl.procedures.resources.python.sw_update.SW_update           WITH NAME    sw_update
Library      testsuite/Krakow/resources/delta/bts_delta_generator.py
Library      AttenuatorKeywords.py
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Variables    ./configuration_variables.py
Variables    ./deltas.py

*** Variables ***
${protocol}     tcp
${duration}     120s
${deviation}    40%
${repeat_measurement_tput}      1
${parallel_streams}             4
${capabilities}                 REAL_UE
${default_scf_filename}         default_scf.xml
${deleted_cell_scf_filename}    deleted_cell_scf.xml
${add_cell_delta_filename}      add_cell_delta.json
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}

*** Keywords ***
Common Preconditions With Watching Alarms and cells set to barred
    [Arguments]    ${cells}
    Common Preconditions With Watching Alarms
    ${delta}  Generate Delta for barred NRCELLs  cells=${cells}
    perform_bts_delta_commissioning   delta=${delta}

Common Postconditions With Watching Alarms and cells set to unbarred
    [Arguments]    ${cells}
    Common Postconditions With Watching Alarms
    ${delta}  Generate Delta for not barred NRCELLs  cells=${cells}
    perform_bts_delta_commissioning    delta=${delta}

CB010652_General_SiSo_Online_Cell_Addition_Deletion
    [Arguments]    ${config}    ${cell_id}    ${DL_attenuation}=0    ${UL_attenuation}=0
    Download gNB Configuration File         local_dir=${LOG_PATH}    filename=${default_scf_filename}
    asir.Perform Asir Recommissioning       ${asir_deltas}[${config}][delta_remove_cell]
    Perform Delta Commissioning On gNB      ${main_deltas}[${config}][delta_remove_cell]
    ${selected_cells}=    Set Variable      ${configurations}[${config}][selected_cells_per_TC][Cell_Add_Del]
    Call to selected cells      cells_info=${configurations}[${config}]
    ...                         selected_cells_ids=${selected_cells}
    ...                         DL_attenuation=${DL_attenuation}
    ...                         UL_attenuation=${UL_attenuation}
    Download gNB Configuration File         local_dir=${LOG_PATH}    filename=${deleted_cell_scf_filename}
    Calculate Delta SCF    ${LOG_PATH}/${default_scf_filename}
    ...                    ${LOG_PATH}/${deleted_cell_scf_filename}
    ...                    ${LOG_PATH}/${add_cell_delta_filename}
    Perform BTS Delta JSON Commissioning    ${LOG_PATH}/${add_cell_delta_filename}
    asir.Perform Asir Recommissioning       ${asir_deltas}[${config}][delta_add_cell]
    Wait Until Keyword Succeeds    60s   10s    gnbcell.verify_all_cells_are_onair
    Append To List    ${selected_cells}    ${cell_id}
    Call to selected cells      cells_info=${configurations}[${config}]
    ...                         selected_cells_ids=${selected_cells}
    ...                         DL_attenuation=${DL_attenuation}
    ...                         UL_attenuation=${UL_attenuation}
    ...                         prepareUE=${False}

General SiSo E2E system setup with data transfer for configuration feature testing
    [Arguments]     ${config}    ${DL_attenuation}=0    ${UL_attenuation}=0
    Set Test Variable    ${deviation}    5%
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][E2E]
    ...                       DL_attenuation=${DL_attenuation}
    ...                       UL_attenuation=${UL_attenuation}

Restore Attenuation
    [Arguments]    ${attenuators}    ${attenuation_value}
    FOR    ${attenuator}    IN    @{attenuators}
        Set attenuation                             value_string=${attenuation_value}
        ...                                         att_id=${attenuator}[attenuator_id]
        ...                                         selected_ports=${attenuator}[ports]
    END

Attenuate RU
    [Arguments]    ${attenuators}
    FOR    ${attenuator}    IN    @{attenuators}
        Gradually increase attenuation              att_id=${attenuator}[attenuator_id]
        ...                                         max_value=110
        ...                                         step=10
        ...                                         interval=2
        ...                                         selected_ports=${attenuator}[ports]
    END

Call to selected cells
    [Arguments]     ${cells_info}    ${selected_cells_ids}    ${DL_attenuation}=0    ${UL_attenuation}=0
    ...             ${prepareUE}=${True}
    Run Keyword If      ${prepareUE}==${True}     Require Ue for L3 Call
    Initialise Attenuators
    Set Max Attenuation On All Attenuators
    FOR     ${selected_cell_id}      IN      @{selected_cells_ids}
        ${selected_cell}    Get selected cell info    ${cells_info}[cells]    ${selected_cell_id}
        Restore Attenuation    attenuators=${selected_cell}[attenuators]    attenuation_value=${DL_attenuation}
        Sleep    15s
        logger.log_info_to_console    ***Call for Cell ${selected_cell}[id]***    log_hierarchy=${2}
        Run Keyword And Continue On Failure   Verify L3 Call One Way Data Transfer  duration=${duration}
        ...                                                                         protocol=${protocol}
        ...                                                                         tput=${selected_cell}[tput_dl]
        ...                                                                         deviation=${deviation}
        ...                                                                         direction=dl
        ...                                                                         parallel_streams=${parallel_streams}
        Run Keyword If      ${UL_attenuation}!=${DL_attenuation}
        ...    Restore Attenuation    attenuators=${selected_cell}[attenuators]    attenuation_value=${UL_attenuation}
        Run Keyword And Continue On Failure   Verify L3 Call One Way Data Transfer  duration=${duration}
        ...                                                                         protocol=${protocol}
        ...                                                                         tput=${selected_cell}[tput_ul]
        ...                                                                         deviation=${deviation}
        ...                                                                         direction=ul
        ...                                                                         parallel_streams=${parallel_streams}
        Attenuate RU    attenuators=${selected_cell}[attenuators]
    END

Get selected cell info
    [Arguments]    ${cells_info}    ${selected_cell_id}
        FOR    ${cell_info}    IN    @{cells_info}
            ${selected_cell_info}=    Set Variable If    ${cell_info}[id] == ${selected_cell_id}  ${cell_info}
            Run Keyword If    ${selected_cell_info}    Exit For Loop
        END
    [Return]    ${selected_cell_info}

Reset all pRRHs via ASIRWebEM
    ${all_ants_ids}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available pRRH IDs: ${all_ants_ids}
    FOR  ${ant_id}  IN  @{all_ants_ids}
        logger.log_info_to_console      Reset ANT ${ant_id}
        asir.reset_antenna              ant_id=${ant_id}
    END
    Wait Until Keyword Succeeds     60 sec     10 sec   gnbcell.verify_all_cells_are_onair

Block Unblock all pRRHs via ASIRWebEM
    ${all_ants_ids}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available pRRH IDs: ${all_ants_ids}
    FOR  ${ant_id}  IN  @{all_ants_ids}
        logger.log_info_to_console      Block ANT ${ant_id}
        asir.block_antenna              ant_id=${ant_id}
    END
    Wait Until Keyword Succeeds    30s   10s    asir.verify_antennas_are_blocked    ant_ids=${all_ants_ids}
    FOR  ${ant_id}  IN  @{all_ants_ids}
        logger.log_info_to_console  Unblock ANT ${ant_id}
        asir.unblock_antenna        ant_id=${ant_id}
    END
    Wait Until Keyword Succeeds    30s   10s    asir.verify_antennas_are_enabled    ant_ids=${all_ants_ids}

Reset BBMOD
    [Arguments]    ${bbmod_id}=1
    gnbbbu.reset_bbmod    bbmod_id=${bbmod_id}
    wait_for_site_to_be_onair

Lock Unlock BBMOD
    [Arguments]    ${bbmod_id}=1
    gnbbbu.lock_bbmod      bbmod_id=${bbmod_id}    timeout=60
    gnbbbu.verify_bbmod_is_locked    bbmod_id=${bbmod_id}
    gnbbbu.unlock_bbmod    bbmod_id=${bbmod_id}    timeout=60
    wait_for_site_to_be_onair

Get SW release
    ${sw_version}             sw_update.get_sw_version
    ${sw_version_splitted}    string.split_string    ${sw_version.package}    _
    [Return]    ${sw_version_splitted[0]}
