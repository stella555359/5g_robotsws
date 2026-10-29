*** Settings ***
Documentation    Robot Test Suite 2
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  coam

Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Force Tags      CA_VRF_TSR2

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}

# UUF4ALL Section
#Helper variable do teremine status of ST4.7 upgrade

${UPDATE_TEST_FAILED}          ${False}

@{CUSTOMERS}=                   Generic
${INITIAL}=                     ${None}
${CANDIDATE}=                   ${None}
${UPGRADE_ITERATION}=           1
${TEMP_ALLOWED_FAULTS}=         ${None}
${SW_UPGRADE_LOOP_NUMBER}       2

# cellX2 links and/or NG links and/or E1 link unavailability: 7107
# FID 10 already exepted by default, need also 1815
# CNI 103974: 4773
@{CUSTOM_ALLOWED_ALARMS}        4700  4773  1815  7107
${ignore_syslog}  INF/l1_application_rt, Startup Log:
...  maskThreadSignals() - maskThreadSignals new stat: 0 old stat 0 for signal: Bus error

&{node1}                        node_alias=NR_BTS1
...                             testline_object=${tl.gnbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                             syslog_ignored_prints=${ignore_syslog}

&{node2}                        node_alias=LTE_BTS2
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                             syslog_ignored_prints=${ignore_syslog}

@{nodes}                        ${node1}  ${node2}

# DEMO Test case: UUF Upgrade + RFS Rollbck + Synch partions in loop
${SW_UPGRADE_ROLLBACK_LOOP_NUMBER}    2
${RESTORE_TO_TARGET_BUILD}    ${False}


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


# UUF Site Reset test
UUF SITE RESET WITHOUT HWF
    [Timeout]   24h
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=1
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}


# DEMO Test case: UUF Upgrade + RFS Rollbck + Synch partions in loop
Upgrade_Rollabck_In_Loop
    [Timeout]    14400

    Log    UPDATE_ROLLBACK_LOOP_NUMBER: ${SW_UPGRADE_ROLLBACK_LOOP_NUMBER}  console=${True}
    Log    RESTORE_TO_TARGET_BUILD: ${RESTORE_TO_TARGET_BUILD}  console=${True}
    Set Test Variable    ${UPGRADE_ITERATION_COUNT}    0

    Repeat Keyword    ${SW_UPGRADE_ROLLBACK_LOOP_NUMBER}    Run in Loop Sw Upgrade and Rollback

    [Teardown]   Run Keyword If Test Failed   Set Test Failed

# RFS SW Update Test
[1]NRL__SWM__LTE_SWDL
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    ALL
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    800
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Teardown
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

#UUF4ALL Test Helper KW
Set Initial And Candidate
    ${initial_sw}             Get Source SW
    ${candidate_sw}           Get Target SW

    Set to dictionary         ${node1}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

    Set to dictionary         ${node2}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

# DEMO Test case: UUF Upgrade + RFS Rollbck + Synch partions in loop
Run in Loop Sw Upgrade and Rollback

    ${UPGRADE_ITERATION_COUNT}=  Evaluate  ${UPGRADE_ITERATION_COUNT} + 1
    Set Test Variable      ${UPGRADE_ITERATION_COUNT}

    # UUF Upgrade

    Log  Start UUF Upgrade iteration ${UPGRADE_ITERATION_COUNT} of ${SW_UPGRADE_ROLLBACK_LOOP_NUMBER}  console=${True}

    e2e_tl_upgrade_test
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=1
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}

    Log  SW Upgrade iteration ${UPGRADE_ITERATION_COUNT} of ${SW_UPGRADE_ROLLBACK_LOOP_NUMBER} completed  console=${True}

    Run Keyword If
    ...  ${UPGRADE_ITERATION_COUNT} == ${SW_UPGRADE_ROLLBACK_LOOP_NUMBER} and ${RESTORE_TO_TARGET_BUILD}
    ...  Return From Keyword

    # RFS Rollback

    Log  Start RFS Rollback iteration ${UPGRADE_ITERATION_COUNT} of ${SW_UPGRADE_ROLLBACK_LOOP_NUMBER}  console=${True}

    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    ALL
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    900
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    1200

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    Synchronize active and pasive SW versions
    Log  SW Rollback iteration ${UPGRADE_ITERATION_COUNT} of ${SW_UPGRADE_ROLLBACK_LOOP_NUMBER} completed  console=${True}

    [Teardown]    Run Keywords
    ...    Set Test Variable  ${TEST STATUS}  ${KEYWORD STATUS}
    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order

# DEMO Test case: UUF Upgrade + RFS Rollbck + Synch partions in loop
Synchronize active and pasive SW versions
    [Documentation]
    ...  Helper keyword used to synchronize Active and Passive partition SW

    Log  Synchronize active and pasive SW versions  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Synchronize active and pasive SW versions on ${label}   console=True
        Admin Synchronizing Active and Passive SW version  alias=${alias}  timeout=1200
    END

