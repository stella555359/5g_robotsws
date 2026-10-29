*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ./setup_teardown.robot
Resource    ./lte_cloud_setup_teardown.robot
Resource    ../../../resources/Robot/reporting.robot
Resource    ../../TestCases/SM/Cloud_SM_RF_Reset_From_GUI.robot
Resource    ../../TestCases/SM/Cloud_SM_Cell_Block_Unblock.robot
Resource    ../../TestCases/SM/Cloud_SM_Radio_Modules_Reset.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Delta_Recommissioning.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_Radio_Modules_Power_Reset.robot
Resource    ../../TestCases/SM/Cloud_SM_Radio_Modules_Lock_Unlock.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_vDU_Reset.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_vCU_Reset.robot
Resource    ../../TestCases/REC/Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_LTE_vDU_Reset.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_Rannic_Reset.robot
Resource    ../../TestCases/LOGS/Cloud_LOGS_Snapshot_Collection_During_Fail_Safe_Mode.robot
Resource    ../../TestCases/SWM/Cloud_SWM_Radio_unit_software_update_during_fail_safe_mode.robot

*** Keywords ***
vDU Commissioning Single Execution
    [Arguments]  ${scfc_file_path}  ${run_index}=1  ${get_logs}=${False}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_CM_vDU_Commissioning") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_CM_vDU_Commissioning
    ...  scfc_file_path=${scfc_file_path}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

vDU Commissioning Loop Execution
    [Arguments]  ${scfc_file_path}  ${run_count}=1  ${get_teardown_logs}=${False}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_CM_vDU_Commissioning") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  vDU Commissioning Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

vDU Delta Recommissioning Single Execution
    [Arguments]  ${scfc_file_path}  ${delta_file_path}  ${run_index}=1  ${get_logs}=${False}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_vDU_Delta_Recommissioning") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | delta_file_path        | Yes  | Path to the vDU delta json file.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_vDU_Delta_Recommissioning
    ...  scfc_file_path=${scfc_file_path}
    ...  delta_file_path=${delta_file_path}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

vDU Delta Recommissioning Loop Execution
    [Arguments]  ${scfc_file_path}  ${delta_file_path}  ${run_count}=1  ${get_teardown_logs}=${False}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_vDU_Delta_Recommissioning") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | delta_file_path        | Yes  | Path to the vDU delta json file.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  vDU Delta Recommissioning Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  delta_file_path=${delta_file_path}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

RMOD Lock Unlock And Check Single Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmods_sn}=@{EMPTY}  ${run_index}=1
    ...  ${get_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Radio_Modules_Lock_Unlock") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmods_sn          |  No  | List of radio module serial numbers to locked/unlocked.                    |
    ...  |                        |      | If the list is empty then all radio modules are locked/unlocked.           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_SM_Radio_Modules_Lock_Unlock
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  cbts_rmods_sn=${cbts_rmods_sn}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

RMOD Lock Unlock And Check Loop Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmods_sn}=@{EMPTY}  ${run_count}=1
    ...  ${get_teardown_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Radio_Modules_Lock_Unlock") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmods_sn          |  No  | List of radio module serial numbers to locked/unlocked.                    |
    ...  |                        |      | If the list is empty then all radio modules are locked/unlocked.           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  RMOD Lock Unlock And Check Single Execution
      ...  vdu_scfc_file_path=${vdu_scfc_file_path}
      ...  cbts_rmods_sn=${cbts_rmods_sn}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

Cell Block Unblock And Check Single Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_cells_id_list}=@{EMPTY}  ${get_kpi}=${False}
    ...  ${run_index}=1  ${get_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Cell_Block_Unblock") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_cells_id_list     |  No  | (optional) List of cell id to be blocked/unblocked.                        |
    ...  |                        |      | If the list is empty then all cells are blocked/unblocked.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi17a/kpi17b or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_SM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  cbts_cells_id_list=${cbts_cells_id_list}
    ...  get_kpi=${get_kpi}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

Cell Block Unblock And Check Loop Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_cells_id_list}=@{EMPTY}  ${get_kpi}=${False}
    ...  ${run_count}=1  ${get_teardown_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Cell_Block_Unblock") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_cells_id_list     |  No  | (optional) List of cell id to be blocked/unblocked.                        |
    ...  |                        |      | If the list is empty then all cells are blocked/unblocked.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi17a/kpi17b or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  Cell Block Unblock And Check Single Execution
      ...  vdu_scfc_file_path=${vdu_scfc_file_path}
      ...  cbts_cells_id_list=${cbts_cells_id_list}
      ...  get_kpi=${get_kpi}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

Radio Modules Reset Single Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}   ${cbts_rmod_sn_count}=0  ${get_kpi}=${False}
    ...  ${run_index}=1  ${get_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Radio_Modules_Reset") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi51a or not.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_SM_Radio_Modules_Reset
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  cbts_rmod_sn_list=${cbts_rmod_sn_list}
    ...  cbts_rmod_sn_count=${cbts_rmod_sn_count}
    ...  get_kpi=${get_kpi}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

Radio Modules Reset Loop Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}   ${cbts_rmod_sn_count}=0  ${get_kpi}=${False}
    ...  ${run_count}=1  ${get_teardown_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Radio_Modules_Reset") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi51a or not.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  Radio Modules Reset Single Execution
      ...  vdu_scfc_file_path=${vdu_scfc_file_path}
      ...  cbts_rmod_sn_list=${cbts_rmod_sn_list}
      ...  cbts_rmod_sn_count=${cbts_rmod_sn_count}
      ...  get_kpi=${get_kpi}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

RMODs Reset From GUI Single Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}  ${cbts_rmod_sn_count}=0
    ...  ${reset_timeout}=400  ${jwt_expiration_time}=120  ${run_index}=1
    ...  ${get_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Radio_Modules_Reset_Via_GUI") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | reset_timeout          |  No  | Timeout for waiting for positive reset procedure result.                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | jwt_expiration_time    |  No  | Expiration time on or after which the JSON Web Token                       |
    ...  |                        |      | must not be accepted for processing (minutes).                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_SM_Radio_Modules_Reset_Via_GUI
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  cbts_rmod_sn_list=${cbts_rmod_sn_list}
    ...  cbts_rmod_sn_count=${cbts_rmod_sn_count}
    ...  reset_timeout=${reset_timeout}
    ...  jwt_expiration_time=${jwt_expiration_time}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

RMODs Reset From GUI Loop Execution
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}  ${cbts_rmod_sn_count}=0
    ...  ${reset_timeout}=400  ${jwt_expiration_time}=120  ${run_count}=1
    ...  ${get_teardown_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SM_Radio_Modules_Reset_Via_GUI") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | reset_timeout          |  No  | Timeout for waiting for positive reset procedure result.                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | jwt_expiration_time    |  No  | Expiration time on or after which the JSON Web Token                       |
    ...  |                        |      | must not be accepted for processing (minutes).                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  RMODs Reset From GUI Single Execution
      ...  vdu_scfc_file_path=${vdu_scfc_file_path}
      ...  cbts_rmod_sn_list=${cbts_rmod_sn_list}
      ...  cbts_rmod_sn_count=${cbts_rmod_sn_count}
      ...  reset_timeout=${reset_timeout}
      ...  jwt_expiration_time=${jwt_expiration_time}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

RMODs Power Reset Single Execution
    [Arguments]  ${vdu_scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${rmod_sn_count}=0  ${run_index}=1
    ...  ${get_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_Radio_Modules_Power_Reset") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_STARTUP_Radio_Modules_Power_Reset
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}
    ...  rmod_sn_count=${rmod_sn_count}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

RMODs Power Reset Loop Execution
    [Arguments]  ${vdu_scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${rmod_sn_count}=0  ${run_count}=1
    ...  ${get_teardown_logs}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_Radio_Modules_Power_Reset") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  RMODs Power Reset Single Execution
      ...  vdu_scfc_file_path=${vdu_scfc_file_path}
      ...  rmod_sn_list=${rmod_sn_list}
      ...  rmod_sn_count=${rmod_sn_count}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

vDU Reset Operation Single Execution
    [Arguments]  ${vdu_scfc_file_path}  ${run_index}=1  ${get_logs}=${False}
    ...  ${vdu_connection}=default   ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_vDU_Reset") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_STARTUP_vDU_Reset
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

vDU Reset Operation Loop Execution
    [Arguments]  ${vdu_scfc_file_path}  ${run_count}=1  ${get_teardown_logs}=${False}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_vDU_Reset") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  vDU Reset Operation Single Execution
      ...  vdu_scfc_file_path=${vdu_scfc_file_path}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

vCU Reset Operation Single Execution
    [Arguments]  ${vcu_scfc_file_path}  ${vdu_scfc_file_path}  ${run_index}=1  ${get_logs}=${False}
    ...  ${vdu_connection}=default  ${vcu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_vCU_Reset") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_scfc_file_path     | Yes  | Path to the vCU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_STARTUP_vCU_Reset
    ...  vcu_scfc_file_path=${vcu_scfc_file_path}
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  vdu_connection=${vdu_connection}
    ...  vcu_connection=${vcu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

vCU Reset Operation Loop Execution
    [Arguments]  ${vcu_scfc_file_path}  ${vdu_scfc_file_path}  ${run_count}=1  ${get_teardown_logs}=${False}
    ...  ${vdu_connection}=default  ${vcu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_vCU_Reset") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_scfc_file_path     | Yes  | Path to the vCU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  vCU Reset Operation Single Execution
      ...  vcu_scfc_file_path=${vcu_scfc_file_path}
      ...  vdu_scfc_file_path=${vdu_scfc_file_path}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  vcu_connection=${vcu_connection}
      ...  log_to_console=${log_to_console}
    END

RMODs Hot Remove Hot Insert Single Execution
    [Arguments]  ${scfc_file_path}  ${switch_settings_off}  ${switch_settings_on}  ${run_index}=1
    ...  ${get_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | switch_settings_off    | Yes  | Switch OFF settings.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | switch_settings_on     | Yes  | Switch ON settings.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert
    ...  scfc_file_path=${scfc_file_path}
    ...  switch_settings_off=${switch_settings_off}
    ...  switch_settings_on=${switch_settings_on}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

RMODs Hot Remove Hot Insert Loop Execution
    [Arguments]  ${scfc_file_path}  ${switch_settings_off}  ${switch_settings_on}  ${run_count}=1
    ...  ${get_teardown_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | switch_settings_off    | Yes  | Switch OFF settings.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | switch_settings_on     | Yes  | Switch ON settings.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  RMODs Hot Remove Hot Insert Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  switch_settings_off=${switch_settings_off}
      ...  switch_settings_on=${switch_settings_on}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

LTE vDU Reset Operation Single Execution
    [Arguments]  ${lte_scfc_file_path}  ${run_index}=1  ${get_logs}=${False}
    ...  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_LTE_vDU_Reset") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lte_scfc_file_path     | Yes  | Path to the LTE vDU scfc file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
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

    Lte Cloud Test Setup
    ...  run_index=${run_index}
    ...  lte_vdu_connection=${lte_vdu_connection}
    ...  log_to_console=${log_to_console}
    TC__Cloud_STARTUP_LTE_vDU_Reset
    ...  lte_scfc_file_path=${lte_scfc_file_path}
    ...  lte_vdu_connection=${lte_vdu_connection}
    ...  log_to_console=${log_to_console}
    [Teardown]  Lte Cloud Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  lte_vdu_connection=${lte_vdu_connection}
    ...  log_to_console=${log_to_console}

LTE vDU Reset Operation Loop Execution
    [Arguments]  ${lte_scfc_file_path}  ${run_count}=1  ${get_teardown_logs}=${False}
    ...  ${lte_vdu_connection}=${LTE_VDU_CONNECTION_DEFAULT}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_LTE_vDU_Reset") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  LTE vDU Reset Operation Single Execution
      ...  lte_scfc_file_path=${lte_scfc_file_path}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  lte_vdu_connection=${lte_vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

RU Entering Deep Sleep Mode And Power Reset Recovery Action Single Execution
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${rmod_sn_count}=0  ${grace_period}=10min
    ...  ${run_index}=1  ${get_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | grace_period           |  No  | Time to enter (exit from) deep sleep mode.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    ...  scfc_file_path=${scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}
    ...  rmod_sn_count=${rmod_sn_count}
    ...  grace_period=${grace_period}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

RU Entering Deep Sleep Mode And Power Reset Recovery Action Loop Execution
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${rmod_sn_count}=0  ${grace_period}=10min
    ...  ${run_count}=1  ${get_teardown_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_vCU_Reset") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | grace_period           |  No  | Time to enter (exit from) deep sleep mode.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  RU Entering Deep Sleep Mode And Power Reset Recovery Action Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  rmod_sn_list=${rmod_sn_list}
      ...  rmod_sn_count=${rmod_sn_count}
      ...  grace_period=${grace_period}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

Rannic Reset Single Execution
    [Arguments]  ${scfc_file_path}  ${run_index}=1  ${get_logs}=${False}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_Rannic_Reset") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_STARTUP_Rannic_Reset
    ...  scfc_file_path=${scfc_file_path}
    ...  log_to_console=${log_to_console}
    ...  vdu_connection=${vdu_connection}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

Rannic Reset Loop Execution
    [Arguments]  ${scfc_file_path}  ${run_count}=1  ${get_teardown_logs}=${False}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_STARTUP_Rannic_Reset") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  Rannic Reset Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  vdu_connection=${vdu_connection}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

vDU Update Single Execution
    [Arguments]  ${scfc_file_path}  ${build_name}=${EMPTY}  ${run_index}=1  ${get_logs}=${False}
    ...  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SWM_vDU_Update") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | build_name             |  No  | Target Build name to be tested.  e.g. vDUCNF00_0.300.24408                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybyak@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_SWM_vDU_Update
    ...  scfc_file_path=${scfc_file_path}
    ...  build_name=${build_name}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

vDU Update Loop Execution
    [Arguments]  ${scfc_file_path}  ${build_name}=${EMPTY}  ${run_count}=1  ${get_teardown_logs}=${False}
    ...  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SWM_vDU_Update") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | build_name             |  No  | Target Build name to be tested.  e.g. vDUCNF00_0.300.24408                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  vDU Update Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  build_name=${build_name}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

Radio Unit Software Update During Fail Safe Mode Single Execution
    [Arguments]  ${scfc_file_path}  ${rmod_ids}  ${build_name}=${EMPTY}  ${run_index}=1
    ...  ${get_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SWM_Radio_Unit_Software_Update_During_Fail_Safe_Mode") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_ids               | Yes  | RM serial numbers separated by '|'                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | build_name             |  No  | Name of the target build, if necessary                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__Cloud_SWM_Radio_Unit_Software_Update_During_Fail_Safe_Mode
    ...  scfc_file_path=${scfc_file_path}
    ...  rmod_ids=${rmod_ids}
    ...  log_to_console=${log_to_console}
    ...  build_name=${build_name}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

Radio Unit Software Update During Fail Safe Mode Loop Execution
    [Arguments]  ${rmod_ids}  ${scfc_file_path}  ${build_name}=${EMPTY}  ${run_count}=1
    ...  ${get_teardown_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SWM_Radio_Unit_Software_Update_During_Fail_Safe_Mode") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_ids               | Yes  | RM serial numbers separated by '|'                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | build_name             |  No  | Name of the target build, if necessary                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  Radio Unit Software Update During Fail Safe Mode Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  rmod_ids=${rmod_ids}
      ...  build_name=${build_name}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

Snapshot Collection During Fail Safe Mode Single Execution
    [Arguments]  ${scfc_file_path}  ${rmod_ids}  ${run_index}=1
    ...  ${get_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__Cloud_SWM_Radio_Unit_Software_Update_During_Fail_Safe_Mode") single execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_ids               | Yes  | RM serial numbers separated by '|'                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | build_name             |  No  | Name of the target build, if necessary                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index              |  No  | Number of single test execution.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_logs               |  No  | Collect logs or not.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    AiC Test Setup
    ...  run_index=${run_index}
    ...  log_to_console=${log_to_console}
    TC__LOGS_Snapshot_Collection_During_Fail_Safe_Mode
    ...  rmod_ids=${rmod_ids}
    ...  scfc_file_path=${scfc_file_path}
    ...  log_to_console=${log_to_console}
    [Teardown]  AiC Test Teardown
    ...  run_index=${run_index}
    ...  get_logs=${get_logs}
    ...  log_to_console=${log_to_console}

Snapshot Collection During Fail Safe Mode Loop Execution
    [Arguments]  ${rmod_ids}  ${scfc_file_path}  ${run_count}=1
    ...  ${get_teardown_logs}=${False}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case ("TC__LOGS_Snapshot_Collection_During_Fail_Safe_Mode") loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_ids               | Yes  | RM serial numbers separated by '|'                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | build_name             |  No  | Name of the target build, if necessary                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Count of single test execution.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_teardown_logs      |  No  | Collect logs or not in single loop.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  Snapshot Collection During Fail Safe Mode Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  rmod_ids=${rmod_ids}
      ...  run_index=${run_index}
      ...  get_logs=${get_teardown_logs}
      ...  log_to_console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}
