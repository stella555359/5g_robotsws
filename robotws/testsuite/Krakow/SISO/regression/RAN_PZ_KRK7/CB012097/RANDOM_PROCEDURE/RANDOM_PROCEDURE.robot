*** Settings ***
Documentation
...   Test suite for executing random OAM operation in loop
...   author: Tomasz Krol
...   contact: tomasz.krol@nokia.com

Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ${L3_CALL_RESOURCE}
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


# Suite Setup       Common Suite Setup With OnAir Test Line Preparation
# ...                         increase_timeout_for_update_sw=${1800}
# ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}

# Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions     collect_syslog=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}


*** Variables ***
${TOTAL_TIMEOUT}                                ${14400}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${False}
# Sample of ${OPERATIONS}  ['site_reset', 'bts_power_on', 'reset_bbmod', 'reset_rmod', 'power_reset_rmod']
${OPERATIONS}           ['site_reset', 'reset_hub', 'rat_reset', 'reset_ant', 'cell_lock_unlock', 'cell_block_unblock']
# Sample of ${OPERATION_KWARGS}  {'site_reset': {'temp_allowed_alarms': [{'alarm_id': '7115', 'fault_id': '4590',
# 'fault_name': 'Sample fault name'}], 'calculate_kpi': true}, 'reset_rmod': {'calculate_kpi': false}}
${OPERATION_KWARGS}                                  ${None}
# ...   {'site_reset':
# ...   {'temp_allowed_alarms': [{'alarm_id': '7115', 'fault_id': '4590', 'fault_name': 'Sample fault name'}], 'calculate_kpi': False},
# ...   'reset_rmod': {'calculate_kpi': false}}
${RANDOM_SEED}                                  ${None}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${L3_CALL}                                      ${False}
${L3_CALL_RESOURCE}                             taf/rfrl/ue/robot/REAL_UE.robot
# Sample of ${L3_CALL_KEYWORDS}
# {"Prepare Ue for L3 Call": {"capabilities": "REAL_UE", "alias": "UE"}, "Verify L3 Call Data Transfer DL&UL":
# {"duration": "60s", "tput_dl": "100 Mbits/sec", "tput_ul": "100 Mbits/sec", "deviation": "99%", "alias": "UE"}
# "Stop Using Ue": ["UE"]}
${L3_CALL_KEYWORDS}                             ${None}



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
