*** Settings ***
Documentation  Scenarios of loop test cases
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ./test_cases.robot
Resource    ../../resources/Robot/reporting.robot

*** Keywords ***
CUS Reset Site Single Execution
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${get_kpi}=False  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True  ${run_index}=1
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}
    ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs BTS reset site as a single execution in a loop.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi1a or not.                                                        |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executions.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    CUS Reset Site
    ...  scfc_file_path=${scfc_file_path}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  get_kpi=${get_kpi}
    ...  hw_configuration=${hw_configuration}
    ...  allowed_alarms=${allowed_alarms}
    ...  log_to_console=${log_to_console}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${logs_dir_path}
    ...  teardown_allowed_alarms=${teardown_allowed_alarms}
    ...  run_index=${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  act_category_alarms=${act_category_alarms}
    ...  collect_test_case_syslog=${collect_test_case_syslog}
    ...  log_to_console=${log_to_console}

CUS Reset Site Loop Execution
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${get_kpi}=False  ${run_count}=1
    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}
    ...  ${log_to_console}=True  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
    ...  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
    ...  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs BTS reset site in loop execution.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi1a or not.                                                        |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_count                |  No  | Number of executions.                                                    |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  CUS Reset Site Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  list_of_cus_ips=${list_of_cus_ips}
      ...  get_kpi=${get_kpi}
      ...  hw_configuration=${hw_configuration}
      ...  allowed_alarms=${allowed_alarms}
      ...  log_to_console=${log_to_console}
      ...  run_index=${run_index}
      ...  logs_dir_path=${logs_dir_path}
      ...  teardown_allowed_alarms=${teardown_allowed_alarms}
      ...  act_category_alarms=${act_category_alarms}
      ...  collect_test_case_syslog=${collect_test_case_syslog}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

CUS BTS Power Reset Single Execution
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${get_kpi}=False  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True  ${run_index}=1
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}
    ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs BTS reset site as a single execution in a loop.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi1a or not.                                                        |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executions.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    CUS BTS Power Reset
    ...  scfc_file_path=${scfc_file_path}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  get_kpi=${get_kpi}
    ...  hw_configuration=${hw_configuration}
    ...  allowed_alarms=${allowed_alarms}
    ...  log_to_console=${log_to_console}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${logs_dir_path}
    ...  teardown_allowed_alarms=${teardown_allowed_alarms}
    ...  run_index=${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  act_category_alarms=${act_category_alarms}
    ...  collect_test_case_syslog=${collect_test_case_syslog}
    ...  log_to_console=${log_to_console}

CUS BTS Power Reset Loop Execution
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${get_kpi}=False  ${run_count}=1
    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}
    ...  ${log_to_console}=True  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
    ...  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
    ...  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs BTS reset site in loop execution.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi1a or not.                                                        |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_count                |  No  | Number of executions.                                                    |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  CUS BTS Power Reset Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  list_of_cus_ips=${list_of_cus_ips}
      ...  get_kpi=${get_kpi}
      ...  hw_configuration=${hw_configuration}
      ...  allowed_alarms=${allowed_alarms}
      ...  log_to_console=${log_to_console}
      ...  run_index=${run_index}
      ...  logs_dir_path=${logs_dir_path}
      ...  teardown_allowed_alarms=${teardown_allowed_alarms}
      ...  act_category_alarms=${act_category_alarms}
      ...  collect_test_case_syslog=${collect_test_case_syslog}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

CUS Radio Module Reset Single Execution
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${list_of_cus_ips}  ${get_kpi}=False
    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True
    ...  ${run_index}=1  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}
    ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs radio module reset as a single execution in a loop.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | rmod_sn_list             | Yes  | List of serial number of radio modules to reset.                         |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP addresses.                                                |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi51a or not.                                                       |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executions.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    CUS Radio Module Reset
    ...  scfc_file_path=${scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}
    ...  get_kpi=${get_kpi}
    ...  hw_configuration=${hw_configuration}
    ...  allowed_alarms=${allowed_alarms}
    ...  log_to_console=${log_to_console}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${logs_dir_path}
    ...  teardown_allowed_alarms=${teardown_allowed_alarms}
    ...  run_index=${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  act_category_alarms=${act_category_alarms}
    ...  collect_test_case_syslog=${collect_test_case_syslog}
    ...  log_to_console=${log_to_console}

CUS Radio Module Reset Loop Execution
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${list_of_cus_ips}
    ...  ${get_kpi}=False  ${run_count}=1  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}
    ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs radio module reset in loop execution.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | rmod_sn_list             | Yes  | List of serial number of radio modules to reset.                         |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP addresses.                                                |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi51a or not.                                                       |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_count                |  No  | Number of executions.                                                    |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  CUS Radio Module Reset Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  rmod_sn_list=${rmod_sn_list}
      ...  list_of_cus_ips=${list_of_cus_ips}
      ...  get_kpi=${get_kpi}
      ...  hw_configuration=${hw_configuration}
      ...  allowed_alarms=${allowed_alarms}
      ...  log_to_console=${log_to_console}
      ...  run_index=${run_index}
      ...  logs_dir_path=${logs_dir_path}
      ...  teardown_allowed_alarms=${teardown_allowed_alarms}
      ...  act_category_alarms=${act_category_alarms}
      ...  collect_test_case_syslog=${collect_test_case_syslog}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

CUS Baseband Module Reset Single Execution
    [Arguments]  ${scfc_file_path}  ${bbmod_sn_list}  ${list_of_cus_ips}  ${get_kpi}=False
    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}
    ...  ${log_to_console}=True  ${run_index}=1  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
    ...  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
    ...  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs baseband module reset as a single execution in a loop.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | bbmod_sn_list            | Yes  |  List of serial number of baseband modules to reset.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi5 or not.                                                         |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executions.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    CUS Baseband Module Reset
    ...  scfc_file_path=${scfc_file_path}
    ...  bbmod_sn_list=${bbmod_sn_list}
    ...  get_kpi=${get_kpi}
    ...  hw_configuration=${hw_configuration}
    ...  allowed_alarms=${allowed_alarms}
    ...  log_to_console=${log_to_console}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${logs_dir_path}
    ...  teardown_allowed_alarms=${teardown_allowed_alarms}
    ...  run_index=${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  act_category_alarms=${act_category_alarms}
    ...  collect_test_case_syslog=${collect_test_case_syslog}
    ...  log_to_console=${log_to_console}

CUS Baseband Module Reset Loop Execution
    [Arguments]  ${scfc_file_path}  ${bbmod_sn_list}  ${list_of_cus_ips}  ${get_kpi}=False
    ...  ${run_count}=1  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}
    ...  ${log_to_console}=True  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
    ...  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
    ...  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs baseband module reset in loop execution.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | bbmod_sn_list            | Yes  |  List of serial number of baseband modules to reset.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi5 or not.                                                         |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_count                |  No  | Number of executions.                                                    |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  CUS Baseband Module Reset Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  bbmod_sn_list=${bbmod_sn_list}
      ...  list_of_cus_ips=${list_of_cus_ips}
      ...  get_kpi=${get_kpi}
      ...  hw_configuration=${hw_configuration}
      ...  allowed_alarms=${allowed_alarms}
      ...  log_to_console=${log_to_console}
      ...  run_index=${run_index}
      ...  logs_dir_path=${logs_dir_path}
      ...  teardown_allowed_alarms=${teardown_allowed_alarms}
      ...  act_category_alarms=${act_category_alarms}
      ...  collect_test_case_syslog=${collect_test_case_syslog}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

CUS BTS Rat Reset Single Execution
    [Arguments]  ${scfc_file_path}  ${rat_type}  ${list_of_cus_ips}  ${rat_reset_timeout}=600  ${get_kpi}=False
    ...  ${verify_changes}=True  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}
    ...  ${log_to_console}=True  ${run_index}=1  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
    ...  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
    ...  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs BTS rat reset as a single execution in a loop.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | rat_type                 | Yes  | RAT name - NR, LTE, WCDMA or GSM.                                        |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | rat_reset_timeout        | Yes  | Timeout for the RAT reset operation.                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | get_kpi                  |  No  | Get kpi7a/kpi7b or not.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | verify_changes           |  No  | Verify and print impacted and no impacted objects after rat reset.       |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executions.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    CUS BTS Rat Reset
    ...  scfc_file_path=${scfc_file_path}
    ...  rat_type=${rat_type}
    ...  rat_reset_timeout=${rat_reset_timeout}
    ...  get_kpi=${get_kpi}
    ...  verify_changes=${verify_changes}
    ...  hw_configuration=${hw_configuration}
    ...  allowed_alarms=${allowed_alarms}
    ...  log_to_console=${log_to_console}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${logs_dir_path}
    ...  teardown_allowed_alarms=${teardown_allowed_alarms}
    ...  run_index=${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  act_category_alarms=${act_category_alarms}
    ...  collect_test_case_syslog=${collect_test_case_syslog}
    ...  log_to_console=${log_to_console}

CUS BTS Rat Loop Execution
    [Arguments]  ${scfc_file_path}  ${rat_type}  ${list_of_cus_ips}  ${rat_reset_timeout}=600
    ...  ${get_kpi}=False  ${verify_changes}=True  ${run_count}=1  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}
    ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs BTS rat reset in loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rat_type               | Yes  | RAT name - NR, LTE, WCDMA or GSM.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | rat_reset_timeout      | Yes  | Timeout for the RAT reset operation.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi7a/kpi7b or not.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | verify_changes         |  No  | Verify and print impacted and no impacted objects after rat reset.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_count              |  No  | Number of executions.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Run Keyword And Continue On Failure
      ...  CUS BTS Rat Reset Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  rat_type=${rat_type}
      ...  list_of_cus_ips=${list_of_cus_ips}
      ...  rat_reset_timeout=${rat_reset_timeout}
      ...  get_kpi=${get_kpi}
      ...  verify_changes=${verify_changes}
      ...  hw_configuration=${hw_configuration}
      ...  allowed_alarms=${allowed_alarms}
      ...  log_to_console=${log_to_console}
      ...  run_index=${run_index}
      ...  logs_dir_path=${logs_dir_path}
      ...  teardown_allowed_alarms=${teardown_allowed_alarms}
      ...  act_category_alarms=${act_category_alarms}
      ...  collect_test_case_syslog=${collect_test_case_syslog}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}

CUS BTS IQRouting Runtime Change Single Execution
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_IQR}  ${log_to_console}=True  ${run_index}=1
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${teardown_allowed_alarms}=${ALLOWED_ALARMS_IQR}
    ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs CUS BTS IQRouting Runtime Change in one execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executions.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    CUS BTS IQRouting Runtime Change
    ...  scfc_file_path=${scfc_file_path}
    ...  hw_configuration=${hw_configuration}
    ...  allowed_alarms=${allowed_alarms}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${logs_dir_path}
    ...  teardown_allowed_alarms=${teardown_allowed_alarms}
    ...  run_index=${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  act_category_alarms=${act_category_alarms}
    ...  collect_test_case_syslog=${collect_test_case_syslog}
    ...  log_to_console=${log_to_console}

CUS BTS IQRouting Runtime Change Loop Execution
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${run_count}=1  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_IQR}  ${log_to_console}=True  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
    ...  ${teardown_allowed_alarms}=${ALLOWED_ALARMS_IQR}   ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
    ...  ${collect_test_case_syslog}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs CUS BTS IQRouting Runtime Change in a loop execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path           | Yes  | Path to the scfc file.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP.                                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_count                | Yes  | Number of test case executions.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration         |  No  | eNB hardware configuration.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms           | Yes  | List of allowed alarms.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Log text to console.                                                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | logs_dir_path            | No   | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | No   | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | No   | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    FOR  ${run_index}  IN RANGE  1  ${run_count}+1
      Log  \n${dots_prefix_green}TC IQRouting Runtime Change ongoing - number ${run_index+1}/${run_count}
      ...  console=${log_to_console}
      Run Keyword And Continue On Failure
      ...  CUS BTS IQRouting Runtime Change Single Execution
      ...  scfc_file_path=${scfc_file_path}
      ...  list_of_cus_ips=${list_of_cus_ips}
      ...  hw_configuration=${hw_configuration}
      ...  allowed_alarms=${allowed_alarms}
      ...  log_to_console=${log_to_console}
      ...  run_index=${run_index}
      ...  logs_dir_path=${logs_dir_path}
      ...  teardown_allowed_alarms=${teardown_allowed_alarms}
      ...  act_category_alarms=${act_category_alarms}
      ...  collect_test_case_syslog=${collect_test_case_syslog}
      Log  ${ok_prefix_green}TC IQRouting Runtime Change ${run_index+1}/${run_count} done\n
      ...  console=${log_to_console}
    END
    [Teardown]  Run Keyword If  ${run_count}>1
    ...  Add Loop Number To Reporting Portal  ${run_index}
