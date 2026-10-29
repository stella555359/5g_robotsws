*** Settings ***
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Library      String
Library      OperatingSystem
Library      Process
Library      taf.rfrl.utilities.tl_config
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                 WITH NAME    cell_operations
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                     WITH NAME    du_operations
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                    WITH NAME    commissioning
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations            WITH NAME    asir
Library      taf.rfrl.utilities.logger.custom_logger                                   WITH NAME    logger
Library      taf.rfrl.common_resources.python.coam_parameter                           WITH NAME    coam_parameters
Library      taf.sbts.oam.coam.admin                                                   WITH NAME    admin
Library      taf.gnb.oam.coam.admin                                                    WITH NAME    coam
Library      ./resources.py                                                            WITH NAME    local_resources
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                WITH NAME    alarm

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py

*** Keywords ***
Reset Hubs
    [Arguments]     ${hub_list}
    FOR     ${hub}      IN      ${hub_list}
        asir.Reset Hub      hub_id=${hub}
        asir.Verify Hubmod Status       hub_ids=${hub}      expected_statuses=${statuses_after_reset_hub}
        ${ru_id}=       local_resources.prepare Ru Id For Checking Ip      ${hub}
        Verify If Ip Assigned To SW0 InterFace On HUBs     ru_id=${ru_id}
    END
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells

Reset BBMODs
    [Arguments]    ${bbmods}=null
    ${bbmods_list}    string.split string    ${bbmods}
    Run Keyword If    '${str_bbmods_list}' == 'null'    logger.log_info_to_console    Reset All BBMODS
    ...    ELSE    logger.log_info_to_console    Reset BBMODs in list @{bbmods_list}
    ${connection}=       admin.connect_to
    ${fbb_info}=    admin.Get fbb info      connection=${connection}
    FOR    ${fbb}    IN    @{fbb_info}
        ${prefix}    ${fbb_full_id} =    string.Split String From Right    ${fbb['id']['internal']}    separator=/
        ...                              max_split=${1}
        ${prefix}    ${fbb_id} =    string.Split String From Right    ${fbb_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${fbb_id}' in @{bbmods_list} or '${str_bbmods_list}' == 'null'    run keywords
        ...    logger.log_info_to_console    Reset BBMOD ${fbb_full_id}
        ...    AND    admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}
        ...                                connection=${connection}
    END

Cell Block And Unblock
    [Arguments]     ${CellIDs}
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    FOR      ${Cell}      IN      @{CellIDs}
        ${cell_id}=      local_resources.get_ids_from_cell_list      cell=${Cell}
        cell_operations.Block Cell      cell_id=${cell_id}
        Sleep      5s
        cell_operations.Verify Cell Is Blocked      cell_id=${cell_id}
        gnb_alarm.Verify Alarm is Active on gNB     fault_name=Cell blocked
        Sleep      5s
        Verify Other Cell Are Actve On BTS      CellIDs=@{CellIDs}          blocked_cell=${cell_id}
        Sleep      5s
        cell_operations.Unblock Cell      cell_id=${cell_id}
        Sleep      5s
        gnb_alarm.Verify Alarm is not Active on gNB      fault_name=Cell blocked
    END
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells

Verify Other Cell Are Actve On BTS
    [Arguments]     ${CellIDs}      ${blocked_cell}
    FOR     ${Cell}     IN      @{CellIDs}
        ${cell_id}=      local_resources.get_ids_from_cell_list      cell=${Cell}
        Run Keyword If    "${cell_id}" != "${blocked_cell}"    cell_operations.Verify Cell Is Onair    cell_id=${cell_id}
    END

Verify DHCP procedure
    [Arguments]     ${ru_id_list}
    gnb_bbu.Reset gNB
    Wait Until Keyword Succeeds      900 sec      30 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    FOR      ${ru}      IN      @{ru_id_list}
        ${ru_id}=       local_resources.prepare Ru Id For Checking Ip      ${ru}
        Verify If Ip Assigned To SW0 InterFace On HUBs     ru_id=${ru_id}
    END

Parameters recommissioning with BTSSM
    [Arguments]     ${local_dir}=/tmp           ${filename}=current_scf.xml
    ...             ${asir_file_path}=/tmp      ${asir_file_name}=current_scf_asir.xml
    du_operations.Verify Configuration Parameters Values     param_dict=${params_commisioning_to_check}
    Wait Until Keyword Succeeds      60 sec      10 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      60 sec      10 sec      gnbcell.Verify Setup of All Cells
    du_operations.Get Bts Configuration File                 local_dir= ${local_dir}     filename=${filename}
    du_operations.Upload Bts Configuration Via Gui           path=${local_dir}/${filename}
    Wait Until Keyword Succeeds      900 sec      30 sec     gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec     gnbcell.Verify Setup of All Cells
    ${asir_path}=       asir.Get Current Scf File       local_dir_path=${asir_file_path}    file_name=${asir_file_name}
    asir.Perform Asir Commissioning                         scf_path=${asir_path}
    Sleep       60s
    Wait Until Keyword Succeeds      900 sec      30 sec     gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec     gnbcell.Verify Setup of All Cells

Get allowed alarms
    [Arguments]    ${alarms_for_test}
    ${allowed_alarms}=     local_resources.get_allowed_alarms     custom_alarms=${alarms_for_test}
    [Return]     ${allowed_alarms}

Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${DEFAULT_ALARMS}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${DEFAULT_ALARMS}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${DEFAULT_ALARMS}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Parameters recommissioning with previous values
    Wait Until Keyword Succeeds      60 sec      10 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      60 sec      10 sec      gnbcell.Verify Setup of All Cells
    ${prev_values_list}=     Create List
    FOR    ${parameter}    IN    @{PARAMETERS_TO_CHANGE_BY_WEBEM}
        ${parameter_name}    Get From Dictionary    ${parameter}    param_name
        ${prev_value_of_parameter}=        du_operations.Get Param Value      param_name=${parameter_name}
        Append To List     ${prev_values_list}     ${prev_value_of_parameter}
    END
    ${delta_file}=      local_resources.generate_delta_file_for_list_of_parameters     list_of_parameters=${PARAMETERS_TO_CHANGE_BY_WEBEM}
    commissioning.perform_bts_delta_commissioning     delta=${delta_file}
    Wait Until Keyword Succeeds      240 sec      10 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      240 sec      10 sec      gnbcell.Verify Setup of All Cells
    ${OLD_PARAMETERS}=      Set Variable     ${PARAMETERS_TO_CHANGE_BY_WEBEM}
    FOR    ${parameter}    IN    @{OLD_PARAMETERS}
        local_resources.iterate_through_list_in_dictionary      list=${prev_values_list}       dicti=${parameter}       parameter=value
    END
    ${delta_previous_file}=      local_resources.generate_delta_file_for_list_of_parameters     list_of_parameters=${OLD_PARAMETERS}
    commissioning.perform_bts_delta_commissioning     delta=${delta_previous_file}
    Wait Until Keyword Succeeds      240 sec      10 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      240 sec      10 sec      gnbcell.Verify Setup of All Cells

Parameters recommissioning with BTSSM without previous
    [Arguments]     ${dict_of_parameters_to_change}
    ${delta_file}=      local_resources.generate_delta_file_for_list_of_parameters     list_of_parameters=${dict_of_parameters_to_change}
    commissioning.perform_bts_delta_commissioning     delta=${delta_file}
    Sleep   300s

Perform asir delta commisioning
    [Arguments]     ${path_to_delta_asir}
    asir.perform_asir_commissioning     scf_path=${path_to_delta_asir}
    Sleep   240s

Parameters recommissioning with BTSSM And AsirWebEm
    ${delta_file}=      local_resources.generate_delta_file_for_list_of_parameters     list_of_parameters=${ALL_PARAMETERS_TO_CHANGE}[WebEM]
    du_comm.perform_bts_delta_commissioning     delta=${delta_file}

    Wait Until Keyword Succeeds     240 sec     10 sec   gnbcell.Verify Setup Of All Cells

    ${dist_name}            Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[AsirWebEM][dist_name]
    ${parameter}            Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[AsirWebEM][param_name]
    ${param_value}          Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[AsirWebEM][value]
    ${prev_val_of_parameter}=       local_resources.get_asirhub_parameter      dist_name=${dist_name}
    ...                             parameter=${parameter}

    local_resources.change_and_activate_asirhub_parameter       dn=${dist_name}         name=${parameter}
    ...                                                         value=${param_value}
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    local_resources.verify_asirhub_parameter        dist_name=${dist_name}      parameter=${parameter}
    ...                                             expected_value=${param_value}

    local_resources.change_and_activate_asirhub_parameter       dn=${dist_name}         name=${parameter}
    ...                                                         value=${prev_val_of_parameter}
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    local_resources.verify_asirhub_parameter        dist_name=${dist_name}      parameter=${parameter}
    ...                                             expected_value=${prev_val_of_parameter}

Get scf from asimgr and webem
    [Arguments]     ${asir_file_name}=current_scf_asir.xml      ${scf_dir_path_asir}=/tmp
    ...             ${file_name}=current_scf_webem.xml                ${scf_dir_path}=/tmp
    Wait Until Keyword Succeeds      60 sec      10 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      60 sec      10 sec      gnbcell.Verify Setup of All Cells
    asir.get_current_scf_file       file_name=${asir_file_name}     local_dir_path=${scf_dir_path_asir}
    du_operations.Get Bts Configuration File        filename=${file_name}       local_dir=${scf_dir_path}      config_type=configuration

Perform asir commisioning
    [Arguments]     ${scf_dir_path_asir}=/tmp/current_scf_asir.xml
    asir.perform_asir_commissioning     scf_path=${scf_dir_path_asir}
    Sleep       240s

Perform webem commisioning
    [Arguments]     ${scf_dir_path}=/tmp/current_scf_webem.xml
    coam.Connect To         bts_host=192.168.255.129         name=cOAM
    commissioning.Perform Bts Full Commissioning     scf_file=${scf_dir_path}
    Sleep       240s

Verify setup is on air
    Wait Until Keyword Succeeds      600 sec      30 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      600 sec      30 sec      gnbcell.Verify Setup of All Cells

Perform parameter changes webem and asir for 1 cell band 25 with gb
    coam.Connect To         bts_host=192.168.255.129         name=cOAM
    ${sw_version}=      gnbbbu.get_bts_sw_release_name
    ${status}=      coam_parameters.Perform Scf Delta Commission        timeout=500         connection=cOAM
    ...             delta_file=${Config_Dir}/${sw_version}/${Delta_Commisioning_B25_1_cell_gb_WebEM}
    Sleep       120s
    asir.perform_asir_commissioning     scf_path=${Config_Dir}/${sw_version}/${Delta_Commisioning_B25_1_cell_gb_ASiR_WebEM}
    Sleep       120s
    Wait Until Keyword Succeeds         900 sec         30 sec      gnbcell.Verify Setup Of All Cells
    [Teardown]      coam.Teardown       connection=cOAM

Perform parameter changes webem for 1 cell 5MHz band 25 with gb
    coam.Connect To         bts_host=192.168.255.129         name=cOAM
    ${sw_version}=      gnbbbu.get_bts_sw_release_name
    ${status}=      coam_parameters.Perform Scf Delta Commission        timeout=500         connection=cOAM
    ...             delta_file=${Config_Dir}/${sw_version}/${Delta_Commisioning_B25_1_cell_5MHz_gb_WebEM}
    Sleep       200s
    Wait Until Keyword Succeeds         900 sec         30 sec      gnbcell.Verify Setup Of All Cells
    [Teardown]      coam.Teardown       connection=cOAM

Perform parameter changes webem and asir for 2 cells band 2 with ngb
    coam.Connect To         bts_host=192.168.255.129         name=cOAM
    ${sw_version}=      gnbbbu.get_bts_sw_release_name
    Run Keyword And Ignore Error     coam_parameters.Perform Scf Delta Commission    timeout=100         connection=cOAM
    ...         delta_file=${Config_Dir}/${sw_version}/${Delta_Commisioning_B2_2_cells_ngb_WebEM}
    Sleep       120s
    Run Keyword And Ignore Error     asir.perform_asir_commissioning
    ...             scf_path=${Config_Dir}/${sw_version}/${Delta_Commisioning_B2_2_cells_ngb_ASiR_WebEM}
    Sleep       50s
    Reset gNB
    Sleep       120s
    [Teardown]      coam.Teardown       connection=cOAM

Perform parameter changes webem and asir for 2 cells band 25 and 66 with gb
    coam.Connect To         bts_host=192.168.255.129         name=cOAM
    ${sw_version}=      gnbbbu.get_bts_sw_release_name
    ${status}=      coam_parameters.Perform Scf Delta Commission        timeout=400         connection=cOAM
    ...             delta_file=${Config_Dir}/${sw_version}/${Delta_Commisioning_B66_B25_2_cells_gb_WebEM}
    Sleep       200s
    asir.perform_asir_commissioning         scf_path=${Config_Dir}/${sw_version}/${Delta_Commisioning_B66_B25_2_cells_gb_ASiR_WebEM}
    Sleep       220s
    Wait Until Keyword Succeeds         900 sec         30 sec      gnbcell.Verify Setup Of All Cells
    [Teardown]      coam.Teardown       connection=cOAM

Perform logscrambling procedure
    ${snapshot_file}=    enblog.Collect Snapshot    log_dir=/home/ute/Tests/EXT_testing/SBTS00_ENB_9999_230425_000009_Snapshot/__snapshot__
    ${result}=     Run Process      scp ${snapshot_file} ute@scrambling-sg09.p04.ska-lab.nsn-rdnet.net:/home/ute/Tests/EXT_testing/
    logger.log_info_to_console   ${result}
    Should Be Equal As Strings    ${should_be_failed}    FAIL

Case Teardown
    Run Keyword If Test Passed      Set Suite Variable      ${cell_block_status}        PASS
    Run Keyword If Test Failed      Set Suite Variable      ${cell_block_status}        FAIL

Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}
