*** Settings ***
Documentation    Connection keywords, variables (IP addresses etc.).

Library    taf.transport.ssh        WITH NAME   ssh
Library    OperatingSystem
Library    SSHLibrary

Resource        ../vm/vm_operations.robot

*** Keywords ***
Connect to BTS
    [Documentation]    SSH to BTS, by default with BTS LMP IP address.
    [Arguments]        ${ip_address}=${LMP_IP}  ${username}=${ROOT_USERNAME}
    ...                ${password}=${ROOT_PASSWORD}  ${proxy}=${None}  ${port}=22
    ...                ${alias}=cOAM_toor4nsn
    ${connection}=     ssh.Connect to  ${ip_address}
    ...                                ${username}
    ...                                ${password}
    ...                                port=${port}
    ...                                proxy=${proxy}
    ...                                alias=${alias}
    Log                Successfully connected with BTS
    ...                console=${TRUE}
    [Return]           ${connection}

Connect to RU from SMOD via SSH
    [Arguments]                         ${user}  ${password}  ${RU_IP}=${None}   ${flag}=0x1018
    ${RU_IP}=                           Run Keyword If    '${RU_IP}' == '${None}'    Get RU IP
    ...                                 ELSE              Set Variable               ${RU_IP}
    SSHLibrary.Open Connection          host=${LMP_IP}
    SSHLibrary.Login                    username=${ROOT_USERNAME}       password=${ROOT_PASSWORD}
    SSHLibrary.Write                    text=lxc-attach -n ${flag}
    SSHLibrary.Read Until               expected=FHNET00:~ >
    SSHLibrary.Write                    text=echo "" > /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Read Until               expected=FHNET00:~ >
    SSHLibrary.Write                    text=ssh ${user}@${RU_IP}
    ${continue}=                        Run keyword and return status
    ...                                 SSHLibrary.Read Until               expected=(yes/no/[fingerprint])?
    Run keyword if   ${continue}        SSHLibrary.Write                    text=yes
    ...              ELSE               SSHLibrary.Write                    text=wrong_password
    ${output}=	                        SSHLibrary.Read   delay=20s
    ${password_prompt}=                 Evaluate   "password:" in """${output}"""
    Run Keyword If                      ${password_prompt} == True
    ...                                 SSHLibrary.Write   text=${password}
    SSHLibrary.Write                    text=\
    Run Keyword If                      """${user}""" == """root"""
    ...                                 SSHLibrary.Read Until               expected=#
    ...                 ELSE            SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=\
    ${RU_prompt}=                       Run Keyword If                      """${user}""" == """root"""
    ...                                 SSHLibrary.Read Until               expected=#
    ...                 ELSE            SSHLibrary.Read Until               expected=$
    SSHLibrary.Set Client Configuration     prompt=${RU_prompt}

Connect with SSH
    [Arguments]     ${ip_addr}  ${user}  ${password}  ${alias}
    ${connection}=  ssh.Connect to           ${ip_addr}
    ...                                      ${user}
    ...                                      ${password}
    ...                                      alias=${alias}
    Log             Successfully connected as ${user} at ${ip_addr}
    ...             console=${TRUE}
    [Return]        ${connection}

Disconnect from BTS
    [Arguments]     ${connection}=cOAM_toor4nsn
    ssh.disconnect  ${connection}

Disconnect SSH Session
    [Arguments]     ${connection}
    ssh.disconnect  ${connection}

Get RU IP
    ssh.Connect to    hostname=${LMP_IP}           username=${ROOT_USERNAME}
    ...               password=${ROOT_PASSWORD}    alias=bts_connection
    ${ip}=            ssh.execute    command=cat /ffs/run/config/FRIps.txt | cut -d";" -f3
    ...                              connection=bts_connection
    ssh.disconnect                   connection=bts_connection
    [Return]          ${ip}

Ping BTS Mplane IP
    ${output}=  Run  ping -c 2 ${BACKHAUL_OAM_IP}

Check If BTS Is Pingable
    [Arguments]    ${ip}=${BACKHAUL_OAM_IP}
    ${output}=    Run    ping -c 1 -W 10 ${ip}
    Should contain    ${output}    1 packets transmitted, 1 received

Check If BTS Is Not Pingable
    [Arguments]    ${ip}=${BACKHAUL_OAM_IP}
    ${output}=    Run    ping -c 1 -W 10 ${ip}
    Should contain    ${output}    1 packets transmitted, 0 received

Get VM IPv4 Address
    ${source_ipv4}=  Run  ip a | grep eth0 -A 2 | grep -w inet | awk {'print $2'} | awk -F/ {'print $1'}
    [Return]  ${source_ipv4}

Create Connection With SSHLibrary
    [Documentation]    Allows to connect to RMOD or SMOD or VM. Warning: on RMOD it changes current directory to /tmp
    ...                Use with Check Prompt With SSHLibrary keyword to validate output.
    [Arguments]    ${target_host}   ${username}   ${password}   ${target_ip}   ${ssh_key}=/home/ute/.ssh/id_rsa
    Run Keyword If   """${target_host}""" == "RU"
    ...      Run Keywords
    ...      Connect to RU from SMOD via SSH   user=${username}   password=${password}   RU_IP=${target_ip}
    ...      AND   SSHLibrary.Write   text=cd /tmp
    ...   ELSE IF   """${target_host}""" == "SMOD"
    ...      Run Keywords
    ...      SSHLibrary.Open Connection   host=${target_ip}
    ...      AND   SSHLibrary.Login   username=${username}   password=${password}
    ...      AND   SSHLibrary.Set Client Configuration   prompt=>
    ...   ELSE IF   """${target_host}""" == "VM"
    ...      Run Keywords
    ...      SSHLibrary.Open Connection	host=${target_ip}
    ...      AND   SSHLibrary.Login With Public Key	username=ute	keyfile=${ssh_key}
    ...      AND   SSHLibrary.Set Client Configuration   prompt=$
    ...   ELSE   Fail    msg=Wrong $\{target_host} argument!

Check Prompt With SSHLibrary
    [Arguments]    ${target_host}   ${username}
    ${prompt}=	SSHLibrary.Read
    Run Keyword If   """${target_host}""" == "SMOD"   Should End With    ${prompt.strip()}    >
    ...       ELSE IF   """${target_host}""" == "RU" and """${username}""" == "root"
    ...                 Should End With    ${prompt.strip()}    \#
    ...       ELSE      Should End With    ${prompt.strip()}    $

Copy File From RU
    [Documentation]    Allowed values: ${target_host} = VM | SMOD
    [Arguments]   ${target_host}   ${ru_username}   ${ru_ip}   ${source_file_path}
    ...           ${destination_path}   ${vm_ip}=${VM_IP}   ${flag}=0x1018   ${ru_password}=None
    @{path}=   Split String   ${source_file_path}   /
    ${source_file_name}=   Set Variable   ${path}[-1]
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Write    lxc-attach -n ${flag}
    Sleep  5s   reason=Wait for command processing...
    Run Keyword If      """${target_host}""" == "SMOD" or """${target_host}""" == "VM"
    ...   SSHLibrary.Write    scp -O ${ru_username}@${ru_ip}:${source_file_path} /tmp
    ...   ELSE   Fail    msg=Wrong $\{target_host} argument!
    Sleep  3s   reason=Wait for command processing...
    ${contain_yes}=     Run Keyword And Return Status  SSHLibrary.Read Until  expected=(yes/no/[fingerprint])?
    Run Keyword If      ${contain_yes}  SSHLibrary.Write  yes
    ${output}=	                        SSHLibrary.Read   delay=20s
    ${password_prompt}=                 Evaluate   "password:" in """${output}"""
    Run Keyword If                      ${password_prompt} == True
    ...                                 SSHLibrary.Write   text=${ru_password}
    Sleep  3s   reason=Wait for command processing...
    Run Keyword If      """${target_host}""" == "SMOD"   Run Keywords
    ...   SSHLibrary.Write   exit
    ...   AND   SSHLibrary.Write   cp /tmp/node_FHNET00/tmp/${source_file_name} ${destination_path}
    ...   AND   Check Copied File    SMOD   toor4nsn   192.168.255.129   ${destination_path}/${source_file_name}
    ...                              oZPS0POrRieRtu
    ...   ELSE   Run Keywords
    ...   Copy File Between SMOD And VM   SMOD   VM
    ...   /tmp/node_FHNET00/tmp/${source_file_name}   ${destination_path}   ${vm_ip}
    ...   AND   Check Copied File    VM   ute   ${vm_ip}   ${destination_path}/${source_file_name}
    SSHLibrary.Close All Connections

Copy File To RU
    [Documentation]    Allowed values: ${source_host} = VM | SMOD
    [Arguments]    ${source_host}   ${ru_username}   ${ru_ip}   ${source_file_path}
    ...            ${destination_path}   ${vm_ip}=${VM_IP}   ${flag}=0x1018   ${ru_password}=None
    @{path}=   Split String   ${source_file_path}   /
    ${source_file_name}=   Set Variable   ${path}[-1]
    Log    ${source_file_name}
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    Sleep  5s   reason=Wait for command processing...
    Run Keyword If      """${source_host}""" == "VM"
    ...   Copy File Between SMOD And VM   VM   SMOD   ${source_file_path}   /tmp   ${vm_ip}
    ...   ELSE IF      """${source_host}""" == "SMOD"
    ...   SSHLibrary.Write    cp ${source_file_path} /tmp
    ...   ELSE   Fail    msg=Wrong $\{source_host} argument!
    Sleep  3s   reason=Wait for command processing...
    SSHLibrary.Write    lxc-attach -n ${flag}
    Sleep    3s   reason=Wait for command processing...
    SSHLibrary.Write    scp -O /tmp/bts_tmp/${source_file_name} ${ru_username}@${ru_ip}:${destination_path}
    Sleep  3s   reason=Wait for command processing...
    ${contain_yes}=     Run Keyword And Return Status  SSHLibrary.Read Until  expected=(yes/no/[fingerprint])?
    Run Keyword If      ${contain_yes}  SSHLibrary.Write  yes
    ${output}=	                        SSHLibrary.Read   delay=20s
    ${password_prompt}=                 Evaluate   "password:" in """${output}"""
    Run Keyword If                      ${password_prompt} == True
    ...                                 SSHLibrary.Write   text=${ru_password}
    Check Copied File    RU   ${ru_username}   ${ru_ip}   ${destination_path}/${source_file_name}   ${ru_password}
    SSHLibrary.Close All Connections

Copy File Between SMOD And VM
    [Documentation]    Allowed values: ${source_host} = VM | SMOD and ${destination_host} = VM | SMOD
    [Arguments]   ${source_host}   ${destination_host}   ${source_file_path}   ${destination_path}   ${vm_ip}=${VM_IP}
    @{path}=   Split String   ${source_file_path}   /
    ${source_file_name}=   Set Variable   ${path}[-1]
    ${output}=   Run Keyword If   """${source_host}""" == "VM" and """${destination_host}""" == "SMOD"
    ...                        Run Command And Return Output
    ...                        sshpass -p oZPS0POrRieRtu scp ${source_file_path} 192.168.255.129:${destination_path}
    ...                        ${vm_ip}
    ...          ELSE IF       """${source_host}""" == "SMOD" and """${destination_host}""" == "VM"
    ...                        Run Command And Return Output
    ...                        sshpass -p oZPS0POrRieRtu scp 192.168.255.129:${source_file_path} ${destination_path}
    ...                        ${vm_ip}
    ...          ELSE          Fail   msg=Wrong arguments combination!
    Sleep    5s   reason=Wait for command processing...
    Log   ${output}   console=True
    Run Keyword If   """${destination_host}""" == "SMOD"
    ...              Check Copied File     SMOD   toor4nsn   192.168.255.129   ${destination_path}/${source_file_name}
    ...              oZPS0POrRieRtu
    ...    ELSE IF   """${destination_host}""" == "VM"
  ...                Check Copied File     VM   ute   ${vm_ip}   ${destination_path}/${source_file_name}

Check Copied File
    [Arguments]    ${target_host}   ${username}   ${target_ip}   ${copied_file_path}   ${password}=None
    ${output}=   Run Keyword If   """${target_host}""" == "RU"   Check Copied File On RU
    ...   ${username}   ${password}   ${target_ip}   ${copied_file_path}
    ${output}=   Run Keyword If   """${target_host}""" == "VM"   Run Command And Return Output
    ...   find ${copied_file_path}   ${target_ip}
    ${output}=   Run Keyword If   """${target_host}""" == "SMOD"   Run
    ...   sshpass -p ${password} ssh ${username}@${target_ip} "find ${copied_file_path}"
    ${check_if_not_exist}=              Evaluate   "No such file or directory" in """${output}"""
    Run Keyword If                      ${check_if_not_exist} == True
    ...                                 Fail   msg=Failed to copy!

Check Copied File On RU
    [Arguments]    ${username}   ${password}   ${target_ip}   ${copied_file_path}
    Create Connection With SSHLibrary   RU   ${username}   ${password}   ${target_ip}
    SSHLibrary.Write   find ${copied_file_path}
    Sleep   3s   reason=Wait for command processing...
    ${output}=   SSHLibrary.Read
    [Return]    ${output}
