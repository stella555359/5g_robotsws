*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/SBTS__STATE__Site_Reset_from_WEBEM.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  coam

Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Force Tags      CA_VRF_TSR2

#UUF4ALL scope
#Suite Setup                     Set Initial And Candidate


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_IGNORED_ALARM_SANITY}    alarmId=7220   faultId=4459

# UUF4ALL Section
#Helper variable do teremine status of ST4.7 upgrade

${UPDATE_TEST_FAILED}          ${False}

@{CUSTOMERS}=                   Generic
${INITIAL}=                     SBTS24R3_ENB_0000_000425_000000
${CANDIDATE}=                   SBTS24R3_ENB_0000_000473_000000
${UPGRADE_ITERATION}=           1

# CNI 103974: 4773
# PPS reference missing, severity: Major, alarm_id: 7108, fault_id: 1898
# LTE DSS: 6134  6132  6129
# NR DSS: 7513  7511  7509
# cellX2 links and/or NG links and/or E1 link unavailability: 7107

${TEMP_ALLOWED_FAULTS}=
@{CUSTOM_ALLOWED_ALARMS}        4592  7319  7300


&{node1}                        node_alias=SBTS_1
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}


@{nodes}                        ${node1}


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
    ...   iterations_per_node=1
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}

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

# UUF update Rollback test
UPDATE ROLLBACK UUF
    [Timeout]   24h

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    # pe care sa faca SWR
    ...   iterations_per_node=${UPGRADE_ITERATION}
    ...   report=${False}
    ...   customers_list=${CUSTOMERS}
    ...   restore_to_target_sw=True
#    ...   synchronize_software_on_passive=True

    # In test teardown we change the value of our global flag to indicate
    # the status of an upgrade
    [Teardown]   Run Keyword If Test Failed   Set Test Failed


[1]SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__site_reset_from_webem_alarms_definitions.py
    ...    AND    Append To List  ${SBTS_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_SANITY}
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    True
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214

    ...    AND    SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__Site_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__Site_Reset_from_WEBEM
    TC__SBTS__STATE__Site_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



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


