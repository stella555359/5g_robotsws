*** Settings ***
Documentation    Common Robot keywords

Library    taf.sw.scout               WITH NAME  scout
Library    taf.sw.reporting_portal    WITH NAME    rp
Library    ./qc.py
Library    ./siso_logger.py

*** Keywords ***
Test Case QC Mapping
    [Arguments]  ${sw_version}
    [Documentation]
    ...  Description:
    ...  Keyword makes QC test case instance mapping.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | sw_version             | Yes  | Running software version.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${test_case_name_status}=  Run Keyword And Return Status
    ...  Should Match Regexp  string=${TEST_NAME}  pattern=^\\[\\d*\\].*
    ${test_case_name}=  Set Variable  ${TEST_NAME}
    Return From Keyword If  ${test_case_name_status}  ${test_case_name}
    ${test_case_name}=  Set Correct Test Instance Based On QC File
    ...  test_name=${TEST_NAME}  sw=${sw_version}  executed_file_path=${SUITE_SOURCE}
    rp.Map Testcase   testcase_name=${test_case_name}
	[Return]  ${test_case_name}

Create Report
    [Documentation]  KW for reporting executed TC
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    Run Keyword And Ignore Error  Request Configuration ID from Scout
    rp.Set Tool  Robot
    QC Mapping  ${CFG.NODES['${cfg.primary_node_bts_id}']['software_active']}

QC Mapping
    [Arguments]   ${sw_under_test}
    [Documentation]  KW Checks if TC name is correct. When any TAG is added at the beggining of TC name, KW prepares correct naming.
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | sw_under_test          | Yes  | active software on BTS                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ${ti_entered_manually}=  Run Keyword And Return Status  Should Match Regexp  ${TEST_NAME}  ^\\[\\d*\\].*
    Return From Keyword If  ${ti_entered_manually}
    ${correct_test_name}=  Set Correct Test Instance Based On QC File  ${TEST_NAME}  ${sw_under_test}  ${SUITE_SOURCE}
    Logging With Timestamp  message=Mapping Test Case as ${correct_test_name}
    rp.Map Testcase  ${correct_test_name}
    [Return]  ${correct_test_name}

Get Vm Ip
    [Documentation]  KW gets Vm IP on which TC is executed.
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Return Values:
    ...    +-----------------------+-------------------------------------------------------------------------+
    ...    | Return Value          | Description                                                             |
    ...    +=======================+=========================================================================+
    ...    | vm_ip                 | Vm IP on which TC is executed                                           |
    ...    +-----------------------+-------------------------------------------------------------------------+
    ${primary_node}=  Get From Dictionary  ${CFG}  primary_node_bts_id
    ${vm_ip}=  Get From Dictionary  ${CFG.NODES["${primary_node}"]}  vm_ip_LMP_address
    [Return]  ${vm_ip}

Request Configuration ID from Scout
    [Arguments]  ${host_vm_ip}=${EMPTY}
    [Documentation]  KW requests configuration ID from Scout
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | host_vm_ip             | No   | IP of VM on which TC is executed                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ${vm_ip}=  Run Keyword If  '${host_vm_ip}'=='${EMPTY}'  Get Vm Ip
    ...  ELSE  Set Variable  ${host_vm_ip}
    ${vm_hostname}=  Run  ssh -o LogLevel=quiet ute@${vm_ip} sed 's/-/_/g' /etc/hostname
    ${single_run_execution}=  Evaluate  [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    ${scout_setup_status}  Start And Confirm Scout Setup  vm_hostname=${vm_hostname}  retry=3  delay=60
    ${scout_conf_id}=  Run Keyword If  ${single_run_execution}  scout.Request Scf
    ...  ELSE  scout.Request Scf  use_scout_internal_id=True
    Run Keyword If  ${scout_setup_status} and (not ${single_run_execution})
    ...  rp.Add To Test Data  data={"tc_execution_id":"${scout_conf_id}"}
    Run Keyword If  not ${scout_setup_status}  Logging With Timestamp
    ...  message=Couldn't match VM's hostname (${vm_hostname}) to TL in Scout! Please check if TL exist in Scout
    ...  style=WARNING
    Run Keyword If  not ${scout_conf_id}  Logging With Timestamp
    ...  message=Couldn't fetch SCF for ${vm_hostname}! Please check connection to Scout
    ...  style=WARNING
    Run Keyword If    ${scout_setup_status} and ${scout_conf_id}
    ...  Logging With Timestamp  message=Request to Scout to fetch new SCF sent
    [Teardown]    scout.Teardown Scout API

Start And Confirm Scout Setup
    [Arguments]  ${vm_hostname}  ${retry}=3  ${delay}=60
    [Documentation]  KW checks or retries Scout setup
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | vm_hostname            | Yes  | VM hostname from Linux command                                     |
    ...  | retry                  | No   | Limit of allowed attempts                                          |
    ...  | delay                  | No   | Sleep time if Scout Monitor is starting up                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return Values:
    ...  +-----------------------+----------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                |
    ...  +=======================+============================================================================+
    ...  | scout_setup_status    | Scout setup status. True if set up or False if not set up                  |
    ...  +-----------------------+----------------------------------------------------------------------------+
    FOR  ${try}  IN RANGE  ${retry}
        ${scout_setup_status}  Run Keyword And Return Status  scout.Setup Scout  ${vm_hostname}
        IF  not ${scout_setup_status}  CONTINUE
        ${scout_monitor_status}  Check Testline Monitor Status Until Running
        IF  ${scout_monitor_status}  RETURN  ${True}
        Log  Setting up Scout monitoring attampt ${try} of ${retry} failed!
        Sleep  ${delay}
    END
    Logging With Timestamp
    ...  message=Couldn't set up Scout monitoring for ${vm_hostname} after ${retry} attempts! Configuration ID won't be repported!
    ...  style=WARNING
    [Return]  ${False}

Check Testline Monitor Status Until Running
    [Arguments]  ${limit}=60 seconds
    [Documentation]  Checks if Scout's KW Get Testline Monitor Status returns "running" in key "admin_subscriptions_status_display" for limited time
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | limit                  | No   | Default '60 seconds'. Provide time unit for timeout or number for  |
    ...  |                        |      | attempts                                                           |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return Values:
    ...  +-----------------------+----------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                |
    ...  +=======================+============================================================================+
    ...  | status                | True if admin_subscriptions_status_display equals running False otherwise  |
    ...  +-----------------------+----------------------------------------------------------------------------+
    TRY
       WHILE  ${True}  limit=${limit}
            Sleep  1s  # Anti spam delay
            ${scout_monitor_dict}  scout.Get Testline Monitor Status
            IF  "${scout_monitor_dict['admin_subscriptions_status_display']}" == "running"  RETURN  ${True}
            IF  "${scout_monitor_dict['admin_subscriptions_status_display']}" == "setting up"  CONTINUE
        END
        Log  Scout Monitor is not running! Its last status was: ${scout_monitor_dict['admin_subscriptions_status_display']}
    EXCEPT  AS  ${error}
        Log  Failed to check Scout Monitor status due to ${error}
    END
    [Return]  ${False}

Start Testline Scout Monitor
    [Arguments]  ${host_vm_ip}=${EMPTY}
    [Documentation]  KW starts scout monitor connection
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | host_vm_ip             | No   | IP of VM on which TC is executed                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ${vm_ip}=  Run Keyword If  '${host_vm_ip}'=='${EMPTY}'  Get Vm Ip
    ...  ELSE  Set Variable  ${host_vm_ip}
    ${scout_conf_path}=  Set Variable  /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    ${venv_cmd}=  Run  if [ -f /home/ute/test_repo/bin/activate ]; then echo "source /home/ute/test_repo/bin/activate"; else echo ":"; fi
    ${pip_cmd_1}=  Set Variable  pip install -U --trusted-host artifactory-espoo1.int.net.nokia.com -i
    ${pip_cmd_2}=  Set Variable  https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple scout-cli
    ${cmd_pip_install_scout_cli}=  Set Variable  ${pip_cmd_1} ${pip_cmd_2}
    ${single_run_execution}=  Evaluate  [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    Run Keyword And Return If  ${single_run_execution}  Logging With Timestamp
    ...  message=Cloud execution detected - skipping...
    Run  ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; ${cmd_pip_install_scout_cli}
    ${scout_config}=  Get Scout Config As Dict  ${vm_ip}  ${scout_conf_path}
    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}
    Run Keyword If  not ${scout_monitor_status}  Run  ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; scout-cli testline start -c ${scout_conf_path}
    Sleep  5s  Waiting for scout connection stabilization
    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}
    Run Keyword If  not ${scout_monitor_status}  Logging With Timestamp
    ...  message=Scout Testline Monitor should not be DISABLED!
    ...  style=WARNING
    Run Keyword If  ${scout_monitor_status}  Logging With Timestamp
    ...  message=Scout Testline Monitor is enabled

Get Scout Config As Dict
    [Arguments]    ${vm_ip}    ${scout_conf_path}
    [Documentation]  KW prepares scout configuration as dictionary
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | vm_ip                  | Yes  | IP of VM on which TC is executed                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return Values:
    ...  +-----------------------+-------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                             |
    ...  +=======================+=========================================================================+
    ...  | config_dict           | scout configuration as dictionary                                       |
    ...  +-----------------------+-------------------------------------------------------------------------+
    ${config_exists}=  Run  ssh -o LogLevel=quiet ute@${vm_ip} [ -f ${scout_conf_path} ]; echo $?
    Should Be Equal  ${config_exists}  0  msg=Couldn't find file ${scout_conf_path} on ${vm_ip}
    ${config_file}=  Run  ssh -o LogLevel=quiet ute@${vm_ip} cat ${scout_conf_path}
    ${config_dict}=  Evaluate  ${config_file}    # This is file (string) to dict convertion
    Dictionary Should Contain Key  ${config_dict}  scout_testline_id
    Dictionary Should Contain Key  ${config_dict}  scout_testline_name
    Dictionary Should Contain Key  ${config_dict}  testline_token
    [Return]  ${config_dict}

Get Scout Tesline Monitor Status
    [Arguments]    ${hostname}    ${vm_ip}    ${scout_conf_path}    ${venv_cmd}=source /home/ute/test_repo/bin/activate
    [Documentation]  KW gets Scout Monitor connection status
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | hostname               | Yes  | VM hostname                                                        |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | vm_ip                  | Yes  | IP of VM on which TC is executed                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | scout_conf_path        | Yes  | scout configuration as dictionary                                  |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | venv_cmd               | No   | command used for getting actual venv                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Return Values:
    ...  +-----------------------+-------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                             |
    ...  +=======================+=========================================================================+
    ...  | status                | Scout Monitor status                                                    |
    ...  +-----------------------+-------------------------------------------------------------------------+
    ${response}=  Run  ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; scout-cli testline status -c ${scout_conf_path}
    ${status}=  Run Keyword And Return Status  Should Match Regexp  ${response}  (?im)scout_prod_testline_${hostname}: Up
    [Return]  ${status}

Stop Testline Scout Monitor
    [Arguments]  ${host_vm_ip}=${EMPTY}
    [Documentation]  KW stops scout monitor connection
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | host_vm_ip             | No   | IP of VM on which TC is executed                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ${vm_ip}=  Run Keyword If  '${host_vm_ip}'=='${EMPTY}'  Get Vm Ip
    ...  ELSE  Set Variable  ${host_vm_ip}
    ${scout_conf_path}=  Set Variable  /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    ${venv_cmd}=  Run  if [ -f /home/ute/test_repo/bin/activate ]; then echo "source /home/ute/test_repo/bin/activate"; else echo ":"; fi
    ${pip_cmd_1}=  Set Variable  pip install -U --trusted-host artifactory-espoo1.int.net.nokia.com -i
    ${pip_cmd_2}=  Set Variable  https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple scout-cli
    ${cmd_pip_install_scout_cli}=  Set Variable  ${pip_cmd_1} ${pip_cmd_2}
    ${single_run_execution}=  Evaluate  [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    Run Keyword And Return If  ${single_run_execution}  Logging With Timestamp
    ...  message=Cloud execution detected - skipping...
    Run  ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; ${cmd_pip_install_scout_cli}
    ${scout_config}=  Get Scout Config As Dict  ${vm_ip}  ${scout_conf_path}
    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}
    Run Keyword If  ${scout_monitor_status}  Run  ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; scout-cli testline stop -c ${scout_conf_path}
    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}
    Run Keyword If  ${scout_monitor_status}  Logging With Timestamp
    ...  message=Scout Testline Monitor is ENABLED - It should not be anymore!
    ...  style=WARNING
    Run Keyword If  not ${scout_monitor_status}  Logging With Timestamp
    ...  message=Scout Testline Monitor is disabled
