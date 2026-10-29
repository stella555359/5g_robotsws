*** Settings ***
Documentation
...   Regression test suite for the feature CB008772
...   author: Aleksandra Faliszek
...   contact: aleksandra.faliszek@nokia.com

Library             testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 prefix_tag=CB008772
Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
${TOTAL_TIMEOUT}                            ${28800}
${EMAIL_NOTIFICATION_WHEN_FAIL}             ${False}
${OPERATIONS}                               ['site_reset', 'bts_power_on', 'reset_rmod', 'power_reset_rmod', 'cell_block_unblock', 'cell_lock_unlock']
${L3_CALL}                                  ${False}

*** Test Cases ***
CB008772-SR-A-Random_OAM_Operations_ASOE_3CC
    [Timeout]    10h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             l3_call=${L3_CALL}
