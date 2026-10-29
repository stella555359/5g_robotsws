*** Settings ***
Documentation  LTE on Cloud setup and teardown keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../../resources/Robot/tl_init.robot
Resource    ../../../resources/Robot/common_kw.robot
Resource    ./vdu_vcu_operations.robot
Resource    ./setup_teardown.robot
Resource    ./logs.robot
Resource    ../../../resources/reporting.robot
Resource    ../../resources/variables.robot

*** Keywords ***
# Setup section
Lte Cloud Suite Setup
    [Arguments]  ${set_prefix}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Setup section for test suite.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | set_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Message Colors
    Set Log Prefix  set_prefix=${set_prefix}
    Log  \n${start_prefix_blue}Suite Setup: LTE Cloud suite setup  console=${log_to_console}
# Setup Host Variables
    Log  ${ok_prefix_blue}Setup Host Variables  console=${log_to_console}
    Setup Host Variables
# LTE vDU build information
    Log  ${dots_prefix_blue}LTE vDU build information  console=${log_to_console}
    ${vdu_build_name_status}  ${vdu_build_number}=  Run Keyword And Ignore Error  Get vDU Build Number
    Run Keyword If  '${vdu_build_name_status}'=='PASS'
    ...  Log  ${info_prefix}LTE vDU build number: ${vdu_build_number}  console=${log_to_console}
    Log  ${ok_prefix_blue}LTE vDU build information  console=${log_to_console}
# Remove unnecessary files and unexpected processes
    Log  ${dots_prefix_blue}Remove unnecessary files  console=${log_to_console}
    Run Keyword And Ignore Error  K8s Master Delete Temporary Files
    Log  ${info_prefix}K8s master temporary files have been deleted  console=${log_to_console}
    Log  ${ok_prefix_blue}Remove unnecessary files  console=${log_to_console}
# SCFC file parameters checking
#    Log  ${dots_prefix_blue}SCFC file parameters checking  console=${log_to_console}
#    Run Keyword And Ignore Error  vDU Activate CLI Parameter Should Be Enabled
#    Log  ${info_prefix}actCli parameter has been checked (vDU, VCU)  console=${log_to_console}
#    Log  ${ok_prefix_blue}SCFC file parameters checking  console=${log_to_console}
# Set test suite logs paths variables
    Log  ${dots_prefix_blue}Set test suite logs paths variables  console=${log_to_console}
    Set Suite Variable  ${TEST_SUITE_LOGS_DIR_PATH}  ${SUITE_LOGS_DIR_PATH}/suite_teardown_logs
    Log  ${ok_prefix_blue}Set test suite logs paths variables  console=${log_to_console}
    Log  ${done_prefix_blue}Suite Setup: LTE Cloud suite setup\n  console=${log_to_console}

Lte Cloud Test Setup
    [Arguments]  ${run_index}=1  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Setup section for test case.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Setup: LTE Cloud test setup  console=${log_to_console}
    LTEvDU Rest Login  lte_vdu_connection=${lte_vdu_connection}
# Get and check LTE vDU active alarms
    Log  ${dots_prefix_blue}Get and check LTE vDU active alarms  console=${log_to_console}
    Append To List  ${LTE_VDU_ALLOWED_ALARMS}  @{ADDITIONAL_COMMON_LTE_VDU_ALLOWED_ALARMS}
    ${lte_vdu_active_alarms}=  LTEvDU Get Active Alarms  lte_vdu_connection=${lte_vdu_connection}
    Run Keyword And Continue On Failure
    ...  Check Active Alarms  allowed_alarms=${LTE_VDU_ALLOWED_ALARMS}  active_alarms=${lte_vdu_active_alarms}
    ...  source=vDU  log_prefix=${info_prefix}  log_to_console=${log_to_console}
    Log  ${info_prefix}All LTE vDU active alarms have been checked  console=${log_to_console}
    Log  ${ok_prefix_blue}Get and check LTE vDU active alarms  console=${log_to_console}
# Get LTE vDU historical alarms
    Log  ${dots_prefix_blue}Get LTE vDU historical alarms  console=${log_to_console}
    ${vdu_setup_historical_alarms}=  LTEvDU Get Historical Alarms  lte_vdu_connection=${lte_vdu_connection}
    Set Test Variable  ${LTE_VDU_SETUP_HISTORICAL_ALARMS}  ${vdu_setup_historical_alarms}
    Log  ${ok_prefix_blue}Get LTE vDU historical alarms  console=${log_to_console}
    Log  ${dots_prefix_blue}Set test case logs paths variables  console=${log_to_console}
    Set Test Variable  ${TC_RUN_LOGS_DIR_PATH}  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/cbts_test_run_${run_index}
    Log  ${ok_prefix_blue}Set test case logs paths variables  console=${log_to_console}
    Log  ${done_prefix_blue}Test Setup: LTE Cloud test setup\n  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  LTEvDU Rest Logout  lte_vdu_connection=${lte_vdu_connection}

# Teardown section
Lte Cloud Suite Teardown
    [Arguments]  ${get_logs}=${True}  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    ...  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Teardown section for test suite.
    ...
    ...  ${get_logs} argument settings:
    ...  ${get_logs}=${False} - logs are not collected
    ...  ${get_logs}=${True} - logs are always collected
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Suite Teardown: LTE Cloud Suite Teardown  console=${log_to_console}
    LTEvDU Rest Login  lte_vdu_connection=${lte_vdu_connection}
    ${suite_teardown_logs_dir}=  Set Variable  ${TEST_SUITE_LOGS_DIR_PATH}
    Create Directory  path=${suite_teardown_logs_dir}
    IF  not ${get_logs}
      Log  ${info_prefix}User flag has been set  console=${log_to_console}
      Log  ${info_prefix}No snapshots or logs will be collected  console=${log_to_console}
      Log  ${done_prefix_blue}Test Suite Teardown: Lte Cloud Suite Teardown\n  console=${log_to_console}
      Return From Keyword
    END
# Get LTE vDU logs
    Log  ${dots_prefix_blue}Get LTE vDU logs  console=${log_to_console}
    Log  ${info_prefix}LTE vDU snapshot is collected now  console=${log_to_console}
    LTEvDU Collect Snapshot  logs_dir_path=${suite_teardown_logs_dir}  timeout=600  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}LTE vDU snapshot has been collected  console=${log_to_console}
    Log  ${info_prefix}LTE vDU container logs from all pods are collected now  console=${log_to_console}
    vDU Get Container Logs On All Pods  logs_dir_path=${suite_teardown_logs_dir}
    Log  ${info_prefix}LTE vDU container logs from all pods have been collected  console=${log_to_console}
    Log  ${ok_prefix_blue}Get LTE vDU logs  console=${log_to_console}
    Log  ${done_prefix_blue}Test Suite Teardown: LTE Cloud Suite Teardown\n  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  LTEvDU Rest Logout  lte_vdu_connection=${lte_vdu_connection}

Lte Cloud Test Teardown
    [Arguments]  ${run_index}=1  ${get_logs}=${False}  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    ...  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Teardown section for test case.
    ...
    ...  Usage:
    ...  ${get_logs}=${False} - logs are not collected, but only if the test is successful
    ...                         and there are no unexpected alarms
    ...  ${get_logs}=${True} - logs are always collected
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | run_index              |  No  | Number of test execution.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Case Teardown: LTE Cloud Test Teardown  console=${log_to_console}
    LTEvDU Rest Login  lte_vdu_connection=${lte_vdu_connection}
    ${tc_status}=  Get Variable Value  ${TEST STATUS}  ${KEYWORD STATUS}
    Run Keyword If  '${tc_status}'=='PASS' and '${get_logs}'=='False'
    ...  Log  ${info_prefix}Single test result (run ${run_index}) ${passed_result}  console=${log_to_console}
    ...  ELSE IF  '${tc_status}'=='PASS' and '${get_logs}'=='True'
    ...  Log  ${info_prefix}Single test result (run ${run_index}) ${passed_result}  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}Single test result (run ${run_index}) ${failed_result}  console=${log_to_console}
    ${logs_dir_path}=  Set Variable  ${TC_RUN_LOGS_DIR_PATH}
    Create Directory  path=${logs_dir_path}
# QC mapping
    Log  ${dots_prefix_blue}QC mapping  console=${log_to_console}
    ${vdu_params}=  ltevdu.Get Vdu State Data  connection=${lte_vdu_connection}
    ${test_case_name}=  Test Case QC Mapping  sw_version=${vdu_params['softwareVersion']}
    Log  ${info_prefix}Test case will be mapped as "${test_case_name}"  console=${log_to_console}
    Log  ${ok_prefix_blue}QC mapping  console=${log_to_console}
# Get and check LTE vDU active alarms
    Log  ${dots_prefix_blue}Get and check LTE vDU active alarms  console=${log_to_console}
    ${lte_vdu_active_alarms}=  LTEvDU Get Active Alarms  lte_vdu_connection=${lte_vdu_connection}
    ${active_alarms_result}=  Check Active Alarms
    ...  allowed_alarms=${LTE_VDU_ALLOWED_ALARMS}
    ...  active_alarms=${lte_vdu_active_alarms}
    ...  source=vDU
    ...  log_prefix=${info_prefix}
    ...  log_to_console=${log_to_console}
    Log  ${info_prefix}All LTE vDU active alarms have been checked  console=${log_to_console}
    Log  ${ok_prefix_blue}Get and check LTE vDU active alarms  console=${log_to_console}
# Get and check historical LTE vDU alarms
    Log  ${dots_prefix_blue}Get and check LTE vDU historical alarms  console=${log_to_console}
    ${lte_vdu_historical_alarms}=  LTEvDU Get Historical Alarms  lte_vdu_connection=${lte_vdu_connection}
    Remove Values From List  ${lte_vdu_historical_alarms}  @{LTE_VDU_SETUP_HISTORICAL_ALARMS}
    Log List  ${lte_vdu_historical_alarms}
    Append To List  ${LTE_VDU_HISTORICAL_ALLOWED_ALARMS}  @{ADDITIONAL_COMMON_HISTORICAL_LTE_VDU_ALLOWED_ALARMS}
    ${historical_alarms_result}=  Check Active Alarms
    ...  allowed_alarms=${LTE_VDU_HISTORICAL_ALLOWED_ALARMS}
    ...  active_alarms=${lte_vdu_historical_alarms}
    ...  source=vDU
    ...  log_prefix=${info_prefix}
    ...  log_to_console=${log_to_console}
    Log  ${info_prefix}All LTE vDU historical alarms have been checked  console=${log_to_console}
    Log  ${ok_prefix_blue}Get and check LTE vDU historical alarms  console=${log_to_console}
    Return From Keyword If  '${tc_status}'=='PASS' and not ${get_logs} and ${active_alarms_result} and ${historical_alarms_result}
# Get LTE vDU logs
    Log  ${dots_prefix_blue}Get LTE vDU logs  console=${log_to_console}
    Log  ${info_prefix}LTE vDU snapshot is collected now  console=${log_to_console}
    LTEvDU Collect Snapshot  logs_dir_path=${logs_dir_path}  timeout=600  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}LTE vDU snapshot has been collected  console=${log_to_console}
    Log  ${info_prefix}LTE vDU container logs from all pods are collected now  console=${log_to_console}
    vDU Get Container Logs On All Pods  logs_dir_path=${logs_dir_path}
    Log  ${info_prefix}LTE vDU container logs from all pods have been collected  console=${log_to_console}
    Log  ${ok_prefix_blue}Get LTE vDU logs  console=${log_to_console}
    Log  ${done_prefix_blue}Test Case Teardown: LTE Cloud Test Teardown\n  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  LTEvDU Rest Logout  lte_vdu_connection=${lte_vdu_connection}

#Alarms section
LTEvDU Get Active Alarms
    [Arguments]  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword gets active alarms form LTE vDU (including faults from BTS and alarms from RCP).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Active alarms list from LTEvDU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${active_alarms}=  ltevdu.Get Active Alarms  connection=${lte_vdu_connection}
    ${alarms_count}=  Get Length  item=${active_alarms["alarms"]}
    Should Be Equal As Integers  first=${alarms_count}  second=${active_alarms["total"]}
    ...  msg=There should be ${active_alarms["total"]} active alarms, but actually got ${alarms_count}
    [Return]  ${active_alarms["alarms"]}

LTEvDU Get Historical Alarms
    [Arguments]  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword gets historical alarms form LTE vDU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Historical alarms list from LTEvDU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${historical_alarms}=  ltevdu.Get Historical Alarms  connection=${lte_vdu_connection}
    ${alarms_count}=  Get Length  item=${historical_alarms["alarms"]}
    Should Be Equal As Integers  first=${alarms_count}  second=${historical_alarms["total"]}
    ...  msg=There should be ${historical_alarms["total"]} historical alarms, but actually got ${alarms_count}
    [Return]  ${historical_alarms["alarms"]}

#Snapshot section
LTEvDU Collect Snapshot
    [Arguments]  ${logs_dir_path}  ${timeout}=300  ${compressed_or_not}=${True}
    ...  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword gets LTE vDU snapshot files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the directory where vDU snapshot log files should be stored.       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | Yes  | Snapshot collection time.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | compressed_or_not      |  No  | Compress or not all files to one zip file.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_snapshot_dir}=  Set Variable  ${logs_dir_path}/lte_vdu_snapshot
    Create Directory  path=${vdu_snapshot_dir}
    Run Keyword And Ignore Error
    ...  ltevdu.Get Snapshot  directory=${vdu_snapshot_dir}  compressed=${compressed_or_not}
    ...  timeout=${timeout}  connection=${lte_vdu_connection}

#Temporary KWs
LTEvDU Check Bts Reset Cause Alarm
    [Arguments]  ${timeout}=30s  ${fault_timeout}=30s  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    ...  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword checks the occurrence of Bts Reset Cause alarm (faultId=4592).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_prefix             |  No  | Set info log prefix to message or not.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected active alarm.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fault_timeout          |  No  |  Time during which fault 4592 will be reported.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${log_prefix}Waiting for alarm activation (faultId=4592) ...  console=${log_to_console}
    LTEvDU Assert Alarm Active
    ...  fault_id=4592
    ...  timeout=${timeout}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Log  ${log_prefix}Alarm (faultId=4592) is active  console=${log_to_console}
    Log  ${log_prefix}Waiting for alarm deactivation (faultId=4592) ...  console=${log_to_console}
    LTEvDU Assert Alarm Inactive
    ...  fault_id=4592
    ...  timeout=${fault_timeout}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Log  ${log_prefix}Alarm (faultId=4592) is inactive  console=${log_to_console}

LTEvDU Assert Alarm Active
    [Arguments]  ${fault_id}  ${timeout}=30  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword waiting for LTE vDU active alarm.
    ...  Active alarm is defined by faultId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm faultId.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected active alarm.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fault_id_status}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  10
    ...  LTEvDU Alarm Should Be Active
    ...  fault_id=${fault_id}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Run Keyword If  '${fault_id_status}'=='${False}'
    ...  Fail  The expected alarm (faultId:${faultId}) is not active !!!

LTEvDU Assert Alarm Inactive
    [Arguments]  ${fault_id}  ${timeout}=30  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword waiting for LTE vDU inactive alarm.
    ...  Active alarm is defined by faultId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm faultId.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  |  Waiting time for active alarm deactivation.                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fault_id_status}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  10
    ...  LTEvDU Alarm Should Be Inactive
    ...  fault_id=${fault_id}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Run Keyword If  '${fault_id_status}'=='${False}'
    ...  Fail  The unexpected alarm (faultId:${faultId}) is active !!!

LTEvDU Alarm Should Be Active
    [Arguments]  ${fault_id}  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword checks if LTE vDU alarm given by faultId is active.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm faultId.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_status}=  LTEvDU Get Alarm Status
    ...  fault_id=${fault_id}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Should Be True  ${alarm_status}

LTEvDU Alarm Should Be Inactive
    [Arguments]  ${fault_id}  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword checks if LTE vDU alarm given by faultId is inactive.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm faultId.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_status}=  LTEvDU Get Alarm Status
    ...  fault_id=${fault_id}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Should Not Be True  ${alarm_status}

LTEvDU Get Alarm Status
    [Arguments]  ${fault_id}  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}
    [Documentation]
    ...  Description:
    ...  Keyword gets LTE vDU alarm status.
    ...  If the alarm exists, the status is "True", if the alarm does not exist, the status is "False".
    ...  Active alarm is defined by faultId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm faultId.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU alarm status (alarm exist: "True" or alarm not exist: "False").
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_status}=  Set Variable  ${False}
    ${active_alarms}=  ltevdu.Get Active Alarms  connection=${lte_vdu_connection}
    FOR  ${active_alarm}  IN  @{active_alarms['alarms']}
      ${alarm_status}=  Set Variable If  ${active_alarm['faultId']}==${fault_id}
      ...  ${True}  ${False}
      Exit For Loop If  ${alarm_status}
    END
    [Return]  ${alarm_status}
