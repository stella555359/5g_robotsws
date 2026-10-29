*** Settings ***
Documentation
...   Test suite for executing random OAM operation in loop
...   author: Piotr Brzezicki, piotr.brzezicki@nokia.com
...   maintainer: Piotr Brzezicki, piotr.brzezicki@nokia.com

Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/l3_call_variables.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ${L3_CALL_RESOURCE}

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...                         increase_timeout_for_update_sw=${1800}
...                         swconfig_from_path=commissionings/Krakow/7_7_T08SK042/CB012453_swconfig.txt
...                         list_of_additional_allowed_alarms=${CB012455_CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                         should_LTE_neighbour_be_changed=${True}
...                         check_truck_roll=${False}
...                         prefix_tag=25R3_N_CB012455_1a

Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions     collect_syslog=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}

*** Variables ***
${TOTAL_TIMEOUT}                                ${10800}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${False}
${OPERATIONS}                ['site_reset', 'cell_block_unblock', 'reset_rmod', 'cell_lock_unlock', 'rat_reset']
${OPERATION_KWARGS}                             ${None}
${RANDOM_SEED}                                  ${None}
@{CB012455_CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7107  61673
# 7107 Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
# 61673 Wifi Enabled Alarm in un-commissioned state

*** Test Cases ***
CB012455_Random_OAM_Operations
    [Timeout]    96h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
