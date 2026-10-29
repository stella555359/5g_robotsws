*** Settings ***
Documentation
...  author:   Patryk Tatarek
...  contact:  patryk.tatarek@nokia.com

Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/netact/netact_operations.robot

Library     SSHLibrary

*** Variables ***
${logs_dest}=    ${OUTPUT_DIR}/ATL_logs.xml

*** Keywords ***
Crash Event After Killing A Process
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    Sleep    5          reason=Wait until terminal execute the command
    SSHLibrary.Write    lxc-attach -n 0x1018
    Sleep    5          reason=Wait until terminal execute the command
    SSHLibrary.Write    ps -ef | grep -i SYSCOM | grep -v grep
    Sleep    5          reason=Wait until terminal execute the command
    ${string}=          SSHLibrary.Read
    ${id}=              Get Substring    ${string}    11    14
    Sleep    5          reason=Wait until terminal execute the command
    SSHLibrary.Write    kill -9 ${id}
    Sleep    5          reason=Wait until terminal execute the command
    SSHLibrary.Write    exit
    SSHLibrary.Close Connection
    FOR    ${i}    IN RANGE    300
         ${ping}=    Run    ping -c 2 192.168.255.129
         ${exit}=    Run Keyword And Return Status    Should Contain    ${ping}    100% packet loss
         Exit For Loop If    ${exit}==True
    END
    Wait until keyword succeeds   30 min  60sec  Check if BTS status is Configured or OnAir
    Sleep    600                  reason=Wait more time to be sure that logs have been generated
    ${connection}=                Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-${tl.gnbs[0].global_bts_id}    ${logs_dest}
    ${crash_log}=                 Grep File    ${logs_dest}    BTS Reboot; RebootReason: Recovery
    Should Contain                ${crash_log}     BTS Reboot; RebootReason: Recovery
    [Teardown]                    Disconnect from NetAct    ${connection}

Reboot Event After Reboot Command
    Connect to BTS
    ssh.execute    command=reboot  connection=cOAM_toor4nsn
    FOR    ${i}    IN RANGE    100
         ${ping}=    Run    ping -c 2 192.168.255.129
         ${exit}=    Run Keyword And Return Status    Should Contain    ${ping}    100% packet loss
         Exit For Loop If    ${exit}==True
    END
    Wait until keyword succeeds   30 min  60sec  Check if BTS status is Configured or OnAir
    Sleep    600                  reason=Wait more time to be sure that logs have been generated
    ${connection}=                Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-${tl.gnbs[0].global_bts_id}    ${logs_dest}
    ${reboot_log}=                Grep File    ${logs_dest}    Autonomous reset triggered by unknown
    Should Contain                ${reboot_log}     Autonomous reset triggered by unknown
    [Teardown]    Run Keywords    Disconnect from BTS
    ...           AND             Disconnect from NetAct    ${connection}
    ...           AND             Reset Site And Reconnect

Parameter Changing Event Should Be Store In ATL Logs
    Change Parameter on BTS       dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                           param_name=maxNumSnapByFaultTrigPerDay
    ...                           param_value=38
    Sleep    900                  reason=Wait more time to be sure that logs have been generated
    ${connection}=                Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-${tl.gnbs[0].global_bts_id}    ${logs_dest}
    ${log_content}=               OperatingSystem.Get File    ${logs_dest}
    Should Contain                ${log_content}     {"maxNumSnapByFaultTrigPerDay":38}
    Should Contain                ${log_content}     <interfaceType>NE3S</interfaceType>
    [Teardown]    Run Keywords               Disconnect from NetAct    ${connection}
    ...    AND    Change Parameter on BTS    dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                      param_name=maxNumSnapByFaultTrigPerDay
    ...                                      param_value=24
