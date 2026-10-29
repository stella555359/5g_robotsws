*** Settings ***
Documentation
...   Test suite for executing random OAM operation in loop
...   author:     Jakub Matuszczyk
...   contact:    jakub.matuszczyk@nokia.com
...   maintainer: jakub.matuszczyk@nokia.com

Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions     collect_syslog=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}


*** Variables ***
${TOTAL_TIMEOUT}                                ${3600}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${False}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${False}

${OPERATION_KWARGS}  {'site_reset':{'temp_allowed_alarms':[{'alarm_id':'7107','fault_id':'7114'}]},
...                   'bts_power_on':{'temp_allowed_alarms':[{'alarm_id':'7107','fault_id':'7300'},
...                                                          {'alarm_id':'7107','fault_id':'7319'},
...                                                          {'alarm_id':'7115','fault_id':'4592'},
...                                                          {'alarm_id':'7115','fault_id':'4590'}]},
...                   'reset_bbmod':{'temp_allowed_alarms':[{'alarm_id':'7107','fault_id':'7300'},
...                                                         {'alarm_id':'7107','fault_id':'7319'},
...                                                         {'alarm_id':'7107','fault_id':'6327'}]},
...                   'power_reset_rmod':{'temp_allowed_alarms':[{'alarm_id':'7107','fault_id':'7114'},
...                                                              {'alarm_id':'7107','fault_id':'7300'},
...                                                              {'alarm_id':'7107','fault_id':'7319'},
...                                                              {'alarm_id':'7115','fault_id':'4589'},
...                                                              {'alarm_id':'7116','fault_id':'1815'}]},
...                   'rat_reset':{'temp_allowed_alarms':[{'alarm_id':'7107','fault_id':'7114'},
...                                                       {'alarm_id':'7107','fault_id':'7319'},
...                                                       {'alarm_id':'7114','fault_id':'7107'}]},
...                   'reset_rmod':{'temp_allowed_alarms':[{'alarm_id':'7107','fault_id':'7300'},
...                                                        {'alarm_id':'7107','fault_id':'7319'}]}
...                  }


*** Test Cases ***
CB013500_Random_OAM_Procedure
    [Timeout]    96h
    Run Random OAM Operations       timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             l3_call=False
