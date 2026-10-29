*** Settings ***
Documentation  Test Suite

#UUF4ALL scope
Library    taf.sbts.oam.coam.admin  WITH NAME  coam

#UUF4ALL scope
Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Force Tags      CA_VRF_TSR2


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_NR_IGNORED_ALARM_SANITY}    alarmId=7115    faultId=1300
${POWER_ON_FLAG}    ${True}

# UUF4ALL Section
#Helper variable do teremine status of ST4.7 upgrade

${UPDATE_TEST_FAILED}          ${False}

@{CUSTOMERS}=                   Generic
${INITIAL}=                     None
${CANDIDATE}=                   None
${UPGRADE_ITERATION}=           1

# CNI 103974: 4773
# PPS reference missing, severity: Major, alarm_id: 7108, fault_id: 1898
# LTE DSS: 6134  6132  6129
# NR DSS: 7513  7511  7509
# cellX2 links and/or NG links and/or E1 link unavailability: 7107

${TEMP_ALLOWED_FAULTS}=
@{CUSTOM_ALLOWED_ALARMS}        4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  1300  4592


&{node1}                        node_alias=SBTS_1
...                             testline_object=${tl.enbs[0]}
...                             source_sw=SBTS00_ENB_9999_241219_000015
...                             target_sw=SBTS00_ENB_9999_241220_000008
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

&{node2}                        node_alias=SBTS_2
...                             testline_object=${tl.enbs[1]}
...                             source_sw=SBTS00_ENB_9999_241219_000015
...                             target_sw=SBTS00_ENB_9999_241220_000008
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

&{node3}                        node_alias=SBTS_3
...                             testline_object=${tl.enbs[2]}
...                             source_sw=SBTS00_FSM3_9999_241219_000003
...                             target_sw=SBTS00_FSM3_9999_241220_000001
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
@{nodes}                        ${node1}  ${node2}  ${node3}


*** Test Cases ***
#UUF4ALL Upgrade Test-Case
PRELIMINARY UPGRADE
    [Timeout]   24h
    # Here is where the magic happens, single keyword to run the upgrade
    # the bts to target software
    # after which you can continue with our scope

    e2e_tl_upgrade_test
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=${UPGRADE_ITERATION}
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}

    # In test teardown we change the value of our global flag to indicate
    # the status of an upgrade
    [Teardown]   Run Keyword If Test Failed   Set Test Failed


#UUF4ALL Upgrade Rollback Test-Case
UPDATE ROLLBACK UUF
    [Timeout]   24h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=2
    ...   report=${False}
    ...   customers_list=${CUSTOMERS}
    ...   restore_to_target_sw=True

    # In test teardown we change the value of our global flag to indicate
    # the status of an upgrade
    [Teardown]   Run Keyword If Test Failed   Set Test Failed


# UUF Site Reset test
UUF SITE RESET WITHOUT HWF
    [Timeout]   24h
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=1
    ...   report=${False}
    ...   customers_list=${CUSTOMERS}

*** Keywords ***
#UUF4ALL Test Helper KW
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}

#UUF4ALL Test Helper KW
Check Update Status
    Run Keyword If      ${UPDATE_TEST_FAILED}  Fail

#UUF4ALL Test Helper KW
Simple admin connection
    ${setup_status}=  run keyword and return status  coam.setup admin
    ...  bts_host=192.168.255.1
    ...  bts_port=443
    ...  admin_api_log_dir=/home/ute/admin_logs/
    ...  name=alias
    Log                       Admin Setup Status: ${setup_status}
    run keyword unless        ${setup_status}  Fail  Setup Admin Failed
    &{bts_info}               coam.get_bts_info  connection=alias  timeout=60
    Log                       ${bts_info}
    [Teardown]  run keyword
    ...       coam.teardown_admin  connection=alias
