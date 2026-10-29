*** Settings ***
Documentation
...     description:    Keywords related to IP traffic.

Library         taf.sbts.oam.coam.admin  WITH NAME    coam_admin
Library         taf.transport.ssh        WITH NAME    ssh
Resource        ../../common_resources/admin/admin.robot

*** Keywords ***
Start Tcpdump
    [Arguments]    ${measurement_point}=NE_Terminated
    ...            ${uplane_capturing}=${True}
    ...            ${password}=${EMPTY}
    ...            ${timeout}=120
    ...            ${bts_host}=${LMP_IP}

    Log    Starting tcpdump   console=True
    ${connection}=   Connect To Admin  ip_address=${bts_host}
    coam_admin.Start Ip Capture File
    ...    measurement_point=${measurement_point}  # Listen before IPSec encryption
    ...    uplane_capturing=${uplane_capturing}  # Capture U-plane traffic
    ...    password=${password}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Teardown]    Disconnect From Admin    ${connection}

TCPDump Teardown
    [Arguments]  ${bts_host}=${LMP_IP}
    ${connection}                     Connect to ADMIN  ip_address=${bts_host}
    Run Keyword And Ignore Error      coam_admin.stop_ip_capture_file
    ...                               connection=${connection}
    [Teardown]                        Disconnect from ADMIN  connection=${connection}

Start Tcpdump On FHNET via SSH
    [Arguments]    ${tcpdump_command}=tcpdump -i rlan0
    ...            ${pcap_file_name}=test.pcap
    ...            ${bts_host}=${LMP_IP}

    ssh.Connect to    hostname=${bts_host}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${output}=    ssh.Execute    command=lxc-ls --active    connection=bts_connection
    ${node}=      Get Regexp Matches    ${output}  0x[12]018
    ssh.Send Command  command=lxc-attach -n ${node[0]} -- ${tcpdump_command} -w ${pcap_file_name} &>/dev/null &
    ...               connection=bts_connection
    [Teardown]    ssh.Disconnect    connection=bts_connection

Start Tcpdump Via SSH
    [Arguments]    ${bts_host}=${LMP_IP}
    ...            ${username}=${ROOT_USERNAME}
    ...            ${password}=${ROOT_PASSWORD}
    ...            ${interface}=any
    ...            ${pcap_file_name}=test_smod.pcap

    ssh.Connect to    hostname=${bts_host}
    ...               username=${username}
    ...               password=${password}
    ...               alias=bts_connection
    ssh.Send Command  command=sudo tcpdump -i ${interface} -w ${pcap_file_name} &>/dev/null &
    ...               connection=bts_connection
    Log    Tcpdump started at ${interface} intreface    console=${TRUE}
    [Teardown]    ssh.Disconnect    connection=bts_connection

Start Tcpdump on SMOD via SSH
    [Arguments]    ${tcpdump_command}=tcpdump -i any
    ...            ${pcap_file_name}=test_smod.pcap
    ...            ${bts_host}=${LMP_IP}
    ...            ${proxy_connection}=None

    ssh.Connect to    hostname=${bts_host}
    ...               username=${ROOT_USERNAME}
    ...               password=${ROOT_PASSWORD}
    ...               proxy=${proxy_connection}
    ...               alias=bts_connection

    ssh.Send Command  command=${tcpdump_command} -w ${pcap_file_name} &>/dev/null &
    ...               connection=bts_connection
    [Teardown]    ssh.Disconnect    connection=bts_connection

Stop Tcpdump And Download Pcap Via SSH
    [Arguments]    ${source_tcpdump_filepath}
    ...            ${target_pcap_filename}=test_smod.pcap
    ...            ${bts_host}=${LMP_IP}
    ...            ${username}=${ROOT_USERNAME}
    ...            ${password}=${ROOT_PASSWORD}

    ssh.Connect To  hostname=${bts_host}
    ...             username=${username}
    ...             password=${password}
    ...             alias=bts_connection

    Log    Stop tcpdump    console=${FALSE}
    Log    Get tcpdump PID    console=${FALSE}
    ${filename}=    Evaluate      "${target_pcap_filename}".split(".")[0]
    ${output}=      ssh.Execute   command=ps -ef | grep "tcpdump.*${filename}" | grep -v grep| awk '{print $2}'
    ...                  connection=bts_connection
    ${pid}=         Get Regexp Matches    ${output}    (\\d+)(?!.*\\d)
    ssh.Execute     command=sudo kill -9 ${pid[0]}
    ...             connection=bts_connection
    Run  mkdir -p ${OUTPUT DIR}/${TEST NAME}    #Create dir for pcap file
    ssh.Download File    remote_path=${source_tcpdump_filepath}
    ...                  local_path=${OUTPUT DIR}/${TEST NAME}/${target_pcap_filename}
    ...                  connection=bts_connection
    Log    Tcpdump stopped and ${target_pcap_filename} file downloaded.    console=${TRUE}
    [Return]    ${OUTPUT DIR}/${TEST NAME}/${target_pcap_filename}
    [Teardown]    ssh.Disconnect    connection=bts_connection

Stop Tcpdump on SMOD And Download Pcap Via SSH
    [Arguments]    ${target_pcap_file_name}=test_smod.pcap
    ...            ${source_tcpdump_filename}=test_smod.pcap
    ...            ${bts_host}=${LMP_IP}
    ...            ${proxy_connection}=None

    ssh.Connect To  hostname=${bts_host}
    ...             username=${ROOT_USERNAME}
    ...             password=${ROOT_PASSWORD}
    ...             proxy=${proxy_connection}
    ...             alias=bts_connection

    Log    Stop tcpdump    console=false
    Log    Get tcpdump PID    console=false
    ${output}=      ssh.Execute   command=ps -ef | grep "tcpdump.*test"|grep -v grep| awk '{print $2}'
    ...                  connection=bts_connection
    ${pid}=         Get Regexp Matches    ${output}    (\\d+)(?!.*\\d)
    ssh.Execute     command=kill -9 ${pid[0]}
    ...             connection=bts_connection
    Run  mkdir -p ${OUTPUT DIR}/${TEST NAME}    #Create dir for pcap file
    ssh.Download File    remote_path=/ffs/run/config/toor4nsn/${source_tcpdump_filename}
    ...                  local_path=${OUTPUT DIR}/${TEST NAME}/${target_pcap_file_name}
    ...                  connection=bts_connection
    Log    Tcpdump stopped and ${target_pcap_file_name} file downloaded.    console=True
    [Return]    ${OUTPUT DIR}/${TEST NAME}/${target_pcap_file_name}
    [Teardown]    ssh.Disconnect    connection=bts_connection

Stop Tcpdump And Download Pcap
    [Arguments]    ${tcpdump_filename}=test.pcap
    ...            ${bts_host}=${LMP_IP}

    ${conn}=    Connect To Admin  ip_address=${bts_host}
    Wait Until Keyword Succeeds  5m  30s      coam_admin.Stop Ip Capture File        connection=${conn}
    coam_admin.Generate Ip Capture File    connection=${conn}
    coam_admin.Download Ip Capture File    target_file_name=${OUTPUT DIR}/${TEST NAME}/${tcpdump_filename}
    ...    timeout=300                      connection=${conn}
    Log    Tcpdump stopped and ${tcpdump_filename} file downloaded.    console=True
    [Teardown]    Disconnect From Admin    ${conn}
    [Return]    ${OUTPUT DIR}/${TEST NAME}/${tcpdump_filename}

Stop Tcpdump on FHNET And Download Pcap Via SSH
    [Arguments]    ${source_tcpdump_filename}=test.pcap
    ...            ${target_pcap_file_name}=test.pcap
    ...            ${bts_host}=${SSH_IP}

    ssh.Connect To  hostname=${bts_host}
    ...             username=${SSH_USERNAME}
    ...             password=${SSH_PASSWORD}
    ...             alias=bts_connection
    Log    Get Airscale FHNET node    console=false
    ${output}=      ssh.Execute    command=lxc-ls --active    connection=bts_connection
    ${node}=        Get Regexp Matches    ${output}  0x[12]018
    Log    Get tcpdump PID    console=false
    ${output}=      ssh.Execute   command=lxc-attach -n ${node[0]} -- ps -ef|grep tcpdump -i |grep -v grep| awk '{print $2}'
    ...             connection=bts_connection
    ${pid}=         Get Regexp Matches    ${output}    (\\d+)(?!.*\\d)
    Log    Stop tcpdump    console=false
    ssh.Execute     command=lxc-attach -n ${node[0]} -- kill -9 ${pid[-1]}
    ...             connection=bts_connection
    Run  mkdir -p ${OUTPUT DIR}/${TEST NAME}    #Create dir for pcap file
    ssh.Download File    remote_path=/ffs/run/config/toor4nsn/${source_tcpdump_filename}
    ...                  local_path=${OUTPUT DIR}/${TEST NAME}/${target_pcap_file_name}
    ...                  connection=bts_connection
    Log    Tcpdump stopped and ${target_pcap_file_name} file downloaded.    console=True
    [Return]    ${OUTPUT DIR}/${TEST NAME}/${target_pcap_file_name}
    [Teardown]    ssh.Disconnect    connection=bts_connection
