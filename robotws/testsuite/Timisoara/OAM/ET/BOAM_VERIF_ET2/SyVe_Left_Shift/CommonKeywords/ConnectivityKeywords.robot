*** Settings ***
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    trs_ssh
Library     String
#Library     netact_operations.py
#Library    ../../../../SISO/Wroclaw/CommonKeywords/PythonKeywords/connections_keywords.py
Resource    RadioUnitKeywords.robot

*** Variables ***
${NETACT_USERNAME}=         sbtsoam
${NETACT_PASSWORD}=         A0zY~rP#8Mx@

${asik_addr}                     192.168.255.1
${asik_username}                 toor4nsn
${asik_password}                 oZPS0POrRieRtu


*** Keywords ***
Connect Ssh To Asix
    [Documentation]
    ...  Establish connection with ASIx via SSH
    trs_ssh.Connect To
    ...    hostname=${asik_addr}
    ...    username=${asik_username}
    ...    password=${asik_password}
    ...    alias=asik

Disconnect Ssh From Asix
    [Documentation]
    ...  Break connection with ASIx via SSH
    trs_ssh.Disconnect      connection=asik

Connect to ABIL via Asik
    trs_ssh.Connect To
    ...     hostname=${asik_addr}
    ...     username=${asik_username}
    ...     password=${asik_password}
    ...     proxy=asik
    ...     alias=abil

Disconnect from ABIL
    trs_ssh.Disconnect      connection=abil

Connect to RU via Asik
    [Arguments]   ${RU_IP}=192.168.254.52    ${username}=root    ${password}=root
    ${container_connection}=    Check if connection through lxc is enabled
    ${proxy}=    set variable if   '${container_connection}'=='True'    fhnet_container     asik
    run keyword if     '${container_connection}'=='True'     Connect to FHNET contaier
    trs_ssh.Connect To
    ...                   hostname=${RU_IP}
    ...                   username=${username}
    ...                   password=${password}
    ...                   proxy=${proxy}
    ...                   alias=ru

Connect to FHNET contaier
    [Arguments]    ${fhnet_host_ip}=192.168.255.254
    ${containers}=    trs_ssh.execute    lxc-ls     connection=asik
    ${fhnet_container}=    get regexp matches     ${containers}     \0x[12]018
    trs_ssh.send command    rm -rf /tmp/sshd_debug.log    connection=asik
    trs_ssh.send command    lxc-attach -n ${fhnet_container[0]} -- /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    ...                     connection=asik
    trs_ssh.connect to    hostname=${fhnet_host_ip}
    ...                   username=toor4nsn
    ...                   password=oZPS0POrRieRtu
    ...                   alias=fhnet_container
    ...                   proxy=asik
#
#
#Connect to ABIL Xeon via Asik
#    trs_ssh.Connect To
#    ...     hostname=192.168.253.20
#    ...     username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#    ...     password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#    ...     proxy=asik
#    ...     alias=abil
#
#Connect to second ABIL Xeon via Asik
#    trs_ssh.Connect To
#    ...     hostname=192.168.253.24
#    ...     username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#    ...     password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#    ...     proxy=asik
#    ...     alias=abil
#
#Connect to 2nd XEON 1st ABIL via Asik
#    trs_ssh.Connect To
#    ...     hostname=192.168.253.21
#    ...     username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#    ...     password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#    ...     proxy=asik
#    ...     alias=abil


Check if BBMOD is pingable
    Connect Ssh To Asix
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.20    connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.21    connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.22    connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    [Teardown]  Disconnect Ssh From Asix

Check if second BBMOD is pingable
    Connect Ssh To Asix
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.24    connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.25    connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.26    connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    [Teardown]  Disconnect Ssh From Asix

Check if BBMOD is not pingable
    Connect Ssh To Asix
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.20     connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.21     connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.22     connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
    [Teardown]  Disconnect Ssh From Asix

Check if eNB is pingable
    ${output}   Run       ping -c 1 -W 10 192.168.255.1
    Should contain      ${output}   1 packets transmitted, 1 received

Check if eNB is not pingable
    ${output}   Run       ping -c 1 -W 10 192.168.255.1
    Should contain      ${output}   1 packets transmitted, 0 received

Check if RU is pingable
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 ${RU_IP}     connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    [Teardown]  Disconnect Ssh From Asix

Check if Radio Unit is not pingable
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 ${RU_IP}     connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
    [Teardown]  Disconnect Ssh From Asix

#Connect to NetAct
#    [Arguments]     ${ip_address}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
#    ...             ${username}=${NETACT_USERNAME}
#    ...             ${password}=${NETACT_PASSWORD}
#
#    ${connection}=  Connect using netact
#    ...             ${ip_address}
#    ...             netact_server_address=${tl.test_pc.default_ssh_connection_details.addr}
#    ...             username=${username}
#    ...             password=${password}
#    Log to console  Connection via NE3S created
#    [Return]        ${connection}

Disconnect from NetAct
    [Arguments]     ${connection}
    Unregister and teardown   ${connection}

Disconnect from RU
    trs_ssh.Disconnect      connection=ru

Close Connections cOAM1
    Run Keyword And Ignore Error    close_ssh_connections
    Run Keyword And Ignore Error    close_cloud_sessions
    Run Keyword And Ignore Error    close_coam_sessions

Check if connection through lxc is enabled
    ${containers}=    trs_ssh.execute    lxc-ls     connection=asik
    ${status}=    run keyword and return status    should contain any    ${containers}    0x2018    0x1018
    [Return]    ${status}
