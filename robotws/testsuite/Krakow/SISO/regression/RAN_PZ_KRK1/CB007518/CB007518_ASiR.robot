*** Settings ***
Documentation
...   Regression test procedures for the feature CB007518
...   author: Julia Luszcz
...   contact: julia.luszcz@nokia.com

Library     taf/rfrl/bts/operations.py
Library     resources/resources.py

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    ./resources/keywords.robot
Resource    ./procedures/Manually_enabling_installation_of_predefined_RU_in_BTS.robot
Resource    ./procedures/Manually_enabling_installation_of_predefined_RU_in_BTS_incompatible_radio.robot
Resource    ./procedures/Manually_enabling_installation_of_predefined_RU_in_BTS_ASIR_error_case.robot
Resource    ./procedures/Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime.robot
Resource    ./procedures/Changing_RU_to_non_predefined_when_the_RU_is_not_connected_in_BTS_runtime.robot
Resource    ./procedures/BTS_start-up_with_configured_predefined_RU_delta_commissioning.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   taf/rfrl/bts/alarms/classical_alarms_definition.py
Variables   ./resources/variables_ASiR.py


Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               prefix_tag=CB007518
...               increase_timeout_for_update_sw=${1800}
...               increase_time_for_checking_radios=${1800}

Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions With Watching Alarms
Test Teardown     common_setups_and_teardowns.Common Postconditions With Watching Alarms


*** Variables ***
${ru_id}=           3
${is_asir}=         True
${cell_list}=       ${predefined_cells}
@{ru_power_off_allowed_alarms}              No connection to unit
...                                         Unit power reset
...                                         Receiving failure in Optical Interface

@{CUSTOM_ALLOWED_ALARMS}    ${CLASSICAL_FAULT_2002}


*** Test Cases ***
CB007518-A_1_BTS_start-up_with_configured_predefined_RU_full_commissioning
    BTS_start-up_with_configured_predefined_RU_full_commissioning   is_asir=${is_asir}
    ...                                                             ru_id=${ru_id}
    ...                                                             radio_type=asirmod
    [Teardown]  Run keywords    Change RU to not predefined     is_asir=${is_asir}     AND
    ...                         Check not predefined statuses   ru_id=${ru_id}      is_asir=${is_asir}      AND
    ...                         common_setups_and_teardowns.Common Postconditions With Watching Alarms

CB007518-A_11_Manually_enabling_installation_of_predefined_RU_in_BTS
    Manually_enabling_installation_of_predefined_RU_in_BTS_ASIR      ${is_asir}

CB007518-A_13_Manually_enabling_installation_of_predefined_RU_in_BTS_incompatible_radio
    Manually_enabling_installation_of_predefined_RU_in_BTS_incompatible_radio     ${is_asir}

CB007518-A_12_Manually_enabling_installation_of_predefined_RU_in_BTS_ASIR_error_case
    Manually_enabling_installation_of_predefined_RU_in_BTS_ASIR_error_case     ${is_asir}
    [Teardown]  Run keywords    Change RU to not predefined     AND
    ...                         Check not predefined statuses   ru_id=${ru_id}      is_asir=${is_asir}      AND
    ...                         common_setups_and_teardowns.Common Postconditions With Watching Alarms

CB007518-A_17_Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime
    Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime_ASIR
    [Teardown]  Run keywords    Change RU to not predefined     is_asir=${is_asir}     AND
    ...                         Check not predefined statuses   ru_id=${ru_id}      is_asir=${is_asir}      AND
    ...                         common_setups_and_teardowns.Common Postconditions With Watching Alarms

CB007518-A_Changing_RU_to_non-predefined_when_the_RU_is_not_connected_in_BTS_runtime
    gnb_alarm.Allow Alarm                           ${ru_power_off_allowed_alarms}
    Changing_RU_to_non_predefined_when_the_RU_is_not_connected_in_BTS_runtime_ASIR
    gnb_alarm.Disallow Alarm                        ${ru_power_off_allowed_alarms}

CB007518-A_4_BTS_start-up_with_configured_predefined_RU_delta_commissioning
    gnb_alarm.Allow Alarm                           ${ru_power_off_allowed_alarms}
    BTS_start-up_with_configured_predefined_RU_delta_commissioning_ASIR
    [Teardown]  Run keywords    Change RU to not predefined     is_asir=${is_asir}     AND
    ...                         Check not predefined statuses   ru_id=${ru_id}      is_asir=${is_asir}      AND
    ...                         gnb_alarm.Disallow Alarm                      ${ru_power_off_allowed_alarms}        AND
    ...                         common_setups_and_teardowns.Common Postconditions With Watching Alarms
