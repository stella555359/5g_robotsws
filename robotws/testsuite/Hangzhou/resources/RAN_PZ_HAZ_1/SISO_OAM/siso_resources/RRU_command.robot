*** Settings ***
Documentation
...    Author:        qiang.1.zhou@nokia.com
...    Maintainer:    qiang.1.zhou@nokia.com

Variables    ./ru_variable.py
Library    SSHLibrary
Library    OperatingSystem
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/parse_soap.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/os_operation.py

*** Keywords ***
Send RRU Command
    [Arguments]    ${RRU_IP}    ${rrucommand}    ${RRU_Port}=23
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...   SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...   SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    Run Keyword If    '${RRU_Port}'=='2323'    SSHLibrary.Write    telnet ${RRU_IP} 2323\n
    ${out}    Run Keyword If    '${RRU_Port}'=='2323'    SSHLibrary.Read Until    $
    ${out}    Run Keyword If    '${RRU_Port}'=='2323'    SSHLibrary.Write    ${rrucommand}\n
    ${out}    Run Keyword If    '${RRU_Port}'=='2323'    SSHLibrary.Read Until    $
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Write    telnet ${RRU_IP} 23\n
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Read Until    login:
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Write    root\n
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Read Until    d:
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Write    root\n
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Read Until    \#
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Write    ${rrucommand}\n
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Read Until    \#
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send RRU Command Mmimo
    [Arguments]    ${RRU_IP}    ${rrucommand}    ${RRU_Port}=23    ${prompt}=$
    ${type_name}=    Evaluate    type($rrucommand).__name__=='list'
    @{rrucommand_list}=    run keyword if    '${type_name}'!='True'
    ...   create list    ${rrucommand}    ELSE    set variable    ${rrucommand}
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    Run Keyword If    '${RRU_Port}'!='22'    SSHLibrary.Write    telnet ${RRU_IP} ${RRU_Port}
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Read Until    login:
    ${out}    Run Keyword If    '${RRU_Port}'=='23'    SSHLibrary.Write    root
    ${prompt}=    Set Variable If    '${RRU_Port}'=='2000'    ^]'.    ${prompt}
    ${out}    Run Keyword If    '${RRU_Port}'!='22'    SSHLibrary.Read Until    ${prompt}
    ${out_ssh_rsa}     Run Keyword And Return Status      Variable Should Exist     ${SSH_RSA}
    ${out}    Run Keyword If    ${out_ssh_rsa} and '${RRU_Port}'=='22'    SSHLibrary.Write
    ...    ssh ${SSH_RSA_CMD} root@${RRU_IP}
    ...    ELSE IF    '${RRU_Port}'=='22'     SSHLibrary.Write    ssh root@${RRU_IP}
    ${status}    Run Keyword If    '${RRU_Port}'=='22'    Run Keyword And Return Status    SSHLibrary.Read Until    $
    ${out}    Run Keyword If    '${RRU_Port}'=='22' and '${status}'=='False'    Run Keyword And Ignore Error
    ...    Run Keywords    SSHLibrary.Write    yes    AND    SSHLibrary.Read Until    $
    ${prompt}=    Set Variable If    '${RRU_Port}'=='2000'    done ok    $
    FOR    ${cmd_tmp}    IN    @{rrucommand_list}
        ${out}    SSHLibrary.Write    ${cmd_tmp}
        ${out}    SSHLibrary.Read Until    ${prompt}
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send RRU Command via Telnet Rel5
    [Arguments]    ${RRU_IP}    ${rrucommands}
    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'
    ...    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    telnet ${RRU_IP} 2000
    ${out}    wait until keyword succeeds    1 min    10 sec    SSHLibrary.Read Until    '^]'
    FOR    ${command}    IN    @{rrucommands}
        ${out}    SSHLibrary.Write    ${command}
        ${out}    SSHLibrary.Read Until   done
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send RRU Command via SSH Rel5
    [Arguments]    ${RRU_IP}    ${rrucommands}
    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x1018\n
#    : FOR    ${command}    IN    @{rrucommands}
#    \    ${out}    SSHLibrary.Write    ${command}
#    \    ${out}    SSHLibrary.Read Until    \#
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh -o StrictHostKeyChecking\=no ${RRU_IP}
#    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
#    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    \#
    FOR    ${command}    IN    @{rrucommands}
        ${out}    SSHLibrary.Write    ${command}
        ${out}    SSHLibrary.Read Until    \#
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send Agent RRU Command via SSH Rel6
    [Arguments]    ${RRU_IP}    ${rrucommands}
    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh rfsw@${RRU_IP}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    ${out_is_trunk}   Run Keyword And Return Status    Should Match Regexp   ${SW_RELEASE}   SBTS(00|21B)+
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Write    ${tl_config.RF_FAULT_INFO['password']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    $
#    ${out}    SSHLibrary.Write    ssh root@192.168.101.2
#    ${out}    SSHLibrary.Read Until    made
    ${out}    SSHLibrary.Write    frmonShellClient localhost 2000
    ${out}    SSHLibrary.Read Until    $
    FOR    ${command}    IN    @{rrucommands}
        ${out}    SSHLibrary.Write    ${command}
        ${out}    SSHLibrary.Read Until    done ok
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send RRU Command via SSH Rel6
    [Arguments]    ${RRU_IP}    ${rrucommands}
    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...     Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh ${RRU_IP}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    ${out_is_trunk}   Run Keyword And Return Status    Should Match Regexp   ${SW_RELEASE}   SBTS(00|21B)+
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Write    ${tl_config.RF_FAULT_INFO['password']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    \#
    FOR    ${command}    IN    @{rrucommands}
        ${out}    SSHLibrary.Write    ${command}
        ${out}    SSHLibrary.Read Until    \#
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send Ping RRU Command via SSH Rel6
    [Arguments]    ${RRU_IP}
    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ping ${RRU_IP}
    ${out}    Wait Until Keyword Succeeds    600s    1s    SSHLibrary.Read Until    from ${RRU_IP}: icmp
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send RRU Command via SSH Rel5 AZNA
    [Arguments]    ${RRU_IP}    ${rrucommands}
    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${RRU_IP}    ^172
    ${ret}     Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${ret}    0x1018

    ${info}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command     uboot_env get
    ${info1}   Run Keyword And Ignore Error    Should Match Regexp    ${info}    active_partition=1
    ${info2}   Run Keyword And Ignore Error    Should Match Regexp    ${info}    active_partition=2

    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'
    ...    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Run Keyword And Ignore Error    SSHLibrary.Write    rm -r -f /user/toor4nsn/.ssh/known_hosts
#    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If
#    ...    '${info1[0]}'=='PASS'    SSHLibrary.Write     ${rrucommands['fs1']}
#    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${info2[0]}'=='PASS'
#    ...    SSHLibrary.Write     ${rrucommands['fs2']}
#    : FOR    ${command}    IN    @{rrucommands}
#    \    ${out}    SSHLibrary.Write    ${command}
#    \    ${out}    SSHLibrary.Read Until    \#
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh ${RRU_IP}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    \#
    FOR    ${command}    IN    @{rrucommands}
        ${out}    SSHLibrary.Write    ${command}
        Sleep    2s
        ${out}    SSHLibrary.Read Until    \#
        Sleep    2s
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send RRU Command Check Antenna Calibration ECPRI
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${ru_password}
    SSHLibrary.Open Connection    ${host_ip}    timeout=20   alias=ping_rf
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    rm /user/toor4nsn/.ssh/known_hosts
    ${out}    SSHLibrary.Write    ssh serviceuser@${rru_ip}
    ${out}    wait until keyword succeeds    1 min    10 sec    SSHLibrary.Read Until
    ...    Are you sure you want to continue connecting (yes/no/[fingerprint])?
    ${out}    SSHLibrary.Write    yes
    ${out}    SSHLibrary.Read Until    password:
    ${out}    SSHLibrary.Write    ${ru_password}
    ${out}    SSHLibrary.Read Until    $
    ${out}    SSHLibrary.Write    sudo su rfsw
    ${out}    SSHLibrary.Read Until    $
    ${out}    SSHLibrary.Write   bfcali -stat
    ${out}    SSHLibrary.Read    delay=300
    SSHLibrary.Close Connection
    [Return]    ${out}

Send RRU Command Check Antenna Calibration AEQP
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    SSHLibrary.Open Connection    ${host_ip}    timeout=20   alias=ping_rf
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    rm /user/toor4nsn/.ssh/known_hosts
    ${out}    SSHLibrary.Write    ssh serviceuser@${rru_ip}
    ${out}    wait until keyword succeeds    1 min    10 sec    SSHLibrary.Read Until
    ...    Are you sure you want to continue connecting (yes/no/[fingerprint])?
    ${out}    SSHLibrary.Write    yes
    ${out}    SSHLibrary.Read Until    password:
    ${out}    SSHLibrary.Write    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
#    ${out}    SSHLibrary.Write    su root
#    ${out}    SSHLibrary.Read Until    Password:
#    ${out}    SSHLibrary.Write    a2%FgSz3$fHmdusap354xujw7a
    ${out_is_trunk}   Run Keyword And Return Status    Should Match Regexp   ${SW_RELEASE}   SBTS00+
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Read Until    $
    ...    ELSE    SSHLibrary.Read Until   :~#
#    ${out}    SSHLibrary.Read Until    $
    ${out}    SSHLibrary.Write   sudo bfcali -stat
    ${out}    SSHLibrary.Read    delay=300
    SSHLibrary.Close Connection
    [Return]    ${out}

Send RRU Command Trigeer Fault 4698
    [Arguments]    ${RRU_IP}    ${rrucommand_list}
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10    alias=rf_alarm
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret1}    SSHLibrary.Execute Command    lxc-ls --active
    ${ret2}    Run Keyword And Ignore Error    Should Match Regexp    ${ret1}    0x.*018
    Run Keyword If    '${ret2[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n ${ret2[1]}\n
    ${out}    SSHLibrary.Read Until    >
    ${is_exist}    Run Keyword And Return Status     Variable Should Exist    ${RFSW_PASSWORD}
    ${out}    Run Keyword If    ${is_exist}
    ...    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no rfsw@${RRU_IP}
    ...    ELSE    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no ${RRU_IP}
    ${status}    Run Keyword If    ${is_exist}
    ...    Run Keyword And Return Status    SSHLibrary.Read Until    password
    Run Keyword If    ${is_exist}    Run Keyword If    ${status}    SSHLibrary.Write     ${RFSW_PASSWORD}
    ${out}    Run Keyword If    ${is_exist}    SSHLibrary.Read Until    $
    ...    ELSE    SSHLibrary.Read Until    \#
    ${out}    SSHLibrary.Write    frmonShellClient\n
    ${out}    SSHLibrary.Read Until    frmonShellClient starting on ip:localhost port:2000
    FOR    ${command}    IN    @{rrucommand_list}
        ${out}    SSHLibrary.Write    ${command}\r\n
        ${out}    Run Keyword If    "${command}"=="/ action create SfpInfo /sfp"
        ...    Run Keyword And Ignore Error    SSHLibrary.Read Until    done ok
        ...    ELSE    SSHLibrary.Read Until    done ok
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Connect to RU With SSH
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]  ${ru_index}   ${ru_info}    ${ru_alias}=RU   ${asik_alias}=ASIK Master
    ...          ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ${ru_ip_addr}    Set Variable    ${ru_info['parameters']["ipAddress"]}
	${container_id}    Get FHNET Container ID2    asik_alias=${asik_alias}
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU Via FHNET Container2    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${asik_alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...                                         ru_index=${ru_index}
    ...                                         ru_info=${ru_info}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${asik_alias}

Connect To RU By ServiceAccount2
    [Documentation]   Auther: jiangjing.lin@nokia-sbell.com
    ...               Description: log in ru with service accout, then add sudo for service account
    [Arguments]  ${ru_ip_addr}    ${service_username}    ${service_password}    ${root_username}    ${root_password}
    ...    ${container_alias}=Container    ${service_alias}=SERVICE    ${ru_alias}=RU
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${service_username}
    ...               password=${service_password}
    ...               alias=${service_alias}
    ...               proxy=${container_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${service_alias}
    ${channel_service}    Call Method    ${connection_service}    invoke_shell
    Call Method    ${channel_service}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel_service}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${port}    get_idle_port    connection=${connection_service}
    ${time}  get time  epoch
    ${start_sshd}    Set Variable    sudo /usr/sbin/sshd -p ${port} -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug_${time}.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel_service}    send    ${start_sshd}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel_service}    recv    ${65535}
    ${get_sshd_port}    Set Variable    ps -ef|grep sshd|grep -v grep|grep 'PermitRootLogin yes'|awk '{print $7}'
    Call Method    ${channel_service}    send    ${get_sshd_port}\n
    Sleep    3 sec
    ${output}    Call Method    ${channel_service}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${output}=    Split String    ${output}    \r\n
    ${port}    set variable    ${output[1]}
    Call Method    ${channel_service}    close
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${root_username}
    ...               password=${root_password}
    ...               port=${port}
    ...               alias=${ru_alias}
    ...               proxy=${service_alias}

Connect To RU Via FHNET Container2
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...               Description: Connect To RU Via FHNET Container2
    ...               ContainerID is 0x1018 for left side of AMIA, 0x2018 for right side.
    ...               eth0(FHNET) ip is 192.168.255.254
    [Arguments]    ${ru_ip_addr}    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...            ${ru_index}=${1}
    ...            ${coam_connection}=GNB_OAM
    ...            ${ru_info}=${1}
    Log    ${ru_index}
    Log    ${coam_connection}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    #${version_active_sw}    Coam Get Active SW Version    connection=${coam_connection}
    #${release}    Set Variable     22R4
    #${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}    connection=${coam_connection}
    ${radio_type}    set variable    ${ru_info["parameters"]["productName"]}
    Run keyword if
    ...    '${active_sw_version}' in @{release_need_service_account} and '${radio_type}' in @{ru_login_with_service_account}
    ...    Connect To RU By ServiceAccount2
    ...            ru_ip_addr=${ru_ip_addr}
    ...            service_username=${service_username}
    ...            service_password=${service_password_${active_sw_version}}
    ...            root_username=${root_username}
    ...            root_password=${root_password}
    ...            container_alias=${container_alias}
    ...            ru_alias=${ru_alias}
    ...    ELSE    Run Keyword    csn.connect to
    ...                      hostname=${ru_ip_addr}
    ...                      username=${ru_username}
    ...                      password=${ru_password}
    ...                      alias=${ru_alias}
    ...                      proxy=${container_alias}

Get FHNET Container ID2
    [Arguments]    ${asik_alias}=ASIK Master
    ${hostname}=    csn.execute    command=hostname    connection=${asik_alias}
    ${container_id}=    Set Variable If    'fct-0a' in '''${hostname}''' or 'asc-0a' in '''${hostname}'''    0x1018
    ...    'fct-4a' in '''${hostname}'''    0x2018    None
    [Return]   ${container_id}


Connect to Common SMOD
    [Documentation]    Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                This keyword currently only suitable for DU with singe ASIK.
    ...                In cloud gNB, ASIK Master connection need OAM as proxy.
    ...                In classical gNB, ASIK Master connection don't need any proxy.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    ${proxy}=    ssh.Connect to    ${tl.test_pcs[${gnb_index}].default_ssh_connection_details.addr}
    ...               ${tl.test_pcs[${gnb_index}].default_ssh_connection_details.username}
    ...               ${tl.test_pcs[${gnb_index}].default_ssh_connection_details.password}
    ...               alias=test_pc_${alias}

    ssh.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=test_pc_${alias}   alias=${alias}
    [Return]   ${proxy}

Connect to one RU with allocated IP
    [Documentation]
    [Arguments]    ${ru_info}   ${du_index}=${0}    ${du_alias}=du_${du_index}    ${gnb_index}=${1}
    #connection_alias_store.Connect to Common Unit Master    du_index=${du_index}    alias=${du_alias}
    ${proxy}   Connect to Common SMOD    du_index=${du_index}    alias=${du_alias}    gnb_index=${gnb_index}
    #connection_alias_store.Connect to Common Unit Slave with IP    du_index=${du_index}    alias=${du_alias}
    Connect to RU With SSH    ru_index=${1}    ru_info=${ru_info}  ru_alias=RU_1
    ...    asik_alias=${du_alias}
    [Return]  ${proxy}

Check Rf Config
    [Arguments]    ${ru_info}   ${du_index}=${0}    ${du_alias}=du_${du_index}

    Log    ${du_alias}
    ${masterAgentDN}    Set Variable     ${ru_info["parameters"]["masterAgentDN"]}
    ${status}    Run Keyword And Return Status  should_not_contain    ${masterAgentDN}    /BTS_L-4/
    ${gnb_index}    Set Variable If   ${status}    ${0}    ${1}
    ${proxy}    Connect to one RU with allocated IP    ru_info=${ru_info}    gnb_index=${gnb_index}
    ${tmp_soap_path}    Download soap Log from RU    ru_alias=RU_${1}


    ${productCode}    Set Variable    ${ru_info['parameters']["productCode"]}
    ${serialNum}    Set Variable    ${ru_info['parameters']["serialNumber"]}
    ${productCode}    Set Variable    ${ru_info['parameters']["productCode"]}
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}    Get Time    year month day hour min sec
    ${PC_soap_path}   Set Variable
    ...    ${TEST_LOGS_DIR_PATH}${/}UnitOAM_SOAP_${serialNum}_${year}-${month}-${day}-${hour}-${min}-${sec}.xml
    OperatingSystem.Move File     ${tmp_soap_path}    ${PC_soap_path}


    ${R_ru_info}    Get R_RRU Info   ${serialNum}

    ${activeSwBuild}    Set Variable    ${R_ru_info['parameters']["activeSwBuild"]}
    ${productCode_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep '<productCode>${productCode}</productCode>'
    #...    | sed -n '1p' | awk -F'productCode>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
    ${output_productCode_cmd_catSOAP}    run    command=${productCode_cmd_cat}
    should_contain    ${output_productCode_cmd_catSOAP}     <productCode>${productCode}</productCode>

    ${serialNum_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep '<serialNum>${serialNum}</serialNum>'
    #...    sed -n '1p' | awk -F'serialNum>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
    ${output_serialNum_cmd_catSOAP}    run    command=${serialNum_cmd_cat}

    should_contain    ${output_productCode_cmd_catSOAP}     <serialNum>${serialNum}</serialNum>

    ${bldName_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep '<bldName>${activeSwBuild}</bldName>'
    #...    sed -n '1p' | awk -F'bldName>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
    ${output_bldName_cmd_catSOAP}    run    command=${bldName_cmd_cat}

    should_contain    ${output_bldName_cmd_catSOAP}     <bldName>${activeSwBuild}</bldName>
    [Teardown]   ssh.disconnect   connection=${proxy}

Download soap Log from RU
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Download soap Log from RU
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]    ${ru_alias}=RU
    log to console  \n**Download soap Log from RU ***
    ${local_path}    Wait Until Keyword Succeeds   3x   10s    getsoapfile    connection=${ru_alias}
    [Return]    ${local_path}

Connect to BBU For RRU Channel
    [Arguments]    ${ru_info}   ${du_index}=${0}    ${du_alias}=du_${du_index}

    ${masterAgentDN}    Set Variable     ${ru_info["parameters"]["masterAgentDN"]}
    ${status}    Run Keyword And Return Status  should_not_contain    ${masterAgentDN}    /BTS_L-4/
    ${gnb_index}    Set Variable If   ${status}    ${0}    ${1}
    ${proxy}   Connect to Common SMOD    du_index=${0}    alias=${du_alias}    gnb_index=${gnb_index}
    #${channel}   Attach To Channel    asik_alias=${du_alias}
    [Return]    ${proxy}

Check RU Pingable
    [Arguments]    ${ru_info}   ${during}=3600
    ${proxy}    Connect to BBU For RRU Channel    ru_info=${ru_info}
    ${asik_alias}    Set Variable    du_${0}
    ${container_id}    Get FHNET Container ID2    asik_alias=${asik_alias}
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    ${ip}    Set Variable    ${ru_info['parameters']["ipAddress"]}

    ${cmd}   Set Variable If   ${feature_1834_opened}
    ...    lxc-attach -n ${container_id} -- ping -c ${during} -W 10 ${ip} -i 1
    ...    ping -c ${during} -W 10 ${ip} -i 1

    ${output}=    ssh.execute    command=${cmd}    connection=${asik_alias}
    Should contain    ${output}    ${during} packets transmitted, ${during} received
    ssh.disconnect    connection=${asik_alias}
    [Teardown]   ssh.disconnect   connection=${proxy}

Upload Incompatible RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}    ${sw_release}
    ${rf}    Set Variable      ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=download_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    mkdir -p ${SW_BUILDS_DIR_PATH}
    Sleep   20s
    Run Keyword If    '${sw_release}' == 'SBTS00'    SSHLibrary.Write
    ...    scp ${rf['LOGIN']}@${rf['HOST_IP']}:${rf['SW_PATH']}${rf['IMAGE_FILE_23R2']} ${SW_BUILDS_DIR_PATH}
    ...    ELSE IF    '${sw_release}' == 'SBTS23R2'    SSHLibrary.Write
    ...    scp ${rf['LOGIN']}@${rf['HOST_IP']}:${rf['SW_PATH']}${rf['IMAGE_FILE_23R1']} ${SW_BUILDS_DIR_PATH}
    ...    ELSE    SSHLibrary.Write
    ...    scp ${rf['LOGIN']}@${rf['HOST_IP']}:${rf['SW_PATH']}${rf['IMAGE_FILE_22R4']} ${SW_BUILDS_DIR_PATH}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    ${rf['PASSWORD']}    ELSE    SSHLibrary.Write    \n
    ${out}    Wait Until Keyword Succeeds    200s    1s    SSHLibrary.Read Until    100%
    SSHLibrary.Write    scp ${SW_BUILDS_DIR_PATH}${file_name} toor4nsn@${bbu_ip}:/user/toor4nsn/${file_name}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    100%
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Password:
    Run Keyword If      '${ret1[0]}'=='PASS'    Run Keywords    SSHLibrary.Write    oZPS0POrRieRtu
    ...     AND     Wait Until Keyword Succeeds    200s    1s    SSHLibrary.Read Until    100%
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
    SSHLibrary.Write    scp /user/toor4nsn/${file_name} ${rf['RRUuser']}@${rru_ip}:${file_path}${file_name}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    scp /user/toor4nsn/${file_name} ${rf['RRUuser']}@${rru_ip}:${file_path}${file_name}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    sleep    60s
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'
    ...    Run Keyword    Upload Incompatible RF Image To FR For Hosts    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Write    stat ${file_path}${file_name}
    ${out}    SSHLibrary.Read Until    regular file
    SSHLibrary.Close Connection

Upload Incompatible RF Image To FR For Hosts
    [Arguments]    ${image_command}
    SSHLibrary.Write    rm -rf /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Write    ${image_command}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n

Upgrade Incompatible RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}    ${sw_release}
    ${rf}    Set Variable      ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=upgrade_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    Run Keyword If    '${sw_release}' == 'SBTS00'    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum_23R2']} ${rf['fileVersion_23R2']} ""
    ...    ELSE IF    '${sw_release}' == 'SBTS23R2'    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum_23R1']} ${rf['fileVersion_23R1']} ""
    ...    ELSE    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum_22R4']} ${rf['fileVersion_22R4']} ""
    ${out}    Wait Until Keyword Succeeds    900s    1s    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    ${23R1_Command_BuildName_BuildVersion}=    Set Variable    ${rf['BuildName_23R1']} ${rf['BuildVersion_23R1']}
    ${23R1_Command_filename_fileVersion}=    Set Variable    ${file_name} ${rf['fileVersion_23R1']}
    ${22R4_Command_BuildName_BuildVersion}=    Set Variable    ${rf['BuildName_22R4']} ${rf['BuildVersion_22R4']}
    ${22R4_Command_filename_fileVersion}=    Set Variable    ${file_name} ${rf['fileVersion_22R4']}
    ${out}    Run Keyword If    '${sw_release}' == 'SBTS00'    SSHLibrary.Write
    ...    SWmanShellCommand -a ${23R1_Command_BuildName_BuildVersion} ${23R1_Command_filename_fileVersion}
    ...    ELSE    SSHLibrary.Write
    ...    SWmanShellCommand -a ${22R4_Command_BuildName_BuildVersion} ${22R4_Command_filename_fileVersion}
    ${out}    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    SSHLibrary.Close Connection
    sleep    2s

Upgrade Incompatible LRM RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}    ${sw_release}
    ${rf}    Set Variable      ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=upgrade_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n

    ${out}    Run Keyword If    '${sw_release}' == 'SBTS00'    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum_23R1']} ${rf['fileVersion_23R2']} ""
    ...    ELSE IF    '${sw_release}' == 'SBTS23R2'    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum_23R1']} ${rf['fileVersion_23R1']} ""
    ...    ELSE    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum_22R4']} ${rf['fileVersion_22R4']} ""
    Sleep    900s
    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=switch_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
   Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    ${23R2_Command_BuildName_BuildVersion}=    Set Variable    ${rf['BuildName_23R2']} ${rf['BuildVersion_23R2']}
    ${23R2_Command_filename_fileVersion}=    Set Variable    ${file_name} ${rf['fileVersion_23R2']}
    ${23R1_Command_BuildName_BuildVersion}=    Set Variable    ${rf['BuildName_23R1']} ${rf['BuildVersion_23R1']}
    ${23R1_Command_filename_fileVersion}=    Set Variable    ${file_name} ${rf['fileVersion_23R1']}
    ${22R4_Command_BuildName_BuildVersion}=    Set Variable    ${rf['BuildName_22R4']} ${rf['BuildVersion_22R4']}
    ${22R4_Command_filename_fileVersion}=    Set Variable    ${file_name} ${rf['fileVersion_22R4']}
    ${out}    Run Keyword If    '${sw_release}' == 'SBTS00'    SSHLibrary.Write
    ...    SWmanShellCommand -a ${23R2_Command_BuildName_BuildVersion} ${23R2_Command_filename_fileVersion}
    ...    ELSE IF    '${sw_release}' == 'SBTS23R2'    SSHLibrary.Write
    ...    SWmanShellCommand -a ${23R1_Command_BuildName_BuildVersion} ${23R1_Command_filename_fileVersion}
    ...    ELSE    SSHLibrary.Write
    ...    SWmanShellCommand -a ${22R4_Command_BuildName_BuildVersion} ${22R4_Command_filename_fileVersion}
    ${out}    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    SSHLibrary.Close Connection
    sleep    2s

Upgrade Incompatible SRM RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}    ${sw_release}
    ${rf}    Set Variable      ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=upgrade_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh -o serveraliveinterval=180 ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su root
    ${out}    SSHLibrary.Read    delay=0.5s
    #${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    #${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${tl_config.RF_FACTORY_SW_STORAGE['rootpassword']}
    ${out}    SSHLibrary.Write    ${rf['rootpassword']}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su rfsw
    ${out}    SSHLibrary.Read    delay=0.5s
    ${23R2_filename_fileVersion}=    Set Variable    ${file_path}${file_name} ${rf['fileVersion_23R2']}
    ${23R1_filename_fileVersion}=    Set Variable    ${file_path}${file_name} ${rf['fileVersion_23R1']}
    ${22R4_filename_fileVersion}=    Set Variable    ${file_path}${file_name} ${rf['fileVersion_22R4']}
    ${out}    Run Keyword If    '${sw_release}' == 'SBTS00'    SSHLibrary.Write
    ...    SWmanShellCommand -s ${23R2_filename_fileVersion} "${rf['BuildVersion_23R2']}" "jekins"
    ...    ELSE IF    '${sw_release}' == 'SBTS23R2'    SSHLibrary.Write
    ...    SWmanShellCommand -s ${23R1_filename_fileVersion} "${rf['BuildVersion_23R1']}" "jekins"
    ...    ELSE    SSHLibrary.Write
    ...    SWmanShellCommand -s ${22R4_filename_fileVersion} "${rf['BuildVersion_22R4']}" "jekins"
    ${out}    SSHLibrary.Read    delay=0.5s
    Sleep    1500s
    ${out}    SSHLibrary.Read    delay=0.5s
    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=switch_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    Sleep    5s
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    Sleep    5s
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su root
    ${out}    SSHLibrary.Read    delay=0.5s
    #${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    #${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${tl_config.RF_FACTORY_SW_STORAGE['rootpassword']}
    ${out}    SSHLibrary.Write    ${rf['rootpassword']}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su rfsw
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    Run Keyword If    '${sw_release}' == 'SBTS00'    SSHLibrary.Write
    ...    SWmanShellCommand -a "${file_name}" "${rf['BuildName_23R2']}" "${file_name}" "${rf['BuildVersion_23R2']}"
    ...    ELSE IF    '${sw_release}' == 'SBTS23R2'    SSHLibrary.Write
    ...    SWmanShellCommand -a "${file_name}" "${rf['BuildName_23R1']}" "${file_name}" "${rf['BuildVersion_23R1']}"
    ...    ELSE    SSHLibrary.Write
    ...    SWmanShellCommand -a "${file_name}" "${rf['BuildName_22R4']}" "${file_name}" "${rf['BuildVersion_22R4']}"
    ${out}    SSHLibrary.Read    delay=1s
    #${out}    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    SSHLibrary.Close Connection
    sleep    2s

Download File From FR Rel6
    [Arguments]    ${rru_ip}    ${file}    ${file_name}    ${target}
    Log    ${file}
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${rru_ip}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
#    ${out}    SSHLibrary.Write    ssh ${rru_ip}
#    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
#    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    ${out_is_trunk}   Run Keyword And Return Status    Should Match Regexp   ${SW_RELEASE}   SBTS(00|21B)+
#    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Read Until    password:
#    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Write    ${tl.RF_FAULT_INFO['password']}
#    ...    ELSE    SSHLibrary.Write    \n
#    ${out}    SSHLibrary.Read Until    \#
#    ${out}    SSHLibrary.Write    scp root@192.168.101.2:${file} /ram/${file_name}
#    ${out}    SSHLibrary.Read Until    100%
#    ${out}    SSHLibrary.Write    exit
#    ${out}    SSHLibrary.Read Until    closed
    ${out}    SSHLibrary.Write    scp rfsw@${rru_ip}:/ram/${file_name} ${file_name}
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Write    ${tl_config.RF_FAULT_INFO['password']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    100%
    SSHLibrary.Close Connection
    Setup Enb Fsm Access
    Get Enb File    /user/toor4nsn/${file_name}    ${target}/${file_name}
    Teardown Enb Fsm Access

Upload File To FR Rel6
    [Arguments]    ${rru_ip}    ${file_path}    ${file_name}    ${target}
    Setup Enb Fsm Access
    Put Enb File    ${target}/${file_name}    /user/toor4nsn/${file_name}
    Teardown Enb Fsm Access
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${rru_ip}    ^172
    ${ret}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword If    '${ret2[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    ${out}    Run Keyword If    '${ret0[0]}'=='PASS'    SSHLibrary.Read Until    >
    SSHLibrary.Write    scp /user/toor4nsn/${file_name} rfsw@${rru_ip}:${file_path}${file_name}
    ${out_is_trunk}   Run Keyword And Return Status    Should Match Regexp   ${SW_RELEASE}   SBTS(00|21B)+
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'     SSHLibrary.Write    ${tl_config.RF_FAULT_INFO['password']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    100%
    ${out}    SSHLibrary.Write    ssh rfsw@${rru_ip}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'     SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    '${out_is_trunk}'=='True'     SSHLibrary.Write    ${tl_config.RF_FAULT_INFO['password']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    $
    ${out}    SSHLibrary.Write    scp ${file_path}${file_name} rfsw@192.168.101.2:${file_path}${file_name}
    ${out}    SSHLibrary.Read Until    100%
    [Teardown]   SSHLibrary.Close Connection

Send RRU Command via ssh
    [Arguments]    ${ru_sn}    ${RRU_IP}    ${rrucommand_list}    ${prompt}=$
    ${vm_ip}    get_vm_ip_by_sn    ${ru_sn}    ${tl}
    SSHLibrary.Open Connection    ${vm_ip}    timeout=10
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${BTS_HOST}
    ${status}    Run Keyword And Return Status    SSHLibrary.Read Until    >
    Run Keyword If    not ${status}     SSHLibrary.Write    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.7
    ...    ELSE    SSHLibrary.Read Until    >
    SSHLibrary.Write    lxc-ls --active
    ${out}    SSHLibrary.Read Until     018
    ${ret}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    0x.*018
    SSHLibrary.Write    lxc-attach -n ${ret[1]}\n
    Sleep   3s
    ${out}    SSHLibrary.Read Until    >
    ${is_exist}    Run Keyword And Return Status     Variable Should Exist    ${RFSW_PASSWORD}
    ${out}    Run Keyword If    ${is_exist}
    ...    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no rfsw@${RRU_IP}
    ...    ELSE    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no ${RRU_IP}
    ${status}    Run Keyword If    ${is_exist}
    ...    Run Keyword And Return Status    SSHLibrary.Read Until    password
    Run Keyword If    ${is_exist}    Run Keyword If    ${status}    SSHLibrary.Write     ${RFSW_PASSWORD}
    ${out}    Run Keyword If    ${is_exist}    SSHLibrary.Read Until    $
    ...    ELSE    SSHLibrary.Read Until    \#
    FOR    ${command}    IN    @{rrucommand_list}
        ${out}    SSHLibrary.Write    ${command}\n
        ${out}    SSHLibrary.Read Until    ${prompt}
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Send RRU Command in frmonShellClient
    [Arguments]    ${ru_sn}    ${RRU_IP}    ${rrucommand_list}    ${bts_index}=0
    Log    ${bts_index}
    ${vm_ip}    get_vm_ip_by_sn    ${ru_sn}    ${tl}
    SSHLibrary.Open Connection    ${vm_ip}    timeout=10
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${BTS_HOST}
    ${status}    Run Keyword And Return Status    SSHLibrary.Read Until    >
    Run Keyword If    not ${status}     SSHLibrary.Write    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.7
    SSHLibrary.Read Until    >
    SSHLibrary.Write    lxc-ls --active
    ${out}    SSHLibrary.Read Until     018
    ${ret}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    0x.*018
    SSHLibrary.Write    lxc-attach -n ${ret[1]}\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${is_exist}    Run Keyword And Return Status     Variable Should Exist    ${RFSW_PASSWORD}
    ${out}    Run Keyword If    ${is_exist}
    ...    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no rfsw@${RRU_IP}
    ...    ELSE    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no ${RRU_IP}
    ${status}    Run Keyword If    ${is_exist}
    ...    Run Keyword And Return Status    SSHLibrary.Read Until    password
    Run Keyword If    ${is_exist}    Run Keyword If    ${status}    SSHLibrary.Write     ${RFSW_PASSWORD}
    ${out}    Run Keyword If    ${is_exist}    SSHLibrary.Read Until    $
    ...    ELSE    SSHLibrary.Read Until    \#
    ${out}    SSHLibrary.Write    frmonShellClient\n
    ${out}    SSHLibrary.Read Until    frmonShellClient starting on ip:localhost port:2000
    FOR    ${command}    IN    @{rrucommand_list}
        ${out}    SSHLibrary.Write    ${command}\r\n
        ${out}    Run Keyword And Ignore Error    SSHLibrary.Read Until    done ok
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Check Ru Fault History Log
    [Arguments]    ${ru_sn}    ${RRU_IP}    ${ru_fault_id}    ${file_path}
    ${vm_ip}    get_vm_ip_by_sn    ${ru_sn}    ${tl}
    SSHLibrary.Open Connection    ${vm_ip}    timeout=10
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${BTS_HOST}
    ${status}    Run Keyword And Return Status    SSHLibrary.Read Until    >
    Run Keyword If    not ${status}     SSHLibrary.Write    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.7
    ...    ELSE    SSHLibrary.Read Until    >
    SSHLibrary.Write    lxc-ls --active
    ${out}    SSHLibrary.Read Until     018
    ${ret}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    0x.*018
    SSHLibrary.Write    lxc-attach -n ${ret[1]}\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${password_exist}    Run Keyword And Return Status    variable should exist    ${RFSW_PASSWORD}
    ${out}    Run Keyword If    ${password_exist}
    ...    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no rfsw@${RRU_IP}
    ...    ELSE    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no ${RRU_IP}
    ${status}    Run Keyword If    ${password_exist}
    ...    Run Keyword And Return Status    SSHLibrary.Read Until    password
    Run Keyword If    ${password_exist}    SSHLibrary.Write     ${RFSW_PASSWORD}
    ${out}    Run Keyword And Ignore Error    Run Keyword If    ${password_exist}    SSHLibrary.Read Until    $
    ...    ELSE    SSHLibrary.Read Until    \#
    sleep    3s
    ${out}    SSHLibrary.Write     cat ${file_path}
    ${out}    Run Keyword And Ignore Error    Run Keyword If    ${password_exist}    SSHLibrary.Read Until    $
    ...    ELSE    SSHLibrary.Read Until    \#
    ${out}    Convert To String    ${out}
    Should Match Regexp    ${out}    ${ru_fault_id}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Get VM IP By RRU
    [Arguments]    ${bts_index}    ${ru_sn}
     ${ru_index}    get length    ${tl.enbs[${bts_index}].rms}
     FOR    ${index}   IN RANGE    ${ru_index}
         ${get_ru_sn}    Set Variable    ${tl.enbs[${bts_index}].rms[${index}].serial_number}
         ${bts_index}    Set Variable If    "${get_ru_sn}"=="${ru_sn}"    ${bts_index}    ${0}
         Exit For Loop If    "${get_ru_sn}"=="${ru_sn}"
     END
     ${host_ip}    Set Vriable    ${tl.test_pcs[${bts_index}].}
     [Return]    ${host_ip}
