*** Settings ***
Documentation
...     description:    Keywords for test cases fot the CB006048-5G-A feature.

Library        taf.transport.ssh        WITH NAME    ssh
Library        String
Library        Collections

*** Variables ***
@{ALLOWED_DUPLICATED_PROCESSES}=  Create List    COMMAND    dhcpd    trs-ipsec-mgr

*** Keywords ***
Compare Root And Btssw Processes List
    ${bts_connection}=  Connect To BTS
    ${root_processes_list}=      ssh.Execute      ps -u root -o comm      connection=${bts_connection}
    ${btssw_processes_list}=     ssh.Execute      ps -u btssw -o comm     connection=${bts_connection}

    @{root_processes_list}=    Split String    ${root_processes_list}    \r\n
    @{btssw_processes_list}=   Split String    ${btssw_processes_list}    \r\n

    @{root_processes_list}=    Remove Duplicates    ${root_processes_list}
    @{btssw_processes_list}=   Remove Duplicates    ${btssw_processes_list}

    Remove Values From List    ${root_processes_list}    ${EMPTY}
    Remove Values From List    ${btssw_processes_list}   ${EMPTY}

    Remove Values From List    ${root_processes_list}    @{ALLOWED_DUPLICATED_PROCESSES}
    Remove Values From List    ${btssw_processes_list}   @{ALLOWED_DUPLICATED_PROCESSES}

    FOR    ${root_process}    IN    @{root_processes_list}
        List Should Not Contain Value    ${btssw_processes_list}    ${root_process}
    END

    Log  \n\nRoot processes list: ${root_processes_list}  console=${TRUE}
    Log  \n\nBtssw processes list: ${btssw_processes_list}  console=${TRUE}
    [Teardown]    Disconnect From BTS    connection=${bts_connection}


