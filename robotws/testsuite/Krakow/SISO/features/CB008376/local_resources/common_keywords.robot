*** Settings ***
Documentation
...   Keywords for regression testing of feature CB008376
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      OperatingSystem
Library      SSHLibrary
Library      taf.sbts.oam.coam.admin                                                   WITH NAME  admin
Library      taf.selenium.sbts                                                         WITH NAME  selenium
Library      taf.selenium.gnb.oam.coam.classical                                       WITH NAME  selenium_coam
Library      taf.transport.ssh                                                         WITH NAME  ssh
Library      taf.hw.pdu                                                                WITH NAME  pdu
Library      taf.rfrl.utilities.logger.custom_logger                                   WITH NAME  logger
Library      taf.rfrl.utilities.test_config.DefaultFileLocation                        WITH NAME  def_file_location
Library      taf.rfrl.bts.commissioning                                                WITH NAME  bts_comm
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                    WITH NAME  comm
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                     WITH NAME  gnb_du
Library      taf.rfrl.bts.devices.du.cell_operations                                   WITH NAME  cell_operations
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                     WITH NAME  du_operations
Library      taf.rfrl.bts.devices.du.sw_update.GnbSwUpdate                             WITH NAME  gnb_sw_update
Library      taf.rfrl.procedures.resources.python.config_operations.ConfigOperations   WITH NAME  config_operations
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                WITH NAME  alarm
Library      ./resources.py                                                            WITH NAME  local_resources
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/7_7_UTE5GCLOUDT9SK023/__init__.py

*** Keywords ***
Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}

Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    local_resources.upload_swconfig_to_bts    bts_id=${1}
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms       alarms_for_test=${alarms_for_test}
    Add Custom Allowed Alarms If Defined
    gnb_alarm.Start watching alarms    allowed_alarms=${allowed_alarms}    gnb_id=${1}
    gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm    gnb_id=${1}
    gnb_log.Start Collecting gNB Btslog    gnb_id=${1}
    Common Preconditions

Actions after test
    Remove custom allowed alarms if defined
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    gnb_log.Collect Snapshot From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    gnb_log.Collect IM Snapshot From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    gnb_log.Collect IMS Log From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    gnb_log.Stop Collecting gNB Btslog    gnb_id=${1}    log_dir=${LOG_PATH}
    [Teardown]    Common Postconditions

Prepare test line
    logger.log_info_to_console     Performing full commisioning
    bts_comm.perform_full_commissioning_on_classical_gnb     awaiting_time=${1200}     readiness_timeout=${1200}
    ...                                                      update_timeout=${1200}     build_directory=/home/ute
    local_resources.upload_swconfig_to_bts
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    Common Suite Setup     check_truck_roll=${True}

Test line teardown
    Common Suite Teardown

Remove Dirs
    [Arguments]    ${directory_paths}
    FOR    ${dir}    IN    @{directory_paths}
        ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Load configuration
    [Arguments]     ${bts_id}=${0}    ${build_directory}=/home/ute/temp_builds    ${prefix_tag}=EDA_03993542
    logger.log_info_to_console    Load configuration after config reset started
    BuiltIn.Sleep    300s
    gnb_du.Wait Unitl Connection Via Admin Is Possible    bts_id=${bts_id}    timeout=${600}
    ${branch}=    Get gNB Sw Release Name    gnb_id=${bts_id}
    ${scf_dir}=    def_file_location.get_commissioning_dir    branch=${branch}
    ${bts_scf_name}=    def_file_location.get_default_scf_name    bts_id=${bts_id}     prefix_tag=${prefix_tag}
    logger.log_info_to_console    scf_dir=${scf_dir}
    bts_comm.perform_full_commissioning_on_classical_gnb    bts_id=${bts_id}     scf_path=${scf_dir}/${bts_scf_name}
    ...                                                     awaiting_time=${1200}
    ...                                                     readiness_timeout=${1200}    update_timeout=${1200}
    ...                                                     build_directory=${build_directory}
    ${asir_scf_name}=    def_file_location.get_default_scf_name    bts_id=${bts_id}     prefix_tag=${prefix_tag}
    ...                                                            sub_device=ASIR
    bts_comm.perform_full_commissioning_on_gnb_asir_hub    bts_id=${bts_id}     scf_path=${scf_dir}/${asir_scf_name}
    BuiltIn.Sleep    30s
    bts_comm.wait_for_onair_on_all_dus    bts_id=${bts_id}

    local_resources.upload_swconfig_to_bts    bts_id=${bts_id}
    BuiltIn.Sleep    10s
    Reset gNB    gnb_id=${bts_id}
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair    bts_id=${bts_id}
    logger.log_info_to_console    Load configuration finished

Get source sw version for upgrade
    [Arguments]    ${n}    ${build_version}=${None}
    ${source_build}=        local_resources.Get SW Version From WFT Upgrade Path    n=${n}
    ...                                                                             build_version=${build_version}
    logger.log_info_to_console    Source SW version for upgrade path ${n}: ${source_build}
    [Return]    ${source_build}

Wait for sw update possible
    [Arguments]    ${bts_id}=${0}
    logger.log_info_to_console    Wait SW update is possible    log_hierarchy=4
    gnb_sw_update.wait_sw_update_possible    readiness_timeout=${900}    bts_id=${bts_id}
