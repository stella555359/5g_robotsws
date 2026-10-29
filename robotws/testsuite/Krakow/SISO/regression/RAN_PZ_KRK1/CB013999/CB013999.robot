*** Settings ***
Documentation
...   Test suite for regression testing of feature CB013999
...   author: Marek Szłapa
...   contact: marek.szlapa@nokia.com

Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/CB013999_keywords.robot
Variables    ./resources/variables.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               increase_timeout_for_update_sw=${1800}
...               list_of_additional_allowed_alarms=${allowed_alarms_during_tl_prep}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms and cells set to Barred
Test Teardown     Common Postconditions With Watching Alarms and cells set to notBarred


*** Variables ***
${CUSTOM_ALLOWED_ALARMS}                [{'fault_id': 61675, 'fault_name': 'WiFi Configuration Issue'},
...                                      {'fault_id': 61673, 'fault_name': 'Wifi Enabled Alarm'}]
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}


*** Test Cases ***
CB013999_C_#4_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Timeout]    20h
    Perform SA L3 Call on all cells    deviation=10%
