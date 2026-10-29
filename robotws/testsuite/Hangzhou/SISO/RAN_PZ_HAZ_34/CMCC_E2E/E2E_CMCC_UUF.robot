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
@{custom_alarms}         7312    7313    7307    7311    4589    2403
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


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
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
    ...                '${testline_name}' == '7_5_UTE5G402T779'      CMCC_A50
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

E2E_eNB_SW_Upgrade_loops_with_WebUI
    [Setup]    Common CMCC Test Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4420
	Selenium Login And Disable Screen Lock    download_dir=${TS_CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${current_version}    Replace String    ${current_version['Active']}    SBTS26R2    SBTS00
    Set Test Variable    ${5g_source_sw}    ${current_version}
    ${initial_sw}=    set variable if  '${INITIAL_SW}'=='${EMPTY}'  ${current_version}
    ${candidate_sw}=    set variable if  '${TARGET_SW}'=='${EMPTY}'    ${target_version}
    Set to dictionary    ${NODE2}    source_sw=${initial_sw}    target_sw=${candidate_sw}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  nodes_details=${NODES_enb}
    ...  test_nodes_details=${NODES_enb}
    ...  package_suffix=CMCC_A50
    ...  iterations_per_node=${runs_of_uuf_upgrade}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    AlarmWatchdog.remove_allow_alarms    fault_id=4420
    [Teardown]    Clear SW Build

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E TL SITE RESET WITH OAM KPI
    [Setup]    Common CMCC Test Case Setup
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_Activation_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_uuf_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Clear SW Build

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_bbmod_reset}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
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
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_nrcel_lock}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_nrcel_lock}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
	set test variable    ${mrbtsid}    ${tl.gnbs[0].instance_id}
	set test variable    ${nrbtsid}    ${tl.gnbs[0].global_bts_id}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=nr_rat_reset
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	E2E TL DELTA COMMISSIONING WITH NR RAT RESET
	...  delta=${delta_file}
	...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_delta_commission}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
	set test variable    ${mrbtsid}    ${tl.enbs[0].instance_id}
	set test variable    ${nrbtsid}    ${tl.enbs[0].global_bts_id}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=lte_rat_reset
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	E2E TL DELTA COMMISSIONING WITH LTE RAT RESET
	...  delta=${delta_file}
	...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_delta_commission}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
	${5G_flag}    Run keyword and return status    should contain    ${testline_name}    5G
    ${mrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].instance_id}
    ...    ELSE    set variable    ${tl.enbs[0].instance_id}
    ${nrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].global_bts_id}
    ...    ELSE    set variable    ${tl.enbs[0].global_bts_id}
	set test variable    ${mrbtsid}
	set test variable    ${nrbtsid}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=site_reset
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
	...  delta=${delta_file}
	...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_delta_commission}
    ...  customers_list=${CUSTOMERS}
    ...  report=${REPORT}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Common CMCC Test Case Teardown

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common CMCC Test Case Setup
    ${5G_flag}    Run keyword and return status    should contain    ${testline_name}    5G
    ${mrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].instance_id}
    ...    ELSE    set variable    ${tl.enbs[0].instance_id}
    ${nrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].global_bts_id}
    ...    ELSE    set variable    ${tl.enbs[0].global_bts_id}
    ${parameter_flag}    Run keyword if    ${5G_flag}     set variable    online_5G
    ...    ELSE    set variable    online_LTE
	set test variable    ${mrbtsid}
	set test variable    ${nrbtsid}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=${parameter_flag}
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
	...  delta=${delta_file}
	...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${runs_of_delta_commission}
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