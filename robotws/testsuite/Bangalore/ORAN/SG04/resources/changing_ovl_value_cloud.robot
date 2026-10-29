*** Settings ***
Documentation    :copyright: Nokia
...              :author:
...              :contact:

Library      taf.transport.ssh    WITH NAME    ssh
Library      taf.gnb.oam.coam.admin    WITH NAME    coam.admin

*** Variables ***
${gNB_OAM_IP}          ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gNB_OAM_USERNAME}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gNB_OAM_PASSWORD}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${CPUE_IP}             cpue-0.local
${CPUE_USERNAME}       robot
${CPUE_PASSWORD}       rastre
${0_set_for_OVL}       LD_LIBRARY_PATH=/opt/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 0 --port 30671
${20_set_for_OVL}      LD_LIBRARY_PATH=/opt/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold --overload_high_threshold 20 --port 30671


*** Keywords ***

Connect using ssh to
    [Arguments]    ${hostname}    ${proxy}=${None}
    ssh.connect_to    hostname=${${hostname}_IP}
    ...    username=${${hostname}_USERNAME}
    ...    password=${${hostname}_PASSWORD}
    ...    alias=${hostname}    proxy=${proxy}    timeout=10 s

Set threshold for OVL
    [Arguments]    ${threshold}
    ssh.send_command   command=${${threshold}_set_for_OVL}
    ...    bufsize=100
    ...    timeout=10 s
    ...    connection=CPUE
    Sleep   2s

Disconnect from
    [Arguments]    ${hostname}
    ssh.disconnect    connection=${hostname}
