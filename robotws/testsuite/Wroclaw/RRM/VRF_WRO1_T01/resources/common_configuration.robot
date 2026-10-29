*** Settings ***
Library    taf.sw.scout
Library    taf.sw.reporting_portal
Library    OperatingSystem
Library    Collections

Documentation
...    This file contains keywords used to generate and send the Configuration ID to Scout.

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
    ...  Set Variable  127.0.0.1
    Set Test Variable  ${host_vm_ip}
    [Return]  ${host_vm_ip}
Get Vm Ip
    ${master_node}=    Get From Dictionary    ${CFG}    master_node_bts_id
    ${vm_ip}=    Get From Dictionary    ${CFG.NODES["${master_node}"]}    host_ip
    [Return]  ${vm_ip}

Send Configuration ID To Scout
    ${host_vm_ip}=  Get Host IP Address  host_index=1
    ${vm_ip}=  Run Keyword If  '${host_vm_ip}'=='${EMPTY}'  Get Vm Ip
    ...  ELSE  Set Variable  ${host_vm_ip}
    ${vm_hostname}=    OperatingSystem.Run    ssh -o LogLevel=quiet ute@${vm_ip} sed 's/-/_/g' /etc/hostname
    ${single_run_execution}=     Evaluate    [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]

    ${scout_setup_status}=    Run Keyword And Return Status    Setup Scout  ${vm_hostname}
    ${scout_monitor_status}=    Run Keyword And Return Status    Get Testline Monitor Status
    ${scout_conf_id}=    Run Keyword If    ${single_run_execution}    Request Scf
    ...    ELSE    Request Scf    use_scout_internal_id=True
    Run Keyword If  ${scout_setup_status} and (not ${single_run_execution})
    ...    Add To Test Data  data={"tc_execution_id":"${scout_conf_id}"}

    Run Keyword If    not ${scout_setup_status}
    ...    Log    Couldn't match VM's hostname (${vm_hostname}) to TL in Scout! Please check if TL exist in Scout.    level=WARN
    Run Keyword If    not ${scout_conf_id}
    ...    Log    Couldn't fetch SCF for ${vm_hostname}! Please check connection to Scout.    level=WARN
    Run Keyword If    ${scout_setup_status} and ${scout_conf_id}
    ...    Log    Request to Scout to fetch new SCF sent.    console=True
    [Teardown]    Teardown Scout API
