*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB012685
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB012685/CB012685_resources.robot
Variables   variables.py

Suite Setup       Common suite setup with onAir Test Line preparation
...               swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT11SK100/default_swconfig.txt
...               list_of_additional_allowed_alarms=${additional_allowed_alarms}
Suite Teardown    Common suite teardown
Test Setup        CB012685 Common test setup
Test Teardown     Common postconditions with watching alarms

*** Variables ***
${UE}                                     QC
${COLLECT_LOGS_DURING_DATA_TRANSFER}      ${False}
${ENABLE_RACH_OBSERVER}                   ${False}
@{RU_LIST}                                0    1    2

${TOTAL_TIMEOUT}                          ${18000}
${EMAIL_NOTIFICATION_WHEN_FAIL}           ${True}
${L3_CALL}                                ${False}

*** Test Cases ***
[1][1.0] CB012685_B_C2_Manual_Recommission_to_use_SFP_50G_with_at_least_one_RU_RF7.1
    Perform L3 call on all cells    cells_for_l3_call=&{cells_tput_C2}

[1][1.0] CB012685_B_C2_General_SiSo_RU_lock_unlock
    Perform RU lock unlock
    Perform L3 call on all cells    cells_for_l3_call=&{cells_tput_C2}

[1][1.0] CB012685_B_C2_Manual_SiSo_SM_NR_RAT_reset
    Permorm NR RAT reset
    Perform L3 call on all cells    cells_for_l3_call=&{cells_tput_C2}

[1][1.0] CB012685_B_C2_General_SiSo_RF_module_power_reset
    Perform RU power reset of selected units    @{RU_LIST}
    Perform L3 call on all cells    cells_for_l3_call=&{cells_tput_C2}

[1][1.0] CB012685_B_C2_Random_OAM_Operations
    [Setup]    Common preconditions    collect_syslog=${False}
    [Timeout]    96h
    Run random OAM operations
    ...    timeout=${TOTAL_TIMEOUT}
    ...    email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...    l3_call=${L3_CALL}
    [Teardown]    Common postconditions    collect_syslog=${False}
