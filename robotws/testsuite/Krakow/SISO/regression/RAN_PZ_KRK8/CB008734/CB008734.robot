*** Settings ***
Documentation
...   Test Suite for testing CB008734 feature
...   author: Aleksander Gospodarczyk
...   contact: aleksander.gospodarczyk@nokia.com
...   rev.1  removed SISO testcases, added RANDOM OAM OPERATIONS



Resource    ./resources/CB008734_keywords.robot
Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ${L3_CALL_RESOURCE}
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py



Suite Setup          Test Suite Setup
Suite Teardown       Common Suite Teardown
Test Setup           Custom Test Setup
Test Teardown        Custom Test Teardown



*** Variables ***
${TOTAL_TIMEOUT}                                ${1800}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${False}
${OPERATIONS} =                                 ['reset_bbmod','reset_rmod', 'site_reset']
${OPERATION_KWARGS}                             {'calculate_kpi': False}
${RANDOM_SEED}                                  ${None}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ToP reference missing
${L3_CALL}                                      ${False}
${L3_CALL_RESOURCE}                             taf/rfrl/ue/robot/REAL_UE.robot
${L3_CALL_KEYWORDS}                             ${None}
${SWCONFIG_PATH}                                ${None}



*** Test Cases ***
Random OAM Operations
    [Timeout]    96h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
    L3 call DL UL
