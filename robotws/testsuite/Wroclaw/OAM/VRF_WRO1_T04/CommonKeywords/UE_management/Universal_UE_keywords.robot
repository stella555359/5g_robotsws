*** Settings ***
Documentation
...     Author: Krzysztof Kulibab
...     Contact: krzysztof.kulibab@nokia.com
...     Group in charge: 5G_PZ_1_WRO_6_SG
...     Following keywords can be used for preparation and run 5G throughput tests on single or multiple UEs
...     Including attach, detach, UL/DL throughput and its verification.
...     NOTE: Iperf3 has to be manually uploaded to UE's /data/local/tmp directory
...     It can be downloaded from: https://github.com/KnightWhoSayNi/android-iperf
...     Keywords from this set were tested with following UEs:
...     Nokia 8.3 5G SA - All KW works properly
...     Askey RTL630X SA - All KW works properly
...     Qualcomm SDX55 SA - All KW works properly
...     Samsung S21 SA + VoNR - All KW works properly

Resource    UE_management_resources/UniversalUEKeywords.robot
Resource    ../Logs_collection/Sherpa_Logs.robot

Library     Process
Library     Collections
Library     String
Library     UE_management_resources/UniversalUEKeywords.py
Library     taf.transport.ssh    WITH NAME    csn

*** Variables ***
${TPUT}     20M
${UE_control_pc}    ${tl.ues[0].ssh_connection_details.addr}
${UE_control_pc_user}    ${tl.ues[0].ssh_connection_details.username}
${UE_control_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${APPSERVER_IP}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${APPS_USERNAME}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${APPS_PASSWORD}    ${tl.appserver.iperf_details.ssh_connection_details.password}
${APPS_NETWORK_IF}    ${tl.appserver.iperf_details.network_interface_address}


*** Keywords ***
Download and prepare gnb_logs
    Check if gnb_logs exist and remove
    Run  wget -P /home/ute https://gitlabe2.ext.net.nokia.com/p5li/gnb_logs_tool/-/raw/master/gnb_logs.zip
    Run  unzip /home/ute/gnb_logs.zip -d /home/ute/
    Run  rm /home/ute/gnb_logs.zip
    Run  chmod +x /home/ute/gnb_logs/gnb_logs
    Run  cd /home/ute/gnb_logs && yes | ./gnb_logs -v

Check if gnb_logs exist and remove
    [Arguments]   ${path_to_gnb_logs}=/home/ute/
    ${not_exist}=  Run Keyword And Return Status  File Should Not Exist  ${path_to_gnb_logs}gnb_logs.zip
    ${dir_not_exist}=  Run Keyword And Return Status  Directory Should Not Exist  ${path_to_gnb_logs}gnb_logs
    Run Keyword Unless  ${not_exist}  Remove File  ${path_to_gnb_logs}gnb_logs.zip
    Run Keyword Unless  ${dir_not_exist}  Remove Directory  ${path_to_gnb_logs}gnb_logs  recursive=True

Start gnb_logs
    [Arguments]  ${file_name}
    ${gnb_logs_col}=  Start Process   command=./gnb_logs -N /home/ute/gnb_logs/${file_name} -c -t 10  shell=yes  cwd=/home/ute/gnb_logs/
    [Return]  ${gnb_logs_col}

Find and unzip csv files
    ${rc}  ${output}=  Run And Return Rc And Output  find *_TTI/tti_packed/*ttiTrace/*dl__all.csv
    [Return]  ${output}

Remove logs if exist
    ${exist_TS1}=    Run Keyword and return status    Directory Should Exist    /home/ute/gnb_logs/TS1
    ${exist_TS2}=    Run Keyword and return status    Directory Should Exist    /home/ute/gnb_logs/TS2
    Run Keyword If  ${exist_TS1}  Run  rm -rf /home/ute/gnb_logs/TS1
    Run Keyword If  ${exist_TS2}  Run  rm -rf /home/ute/gnb_logs/TS2

Attach and run throughput on every UE simultaneously
    [Arguments]     ${DL_TPUT}=20    ${UL_TPUT}=20    ${time}=45    ${file_name}=TS1    ${Detach}=True
    ...  ${mplane}=2a00:8a00:6000:607c::1:b64e  ${destination_ip}=2a00:8a00:6000:607c::24a6  ${path_logs_file}=/home/ute/Sherpa_Logs
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    Connect to appserver    ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    appserver
    ${UE_serial_numbers}=   Discover connected UEs and return serial numbers
    Check Iperf on UEs     ${UE_serial_numbers}    cpc
    ${ue_ips}=     Attach all UEs and return IPs   ${UE_serial_numbers}    Detach=${Detach}
    ${UL_ports}     ${DL_ports}=    Find free ports for uplink and downlink for multiple UEs    ${UE_serial_numbers}
    ${pids}=    Listen for UL throughput from multiple UEs on appserver     ${UE_serial_numbers}    ${UL_ports}
    Listen for DL throughput from appserver on multiple UEs     ${UE_serial_numbers}    ${DL_ports}
    Start UL throughput on multiple UEs simultaneously      ${UE_serial_numbers}     ${APPS_NETWORK_IF}   ${UL_ports}     ${UL_TPUT}     ${time}
    FOR    ${i}    IN RANGE    0    3
        csn.send command    ${ul_command_${i}}    connection=cpc
    END
    Start Sherpa     ${mplane}    ${destination_ip}  ${path_logs_file}
    Sleep  30s
    Run Keyword And Continue On Failure    Stop Sherpa
    Kill iperf on all UEs   ${UE_serial_numbers}
    Kill multiple iperf processes on appserver     ${pids}
    Download throughput files from multiple UEs     ${UL_ports}     ${DL_ports}
    Convert pcap to sherpa csv  output_file_path=${path_logs_file}
#    ${gnb_logs_col}=    Start gnb_logs    ${file_name}
#    Wait For Process    ${gnb_logs_col}    timeout=600
#    Kill iperf on all UEs   ${UE_serial_numbers}
#    Kill multiple iperf processes on appserver     ${pids}
#    Download throughput files from multiple UEs     ${UL_ports}     ${DL_ports}
#    ${files}=    Run    command=cd /home/ute/gnb_logs/${file_name} && unzip *.zip
#    ${files}=    Fetch From Right    ${files}    inflating:
#    ${files}=    Replace String Using Regexp    ${files}    \\D+$  .ul__all.csv
#    ${files}=    Strip String    ${files}
#    [Return]    ${file_name}/${files}
    [Teardown]    Run keywords
    ...         Remove throughput files from multiple UEs and Appserver    ${UL_ports}    ${DL_ports}    AND
    ...         Disconnect from UE PC   AND
    ...         Disconnect from appserver

#Attach and run throughput on every UE simultaneously
#    [Arguments]     ${DL_TPUT}=20M    ${UL_TPUT}=20M    ${time}=45    ${file_name}=TS1    ${Detach}=True
#    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
#    Connect to appserver    ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    appserver
#    ${UE_serial_numbers}=   Discover connected UEs and return serial numbers
#    Check Iperf on UEs     ${UE_serial_numbers}    cpc
#    ${ue_ips}=     Attach all UEs and return IPs   ${UE_serial_numbers}    Detach=${Detach}
#    ${UL_ports}     ${DL_ports}=    Find free ports for uplink and downlink for multiple UEs    ${UE_serial_numbers}
#    ${pids}=    Listen for UL throughput from multiple UEs on appserver     ${UE_serial_numbers}    ${UL_ports}
#    Listen for DL throughput from appserver on multiple UEs     ${UE_serial_numbers}    ${DL_ports}
#    Start UL throughput on multiple UEs simultaneously      ${UE_serial_numbers}     ${APPS_NETWORK_IF}   ${UL_ports}     ${UL_TPUT}     ${time}
#    FOR    ${i}    IN RANGE    0    3
#        csn.send command    ${ul_command_${i}}    connection=cpc
#    END
#    ${gnb_logs_col}=    Start gnb_logs    ${file_name}
#    Wait For Process    ${gnb_logs_col}    timeout=600
#    Kill iperf on all UEs   ${UE_serial_numbers}
#    Kill multiple iperf processes on appserver     ${pids}
#    Download throughput files from multiple UEs     ${UL_ports}     ${DL_ports}
#    ${files}=    Run    command=cd /home/ute/gnb_logs/${file_name} && unzip *.zip
#    ${files}=    Fetch From Right    ${files}    inflating:
#    ${files}=    Replace String Using Regexp    ${files}    \\D+$  .ul__all.csv
#    ${files}=    Strip String    ${files}
#    [Return]    ${file_name}/${files}
#    [Teardown]    Run keywords
#    ...         Remove throughput files from multiple UEs and Appserver    ${UL_ports}    ${DL_ports}    AND
#    ...         Disconnect from UE PC   AND
#    ...         Disconnect from appserver

Start UL throughput on multiple UEs simultaneously
    [Documentation]     Start iperf uplink throughput on appserver to every UE in the setup
    [Arguments]     ${UE_serial_numbers}     ${APPS_NETWORK_IF}   ${UL_ports}     ${TPUT}=20    ${time}=20   ${session}=cpc
    ${type}=  Evaluate  type($TPUT).__name__
    ${TPUT}=  Run Keyword If  '${type}'=='list'  Set Variable  ${TPUT}  ELSE  Create List  ${TPUT}
    ${list_or_not}=  Get Length  ${TPUT}
    ${max_TPUT}=  Run Keyword If  ${list_or_not}!=0    Evaluate  max(${TPUT})
    ${iteration}=  Set Variable  0
    FOR     ${UE_serial_number}     IN  @{UE_serial_numbers}
        ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
        ${iperf}=   Run keyword if  ${is_askey}!=True
        ...     set variable     iperf3
        ...     ELSE    set variable     iperf-android -u
        ${iperf_command}=     run keyword if  ${is_askey}==True
        ...     Create UL iperf command for askey   ${UE_serial_number}     ${session}
        ...     ELSE
        ...     set variable    adb -s ${UE_serial_number} shell /data/local/tmp/${iperf}
        ${index}=   Get index from list     ${UE_serial_numbers}    ${UE_serial_number}
        ${actual_TPUT}=  Run Keyword If  '${list_or_not}'=='1'  Set Variable  ${TPUT}[0]  ELSE  Set Variable  ${TPUT}[${iteration}]
        ${UE_TPUT}=  Run Keyword If  '${list_or_not}'!='1'  Run Keyword If  ${max_TPUT}==${actual_TPUT}
        ...  Set Variable  ${UE_serial_number}_${actual_TPUT}
        ${ul_command}=  Catenate  SEPARATOR=_  ul_command  ${iteration}
        ${command_tmp}=  catenate    ${iperf_command} -c ${APPS_NETWORK_IF} -b ${actual_TPUT}M -p ${UL_ports}[${index}] -i 1 -t ${time} -l 1300
        Set Suite Variable  ${${ul_command}}  ${command_tmp}
        Log To Console    \n--> INFO: Starting uplink on UE: ${UE_serial_number} on port ${UL_ports}[${index}]
        ${iteration}=   Evaluate  ${iteration}+1
    END

Start DL throughput on appserver to multiple UEs simultaneously
    [Arguments]    ${UE_serial_numbers}    ${ue_ips}    ${DL_ports}    ${APPS_NETWORK_IF}       ${TPUT}  ${time}=20     ${session}=appserver
    ${type}=  Evaluate  type($TPUT).__name__
    ${TPUT}=  Run Keyword If  '${type}'=='list'  Set Variable  ${TPUT}  ELSE  Create List  ${TPUT}
    ${list_or_not}=  Get Length  ${TPUT}
    ${iteration}=  Set Variable  0
    FOR     ${UE_serial_number}     IN  @{UE_serial_numbers}
        ${ping_command}=    set variable    adb -s ${UE_serial_number} shell ping -w 3 ${APPS_NETWORK_IF}
        csn.execute       ${ping_command}    connection=cpc
        ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
        ${iperf}=   Run keyword if  ${is_askey}!=True
        ...     set variable     iperf3
        ...     ELSE    set variable     iperf -u
        ${index}=   Get index from list     ${UE_serial_numbers}    ${UE_serial_number}
        ${ue_ip}=   Get from dictionary     ${ue_ips}   ${UE_serial_number}
        ${actual_TPUT}=  Run Keyword If  '${list_or_not}'=='1'  Set Variable  ${TPUT}[0]  ELSE  Set Variable  ${TPUT}[${iteration}]
        ${dl_command}=  Catenate  SEPARATOR=_  dl_command  ${iteration}
        ${command_tmp}=    Catenate      ${iperf} -c ${ue_ip} -b ${actual_TPUT}M -p ${DL_ports}[${index}] -i 1 -t ${time} -l 1300
        Set Suite Variable  ${${dl_command}}  ${command_tmp}
        Log To Console    \n--> INFO: Starting downlink on Appserver to UE ${UE_serial_number} on port ${DL_ports}[${index}]
        ${ping_command}=    set variable    adb -s ${UE_serial_number} shell ping -w 3 ${APPS_NETWORK_IF}
        csn.send command       ${ping_command}    connection=cpc
        ${iteration}=   Evaluate  ${iteration}+1
    END

Attach and run throughput on every UE simultaneously 8940
    [Arguments]     ${TPUT_case}=DL  ${DL_TPUT}=500    ${UL_TPUT}=20    ${time}=75    ${file_name}=TS1    ${Detach}=False
    ...  ${mplane}=2a00:8a00:6000:607c::1:b64e  ${destination_ip}=2a00:8a00:6000:607c::24a6  ${path_logs_file}=/home/ute/Sherpa_Logs
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    Connect to appserver    ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    appserver
    ${UE_serial_numbers}=   Discover connected UEs and return serial numbers
    Check Iperf on UEs     ${UE_serial_numbers}    cpc
    Turn ONOFF Airplane Mode    ${UE_serial_numbers}
    ${ue_ips}=     Return IPs   ${UE_serial_numbers}    Detach=${Detach}
    ${UL_ports}     ${DL_ports}=    Find free ports for uplink and downlink for multiple UEs    ${UE_serial_numbers}
    ${pids}=    Listen for UL throughput from multiple UEs on appserver     ${UE_serial_numbers}    ${UL_ports}
    Listen for DL throughput from appserver on multiple UEs     ${UE_serial_numbers}    ${DL_ports}
    Run Keyword If  '${TPUT_case}'=='UL' or '${TPUT_case}'=='ULandDL'  Start UL throughput on multiple UEs simultaneously
    ...    ${UE_serial_numbers}     ${APPS_NETWORK_IF}   ${UL_ports}     ${UL_TPUT}     ${time}
    Run Keyword If  '${TPUT_case}'=='DL' or '${TPUT_case}'=='ULandDL'  Start DL throughput on appserver to multiple UEs simultaneously
    ...    ${UE_serial_numbers}    ${ue_ips}    ${DL_ports}    ${APPS_NETWORK_IF}    ${DL_TPUT}    ${time}
#    ${gnb_logs_col}=    Start gnb_logs    ${file_name}
    Sleep    1m
    FOR    ${i}    IN RANGE    0    3
        Run Keyword If  '${TPUT_case}'=='UL' or '${TPUT_case}'=='ULandDL'  csn.send command    ${ul_command_${i}}    connection=cpc
        Run Keyword If  '${TPUT_case}'=='DL' or '${TPUT_case}'=='ULandDL'  csn.send command    ${dl_command_${i}}    connection=appserver
    END
    Start Sherpa     ${mplane}    ${destination_ip}  ${path_logs_file}
    Sleep  30s
    Run Keyword And Continue On Failure    Stop Sherpa
    Kill iperf on all UEs   ${UE_serial_numbers}
    Kill multiple iperf processes on appserver     ${pids}
    Download throughput files from multiple UEs     ${UL_ports}     ${DL_ports}
    Convert pcap to sherpa csv  output_file_path=${path_logs_file}
    [Teardown]    Run keywords
    ...         Remove throughput files from multiple UEs and Appserver    ${UL_ports}    ${DL_ports}    AND
    ...         Disconnect from UE PC   AND
    ...         Disconnect from appserver

Attach and run throughput on every UE
    [Documentation]     Send UL/DL throughput on every connected UE and verify it
    [Arguments]     ${TPUT}=20M  ${time}=20
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    Connect to appserver    ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    appserver
    ${UE_serial_numbers}=   Discover connected UEs and return serial numbers
    Check Iperf on UEs     ${UE_serial_numbers}    cpc
    Turn ONOFF Airplane Mode    ${UE_serial_numbers}
    Sleep      30s
    ${ue_ips}=    Return IPs    ${UE_serial_numbers}     cpc     False
#    ${ue_ips}=     Attach all UEs and return IPs   ${UE_serial_numbers}
    ${UL_ports}     ${DL_ports}=    Find free ports for uplink and downlink for multiple UEs    ${UE_serial_numbers}
    ${pids}=    Listen for UL throughput from multiple UEs on appserver     ${UE_serial_numbers}    ${UL_ports}
    Listen for DL throughput from appserver on multiple UEs     ${UE_serial_numbers}    ${DL_ports}
    Start UL throughput on multiple UEs      ${UE_serial_numbers}     ${APPS_NETWORK_IF}   ${UL_ports}     ${TPUT}     ${time}
    Start DL throughput on appserver to multiple UEs    ${UE_serial_numbers}    ${ue_ips}    ${DL_ports}    ${APPS_NETWORK_IF}    ${TPUT}    ${time}
    Kill iperf on all UEs   ${UE_serial_numbers}
    Kill multiple iperf processes on appserver     ${pids}
    Download throughput files from multiple UEs     ${UL_ports}     ${DL_ports}
    Verify throughput from multiple UEs     ${UL_ports}     ${DL_ports}
    [Teardown]  Run keywords
    ...         Remove throughput files from multiple UEs and Appserver    ${UL_ports}    ${DL_ports}    AND
    ...         Disconnect from UE PC   AND
    ...         Disconnect from appserver

Attach and run UL and DL throughput on chosen UE
    [Documentation]     Send UL/DL throughput on chosen UE and verify it. UE serial number has to be passed
    ...                 It can be obtained by using "adb devices" command on UE PC
    [Arguments]     ${UE_serial_number}     ${TPUT}=20M  ${time}=20
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    Connect to appserver    ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    appserver
    ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
    ${iperf}=   Run keyword if  ${is_askey}!=True
    ...     set variable     iperf3
    ...     ELSE    set variable     iperf
    Detach all UEs
    ${ue_ip}=   Attach UE and get its IP    ${UE_serial_number}
    ${UL_port}  ${DL_port}=  Find free ports for uplink and downlink    ${iperf}
    ${pid}=    Listen for UL throughput on appserver  ${UL_port}    ${iperf}    appserver
    Listen for DL throughput on UE  ${UE_serial_number}     ${DL_port}   ${iperf}    cpc
    Start UL throughput on UE   ${UE_serial_number}     ${APPS_NETWORK_IF}   ${UL_port}     iperf3   ${TPUT}    ${time}  cpc
    Start DL throughput on Appserver    ${ue_ip}    ${DL_port}    ${UE_serial_number}    ${iperf}  ${TPUT}     ${time}     appserver
    Kill iperf on appserver    ${pid}
    Kill iperf on UE    ${UE_serial_number}
    Download throughput files   ${UL_port}  ${DL_port}
    Verify throughput   ${UL_port}  ${DL_port}
    [Teardown]  Run keywords
    ...         Remove throughput files    ${UL_port}    ${DL_port}    AND
    ...         Disconnect from UE PC   AND
    ...         Disconnect from appserver

Attach UEs With Sherpa
    [Arguments]     ${file_name}=TS1    ${Detach}=False    ${mplane}=2a00:8a00:6000:607c::1:b64e
    ...    ${destination_ip}=2a00:8a00:6000:607c::24a6  ${path_logs_file}=/home/ute/Sherpa_Logs
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    ${UE_serial_numbers}=   Discover connected UEs and return serial numbers
    Start Sherpa     ${mplane}    ${destination_ip}  ${path_logs_file}
    Turn ONOFF Airplane Mode    ${UE_serial_numbers}
    ${ue_ips}=     Return IPs   ${UE_serial_numbers}    Detach=${Detach}
#    ${ue_ips}=     Attach all UEs and return IPs   ${UE_serial_numbers}    Detach=${Detach}
    Sleep  30s
    Run Keyword And Continue On Failure    Stop Sherpa
    Convert pcap to sherpa csv  output_file_path=${path_logs_file}
    [Teardown]    Run keyword
    ...         Disconnect from UE PC

Connect to UE PC
    [Documentation]     Setup connection to UE PC
    [Arguments]     ${UE_control_pc}  ${UE_control_pc_user}     ${UE_control_pc_password}  ${alias}=cpc
    Log To Console    \n--> INFO: connecting to UE PC
    Wait Until Keyword Succeeds    1min    20s    csn.Connect to
    ...             hostname=${UE_control_pc}
    ...             username=${UE_control_pc_user}
    ...             password=${UE_control_pc_password}
    ...             alias=${alias}

Connect to appserver
    [Documentation]     Setup connection to UE PC
    [Arguments]         ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    ${session}=appserver
    Log To Console    \n--> INFO: connecting to appserver
    csn.Connect To      hostname=${APPSERVER_IP}
    ...                 username=${APPS_USERNAME}
    ...                 password=${APPS_PASSWORD}
    ...                 alias=${session}

Disconnect from UE PC
    [Documentation]     Disconnect from UE PC
    [Arguments]     ${session}=cpc
    csn.disconnect  connection=${session}

Disconnect from appserver
    [Documentation]     Disconnect from Appserver
    [Arguments]     ${session}=appserver
    csn.disconnect  connection=${session}

Discover connected UEs and return serial numbers
    [Documentation]     Sends "adb devices" command on UE PC and return list of connected UE's serial numbers
    [Arguments]     ${session}=cpc
    csn.send_command    adb devices    connection=${session}
    ${adb_output}=      csn.read_output   connection=${session}
    ${ue_ids}=     get_ue_ids_from_adb_output  ${adb_output}
    [Return]    ${ue_ids}

Attach UE and get its IP
    [Documentation]     This keyword sends AT command on every COM port of the UE PC
    ...                 Then checks if UE with given serial number obtained IP address.
    ...                 Keyword retuns UE IP address
    [Arguments]     ${UE_serial_number}    ${session}=cpc
    Log To Console    \n--> INFO: Attempt of attach UE: ${UE_serial_number}
    ${regexp}    Catenate   192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}
    csn.send_command     ls /dev/ttyS*    connection=${session}
    ${list_of_ttyS}=     csn.read_output   connection=${session}
    ${list_of_ttyS}=     Get Regexp Matches     ${list_of_ttyS}    /dev/ttyS[0-9]{1,2}
    FOR  ${ttyS}  IN  @{list_of_ttyS}
        ${attach_command}=    Catenate    echo -ne 'AT+CGATT=1\r' > ${ttyS}\n
        ${has_ip}=  Check if UE has IP  ${UE_serial_number}
        run keyword if  ${has_ip}==False
        ...     Send att command     ${ttyS}     ${attach_command}
        ${result}=  Run keyword and return status    Wait Until Keyword Succeeds  20 sec  5 sec
        ...                                          Wait until UE has IP  ${UE_serial_number}     ${session}

        ${ue_ip}=   run keyword if  ${result}
        ...     Return UE ip   ${UE_serial_number}    ${session}
        Exit for loop if    ${result}
    END
    Should not be true  '${ue_ip}'=='None'
    Log To Console    \n--> INFO: UE: ${UE_serial_number} successfuly attached
    [Return]    ${ue_ip}

Detach all UEs
    [Documentation]     This keyword sends AT command which detaches UE on every COM port of UE PC
    [Arguments]     ${session}=cpc
    Log To Console    \n--> INFO: Detaching all UEs
    csn.send_command     ls /dev/ttyS*    connection=${session}
    ${list_of_ttyS}=     csn.read_output   connection=${session}
    ${list_of_ttyS}=     Get Regexp Matches     ${list_of_ttyS}    /dev/ttyS[0-9]{1,2}
    FOR  ${ttyS}  IN  @{list_of_ttyS}
        ${detach_command}=    Catenate    echo -ne 'AT+CGATT=0\r' > ${ttyS}
        csn.send_command   ${detach_command}    connection=${session}
        Sleep   30
    END

Find free ports for uplink and downlink
    [Documentation]     This keyword gets and returns pair of random ports for uplink and downlink
    [Arguments]     ${iperf}=iperf3    ${session}=appserver
    FOR  ${i}  IN RANGE   1
        ${ul_port}=    Evaluate   random.randint(1000, 9999)    random
        ${dl_port}=    Set variable    ${ul_port+1}
        ${command}=    Catenate   ps -aux | grep ${iperf} | tr -s ' ' | grep -e '-p ${ul_port}' | awk '{print $2}'
        ${pid}=        csn.execute   ${command}    connection=${session}    timeout=5
        @{pid_list}=   Split String    ${pid}       \r\n
        ${pid_nr}=     Get length      ${pid_list}
        Run keyword if    ${pid_nr}==2    csn.send command    kill -9 ${pid_list}[0]    connection=${session}
        Exit For Loop If    ${pid_nr} <= 1
    END
    [Return]       ${ul_port}   ${dl_port}

Listen for UL throughput on appserver
    [Documentation]     Start iperf listener on appserver on given uplink port
    [Arguments]     ${UL_port}    ${iperf}=iperf3  ${session}=appserver
    ${iperf}=   run keyword if  '${iperf}'!='iperf3'
    ...     set variable    iperf -u
    ...     ELSE
    ...     set variable    iperf3
    Log To Console    \n--> INFO: Starting Iperf listener on port ${UL_port} on Appserver
    ${listen}=     Catenate     ${iperf} -s -i 1 -p ${UL_port} > /tmp/iperf_UL_${UL_port}.txt 2>&1 &
    csn.Send command    ${listen}    connection=${session}
    ${command}=    Catenate   ps -aux | grep ${iperf} | tr -s ' ' | grep -e '-p ${UL_port}' | awk '{print $2}'
    ${pid}=        csn.execute   ${command}    connection=${session}    timeout=5
    ${pid}=        Fetch From Left    ${pid}  \r
    [Return]  ${pid}

Listen for DL throughput on UE
    [Documentation]     Start iperf listener on chosen UE, on given downlink port
    [Arguments]     ${UE_serial_number}    ${DL_port}   ${iperf}=iperf3    ${session}=cpc
    ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     ${session}
    Log To Console    \n--> INFO: Starting Iperf listener on port ${DL_port} on UE
    ${iperf}=   run keyword if  '${iperf}'!='iperf3'
    ...     set variable    iperf-android -u
    ...     ELSE
    ...     set variable    iperf3
    ${command}=     run keyword if  ${is_askey}==True
    ...     set variable    /cygdrive/c/iperf/iperf.exe -u
    ...     ELSE
    ...     set variable    adb -s ${UE_serial_number} shell /data/local/tmp/${iperf}
    csn.send_command     ${command} -s -i 1 -p ${DL_port} > /tmp/iperf_DL_${DL_port}.txt 2>&1 &
    ...                  connection=${session}

Start UL throughput on UE
    [Documentation]     Start iperf uplink throughput on chosen UE
    [Arguments]     ${UE_serial_number}     ${APPS_NETWORK_IF}   ${UL_port}     ${iperf}=iperf3     ${TPUT}=20M    ${time}=20   ${session}=cpc
    ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     ${session}
    Log To Console    \n--> INFO: Starting uplink on UE ${UE_serial_number} on port ${UL_port}
    ${iperf}=   run keyword if  '${iperf}'!='iperf3'
    ...     set variable    iperf-android -u
    ...     ELSE
    ...     set variable    iperf3
    ${command}=     run keyword if  ${is_askey}==True
    ...     Create UL iperf command for askey   ${UE_serial_number}     ${session}
    ...     ELSE
    ...     set variable    adb -s ${UE_serial_number} shell /data/local/tmp/${iperf}
    ${command}  catenate    ${command} -c ${APPS_NETWORK_IF} -b ${TPUT} -p ${UL_port} -i 1 -t ${time}
    csn.execute     ${command}  connection=${session}

Start DL throughput on Appserver
    [Documentation]     Start iperf downlink throughput on appserver
    [Arguments]       ${ue_ip}    ${DL_port}     ${UE_serial_number}    ${iperf}=iperf3    ${TPUT}=20M    ${time}=20    ${session}=appserver
    ${iperf}=   run keyword if  '${iperf}'!='iperf3'
    ...     set variable    iperf -u
    ...     ELSE
    ...     set variable    iperf3
    Log To Console    \n--> INFO: Starting downlink on Appserver on port ${DL_port}
    ${command}=    Catenate      ${iperf} -c ${ue_ip} -b ${TPUT} -p ${DL_port} -i 1 -t ${time} -l 1300
    ${ping_command}=    set variable    adb -s ${UE_serial_number} shell ping -w 3 ${APPS_NETWORK_IF}
    csn.send command       ${ping_command}    connection=cpc
    csn.execute       ${command}    connection=${session}

Kill iperf on appserver
    [Documentation]     Kill iperf process on appserver
    [Arguments]    ${pid}   ${session}=appserver
    csn.send_command    kill -9 ${pid}    connection=${session}

Kill iperf on UE
    [Documentation]     Kill iperf process on UE
    [Arguments]      ${UE_serial_number}     ${session}=cpc
    csn.execute    adb -s ${UE_serial_number} shell pkill -9 iperf    connection=${session}
    csn.execute    adb -s ${UE_serial_number} shell pkill -9 iperf3    connection=${session}

Check Iperf on UEs
    [Documentation]     Checks if iperf3 and iperf-android is available on UE.
    ...                 If not, iperf3 is uploaded to UE
    [Arguments]     ${UE_serial_numbers}     ${session}=cpc
    FOR     ${UE_serial_number}   IN  @{UE_serial_numbers}
        ${is_iperf3}=    Check if iperf3 exists on UE    ${UE_serial_number}   ${session}
        ${is_iperf-android}=    Check if iperf-android exists on UE    ${UE_serial_number}   ${session}
        Run keyword if  ${is_iperf3}!=True
        ...     Run keywords
        ...     log to console  Iperf3 does not exist in UE: ${UE_serial_number} /data/local/tmp directory. Upload it manually.   AND
        ...     Fail
        Run keyword if  ${is_iperf-android}!=True
        ...     Run keywords
        ...     log to console  Iperf-android does not exist in UE: ${UE_serial_number} /data/local/tmp directory. Upload it manually.   AND
        ...     Fail
    END

Attach all UEs and return IPs
    [Documentation]     Send AT command on every UEPC's COM port and check if UE obtained IP address
    ...                 Keyword returns list of IP addresses of every UEs connected to UEPC
    [Arguments]     ${UE_serial_numbers}    ${session}=cpc    ${Detach}=False
#    ${list_of_ttyS}=     csn.execute     ls /dev/ttyS*    connection=${session}     timeout=5
    csn.send_command     ls /dev/ttyS*    connection=${session}
    ${list_of_ttyS}=     csn.read_output   connection=${session}
    ${list_of_ttyS}=     Get Regexp Matches     ${list_of_ttyS}    /dev/ttyS[0-9]{1,2}
    &{ue_ips}=  Create dictionary
    Run Keyword If    ${Detach}    Detach all UEs
    FOR  ${UE_serial_number}  IN   @{UE_serial_numbers}
        Log To Console    \n--> INFO: Attempting to attach UE: ${UE_serial_number}
        ${ip}   ${com_port}=  Loop over COM ports to attach UEs   ${UE_serial_number}     ${list_of_ttyS}   ${session}
        set to dictionary   ${ue_ips}   ${UE_serial_number}   ${ip}
        remove values from list     ${list_of_ttyS}     ${com_port}
    END
    [Return]    ${ue_ips}

Return IPs
    [Documentation]     Keyword returns list of IP addresses of every UEs connected to UEPC
    [Arguments]     ${UE_serial_numbers}    ${session}=cpc    ${Detach}=True
#    ${list_of_ttyS}=     csn.execute     ls /dev/ttyS*    connection=${session}     timeout=5
    csn.send_command     ls /dev/ttyS*    connection=${session}
    ${list_of_ttyS}=     csn.read_output   connection=${session}
    ${list_of_ttyS}=     Get Regexp Matches     ${list_of_ttyS}    /dev/ttyS[0-9]{1,2}
    &{ue_ips}=  Create dictionary
    Run Keyword If    ${Detach}    Detach all UEs
    FOR  ${UE_serial_number}  IN   @{UE_serial_numbers}
        Log To Console    \n--> INFO: Attempting to attach UE: ${UE_serial_number}
        ${ip}   ${com_port}=  Loop over COM ports to check UE IP   ${UE_serial_number}    ${session}
        set to dictionary   ${ue_ips}   ${UE_serial_number}   ${ip}
#        remove values from list     ${list_of_ttyS}     ${com_port}
    END
    [Return]    ${ue_ips}

Find free ports for uplink and downlink for multiple UEs
    [Documentation]     Find and return pair of random ports for UL and DL.
    ...                 Number of returned ports pairs depends of number of UEs connected to UEPC
    [Arguments]     ${UE_serial_numbers}    ${iperf}=iperf3    ${session}=appserver
    @{UL_ports}=  Create list
    @{DL_ports}=  Create list
    FOR     ${ue}   IN  @{UE_serial_numbers}
        ${UL_port}  ${DL_port}=     Find free ports for uplink and downlink     ${iperf}    ${session}
        append to list  ${UL_ports}     ${UL_port}
        append to list  ${DL_ports}     ${DL_port}
    END
    [Return]    ${UL_ports}     ${DL_ports}

Listen for UL throughput from multiple UEs on appserver
    [Documentation]     Start iperf listener on appserver on every given uplink ports
    [Arguments]     ${UE_serial_numbers}    ${UL_ports}   ${session}=appserver
    @{pids}=  Create list
    FOR     ${UE_serial_number}     IN  @{UE_serial_numbers}
        ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
        ${iperf}=   Run keyword if  ${is_askey}!=True
        ...     set variable     iperf3
        ...     ELSE    set variable     iperf
        ${index}=   Get index from list     ${UE_serial_numbers}    ${UE_serial_number}
        ${pid}=     Listen for UL throughput on appserver  ${UL_ports}[${index}]     ${iperf}
        append to list  ${pids}     ${pid}
    END
    [Return]    ${pids}

Listen for DL throughput from appserver on multiple UEs
    [Documentation]     Start iperf listener on every UE connected to UEPC, downlink ports
    [Arguments]     ${UE_serial_numbers}    ${DL_ports}   ${session}=cpc
    FOR     ${UE_serial_number}     IN  @{UE_serial_numbers}
        ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
        ${iperf}=   Run keyword if  ${is_askey}!=True
        ...     set variable     iperf3
        ...     ELSE    set variable     iperf-android -u
        ${command}=     run keyword if  ${is_askey}==True
        ...     set variable    /cygdrive/c/iperf/iperf.exe -u
        ...     ELSE
        ...     set variable    adb -s ${UE_serial_number} shell /data/local/tmp/${iperf}
        ${index}=   Get index from list     ${UE_serial_numbers}    ${UE_serial_number}
        Log To Console    \n--> INFO: Starting Iperf listener on UE: ${UE_serial_number} on port ${DL_ports}[${index}]
        csn.send_command     ${command} -s -i 1 -p ${DL_ports}[${index}] > /tmp/iperf_DL_${DL_ports}[${index}].txt 2>&1 &
        ...                  connection=${session}
    END

Start UL throughput on multiple UEs
    [Documentation]     Start iperf uplink throughput on appserver to every UE in the setup
    [Arguments]     ${UE_serial_numbers}     ${APPS_NETWORK_IF}   ${UL_ports}     ${TPUT}=20M    ${time}=20   ${session}=cpc
    FOR     ${UE_serial_number}     IN  @{UE_serial_numbers}
        ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
        ${iperf}=   Run keyword if  ${is_askey}!=True
        ...     set variable     iperf3
        ...     ELSE    set variable     iperf-android -u
        ${iperf_command}=     run keyword if  ${is_askey}==True
        ...     Create UL iperf command for askey   ${UE_serial_number}     ${session}
        ...     ELSE
        ...     set variable    adb -s ${UE_serial_number} shell /data/local/tmp/${iperf}
        ${index}=   Get index from list     ${UE_serial_numbers}    ${UE_serial_number}
        ${command}=  catenate    ${iperf_command} -c ${APPS_NETWORK_IF} -b ${TPUT} -p ${UL_ports}[${index}] -i 1 -t ${time} -l 1300
        Log To Console    \n--> INFO: Starting uplink on UE: ${UE_serial_number} on port ${UL_ports}[${index}]
        csn.execute     ${command}  connection=${session}
    END

Start DL throughput on appserver to multiple UEs
    [Documentation]     Start iperf downlink throughput on every UE in the setup
    [Arguments]    ${UE_serial_numbers}    ${ue_ips}    ${DL_ports}    ${APPS_NETWORK_IF}    ${TPUT}=20M   ${time}=20     ${session}=appserver
    FOR     ${UE_serial_number}     IN  @{UE_serial_numbers}
        ${ping_command}=    set variable    adb -s ${UE_serial_number} shell ping -w 3 ${APPS_NETWORK_IF}
        csn.execute       ${ping_command}    connection=cpc
        ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
        ${iperf}=   Run keyword if  ${is_askey}!=True
        ...     set variable     iperf3
        ...     ELSE    set variable     iperf -u
        ${index}=   Get index from list     ${UE_serial_numbers}    ${UE_serial_number}
        ${ue_ip}=   Get from dictionary     ${ue_ips}   ${UE_serial_number}
#        ${command}=    Catenate      ${iperf} -c ${ue_ip} -b ${TPUT} -p ${DL_ports}[${index}] -i 1 -t ${time} -l 1300
        ${command}=    Catenate      ${iperf} -i 1 -t ${time} -p ${DL_ports}[${index}] -l 1300 -b ${TPUT} -c ${ue_ip}
        Log To Console    \n--> INFO: Starting downlink on Appserver to UE ${UE_serial_number} on port ${DL_ports}[${index}]
        ${ping_command}=    set variable    adb -s ${UE_serial_number} shell ping -w 3 ${APPS_NETWORK_IF}
        csn.send command       ${ping_command}    connection=cpc
        csn.execute       ${command}    connection=${session}
    END

Kill iperf on all UEs
    [Documentation]     Kills iperf process on every UE in the setuup
    [Arguments]      ${UE_serial_numbers}     ${session}=cpc
    FOR     ${UE_serial_number}     IN  @{UE_serial_numbers}
        ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     cpc
        run keyword if  ${is_askey}==True
        ...     Kill iperf on windows   ${session}
        csn.execute    adb -s ${UE_serial_number} shell pkill -9 iperf3    connection=${session}
        csn.execute    adb -s ${UE_serial_number} shell pkill -9 iperf    connection=${session}
    END

Kill multiple iperf processes on appserver
    [Documentation]     Kills iperf process on appserver based on given PIDs
    [Arguments]    ${pids}   ${session}=appserver
    FOR     ${pid}     IN  @{pids}
        csn.send_command    kill -9 ${pid}    connection=${session}
    END

Download throughput files
    [Documentation]     Download files with iperf's output to VM
    [Arguments]     ${UL_port}  ${DL_port}  ${UE_PC_session}=cpc    ${appserver_session}=appserver
    csn.download_file    remote_path=/tmp/iperf_UL_${UL_port}.txt
    ...                  local_path=${OUTPUT DIR}/iperf_UL_${UL_port}.txt
    ...                  connection=${appserver_session}
    csn.download_file    remote_path=/tmp/iperf_DL_${DL_port}.txt
    ...                  local_path=${OUTPUT DIR}/iperf_DL_${DL_port}.txt
    ...                  connection=${UE_PC_session}

Download throughput files from multiple UEs
    [Documentation]     Download files with iperf's output to VM from multiple UEs
    [Arguments]     ${UL_ports}  ${DL_ports}  ${UE_PC_session}=cpc    ${appserver_session}=appserver
    FOR     ${UL_port}    IN   @{UL_ports}
        csn.download_file    remote_path=/tmp/iperf_UL_${UL_port}.txt
        ...                  local_path=${OUTPUT DIR}/iperf_UL_${UL_port}.txt
        ...                  connection=${appserver_session}
    END
    FOR     ${DL_port}    IN   @{DL_ports}
        csn.download_file    remote_path=/tmp/iperf_DL_${DL_port}.txt
        ...                  local_path=${OUTPUT DIR}/iperf_DL_${DL_port}.txt
        ...                  connection=${UE_PC_session}
    END

Remove throughput files
    [Documentation]     Remove files with iperf's output from UEPC and Appserver
    [Arguments]     ${UL_port}  ${DL_port}  ${UE_PC_session}=cpc    ${appserver_session}=appserver
    csn.execute    rm /tmp/iperf_UL_${UL_port}.txt    connection=${appserver_session}
    csn.execute    rm /tmp/iperf_DL_${DL_port}.txt    connection=${UE_PC_session}

Remove throughput files from multiple UEs and Appserver
    [Documentation]     Remove files with iperf's output from UEPC and Appserver
    [Arguments]     ${UL_ports}  ${DL_ports}  ${UE_PC_session}=cpc    ${appserver_session}=appserver
    FOR     ${UL_port}    IN   @{UL_ports}
        csn.execute    rm /tmp/iperf_UL_${UL_port}.txt    connection=${appserver_session}
    END
    FOR     ${DL_port}    IN   @{DL_ports}
        csn.execute    rm /tmp/iperf_DL_${DL_port}.txt    connection=${UE_PC_session}
    END

Verify throughput
    [Documentation]     Verify throughput
    [Arguments]     ${UL_port}  ${DL_port}
    ${bitrate}    ${unit}=    convert tput    ${TPUT}
    ${bitrate}=    convert to number   ${bitrate}     1
    ${UL_tput}=    get_summary   ${OUTPUT DIR}/iperf_UL_${UL_port}.txt
    ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
    ${UL_iperf_bitrate}=     get regexp matches  ${UL_tput}  ${regexp}
    ${UL_iperf_unit}=        fetch from right     ${UL_iperf_bitrate}[0]  ${SPACE}
    ${UL_iperf_bitrate}=     fetch from left     ${UL_iperf_bitrate}[0]  ${SPACE}
    ${UL_iperf_bitrate}=     convert to number   ${UL_iperf_bitrate}  1
    Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${UL_iperf_unit}
    Run Keyword And Continue On Failure    Should Be True    ${UL_iperf_bitrate+2} > ${UL_iperf_bitrate} > ${UL_iperf_bitrate-2}
    ${DL_tput}=    get_summary   ${OUTPUT DIR}/iperf_DL_${DL_port}.txt
    ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
    ${DL_iperf_bitrate}=     get regexp matches  ${DL_tput}  ${regexp}
    ${DL_iperf_unit}=        fetch from right     ${DL_iperf_bitrate}[0]  ${SPACE}
    ${DL_iperf_bitrate}=     fetch from left     ${DL_iperf_bitrate}[0]  ${SPACE}
    ${DL_iperf_bitrate}=     convert to number   ${DL_iperf_bitrate}  1
    Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${DL_iperf_unit}
    Run Keyword And Continue On Failure    Should Be True    ${DL_iperf_bitrate+2} > ${DL_iperf_bitrate} > ${DL_iperf_bitrate-2}

Verify throughput from multiple UEs
    [Documentation]     Verify throughput from multiple UEs
    [Arguments]     ${UL_ports}  ${DL_ports}
    ${bandwidth}    ${unit}=    convert tput    ${TPUT}
    ${bandwidth}=    convert to number   ${bandwidth}     1
    FOR     ${DL_port}  IN  @{DL_ports}
        ${DL_port}=    get_summary   ${OUTPUT DIR}/iperf_DL_${DL_port}.txt
        ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
        ${bitrate}=     get regexp matches  ${DL_port}  ${regexp}
        ${iperf_unit}=        fetch from right     ${bitrate}[0]  ${SPACE}
        ${bitrate}=     fetch from left     ${bitrate}[0]  ${SPACE}
        ${bitrate}=     convert to number   ${bitrate}  1
        Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${iperf_unit}
        Run Keyword And Continue On Failure    Should Be True    ${bandwidth+2} > ${bitrate} > ${bandwidth-2}
    END
    FOR     ${UL_port}  IN  @{UL_ports}
        ${UL_tput}=    get_summary   ${OUTPUT DIR}/iperf_UL_${UL_port}.txt
        ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
        ${bitrate}=     get regexp matches  ${UL_tput}  ${regexp}
        ${iperf_unit}=        fetch from right     ${bitrate}[0]  ${SPACE}
        ${bitrate}=     fetch from left     ${bitrate}[0]  ${SPACE}
        ${bitrate}=     convert to number   ${bitrate}  1
        Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${iperf_unit}
        Run Keyword And Continue On Failure    Should Be True    ${bandwidth+2} > ${bitrate} > ${bandwidth-2}
    END

Turn ONOFF Airplane Mode
    [Documentation]     Turns on and off Airplane mode on UE
    [Arguments]      ${UE_serial_numbers}     ${session}=cpc
    Log To Console    Turn on airplane mode on UEs
    Turn on UE airplane mode    ${UE_serial_numbers}
    Log To Console    Turn off airplane mode on UEs
    Turn off UE airplane mode    ${UE_serial_numbers}

Turn on UE airplane mode
    [Documentation]     Turns on Airplane mode on UE
    [Arguments]      ${UE_serial_numbers}     ${session}=cpc
    FOR    ${UE_serial_number}    IN    @{UE_serial_numbers}
        Csn.Send Command    adb -s ${UE_serial_number} shell cmd connectivity airplane-mode enable
        ...                 connection=${session}
        ...                 timeout=5
        sleep    8s
    END

Turn off UE airplane mode
    [Documentation]     Turns off Airplane mode on UE
    [Arguments]      ${UE_serial_numbers}     ${session}=cpc
    FOR    ${UE_serial_number}    IN    @{UE_serial_numbers}
        csn.Send Command    adb -s ${UE_serial_number} shell cmd connectivity airplane-mode disable
        ...                 connection=${session}
        ...                 timeout=5
        sleep    30s
    END

#Turn on UE airplane mode
#    [Documentation]     Turns on Airplane mode on UE
#    [Arguments]      ${UE_serial_number}     ${session}=cpc
#    Csn.Send Command    adb -s ${UE_serial_number} shell "su 0 settings put global airplane_mode_on 1"
#    ...                 connection=${session}
#    ...                 timeout=5
#    sleep    3s
#    csn.send command    adb -s ${UE_serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
#    ...                 connection=${session}
#    ...                 timeout=5
#    sleep    8s
#    ${result} =    csn.read_output    connection=${session}
#    Should contain    ${result}    result=0
#
#Turn off UE airplane mode
#    [Documentation]     Turns off Airplane mode on UE
#    [Arguments]      ${UE_serial_number}     ${session}=cpc
#    csn.Send Command    adb -s ${UE_serial_number} shell "su 0 settings put global airplane_mode_on 0"
#    ...                 connection=${session}
#    ...                 timeout=5
#    sleep    3s
#    csn.send command    adb -s ${UE_serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
#    ...                 connection=${session}
#    ...                 timeout=5
#    sleep    5s
#    ${result} =    csn.read_output    connection=${session}
#    Should contain    ${result}    result=0

ADB root
    [Documentation]     Performs adb root command on chosen UE
    [Arguments]      ${UE_serial_number}     ${session}=cpc
    csn.send_command    adb -s ${UE_serial_number} root   connection=cpc
    sleep               5s

ADB reboot
    [Documentation]     Performs adb reboot command on chosen UE
    [Arguments]      ${UE_serial_number}     ${session}=cpc
    csn.send_command    adb -s ${UE_serial_number} reboot   connection=cpc
    sleep               5s
    wait until keyword succedess    2min    15s     Verify if UE is up  ${UE_serial_number}     ${session}

Verify if iperf throughput is in given range
    [Documentation]     Checks if throughput recieved by iperf is in given range
    [Arguments]     ${UL_port}  ${DL_port}    ${UL_values}    ${DL_values}
    ${bitrate}    ${unit}=    convert tput    ${TPUT}
    ${bitrate}=    convert to number   ${bitrate}     1
    ${UL_tput}=    get_summary   ${OUTPUT DIR}/iperf_UL_${UL_port}.txt
    ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
    ${UL_iperf_bitrate}=     get regexp matches  ${UL_tput}  ${regexp}
    ${UL_iperf_unit}=        fetch from right     ${UL_iperf_bitrate}[0]  ${SPACE}
    ${UL_iperf_bitrate}=     fetch from left     ${UL_iperf_bitrate}[0]  ${SPACE}
    ${UL_iperf_bitrate}=     convert to number   ${UL_iperf_bitrate}  1
    Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${UL_iperf_unit}
    Run Keyword And Continue On Failure    Should Be True    ${UL_values}[0] < ${UL_iperf_bitrate} < ${UL_values}[1]
    ${DL_tput}=    get_summary   ${OUTPUT DIR}/iperf_DL_${DL_port}.txt
    ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
    ${DL_iperf_bitrate}=     get regexp matches  ${DL_tput}  ${regexp}
    ${DL_iperf_unit}=        fetch from right     ${DL_iperf_bitrate}[0]  ${SPACE}
    ${DL_iperf_bitrate}=     fetch from left     ${DL_iperf_bitrate}[0]  ${SPACE}
    ${DL_iperf_bitrate}=     convert to number   ${DL_iperf_bitrate}  1
    Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${DL_iperf_unit}
    Run Keyword And Continue On Failure    Should Be True    ${DL_values}[0] < ${DL_iperf_bitrate} < ${DL_values}[1]

Verify if iperf throughput from multiple UEs is in given range
    [Documentation]     Verify throughput from multiple UEs
    [Arguments]     ${UL_ports}  ${DL_ports}    ${UL_values}    ${DL_values}
    ${bitrate}    ${unit}=    convert tput    ${TPUT}
    ${UL_bitrate_low}    ${UL_unit}=    convert tput    ${UL_values}[0]
    ${UL_bitrate_low}=    convert to number   ${UL_bitrate_low}     1
    ${UL_bitrate_high}    ${UL_unit}=    convert tput    ${UL_values}[1]
    ${UL_bitrate_high}=    convert to number   ${UL_bitrate_high}     1
    ${DL_bitrate_low}    ${DL_unit}=    convert tput    ${DL_values}[0]
    ${DL_bitrate_low}=    convert to number   ${DL_bitrate_low}     1
    ${DL_bitrate_high}    ${DL_unit}=    convert tput    ${DL_values}[1]
    ${DL_bitrate_high}=    convert to number   ${DL_bitrate_high}     1
    FOR     ${UL_port}  IN  @{UL_ports}
        ${UL_tput}=    get_summary   ${OUTPUT DIR}/iperf_UL_${UL_port}.txt
        ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
        ${UL_iperf_bitrate}=     get regexp matches  ${UL_tput}  ${regexp}
        ${UL_iperf_unit}=        fetch from right     ${UL_iperf_bitrate}[0]  ${SPACE}
        ${UL_iperf_bitrate}=     fetch from left     ${UL_iperf_bitrate}[0]  ${SPACE}
        ${UL_iperf_bitrate}=     convert to number   ${UL_iperf_bitrate}  1
        Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${UL_iperf_unit}
        Run Keyword And Continue On Failure    Should Be True    ${UL_bitrate_low} < ${UL_iperf_bitrate} < ${UL_bitrate_high}
    END
    FOR     ${DL_port}  IN  @{DL_ports}
        ${DL_tput}=    get_summary   ${OUTPUT DIR}/iperf_DL_${DL_port}.txt
        ${regexp}=    Catenate   [0-9]{1,4}\\.[0-9]{1,2}\\ [GMkbits/sec]{8,9}
        ${DL_iperf_bitrate}=     get regexp matches  ${DL_tput}  ${regexp}
        ${DL_iperf_unit}=        fetch from right     ${DL_iperf_bitrate}[0]  ${SPACE}
        ${DL_iperf_bitrate}=     fetch from left     ${DL_iperf_bitrate}[0]  ${SPACE}
        ${DL_iperf_bitrate}=     convert to number   ${DL_iperf_bitrate}  1
        Run Keyword And Continue On Failure    Should Be equal as strings   ${unit}     ${DL_iperf_unit}
        Run Keyword And Continue On Failure    Should Be True    ${DL_bitrate_low} < ${DL_iperf_bitrate} < ${DL_bitrate_high}
    END

Check if askey is attached to LTE or 5G
    [Documentation]     Checks if Askey is attached to LTE or 5G
    [Arguments]      ${UE_serial_number}     ${session}=cpc
    csn.send_command    adb -s ${UE_serial_number} shell uci_restful -r /restful/lte/status_info GET
    ...                 connection=${session}
    ${attach_info}=      csn.read_output    connection=${session}
    ${tech}=    run keyword if  '5G_NSA' in """${attach_info}"""
    ...     set variable    5G
    ...     ELSE IF     'LTE' in """${attach_info}"""
    ...     set variable    LTE
    ...     ELSE IF     '5G_SA' in """${attach_info}"""
    ...     set variable    5G
    ...     ELSE    run keywords
    ...     Log To Console    \n--> INFO: UE ${UE_serial_number} not attached.  AND
    ...     fail
    [Return]    ${tech}

Perform attach with sherpa logs collection
    [Arguments]     ${destinationip}    ${mplaneIP}
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    Connect to appserver    ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    appserver
    ${UE_serial_numbers}=   Discover connected UEs and return serial numbers
    Check Iperf on UEs     ${UE_serial_numbers}    cpc
    Turn ONOFF Airplane Mode    ${UE_serial_numbers}
    Sleep   30s
    ${ue_ips}=    Return IPs    ${UE_serial_numbers}     cpc     False
    ${UL_ports}     ${DL_ports}=    Find free ports for uplink and downlink for multiple UEs    ${UE_serial_numbers}
    ${pids}=    Listen for UL throughput from multiple UEs on appserver     ${UE_serial_numbers}    ${UL_ports}
    Listen for DL throughput from appserver on multiple UEs     ${UE_serial_numbers}    ${DL_ports}
    Start Sherpa     ${mplaneIP}    ${destinationip}
    Start DL throughput on appserver to multiple UEs    ${UE_serial_numbers}    ${ue_ips}    ${DL_ports}    ${APPS_NETWORK_IF}    120M    #${time}
    Run Keyword And Continue On Failure    Stop Sherpa
    Kill iperf on all UEs   ${UE_serial_numbers}
    Kill multiple iperf processes on appserver     ${pids}
    Disconnect from UE PC
    Disconnect from appserver
    Convert pcap to sherpa csv
    ${l1l2sherpa}     ${sfn}=    Get Value For Parameter
    [Return]    ${l1l2sherpa}     ${sfn}
