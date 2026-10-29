*** Settings ***
Documentation
...  author:  Jagoda Kubacka
...  contact: jagoda.kubacka@nokia.com

Resource    ../../../../common_resources/admin/admin.robot
Resource    ../../../../common_resources/connections/connections.robot
Resource    ../../../../common_resources/commissioning/parameters.robot
Resource    ../../../../common_resources/certificates/certificates.robot
Resource    ../../../../common_resources/applications_running_with_root/common_keywords.robot
Resource    ../../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../../../../common_resources/tls/tls.robot
Resource    ../../../../common_resources/netact/netact_operations.robot
Resource    ../../../../common_resources/passwords/password_change.robot

*** Variables ***
@{roots}    root    toor4nsn
@{system_users}    daemon    bin    ftp    sshd    ntp    dhcpd    tss    messagebus    lighttpd    btssw
...    rpcuser    rpc    dhcp    radvd    avahi    systemd-coredump    systemd-oom

*** Test Cases ***
NESAS_A_Restricted_File_Access
    # The same as: NESAS_A_Minimized_file_type_mappings
    ${conn}=    Connect to BTS
    ssh.execute    command=cd /opt/SysAdapter
    ...            connection=${conn}
    ${output}    ssh.execute    command=ls -la
    ...                         connection=${conn}
    @{list}    Split String    ${output}    \n
    FOR    ${i}    IN    @{list}
        ${if_contain}    Run Keyword And Return Status    Should Contain    ${i}    btssw
        IF    '${if_contain}'=='${True}'
            ${element}    Split String    ${i}
            ${owner}      Set Variable    ${element}[2]
            ${group}      Set Variable    ${element}[3]
            Log    Wlascicielem jest ${owner} a wykryta grupa to ${group}    console=True
            Should Be Equal    ${owner}    root
            Should Be Equal    ${group}    btssw
        END
    END
    ${process}    ssh.execute    command=ps -ef | grep SysAdapter | grep -v grep
    ...                         connection=${conn}
    ${process}     Split String    ${process}
    ${owner}    Set Variable    ${process}[0]
    Log    Wlascicielem procesu SysAdapter jest ${owner}    console=True
    Should Not Contain    ${owner}    root
    [Teardown]    Disconnect from BTS    ${conn}

NESAS_A_No_system_privileges_for_web_server
    ${conn}=    Connect to BTS
    ${output}    ssh.execute    command=cat /etc/passwd    connection=${conn}
    @{passwd_lines}    Split To Lines    ${output}
    FOR    ${i}    IN    @{passwd_lines}
        @{user}    Split String    ${i}    :
        ${username}    Set Variable    ${user}[0]
        ${uid}    Set Variable    ${user}[2]
        ${gid}    Set Variable    ${user}[3]
        ${shell}    Set Variable    ${user}[6]
        IF    '${username}' in @{roots}
            Log to console    Sprawdzany user to ${username}    console=true
            Should Be Equal    ${uid}    0
            Should Be Equal    ${gid}    0
            Should Be Equal    ${shell}    /bin/bash
        ELSE IF    '${username}' in @{system_users}
            Log to console    Sprawdzany user to ${username}    console=true
            ${uid_int}    Convert To Integer    ${uid}
            ${result}    Evaluate    1 <= ${uid_int} <=999
            Should Be True    ${result}
            Should Not Be Equal    ${gid}    0
        ELSE
            Log to console    Sprawdzany user to ${username}    console=true
            ${uid_int}    Convert To Integer    ${uid}
            ${result}    Evaluate    ${uid_int} > 999
            Should Be True    ${result}
            Should Not Be Equal    ${gid}    0
        END
    END
    ${output}    ssh.execute    command=netstat -intup    connection=${conn}
    @{interfaces}    Split String    ${output}    \n
    ${header}    Get From List    ${interfaces}    1
    FOR    ${i}    IN    @{interfaces}[2:-1]
        @{element}     Split String    ${i}
        ${iface}       Get From List   ${element}    0
        ${length}      Get Length        ${element}
        IF    ${length}>8
            ${rx_err}=     Get From List   ${element}    3
            ${rx_drp}=     Get From List   ${element}    4
            ${rx_ovr}=     Get From List   ${element}    5
            ${tx_err}=     Get From List   ${element}    7
            ${tx_drp}=     Get From List   ${element}    8
            ${tx_ovr}=     Get From List   ${element}    9
            Log    Interfejs: ${iface}, RX-ERR: ${rx_err}, RX-DRP: ${rx_drp}, RX-OVR: ${rx_ovr},    console=true
            Log    TX-ERR: ${tx_err}, TX-DRP: ${tx_drp}, TX-OVR: ${tx_ovr}    console=true
        ELSE
            ${different}    Split String    ${i}    -
            Should Contain    ${different}[1]    no statistics available
        END
    END
    [Teardown]    Disconnect from BTS    ${conn}
