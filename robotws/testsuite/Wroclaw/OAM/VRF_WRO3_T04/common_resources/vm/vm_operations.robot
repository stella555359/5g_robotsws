*** Settings ***
Documentation
...             Common keywords
...             Authors: Michal Wlosek, michal.wlosek@nokia.com

Library   OperatingSystem
Library   String
Library   taf.transport.ssh    WITH NAME    ssh

*** Keywords ***
Run Command And Return Output
    [Arguments]  ${command}  ${vm_address}  ${username}=ute
    ...          ${key_path}=/home/ute/.ssh/id_rsa  ${alias}=vm_conn
    ssh.connect_to
    ...    hostname=${vm_address}
    ...    username=${username}
    ...    key_path=${key_path}
    ...    alias=${alias}
    ${output}=  ssh.execute  command=${command}  connection=${alias}
    [Return]    ${output}

Get VM Hostname
    [Documentation]       Keyword Gets Hostname of Vm on which test is running
    ...                   author: michal.wlosek@nokia.com
    [Arguments]    ${vm_address}=127.0.0.1
    ${hostname_tmp}=  Run Command And Return Output    hostname    ${vm_address}
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  convert to string  ${hostname_tmp}
    ${hostname_tmp}=  Replace String    ${hostname_tmp}    \r\n    ${EMPTY}
    [Return]  ${hostname_tmp}

Get VM IP address
    [Documentation]    Description:    Getting the VM address.
    ...                Input:          None
    ...                Output:         The IP address of VM.
    ...                Author:         jagoda.kubacka@nokia.com
    ${VM_address}=    Run    ip addr | grep "scope global eth0"
    ${VM_address}=    Get Regexp Matches    ${VM_address}    \\d{1,3}[.]\\d{1,3}[.]\\d{1,3}[.]\\d{1,3}
    [Return]          ${VM_address}[0]
