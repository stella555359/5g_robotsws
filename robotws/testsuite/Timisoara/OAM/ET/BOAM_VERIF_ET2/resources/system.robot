*** Settings ***
Documentation
...              Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...              Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library    taf.transport.ssh
Library    SSHLibrary

*** Variables ***
${SYSTEM_ENB_LOCAL_IP}=        192.168.255.1
${SYSTEM_IPHY_IP}=             192.168.200.1
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${SYSTEM_ALIAS_ASIK}=          asik
${SYSTEM_ALIAS_ASIB}=          asib
${SYSTEM_ALIAS_ASIL}=          asil
${SYSTEM_ALIAS_ASOE}=          asoe
${SYSTEM_ALIAS_IPHY}=          iphy
${SYSTEM_ALIAS_PROXY}=         rmod
${SYSTEM_RMOD_LOCAL_IP}
${SYSTEM_RMOD_SSH_USERNAME}    root
${SYSTEM_RMOD_SSH_PASSWORD}    umniedziala

*** Keywords ***
SYSTEM Execute Command On gNB
    [Arguments]    ${command}
    ...            ${hostname}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${username}=${SYSTEM_ENB_SSH_USERNAME}
    ...            ${password}=${SYSTEM_ENB_SSH_PASSWORD}
    ...            ${alias}=${SYSTEM_ALIAS_ASIK}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
    taf.transport.ssh.force reconnect
    ...    connection=${alias}
    ${reply}    Run Keyword And Return    taf.transport.ssh.execute
    ...    command=${command}
    ...    connection=${alias}
    [Return]    ${reply}

SYSTEM Execute Command On IPHY
    [Arguments]    ${command}
    ...            ${hostname}=${SYSTEM_IPHY_IP}
    ...            ${username}=${SYSTEM_ENB_SSH_USERNAME}
    ...            ${password}=${SYSTEM_ENB_SSH_PASSWORD}
    ...            ${alias}=${SYSTEM_ALIAS_IPHY}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
    taf.transport.ssh.force reconnect     # Issue: execute command on iphy was not working after iphy reset
    ...    connection=${alias}
    ${reply}    Run Keyword And Return    taf.transport.ssh.execute
    ...    command=${command}
    ...    connection=${alias}
    [Return]    ${reply}

SYSTEM Start Command On gNB
    [Arguments]    ${command}
    ...            ${hostname}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${username}=${SYSTEM_ENB_SSH_USERNAME}
    ...            ${password}=${SYSTEM_ENB_SSH_PASSWORD}
    ...            ${alias}=${SYSTEM_ALIAS_ASIK}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
    taf.transport.ssh.send_command
    ...    command=${command}
    ...    connection=${alias}

SYSTEM Execute Command On Rmod
    [Arguments]    ${command}
    ...            ${hostname_enb}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${hostname_rmod}=${SYSTEM_RMOD_LOCAL_IP}
    ...            ${username_enb}=${SYSTEM_ENB_SSH_USERNAME}
    ...            ${username_rmod}=${SYSTEM_RMOD_SSH_USERNAME}
    ...            ${password_enb}=${SYSTEM_ENB_SSH_PASSWORD}
    ...            ${password_rmod}=${SYSTEM_RMOD_SSH_PASSWORD}
    ...            ${alias}=${SYSTEM_ALIAS_ASIK}
    ...            ${proxy}=${SYSTEM_ALIAS_PROXY}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname_enb}
    ...    username=${username_enb}
    ...    password=${password_enb}
    ...    alias=${alias}
    taf.transport.ssh.Connect To
    ...    hostname=${hostname_rmod}
    ...    username=${username_rmod}
    ...    password=${password_rmod}
    ...    proxy=${alias}
    ...    alias=${proxy}
    taf.transport.ssh.execute
    ...    command=${command}
    ...    connection=${proxy}
    taf.transport.ssh.Disconnect
    ...    connection=${proxy}
    taf.transport.ssh.Disconnect
    ...    connection=${alias}

SYSTEM Open FrmonShell On RMOD
    [Arguments]    ${hostname_enb}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${hostname_rmod}=${SYSTEM_RMOD_LOCAL_IP}
    ...            ${username_enb}=${SYSTEM_ENB_SSH_USERNAME}
    ...            ${username_rmod}=${SYSTEM_RMOD_SSH_USERNAME}
    ...            ${password_enb}=${SYSTEM_ENB_SSH_PASSWORD}
    ...            ${password_rmod}=${SYSTEM_RMOD_SSH_PASSWORD}
    ...            ${alias}=${SYSTEM_ALIAS_ASIK}
    ...            ${proxy}=${SYSTEM_ALIAS_PROXY}
    taf.transport.ssh.Connect To
    ...    hostname=${hostname_enb}
    ...    username=${username_enb}
    ...    password=${password_enb}
    ...    alias=${alias}
    taf.transport.ssh.Connect To
    ...    hostname=${hostname_rmod}
    ...    username=${username_rmod}
    ...    password=${password_rmod}
    ...    proxy=${alias}
    ...    alias=${proxy}
    taf.transport.ssh.Send Command
    ...    connection=${proxy}
    ...    get_pty=TRUE
    ...    command=frmonShellClient 127.0.0.1 2000

SYSTEM Write To Frmod Shell
    [Arguments]    ${command}
    ...            ${proxy}=${SYSTEM_ALIAS_PROXY}
    taf.transport.ssh.Write Input    data=${command}\r\n...\n  connection=${proxy}
    sleep  3
    taf.transport.ssh.Read Output Until   \n    timeout=10   connection=rmod
    taf.transport.ssh.Read Output Until   \n    timeout=10   connection=rmod

SYSTEM Remove File From Directory
    [Arguments]    ${fileName}
    ...            ${fileDirectory}
    Run    sudo rm ${fileDirectory}/${fileName}

SYSTEM Check If File Is In Directory
    [Documentation]  File can contain spaces, so grep expression is quoted in ' characters
    [Arguments]    ${fileName}
    ...            ${fileDirectory}
    ${status}    Run    ls ${fileDirectory} | grep '${fileName}'
    Should Contain
    ...    item=${fileName}
    ...    container=${status}

SYSTEM Check If Host Is Pingable
    [Arguments]    ${host_ip_address}
	${out_ping_result}=    Run    ping -c 1 -W 10 ${host_ip_address}
    Should Contain    ${out_ping_result}    1 packets transmitted, 1 received    timeout=5
    [Return]    ${out_ping_result}

SYSTEM Check If Host Is Not Pingable
    [Arguments]    ${host_ip_address}
	${out_ping_result}=    Run    ping -c 1 -W 10 ${host_ip_address}
    Should Contain    ${out_ping_result}    1 packets transmitted, 0 received    timeout=5
    [Return]    ${out_ping_result}

SYSTEM Download File From Server
    [Arguments]    ${password}
    ...            ${user}
    ...            ${server_IP}
    ...            ${file_path}
    ...            ${file_name}
    ...            ${current_path}
    ...            ${current_name}
    Run    sshpass -p ${password} scp -r ${user}@${server_IP}:${file_path}/${file_name} ${current_path}/${current_name}

SYSTEM Add Flag In Swconfig File
    [Arguments]    ${flag}
    ${status}    SYSTEM Execute Command On gNB
    ...    command=cat /rom/swconfig.txt | grep ${flag}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${status}
    Run Keyword If    ${status}
    ...    Run Keywords
    ...    SYSTEM Execute Command On gNB
    ...    command=echo ${flag} >> /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB
    ...    command=reboot    AND
    ...    Wait Until Keyword Succeeds
    ...    300
    ...    5
    ...    SYSTEM Check If Host Is Not Pingable
    ...    host_ip_address=${LMP_IP}    AND
    ...    Wait Until Keyword Succeeds
    ...    300
    ...    5
    ...    SYSTEM Check If Host Is Pingable
    ...    host_ip_address=${LMP_IP}

SYSTEM Add Flag In Swconfig File without Site Reset
    [Arguments]    ${flag}
    ${status}    SYSTEM Execute Command On gNB
    ...    command=cat /rom/swconfig.txt | grep ${flag}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${status}
    Run Keyword If    ${status}
    ...    Run Keywords
    ...    SYSTEM Execute Command On gNB     command=echo ${flag} >> /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB     command=crasign /rom/swconfig.txt

Upload File On Gnb
    [Arguments]    ${local_path}
    ...            ${remote_path}
    ...            ${hostname}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${username}=${SYSTEM_ENB_SSH_USERNAME}
    ...            ${password}=${SYSTEM_ENB_SSH_PASSWORD}
    ...            ${alias}=${SYSTEM_ALIAS_ASIK}
    taf.transport.ssh.connect_to
        ...    hostname=${hostname}
        ...    username=${username}
        ...    password=${password}
        ...    alias=${alias}
    taf.transport.ssh.Upload File
        ...    local_path=${local_path}
        ...    remote_path=${remote_path}
        ...    connection=${alias}

SYSTEM Check if fault is in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should contain  ${RawAlamrsActive}  (${fault_id})
    Should contain  ${RawAlamrsActive}  ${EFaultId}

SYSTEM Check if fault is not in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsActive}  (${fault_id})
    Should not contain  ${RawAlamrsActive}  ${EFaultId}

SYSTEM Check if fault is in inactive raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   get raw alarm history file
    ${RawAlamrsInactive}=  fetch from right  ${RawAlarms}  Inactive faults
    Should contain  ${RawAlamrsInActive}  (${fault_id})
    Should contain  ${RawAlamrsInActive}  ${EFaultId}

SYSTEM Check if fault is not in inactive raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   get raw alarm history file
    ${RawAlamrsInactive}=  fetch from right  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsInActive}  (${fault_id})
    Should not contain  ${RawAlamrsInActive}  ${EFaultId}

SYSTEM Check If Host Is Reachable With Ping
    [Arguments]    ${host_ip_address}
    ${rc}    Run And Return Rc     ping -c 1 ${host_ip_address}
    Should Be Equal As Integers     ${rc}    0

SYSTEM Wait For Host Is Reachable With Ping
    [Arguments]    ${host_ip_address}
    ...            ${timeout}=300
    ...            ${checking_interval}=10s
    Wait Until Keyword Succeeds  ${timeout}  ${checking_interval}  SYSTEM Check If Host Is Reachable With Ping  host_ip_address=${host_ip_address}

SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Iphy Is Not Pingable

SYSTEM Check If Iphy Is Not Pingable
    SYSTEM Check If Host Is Not Pingable    host_ip_address=${SYSTEM_IPHY_IP}

SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Gnb Is Not Pingable

SYSTEM Check If Gnb Is Not Pingable
    SYSTEM Check If Host Is Not Pingable    host_ip_address=${SYSTEM_ENB_LOCAL_IP}

SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Iphy Is Pingable

SYSTEM Check If Iphy Is Pingable
    SYSTEM Check If Host Is Pingable    host_ip_address=${SYSTEM_IPHY_IP}

SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Gnb Is Pingable

SYSTEM Check If Gnb Is Pingable
    SYSTEM Check If Host Is Pingable    host_ip_address=${SYSTEM_ENB_LOCAL_IP}

SYSTEM Wait For Radio Module Is Online
    [Arguments]
    ...            ${timeout}=300
    ...            ${checking_interval}=10s
    Wait Until Keyword Succeeds  ${timeout}  ${checking_interval}  Admin Check Radio Module Online Status


