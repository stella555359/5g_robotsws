*** Settings ***
Documentation    Test Suite
Library    taf.sbts.oam.coam.admin  WITH NAME  coam

Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Force Tags      CA_VRF_TSR2

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate

*** Variables ***

# UUF4ALL Section
#Helper variable do teremine status of ST4.7 upgrade

${RP_CA}                        VRF_SiSo
${RP_LOCATION}                  VRF_TSR2
${RP_ORGANIZATION}              VRF_TSR2_T04

${UPDATE_TEST_FAILED}          ${False}

@{CUSTOMERS}=                   Generic
${INITIAL}=                     ${None}
${CANDIDATE}=                   ${None}
${UPGRADE_ITERATION}=           3
${TEMP_ALLOWED_FAULTS}=         ${None}

# cellX2 links and/or NG links and/or E1 link unavailability: 7107
# FID 10 already exepted by default, need also 1815
# CNI 103974: 4773
# DSS alarms: 7513 7511 7509
@{CUSTOM_ALLOWED_ALARMS}        4773  1815  7300  7513  7511  7509  6129  6134


&{node1}                        node_alias=NR_BTS1
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

&{node2}                        node_alias=LTE_BTS2
...                             testline_object=${tl.enbs[1]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{nodes}                        ${node1}  ${node2}



*** Test Cases ***

UPDATE ROLLBACK UUF
    [Timeout]   24h

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=${UPGRADE_ITERATION}
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}
    ...   restore_to_target_sw=True
	...   synchronize_software_on_passive=True

    [Teardown]   Run Keyword If Test Failed   Set Test Failed

# UUF Site Reset test
UUF SITE RESET WITHOUT HWF
    [Timeout]   24h
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=5
    ...   report=${True}
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