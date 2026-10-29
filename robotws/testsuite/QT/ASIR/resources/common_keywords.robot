*** Settings ***
Library      String
Library      SSHLibrary
Library      taf.sbts.oam.coam.admin                                                    WITH NAME    admin
Library      taf.rfrl.utilities.logger.custom_logger                                    WITH NAME    logger
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations             WITH NAME    asir
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                      WITH NAME    du_operations
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                 WITH NAME    alarm
Library      ./resources.py                                                             WITH NAME    local_resources
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


*** Keywords ***
Run Command On Ue Pc
    [Arguments]     ${command}     ${sudo}=${True}     ${sleep_time}=60s
    ${ue_pc_address}=      local_resources.find_nested_key      data=${ue_info}       target_key=ue_pc_address
    ${ue_pc_login}=        local_resources.find_nested_key      data=${ue_info}       target_key=ue_pc_login
    ${ue_pc_password}=     local_resources.find_nested_key      data=${ue_info}       target_key=ue_pc_password
    SSHLibrary.Open Connection      host=${ue_pc_address}          timeout=300 sec
    Wait Until Keyword Succeeds     300 sec     5 sec
    ...     SSHLibrary.Login                username=${ue_pc_login}     password=${ue_pc_password}
    ${output}=      SSHLibrary.Execute Command      ${command}      output=${True}      sudo=${sudo}
    ...                                             sudo_password=${ue_pc_password}     timeout=${60}
    logger.log_info_to_console      Output: ${output}
    BuiltIn.Sleep     ${sleep_time}

Start Ue Proxy On Ue PC
    Run Command On Ue Pc     command=/mnt/c/Windows/System32/net.exe start "UE PROXY RUNNER"

Stop Ue Proxy On Ue PC
    Run Command On Ue Pc     command=/mnt/c/Windows/System32/net.exe stop "UE PROXY RUNNER"     sleep_time=5s

Configuration Reset On ASIR
    [Arguments]     ${file_name}=initial_configuration.xml
    ...             ${file_path}=/tmp      ${asir_file_name}=initial_configuration_asir.xml
    Save Current gNB Configuration
    logger.log_info_to_console      Download gNB Configuration File
    gnb_bbu.Download gNB Configuration File     local_dir=${file_path}     filename=${file_name}
    logger.log_info_to_console      Download ASIR Configuration File
    ${asir_path}=       asir.Get Current Scf File     local_dir_path=${file_path}     file_name=${asir_file_name}
    logger.log_info_to_console      ASIR config reset
    asir.Reset Configuration
    logger.log_info_to_console      Checking If Config reset is done
    Wait Until Keyword Succeeds     900 sec     30 sec   gnb_alarm.Verify Alarm is Active on gNB
    ...                             fault_name=Antennas assignment not available
    logger.log_info_to_console      Performing Asir Commisioning
    Wait Until Keyword Succeeds     960 sec     120 sec      asir.Perform Asir Commissioning     scf_path=${asir_path}
    BuiltIn.Sleep     120s
    logger.log_info_to_console      Wait For Setup of All Cells
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    logger.log_info_to_console      Performing gNB Commisioning
    Perform Full Commissioning on gNB     scf_file=${file_path}/${file_name}
    logger.log_info_to_console      Wait For Setup of All Cells
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    asir.Verify Only Allowed Alarms Are Active     allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]

Reset BBMODs
    [Arguments]     ${bbmod_id}=1
    logger.log_info_to_console      Reseting BBMOD-${bbmod_id}
    du_operations.reset_bbmod       bbmod_id=${bbmod_id}
    BuiltIn.Sleep     10s
    logger.log_info_to_console      Wait For gNB is onAir
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify gNB is onAir
    logger.log_info_to_console      Wait For Setup of All Cells
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells

gNB Reset
    logger.log_info_to_console      Reseting gNB
    Reset gNB
    BuiltIn.Sleep     10s
    logger.log_info_to_console      Wait For gNB is onAir
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify gNB is onAir
    logger.log_info_to_console      Wait For Setup of All Cells
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells

SW UPGRADE
    ${path_to_sw_build}=        Generate Path To Build     ${build}
    logger.log_info_to_console      Path To SW Build: ${path_to_sw_build}
    Update gNB software     sw_package_dir=${path_to_sw_build}      timeout=3600
    BuiltIn.Sleep     120s
    logger.log_info_to_console      Wait For gNB is onAir
    Wait Until Keyword Succeeds     1200 sec     30 sec   Verify gNB is onAir
    logger.log_info_to_console      Wait For Setup of All Cells
    Wait Until Keyword Succeeds     1200 sec     30 sec   Verify Setup of All Cells
    ${sw_version}=      Get gNB Sw Version
    logger.log_info_to_console      Actual SW Version: ${sw_version}
    ${result}=      local_resources.compare_sw_version      ${sw_version}       ${build}
    logger.log_info_to_console      Is correct SW version (should be True)? ${result}
    Should Be True      ${result}       ${True}

Generate Path To Build
    [Arguments]     ${build_name}
    [Return]        /media/builds/${build_name}/${build_name}_release_BTSSM_downloadable_A54.zip

Start Transfer On Real UE In Specific Direction QC
    [Arguments]     ${duration}    ${tput}    ${deviation}      ${direction}=dl       ${protocol}=udp
    ...             ${parallel_streams}=1    ${size_packet}=${None}    ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}
    ...             ${alias}=UE

    ${direction_upper}    Convert To Upper Case  ${direction}
    Start Data Transfer on Real UE   dt_name=DT_${alias}_${direction_upper}      ue_alias=${alias}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput}     parallel_streams=${parallel_streams}
    ...     size_packet=${size_packet}      buffer_client=${buffer_server}  buffer_server=${buffer_server}
    ...     interval=${interval}      qci=${qci}    linux_congestion=${linux_congestion}    direction=${direction}

    Await Data Transfer Finish       dt_name=DT_${alias}_${direction_upper}
    Verify Average Throughput With Deviation   dt_name=DT_${alias}_${direction_upper}   tput=${tput}
    ...                                        deviation=${deviation}

L3 Call
    [Arguments]     ${direction}        ${tput}     ${deviation}    ${cap}=${capabilities}     ${ue_alias}=UE
    ...             ${prepareUE}=True
    Run Keyword If      '${prepareUE}'=='True'      ue.Require Ue       ${ue_alias}      capabilities=${cap}
    logger.log_info_to_console      Attach UE
    ue.Attach Ue    ${ue_alias}
    BuiltIn.Sleep     5s
    logger.log_info to console      Start transfer in direction: ${direction}
    Run Keyword and continue on failure     Start Transfer On Real UE In Specific Direction QC     direction=${direction}
    ...                                     duration=${duration}        tput=${tput}
    ...                                     deviation=${deviation}      alias=${ue_alias}
    BuiltIn.Sleep     5s
    [Teardown]      ue.Detach Ue    ${ue_alias}

Set additional alarms
    [Arguments]    ${alarms_for_test}
    ${list_of_alarms_for_test}=     local_resources.prepare_additional_alarms_for_test     test_type=${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${list_of_alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Run Keywords     Common Postconditions With Watching Alarms      AND
    ...           Run Keyword If Test Failed     local_resources.send_mail

Get branch name
    ${branch_name}=     local_resources.get_branch_name
    [Return]     ${branch_name}

Prepare Test Line
    [Arguments]     ${file_path}=/home/ute/qt_configs/branches       ${file_name}=GNB0_SCF.xml
    ...             ${asir_file}=GNB0_ASIR_SCF.xml
    ${jenkins_node}     Set Variable     ${TLs_data}[${TL_Name}][Jenkins_node]
    ${branch_name}=      Get branch name
    logger.log_info_to_console      Perform Full Commissioning on gNB
    Perform Full Commissioning on gNB     scf_file=${file_path}/${branch_name}/${jenkins_node}/${file_name}
    BuiltIn.Sleep       180s
    logger.log_info_to_console      Perform Full Commissioning on ASIR
    asir.perform_asir_commissioning     scf_path=${file_path}/${branch_name}/${jenkins_node}/${asir_file}
    Wait Until Keyword Succeeds     1200 sec     30 sec   Verify Setup of All Cells

Verify Test Line Status
    [Arguments]     ${action}
    ${on_air_status}=     Run Keyword And Return Status        Verify Setup of All Cells
    Run Keyword If      '${on_air_status}'=="${False}"     local_resources.send_mail     test_case=${action}

QT Suite Setup
    local_resources.upload_swconfig_to_bts
    ${is_needed}=      Run Keyword And Return Status        Verify Setup of All Cells
    Run Keyword If      '${is_needed}'=="${False}"     Prepare Test Line
    Common Suite Setup     check_truck_roll=${True}
    [Teardown]     Verify Test Line Status     action=Suite Setup

QT Suite Teardown
    Recovery Actions
    Common Suite Teardown
    [Teardown]     Verify Test Line Status     action=Suite Teardown

Recovery Actions
    ${is_on_air}=       Run Keyword And Return Status        Verify Setup of All Cells
    Run Keyword If      '${is_on_air}'=="${False}"      Reset gNB
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    ${second_try_is_on_air}=       Run Keyword And Return Status        Verify Setup of All Cells
    Run Keyword If      '${second_try_is_on_air}'=="${False}"      Reset gNB
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells

Change qrxlevmin parameter
     [Arguments]     ${value}
     local_resources.change_qrxlevmin_parameter     cell=${TLs_data}[${TL_Name}][Cell_for_call]     value=${value}
