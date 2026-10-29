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
Resource    Resources/E2E_CMCC_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

Variables    Resources/CB012591_variables.py


Suite Setup       UUF4ALL common Suite Setup with alarm checking    if_commissioning=${True}
Suite Teardown    UUF4ALL common Suite teardown with scf commission

*** Variables ***
${RP_CA}   VRF_RRM
${RP_LOCATION}    VRF_HAZ4
${RP_ORGANIZATION}    VRF_HAZ4_T02
${EMAIL_RECIPIENTS}         None
@{CUSTOMERS}                CMCC
${INITIAL_SW}               ${EMPTY}
${TARGET_SW}                ${EMPTY}
${REPORT}=                      ${True}
@{critical_faults}       10    16    1806    1868    4341    4352    4383
@{custom_alarms}         7312    7313    7307    7311    4589    2403    4681
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
&{NODE2}                        node_vm=${vm_dict}
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${LTE_custom_alarms}
...                             check_mplane=${False}
...                             syslog_ignored_prints=${IGNORED_PRINTS}
@{NODES_enb}                        ${NODE2}
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

${tl_scf_dir_path}     ${CURDIR}/../../../../../commissionings/HGZ/


*** Test Cases ***
E2E TL SITE RESET WITH OAM KPI
    [Setup]    Common CMCC Test Case Setup
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_trimode.xml
    COAM Teardown gnb connections
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_trimode.xml
    COAM Teardown gnb connections
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_rmod_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_trimode.xml
    COAM Teardown gnb connections
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_nrcel_lock}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E TL SITE RESET WITH OAM KPI D1
    [Setup]    Common CMCC Test Case Setup
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_D1.xml
    COAM Teardown gnb connections
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E TL SITE RESET WITH OAM KPI D3
    [Setup]    Common CMCC Test Case Setup
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_D3.xml
    COAM Teardown gnb connections
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E TL SITE RESET WITH OAM KPI D5
    [Setup]    Common CMCC Test Case Setup
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_D5.xml
    COAM Teardown gnb connections
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E TL SITE RESET WITH OAM KPI D6
    [Setup]    Common CMCC Test Case Setup
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_D6.xml
    COAM Teardown gnb connections
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

*** Keywords ***
UUF4ALL common Suite Setup with alarm checking
    [Arguments]    ${if_commissioning}=${False}
	robot_common_operations.Common Suite Setup
	${5G_flag}    Run keyword and return status    should contain    ${testline_name}    5G
	run keyword if     ${if_commissioning} and ${5G_flag}    CI_interface.Common Suite Setup
	...    ELSE IF    ${if_commissioning}    Do Commission with LTE site
	...    ELSE    log     skip commission
    Set Suite Variable      ${SUITE_SETUP_STATUS}      True

Do Commission with LTE site
    Selenium Login And Disable Screen Lock    download_dir=${TS_CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    selenium_coam.close_browser
    ${current_version}    Replace String    ${current_version['Active']}    SBTS23R3    SBTS00
	${stream}    string.fetch from left    ${current_version}    marker=_
	run keyword and ignore error    csn.disconnect    connection=GNB_OAM
	Connect to gnb coam via ssl    bts_host=${sbts_addr}
	...    username=${tl.enbs[0].airscale.common_units[1].lmp_connection.username}
	...    password=${tl.enbs[0].airscale.common_units[1].lmp_connection.password}
	${scf_base_path}    String.Replace String    ${CURDIR}    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CMCC_E2E
	...    commissionings
	Run keyword and ignore error    COAM Commission with scf file
	...    scf_file_path=${scf_base_path}/HGZ/${testline_name}/${stream}/GNB0_SCF.xml    timeout=600      is_pdl_checking_needed=False
	...    connection=GNB_OAM
	run keyword and ignore error    csn.disconnect    connection=GNB_OAM
	Connect to gnb coam via ssl    bts_host=${sbts_addr}
	...    username=${tl.enbs[0].airscale.common_units[1].lmp_connection.username}
	...    password=${tl.enbs[0].airscale.common_units[1].lmp_connection.password}
    RUn keyword and ignore error      Wait until keyword succeeds    10 min    60 sec
    ...      verify all cells should be onair    cell_type=lte    connection=GNB_OAM
    run keyword and ignore error    csn.disconnect    connection=GNB_OAM
    Set Suite Variable              ${SUITE_SETUP_STATUS}    ${True}
    [Teardown]    COAM Teardown gnb connections

COAM commission scf and wait cell setup
    [Arguments]    ${scf_file_path}    ${is_pdl_checking_needed}=${False}    ${gnb_type}='SA'
    COAM Commission with scf file    scf_file_path=${scf_file_path}    timeout=480    is_pdl_checking_needed=${is_pdl_checking_needed}
    Wait Until Keyword Succeeds   20 min  5min   COAM Wait for gnb ready and cell setup    gnb_type=${gnb_type}

UUF4ALL common Suite teardown with scf commission
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/SCF_${ENB_BRANCH}.xml
    COAM Teardown gnb connections
    common_setups_and_teardowns.Common Suite Teardown
