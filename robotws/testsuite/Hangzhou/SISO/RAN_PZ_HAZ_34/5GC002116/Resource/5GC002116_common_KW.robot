*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com


Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002118/Resource/5GC002118_common_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot


*** Variables ***
${TS_LOG_PATH_BASE}      /home/ute/TA/Case_Logs/
${alarm_filter_0}        1937
${alarm_filter_1937}     Unit \(module\) dangerously overheating
${RU_HOST}               ${ru_addr}
${RU_USER}               ${ru_username}
${RU_PASSWORD}           ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}

*** Keywords ***
Trigger Alarm 1937
    [Arguments]    ${init_value}    ${target_value}
    log to console    \n Trigger Alarm 1937
    Create Json File
    Modify Json file    init_value=${init_value}    target_value=${target_value}
    Activate Json file

"${Step}" Check Alarm 1937 Appear On WebEM
    log to console   \n Check Alarm 1937 Appear On WebEM
    Wait Until Keyword Succeeds    5min    10s        WEBUI Login
    Wait Until Keyword Succeeds    20min    10s    Check Alarm Exist    alarm_filter=${alarm_filter_1937}
    WEBUI Logout

Recovery Alarm 1937
    [Arguments]    ${init_value}    ${target_value}
    log to console    \n Recovery Alarm 1937
    Create Json File
    Modify Json file    init_value=${init_value}    target_value=${target_value}
    Activate Json file

"${Step}" Check Alarm 1937 Disappear On WebEM
    log to console    \n Check Alarm 1937 Disappear On WebEM
    Wait Until Keyword Succeeds    5min     10s    WEBUI Login
    wait until keyword succeeds    10min    10s    Check Cell is UP
    @{alarm_info}=    selenium_coam.get_active_alarm_info    timeout=60
    ${alarms_string}=    Convert To String    ${alarm_info}
    Should not Contain    ${alarms_string}    ${alarm_filter_1937}
    WEBUI Logout

"${step}" Site reset on webui
    log to console           \n"${Step}": Site reset from webui
    WEBUI Login
    Wait Until Keyword Succeeds    1min    30s   selenium_coam.reset_site
    WEBUI Logout
    sleep   2min

"${Step}" RU Led Status Change to Green
    log to console           \n"${Step}": RU Led Status Change to Green
    WEBUI Login
    Wait Until Keyword Succeeds    15min    1s    RU Led Status Change to Green
    WEBUI Logout

"${Step}" Trigger Alarm 1901
    log to console    \n Step2:Trigger Alarm 1901
    ${number}    Get RU Nomuber
    set suite variable    ${number}
    csn.Connect to
    ...    hostname=${asik_addr}
    ...    username=${asik_username}
    ...    password=${asik_password}
    ...    alias=gNB
    csn.send_command
    ...    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts
    ...    connection=gNB
    sleep    2s
    Connect to gnb coam via ssl
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=gNB
    Connect to RU With Allocated IP
    ...     ru_alias=RF
    ...     asik_alias=gNB
    ...     container_id=${FHNETcontainer_id}
    csn.download_file    remote_path=${ru_dir}calibration_rfic1.bin       local_path=/home/ute/Downloads/    connection=RF
    csn.download_file    remote_path=${ru_dir}calibration_rfic1.bin.md5   local_path=/home/ute/Downloads/    connection=RF
    csn.download_file    remote_path=${ru_dir}calibration_rfic2.bin       local_path=/home/ute/Downloads/    connection=RF
    csn.download_file    remote_path=${ru_dir}calibration_rfic2.bin.md5   local_path=/home/ute/Downloads/    connection=RF
    csn.download_file    remote_path=${ru_dir}calibration_rfic3.bin       local_path=/home/ute/Downloads/    connection=RF
    csn.download_file    remote_path=${ru_dir}calibration_rfic3.bin.md5   local_path=/home/ute/Downloads/    connection=RF
    csn.download_file    remote_path=${ru_dir}calibration_rfic4.bin       local_path=/home/ute/Downloads/    connection=RF
    csn.download_file    remote_path=${ru_dir}calibration_rfic4.bin.md5   local_path=/home/ute/Downloads/    connection=RF
    sleep    5s
    csn.Connect to
    ...    hostname=${host_addr}
    ...    username=${host_username}
    ...    password=${host_password}
    ...    alias=VM
    csn.send_command    command=cd /home/ute/Downloads/;ls    connection=VM
    ${file}    csn.read output    connection=VM
    should contain    ${file}     calibration_rfic
    csn.send_command    command=rm /mnt/factory/configs/unit/calibration_rfic*    connection=RF
    sleep    3s
    csn.send_command    command=ls /mnt/factory/configs/unit/ | grep rfic    connection=RF
    ${file}    csn.read output    connection=RF
    should not contain    ${file}     calibration_rfic
    run keyword and ignore error    COAM Teardown gnb connections
    csn.disconnect    connection=RF
    csn.disconnect    connection=gNB

"${Step}" Check Alarm 1901 Disappear On RawAlarmHistory
    log to console   \n Check Alarm 1901 Disappear On RawAlarmHistory
    Wait Until Keyword Succeeds    15min    20s    Check Active Alarm not Exist    alarm_filter=${alarm_filter_0}
    Wait Until Keyword Succeeds    15min    20s    Check Historic Alarm Exist    alarm_filter=${alarm_filter_0}

"${Step}" Recovery ENV
    log to console    \n Recovery ENV
    Wait Until Keyword Succeeds    5min   5s
    ...    csn.Connect to
    ...    hostname=${asik_addr}
    ...    username=${asik_username}
    ...    password=${asik_password}
    ...    alias=gNB
    csn.send_command
    ...    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts
    ...    connection=gNB
    sleep    3s
    Connect to gnb coam via ssl
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=gNB
    csn.disconnect    connection=gNB
    run keyword and ignore error    Wait Until Keyword Succeeds    20min   30s
    ...     Connect to RU and Check IP
    ...     ru_alias=RF
    ...     container_id=${FHNETcontainer_id}
    Wait Until Keyword Succeeds    10min   20s    Upload Rfic Files 
    sleep    5s
    csn.send_command    command=ls /mnt/factory/configs/unit/ | grep rfic    connection=RF
    ${file}    csn.read output    connection=RF
    should contain    ${file}     calibration_rfic
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    csn.disconnect    connection=RF
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB
    "Step6" Site reset on webui
    Check Alarm 1901 Disappear On WebEM

Connect to RU and Check IP
    [Arguments]    ${ru_alias}    ${container_id}
    ${ru_ip_addr}    Get RU IP Address
    Should Not Be Equal    ${ru_ip_addr}    0.0.0.0
    run keyword and ignore error    csn.disconnect    connection=gNB
    csn.Connect to
    ...    hostname=${asik_addr}
    ...    username=${asik_username}
    ...    password=${asik_password}
    ...    alias=gNB
    Connect To RU With Allocated IP
    ...     ru_alias=${ru_alias}
    ...     asik_alias=gNB
    ...     container_id=${container_id}
    [Teardown]    csn.disconnect    connection=ASIK Master

Upload Rfic Files
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic1.bin        remote_path=${ru_dir}    connection=RF
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic1.bin.md5    remote_path=${ru_dir}    connection=RF
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic2.bin        remote_path=${ru_dir}    connection=RF
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic2.bin.md5    remote_path=${ru_dir}    connection=RF
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic3.bin        remote_path=${ru_dir}    connection=RF
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic3.bin.md5    remote_path=${ru_dir}    connection=RF
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic4.bin        remote_path=${ru_dir}    connection=RF
    csn.upload_file   local_path=/home/ute/Downloads/calibration_rfic4.bin.md5    remote_path=${ru_dir}    connection=RF

"${Step}" Check RU Led Status In Log
    log to console   \n  Check RU Led Status In Log
    Run Keyword And Ignore Error    WEBUI Logout
    ${number}    Get RU Nomuber
    set suite variable    ${number}
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=BTS
    ${RU_addr}   Check RU IP    RU_NO=${number}
    set suite variable    ${RU_addr}
    csn.send_command    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=BTS
    csn.disconnect    connection=BTS
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.send_command    command=scp -o StrictHostKeyChecking\=no ${RU_username}@${RU_addr}:/run/startup_DEFAULT.* ${asik_dir}   connection=gNB
    sleep    3s
    ${log_file}    csn.read output    connection=gNB
    #should contain    ${log_file}     100%
    csn.send_command    command=cd /ffs/run/config/toor4nsn/;xz -d startup_DEFAULT.log.xz    connection=gNB
    ${log_file}    csn.read output    connection=gNB
    should be empty    ${log_file}

    #save logs #${SAVE LOG DIRECTORY}

    csn.send_command    command=cat /ffs/run/config/toor4nsn/startup_DEFAULT.log | grep color    connection=gNB
    ${result}    csn.read output    connection=gNB
    should contain    ${result}	  color: Red BLINKING
    should contain    ${result}	  CpriStatus is lost of sync and no TxFault dectected

    csn.send_command    command=cat /ffs/run/config/toor4nsn/startup_DEFAULT.log | grep ledModule    connection=gNB
    ${result}    csn.read output    connection=gNB
    should contain    ${result}	  YELLOW
    csn.disconnect    connection=gNB

Check RU IP
    [Arguments]    ${RU_NO}
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.send_command    command=cd /ffs/run/config;cat FRIps.txt    connection=gNB
    sleep    2s
    ${result}    csn.read output    connection=gNB
    ${RU_addr_info_line}    Get Lines Containing String    ${result}    ${RU_NO}
    ${RU_addr}    Should Match Regexp   ${RU_addr_info_line}    \\d+\\.\\d+\\.\\d+\\.\\d+
    Should not be equal    ${RU_addr}    0.0.0.0
    [Return]    ${RU_addr}
    [Teardown]    csn.disconnect    connection=gNB


Get RU Nomuber
    WEBUI Login
    ${result}    selenium_coam.Get Ru Info     ru_index=${1}
    ${RU_NO}    Set Variable    ${result['Serial number']} 
    WEBUI Logout
    [Return]      ${RU_NO}

Create Json File
    ${number}    Get RU Nomuber
    set suite variable    ${number}
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=BTS
    ${RU_addr}   Check RU IP    RU_NO=${number}
    set suite variable    ${RU_addr}
    csn.send_command    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=BTS
    csn.disconnect    connection=BTS
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    2s
    csn.send_command    command=ssh -o StrictHostKeyChecking\=no ${RU_username}@${RU_addr}    connection=gNB
    SSH To RU     alias=RF    proxy=gNB    RU_HOST=${RU_addr}
    csn.send_command    command=frmonShellClient 127.0.0.1 2000    connection=RF
    csn.write_input    data=/ action create ConfigAccess /CI/ConfigAccess_Module /module\r\n\r\n
    ...    connection=RF
    ${result}    csn.read_output_until    match=done ok    connection=RF

    csn.write_input    data=/CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs.json"\r\n\r\n
    ...    connection=RF
    ${result}    csn.read_output_until    match=done ok    connection=RF

    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    SSH To RU     alias=RF    proxy=gNB    RU_HOST=${RU_addr}

Modify Json file
    [Arguments]    ${init_value}    ${target_value}
    csn.Send command    command=cat /var/tmp/tcs.json | grep -i Tdanger    connection=RF
	  ${result}    csn.read_output    connection=RF

    csn.Send command    command=sed -i 's/"Tdanger": ${init_value},/"Tdanger": ${target_value},/g' /var/tmp/tcs.json
    ...    connection=RF
    sleep    2s

    csn.Send command    command=cat /var/tmp/tcs.json | grep -i Tdanger    connection=RF
	  ${result}    csn.read_output    connection=RF

Activate Json file
    csn.send_command    command=frmonShellClient 127.0.0.1 2000    connection=RF
    csn.write_input
    ...    data=/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs.bin" "/var/tmp/tcs.json"\r\n\r\n
    ...    connection=RF
    ${result}    csn.read_output_until    match=done ok    connection=RF

    csn.write_input    data=/CI/ConfigAccess_Module action update\r\n\r\n
    ...    connection=RF
    ${result}    csn.read_output_until    match=done ok    connection=RF

    csn.disconnect    connection=RF
    csn.Send command    command=reboot     connection=gNB
    log to console    \n reboot
    sleep    120s
    csn.disconnect    connection=gNB

Check Alarm Exist
    [Arguments]    ${alarm_filter}
    @{alarm_info}=    selenium_coam.get_active_alarm_info    timeout=60
    ${alarms_string}=    Convert To String    ${alarm_info}
    Should Contain    ${alarms_string}    ${alarm_filter}

Check Alarm 1901 Disappear On WebEM
    log to console    \n Check Alarm 1901 Disappear On WebEM
    WEBUI Login
    wait until keyword succeeds    20min    10s    Check Cell is UP
    @{alarm_info}=    selenium_coam.get_active_alarm_info    timeout=10
    ${alarms_string}=    Convert To String    ${alarm_info}
    should not contain    ${alarms_string}    1901
    WEBUI Logout

Check Historic Alarm Exist
    [Arguments]    ${alarm_filter}
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK
    csn.send_command    command=cat /tmp/RawAlarmHistory.txt | grep 'Inactive faults' -A 50 | grep 1901    connection=ASIK
    sleep    2s
    ${alarms_string}    csn.read output    connection=ASIK
    csn.disconnect    connection=ASIK
    Should Contain    ${alarms_string}    ${alarm_filter}

Check Active Alarm not Exist
    [Arguments]    ${alarm_filter}
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK
    csn.send_command    command=cat /tmp/RawAlarmHistory.txt | grep 'Inactive faults' -B 50 | grep 1901    connection=ASIK
    sleep    2s
    ${alarms_string}    csn.read output    connection=ASIK
    csn.disconnect    connection=ASIK
    Should not Contain    ${alarms_string}    ${alarm_filter}

Check Led Status of Unit
    @{module_list}    Create List    SMOD-1    BBMOD-1    RMOD-1
    FOR    ${module}    IN    @{module_list}
        ${module_status}=    Get led status of unit    unit_name=${module}
        Should be equal as strings    ${module_status}    Online    msg=${module} current status is ${module_status}    ignore_case=${True}
    END

Get Led status of unit
    [Arguments]    ${unit_name}
    ${led_status}    selenium_coam.Get Led Status Of An Unit    unit=${unit_name}
    [Return]    ${led_status}

RU Led Status Change to Green
    ${RU_State}      5GC002118_common_KW.Check Given RU Led State       ru=1
    should be equal    ${RU_State}    Online

SSH To RU
    [Arguments]  ${alias}=${RU_ALIAS}     ${proxy}=ASOD    ${RU_HOST}=${RU_ADDR}
    csn.connect to    hostname=${RU_HOST}    username=${RU_USER}     password=${RU_PASSWORD}    alias=${alias}    proxy=${proxy} 

Case preparation
    COAM Create log directory
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to Capacity Unit Loner    alias=ABIL Loner_1
    #Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK Master    connection=GNB_OAM
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=ASIK Master
    Connect to RU With Allocated IP
    ...     ru_index=${1}
    ...     ru_alias=RU_1
    ...     asik_alias=ASIK Master
    ...     connection=GNB_OAM
    ...     container_id=${FHNETcontainer_id}

Teardown connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=ABIL Loner_1
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=RU_1

COAM Common Setup
    COAM Create log directory
    COAM Wait for gnb ready and cell setup

COAM Common Teardown    
    COAM Wait for gnb ready and cell setup
    COAM Teardown gnb connections
