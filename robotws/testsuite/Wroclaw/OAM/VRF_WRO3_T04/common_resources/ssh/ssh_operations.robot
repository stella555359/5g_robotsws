*** Settings ***
Documentation   Keywords regarding getting values from BTS via ssh connection
...             Author:     Artur Czainski
...             Contact:    artur.czainski@nokia.com

Library         taf.transport.ssh    WITH NAME    ssh
Library         String

*** Keywords ***
Get IP Address For All RUs
    [Arguments]    ${bts_host}=${SSH_IP}
    [Documentation]  Returns List of IP Addresses for All Radio Units
    ${node}=         Get NodeId For Your Airscale    bts_host=${bts_host}
    ssh.Connect To   hostname=${bts_host}
    ...              username=${SSH_USERNAME}
    ...              password=${SSH_PASSWORD}
    ...              alias=radio_ip
    ${output}=       ssh.execute    cat /ffs/run/config/FRIps.txt | cut -d';' -f3
    ...                             connection=radio_ip
    ${output_stripped}=    Strip String    string=${output}             characters=\r\n
    ${radio_ip_list}=      Split String    string=${output_stripped}    separator=\r\n
    [Return]      ${radio_ip_list}
    [Teardown]    ssh.Disconnect    connection=radio_ip

Get NodeId For Your Airscale
    [Arguments]    ${bts_host}=${SSH_IP}
    [Documentation]  Returns 0x1018 or 0x2018 depends on SMOD position in AMIA
    ssh.Connect To   hostname=${bts_host}
    ...              username=${SSH_USERNAME}
    ...              password=${SSH_PASSWORD}
    ...              alias=node_id
    ${node}=         ssh.Execute    command=lxc-ls --active --filter=0x[12]018    connection=node_id
    ${node}=         Strip String    ${node}    characters= \r\n
    [Return]      ${node}
    [Teardown]    ssh.Disconnect    connection=node_id

Get Fronthaul IP address
    ${conn}     Connect to ADMIN
    ${x}        admin.Get Managed Objects    class_name=RMOD_L    connection=${conn}
    ${y}        Convert to string    ${x}
    @{match}    Get Regexp Matches    ${y}    ipAddress['"]?: ['"]?([0-9.]+)
    @{fhip_list}    Create List
    FOR    ${i}     IN    @{match}
        ${status}              Run Keyword And Return Status    Should Not Contain    ${i}    0.0.0.0
        IF  ${status}
            ${match_i}         Get Regexp Matches    ${i}    [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+
            Append To List     ${fhip_list}    ${match_i}[0]
            Exit For Loop
        END
    END
    [Return]      ${fhip_list}[0]
    [Teardown]    Disconnect from ADMIN    ${conn}

Get Fronthaul RU Name With IP
    ${conn}     Connect to ADMIN
    @{x}        admin.Get Managed Objects    class_name=RMOD_L    connection=${conn}
    ${y}        Get Length    ${x}
    ${ru_dict}=               Create Dictionary
    FOR    ${i}    IN    @{x}
        ${ru_ip}     Set Variable    ${i}[parameters][ipAddress]
        ${status}    Run Keyword And Return Status    Should Not Contain    ${ru_ip}    0.0.0.0
        IF    not ${status}
            Continue For Loop
        END
        ${ru_name}    Set Variable    ${i}[parameters][productName]
        Set To Dictionary    ${ru_dict}    ${ru_name}=${ru_ip}
    END
    [Return]      ${ru_dict}
    [Teardown]    Disconnect from ADMIN    ${conn}
