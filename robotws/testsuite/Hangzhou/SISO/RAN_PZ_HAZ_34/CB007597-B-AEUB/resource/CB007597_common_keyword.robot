*** Settings ***
Documentation
...               author: Steven Liu
...               contact: steven.liu@nokia-sbell.com
...               squad group: MMW_SG_04

Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh         WITH NAME    ssh
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource          ../../../../RRM/Paris/resources/coam_ulm.robot

*** Variables ***
${DU_IP}             ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
Connect to DU
    [Arguments]    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}

Disconnect from DU
    [Arguments]    ${connection}=cOAM_admin
    coam.teardown      connection=${connection}

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=cOAM_admin
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=cOAM_admin
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_name_list}    ${fault_id_list}

gNB connections
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${DU_OAM_SSH_USERNAME}
    ...               password=${DU_OAM_SSH_PASSWORD}
    ...               alias=gnb

RU Ping
    [Documentation]    ping ip address from DU to RU
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
    ${response}    csn.execute    command=lxc-attach -n 0x1018 -- ping ${RU_IP} -c 5    connection=VM
    should contain    ${response}    0% packet loss
    [Teardown]    ssh.disconnect    connection=VM
    [Return]  ${response}

