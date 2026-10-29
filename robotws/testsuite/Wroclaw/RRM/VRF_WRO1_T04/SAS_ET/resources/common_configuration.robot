*** Settings ***
Library    taf.sw.scout
Library    taf.sw.reporting_portal
Library    taf.rfrl.common_resources.reporting_portal.bts_metadata
Library    taf.sbts.oam.coam.admin          WITH NAME    admin
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
