*** Settings ***
Documentation    Nokia Fastmile CPE L3 Call keywords
Library     BuiltIn
Library     OperatingSystem
Library     String
Library     taf.transport.ssh      WITH NAME    ssh


*** Variables ***
${CFGCLI}               InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular
${CFGCLI_WAN}           InternetGatewayDevice.WANDevice.2.WANConnectionDevice

*** Keywords ***
# ----------------------------------- ATTACH KEYWORDS ------------------------------------
fastmile Detach
    [Arguments]    ${capability}=_4G
    Clean_Lock_Band    ${capability}
    [Teardown]    ssh.disconnect    connection=Fastmile_cpe

fastmile Attach
    [Arguments]    ${capability}=_4G
    Log To Console      \n\t ================================================================
    Log To Console      \t * * * * * * * * * * * * * START ATTACH * * * * * * * * * * * * *
    Log To Console      \t ================================================================
    Log To Console      \n Start fastmile attach...
    # ${5G_deployment}         Get Variable Value    ${deployment}    NSA
    ${5G_deployment}=    Set Variable if    '${deployment}'=='SA'   SA    NSA
    Set test variable    ${5G_deployment}
    Connect to CPE
    Run Keyword If    '${tl.ues[${UE_index}].version}'=='3.2'    Run Keyword And Ignore Error
    ...                   Set capability    ${capability}
    ${Lock_Band_passed}=    Run Keyword and return status    Lock_Band    ${capability}
    Run Keyword If    '${Lock_Band_passed}'=='False'    Run Keywords
    ...                   Log    'Lock Band failed, will try to reboot fastmile for recovery'    WARN
    ...                   AND        Reboot Fastmile
    ...                   AND        Lock_Band    ${capability}
    ${attach_passed}=    Run Keyword and return status    Wait Until Keyword Succeeds    20s    5s    Attach_result    ${capability}
    Run Keyword If    '${attach_passed}'=='False'    Run Keywords
    ...                   Log    'Attach failed, please check attach info in robot log. Will try to reboot fastmile for recovery'    WARN
    ...                   AND        Reboot Fastmile
    ...                   AND        Fail

Set capability
    [Arguments]    ${capability}=_4G
    # ${Enable_5G}=    Set Variable if    '${capability}'=='_4G'    FALSE    TRUE
    ${Enable_SA}=    Set Variable if    '${capability}'=='_5G' and '${5G_deployment}'=='SA'   TRUE    FALSE
    ${Enable_NSA}=    Set Variable if    '${capability}'=='_5G' and '${5G_deployment}'=='NSA'   TRUE    FALSE
    Log to console    --> INFO: Start Set capability on 3.2 version CPE ...
    ${Set_SA}=    Fastmile_Command    "cfgcli -s ${CFGCLI}.Interface.1.X_ALU-COM_EnableSA ${Enable_SA}"
    Log    --> INFO: Set SA result: \n ${Set_SA}
    Should Contain    ${Set_SA}    success!
    ${Set_NSA}=    Fastmile_Command    "cfgcli -s ${CFGCLI}.Interface.1.X_ALU-COM_EnableNSA ${Enable_NSA}"
    Log    --> INFO: Set NSA result: \n ${Set_NSA}
    Should Contain    ${Set_NSA}    success!
    Log to console    --> INFO: Set capability on 3.2 version CPE finished ...


Lock_Band
    [Arguments]    ${capability}=_4G
    ${Band_cli}=    Set Variable if    '${capability}'=='_4G'    COM_Band    COM_5GBand
    Clean_Lock_Bands    ${capability}
    ${add_lock_band}=    Fastmile_Command    "cfgcli add ${CFGCLI}.X_ALU-${Band_cli}."
    ${band_number}=        Get Substring    ${add_lock_band}    -3    -1
    Set test variable    ${band_number}
    Log to console    --> INFO: Start lock band ...
    ${lock_band}=    Fastmile_Command    "cfgcli -s ${CFGCLI}.X_ALU-${Band_cli}.${band_number}Band ${tl.ues[${UE_index}].${capability}_band}"
    Log    --> INFO: Lock Band result: \n ${lock_band}
    Should Contain    ${lock_band}    success!
    ${locked_band_info}=    Fastmile_Command    "cfgcli -G ${CFGCLI}.X_ALU-${Band_cli}.${band_number}"
    Log    --> INFO: Locked band info: \n ${locked_band_info}
    Log to console    --> INFO: Lock band finished, wait until attached ...
    BuiltIn.Sleep      30s

Attach_result
    [Arguments]    ${capability}=_4G
     # query PCI
    ${cell_index}=    Set Variable if    '${capability}'=='_4G'    1    2
    # ${access_capability}=    Set Variable if    '${capability}'=='_4G'    LTE    NR5GNSA
    ${access_capability}=    Set Variable if    '${capability}'=='_4G'    LTE    NR5G${5G_deployment}
    Run Keyword If    'NR5GNSA' in '${access_capability}'    ENDC Addition 4G Attach Info
    ${attach_info}=    Fastmile_Command    "cfgcli -G ${CFGCLI}.Interface.1.X_ALU-COM_CellTower.${cell_index}."
    Detail Attach Info    ${attach_info}    ${capability}
    Should Contain    ${attach_info}    CurrentAccessTechnology = ${access_capability}
    Should Contain    ${attach_info}    PCI = ${tl.ues[${UE_index}].${capability}_pci}
    Log To Console      --> INFO: CPE ATTACHED SUCCESSFULLY
    # query IP
    ${UE_IP}=    Aquire IP
    Log To Console                  --> INFO: UE IP: ${UE_IP}

Clean_Lock_Band
    [Arguments]    ${capability}=_4G
    ${Band_cli}=    Set Variable if    '${capability}'=='_4G'    COM_Band    COM_5GBand
    ${clean_band}=    Fastmile_Command    "cfgcli del ${CFGCLI}.X_ALU-${Band_cli}.${band_number}"
    Should Contain    ${clean_band}    success!
    Log to console    --> INFO: ${capability} band unlocked
    BuiltIn.Sleep    20s

Clean_Lock_Bands
    [Arguments]    ${capability}=_4G
    ${Band_cli}=    Set Variable if    '${capability}'=='_4G'    COM_Band    COM_5GBand
    FOR   ${index}   IN RANGE   10
        ${clean_band}=    Fastmile_Command    "cfgcli del ${CFGCLI}.X_ALU-${Band_cli}.${index}."
        Log    ${clean_band}
        BuiltIn.Sleep    2s
    END
ENDC Addition 4G Attach Info
     ${attach_info_ENDC}=    Fastmile_Command    "cfgcli -G ${CFGCLI}.Interface.1.X_ALU-COM_CellTower.1."
     Detail Attach Info    ${attach_info_ENDC}    ENDC_4G
Detail Attach Info
    [Arguments]  ${attach_info}     ${capability}=_5G
    ${lines}=  Split String  ${attach_info}  \n
    Log To Console      \n\t ----------------------------------------------------------------
    Beautify Output     Attach info ${capability}
    Log To Console      \t ----------------------------------------------------------------
    FOR  ${line}  IN  @{lines}
        ${has_PCI}=    Run Keyword And Return Status    Should Contain    ${line}    PCI
        ${has_RSRP}=   Run Keyword And Return Status    Should Contain    ${line}    RSRP
        ${has_SNR}=    Run Keyword And Return Status    Should Contain    ${line}    SNR
        ${has_Band}=   Run Keyword And Return Status    Should Contain    ${line}    Band
        ${has_Bandwidth}=   Run Keyword And Return Status    Should Contain    ${line}    Bandwidth
        Run Keyword If    ${has_PCI} or ${has_RSRP} or ${has_SNR} or ${has_Band} or ${has_Bandwidth}   Beautify Output  ${line}
    END
    Log To Console      \t ----------------------------------------------------------------

Beautify Output
    [Arguments]  ${line}
    ${line}=  Strip String  ${line}
    ${line_length}=  Get Length  ${line}
    ${padding_left}=  Evaluate  " " * ((64 - ${line_length}) // 2)
    ${padding_right}=  Run Keyword If  ${line_length} % 2 == 0  Evaluate  " " * ((64 - ${line_length}) // 2 - 1)  ELSE  Set Variable  ${padding_left}
    Log To Console  \t |${padding_left}${line}${padding_right}|

# -------------------------------- END OF ATTACH KEYWORDS --------------------------------
# ----------------------------------------------------------------------------------------
# --------------------------------- THROUGHPUT KEYWORDS ----------------------------------
Fastmile Data Transfer
    [Arguments]    ${capability}=_4G
    ${CPE_IP}=    Aquire IP
    Should Contain X Times    '${CPE_IP}'    .   3
    Set Test Variable    ${CPE_IP}
    ${fastmile_timestamp}    Get timestamp
    Set Test Variable    ${fastmile_timestamp}
    ${data_transfer_protocol}    Get Variable Value    ${data_transfer_protocol}    UDP
    ${iperf_dl_send}    ${iperf_dl_receive}    ${iperf_ul_send}    ${iperf_ul_receive}    ${iperf_UL}    ${iperf_DL}    Set Fastmile Iperf Variables
    Log To Console    \n Start iperf throughput [${tl.target_traffic${capability}}[IPERF_DURATION] sec]...
    FASTMILE UL Throughput    ${data_transfer_protocol}    ${iperf_ul_send}    ${iperf_ul_receive}    ${capability}
    FASTMILE DL Throughput    ${data_transfer_protocol}    ${iperf_dl_send}    ${iperf_dl_receive}    ${capability}
    Get IPerf Results Fastmile    ${iperf_dl_receive}    ${iperf_ul_send}    ${iperf_UL}    ${iperf_DL}    ${capability}
    Set IPerf results    ${iperf_UL}    ${iperf_DL}
    Log To Console       \n RESULTS:
    Log To Console       \t\t\t Uplink:\t ${average_throughput_ul} Mbit/s
    Log To Console       \t\t\t Downlink:\t ${average_throughput_dl} Mbit/s
    ${UL_info}    Set Variable    UL tput is ${average_throughput_ul} UL target tput is ${tl.target_traffic${capability}}[MIN_UL]
    ${DL_info}    Set Variable    DL tput is ${average_throughput_dl} DL target tput is ${tl.target_traffic${capability}}[MIN_DL]
    Set Test Variable    ${message_${RF}}    ${UL_info} ${DL_info}
    ${UL_passed}=    Run Keyword And Return Status    Verify UL
    ${DL_passed}=    Run Keyword And Return Status    Verify DL
    Run Keyword If    '${UL_passed}'=='False' or '${DL_passed}'=='False'    Run Keywords
    ...                   Log    iperf UL/DL failed, will try to reboot fastmile for recovery    WARN
    ...                   AND        Reboot Fastmile
    ...                   AND        Fail

FASTMILE UL Throughput
    [Arguments]    ${data_transfer_protocol}    ${iperf_ul_send}    ${iperf_ul_receive}    ${capability}=_4G
    ${iperf_dest_ul}=       Set Variable    ${tl.ues[${UE_index}].ue_pc_address}
    ${iperf_ul_duration}=    Evaluate   ${tl.target_traffic${capability}}[IPERF_DURATION]+190
    IF    '${data_transfer_protocol}' == 'UDP'
        ${ul_client_iperf_cmd_ip_port}=    Set Variable
        ...    iperf -c ${iperf_dest_ul} -u -p ${tl.target_traffic${capability}}[UL_PORT]
        ${ul_client_iperf_cmd_duration}=    Set Variable
        ...    -t ${iperf_ul_duration} -i 1 -P 1 -f m
        ${ul_client_iperf_cmd_bandwith}=    Set Variable
        ...    -b ${tl.target_traffic${capability}}[MAX_UL]M -l 1024B -T 64
        ${ul_client_iperf_cmd}=    Set Variable
        ...    ${ul_client_iperf_cmd_ip_port} ${ul_client_iperf_cmd_duration} ${ul_client_iperf_cmd_bandwith}
        ${ul_server_iperf_cmd}=    Set Variable
        ...    iperf -s -u -i 1 -p ${tl.target_traffic${capability}}[UL_PORT] -P 1
    ELSE IF    '${data_transfer_protocol}' == 'TCP'
        ${ul_client_iperf_cmd_ip_port}=    Set Variable
        ...    iperf -c ${iperf_dest_ul} -p ${tl.target_traffic${capability}}[UL_PORT]
        ${ul_client_iperf_cmd_duration}=    Set Variable
        ...    -t ${iperf_ul_duration} -i 1 -P 1 -f m
        ${ul_client_iperf_cmd_bandwith}=    Set Variable
        ...    -M 1400
        ${ul_client_iperf_cmd}=    Set Variable
        ...    ${ul_client_iperf_cmd_ip_port} ${ul_client_iperf_cmd_duration} ${ul_client_iperf_cmd_bandwith}
        ${ul_server_iperf_cmd}=    Set Variable
        ...    iperf -s -i 1 -p ${tl.target_traffic${capability}}[UL_PORT] -P 1
    ELSE
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    Run    nohup ${ul_server_iperf_cmd} > ${iperf_ul_receive} 2>&1 &
    Fastmile_Command_without_res    "${ul_client_iperf_cmd} > ${iperf_ul_send}"

Set Fastmile Iperf Variables
    ${iperf_dl_send}=       Set Variable    ${ue_log_dir}/iperf${capability}_dl_send_${fastmile_timestamp}.txt
    ${iperf_dl_receive}=    Set Variable    /tmp/iperf${capability}_dl_receive_${fastmile_timestamp}.txt
    ${iperf_ul_send}=       Set Variable    /tmp/iperf${capability}_ul_send_${fastmile_timestamp}.txt
    ${iperf_ul_receive}=    Set Variable    ${ue_log_dir}/iperf${capability}_ul_receive_${fastmile_timestamp}.txt
    ${iperf_UL}=    Set Variable    ${ue_log_dir}/iperf${capability}_ul_receive_${fastmile_timestamp}_parsed.txt
    ${iperf_DL}=    Set Variable    ${ue_log_dir}/iperf${capability}_dl_receive_${fastmile_timestamp}_parsed.txt
    RETURN    ${iperf_dl_send}    ${iperf_dl_receive}    ${iperf_ul_send}    ${iperf_ul_receive}    ${iperf_UL}    ${iperf_DL}

FASTMILE DL Throughput
    [Arguments]    ${data_transfer_protocol}    ${iperf_dl_send}    ${iperf_dl_receive}    ${capability}=_4G
    IF    '${data_transfer_protocol}' == 'UDP'
        ${dl_client_iperf_cmd_ip_port}=    Set Variable
        ...    iperf -c ${CPE_IP} -u -p ${tl.target_traffic${capability}}[DL_PORT]
        ${dl_client_iperf_cmd_duration}=    Set Variable
        ...    -t ${tl.target_traffic${capability}}[IPERF_DURATION] -i 1 -P 1 -f m
        ${dl_client_iperf_cmd_bandwith}=    Set Variable
        ...    -b ${tl.target_traffic${capability}}[MAX_DL]M -l 1400B -T 64
        ${dl_client_iperf_cmd}=    Set Variable
        ...    ${dl_client_iperf_cmd_ip_port} ${dl_client_iperf_cmd_duration} ${dl_client_iperf_cmd_bandwith}
        ${dl_server_iperf_cmd}=    Set Variable
        ...    iperf -s -u -i 1 -p ${tl.target_traffic${capability}}[DL_PORT] -P 1
    ELSE IF    '${data_transfer_protocol}' == 'TCP'
        ${dl_client_iperf_cmd_ip_port}=    Set Variable
        ...    iperf -c ${CPE_IP} -p ${tl.target_traffic${capability}}[DL_PORT]
        ${dl_client_iperf_cmd_duration}=    Set Variable
        ...    -t ${tl.target_traffic${capability}}[IPERF_DURATION] -i 1 -P 1 -f m
        ${dl_client_iperf_cmd_bandwith}=    Set Variable
        ...    -M 1400
        ${dl_client_iperf_cmd}=    Set Variable
        ...    ${dl_client_iperf_cmd_ip_port} ${dl_client_iperf_cmd_duration} ${dl_client_iperf_cmd_bandwith}
        ${dl_server_iperf_cmd}=    Set Variable
        ...    iperf -s -i 1 -p ${tl.target_traffic${capability}}[DL_PORT] -P 1
    ELSE
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    Fastmile_Command_without_res    "iptables -F | ${dl_server_iperf_cmd} > ${iperf_dl_receive}"
    Run    nohup ${dl_client_iperf_cmd} > ${iperf_dl_send} 2>&1 &
    BuiltIn.Sleep    ${tl.target_traffic${capability}}[IPERF_DURATION]
    BuiltIn.Sleep    5s


Get IPerf Results Fastmile
    [Arguments]    ${iperf_dl_receive}    ${iperf_ul_send}    ${iperf_UL}    ${iperf_DL}    ${capability}=_4G
    ssh.Force Reconnect   connection=Fastmile_cpe
    Wait Until Keyword Succeeds    4x  10s        ssh.Download File    remote_path=${iperf_ul_send}
    ...                  local_path=${ue_log_dir}/iperf${capability}_ul_send_${fastmile_timestamp}.txt
    ...                  connection=Fastmile_cpe
    Wait Until Keyword Succeeds    4x  10s    ssh.Download File    remote_path=${iperf_dl_receive}
    ...                  local_path=${ue_log_dir}/iperf${capability}_dl_receive_${fastmile_timestamp}.txt
    ...                  connection=Fastmile_cpe
    Run    ${iperf_egrep} ${ue_log_dir}/iperf${capability}_dl_receive_${fastmile_timestamp}.txt | awk '{print $(1)}' > ${iperf_DL}
    Run    ${iperf_egrep} ${ue_log_dir}/iperf${capability}_ul_receive_${fastmile_timestamp}.txt | awk '{print $(1)}' > ${iperf_UL}
    Run Keyword          Kill Iperf Fastmile

Kill Iperf Fastmile
    Fastmile_Command_without_res    "rm -rf /tmp/iperf*"

# -------------------------------- END OF THROUGHPUT KEYWORDS --------------------------------
# ----------------------------------------------------------------------------------------
# --------------------------------- COMMON KEYWORDS ----------------------------------
Connect to CPE
    [Arguments]         ${alias}=Fastmile_cpe
    ${FASTMILE_SSH_USER}=    Set Variable if    '${tl.ues[${UE_index}].version}'=='3.1'    hguser    root
    ${Fastmile_ssh_password}=    Set Variable if    '${tl.ues[${UE_index}].version}'=='3.1'    bkIt0@Uq    ${tl.ues[${UE_index}].root_password}
    set test variable   ${Fastmile_ssh_password}
    FOR   ${index}   IN RANGE   3
        ${cpe_connection}   Run keyword and return status    Wait Until Keyword Succeeds    20s    10s    ssh.connect_to
        ...                 hostname=${tl.ues[${UE_index}].ue_manage_ip}    username=${FASTMILE_SSH_USER}
        ...                 password=${Fastmile_ssh_password}    alias=${alias}
        Exit For Loop If    '${cpe_connection}'=='${True}'
        BuiltIn.Sleep    5s
    END
    ${cpe_info}    Set Variable
    ...    ${tl.ues[${UE_index}].ue_manage_ip} -> ${FASTMILE_SSH_USER} / ${Fastmile_ssh_password} root: ${tl.ues[${UE_index}].root_password}
    Run Keyword If    ${cpe_connection}!=${True}
    # ...    Log    CPE connection failed: ${cpe_info}    WARN
    ...    Log    CPE connection failed: ${cpe_info}
    Should be true     ${cpe_connection}

Fastmile_Command
    [Arguments]    ${command}="cfgcli -G ${CFGCLI}.X_ALU-COM_Band.1."
    ssh.send_command    echo ${tl.ues[${UE_index}].root_password} |su -c ${command}    connection=Fastmile_cpe    timeout=10
    ${res}    ssh.read_output    connection=Fastmile_cpe
    Log    ${res}
    RETURN    ${res}

Fastmile_Command_without_res
    [Arguments]    ${command}="cfgcli -G ${CFGCLI}.X_ALU-COM_Band.1."
    ssh.send_command    echo ${tl.ues[${UE_index}].root_password} |su -c ${command}   connection=Fastmile_cpe    timeout=10


Aquire IP
    ${IP_info}=    Fastmile_Command    "cfgcli -g ${CFGCLI_WAN}.1.WANIPConnection.1.ExternalIPAddress"
    ${IP_info_tmp}=    Get Substring    ${IP_info}    0    -1
    ${IP_ADDR}=    Split String    ${IP_info_tmp}    =
    RETURN    ${IP_ADDR}[1]

Fastmile Uptime Query
    ssh.send_command    uptime    connection=Fastmile_cpe    timeout=10
    ${res}    ssh.read_output    connection=Fastmile_cpe
    Log To Console    --> INFO: CPE uptime: ${res}

Reboot Fastmile
    Run Keyword And Ignore Error    Fastmile Uptime Query
    Wait Until Keyword Succeeds    1min    10s    Fastmile_Command_without_res    "reboot"
    Log    Fastmile recovery by reboot had been peformed!!!    WARN
    BuiltIn.Sleep    3min
    Wait Until Keyword Succeeds    5min    30s    Connect to CPE
    BuiltIn.Sleep    1min
# --------------------------------- END OF COMMON KEYWORDS ----------------------------------
