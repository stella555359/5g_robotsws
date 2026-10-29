*** Settings ***
Documentation
...   Test Suite: CB009301 for 5G testing.
...   Test cases verify if the feature collects successfully initial and periodic eCPRI delay measurements during basic
...   operations performed on BTS.
...   In test scenarios below logs are used for verification:
...   1. eGEN logs - in collected pcap can be checked if count of MSG5 requests is matching MSG5 responses. It is done
...   by comparing amount of each action type: 0x00 & 0x02 for request & response for delay measurement in DL and
...   0x01, 0x05 & 0x04 for request & response for delay measurement in UL.
...   2. Snapshot - in L1 RMOD journal and L1 previous boots journal can be verified if unexpected actions occured
...   during test procedure e.g. timeout, no responses from RU.

...   author: Karolina Pacia, Mateusz Potoniec
...   contact: karolina.pacia@nokia.com, mateusz.potoniec@nokia.com
...   maintainer: karolina.pacia@nokia.com, mateusz.potoniec@nokia.com


Library    taf.rfrl.csv4all.CSV4AllTestCases
Library    testsuite/Krakow/resources/random_oam_procedure_runner.py

Resource    ./resources/suite_specific_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 scf_prefix_tag=9301
...                 increase_timeout_for_update_sw=1800
...                 increase_time_for_checking_cells=1800
Suite Teardown      Common Suite Setup With OnAir Test Line Preparation Teardown


*** Variables ***
${TOTAL_TIMEOUT}                                ${3600}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${False}
${OPERATIONS}                                   ['site_reset', 'reset_rmod', 'cell_block_unblock', 'cell_lock_unlock', 'rat_reset']
${OPERATION_KWARGS}                             {'cell_block_unblock': {'temp_allowed_alarms': [{'alarm_id': '7102', 'fault_id': '49',
...                                             'fault_name': 'Cell blocked'}], 'calculate_kpi': false}}
${RANDOM_SEED}                                  ${None}
${L3_CALL}                                      ${False}

${SERIAL_CONSOLE}                          ${False}

${REPORT}                                  ${True}
${QC_REPORT}                               ${True}
${STOP_TEST_AFTER_FAIL}                    ${False}

@{CUSTOMERS}                               Generic
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_KRK
${RP_ORGANIZATION}                         VRF_KRK_T06
${RP_CA}                                   VRF_RRM


*** Test Cases ***
CB009301_Random_OAM_Operations
    [Setup]    Test Setup UUF
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    [Teardown]    Test Teardown UUF
