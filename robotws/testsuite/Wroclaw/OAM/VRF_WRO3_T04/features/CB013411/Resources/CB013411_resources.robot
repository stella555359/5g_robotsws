*** Settings ***
Documentation    Keywords to change mcc
...              Author:    Klaudyna Piechocka
...              Contact:   klaudyna.piechocka@nokia.com

Resource    ../../../common_resources/connections/connections.robot
Resource       ../../../common_resources/ssh/ssh_operations.robot
Library     taf.nms.netact             WITH NAME    nms
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.transport.ssh          WITH NAME    ssh
Library     taf.ul.bts_components.Smod       WITH NAME    smod
Library     taf.ul.bts_components.Bbmod      WITH NAME    bbmod
Library     Collections

*** Variables ***
${slot}              0x1018
${RU_NAME}           AZQI
${id}                1234
${defaultName}       fjncuser0
${defaultPwd}        ncCl2fjRu+autH0

*** Keywords ***
Check M51334C1 Counter by WebEM
    [Arguments]   ${TNL}   ${connection}=${None}
    ${time}=  Get Current Date
    ${seconds}=  Convert Date	  ${time}  epoch
    ${Counter}=   admin.Get Counters Info  dist_name=TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-${TNL}/IPNO-1/IP_filtering_FH_Stats/M51334C1
    ...                                            timeout=60  connection=${connection}
    ${counter_dict}=     Set Variable  ${Counter['TRS']['MRBTS-${BTS_ID}']['TNLSVC-1']['TNL-${TNL}']['IPNO-1']['IP_filtering_FH_Stats']['M51334C1']}
    ${counter_time}=     Get Dictionary Keys  ${counter_dict}
    ${newest_value}=     get from dictionary   ${counter_dict}    ${counter_time[-1]}
    ${previous_value}=   get from dictionary   ${counter_dict}    ${counter_time[-2]}
    [Return]    ${newest_value}    ${previous_value}

Send packets from test PC using scapy sendpfast
    [Arguments]    ${packets}
    SSHLibrary.Open Connection   host=${TEST_PC_IP}
    SSHLibrary.Login             username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write             sudo su
    Sleep    2
    SSHLibrary.Write             ${TEST_PC_PASS}
    Sleep    2
    SSHLibrary.Write             sudo python3 -c "from scapy.all import Ether, IP, ICMP, UDP, TCP, sendpfast; ${packets}"
    Sleep                        20
    SSHLibrary.Read

Check RATE-LIMIT Counter
    [Arguments]         ${bsh}
    smod.connect_to     address=${LMP_IP}    username=${SSH_USERNAME}    password=${SSH_PASSWORD}
    ${smod_alias}=      smod.get_alias
    @{bbmods_info}=     smod.get_bbmods_topology_info    get_other_cpus_info=${TRUE}
    FOR    ${item}    IN    @{bbmods_info}
        IF    '${item['login_shortcut']}' == 'bsh ${bsh}'
            Set Test Variable    ${right_bbmod}    ${item}
            BREAK
        END
    END
    bbmod.connect_to    address=${right_bbmod['address']}    username=${right_bbmod['username']}
    ...                 password=${right_bbmod['password']}    proxy=${smod_alias}
    ${output}=          bbmod.execute    command=ip netns exec radions nft list chain inet filter filtering-logging
    Log to console      ${output}
    ${split1}=          Split String    ${output}    packets
    ${split2}=          Split String    ${split1[1]}    ${SPACE}
    ${packets}=         Set Variable    ${split2[1]}
    [Return]            ${packets}
    [Teardown]          Run Keywords    bbmod.close_connection
    ...    AND                          smod.close_connection

Clear Iptables Statistics
    SSHLibrary.Open Connection    ${LMP_IP}
    SSHLibrary.Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    SSHLibrary.Write    lxc-attach -n ${slot}
    Sleep  5
    SSHLibrary.Read
    SSHLibrary.Write   iptables -Z
    SSHLibrary.Close Connection

Check Iptables
    [Arguments]   ${type}  ${pre/post}=pre
    Run Keyword If   '${pre/post}'=='post'  Sleep  15
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Write    lxc-attach -n ${slot}
    Sleep  5
    SSHLibrary.Read
    SSHLibrary.Write   iptables -nvL -w 60 | grep -F ${type}
    Sleep  3
    ${iptables}=  SSHLibrary.Read
    ${iptables1}=   Split String  ${iptables}  ${SPACE}
    Remove Values From List   ${iptables1}  ${EMPTY}
    ${packets}=   Remove String  ${iptables1[0]}  K
    Run Keyword If   '${pre/post}'=='post'  SSHLibrary.Write   iptables -Z
    Set Test Variable   ${${pre/post}_packets}   ${packets}
    [Teardown]   SSHLibrary.Close Connection

Check Iptables With Given Chain
    [Arguments]   ${chain}    ${type}  ${pre/post}=pre
    Run Keyword If   '${pre/post}'=='post'  Sleep  15
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Write    lxc-attach -n ${slot}
    Sleep  5
    SSHLibrary.Read
    SSHLibrary.Write   iptables -nvL ${chain} -w 60 | grep -F ${type}
    Sleep  3
    ${iptables}=  SSHLibrary.Read
    ${iptables1}=   Split String  ${iptables}  ${SPACE}
    Remove Values From List   ${iptables1}  ${EMPTY}
    ${packets}=   Remove String  ${iptables1[0]}  K
    Run Keyword If   '${pre/post}'=='post'  SSHLibrary.Write   iptables -Z
    Set Test Variable   ${${pre/post}_packets}   ${packets}
    [Teardown]   SSHLibrary.Close Connection

Compare Iptables Packets
    [Arguments]   ${packets}=100
    ${result}=   Evaluate  ${post_packets} - ${pre_packets}
    ${results}=  Evaluate  ${packets}*0.9 <= ${result}
    Run Keyword If    ${results}==False   Fail  Expected: ${packets} Result:${result}

Create nft Rule To Break Link To RU
    [Arguments]   ${radio_ip}
    ${node}=          Get NodeId For Your Airscale

    ssh.Connect to    hostname=${LMP_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${nft_table}  Set Variable  nft add table ip table1
    ${nft_chain}  Set Variable  nft add chain ip table1 chain1 '{ type filter hook input priority 10; policy accept; }'
    ${nft_rule}  Set Variable  nft insert rule ip table1 chain1 iifname rlan0.ecpri ip saddr ${radio_ip} counter drop
    Log    Create nft rule    console=True
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_table}
    ...               connection=bts_connection
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_chain}
    ...               connection=bts_connection
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_rule}
    ...               connection=bts_connection
    [Teardown]    ssh.Disconnect    connection=bts_connection

Delete nft Rule to Unbreak Link to RU
    [Arguments]   ${radio_ip}
    ${node}=          Get NodeId For Your Airscale
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${nft_table_list}    Set Variable    nft -a list table table1
    Log    Get Handle ID    console=False
    ${command}=  Set Variable   lxc-attach -n ${node} -- ${nft_table_list} | grep ${radio_ip}
    ${output}=    ssh.Execute    command=${command}
    ...                          connection=bts_connection
    ${output}=    Convert To String    ${output}
    ${output}=    Split String    ${output}    handle
    ${chain_number}=     Split String    ${output}[1]    \r
    ${chain_number}=     Replace String    ${chain_number}[0]    ${SPACE}    ${EMPTY}
    Log    Delete nft rule    console=True
    ${nft_handle}=    Set Variable    nft delete rule table1 chain1 handle ${chain_number}
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_handle}
    ...               connection=bts_connection
    [Teardown]    ssh.Disconnect    connection=bts_connection

ISAKMP Packets Should Be Present On BTS
    [Arguments]    ${pcap_file}
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${radio_ip}=      Get IP Address For Given RU    ${RU_NAME}
    ${output}=    Run  tshark -r ${pcap_file} -Y 'ip.src==${radio_ip} && isakmp.exchangetype == 34'
    Should Contain    ${output}    IKE_SA_INIT
    [Teardown]    ssh.Disconnect    connection=bts_connection

ESP Packets Should Be Present On BTS
    ${node}=    Get NodeId For Your Airscale
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${response}=      ssh.Execute    command=lxc-attach -n ${node} -- timeout -s 9 90s tcpdump -i rlan0
    ...                              connection=bts_connection
    Should Contain    ${response}    ESP
    [Teardown]    ssh.Disconnect     connection=bts_connection

ESP Packets Should Not Be Present On BTS
    ${node}=    Get NodeId For Your Airscale
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${response}=    ssh.Execute     command=lxc-attach -n ${node} -- timeout -s 9 90s tcpdump -i rlan0
    ...                             connection=bts_connection
    Should Not Contain    ${response}    ESP
    [Teardown]    ssh.Disconnect    connection=bts_connection

Check If RU operationalState has expected value
    [Arguments]    ${excpected_value}
    Log    Checking If RU operational state is ${excpected_value}    console=True
    ${admin_connection}=    Connect To Admin
    ${bts_info}=    coam_admin.get_bts_info    connection=${admin_connection}
    ${RU_operationalState}=  Get From Dictionary    ${bts_info['radioModules']['rmod'][0]['status']}    operationalState
    Should Match Regexp    ${RU_operationalState}    ${excpected_value}
    [Teardown]    Disconnect From Admin    ${admin_connection}

Wait Until RU Will Automatically Reboot
    Wait Until Keyword Succeeds    5min      1min
    ...                            Check If RU operationalState has expected value   excpected_value=[Dd]isabled
    Wait Until Keyword Succeeds    15min    1min
    ...                            Check If RU operationalState has expected value   excpected_value=[Ee]nabled


Create Accounts Array
    ${defaultAccount}=    Create Dictionary
    ...    defaultNetconfAccountName=${defaultName}
    ...    defaultNetconfAccountPwd=${defaultPwd}

    ${account1}=    Create Dictionary
    ...    id=${id}
    ...    defaultNetconfAccount=${defaultAccount}

    @{accounts}=    Create List    ${account1}
    [Return]     ${accounts}

Get IP Address For Given RU
    [Arguments]       ${ru_name}
    [Documentation]   Returns List of IP Addresses for All Radio Units
    ${ru_dict}        Get Fronthaul RU Name With IP
    ${ru_ip}=         Get From Dictionary    ${ru_dict}    ${ru_name}
    [Return]          ${ru_ip}
