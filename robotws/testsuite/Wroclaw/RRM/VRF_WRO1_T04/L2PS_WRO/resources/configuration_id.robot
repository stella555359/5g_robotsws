*** Settings ***
Documentation    :copyright: Nokia

Library    taf.sw.scout
Library    taf.sw.reporting_portal
Library    taf.rfrl.common_resources.reporting_portal.bts_metadata
Library    taf.sbts.oam.coam.admin          WITH NAME    admin
Library    OperatingSystem
Library    Collections

*** Keywords ***

Get Host IP Address
    [Arguments]  ${host_index}
    [Documentation]
    ...  Description:
    ...  Keyword gets host IP address from from TL configuration init file based on host index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vm_index               | Yes  | Index of host.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${gve_model_status}=  Run Keyword And Return Status  Variable Should Exist  ${tl.host[1].addr}
    ${taf_model_status}=  Run Keyword And Return Status  Variable Should Exist  ${tl.test_pcs}
    ${host_vm_ip}=  Run Keyword If  ${gve_model_status}
    ...  Get Variable Value  ${tl.host[${host_index}].addr}  ${None}
    ...  ELSE IF  ${taf_model_status}
    ...  Get Variable Value  ${tl.test_pcs[${host_index}-1].default_ssh_connection_details.addr}  ${None}
    ...  ELSE
    ...  Set Variable  ${None}
    Set Test Variable  ${host_vm_ip}
    [Return]  ${host_vm_ip}

Get Vm Ip
    ${master_node}=    Get From Dictionary    ${CFG}    master_node_bts_id
    ${vm_ip}=    Get From Dictionary    ${CFG.NODES["${master_node}"]}    host_ip
    [Return]  ${vm_ip}

Send Configuration ID To Scout
    admin.Setup Admin       name=admin_alias
    ${host_vm_ip}=  Get Host IP Address  host_index=1
    ${vm_ip}=  Run Keyword If  '${host_vm_ip}'=='${EMPTY}'  Get Vm Ip
    ...  ELSE  Set Variable  ${host_vm_ip}
    ${vm_hostname}=    OperatingSystem.Run    ssh -o LogLevel=quiet ute@${vm_ip} sed 's/-/_/g' /etc/hostname
    &{bts_params}=     Create dictionary    admin_connection=admin_alias   scout_bts_name=${vm_hostname}
    Run Keyword and Ignore Error     add_bts_metadata_to_report    bts_params=${bts_params}
    [Teardown]    admin.Teardown Admin    connection=admin_alias

Start Testline Scout Monitor
    [Arguments]  ${host_vm_ip}=${EMPTY}
    ${vm_ip}=  Run Keyword If  '${host_vm_ip}'=='${EMPTY}'  Get Vm Ip
    ...  ELSE  Set Variable  ${host_vm_ip}
    ${scout_conf_path}=    Set Variable    /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    ${venv_cmd}=    Run    if [ -f /home/ute/test_repo/bin/activate ]; then echo "source /home/ute/test_repo/bin/activate"; else echo ":"; fi
    ${https_addr}=  Set Variable  https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple scout-cli
    ${cmd_pip_install_scout_cli}=    Set Variable    pip install -U --trusted-host artifactory-espoo1.int.net.nokia.com -i ${https_addr}


    ${single_run_execution}=     Evaluate    [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    Run Keyword And Return If    ${single_run_execution}    Log To Console    Cloud execution detected - skipping...

    Run    ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; ${cmd_pip_install_scout_cli}
    ${scout_config}=    Get Scout Config As Dict    ${vm_ip}    ${scout_conf_path}

    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}
    Run Keyword If  not ${scout_monitor_status}  Run  ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; scout-cli testline start -c ${scout_conf_path}
    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}

    Run Keyword If    not ${scout_monitor_status}    Log To Console    Scout Testline Monitor should not be DISABLED!    level=warn
    Run Keyword If        ${scout_monitor_status}    Log To Console    Scout Testline Monitor is enabled

Get Scout Config As Dict
    [Arguments]    ${vm_ip}    ${scout_conf_path}
    # Bash way to check if file exist (0->exist; 1->not exist)
    ${config_exists}=        Run    ssh -o LogLevel=quiet ute@${vm_ip} [ -f ${scout_conf_path} ]; echo $?
    Should Be Equal    ${config_exists}    0    msg=Couldn't find file ${scout_conf_path} on ${vm_ip}
    ${config_file}=    Run    ssh -o LogLevel=quiet ute@${vm_ip} cat ${scout_conf_path}
    ${config_dict}=    Evaluate    ${config_file}    # This is file (string) to dict convertion
    Dictionary Should Contain Key    ${config_dict}    scout_testline_id
    Dictionary Should Contain Key    ${config_dict}    scout_testline_name
    Dictionary Should Contain Key    ${config_dict}    testline_token
    [Return]    ${config_dict}

Get Scout Tesline Monitor Status
    [Arguments]    ${hostname}    ${vm_ip}    ${scout_conf_path}    ${venv_cmd}=source /home/ute/test_repo/bin/activate
    ${response}=    Run    ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; scout-cli testline status -c ${scout_conf_path}
    ${status}=    Run Keyword And Return Status    Should Match Regexp    ${response}    (?im)scout_prod_testline_${hostname}: Up
    [Return]    ${status}

Stop Testline Scout Monitor
    [Arguments]  ${host_vm_ip}=${EMPTY}
    ${vm_ip}=  Run Keyword If  '${host_vm_ip}'=='${EMPTY}'  Get Vm Ip
    ...  ELSE  Set Variable  ${host_vm_ip}
    ${scout_conf_path}=    Set Variable    /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    ${venv_cmd}=    Run    if [ -f /home/ute/test_repo/bin/activate ]; then echo "source /home/ute/test_repo/bin/activate"; else echo ":"; fi
    ${https_addr}=  Set Variable  https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple scout-cli
    ${cmd_pip_install_scout_cli}=  Set Variable  pip install -U --trusted-host artifactory-espoo1.int.net.nokia.com -i ${https_addr}

    ${single_run_execution}=     Evaluate    [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    Run Keyword And Return If    ${single_run_execution}    Log To Console    Cloud execution detected - skipping...

    Run    ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; ${cmd_pip_install_scout_cli}
    ${scout_config}=    Get Scout Config As Dict    ${vm_ip}    ${scout_conf_path}

    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}
    Run Keyword If  ${scout_monitor_status}  Run  ssh -o LogLevel=quiet ute@${vm_ip} ${venv_cmd}; scout-cli testline stop -c ${scout_conf_path}
    ${scout_monitor_status}=  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${vm_ip}  ${scout_conf_path}  ${venv_cmd}

    Run Keyword If    ${scout_monitor_status}    Log To Console    Scout Testline Monitor is ENABLED - It should not be anymore!    level=warn
    Run Keyword If    not ${scout_monitor_status}    Log To Console    Scout Testline Monitor is disabled
