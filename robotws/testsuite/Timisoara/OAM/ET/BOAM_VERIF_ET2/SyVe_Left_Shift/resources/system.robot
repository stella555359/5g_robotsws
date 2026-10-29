*** Settings ***
Documentation
...              Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...              Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library    taf.transport.ssh

*** Variables ***
${SYSTEM_ENB_LOCAL_IP}=        192.168.255.1
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${SYSTEM_ALIAS_ASIK}=          asik
${SYSTEM_ALIAS_PROXY}=         rmod
${SYSTEM_RMOD_LOCAL_IP}
${SYSTEM_RMOD_SSH_USERNAME}    root
${SYSTEM_RMOD_SSH_PASSWORD}    umniedziala
${SYSTEM_RMOD_SSH_PASSWORD_AEQN}     w@=EIj7P6R0bVy85OjCVa^ho&8

@{UBOOT_FLAGS_ASIK}            &{netboot}
@{UBOOT_FLAGS_ASIB}            &{bootpretries}    &{bootptimeout}    &{macspeed}    &{netboot}    &{netboot_interface}    &{tftpretries}
${UBOOT_UNWANTED_FLAGS}        disable_watchdog
&{bootptimeout}                bootptimeout=3000
&{bootpretries}                bootpretries=2
&{macspeed}                    macspeed=1G
&{netboot}                     netboot=netboot_first
&{netboot_interface}           netboot_interface=lmp
&{tftpretries}                 tftpretries=2

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
    ${reply}    Run Keyword And Return    taf.transport.ssh.execute
    ...    command=${command}
    ...    connection=${alias}
    [Return]    ${reply}

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

SYSTEM Get VM IP
    ${ips}=     run  sudo ifconfig eth0 | grep -i "inet "
    @{ip1}=     split string  ${ips}
    ${vm_ip}=   set variable    @{ip1}[1]
    [Return]    ${vm_ip}

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
    taf.transport.ssh.Read Output Until   \n    timeout=10   connection=${proxy}
    taf.transport.ssh.Read Output Until   \n    timeout=10   connection=${proxy}

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
    ...    command=ddal -s ddal_reboot_graceful    AND
    ...    Wait Until Keyword Succeeds
    ...    240
    ...    5
    ...    SYSTEM Check If Host Is Not Pingable
    ...    host_ip_address=${LMP_IP}    AND
    ...    Wait Until Keyword Succeeds
    ...    240
    ...    5
    ...    SYSTEM Check If Host Is Pingable
    ...    host_ip_address=${LMP_IP}

SYSTEM Get Uboot Env Flag
    [Arguments]    ${uboot_flag}
    ${output}    SYSTEM Execute Command On gNB    command=uboot_env get ${uboot_flag}
    [Return]    ${output}

SYSTEM Delete Uboot Env Flag
    [Arguments]    ${uboot_flag}
    ${output}    SYSTEM Execute Command On gNB    command=uboot_env del ${uboot_flag}
    Should Contain    ${output}    Deleted ${uboot_flag}
    Log to console    \nuboot_env flag: ${uboot_flag} has been removed

SYSTEM Set Uboot Env Flag
    [Arguments]    ${uboot_flag}    ${flag_value}
    ${output}    SYSTEM Execute Command On gNB    command=uboot_env set ${uboot_flag}=${flag_value}
    Should Contain    ${output}    Added 1 variables
    Log to console    \nuboot_env flag: ${uboot_flag} has been set to: ${flag_value}

SYSTEM Check If Uboot Flag Is Set To Expected Value
    [Arguments]    ${uboot_flag}    ${expected_value}
    ${output}    SYSTEM Get Uboot Env Flag    ${uboot_flag}
    Should Contain    ${output}    ${uboot_flag}=${expected_value}
    # TODO remove \r\n and check SHOULD MATCH

SYSTEM Get Proper Flag Values From Uboot Flags List
    [Arguments]    ${uboot_flags_list}
    ${uboot_flag}    Get Dictionary Keys    ${uboot_flags_list}
    ${flag_value}    Get Dictionary Values    ${uboot_flags_list}
    [Return]    ${uboot_flag}    ${flag_value}

SYSTEM Set Proper Netboot Recovery Flags
    [Arguments]    ${smod_product_name}
    FOR    ${element}    IN    @{UBOOT_FLAGS_${smod_product_name}}
#    get flag and value
        ${uboot_flag}    ${flag_value}    SYSTEM Get Proper Flag Values From Uboot Flags List
    ...    uboot_flags_list=${element}
#    check if flag is set to expected value
        ${status}    Run Keyword And Return Status
    ...    SYSTEM Check If Uboot Flag Is Set To Expected Value    uboot_flag=${uboot_flag[0]}    expected_value=${flag_value[0]}
#    set flag if is not set
        Run Keyword Unless    ${status}    SYSTEM Set Uboot Env Flag    ${uboot_flag[0]}    ${flag_value[0]}
#    check if flag is set to expected value
        SYSTEM Check If Uboot Flag Is Set To Expected Value    uboot_flag=${uboot_flag[0]}    expected_value=${flag_value[0]}
    END

SYSTEM Remove Unwanted Uboot Flags
    ${status}    Run Keyword And Return Status
    ...    SYSTEM Check If Uboot Flag Is Set To Expected Value
    ...    uboot_flag=${UBOOT_UNWANTED_FLAGS}
    ...    expected_value=${EMPTY}
    Run Keyword If    ${status}    SYSTEM Delete Uboot Env Flag    uboot_flag=${UBOOT_UNWANTED_FLAGS}
     ${status}    Run Keyword And Return Status
    ...    SYSTEM Check If Uboot Flag Is Set To Expected Value
    ...    uboot_flag=${UBOOT_UNWANTED_FLAGS}
    ...    expected_value=${EMPTY}
    Should Not Be True    ${status}

SYSTEM Get Time From Various Time Sources
    [Documentation]    debug KW to monitor time gaps issues
    ${date_shell}        Run    date +%Y-%m-%d-%H:%M:%S
    ${date_gnb_shell}    SYSTEM Execute Command On gNB    command=date +%Y-%m-%d-%H:%M:%S
    ${date_python}       Get Date Python
    ${date_robot}        Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ...                                      time_zone=UTC
    ...                                      increment=2 hours
    ${time_adminApi}    Run
    ...    command=tail --lines=4 ${ADMIN_API_LOG_DIR}/admin_api_default.log | awk '{print $1}' | egrep -m 1 '[0-9]+:[0-9]+:[0-9]+'
    ${date_list}    Create List       date_shell=${date_shell}    date_gnb_shell=${date_gnb_shell}    date_python=${date_python}
    Append To List    ${date_list}    date_robot${date_robot}    time_adminApi=${time_adminApi}
    Log    ${date_list}

SYSTEM Get Local Timezone Time Offset
    ${time_offset_cut}    Run    date +%z | cut -b 2-3
    ${time_offset_int}    Convert To Integer    ${time_offset_cut}
    [Return]    ${time_offset_int}
