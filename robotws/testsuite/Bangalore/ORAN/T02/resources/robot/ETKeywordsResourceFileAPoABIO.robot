*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com

*** Variables ***

${Docker_username}=        inbabtslabuser
${ssh_username}=           toor4nsn
${ssh_password}=           oZPS0POrRieRtu
${password_BTS}=           BT5l@bus3rl0g1n
${oran_alias}=             rusim
${ORU_SIM_IP}=             10.45.150.73
${BTS_path}=               /home/ute/Logs
${value_true}=            true
${value_false}=           false
${connection}=            default
${BTS_ADDRESS} =           192.168.255.129
${BTS_ADDRESS_iphy} =      192.168.200.1
${netconf_password}=       netconf
${Netconf_Login_cmd}=      connect --ssh --login netconf --host 127.0.0.1 --port 830
${Backdoor_cmd_apoabio}=          /opt/UE-APP-OAM-oru/service/oran/xml/backdoor/alarm

*** Keywords ***

Trigger_LBM
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    username=${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.write    bsh 1:1
    SSHLibrary.Read    delay=3s
    SSHLibrary.write    ip netns exec radions bash
    SSHLibrary.Read    delay=3s
    SSHLibrary.write    ip netns exec radions tcpdump -i rfoe0 -XX -c 100000 -e -nn |grep CFM
    ${var}=    SSHLibrary.Read    delay=30s
    log    ${var}
    SSHLibrary.Close All Connections

Send Cmd By Netopeer Cli xranuser APoabio
    [Arguments]    ${value}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS_iphy}
    SSHLibrary.Login    username=${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.write    lxc-attach -n 0x551a
    SSHLibrary.Read    delay=10s
    SSHLibrary.write    ip netns exec ORU01 /opt/UE-APP-OAM-oru/service/netopeer2/netopeer2-cli\r\n
    SSHLibrary.Read    delay=10s
    SSHLibrary.write    connect --ssh --login netconf --host 127.0.0.1\r\n
    ${output}=    SSHLibrary.Read     delay=2s
    Log   ${output}
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output}    Are you sure you want to continue connecting
    Run Keyword if    '${contains}' == 'True'    SSHLibrary.write   yes\r\n
    SSHLibrary.Read    delay=3s
    SSHLibrary.write   netconf\r\n
    SSHLibrary.Read    delay=2s
    SSHLibrary.write    user-rpc --content ${value}\r\n
    SSHLibrary.Read    delay=10s

    SSHLibrary.Close All Connections

Create_alarm_xml
    [Arguments]    ${alarmfilelistsent}    @{alarm_list_sent}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS_iphy}
    SSHLibrary.Login    username=${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.write    lxc-attach -n 0x551a
    SSHLibrary.Read     delay=10s
    SSHLibrary.write    cd ${Backdoor_cmd_apoabio}
    SSHLibrary.Read     delay=10s
    SSHLibrary.write    rm -rf ${alarmfilelistsent}
    SSHLibrary.Read     delay=10s
    SSHLibrary.write    touch ${alarmfilelistsent}
    SSHLibrary.write    ls -lrt
    SSHLibrary.Read     delay=10s
    Sleep    10s
    FOR    ${i}    IN    @{alarm_list_sent}
        SSHLibrary.write    echo -e '${i}' >> ${alarmfilelistsent}
        SSHLibrary.Read     delay=10s
    END
    SSHLibrary.Close All Connections
