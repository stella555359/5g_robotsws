*** Settings ***
Documentation
...   author: Bartlomiej Swoboda and Hubert Grobelny
...   contact: bartlomiej.swoboda@nokia.com
...   maintainer:    bartlomiej.swoboda@nokia.com
...   Description:   This feature describes and verify graceful shutdown procedure according to 5GC000501 feauture

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   5G_RAN   5G_RAN_TDD
...           RAN_5G    RAN_5G_TDD   PY36
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIB_ABIO_3xAZQO_ENB


Resource         ./resources/keywords_501_TDD.robot
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py  WITH NAME  bts_log

Suite Setup       prepare_testline

Suite Teardown    Run Keywords
...               AdminUtils.get_active_alarms   AND
...               sleep_well_tl

Test Setup        bts_log.start_btslog_on_local_machine

Test Teardown     Run Keywords
...               bts_log.stop_and_collect_btslog                     AND
...               Run keyword if test failed    AdminUtils.collect_snapshot


*** Test Cases ***
5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns validation and handling
    ...              of invalid values for parameters.
    ...              This test covers following operations realated to the Gracefull cell shutdown feature like:
    ...              1) Check if test fail for out of range parameters values
    ...              2) Check if feauture activation fail becouse of invalid parameters
    [Tags]   CRT
    [1][1.0] 5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling


5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns operator's parameters check.
    ...              This test covers following operations realated to the Gracefull cell shutdown feature like:
    ...              Check operator's parameters after graceful cell shutdown
    [Tags]   CRT
    [1][1.0] 5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check
