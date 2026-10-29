*** Settings ***
Documentation
...   Test suite for executing random OAM operation in loop
...   author: Patryk Wojcik
...   contact: patryk.wojcik@nokia.com

Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ${L3_CALL_RESOURCE}
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...                         increase_timeout_for_update_sw=${1800}
...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                         swconfig_from_path=${SWCONFIG_PATH}

Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions     collect_syslog=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}


*** Variables ***
${TOTAL_TIMEOUT}                                ${3600}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${True}
${OPERATIONS}                                   ${None}
${OPERATION_KWARGS}                             ${None}
${RANDOM_SEED}                                  ${None}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  61673
${L3_CALL}                                      ${False}
${L3_CALL_RESOURCE}                             taf/rfrl/ue/robot/REAL_UE.robot
${L3_CALL_KEYWORDS}                             ${None}
${SWCONFIG_PATH}                                ${None}
${COLLECT_LOGS_DURING_DATA_TRANSFER}            ${False}
${ENABLE_RACH_OBSERVER}                         ${False}

*** Test Cases ***
CB012608-SR-B_Robustness_Random_OAM_procedures
    [Timeout]    96h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
