*** Settings ***
Documentation
...   Keywords for regression testing of feature CB008376
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.logger.custom_logger                                   WITH NAME  logger
Library      taf.rfrl.bts.commissioning                                                WITH NAME  bts_comm
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                WITH NAME  alarm
Library      testsuite.Krakow.SISO.resources.sassim.SASSim     WITH NAME  sassim
Library      ./resources.py                                                            WITH NAME  local_resources
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_operations    WITH NAME    bts_oper
Library      BuiltIn

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/7_7_UTE5GCLOUDT4SK173/__init__.py
${deltas_dir}    /testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010969_B2/local_resources/deltas

*** Keywords ***
Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}

Start SASsim
    logger.log_info_to_console     Starting SASsim
    ${repo_path}=     taf.rfrl.utilities.test_config.Get Repository Path
    sassim.set_sas_sim_config
    ...     sas_sim_config=${repo_path}/testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010969_B2/local_resources/configs/SAS_Sim.conf
    sassim.prepare_sas_sim


Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    ${status}=       local_resources.check_sas_process_is_running
    Run Keyword If  '${status}'=='False'      Start SASsim
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    local_resources.upload_swconfig_to_bts
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Prepare test line
    logger.log_info_to_console     Performing full commisioning
    bts_comm.perform_full_commissioning_on_classical_gnb     awaiting_time=${1200}     readiness_timeout=${1200}
    ...                                                      update_timeout=${1200}     build_directory=/home/ute
    ...                                                      prefix_tag=SAS
    local_resources.upload_swconfig_to_bts
    Start SASsim
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    Common Suite Setup     check_truck_roll=${True}

Test line teardown
    Common Suite Teardown
    sassim.kill_sas_sim_server
    sassim.get_sas_sim_log

Perform RU lock unlock
    gnbru.Lock all radio unit
    gnbru.Verify all radio units statuses
    ...    administrative_state=Locked
    ...    operational_state=Enabled
    gnbcell.Verify all cells statuses
    ...    availability_status=dependency
    ...    operational_state=disabled
    gnbru.Unlock all radio unit
    gnbru.Wait for all radio units to be online
    Wait until keyword succeeds     360 sec     10 sec   gnbcell.Verify all cells are onAir
    Verify gNB is onAir

Load basic Commissioning change parameters and verify if CBRS cells are on Air
    [Arguments]    ${delta_file}
    logger.log_info_to_console     Performing full commissioning
    bts_comm.perform_full_commissioning_on_classical_gnb     awaiting_time=${1200}     readiness_timeout=${1200}
    ...                                                      update_timeout=${1200}     build_directory=/home/ute
    ...                                                      prefix_tag=SAS
    local_resources.upload_swconfig_to_bts
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    logger.log_info_to_console     Loading delta parameters
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/${delta_file}
    ...                                  bts_id=0    delta_purpose=Change values stored in ${delta_file} file
    Sleep    60s
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
