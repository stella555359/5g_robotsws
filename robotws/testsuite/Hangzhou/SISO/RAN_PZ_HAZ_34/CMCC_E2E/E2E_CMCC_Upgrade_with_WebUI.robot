*** Settings ***
Documentation
...   Test suite for regression testing of CMCC
...                 Author: Chen Yin
...                 Contact: yin.1.chen@nokia-sbell.com
Force Tags        5G_SISO    CA_VRF_HAZ4

Library      String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     taf/rfrl/csv4all/resources/utilities/utilities.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CMCC_E2E/Resources/delta.py
Resource          Resources/E2E_CMCC_common_keyword.robot

Suite Setup       UUF4ALL common Suite Setup with alarm checking    if_commissioning=${True}
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

*** Variables ***
${RP_CA}   VRF_RRM
${RP_LOCATION}    VRF_HAZ
${RP_ORGANIZATION}    VRF_HAZ_T02
${EMAIL_RECIPIENTS}         None
@{CUSTOMERS}                CMCC
${INITIAL_SW}               ${EMPTY}
${TARGET_SW}                ${EMPTY}
${REPORT}=                      ${True}
@{critical_faults}       10    16    1806    1868    4341    4352    4383
@{custom_alarms}         7312    7313    7307    7311    4589
@{IGNORED_PRINTS}        INF/
@{LTE_custom_alarms}    4420    4125    4405
&{vm_dict}                  host=${tl.test_pcs[0].default_ssh_connection_details.addr}
...                         user=${tl.test_pcs[0].default_ssh_connection_details.username}
...                         password=${tl.test_pcs[0].default_ssh_connection_details.password}
&{NODE1}                        node_vm=${vm_dict}
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${custom_alarms}
...                             check_mplane=${False}
...                             syslog_ignored_prints=${IGNORED_PRINTS}
@{NODES}                        ${NODE1}
${testline_name}
${CONFIGURATION}    HGZ.${testline_name}
${delta_file}    delta.json
${STOP_TEST_AFTER_FAIL}         ${True}

# Test iteration count used in keyword call
${runs_of_uuf_upgrade}   ${3}
${runs_of_uuf_reset}     ${20}
${runs_of_bbmod_reset}   ${10}
${runs_of_rmod_reset}    ${20}
${runs_of_nrcel_lock}    ${10}
${runs_of_delta_commission}    ${3}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Setup]    Common CMCC Test Case Setup
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${current_version}    Replace String    ${current_version['Active']}    SBTS26R2    SBTS00
    Set Test Variable    ${5g_source_sw}    ${current_version}
    ${initial_sw}=    set variable if  '${INITIAL_SW}'=='${EMPTY}'  ${current_version}
    ${candidate_sw}=    set variable if  '${TARGET_SW}'=='${EMPTY}'    ${target_version}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
    ${package_suffix}=      set variable if    '${testline_name}' == '7_5_UTE5G402T785'      CMCC_A50
    ...                '${testline_name}' == '7_5_UTE4G402T9672'      CMCC_A50
    ...                '${testline_name}' == '7_5_UTE5G402T777'      CMCC_A50
    ...                '${testline_name}' == '7_5_UTE5G402T978'      CMCC_A50
    ...                '${testline_name}' == '7_5_UTE5G402T10756'      CMCC_A50
    ...                A54
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  package_suffix=${package_suffix}
    ...  iterations_per_node=${runs_of_uuf_upgrade}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Clear SW Build

#E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
#    [Setup]    Common CMCC Test Case Setup
#    ${5G_pakage_path}      Get package link and Download to VM
#    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
#    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    ${current_version}    Replace String    ${current_version['Active']}    SBTS25R2    SBTS00
#    Set Test Variable    ${5g_source_sw}    ${current_version}
#    UUF4ALL_SW_UPGRADE_TEST
#    ...    test_iteration=${runs_of_uuf_upgrade_withcall}
#    ...    custom_alarms=@{custom_alarms}
#    ...    critical_faults=@{critical_faults}
#    ...    customers_list=${customers}
#    ...    5g_source_sw=${5g_source_sw}
#    ...    5g_target_sw=${target_version}
#    ...    5g_target_sw_path=${5G_pakage_path}
#    ...    use_builds_storage=${False}
#    ...    restore_to_target_sw=${True}
#    ...    local_node_attach_test_keyword=UE Attach and Check traffic for Sleeping Cells
#    [Teardown]    Clear SW Build

*** Keywords ***
UUF4ALL common Suite Setup with alarm checking
    [Arguments]    ${if_commissioning}=${False}
	robot_common_operations.Common Suite Setup
	${5G_flag}    Run keyword and return status    should contain    ${testline_name}    5G
	run keyword if     ${if_commissioning} and ${5G_flag}    CI_interface.Common Suite Setup
	...    ELSE    log     skip commission
    Set Suite Variable      ${SUITE_SETUP_STATUS}      True
