*** Settings ***
Documentation    Setup and teardown keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../../resources/Robot/tl_init.robot
Resource    ../../../resources/Robot/common_kw.robot
Resource    ../../../resources/reporting.robot
Resource    ../../resources/variables.robot
Resource    ./vdu_vcu_operations.robot
Resource    ./vdu_oam_operations.robot
Resource    ./vcu_oam_operations.robot
Resource    ./logs.robot
Resource    ./sbts_setup_teardown.robot

*** Keywords ***
# Setup section
AiC Suite Setup
    [Arguments]  ${set_prefix}=True  ${log_to_console}=True
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
    Log  \n${start_prefix_blue}Test Suite Setup: AiC suite setup  console=${log_to_console}
    Log  ${ok_prefix_blue}Setup Host Variables  console=${log_to_console}
    Setup Host Variables
    Log  ${dots_prefix_blue}vDU and vCU build information  console=${log_to_console}
    ${vdu_build_name_status}  ${vdu_build_number}=  Run Keyword And Ignore Error  Get vDU Build Number
    Run Keyword If  '${vdu_build_name_status}'=='PASS'
    ...  Log  ${info_prefix}vDU build number: ${vdu_build_number}  console=${log_to_console}
    ${vcu_build_name_status}  ${vcu_build_number}=  Run Keyword And Ignore Error  Get vCU Build Number
    Run Keyword If  '${vcu_build_name_status}'=='PASS'
    ...  Log  ${info_prefix}vCU build number: ${vcu_build_number}  console=${log_to_console}
    Log  ${ok_prefix_blue}vDU and vCU build information  console=${log_to_console}
    Log  ${dots_prefix_blue}vDU and vCU active software version  console=${log_to_console}
    ${vdu_sw_version}=  vDU Get Running Software Version  vdu_connection=${VDU_CONNECTION_DEFAULT}
    Set Suite Variable  ${VDU_SW_VERSION}  ${vdu_sw_version}
    Log  ${info_prefix}vDU active software version: ${vdu_sw_version}  console=${log_to_console}
    ${vcu_sw_version}=  vCU Get Running Software Version  vcu_connection=${VCU_CONNECTION_DEFAULT}
    Set Suite Variable  ${VCU_SW_VERSION}  ${vcu_sw_version}
    Log  ${info_prefix}vCU active software version: ${vcu_sw_version}  console=${log_to_console}
    Log  ${ok_prefix_blue}vDU and vCU active software version   console=${log_to_console}
    Log  ${dots_prefix_blue}Remove unnecessary files  console=${log_to_console}
    Run Keyword And Ignore Error  K8s Master Delete Temporary Files
    Log  ${info_prefix}K8s master temporary files have been deleted  console=${log_to_console}
    Log  ${ok_prefix_blue}Remove unnecessary files  console=${log_to_console}
    Log  ${dots_prefix_blue}SCFC file parameters checking  console=${log_to_console}
    Run Keyword And Ignore Error  vCU Activate CLI Parameter Should Be Enabled
    Run Keyword And Ignore Error  vDU Activate CLI Parameter Should Be Enabled
    Log  ${info_prefix}actCli parameter has been checked (vDU, VCU)  console=${log_to_console}
    Log  ${ok_prefix_blue}SCFC file parameters checking  console=${log_to_console}
    Log  ${dots_prefix_blue}Set test suite logs paths variables  console=${log_to_console}
    Set Suite Variable  ${TEST_SUITE_LOGS_DIR_PATH}  ${SUITE_LOGS_DIR_PATH}/cbts/suite_teardown_logs
    Log  ${ok_prefix_blue}Set test suite logs paths variables  console=${log_to_console}
    Log  ${done_prefix_blue}Test Suite Setup: AiC suite setup\n  console=${log_to_console}

AiC Test Setup
    [Arguments]  ${run_index}=1  ${log_to_console}=True
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
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Case Setup: AiC test setup (run ${run_index})  console=${log_to_console}
    Log  ${dots_prefix_blue}Get all active alarms (vDU, VCU)  console=${log_to_console}
    Append To List  ${VDU_ALLOWED_ALARMS}  @{ADDITIONAL_COMMON_VDU_ALLOWED_ALARMS}
    Append To List  ${VCU_ALLOWED_ALARMS}  @{ADDITIONAL_COMMON_VCU_ALLOWED_ALARMS}
    ${vcu_alarms}  ${vdu_alarms}=  Get All Active Alarms
    Run Keyword And Continue On Failure
    ...  Check Active Alarms  allowed_alarms=${VDU_ALLOWED_ALARMS}  active_alarms=${vdu_alarms}
    ...  source=vDU  log_prefix=${info_prefix}  log_to_console=True
    Log  ${info_prefix}All vDU active alarms have been checked  console=${log_to_console}
    Run Keyword And Continue On Failure
    ...  Check Active Alarms  allowed_alarms=${VCU_ALLOWED_ALARMS}  active_alarms=${vcu_alarms}
    ...  source=vCU  log_prefix=${info_prefix}  log_to_console=True
    Log  ${info_prefix}All vCU active alarms have been checked  console=${log_to_console}
    Log  ${ok_prefix_blue}Get all active alarms (vDU, VCU)  console=${log_to_console}
    Log  ${dots_prefix_blue}Get historical alarms (vDU, VCU)  console=${log_to_console}
    ${vCU_setup_historical_alarms}  ${vDU_setup_historical_alarms}=  Get All Actual Historical Alarms
    Set Test Variable  ${VCU_SETUP_HISTORICAL_ALARMS}  ${vCU_setup_historical_alarms}
    Set Test Variable  ${VDU_SETUP_HISTORICAL_ALARMS}  ${vDU_setup_historical_alarms}
    Log  ${ok_prefix_blue}Get historical alarms (vDU, VCU)  console=${log_to_console}
    Log  ${dots_prefix_blue}Set test case logs paths variables  console=${log_to_console}
    Set Test Variable  ${TC_LOGS_DIR_PATH}  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}
    Set Test Variable  ${TC_RUN_LOGS_DIR_PATH}  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/cbts_test_run_${run_index}
    Log  ${ok_prefix_blue}Set test case logs paths variables  console=${log_to_console}
    Log  ${done_prefix_blue}Test Case Setup: AiC test setup (run ${run_index})\n  console=${log_to_console}

Sharing Suite Setup
    [Arguments]  ${sbts_scfc_file_path}  ${swconfig_file_path}=${SWCONFIG_FILE_PATH}
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${set_prefix}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Setup section for test suite (sharing CBTS-SBTS).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | sbts_scfc_file_path    | Yes  | Path to the default SBTS scfc file.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | swconfig_file_path     | Yes  | Path to the default SBTS swconfig file.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where logs file should be stored.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | set_prefix             |  No  | Set (or not) log prefix to message.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Suite Setup
    ...  set_prefix=${set_prefix}
    ...  log_to_console=${log_to_console}
    SBTS Suite Setup
    ...  scfc_file_path=${sbts_scfc_file_path}
    ...  swconfig_file_path=${swconfig_file_path}
    ...  logs_dir_path=${logs_dir_path}
    ...  set_prefix=${set_prefix}
    ...  log_to_console=${log_to_console}

Sharing Test Setup
    [Arguments]  ${run_index}=1  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Setup section for test case (sharing CBTS-SBTS).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    SBTS Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}

# Teardown section
AiC Suite Teardown
    [Arguments]  ${get_logs}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Teardown section for test suite.
    ...
    ...  ${get_logs} argument settings:
    ...  ${get_logs}=${False} - logs are not collected, but only if the test is successful
    ...                         and there are no unexpected alarms
    ...  ${get_logs}=${True} - logs are always collected
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Suite Teardown: AiC suite teardown  console=${log_to_console}
    ${suite_teardown_logs_dir}=  Set Variable  ${TEST_SUITE_LOGS_DIR_PATH}
    Create Directory  path=${suite_teardown_logs_dir}
    IF  '${get_logs}'=='${False}'
      Log  ${info_prefix}User flag was set  console=${log_to_console}
      Log  ${info_prefix}No snapshots or logs will be collected (vDU, vCU, FHGW)  console=${log_to_console}
      Log  ${done_prefix_blue}Test Suite Teardown: AiC suite teardown\n  console=${log_to_console}
      Return From Keyword
    END
# Get vDU and vCU snapshot
    Log  ${dots_prefix_blue}Get vDU and vCU logs  console=${log_to_console}
    Log  ${info_prefix}vDU snapshot is collected now  console=${log_to_console}
    vDU Collect Snapshot  logs_dir_path=${suite_teardown_logs_dir}
    Log  ${info_prefix}vDU snapshot has been collected  console=${log_to_console}
    Log  ${info_prefix}vCU snapshot is collected now  console=${log_to_console}
    vCU Collect Snapshot  logs_dir_path=${suite_teardown_logs_dir}
    Log  ${info_prefix}vCU snapshot has been collected  console=${log_to_console}
# Get FHGWs snapshots
    ${fhgw_connection}=  Get FHGWs Connection Status From Init File
    Run Keyword If  ${fhgw_connection}  Run Keywords
    ...  Log  ${info_prefix}FHGW snapshot is collected now  console=${log_to_console}
    ...  AND
    ...  Run Keyword And Ignore Error  FHGW Collect Snapshot  logs_dir_path=${suite_teardown_logs_dir}
# Get vDU and vCU pods logs
    Log  ${info_prefix}vDU container logs from all pods are collected now  console=${log_to_console}
    vDU Get Container Logs On All Pods  logs_dir_path=${suite_teardown_logs_dir}
    Log  ${info_prefix}vDU container logs from all pods have been collected  console=${log_to_console}
    Log  ${info_prefix}vCU container logs from all pods are collected now  console=${log_to_console}
    vCU Get Container Logs On All Pods  logs_dir_path=${suite_teardown_logs_dir}
    Log  ${info_prefix}vCU container logs from all pods have been collected  console=${log_to_console}
    Log  ${ok_prefix_blue}Get vDU and vCU logs  console=${log_to_console}
    Log  ${done_prefix_blue}Test Suite Teardown: AiC suite teardown\n  console=${log_to_console}

AiC Test Teardown
    [Arguments]  ${run_index}=1  ${get_logs}=${False}  ${log_to_console}=${True}
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
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Case Teardown: AiC test teardown (run ${run_index})  console=${log_to_console}
    ${tc_status}=  Get Variable Value  ${TEST STATUS}  ${KEYWORD STATUS}
    ${logs_dir_path}=  Set Variable  ${TC_RUN_LOGS_DIR_PATH}
    Create Directory  path=${logs_dir_path}
# QC mapping
    Log  ${dots_prefix_blue}QC mapping  console=${log_to_console}
    ${test_case_name}=  Test Case QC Mapping  sw_version=${VDU_SW_VERSION}
    Log  ${info_prefix}Test case will be mapped as "${test_case_name}"  console=${log_to_console}
    Log  ${ok_prefix_blue}QC mapping  console=${log_to_console}
# Remove unnecessary files and unexpected processes
    Log  ${dots_prefix_blue}Remove unnecessary files  console=${log_to_console}
    Run Keyword And Ignore Error  K8s Master Delete Temporary Files
    Log  ${info_prefix}K8s master temporary files have been deleted  console=${log_to_console}
    Log  ${ok_prefix_blue}Remove unnecessary files  console=${log_to_console}
# Get and check vDU and vCU active alarms
    Log  ${dots_prefix_blue}Get and check active alarms (vDU, VCU)  console=${log_to_console}
    ${vcu_active_alarms}  ${vdu_active_alarms}=  Get All Active Alarms
    ${vdu_active_alarms_result}=  Check Active Alarms  allowed_alarms=${VDU_ALLOWED_ALARMS}  active_alarms=${vdu_active_alarms}
    ...  source=vDU  log_prefix=${info_prefix}  log_to_console=${log_to_console}
    Log  ${info_prefix}All vDU active alarms have been checked  console=${log_to_console}
    ${vcu_active_alarms_result}=  Check Active Alarms  allowed_alarms=${VCU_ALLOWED_ALARMS}  active_alarms=${vcu_active_alarms}
    ...  source=vCU  log_prefix=${info_prefix}  log_to_console=${log_to_console}
    Log  ${info_prefix}All vCU active alarms have been checked  console=${log_to_console}
    Log  ${ok_prefix_blue}Get and check active alarms (vDU, VCU)  console=${log_to_console}
# Get and check historical vDU and vCU alarms
    Log  ${dots_prefix_blue}Get and check historical alarms (vDU, VCU)  console=${log_to_console}
    ${vcu_historical_alarms}  ${vDU_historical_alarms}=  Get All Actual Historical Alarms
    Remove Values From List  ${vcu_historical_alarms}  @{VCU_SETUP_HISTORICAL_ALARMS}
    Log  ${vcu_historical_alarms}
    Remove Values From List  ${vdu_historical_alarms}  @{VDU_SETUP_HISTORICAL_ALARMS}
    Log  ${vdu_historical_alarms}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{ADDITIONAL_COMMON_HISTORICAL_VDU_ALLOWED_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{ADDITIONAL_COMMON_HISTORICAL_VCU_ALLOWED_ALARMS}
    ${vdu_hist_alarms_result}=  Check Active Alarms  allowed_alarms=${VDU_HISTORICAL_ALLOWED_ALARMS}  active_alarms=${vdu_historical_alarms}
    ...  source=vDU  log_prefix=${info_prefix}  log_to_console=${log_to_console}
    Log  ${info_prefix}All vDU historical alarms have been checked  console=${log_to_console}
    ${vcu_hist_alarms_result}=  Check Active Alarms  allowed_alarms=${VCU_HISTORICAL_ALLOWED_ALARMS}  active_alarms=${vcu_historical_alarms}
    ...  source=vCU  log_prefix=${info_prefix}  log_to_console=${log_to_console}
    ${active_hist_alarms_result}=  Create List  ${vdu_active_alarms_result}  ${vcu_active_alarms_result}
    ...  ${vdu_hist_alarms_result}  ${vcu_hist_alarms_result}
    Log  ${info_prefix}All vCU historical alarms have been checked  console=${log_to_console}
    Log  ${ok_prefix_blue}Get and check historical alarms (vDU, VCU)  console=${log_to_console}
    ${test_result}=  Set Variable If  '${tc_status}'=='PASS' and not ('${False}' in ${active_hist_alarms_result})
    ...  ${passed_result}  ${failed_result}
    IF  '${tc_status}'=='PASS' and '${get_logs}'=='${False}' and not ('${False}' in ${active_hist_alarms_result})
      Log  ${info_prefix}Test result (run ${run_index}) ${test_result}  console=${log_to_console}
      Log  ${info_prefix}No snapshots or logs will be collected (vDU, vCU, FHGW)  console=${log_to_console}
    ELSE
# Get vDU and vCU snapshot
      Log  ${info_prefix}Test case (run ${run_index}) ${test_result}  console=${log_to_console}
      Log  ${dots_prefix_blue}Get vDU and vCU logs  console=${log_to_console}
      Log  ${info_prefix}vDU snapshot is collected now  console=${log_to_console}
      vDU Collect Snapshot  logs_dir_path=${logs_dir_path}
      Log  ${info_prefix}vDU snapshot has been collected  console=${log_to_console}
      Log  ${info_prefix}vCU snapshot is collected now  console=${log_to_console}
      vCU Collect Snapshot  logs_dir_path=${logs_dir_path}
      Log  ${info_prefix}vCU snapshot has been collected  console=${log_to_console}
# Get FHGWs snapshots
      ${fhgw_connection}=  Get FHGWs Connection Status From Init File
      IF  ${fhgw_connection}
        Log  ${info_prefix}FHGW snapshot is collected now  console=${log_to_console}
        Run Keyword And Ignore Error  FHGW Collect Snapshot  logs_dir_path=${logs_dir_path}
      END
# Get vDU and vCU pods logs
      Log  ${info_prefix}vDU container logs from all pods are collected now  console=${log_to_console}
      vDU Get Container Logs On All Pods  logs_dir_path=${logs_dir_path}
      Log  ${info_prefix}vDU container logs from all pods have been collected  console=${log_to_console}
      Log  ${info_prefix}vCU container logs from all pods are collected now  console=${log_to_console}
      vCU Get Container Logs On All Pods  logs_dir_path=${logs_dir_path}
      Log  ${info_prefix}vCU container logs from all pods have been collected  console=${log_to_console}
      Log  ${ok_prefix_blue}Get vDU and vCU logs  console=${log_to_console}
    END
    Log  ${done_prefix_blue}Test Case Teardown: AiC test teardown\n  console=${log_to_console}

Sharing Suite Teardown
    [Arguments]  ${cbts_get_logs}=${True}  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Teardown section for test suite (sharing CBTS-SBTS).
    ...
    ...  ${cbts_get_logs} argument settings:
    ...  ${cbts_get_logs}=${False} - logs are not collected, but only if the test is successful
    ...                         and there are no unexpected alarms
    ...  ${cbts_get_logs}=${True} - logs are always collected
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cbts_get_logs          |  No  | Collect CBTS logs or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where logs files should be stored.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Suite Teardown
    ...  get_logs=${cbts_get_logs}
    ...  log_to_console=${log_to_console}
    SBTS Suite Teardown
    ...  logs_dir_path=${logs_dir_path}
    ...  log_to_console=${log_to_console}

Sharing Test Teardown
    [Arguments]  ${run_index}=1  ${cbts_get_logs}=${False}  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
    ...  ${test_case_syslog}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Teardown section for test case (sharing CBTS-SBTS).
    ...
    ...  Usage:
    ...  ${cbts_get_logs}=${False} - logs are not collected, but only if the test is successful
    ...                         and there are no unexpected alarms
    ...  ${cbts_get_logs}=${True} - logs are always collected
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | run_index              |  No  | Number of test execution.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_get_logs          |  No  | Collect CBTS logs or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where logs files should be stored.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | test_case_syslog       |  No  | Collect SBTS syslog file separately for each test or not.                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${cbts_get_logs}
    ...  log_to_console=${log_to_console}
    SBTS Test Teardown
    ...  logs_dir_path=${logs_dir_path}
    ...  run_index=${run_index}
    ...  test_case_syslog=${test_case_syslog}
    ...  log_to_console=${log_to_console}

Setup Host Variables
    [Documentation]
    ...  Description:
    ...  Keyword sets test suite global variables.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${host_parameters}=  Get Host Parameters From Init File
    Set Suite Variable  ${UTE_SSH_IP}  ${host_parameters['ip_addr']}
    Set Suite Variable  ${UTE_SSH_USER_NAME}  ${host_parameters['username']}
    Set Suite Variable  ${UTE_SSH_PASSWORD}  ${host_parameters['password']}

#Alarm section
Get All Active Alarms
    [Arguments]  ${vcu_login}=True  ${vdu_login}=True  ${vdu_connection}=default  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets active alarms from all vDU and all vCU (including faults from BTS and alarms from RCP).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_login              |  No  | vCU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Active alarm list from all vDU and all vCU.
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${gnb_numbers}=  Get Gnb Count From Init File
    ${vcu_active_alarms}=  Create List
    ${vdu_active_alarms}=  Create List
    FOR  ${gnb_index}  IN RANGE  ${gnb_numbers}
      ${vcu_alarms}=  vCU Get Active Alarms  vcu_login=${vcu_login}
      ...  gnb_index=${gnb_index}  vcu_connection=${vcu_connection}
      Append to List  ${vcu_active_alarms}  @{vcu_alarms}
      ${vdu_alarms}=  vDU Get All Active Alarms  vdu_login=${vdu_login}
      ...  gnb_index=${gnb_index}  vdu_connection=${vdu_connection}
      Append to List  ${vdu_active_alarms}  @{vdu_alarms}
    END
    [Return]  ${vcu_active_alarms}  ${vdu_active_alarms}

vCU Get Active Alarms
    [Arguments]  ${vcu_login}=True  ${gnb_index}=0  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets active alarms from vCU (including faults from BTS and alarms from RCP).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_login              |  No  | vCU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Active alarm list from vCU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vcu_login}
    ...  vCU Rest Login  gnb_index=${gnb_index}  vcu_connection=${vcu_connection}
     ${active_alarm_list}=  cu.Get Active Alarms  connection=${vcu_connection}  raw=True
     ${alarms_count}=  Get Length  item=${active_alarm_list['alarms']}
     Should Be Equal As Integers  first=${alarms_count}  second=${active_alarm_list["total"]}
     ...  msg=There should be ${active_alarm_list["total"]} active alarms, but actually got ${alarms_count}
     [Return]  ${active_alarm_list["alarms"]}
     [Teardown]  Run Keyword If  ${vcu_login}
     ...  Run Keyword And Ignore Error  vCU Rest Logout  vcu_connection=${vcu_connection}

vDU Get All Active Alarms
    [Arguments]  ${vdu_login}=True  ${gnb_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets active alarms from all vDU (including faults from BTS and alarms from RCP).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Active alarm list from all vDU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_count}=  Get vDU Count From Init File  gnb_index=${gnb_index}
    ${vdu_active_alarms}=  Create List
    FOR  ${vdu_index}  IN RANGE  ${vdu_count}
      ${active_alarms}=  vDU Get Active Alarms  vdu_login=${vdu_login}  gnb_index=${gnb_index}
      ...  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
      Append to List  ${vdu_active_alarms}  @{active_alarms}
    END
    [Return]  ${vdu_active_alarms}

vDU Get Active Alarms
    [Arguments]  ${vdu_login}=True  ${gnb_index}=0  ${vdu_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets active alarms form vDU (including faults from BTS and alarms from RCP).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Active alarm list from vDU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  gnb_index=${gnb_index}  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
    ${active_alarms}=  vdu.Vdu Get Active Alarms  vdu_connection=${vdu_connection}  raw=True
    ${alarms_count}=  Get Length  item=${active_alarms["alarms"]}
    Should Be Equal As Integers  first=${alarms_count}  second=${active_alarms["total"]}
    ...  msg=There should be ${active_alarms["total"]} active alarms, but actually got ${alarms_count}
    [Return]  ${active_alarms["alarms"]}
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Get All Actual Historical Alarms
    [Arguments]  ${vcu_login}=True  ${vdu_login}=True  ${vdu_connection}=default  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets historical alarms from all vDUs and all vCUs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_login              |  No  | vCU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Historical alarm list from all vDU and all vCU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${gnb_numbers}=  Get Gnb Count From Init File
    ${vcu_historical_alarms}=  Create List
    ${vdu_historical_alarms}=  Create List
    FOR  ${gnb_index}  IN RANGE  ${gnb_numbers}
      ${vcu_alarms}=  vCU Get Actual Historical Alarms  vcu_login=${vcu_login}
      ...  gnb_index=${gnb_index}  vcu_connection=${vcu_connection}
      Append to List  ${vcu_historical_alarms}  @{vcu_alarms}
      ${vdu_alarms}=  vDU Get All Actual Historical Alarms  vdu_login=${vdu_login}
      ...  gnb_index=${gnb_index}  vdu_connection=${vdu_connection}
      Append to List  ${vdu_historical_alarms}  @{vdu_alarms}
    END
    [Return]  ${vcu_historical_alarms}  ${vdu_historical_alarms}

vCU Get Actual Historical Alarms
    [Arguments]  ${vcu_login}=True  ${gnb_index}=0  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets historical alarms from vCU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_login              |  No  | vCU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Historical alarms list from vCU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vcu_login}
    ...  vCU Rest Login  gnb_index=${gnb_index}  vcu_connection=${vcu_connection}
     ${historical_alarms}=  cu.Get Historical Alarms  connection=${vcu_connection}  raw=True
     ${alarms_count}=  Get Length  item=${historical_alarms['alarms']}
     Should Be Equal As Integers  first=${alarms_count}  second=${historical_alarms["total"]}
     ...  msg=There should be ${historical_alarms["total"]} historical alarms, but actually got ${alarms_count}
     [Return]  ${historical_alarms["alarms"]}
     [Teardown]  Run Keyword If  ${vcu_login}
     ...  Run Keyword And Ignore Error  vCU Rest Logout  vcu_connection=${vcu_connection}

vDU Get All Actual Historical Alarms
    [Arguments]  ${vdu_login}=True  ${gnb_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets historical alarms from all vDU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Historical alarm list from all vDU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_count}=  Get vDU Count From Init File  gnb_index=${gnb_index}
    ${vdu_historical_alarms}=  Create List
    FOR  ${vdu_index}  IN RANGE  ${vdu_count}
      ${historical_alarms}=  vDU Get Actual Historical Alarms  vdu_login=${vdu_login}  gnb_index=${gnb_index}
      ...  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
      Append to List  ${vdu_historical_alarms}  @{historical_alarms}
    END
    [Return]  ${vdu_historical_alarms}

vDU Get Actual Historical Alarms
    [Arguments]  ${vdu_login}=True  ${gnb_index}=0  ${vdu_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets historical alarms form vDU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Historical alarms list from vDU.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  gnb_index=${gnb_index}  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
    ${historical_alarms}=  vdu.Vdu Get Historical Alarms  vdu_connection=${vdu_connection}  raw=True
    ${alarms_count}=  Get Length  item=${historical_alarms["alarms"]}
    Should Be Equal As Integers  first=${alarms_count}  second=${historical_alarms["total"]}
    ...  msg=There should be ${historical_alarms["total"]} historical alarms, but actually got ${alarms_count}
    [Return]  ${historical_alarms["alarms"]}
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Check Active Alarms
    [Arguments]  ${allowed_alarms}  ${active_alarms}  ${source}=All  ${log_prefix}=${EMPTY}  ${log_to_console}=False
    [Documentation]
    ...  Description:
    ...  Keyword checks the active and historical alarms if they are on the list of allowed alarms.
    ...  The 'faultId' and 'severity' fields are taken into account.
    ...  Example:
    ...  @{allowed_alarms}=
    ...                      faultId=4592, severity=Warning
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | active_alarms          | Yes  | List of active alarms.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | source                 |  No  | Source of alarms (All, vDU or vCU).                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${active_alarms_count}=  Get Length  item=${active_alarms}
    Log  ${log_prefix}${source} alarms count is ${active_alarms_count}  console=${log_to_console}
    ${active_alarm_result}=  Set Variable  True
    Return From Keyword If  ${active_alarms_count}==0  ${active_alarm_result}
    ${allowed_active_alarms}=  Create List
    ${unexpected_active_alarms}=  Create List
    Log List  ${active_alarms}
    ${allowed_alarm_list}=  Convert Allowed Alarms List  allowed_alarms=${allowed_alarms}
    FOR  ${active_alarm}  IN  @{active_alarms}
      ${allowed_alarm_status}=  Check Allowed Alarm
      ...  allowed_alarms=${allowed_alarm_list}  actual_alarm=${active_alarm}
      Run Keyword If  ${allowed_alarm_status}
      ...  Append To List  ${allowed_active_alarms}
      ...  fault_id='${active_alarm['faultId']}', fault_name='${active_alarm['faultName']}', faultSeverity='${active_alarm['severity']}'
      ...  ELSE
      ...  Append To List  ${unexpected_active_alarms}
      ...  fault_id='${active_alarm['faultId']}', fault_name='${active_alarm['faultName']}', faultSeverity='${active_alarm['severity']}'
    END
#ALLOW ACTIVE ALARMS LOG
    ${allowed_active_alarms_count}=  Get Length  item=${allowed_active_alarms}
    Log  ${log_prefix}${source} allowed alarms count: ${allowed_active_alarms_count}  console=${log_to_console}
    FOR  ${allowed_active_alarm}  IN  ${allowed_active_alarms}
      Log  ${log_prefix}${source} allowed alarm: ${allowed_active_alarm}
    END
#UNEXPECTED ACTIVE ALARMS LOG
    ${unexpected_active_alarms_count}=  Get Length  item=${unexpected_active_alarms}
    ${unexpected_active_alarms_string}=  Set Variable
    ...  ${log_prefix}${source} unexpected alarms count: ${unexpected_active_alarms_count}
    FOR  ${unexpected_active_alarm}  IN  @{unexpected_active_alarms}
      ${unexpected_active_alarms_string}=  Catenate  ${unexpected_active_alarms_string}
      ...  \n${log_prefix}${source} unexpected alarms: ${unexpected_active_alarm}
    END
    Log  ${log_prefix}${unexpected_active_alarms_string}
    ${active_alarm_result}=  Set Variable If  ${unexpected_active_alarms_count}>0  False  True
    Run Keyword If  ${unexpected_active_alarms_count}>0  Fail  ${unexpected_active_alarms_string}
    [Return]  ${active_alarm_result}

Check Allowed Alarm
    [Arguments]  ${allowed_alarms}  ${actual_alarm}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the active or historical alarm is on the list of allowed alarms.
    ...  Keyword returns information whether the active or historical alarm is on the list of allowed alarms (True, False).
    ...  The 'faultId' and 'severity' fields are taken into account.
    ...  Allowed alarms should have the format of the list of the dictionaries of parameters.
    ...  Example:
    ...  [{'faultId': '4592', 'severity': 'Warning'}, {'faultId': '61524', 'severity': 'Minor'}]
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | actual_alarm           | Yes  | List of active or historical alarm.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${allowed_alarm_faultid_status}=  Set Variable  ${False}
    ${allowed_alarm_severity_status}=  Set Variable  ${False}
    FOR  ${allowed_alarm}  IN  @{allowed_alarms}
      ${allowed_alarm_faultid_status}=  Run Keyword And Return Status
      ...  Should Match  ${actual_alarm['faultId']}  ${allowed_alarm['faultId']}
      ${allowed_alarm_severity_status}=  Run Keyword And Return Status
      ...  Should Match Regexp  ${actual_alarm['severity']}  (?i)${allowed_alarm['severity']}
      Exit For Loop If  ${allowed_alarm_faultid_status}
    END
    ${allowed_alarm_status_list}=  Create list  ${allowed_alarm_faultid_status}  ${allowed_alarm_severity_status}
    ${allowed_alarm_status}=   Run Keyword And Return Status
    ...  List Should Not Contain Value  ${allowed_alarm_status_list}  ${False}
    [Return]  ${allowed_alarm_status}

vDU Get Alarm Status
    [Arguments]  ${fault_id}  ${alarming_object_list}=@{EMPTY}  ${alarm_severity_list}=@{EMPTY}
    ...  ${custom_field_search}=${EMPTY}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU alarm status.
    ...  If the alarm exists, the status is "True", if the alarm does not exist, the status is "False".
    ...  Active alarm is defined by fault id and optionally alarm object or/and alarm severity.
    ...  Additionaly custom_field_search can be defined, then status is true when both alarm exists and custom_field_search
    ...  is found in existing alarm.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | custom_field_search    |  No  | checks desired fault's custom field content. Content is validated as regex |
    ...  |                        |      | default value ${EMPTY}                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  custom_field_content example:
    ...  custom_field_search=alarm_name=STATION-/d+ -> means -> search for regex "STATION-/d+" in field "alarm_name" under "fault_id"
    ...
    ...  Return:
    ...  vDU alarm status (alarm exist-True or alarm not exist-False).
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_status}=  Set Variable  False
    ${active_alarms}=  Run Keyword If  ${alarming_object_list}==@{EMPTY} and ${alarm_severity_list}==@{EMPTY}
    ...  vdu.Vdu Get Active Alarms
    ...  vdu_connection=${vdu_connection}  raw=True
    ...  ELSE IF  ${alarming_object_list}==@{EMPTY}
    ...  vdu.Vdu Get Active Alarms  raw=True
    ...  filter_by_severity=${alarm_severity_list}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  ${alarm_severity_list}==@{EMPTY}
    ...  vdu.Vdu Get Active Alarms  raw=True
    ...  filter_by_alarming_object=${alarming_object_list}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE
    ...  vdu.Vdu Get Active Alarms  raw=True
    ...  filter_by_severity=${alarm_severity_list}
    ...  filter_by_alarming_object=${alarming_object_list}
    ...  vdu_connection=${vdu_connection}
    FOR  ${active_alarm}  IN  @{active_alarms['alarms']}
      ${alarm_status}=  Set Variable If  ${active_alarm['faultId']}==${fault_id}
      ...  True  False
      IF  ${alarm_status} and "${custom_field_search}"!="${EMPTY}"
        ${field_name}  ${field_content}=  Split String  string=${custom_field_search}  separator==  max_split=1
        ${custom_field_status}=  Evaluate  re.search(r'${field_content}', '''${active_alarm['${field_name}']}''') is not None  re
      ELSE
        ${custom_field_status}=  Set Variable  ${TRUE}
      END
      ${alarm_status}=  Evaluate  ${alarm_status} and ${custom_field_status}
      Exit For Loop If  ${alarm_status}
    END
    [Return]  ${alarm_status}

vDU Alarm Should Be Active
    [Arguments]  ${fault_id}  ${alarming_object_list}=@{EMPTY}  ${alarm_severity_list}=@{EMPTY}
    ...  ${custom_field_search}=${EMPTY}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if vDU alarm given by fault id (optionally alarm object or/and alarm severity) is active.
    ...  Additionaly custom_field_search can be defined to verify active fault_id's content
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | custom_field_search    |  No  | checks desired fault's custom field content. Content is validated as regex |
    ...  |                        |      | default value ${EMPTY}                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  custom_field_content example:
    ...  custom_field_search=alarm_name=STATION-/d+ -> means -> search for regex "STATION-/d+" in field "alarm_name" under "fault_id"
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_status}=  vDU Get Alarm Status
    ...  fault_id=${fault_id}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  alarming_object_list=${alarming_object_list}
    ...  custom_field_search=${custom_field_search}
    ...  vdu_connection=${vdu_connection}
    Should Be True  ${alarm_status}

vDU Assert Alarm Active
    [Arguments]  ${fault_id}  ${alarming_object_list}=@{EMPTY}  ${alarm_severity_list}=@{EMPTY}  ${custom_field_search}=${EMPTY}
    ...  ${vdu_login}=${False}  ${timeout}=30  ${gnb_index}=0  ${vdu_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waiting for vDU active alarm.
    ...  Active alarm is defined by fault id and optionally alarm object or/and alarm severity.
    ...  Additionaly custom_field_search can be defined to verify active fault_id's content
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | custom_field_search    |  No  | checks desired fault's custom field content. Content is validated as regex |
    ...  |                        |      | default value ${EMPTY}                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected active alarm.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  custom_field_content example:
    ...  custom_field_search=alarm_name=STATION-/d+ -> means -> search for regex "STATION-/d+" in field "alarm_name" under "fault_id"
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  gnb_index=${gnb_index}  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
    ${fault_id_status}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  10
    ...  vDU Alarm Should Be Active
    ...  fault_id=${fault_id}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  alarming_object_list=${alarming_object_list}
    ...  custom_field_search=${custom_field_search}
    ...  vdu_connection=${vdu_connection}
    ${log_parameters}=  Set Variable
    ...  faultId:${faultId}, alarming_object:${alarming_object_list}, severity:${alarm_severity_list}, custom_field_search:${custom_field_search}
    Run Keyword If  '${fault_id_status}'=='False'
    ...  Fail  The expected alarm (${log_parameters}) is not active !!!
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

vDU Assert Object Alarm Active
    [Arguments]  ${fault_id}  ${alarming_object_list}  ${alarm_severity_list}=@{EMPTY}  ${vdu_login}=True
    ...  ${timeout}=30  ${gnb_index}=0  ${vdu_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waiting for vDU active alarms.
    ...  Active alarms are defined by fault id and alarm objects.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected active alarm.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  gnb_index=${gnb_index}  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
    ${alarm_severity_list}=  Create List  @{alarm_severity_list}
    FOR  ${alarming_object}  IN  @{alarming_object_list}
      ${ant_list}=  Create List  ${alarming_object}
      Run Keyword And Continue On Failure
      ...  vDU Assert Alarm Active
      ...  fault_id=${fault_id}
      ...  alarm_severity_list=${alarm_severity_list}
      ...  alarming_object_list=${ant_list}
      ...  vdu_login=False
      ...  timeout=${timeout}
      ...  vdu_connection=${vdu_connection}
    END
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

vDU Alarm Should Be Inactive
    [Arguments]  ${fault_id}  ${alarming_object_list}=@{EMPTY}  ${alarm_severity_list}=@{EMPTY}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if vDU alarm given by fault id (optionally alarm object or/and alarm severity) is inactive.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_status}=  vDU Get Alarm Status
    ...  fault_id=${fault_id}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  alarming_object_list=${alarming_object_list}
    ...  vdu_connection=${vdu_connection}
    Should Not Be True  ${alarm_status}

vDU Assert Alarm Inactive
    [Arguments]  ${fault_id}  ${alarming_object_list}=@{EMPTY}  ${alarm_severity_list}=@{EMPTY}
    ...  ${vdu_login}=${False}  ${timeout}=30  ${gnb_index}=0  ${vdu_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waiting for vDU inactive alarm.
    ...  Active alarm is defined by fault id and optionally alarm object or/and alarm severity.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  |  Waiting time for active alarm disappeared.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  gnb_index=${gnb_index}  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
    ${fault_id_status}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  10
    ...  vDU Alarm Should Be Inactive
    ...  fault_id=${fault_id}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  alarming_object_list=${alarming_object_list}
    ...  vdu_connection=${vdu_connection}
    Run Keyword If  '${fault_id_status}'=='False'
    ...  Fail  The unexpected alarm (faultId:${faultId}, alarming_object:${alarming_object_list}, severity: ${alarm_severity_list}) is active !!!
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

vDU Assert Object Alarm Inactive
    [Arguments]  ${fault_id}  ${alarming_object_list}  ${alarm_severity_list}=@{EMPTY}  ${vdu_login}=True
    ...  ${timeout}=30  ${gnb_index}=0  ${vdu_index}=0  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waiting for vDU inactive alarms.
    ...  Inactive alarms are defined by fault id and alarm objects.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected active alarm.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  gnb_index=${gnb_index}  vdu_index=${vdu_index}  vdu_connection=${vdu_connection}
    ${alarm_severity_list}=  Create List  @{alarm_severity_list}
    FOR  ${alarming_object}  IN  @{alarming_object_list}
      ${ant_list}=  Create List  ${alarming_object}
      Run Keyword And Continue On Failure
      ...  vDU Assert Alarm Inactive
      ...  fault_id=${fault_id}
      ...  alarm_severity_list=${alarm_severity_list}
      ...  alarming_object_list=${ant_list}
      ...  vdu_login=False
      ...  timeout=${timeout}
      ...  vdu_connection=${vdu_connection}
    END
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

vDU Get Active Alarm Parameters
    [Arguments]  ${fault_id}  ${alarming_object_list}=@{EMPTY}
    ...  ${alarm_severity_list}=@{EMPTY}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU alarm parameters.
    ...  Active alarm is defined by fault id and optionally alarm object or/and alarm severity.
    ...  The parameters in the form of a dictionary are saved in a list.
    ...  If there are more alarms with a given fault_id, the parameters of each of them are in the parameter list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fault_id               | Yes  | Active alarm fault id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarming_object_list   |  No  | Filtering by alarming objects.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alarm_severity_list    |  No  | Filtering severity values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU alarm(s) parameters.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_parameters_list}=  Create List
    ${active_alarms}=  Run Keyword If  ${alarming_object_list}==@{EMPTY} and ${alarm_severity_list}==@{EMPTY}
    ...  vdu.Vdu Get Active Alarms
    ...  vdu_connection=${vdu_connection}  raw=True
    ...  ELSE IF  ${alarming_object_list}==@{EMPTY}
    ...  vdu.Vdu Get Active Alarms  raw=True
    ...  filter_by_severity=${alarm_severity_list}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  ${alarm_severity_list}==@{EMPTY}
    ...  vdu.Vdu Get Active Alarms  raw=True
    ...  filter_by_alarming_object=${alarming_object_list}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE
    ...  vdu.Vdu Get Active Alarms  raw=True
    ...  filter_by_severity=${alarm_severity_list}
    ...  filter_by_alarming_object=${alarming_object_list}
    ...  vdu_connection=${vdu_connection}
    FOR  ${active_alarm}  IN  @{active_alarms['alarms']}
      Run Keyword If  ${active_alarm['faultId']}==${fault_id}
      ...  Append To List  ${alarm_parameters_list}  ${active_alarm}
    END
    [Return]  ${alarm_parameters_list}

Convert Allowed Alarms List
    [Arguments]  ${allowed_alarms}
    [Documentation]
    ...  Description:
    ...  Keyword converts the "admin" format of allowed alarms
    ...  to a list format in the form of a dictionary of allowed alarm parameters.
    ...  After creating the lists, each alarm is defined as a dictionary of parameters ("faultId" and "severity").
    ...  Example:
    ...  Input format:
    ...  ['faultId=4592, severity=Warning', 'faultId=61524, severity=Minor']
    ...  Output format:
    ...  [{'faultId': '4592', 'severity': 'Warning'}, {'faultId': '61524', 'severity': 'Minor'}]
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms (input format).                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${allowed_alarms_list}=  Create List
    FOR  ${alarm}  IN  @{allowed_alarms}
      ${alarm_parameters_dict}=  Create Dictionary
      ${alarm_parameters_string}=  Remove String  ${alarm}  ,
      ${alarm_parameters_list}=  Split String  string=${alarm_parameters_string}
      FOR  ${alarm_parameter}  IN  @{alarm_parameters_list}
        ${parameter_key}=  Fetch From Left  string=${alarm_parameter}  marker==
        ${parameter_value}=  Fetch From Right  string=${alarm_parameter}  marker==
        Set To Dictionary  ${alarm_parameters_dict}  ${parameter_key}=${parameter_value}
      END
      Append To List  ${allowed_alarms_list}  ${alarm_parameters_dict}
    END
    [Return]  ${allowed_alarms_list}

vDU Check Unit Power Reset Alarm
    [Arguments]  ${log_prefix}=${EMPTY}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword checks the occurrence of Unit Power Reset alarm (fault_id=4589).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_prefix             |  No  | Set info log prefix to message or not.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${alarm_severity_list}=  Create List  warning
    Log  ${log_prefix}Waiting for alarm activation (fault id=4589) ...  console=${log_to_console}
    vDU Assert Alarm Active
    ...  fault_id=4589
    ...  alarm_severity_list=${alarm_severity_list}
    ...  timeout=30
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}Alarm (fault id=4589) is active now  console=${log_to_console}
    Log  ${log_prefix}Waiting for alarm deactivation (fault id=4589) ...  console=${log_to_console}
    vDU Assert Alarm Inactive
    ...  fault_id=4589
    ...  alarm_severity_list=${alarm_severity_list}
    ...  timeout=60
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}Alarm (fault id=4589) is inactive now  console=${log_to_console}

vDU Check BTS Reset Cause Alarm
    [Arguments]  ${activation_timeout}  ${cancellation_timeout}  ${info_pattern}=${EMPTY}
    ...  ${vdu_connection}=${VDU_CONNECTION_DEFAULT}  ${log_prefix}=${EMPTY}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether an alarm (FID=4592) has occurred.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | activation_timeout     | Yes  | Wait until alarm 4592 is active.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cancellation_timeout   | Yes  | Wait until alarm 4592 is inactive.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | info_pattern           | Yes  | Additional information about the fault reason.                             |
    ...  |                        |      | Pattern matching is similar as matching files in a shell: `*`, `?', etc.   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

# vDU Assert Alarm Active (FID=4592)
    Log  ${log_prefix}Waiting for alarm activation (FID=4592) ...  console=${log_to_console}
    ${alarm_severity}=  Set Variable If  ${cancellation_timeout} > 30  minor  warning
    ${alarm_severity_list}=  Create List  ${alarm_severity}
    vDU Assert Alarm Active
    ...  fault_id=4592
    ...  alarm_severity_list=${alarm_severity_list}
    ...  vdu_login=${False}
    ...  timeout=${activation_timeout}
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}Alarm (FID=4592) is active now  console=${log_to_console}
    ${alarm_parameters_list}=  vDU Get Active Alarm Parameters
    ...  fault_id=4592
    ...  vdu_connection=${vdu_connection}
    ${alarm_info_list}=  Create List
    FOR  ${alarm_parameters}  IN  @{alarm_parameters_list}
      Log  ${log_prefix}Alarm (FID=4592) additional information and fault signature info:  console=${log_to_console}
      Log  \t${SPACE * 7}Additional info: ${alarm_parameters['additionalInfo']}  console=${log_to_console}
      Append To List  ${alarm_info_list}  ${alarm_parameters['additionalInfo']}
    END
    Sleep  2s  reason=Additional time to start alarm deactivation
# vDU Assert Alarm Inactive (FID=4592)
    Log  ${log_prefix}Fault 4592 cancellation timer: ${cancellation_timeout}s  console=${log_to_console}
    Log  ${log_prefix}Waiting for alarm deactivation (fault id=4592) ...  console=${log_to_console}
    vDU Assert Alarm Inactive
    ...  fault_id=4592
    ...  alarm_severity_list=${alarm_severity_list}
    ...  vdu_login=${False}
    ...  timeout=${cancellation_timeout}
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}Alarm (FID=4592) is inactive now  console=${log_to_console}
    Run Keyword And Continue On Failure
    ...  Should Contain Match  list=${alarm_info_list}  pattern=${info_pattern}
    ...  msg=Unexpected error reason. Please check logs !
