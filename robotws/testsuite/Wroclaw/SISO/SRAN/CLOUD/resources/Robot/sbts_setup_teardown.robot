*** Settings ***
Documentation  SBTS setup and teardown actions
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    OperatingSystem
Library    BuiltIn
Library    String
Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_admin_infomodel
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Robot/common_kw.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/swconfig.robot
Resource    ../../../resources/Robot/faults.robot
Resource    ../../../resources/Robot/logging.robot
Resource    ../../../resources/bts_scfc.robot
Resource    ../sbts_variables.robot

*** Keywords ***
SBTS Suite Setup
    [Arguments]  ${scfc_file_path}  ${swconfig_file_path}=${SWCONFIG_FILE_PATH}
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${set_prefix}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Setup section for test suite.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the default scfc file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | swconfig_file_path     | Yes  | Path to the default swconfig file.                                         |
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

    Set Message Colors
    Set Log Prefix  set_prefix=${set_prefix}
    Log  \n${start_prefix_blue}Test Suite Setup: SBTS suite setup  console=${log_to_console}
    Set Library Search Order  ute_admin_infomodel  admin
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error  Teardown Enb Fsm Access
    Run Keyword And Ignore Error  Teardown All Aliases For Infomodel
#eNB Setup Section
    Log  ${dots_prefix_blue}Setup process (enb, admin)  console=${log_to_console}
    Setup Enb Fsm Access  log_path=${logs_dir_path}
    admin.Setup Admin  update_interval=100  admin_api_log_dir=${logs_dir_path}
    Log  ${ok_prefix_blue}Setup process (enb, admin)  console=${log_to_console}
#SCFC Variables Section
    Log  ${dots_prefix_blue}Setting up variables  console=${log_to_console}
    ${number_of_smod_unit}=  SCFC Get SMOD Count  scfc_file_path=${scfc_file_path}
    Set Suite Variable  ${NUMBER_OF_SMOD_UNIT}  ${number_of_smod_unit}
    ${mrbts_id}=  SCFC Get MRBTS ID  scfc_file_path=${scfc_file_path}
    Set Suite Variable  ${MRBTS_ID}  ${mrbts_id}
    Log  ${ok_prefix_blue}Setting up variables  console=${log_to_console}
#Swconfig Update Section
    Log  ${dots_prefix_blue}Preparation of swconfig file for BTS  console=${log_to_console}
    Add Flags To Swconfig File  swconfig_file=${swconfig_file_path}  swconfig_flag_list=${SWCONFIG_FLAGS}
    ...  log_prefix=${info_prefix}
    Put Enb Swconfig File  source=${swconfig_file_path}
    Run Keyword If  ${number_of_smod_unit}==2
    ...  Put Swconfig File From Remote Host  swconfig_file_path=${swconfig_file_path}
    Get Enb Swconfig File  destination=${logs_dir_path}/
    Log  ${ok_prefix_blue}Preparation of swconfig file for BTS  console=${log_to_console}
#Syslog Setup Section
    Log  ${dots_prefix_blue}Setup and start syslog (enb)  console=${log_to_console}
    Start Enb Syslog  logs_dir_path=${logs_dir_path}
    ${savepoint_enb}=  Capture Enb Syslog Savepoint
    Set Suite Variable  ${SAVEPOINT_ENB}  ${savepoint_enb}
    Log  ${ok_prefix_blue}Setup and start syslog (enb)  console=${log_to_console}
#InfoModel Setup Section
    Log  ${dots_prefix_blue}Setup and connect to infomodel  console=${log_to_console}
    Setup Infomodel  address=${ENB_IP_ADDR}  port=443  use_ssl=True
    Connect Infomodel  timeout=180
    Log  ${ok_prefix_blue}Setup and connect to infomodel  console=${log_to_console}
    Log  ${done_prefix_blue}Test Suite Setup: SBTS suite setup\n  console=${log_to_console}

SBTS Test Setup
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

    Log  \n${start_prefix_blue}Test Case Setup: SBTS test setup (run ${run_index})  console=${log_to_console}
#Check alarms
    Append To List  ${ALLOWED_ALARMS_FAULT_ID}  @{ADDITIONAL_COMMON_ALLOWED_ALARMS}
    Verify Unexpected Active Alarms  allowed_alarms=${ALLOWED_ALARMS_FAULT_ID}  log_prefix=${info_prefix}
    Log  ${done_prefix_blue}Test Case Setup: SBTS test setup\n  console=${log_to_console}

SBTS Suite Teardown
    [Arguments]  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Teardown section for test suite.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where logs files should be stored.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console        |  No  | Logs the given message to console.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Suite Teardown: SBTS suite teardown  console=${log_to_console}
    Create Directory  path=${logs_dir_path}/sbts/remaining_logs
    Create Directory  path=${logs_dir_path}/sbts/suite_teardown_logs
    Create Directory  path=${logs_dir_path}/sbts/backup_files
    Info Model Save Logs And Teardown  logs_dir_path=${logs_dir_path}/sbts/suite_teardown_logs
    Stop Enb Syslog  logs_dir_path=${logs_dir_path}/sbts/suite_teardown_logs
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error  Teardown Enb Fsm Access
    Log  ${ok_prefix_blue}Teardown all services  console=${log_to_console}
    Copy And Move Files  logs_dir_path=${logs_dir_path}
    Log  ${ok_prefix_blue}Coping and moving files  console=${log_to_console}
    Log  ${done_prefix_blue}Test Suite Teardown: SBTS suite teardown \n  console=${log_to_console}

SBTS Test Teardown
    [Arguments]  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${run_index}=1
    ...  ${test_case_syslog}=${True}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Teardown section for test case.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executions.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | test_case_syslog         |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Logs the given message to console.                                       |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Case Teardown: SBTS test teardown (run ${run_index})
    ...  console=${log_to_console}
#File and directory operations
    ${sbts_logs_dir_path}=  Set variable  ${logs_dir_path}/${TEST NAME}/sbts_test_run_${run_index}
    Create Directory  path=${sbts_logs_dir_path}
#Collect snapshot
    Log  ${dots_prefix_blue}Collect snapshot  console=${log_to_console}
    Collect Snapshot File  logs_dir_path=${sbts_logs_dir_path}
    Log  ${ok_prefix_blue}Collect snapshot  console=${log_to_console}
#Collect InfoModel logs and alarms check
    Save Infomodel Log  filename=${sbts_logs_dir_path}/IM_infomodel.ims2
    ...  timeout=180
#Check alarms
    Verify Unexpected Active Alarms  allowed_alarms=${ALLOWED_ALARMS_FAULT_ID}  log_prefix=${info_prefix}
    Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  @{ADDITIONAL_COMMON_HISTORICAL_ALLOWED_ALARMS}
    Verify Unexpected Historical Alarms  allowed_alarms=${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  log_prefix=${info_prefix}
#Setup new InfoModel log session
    Perform Reconnect InfoModel
    Log  ${ok_prefix_blue}Reconnect infomodel  console=${log_to_console}
#Collect syslog
    Log  ${dots_prefix_blue}Collect syslog file  console=${log_to_console}
    IF  ${test_case_syslog}
      ${savepoint_enb}=  Collect And Capture Enb Syslog
      ...  savepoint_enb=${SAVEPOINT_ENB}
      ...  logs_dir_path=${sbts_logs_dir_path}
    END
    Set Suite Variable  ${SAVEPOINT_ENB}  ${savepoint_enb}
    Log  ${ok_prefix_blue}Collect syslog file  console=${log_to_console}
    Log  ${done_prefix_blue}Test Case Teardown: SBTS test teardown (run ${run_index})\n
    ...  console=${log_to_console}

Copy And Move Files
    [Arguments]  ${logs_dir_path}
    [Documentation]
    ...  Description:
    ...  Keyword copies and moves log and backup files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to the logs directory.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*swconfig*        ${logs_dir_path}/sbts/backup_files/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*SCFC*            ${logs_dir_path}/sbts/backup_files/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*tshark*          ${logs_dir_path}/sbts/remaining_logs/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*admin_api*       ${logs_dir_path}/sbts/remaining_logs/
