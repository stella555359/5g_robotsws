*** Settings ***
Documentation    huawei router and cus related testing keywords
Library    BuiltIn
Library    OperatingSystem
Library    robot.libraries.Process
Library    taf.sw.wtssim
Library    taf.trafficgenerator.iperf       WITH NAME    iperf
Library    taf.analyzer.iperf_throughput    WITH NAME    tput
Resource    ${CURDIR}/wtssim.robot
Resource    ${CURDIR}/egate.robot
Resource    ${CURDIR}/tshark.robot

*** Variables ***
${ue_service_script}           ${CURDIR}/../python/no_service.py
${ue_service_script_remote}    /home/ute/QT_unification/no_service.py
${iperf_service_1_ul}    iperf_service_1_ul
${iperf_ue_1_ul}         iperf_ue_1_ul
${iperf_service_1_dl}    iperf_service_1_dl
${iperf_ue_1_dl}         iperf_ue_1_dl


*** Keywords ***
Attach Huawei Router
    ${pdu_version}    Get Variable Value    ${tl.ues[0].pdu_port.pdu.version}   ${None}
    Reset port on PDU
    ...    PDU_IP=${tl.ues[0].pdu_port.pdu.addr}
    ...    PDU_PORT=${tl.ues[0].pdu_port.port_no}
    ...    alias=ue
    ...    model=${tl.ues[0].pdu_port.pdu.model}
    ...    version=${pdu_version}
    Check If UE Is Attached
    Wait Until Keyword Succeeds    120    10    Check If Remote Router Is Pingable

Perform And Check Huawei Router Data Transfer
    Log To Console    Perform Traffic Real_UE
    ${data_transfer_protocol}    Get Variable Value    ${data_transfer_protocol}    UDP
    Perform Iperf Traffic    ${data_transfer_protocol}
    Verify Iperf Traffic    ${data_transfer_protocol}

Perform Iperf Traffic
    [Arguments]    ${data_transfer_protocol}
    ${iperf_service_host_configuration}              ${iperf_ue_host_configuration}    Create Host Configuration
    ${iperf_service_cmd_options_configuration_ul}    Create Iperf Cmd Options
    ...                                              ${data_transfer_protocol}    parameter=bind    value=${tl.UE['core_network']}    throughput=ul
    ${iperf_ue_cmd_options_configuration_ul}         Create Iperf Cmd Options
    ...                                              ${data_transfer_protocol}    parameter=client    value=${tl.UE['core_network']}    throughput=ul
    ${iperf_service_cmd_options_configuration_dl}    Create Iperf Cmd Options
    ...                                              ${data_transfer_protocol}    parameter=client    value=${tl.UE['UE_ip']}    throughput=dl
    ${iperf_ue_cmd_options_configuration_dl}         Create Iperf Cmd Options
    ...                                              ${data_transfer_protocol}    parameter=bind    value=${tl.UE['master_eth']}    throughput=dl
    Create Iperf Server
    ...  cmd_options=${iperf_service_cmd_options_configuration_ul}
    ...  host_configuration=${iperf_service_host_configuration}
    ...  log_path=${ue_log_dir}/service_iperf2_log_ul.txt
    ...  iperf_alias=${iperf_service_1_ul}
    Create Iperf Client
    ...  cmd_options=${iperf_ue_cmd_options_configuration_ul}
    ...  host_configuration=${iperf_ue_host_configuration}
    ...  log_path=${ue_log_dir}/ue_iperf2_log_ul.txt
    ...  iperf_alias=${iperf_ue_1_ul}
    Create Iperf Client
    ...  cmd_options=${iperf_service_cmd_options_configuration_dl}
    ...  host_configuration=${iperf_service_host_configuration}
    ...  log_path=${ue_log_dir}/service_iperf2_log_dl.txt
    ...  iperf_alias=${iperf_service_1_dl}
    Create Iperf Server
    ...  cmd_options=${iperf_ue_cmd_options_configuration_dl}
    ...  host_configuration=${iperf_ue_host_configuration}
    ...  log_path=${ue_log_dir}/ue_iperf2_log_dl.txt
    ...  iperf_alias=${iperf_ue_1_dl}
    ${iperf_list}=  Create List     ${iperf_ue_1_dl}    ${iperf_service_1_dl}
    ...                             ${iperf_service_1_ul}    ${iperf_ue_1_ul}
    iperf.Setup    iperfs=${iperf_list}
    BuiltIn.Sleep    3
    iperf.Start    iperfs=${iperf_list}
    BuiltIn.Sleep    121
    iperf.Stop     iperfs=${iperf_list}
    BuiltIn.Sleep    3
    iperf.Teardown

Create Host Configuration
    ${iperf_service_host_configuration}    Create Dictionary
    ...    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}
    ${iperf_ue_host_configuration}    Create Dictionary
    ...    host=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}
    RETURN    ${iperf_service_host_configuration}    ${iperf_ue_host_configuration}

Create Iperf Cmd Options
    [Arguments]    ${data_transfer_protocol}    ${parameter}    ${value}    ${throughput}
    IF    '${data_transfer_protocol}' == 'UDP'
        ${iperf_cmd_options_configuration}    Create Dictionary
        ...    ${parameter}=${value}
        ...    udp=True
        ...    interval=${tl.target_traffic_4G['interval']}
        ...    port=${tl.target_traffic_4G['port_${throughput}']}
        ...    bandwidth=${tl.target_traffic_4G['tput_${throughput}']}
        ...    time=${tl.target_traffic_4G['tput_time']}
        ...    len=${tl.target_traffic_4G['len_${throughput}']}
    ELSE IF    '${data_transfer_protocol}' == 'TCP'
        ${iperf_cmd_options_configuration}    Create Dictionary
        ...    ${parameter}=${value}
        ...    interval=${tl.target_traffic_4G['interval']}
        ...    port=${tl.target_traffic_4G['port_${throughput}']}
        ...    time=${tl.target_traffic_4G['tput_time']}
        ...    mss=1400
    ELSE
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    RETURN    ${iperf_cmd_options_configuration}

Verify Iperf Traffic
    [Arguments]    ${data_transfer_protocol}
    IF    '${data_transfer_protocol}' == 'UDP'
        Create Iperf Server UDP Throughput    log=${ue_log_dir}/service_iperf2_log_ul.txt    alias=${iperf_service_1_ul}
        Create Iperf Server UDP Throughput    log=${ue_log_dir}/ue_iperf2_log_dl.txt         alias=${iperf_ue_1_dl}
    ELSE IF    '${data_transfer_protocol}' == 'TCP'
        Create Iperf Server TCP Throughput    log=${ue_log_dir}/service_iperf2_log_ul.txt    alias=${iperf_service_1_ul}
        Create Iperf Server TCP Throughput    log=${ue_log_dir}/ue_iperf2_log_dl.txt         alias=${iperf_ue_1_dl}
    ELSE
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    ${list_of_throughputs}    Create list    ${iperf_service_1_ul}    ${iperf_ue_1_dl}
    Analyze         throughputs=${list_of_throughputs}
    Verify Iperf    min_throughput=${tl.target_traffic_4G['tput_ul_min']}    throughput=${iperf_service_1_ul}    ul_dl=UL
    Verify Iperf    min_throughput=${tl.target_traffic_4G['tput_dl_min']}    throughput=${iperf_ue_1_dl}         ul_dl=DL

Verify Iperf
    [Arguments]        ${min_throughput}    ${throughput}    ${ul_dl}
    ${service_output}    Get Throughput    throughput=${throughput}
    Log    ${service_output}
    Log To Console    \n\n Average ${ul_dl} throughput: ${service_output[0]['average']['value']} Mbits/sec
    Log To Console    Minimum ${ul_dl} throughput: ${service_output[0]['minimum']['value']} Mbits/sec
    Should Be True    ${service_output[0]['average']['value']} > ${min_throughput}

UE Detach Huawei Router
    ${pdu_version}    Get Variable Value    ${tl.ues[0].pdu_port.pdu.version}   ${None}
    Power Off PDU Port    PDU_IP=${tl.ues[0].pdu_port.pdu.addr}
    ...                   PDU_PORT=${tl.ues[0].pdu_port.port_no}
    ...                   model=${tl.ues[0].pdu_port.pdu.model}
    ...                   alias=ue
    ...                   version=${pdu_version}

Restart Router
    ${UE_mode}=  Get Variable Value  ${tl.UE['UE_mode']}
    Run Keyword If  '${UE_mode}'=='remote_master'  Restart Router 3G to 4G Remotely
    ...  ELSE  Restart Router 3G to 4G Locally

Restart Router 3G To 4G Remotely
    [Documentation]  Router must be ON.
    Check If Remote Router Is Pingable
    ${script_exists}=  ssh.file_exists  remote_path=/home/ute/QT_unification/  connection=remote_router
    Run Keyword If  '${script_exists}' =='False'  ssh.execute  command=mkdir -p /home/ute/QT_unification/
    ...    connection=remote_router    timeout=30s
    ssh.upload_file    local_path=${ue_service_script}    remote_path=${ue_service_script_remote}    connection=remote_router
    ${command}    Catenate    python3 ${ue_service_script_remote} --router_ip ${tl.UE['router_ip']}
    ...           --username ${tl.UE['router_user']} --password ${tl.UE['router_password']} --lte_band ${tl.UE['lte_band']}
    ssh.execute        command=${command}    connection=remote_router    timeout=90s
    [Teardown]  ssh.Disconnect    connection=remote_router

Restart Router 3G To 4G Locally
    Run  python3 ${ue_service_script}

Check If Remote Router Is Pingable
    ssh.connect_to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...               username=${tl.ues[0].ssh_connection_details.username}
    ...               password=${tl.ues[0].ssh_connection_details.password}
    ...               alias=remote_router
    ${result}         ssh.execute    command=ping ${tl.UE['router_ip']} -c 4     connection=remote_router   timeout=20s
    Should Contain  ${result}  64 bytes from ${tl.UE['router_ip']}

Reach OnAir With WTS
    Log To Console    \n Check If WTS Is Active
    ${is_wts_active}  ${value}  Run Keyword And Ignore Error  Check If WTS Is Active
    ${status}    Run Keyword And Return Status    Variable Should Not Exist    ${ue_type}
    ${ue_type}=    Run Keyword If    ${status}   Get Variable Value    ${tl.ues[0].ue_type}    None
           ...    ELSE    Set Variable    ${ue_type}
    Run Keyword If  '${is_wts_active}'=='FAIL' and '${ue_type}' == 'cus'   Trigger Simulator Start With Config   configuration=${EGATE_CUS_PATH}

Check IPHY Data Transfer
    Log To Console    Perform Traffic IPHY
    Perform Traffic IPHY  time=${tl.target_traffic_4G}[IPERF_DURATION]
    Verify Traffic IPHY
    Stop Traffic IPHY

Check CUS Data Transfer
    ${data_transfer_protocol}    Get Variable Value    ${data_transfer_protocol}    UDP
    Log To Console    Perform Traffic CUS
    Perform Traffic CUS    ${data_transfer_protocol}    time=${tl.target_traffic_4G}[IPERF_DURATION]
    Stop Traffic CUS
    Verify Traffic CUS    ${data_transfer_protocol}

Restart ePC SIM
    Log to Console    Restarting ePC SIM core simulator
    ${time_stamp}    Get timestamp
    ${epc_sim_scripts}    Set Variable    /home/ute/robotws/testsuite/QT/SRAN/resources/scripts/epc_sim_scripts
    ${epc_sim_state_file}    Set Variable    /tmp/ePC_SIM_state_${time_stamp}.txt
    Run    bash ${epc_sim_scripts}/epc_stop.sh
    Run    bash ${epc_sim_scripts}/epc_start_robotws.sh
    BuiltIn.Sleep    5
    Run    bash ${epc_sim_scripts}/epc_execute_command.sh -c state -w ${epc_sim_state_file}
    ${state}    Run    grep -a "The state is" ${epc_sim_state_file} | awk '{print $NF}' | tr -d '\r'
    IF    '${state}' != 'ACTIVE'
        Log    ePC SIM state is ${state} (but not ACTIVE)!\n    WARN
        Run    cat ${epc_sim_state_file}
        ${result}    Set Variable    ${False}
    ELSE
        Log to Console    ePC SIM state: ${state}
        ${result}    Set Variable    ${True}
    END
    Run    rm ${epc_sim_state_file}
    RETURN    ${result}