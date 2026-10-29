*** Settings ***
Documentation    Connection keywords regarding cOAM, variables (IP addresses etc.) for cOAM.

Library  taf.transport.ssh		    WITH NAME   ssh
Library  taf.ul.oam.selenium_coam   WITH NAME   gui
Library  coam_bts_operations.py

*** Variables ***
#${ROOT_USERNAME}=           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#${ROOT_PASSWORD}=           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${SERVICEUSER_USERNAME}=    serviceuser
${SERVICEUSER_PASSWORD}=    Pl(FzaYj5~c5;q
#${WEBEM_USERNAME}=          ${tl.gnbs[0].cu.oam_http_connection_details.username}
#${WEBEM_PASSWORD}=          ${tl.gnbs[0].cu.oam_http_connection_details.password}

${WEBEM_DEVELOPER_USERNAME}=  developer
${WEBEM_DEVELOPER_PASSWORD}=  $developer#
${RADIO_USERNAME}=          root
${RADIO_PASSWORD}=          umniedziala

${ABIL_IP}=                 192.168.253.22
#${WEBEM_IP}=                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#${LMP_IP}=                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

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

Connect to ABIL with proxy ${proxy}
    ssh.Connect to  ${ABIL_IP}
    ...             ${ROOT_USERNAME}
    ...             ${ROOT_PASSWORD}
    ...             alias=ABIL_toor4nsn
    ...             proxy=${proxy}

Connect to admin TRS keyword
    [Arguments]  ${ip_address}=${LMP_IP}        ${alias}=cOAM_admin
    ...          ${username}=${WEBEM_USERNAME}  ${password}=${WEBEM_PASSWORD}

    ${connection}=  coam_bts_operations.create_connection  ip_address=${ip_address}
    ...                                                    alias=${alias}
    ...                                                    username=${username}
    ...                                                    password=${password}
    [Return]  ${connection}

Disconnect from admin
    [Arguments]  ${alias}=cOAM_admin
    coam_bts_operations.teardown_connection  ${alias}

Login to WebEM
    gui.enable_virtual_display
    gui.login  url=https://${LMP_IP}
    ...        username=${WEBEM_USERNAME}
    ...        password=${WEBEM_PASSWORD}

Logout from WebEM
    gui.logout
    gui.disable_virtual_display

Connect to ${ip_addr} as ${user} with SSH key ${key_path} and alias ${alias}
    ssh.connect to           ${ip_addr}
    ...                      ${user}
    ...                      key_path=${key_path}
    ...                      alias=${alias}
