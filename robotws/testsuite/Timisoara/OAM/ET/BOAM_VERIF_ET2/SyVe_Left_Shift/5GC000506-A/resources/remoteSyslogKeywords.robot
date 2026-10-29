*** Settings ***
Library  Process
Library  taf.transport.ssh  WITH NAME  transport_ssh
Library  OperatingSystem
Library  String
Library  Collections
Library  remoteSyslogFilters.py   WITH NAME   RemoteSyslogFilters


*** Variables ***
${SerwerConnectionAlias}     SerwerConnection

*** Keywords ***

clear syslogs on server
    Run  sudo rm -rf /var/log/btslog-udp.json

clear syslogs on server for ip
    [Arguments]  ${remoteServerIp}   ${btsIpAdress}
    transport_ssh.Connect to
    ...     ${remoteServerIp}
    ...     ute
    ...     ute
    ...     alias=${SerwerConnectionAlias}

    transport_ssh.Send Command
    ...     sudo > /var/log/hosts/${btsIpAdress}/syslog.log
    ...     get_pty=${True}
    ...     connection=${SerwerConnectionAlias}

    ${output}    transport_ssh.Read Output     connection=${SerwerConnectionAlias}

    [Teardown]  transport_ssh.Disconnect    connection=${SerwerConnectionAlias}

Resolve logs to .log type
    Run  sudo cp /var/log/btslog-udp.json /home/ute/btslog-udp.log


get logs from remote server for ip
    [Arguments]  ${remoteServerIp}   ${btsIpAdress}   ${outputPath}
    transport_ssh.Connect to
    ...     ${remoteServerIp}
    ...     ute
    ...     ute
    ...     alias=${SerwerConnectionAlias}

    transport_ssh.Send Command
    ...     sudo cp /var/log/hosts/${btsIpAdress}/syslog.log /home/ute/syslog_${btsIpAdress}.log
    ...     get_pty=${True}
    ...     connection=${SerwerConnectionAlias}

    ${output}    transport_ssh.Read Output     connection=${SerwerConnectionAlias}

    transport_ssh.Send Command
    ...     sudo chown ute:ute /home/ute/syslog_${btsIpAdress}.log
    ...     get_pty=${True}
    ...     connection=${SerwerConnectionAlias}

    ${output}    transport_ssh.Read Output     connection=${SerwerConnectionAlias}

    transport_ssh.Download File    /home/ute/syslog_${btsIpAdress}.log    ${outputPath}   connection=${SerwerConnectionAlias}

    [Teardown]  transport_ssh.Disconnect    connection=${SerwerConnectionAlias}

check chronology of syslog
    [Arguments]  ${syslogPath}
    ${result}  RemoteSyslogFilters.check chronology of syslog   ${syslogPath}
    [Return]  ${result}
