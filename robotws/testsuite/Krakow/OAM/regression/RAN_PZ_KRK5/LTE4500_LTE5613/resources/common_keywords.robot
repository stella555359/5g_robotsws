*** Settings ***
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Library      OperatingSystem
Library      SSHLibrary
Library      String
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations                 WITH NAME    asir
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                      WITH NAME    cell_operations
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                          WITH NAME    du_operations
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                     WITH NAME    alarm
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                         WITH NAME    du_comm
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                          WITH NAME    ru_operations
Library      taf.rfrl.common_resources.python.coam_parameter                                WITH NAME    coam_parameters
Library      taf.rfrl.utilities.logger.custom_logger                                        WITH NAME    logger
Library      taf.sbts.oam.coam.admin                                                        WITH NAME    admin
Library      taf.gnb.oam.coam.admin                                                         WITH NAME    coam
Library      ute_syslog                                                                     WITH NAME    syslog
Library      ./resources.py                                                                 WITH NAME    local_resources


*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py


*** Keywords ***
Install Cert
    ${private_key_path}=     local_resources.download_cert_file
    logger.log_info_to_console      ${private_key_path}
    ${connection}=       admin.Connect To
    admin.Install Certificate       cert_file=${private_key_path}       cert_type=BtsTrustChain     cert_format=P12      password=123456
    ${delta_file}=      local_resources.generate_delta_file_to_update     dist_name=MRBTS-76140/MNL-1/MNLENT-1/MPLANENW-1
    ...                 parameter=oamTls     param_value=forced
    du_comm.perform_bts_delta_commissioning     delta=${delta_file}
    Sleep       120s
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells

Change SC To SFN Configuration
    [Arguments]     ${file_name}=initial_configuration.xml
    ...             ${file_path}=/tmp      ${asir_file_name}=initial_configuration_asir.xml
    ${sw_version}=      gnb_bbu.Get gNB Sw Release Name
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    gnb_bbu.Download gNB Configuration File      local_dir=${file_path}         filename=${file_name}
    ${asir_path}=       asir.Get Current Scf File      local_dir_path=${file_path}      file_name=${asir_file_name}
    coam.Connect To     bts_host=192.168.255.129     name=cOAM
    ${status}=          coam_parameters.Perform Scf Delta Commission       timeout=300     connection=cOAM
    ...                 delta_file=${Delta_Commisioning_SC_to_SFN_WebEM}${sw_version}_delta_SC_to_SFN_WeBEM.json
    Sleep       60s
    asir.Perform Asir Commissioning
    ...                 scf_path=${Delta_Commisioning_SC_to_SFN_ASiR_WebEM}${sw_version}_delta_SC_to_SFN_ASiR_WebEM.xml
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    du_comm.Perform Bts Full Commissioning      scf_file=${file_path}/${file_name}
    Sleep       60s
    Wait Until Keyword Succeeds      900 sec      30 sec      ru_operations.Verify Statuses On All Rus      usage_state=Idle
    asir.Perform Asir Commissioning     scf_path=${file_path}/${asir_file_name}
    Sleep   60s
    Wait Until Keyword Succeeds      900 sec      30 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    [Teardown]      coam.Teardown       connection=cOAM

Configuration Reset On ASIR
    [Arguments]     ${file_name}=initial_configuration.xml
    ...             ${file_path}=/tmp      ${asir_file_name}=initial_configuration_asir.xml
    gnb_bbu.Download gNB Configuration File      local_dir=${file_path}         filename=${file_name}
    ${asir_path}=       asir.Get Current Scf File      local_dir_path=${file_path}      file_name=${asir_file_name}
    asir.Reset Configuration
    Sleep       240s
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Config_Reset]
    asir.Perform Asir Commissioning     scf_path=${asir_path}
    Sleep       120s
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]

Site Reset Time
    [Arguments]     ${log_dir}=${OUTPUT_DIR}        ${log_name}=syslog_BTSSM.log
    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}
    Reset gNB
    Sleep   60s
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    FOR     ${hub}      IN RANGE    1       3
        @{hubs_list}    create list
        Append To List    ${hubs_list}    ${hub}
        asir.Verify Hubmod Status       hub_ids=${hubs_list}      expected_statuses=${statuses_after_reset_hub}
        ${hub}=         local_resources.prepare_ru_id_for_checking_ip       ${hub}
        Get Power Consumption       ant_id=${hub}
    END
    FOR     ${ant}      IN RANGE    1       3
        @{ants_list}    create list
        Append To List    ${ants_list}    ${ant}
        ${hub}=         local_resources.prepare_ru_id_for_checking_ip       ${hub}
        asir.Verify Antmod Status       ant_ids=${ants_list}      expected_statuses=${statuses_after_reset_ants}
    END
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]
    syslog.Collect Syslog Results
    FOR     ${Time}     IN      @{Site_Reset_Time_Times}
        ${message_1_time}=        local_resources.Get Time Of Message       log_file_path=${log_dir}/${log_name}
        ...                                       regexp=${Time}[first_regex]
        ${message_2_time}=        local_resources.Get Time Of Message       log_file_path=${log_dir}/${log_name}
        ...                                       regexp=${Time}[second_regex]
        ${Time_diff}=             local_resources.Substract Time From Two Messages        message_1=${message_2_time}
        ...                                        message_2=${message_1_time}
        Should be True      ${Time_diff}<${Time}[max_time_diff]
        logger.log_info_to_console      ${Time}[output_message] ${Time_diff}
    END

Parameters recommissioning with BTSSM And AsirWebEm
    ${dist_name}            Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[WebEM][dist_name]
    ${parameter}            Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[WebEM][param_name]
    ${param_value}          Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[WebEM][value]
    ${prev_val_of_parameter}=      du_operations.get_param_value       param_name=${parameter}
    ${delta_file}=      local_resources.generate_delta_file_to_update     dist_name=${dist_name}
    ...                 parameter=${parameter}      param_value=${param_value}
    du_comm.perform_bts_delta_commissioning     delta=${delta_file}

    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    ${delta_file_to_check}=      local_resources.generate_delta_file_to_check     dist_name=${dist_name}
    ...                 parameter=${parameter}      param_value=${param_value}
    du_operations.verify_configuration_parameters_values        param_dict=${delta_file_to_check}

    ${delta_file}=      local_resources.generate_delta_file_to_update     dist_name=${dist_name}
    ...                 parameter=${parameter}      param_value=${prev_val_of_parameter}
    du_comm.perform_bts_delta_commissioning     delta=${delta_file}

    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    ${delta_file_to_check}=      local_resources.generate_delta_file_to_check     dist_name=${dist_name}
    ...                 parameter=${parameter}      param_value=${prev_val_of_parameter}
    du_operations.verify_configuration_parameters_values        param_dict=${delta_file_to_check}

    ${dist_name}            Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[AsirWebEM][dist_name]
    ${parameter}            Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[AsirWebEM][param_name]
    ${param_value}          Set Variable    ${ALL_PARAMETERS_TO_CHANGE}[AsirWebEM][value]
    ${prev_val_of_parameter}=       local_resources.get_asirhub_parameter      dist_name=${dist_name}
    ...                             parameter=${parameter}

    local_resources.change_and_activate_asirhub_parameter       dn=${dist_name}         name=${parameter}
    ...                                                         value=${param_value}
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Delata_commisioning]
    local_resources.verify_asirhub_parameter        dist_name=${dist_name}      parameter=${parameter}
    ...                                             expected_value=${param_value}

    local_resources.change_and_activate_asirhub_parameter       dn=${dist_name}         name=${parameter}
    ...                                                         value=${prev_val_of_parameter}
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Delata_commisioning]
    local_resources.verify_asirhub_parameter        dist_name=${dist_name}      parameter=${parameter}
    ...                                             expected_value=${prev_val_of_parameter}

Reset Ants
    [Arguments]     ${ant_list}
    FOR     ${ant}      IN      ${ant_list}
        asir.Reset Antenna      ant_id=${ant}
        Wait Until Keyword Succeeds    300 sec    20 sec    asir.Verify Hubmod Status       hub_ids=${ant}
        ...                                                 expected_statuses=${statuses_after_reset_hub}
        Connect To BTS
        Connect To HUB
        Wait Until Keyword Succeeds    300 sec    20 sec    Verify Direct Connection For CLI Interface Via An LMT Interface
        SSHLibrary.Close Connection
        ${ru_id}=       local_resources.prepare Ru Id For Checking Ip      ${ant}
        Verify If Ip Assigned To SW0 InterFace On HUBs     ru_id=${ru_id}
        Get Power Consumption       ant_id=${ru_id}
    END
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells

Check Requirement For AsirAnt
    [Arguments]     ${messages_to_check}
#    ${snapshot_file}=   Set Variable    [path_to_snapshot]
    ${snapshot_file}=   gnblog.Collect Snapshot
    Sleep      5s
    ${path_to_unzip_snapshot}=        local_resources.unzip_snapshot     snapshot_file=${snapshot_file}
    ...                                    path_to_unzip=${OUTPUT_DIR}/snapshot
    ${snap_struct}=      local_resources.get_snapshot_file_orgnization       file_folder=${OUTPUT_DIR}/snapshot
    ${file_1_loc}=       local_resources.get_file_from_snapshot_by_key      snapshot_structure=${snap_struct}
    ...                  key_name=${messages_to_check}[first_file]
    logger.log_info_to_console      ${file_1_loc}
    ${file_1}=           local_resources.get_file_from_snapshot     snapshot_file=${path_to_unzip_snapshot}/${file_1_loc}
    ...                  path_to_unzip=${OUTPUT_DIR}/expected_files/        unzip_type=one_file
    ...                  file_regexp=${messages_to_check}[first_file]
    ...                  second_file_regexp=${messages_to_check}[first_file_inside]


    ${file_2_loc}=       local_resources.get_file_from_snapshot_by_key      snapshot_structure=${snap_struct}
    ...                  key_name=${messages_to_check}[second_file]
    ${file_2}=           local_resources.get_file_from_snapshot     snapshot_file=${path_to_unzip_snapshot}/${file_2_loc}
    ...                  path_to_unzip=${OUTPUT_DIR}/expected_files/       unzip_type=one_file
    ...                  file_regexp=${messages_to_check}[second_file]
    ...                  second_file_regexp=${messages_to_check}[second_file_inside]
    ${mess_1}=           local_resources.extract_message_from_file     file_path=${file_1}
    ...                  regexp=${messages_to_check}[first_regexp]
    logger.log_info_to_console      ${mess_1}
    ${mess_2}=           local_resources.extract_message_from_file     file_path=${file_2}
    ...                  regexp=${messages_to_check}[second_regexp]
    ${Time_diff}=        local_resources.Substract Time From Two Messages        message_1=${mess_2}
    ...                                        message_2=${mess_1}
    Should be True       ${Time_diff}<${messages_to_check}[time_diff]
    logger.log_info_to_console     Reset time for ASiANT: ${Time_diff}

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

Reset Hubs
    [Arguments]     ${hub_list}
    FOR     ${hub}      IN      ${hub_list}
        asir.Reset Hub      hub_id=${hub}       timeout=${300}
        Wait Until Keyword Succeeds    300 sec    20 sec    asir.Verify Hubmod Status       hub_ids=${hub}
        ...                                                 expected_statuses=${statuses_after_reset_hub}
        Connect To BTS
        Connect To HUB
        Wait Until Keyword Succeeds    300 sec    20 sec    Verify Direct Connection For CLI Interface Via An LMT Interface
        SSHLibrary.Close Connection
        ${ru_id}=       local_resources.prepare Ru Id For Checking Ip      ${hub}
        Wait Until Keyword Succeeds    300 sec    20 sec    Verify If Ip Assigned To SW0 InterFace On HUBs     ru_id=${ru_id}
        Wait Until Keyword Succeeds    300 sec    20 sec    Get Power Consumption       ant_id=${ru_id}
    END
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells

Check Requirement For AsirHub
     [Arguments]     ${messages_to_check}
#     ${snapshot_file}=   Set Variable    [path_to_snapshot]
     ${snapshot_file}=   gnblog.Collect Snapshot
     Sleep      5s
     ${path_to_unzip_snapshot}=        local_resources.unzip_snapshot     snapshot_file=${snapshot_file}
     ...                                    path_to_unzip=${OUTPUT_DIR}/snapshot
     ${snap_struct}=      local_resources.get_snapshot_file_orgnization       file_folder=${OUTPUT_DIR}/snapshot
     ${file_1_loc}=       local_resources.get_file_from_snapshot_by_key      snapshot_structure=${snap_struct}
     ...                  key_name=${messages_to_check}[first_file]
     ${file_1}=           local_resources.get_file_from_snapshot     snapshot_file=${path_to_unzip_snapshot}/${file_1_loc}
     ...                  path_to_unzip=${OUTPUT_DIR}/expected_files/       unzip_type=one_file
     ...                  file_regexp=${messages_to_check}[first_file]
     ...                  second_file_regexp=${messages_to_check}[first_file_inside]

     ${file_2_loc}=       local_resources.get_file_from_snapshot_by_key      snapshot_structure=${snap_struct}
     ...                  key_name=${messages_to_check}[second_file]
     ${file_2}=           local_resources.get_file_from_snapshot     snapshot_file=${path_to_unzip_snapshot}/${file_2_loc}
     ...                  path_to_unzip=${OUTPUT_DIR}/expected_files/       unzip_type=one_file
     ...                  file_regexp=${messages_to_check}[second_file]
     ${mess_1}=           local_resources.extract_message_from_file     file_path=${file_1}
     ...                  regexp=${messages_to_check}[first_regexp]
     ${mess_2}=           local_resources.extract_message_from_file     file_path=${file_2}
     ...                  regexp=${messages_to_check}[second_regexp]
     ${Time_diff}=        local_resources.Substract Time From Two Messages        message_1=${mess_2}
     ...                                        message_2=${mess_1}
     Should be True       ${Time_diff}<${messages_to_check}[time_diff]
     logger.log_info_to_console     Reset time for ASiHUB: ${Time_diff}

Reset BBMODs
    [Arguments]    ${bbmods}=null
    ${bbmods_list}    string.split string    ${bbmods}
    Run Keyword If    '${bbmods}' == 'null'    logger.log_info_to_console    Reset All BBMODS
    ...    ELSE    logger.log_info_to_console    Reset BBMODs in list @{bbmods_list}
    ${connection}=       admin.connect_to
    ${fbb_info}=    admin.Get fbb info      connection=${connection}
    FOR    ${fbb}    IN    @{fbb_info}
        ${prefix}    ${fbb_full_id} =    string.Split String From Right    ${fbb['id']['internal']}    separator=/
        ...                              max_split=${1}
        ${prefix}    ${fbb_id} =    string.Split String From Right    ${fbb_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${fbb_id}' in @{bbmods_list} or '${bbmods}' == 'null'    run keywords
        ...    logger.log_info_to_console    Reset BBMOD ${fbb_full_id}
        ...    AND    admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}
        ...                                connection=${connection}
    END

Turn Off Hub And Verify Tput
    [Arguments]     ${ru_id}=0      ${enb_index}=0
    Wait Until Keyword Succeeds     300 sec     30 sec   gnbcell.Verify Setup Of All Cells
    Prepare Ue for L3 Call      capabilities=${capabilities}        reboot_ue=False     timeout_reboot_ue=100
    Run Data Transfer With Attach And Detach
    FOR     ${operation}        IN      off     on
        Modify PoePower On Hub      ant_id=${ru_id}     action=${operation}
        Sleep       20s
        Run Keyword If      "${operation}"=="off"       asir.Verify Only Allowed Alarms Are Active
        ...                                             allowed_alarms=${ASIR_ALARMS}[PoePower]
        Get Power Consumption       action=${operation}
    END
    Wait Until Keyword Succeeds     320 sec     20 sec   gnbcell.Verify Setup Of All Cells
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]
    Run Data Transfer With Attach And Detach        run=2

Start Transfer On Real UE In Specific Direction
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}       ${run}=1
    ...             ${parallel_streams}=1    ${size_packet}=1320B   ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}
    ...             ${alias}=UE

    ${direction_upper}    Convert To Upper Case  ${direction}
    Start Data Transfer on Real UE   dt_name=DT_${run}_${direction_upper}      ue_alias=${alias}     direction=${direction}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput}     parallel_streams=${parallel_streams}
    ...     size_packet=${size_packet}      buffer_client=${buffer_server}  buffer_server=${buffer_server}
    ...     interval=${interval}      qci=${qci}    linux_congestion=${linux_congestion}

    Check Data Transfer is Alive     dt_name=DT_${run}_${direction_upper}
    Await Data Transfer Finish       dt_name=DT_${run}_${direction_upper}
    Verify Average Throughput With Deviation   dt_name=DT_${run}_${direction_upper}   tput=${tput}   deviation=${deviation}

Perform DL And UL Call
    Prepare Ue for L3 Call      capabilities=${capabilities}        reboot_ue=False     timeout_reboot_ue=100
    ue.Attach Ue    UE      timeout=200
    Start Transfer On Real UE In Specific Direction     direction=dl    duration=${duration}    tput=${tput}
    ...                                                 protocol=${protocol}    deviation=${deviation}
    Start Transfer On Real UE In Specific Direction     direction=ul    duration=${duration}    tput=${tput_ul}
    ...                                                 protocol=${protocol}    deviation=${deviation}
    sleep   2s
    ue.Detach Ue    UE

Run Data Transfer With Attach And Detach
    [Arguments]     ${direction}=dl     ${run}=1
    ue.Attach Ue    UE      timeout=200
    Run Keyword And Continue On Failure        Start Transfer On Real UE In Specific Direction   direction=dl
    ...                                        duration=${duration}    tput=${tput}
    ...                                        protocol=${protocol}     deviation=${deviation}      run=${run}
    sleep   2s
    ue.Detach Ue    UE

Attach Detach Verification
    [Arguments]     ${start}=0      ${end}=10       ${prepareUE}=True
    Run Keyword If      '${prepareUE}'=='True'      Prepare Ue for L3 Call      capabilities=${capabilities}
    ...                                             reboot_ue=False     timeout_reboot_ue=100
    FOR     ${run}      IN RANGE    ${start}       ${end}
        logger.log_info_to_console      Run num: ${run}/${end}
        Run Data Transfer With Attach And Detach    run=${run}
    END

Get Power Consumption
    [Arguments]     ${ant_id}=0     ${action}=on
    Connect To BTS
    Connect To HUB      ru_id=${ant_id}
    SSHLibrary.Write    ${commands}[Hub][power_consumptions]
    ${output}=     SSHLibrary.Read      delay=0.5s
    local_resources.compare_power_consumption    command_output=${output}    ant_id=${ant_id}       action=${action}
    SSHLibrary.Close Connection

Block Ants
    [Arguments]         ${ant_statuses}     ${str_ants_list}=null
    ${all_ants_mod_id_list}   asir.get_all_antenna_ids
    @{Cell_map}     cell_operations.get_all_cells_id
    logger.log_info_to_console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    logger.log_info_to_console  Block ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        logger.log_info_to_console  Block ANT ${ant_id}
        asir.block_antenna      ant_id=${ant_id}
        Sleep   5s
        @{ants_list}    create list
        Append To List    ${ants_list}    ${ant_id}
        Wait Until Keyword Succeeds      300 sec      30 sec      asir.verify_antmod_status       ant_ids=@{ants_list}
        ...                                                       expected_statuses=${ant_statuses_blocked}
    END
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Block_ants]

Unblock Ants
    [Arguments]         ${ant_statuses}     ${str_ants_list}=null
    ${all_ants_mod_id_list}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    logger.log_info_to_console  UnBlock ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        logger.log_info_to_console  Unblock ANT ${ant_id}
        asir.unblock_antenna      ant_id=${ant_id}
        Sleep   5s
    END
    Wait Until Keyword Succeeds      120 sec      20 sec      asir.verify_antmod_status       ant_ids=@{ants_list}
    ...                                                       expected_statuses=${ant_statuses_unblocked}
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]

Modify PoePower On Hub
    [Arguments]     ${ant_id}=0     ${action}=on
    Connect To BTS
    Connect To HUB
    Sleep       5s
    SSHLibrary.Write        poepower ${ant_id} ${action}
    SSHLibrary.Read Until       success
    SSHLibrary.Close Connection

Check If Log File For Hub Exists In Snapshot
    [Arguments]     ${ru_id}=0      ${gnb_index}=0
    ...             ${serial_num_for_first_ru}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].serial_number}
     ${snapshot_file}=   gnblog.Collect Snapshot
     Sleep      5s
     ${path_to_unzip_snapshot}=        local_resources.unzip_snapshot     snapshot_file=${snapshot_file}
     ...                                    path_to_unzip=${OUTPUT_DIR}/snapshot
     ${snap_struct}=      local_resources.get_snapshot_file_orgnization       file_folder=${OUTPUT_DIR}/snapshot
     local_resources.find_logs_in_snapshot      snap_struct=${snap_struct}      mandatory_logs=${snapshot_log_full}
     ...                    logs_prefix=BTS_${serial_num_for_first_ru}_RMOD_L_1_

Block Cell And Reset Site
    [Arguments]      ${Cell}
    Wait Until Keyword Succeeds      900 sec      30 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    ${cell_id}=      local_resources.get_ids_from_cell_list      cell=${Cell}
    cell_operations.Block Cell      cell_id=${cell_id}
    Sleep      5s
    cell_operations.Verify Cell Is Blocked      cell_id=${cell_id}
    gnb_alarm.Verify Alarm is Active on gNB     fault_name=Cell blocked
    Sleep      5s
    gnb_bbu.Reset gNB
    Wait Until Keyword Succeeds      900 sec      30 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    gnb_alarm.Verify Alarm is not Active on gNB      fault_name=Cell blocked

Verify Other Cell Are Actve On BTS
    [Arguments]     ${CellIDs}      ${blocked_cell}
    FOR     ${Cell}     IN      @{CellIDs}
        ${cell_id}=      local_resources.get_ids_from_cell_list      cell=${Cell}
        Run Keyword If    "${cell_id}" != "${blocked_cell}"    cell_operations.Verify Cell Is Onair    cell_id=${cell_id}
    END

Connect To BTS
    [Arguments]      ${gnb_index}=0
    SSHLibrary.Open Connection     host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    SSHLibrary.Login       username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}

Connect To HUB
    [Arguments]      ${gnb_index}=0      ${ru_id}=0
    ...              ${user}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.username}
    ...              ${password}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.password}
    ...              ${ru_ip}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.addr}
    SSHLibrary.Write               text=lxc-attach -n 0x2018
    SSHLibrary.Read Until          expected=root@FHNET00:~ >
    SSHLibrary.Write               text=ssh ${user}@${ru_ip}
    ${continue}=                   Run keyword and return status
    ...                            SSHLibrary.Read Until               expected=(yes/no/[fingerprint])?
    Run keyword if   ${continue}   SSHLibrary.Write                    text=yes
    ...              ELSE          SSHLibrary.Write                    text=wrong_password
    Sleep            time_=20s     reason=Waiting for password prompt...
    SSHLibrary.Read Until          expected=Password:
    SSHLibrary.Write               text=${password}
    SSHLibrary.Read Until          expected=#

Execute CLI Commands
    [Arguments]     ${Tests_list}
    Connect To BTS
    Connect To HUB
    FOR     ${test}     IN      @{Tests_list}
        logger.Log Info To Console      ${test}
        BuiltIn.Run Keyword And Continue On Failure     ${test}
    END
    SSHLibrary.Close Connection
    Sleep       120s
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells

Get and update rfsw cli services on ASIHUB
    SSHLibrary.Write    getServices
    SSHLibrary.Write    updateServices

Inspecting SW Version On ASiHub And Selecting Image For Next Boot
    SSHLibrary.Write        hub_version
    ${output}=     SSHLibrary.Read     delay=1s
    Should Contain      ${output}       ASiR sHUB software versions in the active partition
    ${hub_version}=        String.Get Line        ${output}    -3

Check connectivity to BBU from ASiHUB
    @{keys}=    Get Dictionary Keys    ${bbu_conn_answer_list}
    FOR       ${i}       IN       @{keys}
        SSHLibrary.Write    bbu_conn ${i}
        ${stdout}=      SSHLibrary.Read     delay=4s
        ${value} =    Get From Dictionary    ${bbu_conn_answer_list}    ${i}
        Loop over items  ${value}    ${stdout}
    END

Check CPU status of ASiHUB
    SSHLibrary.Write    cpu
    ${stdout}=      SSHLibrary.Read     delay=1s
    FOR       ${i}        IN       @{cpu_list}
        Should Contain      ${stdout}       ${i}
    END

Check Memory status of ASiHUB
    SSHLibrary.Write    mem
    ${stdout}=      SSHLibrary.Read     delay=1s
    FOR       ${i}        IN       @{mem_list}
        Should Contain      ${stdout}       ${i}
    END

Check ANT status
    SSHLibrary.Write        ant_status ${PORT}
    ${stdout}=      SSHLibrary.Read     delay=5s
    FOR       ${i}        IN       @{ant_status}
        Should Contain      ${stdout}       ${i}
    END

Check ASiHUB configuration
    SSHLibrary.Write        configuration
    ${stdout}=      SSHLibrary.Read     delay=8s
    FOR       ${i}        IN       @{asihub_configuration}
        Should Contain      ${stdout}       ${i}
    END

Loop over items
    [Arguments]  ${items}   ${stdout}
    @{items}=     Convert to list     ${items}
    FOR  ${item}  IN  @{items}
       Should contain     ${stdout}      ${item}
    END

Check ANT delay
    SSHLibrary.Write        ant_delay ${PORT}
    SSHLibrary.Read Until       delay =

Verify Direct Connection For CLI Interface Via An LMT Interface
    Sleep       5s
    SSHLibrary.Write        rfsw_cli
    SSHLibrary.Read Until       rfsw>

Viewing The Current List Of Faults And Alarms Pending At This ASiHub
    SSHLibrary.Write        fault_mnt
    ${fault}=     SSHLibrary.Read     delay=0.5s
    Should Contain      ${fault}       Active faults

Collection And Display Of SFP Received Power Via Fibber Connection
    SSHLibrary.Write        sfptool ${CPRIPORT}
    ${sfp_output}=     SSHLibrary.Read     delay=0.5s
    Should Contain      ${sfp_output}       SFP MEMORY INTERFACE DIAGNOSTICS:

Temporarily Power On And Power Off An ASiANT Port '${POWER}'
    SSHLibrary.Write        poe_switch ${ANTPORT} ${POWER}
    ${status}    ${value}=      Run Keyword And Ignore Error        SSHLibrary.Read Until       success
    Run Keyword If      '${status}'=='FAIL'      SSHLibrary.Write        ppe_power ${ANTPORT} ${POWER}
    Run Keyword If      '${status}'=='FAIL'      SSHLibrary.Read Until       success

Inspectnig SW Version On ASiHub And Selecting Image For Next Boot
    SSHLibrary.Write        hub_version
    ${output}=     SSHLibrary.Read     delay=0.5s
    Should Contain      ${output}       ASiR sHUB software versions in the active partition
    ${hub_version}=     String.Get Line        ${output}    2
    Set Test Variable    ${hub_version}

Display Of All The ASi ANTs Image Version On This ASI HUB
    SSHLibrary.Write        ant_version ${PORT}
    SSHLibrary.Read Until       Version =

Perform Power Cycle Of The ASiHUB
    SSHLibrary.Write            reboot power
    SSHLibrary.Read Until Regexp       Connection to ((?:[0-9]{1,3}\.){3}[0-9]{1,3}) closed

Verify If Ip Assigned To SW0 InterFace On HUBs
    [Arguments]      ${gnb_index}=0      ${ru_id}=0
    ...              ${user}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.username}
    ...              ${password}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.password}
    ...              ${ru_ip}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.addr}
    Connect To BTS
    Connect To HUB     ru_id=${ru_id}
    SSHLibrary.Write               text= ifconfig sw0| grep ether
    ${output}=      SSHLibrary.Read Until Regexp   ether ([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})
    logger.log_info_to_console      ${output}
    SSHLibrary.Close Connection

Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms


Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}
