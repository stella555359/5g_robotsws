*** Settings ***
Documentation
...    Author:          Bartlomiej Lebda | Jakub Klein
...    Maintainer:      Bartlomiej Lebda | Jakub Klein
...    Contact:         bartlomiej.lebda@nokia.com jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Description:     The following keywords are responsible for connection operations

Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    trs_ssh
Library     String
Library     ../NetAct/NetAct_resources/netact_operations.py
Library     ../Connections/Connections_resources/connections_keywords.py
Resource    ../Component_operations/RU_operation.robot
Resource    ../Admin_CLI/Basic_WebEM_operation.robot
*** Variables ***
${NETACT_USERNAME}=         sbtsoam
${NETACT_PASSWORD}=         A0zY~rP#8Mx@

*** Keywords ***
Connect Ssh To Asix
    [Documentation]
    ...  Establish connection with ASIx via SSH
    [Arguments]    ${connection}=asik
    trs_ssh.Connect To
    ...    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${connection}

Disconnect Ssh From Asix
    [Documentation]
    ...  Break connection with ASIx via SSH
    [Arguments]    ${connection}=asik
    trs_ssh.Disconnect      connection=${connection}

Connect to ABIL via Asik
    [Arguments]    ${proxy}=asik    ${connection}=abil
    trs_ssh.Connect To
    ...     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
    ...     username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...     password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...     proxy=${proxy}
    ...     alias=${connection}

Disconnect from ABIL
    [Arguments]    ${connection}=abil
    trs_ssh.Disconnect      connection=${connection}

Connect to RU via address from info model
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Establishing a connection to the indicated RMOD, based on the address of the L-type RMOD object
    ...     from info_model view.
    ...     As arguments it takes:
    ...                            - ru_id - RU ID from info_model view(object _L). By default is '1'
    ...                            - ru_login - by default is 'root'
    ...                            - ru_password - by default is 'umniedziala'
    ...                            - smod_connection - by default alias is 'asik'
    ...                            - rmod_connection - by default alias is 'ru'
    ...                            - cli_connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]  ${ru_id}=1    ${ru_login}=root    ${ru_password}=umniedziala
    ...          ${smod_connection}=asik    ${rmod_connection}=ru    ${cli_connection}=default
    ${RU_IP}       Get RU IP from Info Model    ${ru_id}    ${cli_connection}
    Connect Ssh To Asix       ${smod_connection}
    Connect to RU via Asik    ${RU_IP}    ${ru_login}    ${ru_password}    ${smod_connection}    ${rmod_connection}

Connect to RU via Asik
    [Arguments]   ${RU_IP}=192.168.254.52    ${username}=root    ${password}=umniedziala    ${proxy}=asik
    ...           ${connection}=ru
    ${container_connection}=    Check if connection through lxc is enabled    ${proxy}
    ${kw_proxy}=    set variable if   '${container_connection}'=='True'    fhnet_container     ${proxy}
    run keyword if     '${container_connection}'=='True'     Connect to FHNET contaier    proxy=${proxy}
    trs_ssh.Connect To
    ...                   hostname=${RU_IP}
    ...                   username=${username}
    ...                   password=${password}
    ...                   proxy=${kw_proxy}
    ...                   alias=${connection}

Connect to FHNET contaier
    [Arguments]    ${fhnet_host_ip}=192.168.255.254    ${proxy}=asik    ${connection}=fhnet_container
    ${containers}=    trs_ssh.execute    lxc-ls     connection=${proxy}
    ${fhnet_container}=    get regexp matches     ${containers}     \0x[12]018
    trs_ssh.send command    rm -rf /tmp/sshd_debug.log    connection=${proxy}
    trs_ssh.send command    lxc-attach -n ${fhnet_container[0]} -- /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    ...                     connection=${proxy}
    trs_ssh.connect to    hostname=${fhnet_host_ip}
    ...                   username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                   password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                   proxy=${proxy}
    ...                   alias=${connection}

Connect to ABIL Xeon via Asik
    [Arguments]    ${proxy}=asik    ${connection}=abil
    trs_ssh.Connect To
    ...     hostname=192.168.253.20
    ...     username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...     password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...     proxy=${proxy}
    ...     alias=${connection}

Connect to second ABIL Xeon via Asik
    [Arguments]    ${proxy}=asik    ${connection}=abil
    trs_ssh.Connect To
    ...     hostname=192.168.253.24
    ...     username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...     password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...     proxy=${proxy}
    ...     alias=${connection}

Connect to 2nd XEON 1st ABIL via Asik
    [Arguments]    ${proxy}=asik    ${connection}=abil
    trs_ssh.Connect To
    ...     hostname=192.168.253.21
    ...     username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...     password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...     proxy=${proxy}
    ...     alias=${connection}


Check if BBMOD is pingable
    [Arguments]    ${connection}=asik
    Connect Ssh To Asix
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.20    connection=${connection}
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.21    connection=${connection}
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.22    connection=${connection}
    Should contain      ${output}   1 packets transmitted, 1 received
    [Teardown]  Disconnect Ssh From Asix

Check if second BBMOD is pingable
    [Arguments]    ${connection}=asik
    Connect Ssh To Asix
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.24    connection=${connection}
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.25    connection=${connection}
    Should contain      ${output}   1 packets transmitted, 1 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.26    connection=${connection}
    Should contain      ${output}   1 packets transmitted, 1 received
    [Teardown]  Disconnect Ssh From Asix

Check if BBMOD is not pingable
    [Arguments]    ${connection}=asik
    Connect Ssh To Asix
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.20     connection=${connection}
    Should contain      ${output}   1 packets transmitted, 0 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.21     connection=${connection}
    Should contain      ${output}   1 packets transmitted, 0 received
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 192.168.253.22     connection=${connection}
    Should contain      ${output}   1 packets transmitted, 0 received
    [Teardown]  Disconnect Ssh From Asix

Check if eNB is pingable
    [Arguments]    ${eNB_ip}=192.168.255.1
    ${output}   Run       ping -c 1 -W 10 ${eNB_ip}
    Should contain      ${output}   1 packets transmitted, 1 received

Check if eNB is not pingable
    [Arguments]    ${eNB_ip}=192.168.255.1
    ${output}   Run       ping -c 1 -W 10 ${eNB_ip}
    Should contain      ${output}   1 packets transmitted, 0 received

Check if RU is pingable
    [Arguments]    ${ru_id}=1    ${connection}=default    ${connection_smod}=asik
    Connect Ssh To Asix    ${connection_smod}
    ${RU_IP}=     Get RU IP from Info Model    ${ru_id}    ${connection}
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 ${RU_IP}     connection=${connection_smod}
    Should contain      ${output}   1 packets transmitted, 1 received
    [Teardown]  Disconnect Ssh From Asix    ${connection_smod}

Check if Radio Unit is not pingable
    [Arguments]    ${ru_id}=1    ${connection}=default    ${connection_smod}=asik
    Connect Ssh To Asix    ${connection_smod}
    ${RU_IP}=     Get RU IP from Info Model    ${ru_id}    ${connection}
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 ${RU_IP}     connection=${connection_smod}
    Should contain      ${output}   1 packets transmitted, 0 received
    [Teardown]  Disconnect Ssh From Asix    ${connection_smod}

Connect to NetAct
    [Arguments]     ${ip_address}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    ...             ${username}=${NETACT_USERNAME}
    ...             ${password}=${NETACT_PASSWORD}

    ${connection}=  Connect using netact
    ...             ${ip_address}
    ...             netact_server_address=${tl.test_pc.default_ssh_connection_details.addr}
    ...             username=${username}
    ...             password=${password}
    Log to console  Connection via NE3S created
    [Return]        ${connection}

Disconnect from NetAct
    [Arguments]     ${connection}
    Unregister and teardown   ${connection}

Disconnect from RU
    [Arguments]    ${connection}=ru
    trs_ssh.Disconnect      connection=${connection}

Close Connections cOAM1
    Run Keyword And Ignore Error    close_ssh_connections
    #Run Keyword And Ignore Error    close_cloud_sessions
    Run Keyword And Ignore Error    close_coam_sessions

Check if connection through lxc is enabled
    [Arguments]    ${connection}=asik
    ${containers}=    trs_ssh.execute    lxc-ls     connection=${connection}
    ${status}=    run keyword and return status    should contain any    ${containers}    0x2018    0x1018
    [Return]    ${status}

Restore Default Ethif cOAM1
    [Documentation]  Restores default VM's ethernet interfaces by running networking restart command with
    ...              setting eth1 up.
    [Arguments]    ${number_of_rus}=1
    Reset Ethif cOAM1    ${number_of_rus}
    ${return_code}    ${output}=    OperatingSystem.Run And Return Rc And Output
         ...    sudo /etc/init.d/networking restart
    run keyword if    ${return_code}!=0    log    ${output}    level=WARN
    ${return_code}    ${output}=    OperatingSystem.Run And Return Rc And Output
         ...    sudo ip link set eth1 up
    run keyword if    ${return_code}!=0    log    ${output}    level=WARN

Reset Ethif cOAM1
    [Arguments]     ${number_of_rus}=1
    @{rus_iter}=    evaluate    list(range(1, ${number_of_rus}+1))

    FOR    ${ethif_counter}    IN    @{rus_iter}
        ${return_code}    ${output}=    OperatingSystem.Run And Return Rc And Output
        ...    sudo ip link set eth${ethif_counter} down
        run keyword if    ${return_code}!=0    log    ${output}    level=WARN
        ${return_code}    ${output}=    OperatingSystem.Run And Return Rc And Output
        ...    sudo ip addr flush dev eth${ethif_counter}
        run keyword if    ${return_code}!=0    log    ${output}    level=WARN
    END
