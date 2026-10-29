*** Settings ***
Documentation
...   Test suite for CB012261 CIT executing random OAM operation in loop
...   author: Aleksandra Faliszek
...   contact: aleksandra.faliszek@nokia.com

Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ${L3_CALL_RESOURCE}
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...                         increase_timeout_for_update_sw=${1800}
...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}

Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions     collect_syslog=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}


*** Variables ***
${TOTAL_TIMEOUT}                                ${7200}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${True}
${OPERATIONS}   ['site_reset', 'bts_power_on', 'reset_bbmod', 'reset_rmod', 'power_reset_rmod', 'cell_block_unblock', 'cell_lock_unlock', 'rat_reset']
${OPERATION_KWARGS}                             ${None}
${RANDOM_SEED}                                  ${None}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${logs_path}                                    ${OUTPUTDIR}
${L3_CALL}                                      ${False}
${L3_CALL_RESOURCE}                             taf/rfrl/ue/robot/REAL_UE.robot
${L3_CALL_KEYWORDS}                             ${None}
${SWCONFIG_PATH}                                ${None}
${COLLECT_LOGS_DURING_DATA_TRANSFER}            ${False}
${ENABLE_RACH_OBSERVER}                         ${False}

*** Test Cases ***
CB012261_SR_Random_OAM_procedures
    [Timeout]    5h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
