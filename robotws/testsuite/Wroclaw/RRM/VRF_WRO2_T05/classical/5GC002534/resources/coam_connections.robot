*** Settings ***
Documentation    Connection keywords regarding cOAM, variables (IP addresses etc.) for cOAM.

Library  taf.transport.ssh		    WITH NAME   ssh
Library  taf.ul.oam.selenium_coam   WITH NAME   gui
Library  coam_gNB_operations.py

*** Variables ***
${ROOT_USERNAME}=           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}=           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${SERVICEUSER_USERNAME}=    serviceuser
${SERVICEUSER_PASSWORD}=    Pl(FzaYj5~c5;q
${WEBEM_USERNAME}=          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}=          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${VM_IP}=                   ${tl.test_pc.default_ssh_connection_details.addr}

${WEBEM_DEVELOPER_USERNAME}=  developer
${WEBEM_DEVELOPER_PASSWORD}=  $developer#
${RADIO_USERNAME}=          root
${RADIO_PASSWORD}=          umniedziala

${ABIL_IP}=                 192.168.253.22
${WEBEM_IP}=                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${LMP_IP}=                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${BACKHAUL_OAM_IP}=         ${tl.gnbs[0].cu.m.v4}

${ATL_path}                 /home/ute/logs/ATLlogs.txt
*** Keywords ***
Connect to cOAM as toor4nsn
    [Arguments]  ${ip_address}=${LMP_IP}  ${alias}=cOAM_toor4nsn  ${password}=${ROOT_PASSWORD}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]  ${connection}

Connect to cOAM as serviceuser
    [Arguments]  ${ip_address}=${LMP_IP}  ${alias}=cOAM_serviceuser  ${password}=${SERVICEUSER_PASSWORD}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${SERVICEUSER_USERNAME}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]  ${connection}

Disconnect from cOAM
    [Arguments]  ${connection}=cOAM_toor4nsn
    ssh.disconnect  ${connection}

Connect to ABIL with proxy ${proxy}
    ssh.Connect to  ${ABIL_IP}
    ...             ${ROOT_USERNAME}
    ...             ${ROOT_PASSWORD}
    ...             alias=ABIL_toor4nsn
    ...             proxy=${proxy}

Connect to admin
    [Arguments]  ${ip_address}=${LMP_IP}        ${alias}=cOAM_admin
    ...          ${username}=${WEBEM_USERNAME}  ${password}=${WEBEM_PASSWORD}

    ${connection}=  coam_gNB_operations.create_connection  ip_address=${ip_address}
    ...                                                    alias=${alias}
    ...                                                    username=${username}
    ...                                                    password=${password}
    [Return]  ${connection}

Disconnect from admin
    [Arguments]  ${alias}=cOAM_admin
    coam_gNB_operations.teardown_connection  ${alias}

Login to WebEM
    gui.enable_virtual_display
    gui.login  url=https://${LMP_IP}
    ...        username=${WEBEM_USERNAME}
    ...        password=${WEBEM_PASSWORD}

Logout from WebEM
    gui.logout
    gui.disable_virtual_display

Connect to ${ip_addr} as ${user} with SSH key ${key_path} and alias ${alias}
    ${connection}=  ssh.connect to           ${ip_addr}
    ...                                      ${user}
    ...                                      key_path=${key_path}
    ...                                      alias=${alias}
    Log to console  Successful ${user} login
    [Return]  ${connection}



