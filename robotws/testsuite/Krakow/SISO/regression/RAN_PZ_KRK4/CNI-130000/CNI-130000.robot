*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CRT test suite of feature CNI-130000

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/Trigger_stuck_or_broken_ACACIA_link_and_fault_1907_verification.robot
Resource    ../resources/robot/Trigger_5G_RF_Alarm.robot

Library     ../resources/python/RadioOperations.py   WITH NAME    radio_keywords

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/variables.py

Suite Setup     Run Keywords    common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...                                     increase_timeout_for_update_sw=${1800}
...                                     list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                                     swconfig_from_path=${SWCONFIG_PATH}   AND
...                             radio_keywords.set_multiple_rfsw_rad_flags    flags_dict=${RAD_FLAGS_RU_RECOVERY_RESET['disable']}
...                                                                           ru_id=${AWKUC_ID}    AND
...                             Trigger_5G_RF_Alarm.Power Reset RU And Wait For OnAir    ru_id=${AWKUC_ID}
Suite Teardown     Run Keywords    common_setups_and_teardowns.Common Suite Teardown    AND
...                                radio_keywords.set_multiple_rfsw_rad_flags  flags_dict=${RAD_FLAGS_RU_RECOVERY_RESET['enable']}
...                                                                            ru_id=${AWKUC_ID}    AND
...                                Trigger_5G_RF_Alarm.Power Reset RU And Wait For OnAir    ru_id=${AWKUC_ID}

Test Setup      common_setups_and_teardowns.Common Preconditions With Watching Alarms
Test Teardown   Run Keywords    common_setups_and_teardowns.Common Postconditions With Watching Alarms    AND
...                             Run Keyword If Test Failed    common_setups_and_teardowns.Restore gNB Configuration After Test

*** Variables ***
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${SWCONFIG_PATH}                                commissionings/Krakow/swconfig/default_swconfig.txt

*** Test Cases ***
CNI-130000_#4_Trigger_A5G067_and_verification_of_RU_and_BTS_fault
    Trigger_5G_RF_Alarm_and_verification_of_RU_and_BTS_fault    rf_alarm_data=${RF_ALARM_TRIGGER_DATA['A5G067']}
    ...                                                         ru_id=${AWKUC_ID}

CNI-130000_#5_Trigger_A5G160_and_verification_of_RU_and_BTS_fault
    Trigger_5G_RF_Alarm_and_verification_of_RU_and_BTS_fault    rf_alarm_data=${RF_ALARM_TRIGGER_DATA['A5G160']}
    ...                                                         ru_id=${AWKUC_ID}

CNI-130000_#7_Trigger_A5G163_and_verification_of_RU_and_BTS_fault
    Trigger_5G_RF_Alarm_and_verification_of_RU_and_BTS_fault    rf_alarm_data=${RF_ALARM_TRIGGER_DATA['A5G163']}
    ...                                                         ru_id=${AWKUC_ID}

CNI-130000_#8_Trigger_A5G164_and_verification_of_RU_and_BTS_fault
    Trigger_5G_RF_Alarm_and_verification_of_RU_and_BTS_fault    rf_alarm_data=${RF_ALARM_TRIGGER_DATA['A5G164']}
    ...                                                         timeout_trigger_raw_fault=${90}
    ...                                                         ru_id=${AWKUC_ID}
CNI-130000_#2_Trigger_stuck_or_broken_ACACIA_link_and_fault_1907_verification
    [Setup]   Run Keywords
    ...       Common Preconditions With Watching Alarms    AND
    ...       radio_keywords.set_multiple_rfsw_rad_flags  flags_dict=${RAD_FLAGS_RU_RECOVERY_RESET['enable']}
    ...                                                   ru_id=${AWKUC_ID}    AND
    ...       Trigger_5G_RF_Alarm.Power Reset RU And Wait For OnAir    ru_id=${AWKUC_ID}
    Trigger_stuck_or_broken_ACACIA_link_and_fault_1907_verification    ru_id=${AWKUC_ID}
