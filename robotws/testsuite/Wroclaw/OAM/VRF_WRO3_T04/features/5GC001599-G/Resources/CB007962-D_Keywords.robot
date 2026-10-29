*** Settings ***
Documentation
...  author:   Patryk Tatarek
...  contact:  patryk.tatarek@nokia.com

Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/admin/admin.robot
Library     taf.sbts.oam.coam.admin  WITH NAME    coam_admin
Library     taf.transport.ssh        WITH NAME    ssh
Library     SSHLibrary

*** Keywords ***
Check Kernel Settings For Reverse Path Filter
    Connect to BTS
    coam_admin.Connect To      name=cOAM_admin
    ${SMOD_info}=         coam_admin.Get Fsm Info   connection=cOAM_admin
    ${key}=               Get Dictionary Keys   ${SMOD_info[0]}
    ${sysctl_result}=     Run Keyword If   '${SMOD_info[0]['productName'][0:4]}'=='ASIK'
    ...                   ssh.execute    command=sysctl -a | grep martians | grep fp0   connection=cOAM_toor4nsn
    ...    ELSE IF        '${SMOD_info[0]['productName'][0:4]}'=='ASIB'
    ...                   ssh.execute    command=sysctl -a | grep martians | grep br1   connection=cOAM_toor4nsn
    ...    ELSE           ssh.execute    command=sysctl -a | grep martians | grep br0   connection=cOAM_toor4nsn
    Should Not Contain    ${sysctl_result}  = 0
    Should Contain        ${sysctl_result}  = 1
    [Teardown]            Run Keywords  Run Keyword And Ignore Error  coam_admin.Teardown  connection=cOAM_admin
    ...    AND            Disconnect from BTS

Check Kernel Settings For Reverse Path Filter ASIA
    Connect to BTS
    coam_admin.Connect To      name=cOAM_admin
    ${SMOD_info}=         coam_admin.Get Fsm Info   connection=cOAM_admin
    ${key}=               Get Dictionary Keys   ${SMOD_info[0]}
    ${sysctl_result}=     Run Keyword If   '${SMOD_info[0]['productName'][0:4]}'=='ASIA'
    ...                   ssh.execute    command=sysctl -a | grep martians | grep br1   connection=cOAM_toor4nsn
    Should Not Contain    ${sysctl_result}  = 0
    Should Contain        ${sysctl_result}  = 1
    [Teardown]            Run Keywords  Run Keyword And Ignore Error  coam_admin.Teardown  connection=cOAM_admin
    ...    AND            Disconnect from BTS

Check Kernel Settings For Reverse Path Filter ASIM
    Connect to BTS        alias=cOAM_toor4nsn
    coam_admin.Connect To      name=cOAM_admin
    ${SMOD_info}=         coam_admin.Get Fsm Info   connection=cOAM_admin
    ${key}=               Get Dictionary Keys   ${SMOD_info[0]}
    ${sysctl_result}=     ssh.execute    command=sysctl -a | grep martians | grep br0 | grep -v br0.log
    ...                   connection=cOAM_toor4nsn
    Should Not Contain    ${sysctl_result}  = 0
    Should Contain        ${sysctl_result}  = 1
    [Teardown]            Run Keywords  Run Keyword And Ignore Error  coam_admin.Teardown  connection=cOAM_admin
    ...    AND            Disconnect from BTS    cOAM_toor4nsn

Check If BTS Logs Packets Without Existing Route
    Connect to BTS
    ${time}=           Get Current Date  UTC
    ${python_path}=    Run  which python
    ${command}=  Catenate  'import scapy.all as scapy; scapy.send(scapy.IP(dst="192.168.255.129", src="255.255.255.255")
    ...                     /scapy.TCP(dport=443, flags="S"), count=10)'
    ${scapy_output}=    Run  sudo -E ${python_path} -c ${command}
    Should Contain      ${scapy_output}    Sent 10 packets
    Log                 \n SCAPY ${scapy_output}   console=True
    Log                 Scapy Done   console=True
    ${martian}=         ssh.execute    cat /var/log/martian | tail -10   connection=cOAM_toor4nsn
    Should Contain X Times   ${martian}  kernel  10
    Should Contain X Times   ${martian}  IPv4: martian source 192.168.255.129 from 255.255.255.255, on dev ethlmp0  10
    Check Time In Output     ${time}   ${martian}
    [Teardown]               Disconnect from BTS

Check If BTS Ignores And Logs DHCPDECLINE
    Firewall BTS Setup
    ${time}=    Get Current Date  UTC
    ${S1}  Set Variable
    ...    sendp ((Ether(src="${Test_PC_MAC}", dst="${BBMOD_MAC}")/IP(src="${PC_RMOD_IP}", dst="${FHNET_IP}")/UDP(sport
    ${S2}  Set Variable
    ...    =68,dport=67)/BOOTP()/DHCP(options=[("message-type","decline"),('requested_addr','${PC_RMOD_IP}'),"end"]))
    SSHLibrary.Open Connection    ${UTE5G${TL_NUMBER}.PC_IP}
    SSHLibrary.Login              ${UTE5G${TL_NUMBER}.PC_User}   ${UTE5G${TL_NUMBER}.PC_Password}
    Run Keyword If               '${UTE5G${TL_NUMBER}.VM_IP}'=='None'   Run Keywords
    ...    SSHLibrary.Write            su - root
    ...    AND     Sleep  5            reason=Wait until terminal executes the command
    ...    AND     SSHLibrary.Write    ${UTE5G${TL_NUMBER}.PC_Password}
    ...    ELSE    Run Keywords
    ...    SSHLibrary.Write            ssh ute@${UTE5G${TL_NUMBER}.VM_IP}
    ...    AND     Sleep  5            reason=Wait until terminal executes the command
    ...    AND     SSHLibrary.Write    ute
    Sleep  5
    SSHLibrary.Write    sudo scapy
    Sleep  10           reason=Wait until terminal executes the command
    SSHLibrary.Read
    SSHLibrary.Write    ${S1}${S2}, iface="${BBMOD_IF}")
    Sleep  3            reason=Wait until terminal executes the command
    ${Scapy_output}=    SSHLibrary.Read
    Should Contain      ${Scapy_output}       Sent 1 packets
    Log           \n SCAPY ${Scapy_output}    console=True
    Log           Scapy Done                  console=True
    ${output}=    ssh.Execute  command=cat /var/log/messages | grep DHCPDECLINE | tail -1
    ...           timeout=300   connection=${gNB_ssh_connection}
    Should Contain          ${output}    ignored
    Check Time In Output    ${time}      ${output}
    [Teardown]    Run Keywords  SSHLibrary.Close Connection
    ...    AND    Firewall BTS Teardown

Check Time In Output
    [Arguments]            ${time}              ${output}
    ${out_time1}=          Split String         ${output}          ${SPACE}
    ${out_time2}=          Split String         ${out_time1[0]}    +
    ${out_time3}=          Replace String       ${out_time2[0]}    T    ${SPACE}
    ${time_number}=        Convert Date         ${time}            epoch
    ${out_time_number}=    Convert Date         ${out_time3}       epoch
    ${time1}=              Convert To Number    ${time_number}
    ${time2}=              Convert To Number    ${out_time_number}
    ${results}=            Evaluate             ${time1} < ${time2}
    Should Not Be True    '${results}'=='False'

Check If Serviceuser Can Perform Tunnel Based Access To Toor4nsn Account
    SSHLibrary.Open Connection         192.168.255.129
    SSHLibrary.Login    serviceuser    Pl(FzaYj5~c5;q
    SSHLibrary.Write    ssh toor4nsn@192.168.255.129
    Sleep  5            reason=Wait until terminal executes the command
    ${output}=          SSHLibrary.Read
    ${contain_yes}=     Run Keyword And Return Status   Should Match Regexp    ${output}    Password
    Run Keyword If      ${contain_yes}==False   SSHLibrary.Write    yes
    Sleep  5            reason=Wait until terminal executes the command
    SSHLibrary.Write    oZPS0POrRieRtu
    Sleep  3            reason=Wait until terminal executes the command
    SSHLibrary.Write    pwd
    Sleep  2            reason=Wait until terminal executes the command
    ${toor4nsn_output}=    SSHLibrary.Read
    Should Match Regexp    ${toor4nsn_output}    /user/toor4nsn
    SSHLibrary.Write       exit
    [Teardown]             SSHLibrary.Close Connection

SSH LoginGracePeriod
    Connect to BTS
    ${cat_result}=    ssh.execute      command=cat /etc/ssh/sshd_config    connection=cOAM_toor4nsn
    Should Contain    ${cat_result}    LoginGraceTime 60
    [Teardown]        Disconnect from BTS

Telnet Server Binary And Supporting Files Removal
    Connect to BTS
    ${telnetd_searching}=    ssh.execute             command=find / -name telnet*  connection=cOAM_toor4nsn
    Should Not Contain       ${telnetd_searching}    telnetd
    ${xinetd_searching}=     ssh.execute             command=find / -name xinetd*  connection=cOAM_toor4nsn
    Should Not Contain       ${xinetd_searching}     xinetd
    ${busybox_output}=       ssh.execute             command=busybox telnetd --help  connection=cOAM_toor4nsn
    Should Contain           ${busybox_output}       telnetd: applet not found
    [Teardown]               Disconnect from BTS

BTS Should Alarm User If SOE Is NOT Enabled
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=ethernetPortSecurityEnabled
    ...                        param_value=false
    ${alarms}=                 Get Active Alarms From BTS
    ${correct_alarm_id}=       Convert to Integer    4654
    Should Contain             ${alarms}    ${correct_alarm_id}
    [Teardown]                 Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=ethernetPortSecurityEnabled
    ...                        param_value=true
