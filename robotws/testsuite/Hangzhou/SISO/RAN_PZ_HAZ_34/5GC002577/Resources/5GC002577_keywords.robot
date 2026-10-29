*** Settings ***
Documentation     author: Dong Tingting
...               contact: tingting.dong@nokia-sbell.com
...               squad group: MMW_02

*** Keywords ***
General_SiSo_RF_alarms_with_recovery
    [Documentation]    ********General_SiSo_RF_alarms_with_recovery*********
    [Arguments]  ${ru_index}=1
    Modify Calibration File On RU Unit    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk    ru_index=${ru_index}
	${need_teardown}    Set variable    True
    Run Keyword and Ignore Error    Wait until keyword succeeds    10min    3s    RU Status Should Be Failed    ru_index=${ru_index}
    log to console    \n Check Alarm Exist in RawAlarmHistory
    Wait until keyword succeeds    25min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
    log to console    \n Alarm 1901 Exists in RawAlarmHistory
    Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${ru_index}
	${need_teardown}    Set variable    False
    log to console    \n Check GNB cell on air
    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
	log to console    \n Check Fault 1901 Absent on WebUI
    ${status}    run keyword and return status    Expect Fault Should Absent    faultId=1901
	log to console    \n Check Fault 1901 Absent on WebUI:${status}
#	run keyword if    '${status}' == 'False'    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
	run keyword if  not ${status}    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
	run keyword if  not ${status}    log to console    \n Performed BTS Site Reset
    run keyword if  not ${status}    sleep    120s
	run keyword if  not ${status}    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
    [Teardown]    Run Keyword If    ${need_teardown}
    ...    Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${ru_index}

#RU Status Should Be Failed
#    [Arguments]  ${ru_index}=1
#    ${dict_ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
#    should match regexp    ${dict_ru_info['status']['availabilityStatus']}    Failed|NotInstalled


Modify Calibration File On RU Unit
    [Arguments]    ${current_name}    ${new_name}    ${ru_index}=${1}
    ${cd_cmd}   Set Variable    cd /mnt/factory/configs/unit;
#    ${ru_ip_addr}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
#    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
#    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
	Connect To RU proxy FHNET Container    container_alias=Container    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    sleep    2s
    csn.send_command    command=${cd_cmd}ls -l | grep ${current_name}.bin | awk '{print $9}'     connection=RU_${ru_index}
    sleep    2s
    ${result}    csn.read_output    connection=RU_${ru_index}
    ${status}    Run Keyword And Return Status    should match regexp    ${result}    ${current_name}
    sleep    1s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}mv ${current_name}.bin ${new_name}.bin     connection=RU_${ru_index}
    sleep    2s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}mv ${current_name}.bin.md5 ${new_name}.bin.md5     connection=RU_${ru_index}
    sleep    15s
	Run Keyword If    '${status}' == 'True'    log to console    \n Modified Calibration File "${current_name}" to "${new_name}"
    Run Keyword If    '${status}' == 'True'    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    Run Keyword If    '${status}' == 'True'    sleep    20s
    [Teardown]    Run Keyword And Ignore Error    Modify_Calibration_Teardown  ru_index=${ru_index}

Modify_Calibration_Teardown
    [Arguments]    ${ru_index}=${1}
    csn.disconnect    connection=RU_${ru_index}
	sleep    2s
    csn.disconnect    connection=Container
    sleep    2s
	csn.disconnect    connection=ASIK Master

Connect To RU proxy FHNET Container
    [Documentation]   Auther: tingting.dong@nokia-sbell.com
    ...               Description: Connect To RU proxy FHNET Container
    ...               ContainerID is 0x1018 for left side of AMIA, 0x2018 for right side.
    ...               eth0(FHNET) ip is 192.168.255.254
    [Arguments]    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254    ${ru_index}=${1}
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...            ${coam_connection}=GNB_OAM
	csn.reset_cache
	Connect to Common Unit Master    alias=${asik_alias}
    csn.send_command    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=${asik_alias}
    sleep    2s
    csn.send_command    command=ssh -o StrictHostKeyChecking\=no ${ru_username}@${ru_ip_addr}    connection=${asik_alias}
    sleep    2s
	${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
	${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
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
#	${ru_ip_addr}    Get RU IP Address    ru_index=${ru_index}
#	wait until keyword succeeds  30min  3s  csn.connect to    hostname=${ru_ip_addr}
#    ...               username=${ru_username}
#    ...               password=${ru_password}
#    ...               alias=${ru_alias}
#    ...               proxy=${container_alias}
###    ${version_active_sw}    Coam Get Active SW Version    connection=${coam_connection}
    ${release}    Coam Get program version based on gNB active version    version_active_sw=${Active_SW_version}
    ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}    connection=${coam_connection}
    ${radio_type}    set variable    ${ru_info}[productName]
    Run keyword if    '${release}' in @{release_need_service_account} and '${radio_type}' in @{ru_login_with_service_account}
    ...    wait until keyword succeeds  30min  3s  Connect To RU By ServiceAccount
    ...            ru_ip_addr=${ru_ip_addr}
    ...            service_username=${service_username}
    ...            service_password=${service_password_${release}}
    ...            root_username=${root_username}
    ...            root_password=${root_password}
    ...            container_alias=${container_alias}
    ...            ru_alias=${ru_alias}
    ...    ELSE    Run Keyword    wait until keyword succeeds  30min  3s  csn.connect to
    ...                      hostname=${ru_ip_addr}
    ...                      username=${ru_username}
    ...                      password=${ru_password}
    ...                      alias=${ru_alias}
    ...                      proxy=${container_alias}
	
    log to console  \n***Connected to RU_${ru_index}***

#Get_RU_IP_Address
#    [Documentation]    Get_RU_IP_Address  
#    [Arguments]  ${ru_index}=1
#    log to console  \n***Get RU IP Address***
#    Connect to Common Unit Master
#    &{ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
#    ${ru_ip_addr}   Get RU IP Address Via File FRIps   ru_serial_number=${ru_info['serialNumber']}
#    should not be equal    ${ru_ip_addr}    0.0.0.0
#	log to console  \n***RU IP Address:${ru_ip_addr}***
#    [Return]    ${ru_ip_addr}
#    [Teardown]    csn.disconnect    connection=ASIK Master
#
#Get RU IP Address
#    [Documentation]    Get_RU_IP_Address
#    [Arguments]  ${ru_index}=1
#    log to console  \n***Get RU IP Address***
#    Connect to gnb coam via ssl
#    &{ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
##    Connect to Common Unit Master
#    ${ru_ip_addr}  wait until keyword succeeds  30min  5s  Target_RU_IP_Allocated  ru_sn=${ru_info['serialNumber']}
#	[Return]    ${ru_ip_addr}
##    [Teardown]    csn.disconnect    connection=ASIK Master
#
#Target_RU_IP_Allocated
#    [Documentation]    Get_Target_RU_IP
#    [Arguments]  ${ru_sn}
#    ${ru_ip_addr}   Get RU IP Address Via File FRIps   ru_serial_number=${ru_sn}
#    should not be equal    ${ru_ip_addr}    0.0.0.0
#	log to console  \n***RU IP Allocated***
#    [Return]    ${ru_ip_addr}
