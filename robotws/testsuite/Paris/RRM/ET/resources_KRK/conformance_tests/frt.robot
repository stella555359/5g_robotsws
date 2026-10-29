*** Settings ***
Documentation
...               LTEEMU Management

Library           taf.transport.ssh    WITH NAME    csn


*** Keywords ***
Connect to LTEEMU
    [Arguments]    ${alias}=lteemu
    csn.connect_to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...               username=${tl.core.default_ssh_connection_details.username}
    ...               password=${tl.core.default_ssh_connection_details.password}
    ...               alias=${alias}

Ssh Execute With Timeout
    [Arguments]      ${command}     ${connection}   ${timeout}=10
    [Documentation]    Exceute command via ssh (with timeout)
    csn.Send Command    ${command}    timeout=${timeout}     connection=${connection}
    ${output}=    csn.Read Output     connection=${connection}
    [Return]    ${output}

Kill Previous services on LTEEMU
    [Arguments]
    frt.Connect to LTEEMU    alias=lteemu
    ${output}    frt.Ssh Execute With Timeout    sudo netstat -anp | grep edaemon    connection=lteemu
    ${len}    Get Length    ${output}
    ${edaemon_pid}    Run Keyword If    ${len}>0    frt.Ssh Execute With Timeout    sudo netstat -anp | grep edaemon | awk '{print $7}'
    ...     connection=lteemu
    ${edaemon_pid}    Run Keyword If    ${len}>0    Fetch From Left    ${edaemon_pid}    /
    Run Keyword If    ${len}>0    frt.Ssh Execute With Timeout    sudo kill -9 ${edaemon_pid}    connection=lteemu
    ${output}    frt.Ssh Execute With Timeout    sudo netstat -anp | grep egate    connection=lteemu
    ${len}    Get Length    ${output}
    ${egate_pid}    Run Keyword If    ${len}>0    frt.Ssh Execute With Timeout    sudo pkill -9 -f './egate.* --port ${tl.core.egate_port}'
    ...     connection=lteemu
