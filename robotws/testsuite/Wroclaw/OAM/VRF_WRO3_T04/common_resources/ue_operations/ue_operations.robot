*** Settings ***
Documentation
...     description:    Keywords related to ue operations.

Library           taf.ue               WITH NAME    ue
Library           taf.hw.pdu              WITH NAME    pdu
Library           taf.transport.ssh    WITH NAME    ssh

*** Variables ***
${APPSERV_IP}=          10.42.61.65
${APPSERV_USERNAME}=    5g
${APPSERV_PASSWORD}=    2019H@slo

*** Keywords ***
Attach UE Without Power Reset
    [Arguments]    ${ue_alias}    ${pdu_number}
    Log                              Attaching ${ue_alias}                   console=true
    ${attach_status}=                Run Keyword And Return Status           ue.attach_ue    ${ue_alias}
    Run Keyword If                   ${attach_status}
    ...                              Log    ${ue_alias} attached properly    console=true
    ...  ELSE  Run Keywords          Log    Attach problem, UE reset         console=true
    ...        AND                   Attach UE With Power Reset              ${ue_alias}     ${pdu_number}

Attach UE With Power Reset
    [Arguments]       ${ue_alias}    ${pdu_number}
    Power Reset UE    ${pdu_number}
    Sleep             2m    reason=Waiting for UE availability after power reset
    Log               Attaching UE after power reset    console=true
    ue.attach_ue      ${ue_alias}
    Log               UE attached after power reset     console=true

Send Packets From UE Shell
    [Arguments]    ${ue_pc_ip}    ${ue_pc_username}    ${ue_pc_password}    ${ue_serial}    ${port}    ${destination_ip}
    Log                                 Sending packets from ${ue_serial} UE shell
    SSHLibrary.Open Connection          host=${ue_pc_ip}
    SSHLibrary.Login                    username=${ue_pc_username}       password=${ue_pc_password}
    Sleep                               10s    reason=Timeout for login
    SSHLibrary.Write Bare               text=adb -s ${ue_serial} shell\n
    Sleep                               10s    reason=Time for UE shell connection
    SSHLibrary.Write Bare               text=iperf -c ${destination_ip} -u -i 1 -p ${port} -t 10 -b 300M -l 1400\n
    Sleep                               30s    reason=Time to complete sending packets

Detach UE Without Power Reset
    [Arguments]       ${ue_alias}
    Log               Detaching ${ue_alias}            console=true
    ${status}=        Run Keyword And Return Status    ue.detach_ue    ${ue_alias}
    Run Keyword If    ${status}    Log                 ${ue_alias} detached properly      console=true
    ...               ELSE         Log                 Problem with detach ${ue_alias}    console=true

Perform Data Transfer On UE
    [Arguments]  ${dt_name}=dt1      ${ue_alias}=UE_1    ${direction}=dl    ${throughput}=20Mbits/sec
    ...          ${duration}=180s    ${protocol}=udp     ${packet_size}=1390
    Log    Starting data transfer with: direction: ${direction}, throughput: ${throughput},    console=true
    Log    duration: ${duration}, protocol: ${protocol} and packet size: ${packet_size}        console=true
    ue.start_data_transfer    dt_name=${dt_name}
    ...                       ue_alias=${ue_alias}
    ...                       direction=${direction}
    ...                       duration=${duration}
    ...                       throughput=${throughput}
    ...                       protocol=${protocol}
    ...                       packet_size=${packet_size}
    Log    Data transfer on UE completed    console=true

Get UE IP Address
    [Arguments]               ${ue_alias}
    ${ue_ip_info_output}=     ue.get_ue_info           ${ue_alias}    ips
    ${ue_ip}=                 Get Dictionary Values    ${ue_ip_info_output}
    [Return]                  ${ue_ip[0][0]}

Prepare And Attach UE
    [Arguments]    ${pdu_number}    ${ue_alias}    ${capabilities}
    Power On UE                      ${pdu_number}
    Reserve UE                       ${ue_alias}      ${capabilities}
    Attach UE Without Power Reset    ${ue_alias}      ${pdu_number}

Release UE
    [Arguments]    ${ue_alias}    ${pdu_number}
    Detach UE Without Power Reset    ${ue_alias}
    Power Off UE                     ${pdu_number}

Perform UE Traffic By Appserv
    [Arguments]    ${pdu_number}    ${ue_alias}    ${capabilities}
    Prepare And Attach UE            ${pdu_number}    ${ue_alias}     ${capabilities}
    ${ue_ip_address}=                Ping UE From Appserv             ${ue_alias}
    [Return]      ${ue_ip_address}
    [Teardown]    Release UE    ${ue_alias}    ${pdu_number}

Ping UE From Appserv
    [Arguments]            ${ue_alias}
    Log                    Pinging UE           console=true
    ${ue_ip_address}=      Get UE IP Address    ${ue_alias}
    ${ssh_connection}=     ssh.connect_to       hostname=${APPSERV_IP}
    ...                                         username=${APPSERV_USERNAME}
    ...                                         password=${APPSERV_PASSWORD}
    ${ping_result}=        ssh.execute          command=ping ${ue_ip_address} -c 4
    ...                                         connection=${ssh_connection}
    Should Contain         ${ping_result}       64 bytes from ${ue_ip_address}
    Log                    Ping UE with success
    [Return]               ${ue_ip_address}
    [Teardown]             ssh.disconnect       ${ssh_connection}

Power On UE
    [Arguments]            ${pdu_number}
    Log                    Turning on UE    console=true
    pdu.setup_pdu          model=${tl.pdus[${pdu_number}]}
    ...                    host=${tl.pdus[${pdu_number}].addr}
    ...                    alias=UE_${pdu_number}_pdu
    ${pdu_port_number}=    Get Dictionary Keys    ${tl.pdus[${pdu_number}].pdu_ports}
    pdu.power_on           port=${pdu_port_number[0]}
    ...                    pdu_device=UE_${pdu_number}_pdu
    Sleep                  2m    reason=Waiting for complete of power on UE process
    Log                    UE turned on     console=true

Power Off UE
    [Arguments]            ${pdu_number}
    Log                    Turning off UE   console=true
    pdu.setup_pdu          model=${tl.pdus[${pdu_number}]}
    ...                    host=${tl.pdus[${pdu_number}].addr}
    ...                    alias=UE_${pdu_number}_pdu
    ${pdu_port_number}=    Get Dictionary Keys    ${tl.pdus[${pdu_number}].pdu_ports}
    pdu.power_off          port=${pdu_port_number[0]}
    ...                    pdu_device=UE_${pdu_number}_pdu
    Sleep                  30s    reason=Waiting for complete of power on UE process
    Log                    UE turned off    console=true

Power Reset UE
    [Arguments]            ${pdu_number}
    Log                    Performing power reset UE    console=true
    pdu.setup_pdu          model=${tl.pdus[${pdu_number}]}
    ...                    host=${tl.pdus[${pdu_number}].addr}
    ...                    alias=UE_${pdu_number}_pdu
    ${pdu_port_number}=    Get Dictionary Keys    ${tl.pdus[${pdu_number}].pdu_ports}
    pdu.power_off          port=${pdu_port_number[0]}             pdu_device=UE_${pdu_number}_pdu
    Sleep                  30s    reason=Waiting for complete power off UE procedure
    pdu.power_on           port=${pdu_port_number[0]}             pdu_device=UE_${pdu_number}_pdu
    Sleep                  2m     reason=Waiting for complete power on UE procedure
    Log                    Power reset UE completed    console=true

Reserve UE
    [Arguments]       ${ue_alias}    ${capabilities}
    Log               Reserving ${ue_alias} with capabilities: ${capabilities}            console=true
    ue.require_ue     ${ue_alias}    ${capabilities}
    Log               ${ue_alias} with capabilities: ${capabilities} reserved properly    console=true
