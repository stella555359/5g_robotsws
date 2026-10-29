*** Settings ***
Documentation
...     Test Suite Purpose:
...         Generic purpose kws
...
...     AUTHOR (mmW&SC Pz NPS 4 SG):
...         I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com


*** Keywords ***
Close the iperf process on Core side
    [Documentation]     Stops all iperf process on traffic server core side
    wait until keyword succeeds    5 min    10 sec    Connect to Core iperf
    ssh.execute    ps -ef|grep iperf|grep -v grep| awk '{print $2}' |xargs kill -9    connection=Core_iperf
    ssh.disconnect  connection=Core_iperf

Close the iperf process on UE side
    [Documentation]     Stops all iperf process on traffic server UE side
    wait until keyword succeeds    5 min    10 sec    Connect to UE iperf
    ssh.execute    ps -ef|grep iperf|grep -v grep| awk '{print $2}' |xargs kill -9    connection=UE_iperf
    ssh.disconnect  connection=UE_iperf

Connect to Core iperf
    [Documentation]     Create ssh connection on iperf server core side
    [Arguments]    ${alias}=Core_iperf
    ssh.Connect to    hostname=${custom['iPerf_VM_DL_ipaddress']}
    ...    username=${custom['iPerf_VM_DL_login']}
    ...    password=${custom['iPerf_VM_DL_passwd']}    alias=${alias}

Connect to UE iperf
    [Documentation]     Create ssh connection on iperf server UE side
    [Arguments]    ${alias}=UE_iperf
    ssh.Connect to    hostname=${custom['iPerf_VM_UL_ipaddress']}
    ...    username=${custom['iPerf_VM_UL_login']}
    ...    password=${custom['iPerf_VM_UL_passwd']}    alias=${alias}

Start DL UL traffic
    [Documentation]     Stops all iperf process on both side and then start UL and DL traffic
    [Arguments]    ${throughput_DL}=100M        ${throughput_UL}=100M
    Close the iperf process on Core side
    Close the iperf process on UE side
    Start DL traffic via iperf on Core    ${custom['iPerf_VM_UL_Network_Interface_Address']}    ${dl_ul_time}    ${custom['iPerf_VM_DL_Port']}
    ...    ${throughput_DL}    ${buffer_length}
    Start UL traffic via iperf on UE to Core    ${custom['iPerf_VM_DL_Network_Interface_Address']}    ${dl_ul_time}
    ...    ${custom['iPerf_VM_UL_Port']}    ${throughput_UL}    ${buffer_length}
    sleep    5s

Start DL traffic
    [Documentation]     Stops all iperf process on both side and then start UL and DL traffic
    Close the iperf process on Core side
    Close the iperf process on UE side
    Start DL traffic via iperf on Core    ${custom['iPerf_VM_UL_Network_Interface_Address']}    ${dl_ul_time}    ${custom['iPerf_VM_DL_Port']}
    ...    ${throughput_DL}    ${buffer_length}
    sleep    5s

Start Prisma traffic On UE
    [Arguments]
    ...     ${ueid}=${1}       ${direction}=dl     ${throughput}=100M      ${duration}=60s
    ...     ${buffer_length}=1350        ${type}=nGBR
    ${ue_index}     Evaluate       ${ueid}-${1}
    ${dl_port}      Set Variable If     '${type}'=='nGBR'       ${custom['iPerf_VM_DL_Port'][${ue_index}]}       ${5005}
    ${ul_port}      Set Variable If     '${type}'=='nGBR'       ${tl.ues[0].iperf_details.port}       ${5005}
#    Close the iperf process on Core side
#    Close the iperf process on UE side

    Run Keyword if      '${direction}'=='dl'
    ...         Start DL traffic via iperf on Core    ${custom['iPerf_VM_UL_Network_Interface_Address'][${ue_index}]}
    ...     ${duration}    ${dl_port}
    ...    ${throughput}    ${buffer_length}

    Run Keyword if      '${direction}'=='ul'
    ...         Start UL traffic via iperf on UE to Core        ${custom['iPerf_VM_DL_Network_Interface_Address']}
    ...     ${duration}    ${ul_port}
    ...    ${throughput}    ${buffer_length}        ${ue_index}

Start UL traffic
    [Documentation]     Stops all iperf process on both side and then start UL and DL traffic
    Close the iperf process on Core side
    Close the iperf process on UE side
    Start UL traffic via iperf on UE to Core    ${custom['iPerf_VM_DL_Network_Interface_Address']}    ${dl_ul_time}
    ...    ${custom['iPerf_VM_UL_Port']}    ${throughput_UL}    ${buffer_length}
    sleep    5s

Stop DL UL traffic
    [Documentation]     Stops all iperf process on both side
    Close the iperf process on Core side
    Close the iperf process on UE side

Start DL traffic via iperf on Core
    [Documentation]     Start DL traffic by using argument value
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    log to console      \nKW:Start DL traffic via iperf on Core
    Connect to Core iperf          alias=Core_iperf

    ${cmd}    Catenate    iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -b ${dl_throughput} -l ${dl_length}
    ssh.send_command   command=${cmd}   connection=Core_iperf
    Log to console    ${cmd} command sent

Start UL traffic via iperf on UE to Core
    [Documentation]     Start UL traffic by using argument value
    [Arguments]     ${PGW_addr}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}     ${ue_id}=0
    @{list_from_ip}        Split string        ${tl.ues[0].iperf_details.network_interface_address}     .
    ${ip_from_ue}          Evaluate        @{list_from_ip}[-1]+${ue_id}
    Set List Value          ${list_from_ip}     -1      ${ip_from_ue}
    ${Interface_IP}     Catenate        SEPARATOR=.     @{list_from_ip}
    log to console      \nKW:Start UL traffic via iperf to Core
    Connect to UE iperf            alias=UE_iperf
    ${cmd}   Catenate   iperf -c ${PGW_Addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -B ${Interface_IP} -b ${ul_throughput} -l ${ul_length}
    ssh.send command    command=${cmd}   connection=UE_iperf
    Log to console    ${cmd} command sent
