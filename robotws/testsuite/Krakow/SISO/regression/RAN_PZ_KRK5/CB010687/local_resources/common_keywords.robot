*** Settings ***
Documentation
...   Keywords for regression testing of feature CB008376
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.logger.custom_logger                                   WITH NAME  logger
Library      taf.rfrl.bts.commissioning                                                WITH NAME  bts_comm
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                WITH NAME  alarm
Library      ./resources.py                                                            WITH NAME  local_resources
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_operations      WITH NAME    bts_oper
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_pm_counters.bts_pm_counters
...                                                                                            WITH NAME    pm_verifier
Library      BuiltIn
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/bts/robot/common/gnb_counter.robot

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/7_7_UTE5GCLOUDT4SK173/__init__.py
${deltas_dir}    /testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010687/local_resources/deltas

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
    local_resources.upload_swconfig_to_bts
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Prepare test line
    logger.log_info_to_console     Performing full commisioning
    bts_comm.perform_full_commissioning_on_classical_gnb     awaiting_time=${1200}     readiness_timeout=${1200}
    ...                                                      update_timeout=${1200}     build_directory=/home/ute
    local_resources.upload_swconfig_to_bts
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    Common Suite Setup     check_truck_roll=${True}

Test line teardown
    Common Suite Teardown

Recommission
    [Arguments]    ${prefix_tag}=null
    logger.log_info_to_console    Loading new config to BTS
    local_resources.perform_bts_recommissioning    prefix_tag=${prefix_tag}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir

Load basic commissioning change parameters and verify cells are on air
    [Arguments]    ${delta_file}
    logger.log_info_to_console     Loading delta parameters
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/${delta_file}
    ...                                  bts_id=0    delta_purpose=Change values stored in ${delta_file} file
    Sleep    60s
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
