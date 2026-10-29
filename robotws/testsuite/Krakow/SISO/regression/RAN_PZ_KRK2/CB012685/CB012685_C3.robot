*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB012685
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Variables   variables.py
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB012685/CB012685_resources.robot

Suite Setup       Common suite setup with onAir Test Line preparation
...               swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT11SK100/default_swconfig.txt
...               list_of_additional_allowed_alarms=${additional_allowed_alarms}
...               prefix_tag=CB012685_C3
Suite Teardown    Common suite teardown

*** Variables ***
${UE}                                     QC
${COLLECT_LOGS_DURING_DATA_TRANSFER}      ${False}
${ENABLE_RACH_OBSERVER}                   ${False}

${TOTAL_TIMEOUT}                          ${18000}
${EMAIL_NOTIFICATION_WHEN_FAIL}           ${True}
${L3_CALL}                                ${False}

*** Test Cases ***
[1][3.0] CB012685_B_C3_General_SiSo_Cell_block_and_unblock
    [Setup]    CB012685 Common test setup
    Perform all cells block unblock
    Perform L3 call on all cells    cells_for_l3_call=&{cells_tput_C3}
    [Teardown]    Common postconditions with watching alarms

[1][1.0] CB012685_B_C3_Random_OAM_Operations
    [Setup]    Common preconditions    collect_syslog=${False}
    [Timeout]    96h
    Run random OAM operations
    ...    timeout=${TOTAL_TIMEOUT}
    ...    email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...    l3_call=${L3_CALL}
    [Teardown]    Common postconditions    collect_syslog=${False}
