*** Settings ***
Documentation    author: Hongyan Yuan
...              Group: HGZ_SG1
...              contact: hongyan.1.yuan@nokia-sbell.com
...              Provide common kws for L3 call on Classical gNB NSA and SA with tm500

Library  Collections
Library  taf.ue.tm500.rci       WITH NAME    tm500_remote
Library  taf.transport.ssh      WITH NAME    csn
Resource  taf/rfrl/common_resources/robot/connections.robot

*** Variables ***
${LOCAL_SWCONFIG_PATH}   ${CURDIR}/../bb2_files/swconfig.txt
${TM500_IP}          ${tl.ues[0].tma_host.addr}
${TM500_PORT}        ${tl.ues[0].tma_command_port}
${TM500_USER}        ${tl.ues[0].tma_host.username}
${TM500_PW}          ${tl.ues[0].tma_host.password}


*** Keywords ***
TM500 Custom Attach
    [Documentation]  Allows to provide custom scripts for:
    ...  hardware connection, cell search, attach, and detach.
    ...  User is responsible for setting proper variables in scripts
    [Arguments]  ${tm500_alias}  ${hw_connect_script_path}
    ...  ${cell_search_script_path}  ${attach_script_path}
    log    Sending hw_connect_script from ${hw_connect_script_path}
    send script  ${hw_connect_script_path}  alias=${tm500_alias}  timeout=5 minutes

    log    Sending cell_search_script from ${cell_search_script_path}
    send script  ${cell_search_script_path}  alias=${tm500_alias}  timeout=5 minutes

    log    Sending attach_script from ${attach_script_path}
    ${response}=  send script  ${attach_script_path}  alias=${tm500_alias}  timeout=5 minutes
    [Return]    ${response}

TM500 Attach
    [Documentation]  This keyword generate scripts based on provided variables.
    ...  For more details about variables see [2].
    ...  Arguments:
    ...    tm500_alias - aliast to tm500 connection created by taf.ue.tm500.rci
    ...    rfrx_gain - Expected received singal power for antenna 1 and 2 in dBm
    ...    mcc_mnc - Mobile Country Code followed by Mobile Network Code. 5-6 decimal digits.
    ...    physical_cell_id - physical cell id
    ...    middle_cell_freq - Downlink carrier frequency
    ...    imsi - either value set in epcsim or see confluence page [1] for real core
    ...    mnc_length - Length of mnc in digits
    ...    authentication_key - either value set in epcsim or see confluence page [1] for real core (field KI)
    ...    milenage_op_key - either value set in epcsim or see confluence page [1] for real core (field OPC)
    ...    [1]  https://confluence.int.net.nokia.com/pages/viewpage.action?pageId=514160999
    ...    [2]  https://confluence.int.net.nokia.com/display/CV/Automation+CWR?preview=/489894279/489894264/TM500LTE_CommandReference.pdf
    [Arguments]  ${tm500_alias}  ${rfrx_gain}  ${mcc_mnc}  ${physical_cell_id}
    ...  ${middle_cell_freq}  ${imsi}  ${mnc_length}
    ...  ${authentication_key}  ${milenage_op_key}
    ${template_dir}=  set variable  ${CURDIR}/../tm500_scripts_templates
    Render template to file  ${template_dir}/Cell_Search_MIB_decoding_3rdGen_rc.txt.j2  ${LOG_PATH}/Cell_Search_MIB_decoding_3rdGen_rc.txt
    ...  rfrx_gain=${rfrx_gain}  mcc_mnc=${mcc_mnc}  physical_cell_id=${physical_cell_id}  middle_cell_freq=${middle_cell_freq}
    Render template to file  ${template_dir}/UE_Attach_3rdGen_rc.txt.j2  ${LOG_PATH}/UE_Attach_3rdGen_rc.txt
    ...  imsi=${imsi}  mnc_length=${mnc_length}  authentication_key=${authentication_key}  milenage_op_key=${milenage_op_key}
    ...  middle_cell_freq=${middle_cell_freq}  physical_cell_id=${physical_cell_id}  mcc_mnc=${mcc_mnc}
    ${response}=    TM500 Custom Attach  ${tm500_alias}
    ...  ${template_dir}/NAS_mode_config.txt
    ...  ${LOG_PATH}/Cell_Search_MIB_decoding_3rdGen_rc.txt
    ...  ${LOG_PATH}/UE_Attach_3rdGen_rc.txt
    [Return]    ${response}

TM500 Detach
    [Documentation]  Detach TM500. Allows to provide custom scripts for detach
    ...  and it this case user is responsible for setting proper variables
    ...  in script. If detach_script_path was not provided default value is used.
    [Arguments]  ${tm500_alias}
    ...  ${detach_script_path}=${CURDIR}/../tm500_scripts_templates/detach.txt
    tm500_remote.send script  ${detach_script_path}  alias=${tm500_alias}  timeout=5 minutes
    Log to console    \nINFO:TM500 detach successfully

Do pre-attach configuration
     Configure ASIA
     Configure Radio Attenuation
     Set BB2 Flags

Configure ASIA
    ${asia 10mhz synchro command}=   Set Variable    ddal -s ddal_clk_io_set_single_ended_clk_out1_to 1 DDAL_OUTPUT_CLK_SRC_10M_INT
    ${asia check synchro command}=   Set Variable    cat /sys/class/clk/picasso/regs/clk_single_out1_select_rw
    csn.Connect To     hostname=${OAM_IP}    username=${VM_LOGIN}    password=${VM_PASSWORD}    alias=OAM
    csn.Connect To     hostname=${BB1_IP}   username=${GNB_AIRSCALE_USERNAME}   password=${GNB_AIRSCALE_PASSWORD}   proxy=OAM   alias=ASIA
    csn.Send Command   ${asia 10mhz synchro command}        connection=ASIA
    csn.Read Output                                         connection=ASIA
    Log    The output of this should be 0x2 (sync signal is on)
    csn.Send Command   ${asia check synchro command}        connection=ASIA
    csn.Read Output                                         connection=ASIA

Configure Radio Attenuation
    csn.Connect To     hostname=${BB1_IP}       username=${GNB_AIRSCALE_USERNAME}           password=${GNB_AIRSCALE_PASSWORD}
    ...       proxy=OAM        alias=ASIA
    csn.Connect To     hostname=${RADIO_N0_IP}   username=${RADIO_USERNAME}       password=${RADIO_PASSWORD}
    ...       proxy=ASIA       alias=RADIO_N0
    csn.Connect To     hostname=${RADIO_N2_IP}   username=${RADIO_USERNAME}       password=${RADIO_PASSWORD}
    ...       proxy=RADIO_N0   alias=RADIO_N2
    Set attenuation    RADIO_N0
    Set attenuation    RADIO_N2

Set attenuation     [Arguments]    ${connection}
    ${set attenuation command}=   Set Variable       /sbin/devmem 0xa000b088 32 0x00000020; /sbin/devmem 0xa000b08c 32 0x00000020
    ${get attenuation command}=   Set Variable       /sbin/devmem 0xa000b088 32; /sbin/devmem 0xa000b08c 32
    csn.Send Command   ${set attenuation command}       connection=${connection}
    csn.Send Command   ${get attenuation command}       connection=${connection}
    csn.Read Output                                     connection=${connection}

Set BB2 Flags
    csn.Connect To     hostname=${BB2_IP}    username=${BB2_LOGIN}    password=${BB2_PASSWORD}    proxy=OAM   alias=BB2
    csn.Upload File    local_path=${LOCAL_SWCONFIG_PATH}    remote_path=${BB2_SWCONFIG_PATH}    connection=BB2

Perform TM500 Attach
    # WARN  deprecated
    tm500_remote.Connect to  ip=${TM500_IP}  command_port=${TM500_PORT}  alias=tm500
    Do pre-attach configuration
    ${response}=    TM500 Attach  tm500_alias=tm500
    ...  rfrx_gain=-10
    ...  mcc_mnc=310489
    ...  physical_cell_id=307
    ...  middle_cell_freq=34633
    ...  imsi=310489000000788
    ...  mnc_length=3
    ...  authentication_key=01020304050607080910101010101001
    ...  milenage_op_key=63BFA50EE6523365FF14C1F45F88737D
    [Teardown]  Run Keywords
    ...  TM500 Detach  tm500_alias=tm500   AND
    ...  tm500_remote.disconnect  alias=tm500
    Evaluate attach response    ${response}

Evaluate attach response
    [Arguments]  ${response}
    ${Random Access Completed}=      Evaluate    "Random Access Complete" in """${response}"""
    ${EPS only mode}=                Evaluate    "Attach Result: EPS Only" in """${response}"""
    Should be true    ${Random access completed}
    Should be true    ${EPS only mode}

TM500 Data Transfer
    [Documentation]  Performs data transfer test. Assumes iperf is installed and
    ...  networks are configured.
    ...  Arguments:
    ...  iperf_downlink - ssh connection to iperf responsible for downlink (AppServer)
    ...  iperf_uplink - ssh connection to iperf responsible for uplink (COBHAM VM)
    [Arguments]  ${iperf_downlink}  ${iperf_uplink}
    Run iperf Client  server_ip=${DATA_TRANSFER_DOWNLINK_DOWNLINK_SERVER_IP}
    ...  bind_interface=${DATA_TRANSFER_DOWNLINK_BIND_INTERFACE}  udp=True  bitrate=${DATA_TRANSFER_DOWNLINK_BITRATE}M
    ...  transmission_time=${DATA_TRANSFER_TRANSMISSION_TIME}  interval=1  connection=${iperf_downlink}
    Run iperf Client  server_ip=${DATA_TRANSFER_UPLINK_SERVER_IP}  udp=True  port=${DATA_TRANSFER_UPLINK_PORT}
    ...  bitrate=${DATA_TRANSFER_UPLINK_BITRATE}M  transmission_time=${DATA_TRANSFER_TRANSMISSION_TIME}  interval=1
    ...  buf_length=${DATA_TRANSFER_UPLINK_BUF_LENGTH}  connection=${iperf_uplink}
    Evaluate throughput  expected_uplink=${DATA_TRANSFER_UPLINK_BITRATE}  expected_downlink=${DATA_TRANSFER_DOWNLINK_BITRATE}

Run iperf Client
    [Documentation]  Runs Iperf Client.
    ...  Arguments:
    ...    server_ip - iperf server ip
    ...    bitrate - target bitrate in format n[KM] where n is number
    ...    transmission_time - time in second to transmit for
    ...    interval - Specify pause between periodic throughput reports. 0 - disables. Default 1.
    ...    bind_interface - interface to bind. (optional)
    ...    udp - set true to use udp. Default false.
    ...    port - iperf port. (optional)
    ...    buf_length - length of read/write buffer (optional)
    ...    connection - ssh connection to iperf host
    [Arguments]  ${server_ip}  ${bitrate}  ${transmission_time}  ${interval}=${1}  ${bind_interface}=${None}
    ...  ${udp}=${False}  ${port}=${None}  ${buf_length}=${None}  ${connection}=${None}
    ${cmd}=  set variable  iperf -c ${server_ip} -t ${transmission_time} -b ${bitrate} -i ${interval}
    ${cmd}=  set variable if  '${bind_interface}' != '${None}'  ${cmd} -B ${bind_interface}  ${cmd}
    ${cmd}=  set variable if  '${port}' != '${None}'  ${cmd} -p ${port}  ${cmd}
    ${cmd}=  set variable if  '${buf_length}' != '${None}'  ${cmd} -l ${buf_length}  ${cmd}
    ${cmd}=  set variable if  '${udp}' != '${None}'  ${cmd} -u  ${cmd}
    ${cmd}=  set variable  ${cmd} 1>/dev/null 2>/dev/null &
    csn.Send Command  ${cmd}  connection=${connection}

Evaluate throughput
    [Documentation]  Runs sar on UEUP and evaluates throughtput. Evaluation is based on average returned by sar.
    ...  Arguments:
    ...    expected_uplink - expected value of uplink thoruhput rate
    ...    expected_downlink - expected value of downlink  thoruhput rate
    ...    interval - sar interval (in seconds). Default 1
    ...    count - sar counter. Default 600
    [Arguments]  ${expected_uplink}  ${expected_downlink}  ${interval}=1  ${count}=600
    ${sar_command}=  Set Variable  sar -n DEV ${interval} ${count} | grep Average | sed -e "s/\s\+/,/g" | sed -e "s/Average:,//g"
    csn.Send Command  ${sar_command}    connection=UEUP
    ${result_csv}=  csn.Read Output     connection=UEUP
    ${throughput_dict}=  convert_throughput_csv_to_dict  ${result_csv}
    ${percents}=  evaluate_throughput_percentage  data=${throughput_dict}  expected_uplink=${expected_uplink}  expected_downlink=${expected_downlink}
    ${uplink_percent}=  Get From Dictionary  ${percents}  uplink
    ${downlink_percent}=  Get From Dictionary  ${percents}  downlink
    should be true  ${uplink_percent} >= ${DATA_TRANSFER_RELEASE_WITH_RESTRICTION_THRESHOLD}
    ...  msg=Uplink percent (${uplink_percent}) is below required ${DATA_TRANSFER_RELEASE_WITH_RESTRICTION_THRESHOLD}.
    should be true  ${downlink_percent} >= ${DATA_TRANSFER_RELEASE_WITH_RESTRICTION_THRESHOLD}
    ...  msg=Downlink percent (${downlink_percent}) is below required ${DATA_TRANSFER_RELEASE_WITH_RESTRICTION_THRESHOLD}.
    should be true  ${uplink_percent} >= ${DATA_TRANSFER_RELEASE_THRESHOLD}
    ...  msg=Uplink percent (${uplink_percent}) is below required ${DATA_TRANSFER_RELEASE_THRESHOLD}.
    should be true  ${downlink_percent} >= ${DATA_TRANSFER_RELEASE_THRESHOLD}
    ...  msg=Downlink percent (${downlink_percent}) is below required ${DATA_TRANSFER_RELEASE_THRESHOLD}.


Precondition
    [Documentation]  [Deprecated] Connect to cobham control PC via telnet, and start TMA application.
    ...    Arguments:
    ...    TMA_PATH -  the installation path of TMA, in Windows form.
    ...    eg. C:\\Program Files (x86)\\Aeroflex\\TM500\\5G NR - NLA 4.5.0\\Test Mobile Application\\TmaApplication.exe
    ...    tma_alias - telnet connecton to tm500 control PC.
    [Arguments]      ${TMA_PATH}    ${tma_alias}=tma
    tm500_remote.create telnet runner       ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    sleep  5s
    tm500_remote.run tma app        path=${TMA_PATH}    proxy_port=${TM500_PORT}   alias=${tma_alias}
    sleep  10s
    tm500_remote.tma app is running    imagename=TmaApplication.exe     alias=${tma_alias}
    sleep  5s

Precondition_SSH
    [Documentation]  Connect to cobham control PC via SSH, and start TMA application.
    ...    TMA_PATH -  the installation path of TMA, in Linux form.
    ...    eg. /cygdrive/c/Program Files (x86)/Aeroflex/TM500/5G NR - NLA 4.8.0/Test Mobile Application/TmaApplication.exe
    ...    tma_alias - ssh connecton to tm500 control PC.
    [Arguments]    ${TMA_PATH}    ${tma_alias}=tma
    ${TM500_PORT}=  Convert To Integer  ${TM500_PORT}
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    ${tma_PID}  csn.Execute  command=ps -Wef |grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    csn.Execute  command=/bin/kill -f ${tma_PID.strip()}  connection=${tma_alias}
    sleep  3s
    csn.send_command   command="${TMA_PATH}" /u "Default User" /p ${TM500_PORT} /c y /a y &    connection=${tma_alias}
    sleep  60s
    ${tma_PID}  csn.Execute  command=ps -Wef |grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    Log    TMA is running with PID ${tma_PID}.
    Should not be empty    ${tma_PID.strip()}    msg=TMA app is not started
    sleep  10s
    csn.disconnect    connection=${tma_alias}
    [Return]    ${tma_PID}

Postcodition
    [Documentation]  [Deprecated]  Kill TMA application via Telnet.
    [Arguments]     ${tma_alias}=tma
    sleep  5s
    tm500_remote.kill tma app       imagename=TmaApplication.exe    alias=${tma_alias}

Postcondition_SSH
    [Documentation]  Kill TMA application via SSH.
    [Arguments]     ${tma_alias}=tma
    sleep  5s
    Wait Until Keyword Succeeds    3x    30sec    csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    ${tma_PID}  csn.Execute  command=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    csn.force_reconnect    connection=${tma_alias}
    csn.execute  command=/bin/kill -f ${tma_PID.strip()}  connection=${tma_alias}
    ${tma_PID}  csn.Execute  command=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    ${tma_PID}  strip_string    string=${tma_PID}
    csn.disconnect    connection=${tma_alias}
    [Return]    ${tma_PID}

Connect
    [Documentation]  Connect to cobham from control PC.
    [Arguments]     ${tm500_alias}=tm500
    tm500_remote.Connect to  ip=${TM500_IP}  command_port=${TM500_PORT}  alias=${tm500_alias}
    Log to console    \nINFO:connect to tm500 control pc

Disconnect
    [Arguments]     ${tm500_alias}=tm500
    tm500_remote.disconnect  alias=${tm500_alias}
    Log to console    \nINFO:disconnect to tm500

Reboot via MCI
    [Documentation]  Soft reboot cobham via MCI command.
    [Arguments]     ${hw_connect_script_path}=${template_dir}/Init_Config.txt    ${tm500_alias}=tm500
    log    Sending hw_connect_script from ${hw_connect_script_path}
    ${response}=  tm500_remote.send script  ${hw_connect_script_path}  alias=${tm500_alias}  timeout=5 minutes
    Should Not Contain    ${response}    failure
    sleep   30s
    Log    rebooting
    ${response}=  tm500_remote.send command     command=RBOT   alias=${tm500_alias}
    Should Contain    ${response}    RBOT 0x00 Ok
    sleep   60s
    Log    disconnecting
    ${response}=  tm500_remote.send command     command=#$$DISCONNECT   alias=${tm500_alias}
    Should Contain    ${response}    DISCONNECT 0x00 OK

Connect HW and Initialize
    [Documentation]  Connect and initialize cobham.
    [Arguments]   ${hw_connect_script_path}=${template_dir}/Init_Config.txt      ${tm500_alias}=tm500
    [Timeout]    5 minutes

    log    Sending hw_connect_script from ${hw_connect_script_path}
    ${response}=  tm500_remote.send script  ${hw_connect_script_path}  alias=${tm500_alias}  timeout=5 minutes
    Should Not Contain    ${response}    Failure
    sleep   30s

Perform Cell Search
    [Arguments]   ${cell_search_script_path}=${template_dir}/Cell_Search.txt      ${tm500_alias}=tm500
    [Timeout]    5 minutes

    log    Sending cell_search_script from ${cell_search_script_path}
    ${response}=  tm500_remote.send script  ${cell_search_script_path}  alias=${tm500_alias}
    Should Not Contain    ${response}    Failure


