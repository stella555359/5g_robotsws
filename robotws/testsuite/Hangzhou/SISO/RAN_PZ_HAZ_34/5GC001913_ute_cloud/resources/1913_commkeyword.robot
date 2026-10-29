*** Settings ***
Documentation
...   author: jiao.1.yang@nokia-sbell.com
...   contact: jiao.1.yang@nokia-sbell.com


Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh            WITH NAME    ssh


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot


*** Variables ***
######## testline related value ############

${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}   
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${RU_IP}    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}


*** Keywords ***
RU Ping
    [Documentation]    ping ip address from DU to RU
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
    ${response}    csn.execute    command=lxc-attach -n 0x1018 -- ping ${RU_IP} -c 5    connection=VM
    should contain    ${response}    0% packet loss
    [Teardown]    ssh.disconnect    connection=VM
    [Return]  ${response}




