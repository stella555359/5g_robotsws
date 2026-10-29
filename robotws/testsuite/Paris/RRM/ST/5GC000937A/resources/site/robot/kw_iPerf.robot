*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords generate trafic with iPerf in both way:
...             - Generating trafic in DL et monitoring behind UE
...             - Generating trafic in UL et monitoring behind Core Network
...         It is necessary to have 2 iPerf: One UE side and one Code network side.
...
...     AUTHOR (I&V-1):
...         Philippe Vignerte     philippe.vignerte@nokia.com
...         Merwane CHEMSSI        merwane.chemssi@nokia.com

*** Variables ***
# Connection to iPerf DL VM:
${iPerfDLvm_addr}                   ${custom['iPerf_VM_DL_ipaddress']}
${iPerfDLvm_login}                  ${custom['iPerf_VM_DL_login']}
${iPerfDLvm_passwd}                 ${custom['iPerf_VM_DL_passwd']}
${dl_alias}                         iPerfDLVM

# Connection to iPerf UL VM:
${iPerfULvm_addr}                   ${custom['iPerf_VM_UL_ipaddress']}
${iPerfULvm_login}                  ${custom['iPerf_VM_UL_login']}
${iPerfULvm_passwd}                 ${custom['iPerf_VM_UL_passwd']}
${ul_alias}                         iPerfULVM

${iperf_path}                       /usr/bin
${ul_throughput_log}                /home/ftp/ul_throughput_log
${dl_throughput_log}                /home/ftp/dl_throughput_log
${collected_ul_throughput_log}      ${custom['PATH_Storage']}/iPerf_logs/ul_throughput_log
${collected_dl_throughput_log}      ${custom['PATH_Storage']}/iPerf_logs/dl_throughput_log

*** Keywords ***

Connect to iPerf DL VM
    [Arguments]     ${iPerfDLvm_addr}=${custom['iPerf_VM_DL_ipaddress']}
    ...             ${iPerfDLvm_login}=${custom['iPerf_VM_DL_login']}
    ...             ${iPerfDLvm_passwd}=${custom['iPerf_VM_DL_passwd']}
    ...             ${dl_alias}=iPerfDLVM
    ssh.Connect to
    ...          ${iPerfDLvm_addr}        ${iPerfDLvm_login}      ${iPerfDLvm_passwd}     alias=${dl_alias}

Connect to iPerf UL VM
    [Arguments]     ${iPerfULvm_addr}=${custom['iPerf_VM_UL_ipaddress']}
    ...             ${iPerfULvm_login}=${custom['iPerf_VM_UL_login']}
    ...             ${iPerfULvm_passwd}=${custom['iPerf_VM_UL_passwd']}
    ...             ${ul_alias}=iPerfULVM

    ssh.Connect to      ${iPerfULvm_addr}           ${iPerfULvm_login}      ${iPerfULvm_passwd}     alias=${ul_alias}

Start UL traffic via iperf on iPerf UL VM
    [Arguments]         ${ul_server_addr}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}
    ssh.send_command
    ...     command=${iperf_path}/iperf -c ${ul_server_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length}
    ...     connection=${ul_alias}

Start monitor UL traffic on iPerf DL VM
    [Arguments]    ${ul_port}
    ssh.send command    command=${iperf_path}/iperf -s -u -i 1 -p ${ul_port} > ${ul_throughput_log}
    ...    connection=${dl_alias}

Start DL traffic via iperf on iPerf DL VM
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ssh.send command
    ...     command=${iperf_path}/iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length}
    ...     connection=${dl_alias}

Start monitor DL traffic on iPerf UL VM
    [Arguments]    ${dl_port}
    ssh.send command
    ...     command=${iperf_path}/iperf -s -u -i 1 -p ${dl_port} > ${dl_throughput_log}
    ...     connection=${ul_alias}

Close iperf process on iPerf DL VM
    ${output}=          ssh.execute         ps -ef |grep iperf                      connection=${dl_alias}
    ${len}=             Get length          ${output}
    ${iperf_pid}=       Run Keyword If      ${len}>0
    ...                 ssh.execute         ps -ef |grep iperf |awk '{print $2}'    connection=${dl_alias}
    @{iperf_pids}       split string        string=${iperf_pid}
    :FOR    ${pid}     IN      @{iperf_pids}
    #\       log to console       ${pid}
    \       ssh.send_command    command=kill -9 ${pid}    connection=${dl_alias}
    sleep               3s
    ssh.disconnect      connection=${dl_alias}

Close iperf process on iPerf UL VM
    ${output}=          ssh.execute         ps -ef |grep iperf                      connection=${ul_alias}
    ${len}=             Get length          ${output}
    ${iperf_pid}=       Run Keyword If      ${len}>0
    ...                 ssh.execute         ps -ef |grep iperf |awk '{print $2}'    connection=${ul_alias}
    @{iperf_pids}            split string      string=${iperf_pid}
    :FOR    ${pid}     IN      @{iperf_pids}
    #\       log to console       ${pid}
    \       ssh.send_command    command=kill -9 ${pid}    connection=${ul_alias}
    sleep               3s
    ssh.disconnect      connection=${ul_alias}

# [BC] - Adding KW for Multi-UE:  -  Copied from NPS_IV_iSpeed5G Branch
# [BC] - Above KW can't be used in a multi-UE test: need the -B option (Bind)
Start iPerf DL
    [Documentation]             Start traffic in DL with DL & UL traffic server both linux VM.
    ...                         Listen to the DL traffic on the UL traffic server,
    ...                         and redirect the result file to a received_tp directory
    ...                         UE_Address : address of the UE
    ...                         Throughput : throughput
    ...                         PortNb : port number
    ...                         UL_UE_Address : UE UL address (Ip passthrough)
    ...                         Modif 04 July,
    ...                 modify the duration of iperf in order to do traffic longer -t option 50000 is more than 12hours
    [Arguments]                 ${UE_Address}        ${Throughput}      ${PortNb}    ${UL_UE_Address}
    ssh.Send Command            command=iperf -s -f m -u -i 1 -p ${PortNb} -B ${UL_UE_Address} >
     ...    /home/${iPerfDLvm_login}/received_tp/UE${PortNb}.log&
    ...                         connection=${ul_alias}
    ssh.Send Command            command=iperf -c ${UE_Address} -u -b ${Throughput} -i 1 -l 1400 -t 50000 -p ${PortNb}&
    ...                         connection=${dl_alias}

Start iPerf UL
    [Documentation]             Start traffic in DL with DL & UL traffic server both linux VM.
    ...                         Listen to the DL traffic on the UL traffic server,
    ...                         and redirect the result file to a received_tp directory
    ...                         UE_Address : address of the UE
    ...                         Throughput : throughput
    ...                         PortNb : port number
    ...                         Modif 04 July,
    ...                 modify the duration of iperf in order to do traffic longer -t option 50000 is more than 12 hours
    [Arguments]                 ${UE_Address}        ${Throughput}    ${PortNb}
    ssh.Send Command            command=iperf -s -f m -u -i 1 -p ${PortNb} >
    ...  /home/${iPerfDLvm_login}/received_tp/UE${PortNb}.log&
    ...                         connection=${dl_alias}
    ssh.Send Command            command=iperf -c ${CoreIPTrafficServerDL} -u -b ${Throughput}
    ...  -i 1 -l 1400 -t 50000 -p ${PortNb} -B ${UE_Address}&
    ...                         connection=${ul_alias}