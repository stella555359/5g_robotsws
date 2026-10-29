*** Settings ***
Documentation		Place for qualcomm attach_detach and  Monitor the UL_DL throughput
...			author: Kongshuai.fan
...			contact: Kongshuai.fan@nokia-sbell.com
Library           OperatingSystem
Library           Collections
Library	          String
Library           taf.ue  WITH NAME   ute_ue
Library           taf.pdu  WITH NAME   pdu
Library           taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot


*** Variables ***
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${fsp1a_addr}       ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${asik_passwd}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
Reserve ue for tests
    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
    ...  It is strongly suggested to put this keyword into the suite setup.
    ...  If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...  :param UE_CAPABILITIES:  REAL_ANDROID_UE.
    ...  :param UE_alias:  It is a name to distingush ue.
    [Arguments]  ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_ANDROID_UE
    ute_ue.require Ue  ${UE_alias}  capabilities=${UE_CAPABILITIES}
    Log to console    \nINFO:reserve UE successfully

Ue attach
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...   If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword just send AT command without any log checking.
    [Arguments]  ${UE_alias}=UE_1
    ute_ue.attach_ue    ${UE_alias}
    Log to console    \nINFO:UE attach successfully

Ue detach
    [Arguments]  ${UE_alias}=UE_1
    ute_ue.detach_ue    ${UE_alias}
    Log to console    \nINFO:UE detach successfully

Data Transfer
    [Documentation]  This keyword will setup the data transfer in the backgroud.
    ...  :param DT_Name:  It is a label use to seprate from other data transfer.
    ...  :param dirction:  when it is dl, start DL data transfer; when it is ul, start UL data transfer.
    ...  :param Expected_Tput:  It should be the data throughput that you will perform.
    ...  :param Duration:  The time duration that the data transfer will keep.
    ...  :param Data_Type:  It is the data type which can be set to udp or tcp.
    ...  :packet_size: -l  option in the iperf command.
    [Arguments]  ${DT_Name}=dt1    ${UE_alias}=UE_1    ${direction}=dl
    ...   ${Expected_Tput}=20Mbits/sec    ${Duration}=180s    ${Data_Type}=udp
    ...   ${Packet_Size}=1400
    ute_ue.start_data_transfer
    ...   dt_name=${DT_Name}  ue_alias=${UE_alias}
    ...   direction=${direction}  throughput=${Expected_Tput}
    ...   duration=${Duration}  protocol=${Data_Type}
    ...   packet_size=${Packet_Size}
    Log to console    \nINFO:start data transfer...

Check out throughput
    [Documentation]  The keyword is used to check out througenput.
    ...    :param Acceptable_Deviation:  It is a tolerance of throughput that the test can accept.
    [Arguments]  ${DT_Name}=dt1    ${Expected_Throughput}=20Mbits/sec
    ...   ${Acceptable_Deviation}=10%
    Log to console    \nINFO:check throughput...
    ute_ue.verify average throughput with deviation
    ...   dt_name=${DT_Name}
    ...   tput=${Expected_Throughput}
    ...   deviation=${Acceptable_Deviation}

Wait until data transfer finished
    [Documentation]  The keyword is to wait times unitl the data transfer is done.
    ...  However, it does not support the ta_ue_plugin_qualcomm
    [Arguments]  ${DT_Name}=dt1
    ute_ue.await data transfer finish       dt_name=${DT_Name}
    Log to console    \nINFO:await data transfer finish...

Start catch UE ADB logs
    [Documentation]  Catch the UE adb log for check UE setup.
    ...    :param serial_number:    The serial number of phone
    [Arguments]     ${serial_number}
    Csn.send_command  command=rm /tmp/*.*  connection=cpc    timeout=5
    sleep   1s
    Csn.read_output    connection=cpc
    Csn.send_command  command=adb -s ${serial_number} logcat -c  connection=cpc    timeout=5
    Sleep  3s
    Csn.read_output    connection=cpc
    Csn.send_command
    ...   command=nohup adb -s ${serial_number} logcat -b all > /tmp/ADB.log &
    ...   connection=cpc    timeout=5
    Log  INFO:Start to catch UE ADB logs  console=true

Stop catch UE ADB logs and save it
    [Documentation]  Stop catch UE ADB log and save it.
    Csn.send_command  command=adb kill-server logcat  connection=cpc    timeout=5
    sleep   1s
    Csn.read_output    connection=cpc
    Log  INFO:Stop to catch UE ADB logs  console=true

Connect to control pc
    [Documentation]  connect the control PC
    ...   :param cpc_ip: the ip address of control PC
    ...   :param cpc_usrname:  the user name to login in control PC
    ...   :param cpc_passwd: the user password to login in control PC
    [Arguments]    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}  ${alias}=cpc
    ${connection_status}    Run keyword and return status   Connect to cpc    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}
    Run keyword if    '${connection_status}'=='${False}'     Log
    ...      CPC connection failed: ${cpc_ip} / ${cpc_usrname} / ${cpc_passwd} !    WARN
    Should be true    ${connection_status}

Connect to cpc
    [Documentation]  connect the control PC
    ...   :param cpc_ip: the ip address of control PC
    ...   :param cpc_usrname:  the user name to login in control PC
    ...   :param cpc_passwd: the user password to login in control PC
    [Arguments]    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}  ${alias}=cpc
    Wait Until Keyword Succeeds    5min    20s
    ...   Csn.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}
    Log to console    \nINFO:connect to control pc successfully

ADB log verify 5G UE setup successfully
    [Documentation]  This keyword is to verify 4G and 5G UE setup successfully via ADB log.
    ...    :param lte_earfcn: earfcnDL in the eNB bts
    [Arguments]  ${lte_earfcn}
    Verify 4G UE setup by ADB log   ${lte_earfcn}
    Csn.send_command
    ...   command=grep is5GConnected /tmp/ADB.log |tail -1
    ...   connection=cpc
    ${result_ALL}   Csn.read_output    connection=cpc
    Csn.send_command
    ...   command=grep is5GConnected /tmp/ADB.log |tail -1
    ...   connection=cpc
    ${result}   Csn.read_output    connection=cpc
    should_match_regexp  ${result}   is5GConnected.? true
    should_not_match_regexp  ${result}   is5GConnected.? false
    Csn.send_command
    ...   command=grep ratType /tmp/ADB.log
    ...   connection=cpc
    ${result}   Csn.read_output    connection=cpc
    # Should contain  ${result}  ratType 5gnr

Check ADB devices
    [Documentation]  check phone serial number
    ...    :param serial_number: the serial number of phone
    [Arguments]  ${serial_number}
    Csn.send_command   command=adb devices  connection=cpc      timeout=5
    Sleep   3s
    ${result}    Csn.read_output    connection=cpc
    Should contain   ${result}   ${serial_number}
    should not contain  ${result}   connecting
    log     INFO:UE devices detected    console=true

Verify 4G UE setup by ADB log
    [Documentation]   Verify 4G UE setup by ADB log.
    ...  :param lte_erafcn: earfcnDL in the eNB bts
    [Arguments]  ${lte_earfcn}
    Csn.send_command
    ...  command=cat /tmp/ADB.log | grep DATA_REGISTRATION | grep rat
    ...  connection=cpc
    sleep   2s
    ${result}   Csn.read_output    connection=cpc
    @{adb_results}  split to lines  ${result}
    Run keywords
    ...   Should contain  @{adb_results}[-2]  rat = 14   AND
    ...   Should contain  @{adb_results}[-2]  earfcn = ${lte_earfcn}

Power reset UE
    [Documentation]  Power reset phone by PB
    ...     :param ue_pdu_ip: the PB ip address to power cycle the ue.
    ...     :param ue_pdu_port: the PB port number that connected with ue
    [Arguments]  ${ue_pdu_ip}   ${ue_pdu_port}   ${ue_pdu_model}=FACOM
    pdu.setup_pdu    model=${ue_pdu_model}
    ...              host=${ue_pdu_ip}
    ...              alias=pdu_devices_connect
    pdu.power_off    port=${ue_pdu_port}    pdu_device=pdu_devices_connect
    sleep    10s
    pdu.power_on    port=${ue_pdu_port}    pdu_device=pdu_devices_connect
    sleep    10s

start to record the throughput into log
    [Documentation]     This keyword is used to record jouranlctl log in the background.
    ...    :param direction: dl means download link; ul means upper link.
    ...    :param alias: alias is the connection where to execute the cmd.
    ...    author: kongshuai.fan
    [Arguments]     ${direction}    ${alias}=fsp1a
    ${grep_msg}     set variable if
    ...     '${direction}'== 'dl'     L2_LO_TB
    ...     '${direction}'== 'ul'     L2_LO_UL
    ${file_name}    set variable if
    ...     '${direction}'== 'dl'     DL_data
    ...     '${direction}'== 'ul'     UL_data
    Csn.send_command    command=nohup journalctl -f | grep ${grep_msg}>/tmp/${file_name}.log &   connection=${alias}

stop recording the throughput
    [Documentation]     This keyword will stop the journalctl process that catch log.
    ...     :param alias: alias is the connection where to execute the cmd.
    ...     author:kongshuai.fan
    [Arguments]     ${alias}=fsp1a
    Csn.send_command    command=killall journalctl      connection=${alias}
    Log to console    \nINFO:stop recording the throughput

download transfer data log
    [Documentation]     This keyword will download the log from ABIL master to test PC.
    ...    :param direction: dl means download link; ul means upper link
    ...    :param log_dir: the directory on the Test PC to store logs
    ...    :param alias: alias is the connection where to execute the cmd.
    ...    author: kongshuai.fan and updated by SKK
    [Arguments]     ${direction}    ${log_dir}  ${alias}=ASIK1    ${1514_featuer_enabled}=false
    ${file_name}    set variable if
    ...      '${direction}'== 'dl'     DL_data
    ...      '${direction}'== 'ul'     UL_data
    run keyword and ignore error    Csn.execute     command=rm -rf /tmp/${file_name}.log   connection=${alias}
    run keyword if    '${1514_featuer_enabled}' == 'false'    csn.Send Command
    ...        command=scp -o StrictHostKeyChecking\=no ${asik_username}@${fsp1a_addr}:/tmp/${file_name}.log /tmp/${file_name}.log
    ...        get_pty=True
    ...        connection=${alias}
    run keyword if    '${1514_featuer_enabled}' == 'true'    csn.Send Command
    ...        command=scp -o StrictHostKeyChecking\=no ${asik_username}@${fsp1b_addr}:/tmp/${file_name}.log /tmp/${file_name}.log
    ...        get_pty=True
    ...        connection=${alias}
    ${scp_output} =    Run Keyword And Ignore Error
    ...                csn.read output until    match=Password    timeout=10    connection=${alias}
    Log    ${scp_output}
    run keyword if    '${scp_output[0]}' == 'PASS'
    ...              csn.write input    data=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}\n    connection=${alias}
    sleep    10s
    Csn.download file
    ...   /tmp/${file_name}.log
    ...   ${log_dir}/${file_name}.log
    ...   connection=${alias}

Preprocess dl transfer data log
    [Documentation]     This keyword will process the log data for further calculate.
    ...    :param log_dir: the directory on the Test PC to store logs
    [Arguments]     ${log_dir}    ${log_type}=journalctl
    ${file_name}    set variable    DL_data
    Run keyword if      '${log_type}'=='journalctl'     Run keyword
    ...     run     grep DataPdu ${log_dir}/${file_name}.log > ${log_dir}/${file_name}_proc.log
    Run keyword if      '${log_type}'=='aasyslog'    Run keyword
    ...     run     more ${log_dir}/${file_name}.log| grep -a 'DataPdu' > ${log_dir}/${file_name}_proc.log
    run     sed -i 's/.*DataPdu: //g' ${log_dir}/${file_name}_proc.log
    run     sed -i 's/\\].*//g' ${log_dir}/${file_name}_proc.log
    run     awk -F \\| '{print $4 > "${log_dir}/${file_name}_proc.log"}' ${log_dir}/${file_name}_proc.log

Preprocess ul transfer data log
    [Documentation]     This keyword will process the log data for further calculate.
    ...    :param log_dir: the directory on the Test PC to store logs
    [Arguments]     ${log_dir}     ${log_type}=journal
    ${file_name}    set variable    UL_data
    Run keyword if      '${log_type}'=='journalctl'    Run keyword
    ...        run     grep rlcPduBytes ${log_dir}/${file_name}.log > ${log_dir}/${file_name}_proc.log
    Run keyword if      '${log_type}'=='aasyslog'     Run keyword
    ...        run     more ${log_dir}/${file_name}.log| grep -a 'rlcPduBytes' > ${log_dir}/${file_name}_proc.log
    run     sed -i 's/.*(//g' ${log_dir}/${file_name}_proc.log
    run     awk '{print $1 > "${log_dir}/${file_name}_proc.log"}' ${log_dir}/${file_name}_proc.log


verify the data transfer thoughput on gNB
    [Documentation]  This keyword will calucate the average throughput using the processed log.
    ...    :param direction: dl means download link; ul means upper link
    ...    :param log_dir: the directory on the Test PC to store logs
    ...    :param expect: the expect throughput
    ...    :param ratio: the acceptable ratio
    [Arguments]     ${direction}    ${log_dir}     ${expect}=20     ${ratio}=0.8
    ${threshold}    evaluate  ${expect}*${ratio}
    ${file_name}    set variable if
    ...      '${direction}'== 'dl'     DL_data
    ...      '${direction}'== 'ul'     UL_data
    ${average}=      calculate_average_of_the_throughput_listed_in_file   ${log_dir}/${file_name}_proc.log
    Set Test Variable   ${average_throughput_${direction}}  ${average}
    Set Test Variable   ${${direction}_threshold}  ${threshold}
    should be true      ${average}>=${threshold}

Connect to asp1a
    [Arguments]    ${alias}=asp1a    ${proxy}=ASIK
    csn.Connect to    hostname=${fsp1a_addr}    username=${asik_username}    password=${asik_passwd}
    ...    alias=${alias}    proxy=${proxy}
    Log to console    \nINFO:connect to asp1a

Reboot UE with ADB
   Csn.send_command   command=adb reboot  connection=cpc      timeout=5
   Log to console    \nINFO:reboot UE with ADB successfully
