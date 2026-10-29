*** Settings ***
Documentation
...   Regression test procedures for the feature CB007518
...   author: Julia Luszcz
...   contact: julia.luszcz@nokia.com

Library     taf/rfrl/bts/operations.py
Library     resources/resources.py

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./resources/keywords.robot
Resource    ./procedures/Manually_enabling_installation_of_predefined_RU_in_BTS.robot
Resource    ./procedures/Automatic_installation_of_predefined_RU_in_BTS_runtime.robot
Resource    ./procedures/Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime.robot
Resource    ./procedures/Changing_RU_to_non_predefined_when_the_RU_is_not_connected_in_BTS_runtime.robot
Resource    ./procedures/BTS_start-up_with_configured_predefined_RU_delta_commissioning.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables_TSN.py


Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Teardown     common_setups_and_teardowns.Common Postconditions With Watching Alarms


*** Variables ***
${ru_id}=           3
${cell_list}=       ${predefined_cells}
@{ru_power_off_allowed_alarms}              No connection to unit
...                                         Unit power reset

*** Test Cases ***
CB007518-A_TSN_BTS_start-up_with_configured_predefined_RU_full_commissioning
    [Setup]     TSN custom preconditions
    BTS_start-up_with_configured_predefined_RU_full_commissioning   ru_id=${ru_id}
    [Teardown]  Run keywords    Change RU to not predefined     AND
    ...                         Check not predefined statuses      AND
    ...                         common_setups_and_teardowns.Common Postconditions With Watching Alarms

CB007518-A_TSN_Manually_enabling_installation_of_predefined_RU_in_BTS
    [Setup]     TSN custom preconditions
    Manually_enabling_installation_of_predefined_RU_in_BTS

CB007518-A_TSN_Automatic_installation_of_predefined_RU_in_BTS_runtime
    [Setup]     TSN custom preconditions
    Automatic_installation_of_predefined_RU_in_BTS_runtime

CB007518-A_TSN_Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime
    [Setup]     TSN custom preconditions
    Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime
    [Teardown]  Run keywords    Change RU to not predefined     AND
    ...                         Check not predefined statuses      AND
    ...                         common_setups_and_teardowns.Common Postconditions With Watching Alarms

CB007518-A_TSN_Changing_RU_to_non-predefined_when_the_RU_is_not_connected_in_BTS_runtime
    [Setup]     TSN custom preconditions
    gnb_alarm.Allow Alarm                           ${ru_power_off_allowed_alarms}
    Changing_RU_to_non_predefined_when_the_RU_is_not_connected_in_BTS_runtime
    gnb_alarm.Disallow Alarm                        ${ru_power_off_allowed_alarms}

CB007518-A_TSN_BTS_start-up_with_configured_predefined_RU-delta_commissioning
    [Setup]     TSN custom preconditions
    gnb_alarm.Allow Alarm                           ${ru_power_off_allowed_alarms}
    BTS_start-up_with_configured_predefined_RU_delta_commissioning
    [Teardown]  Run keywords    Change RU to not predefined     AND
    ...                         Check not predefined statuses      AND
    ...                         gnb_alarm.Disallow Alarm                      ${ru_power_off_allowed_alarms}        AND
    ...                         common_setups_and_teardowns.Common Postconditions With Watching Alarms

*** Keywords ***
TSN custom preconditions
    Turn off automated activation
    common_setups_and_teardowns.Common Preconditions With Watching Alarms
