*** Settings ***
Documentation
...   author: kaijia.chen@nokia-sbell.com
...   contact: kaijia.chen@nokia-sbell.com

Library         taf.rfrl.common_resources.python.check_cap.CapPacket    WITH NAME   cap
Library         taf.transport.ssh            WITH NAME    ssh
Library         taf.collectors.core          WITH NAME    core
Library         taf.collectors.tcpdump       WITH NAME    tcpdump
Library         taf.analyzer.pdml            WITH NAME    cpdml
Library         taf.collectors.btslog        WITH NAME    btslog
Library         taf.ue                       WITH NAME    ute_ue
Library         taf.hw.rf_attenuator           WITH NAME    att
Library         String
Library         Collections
Library         OperatingSystem
Library         Process
Library         XML
Library         DateTime
Library         Telnet
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${gNB_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${eNB_OAM_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${DU_OAM_SSH_USERNAME}
${DU_OAM_SSH_PASSWORD}
${DU_OAM_WEBUI_URL}
${DU_OAM_WEBUI_USER}
${DU_OAM_WEBUI_PASSWORD}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${att_ipaddr}    ${tl.attenuator.ip_addr}
${att_api_port}    ${tl.attenuator.port}
${att_port_5}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_8}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_13}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_14}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${vendor}    HBTE
${max_attenuation_value}    ${127}
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
${2056_AHAC_default_scf}          ${CURDIR}/../../../../commissionings/HGZ/${testline_name}/SCF_10.1100_DU.xml
${server_port}      ${tl.appserver.iperf_details.port}
${server_ip}         ${tl.appserver.iperf_details.network_interface_address}
${appserver_addr}    ${tl.ues[1].iperf_details.ssh_connection_details.addr}

*** Keywords ***
Tests_suite_setup
    Log To Console                  \n Start Tests suite needed configuration
    Run Keyword And Ignore Error    _Init_Global_Variable

Input default SCF
    [Timeout]  20 min
    [Arguments]    ${timeout}=10 min
    ${conn}    Connect to DU
    BuiltIn.Log    \n Input default SCF \n    console=yes
    COAM Commission with scf file ignore error    scf_file_path=${2056_AHAC_default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU

Change Threshold
    [Arguments]    ${DU_OAM_IP}    ${Actual_value_1}    ${Actual_value_2}    ${Actual_value_3}    ${Actual_value_4}    ${connection}=GNB_OAM
    Log To Console    Change Threshold in progress
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${dict_1}    create dictionary    parameterName=rlpDetCsiBsiThreshold    operation=update    value=${Actual_value_1}
    ${dict_2}    create dictionary    parameterName=rlpDetDlHarqThreshold    operation=update    value=${Actual_value_2}
    ${dict_3}    create dictionary    parameterName=rlpRecCsiBsiThreshold    operation=update    value=${Actual_value_3}
    ${dict_4}    create dictionary    parameterName=rlpRecDlHarqThreshold    operation=update    value=${Actual_value_4}
    ${list}    create list    ${dict_1}    ${dict_2}    ${dict_3}    ${dict_4}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]   COAM Teardown gnb connections

Change InitRlf
    [Arguments]    ${DU_OAM_IP}    ${Actual_value_5}    ${Actual_value_6}    ${Actual_value_7}
    ...            ${Actual_value_8}    ${Actual_value_9}    ${Actual_value_10}    ${connection}=GNB_OAM
    Log To Console    Change InitRlf in progress
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${dict_1}    create dictionary    parameterName=actGnbInitRlf    operation=update    value=${Actual_value_5}
    ${dict_2}    create dictionary    parameterName=actUeInitRlf    operation=update    value=${Actual_value_6}
    ${dict_3}    create dictionary    parameterName=actInterMeNBMobility    operation=update    value=${Actual_value_7}
    ${dict_4}    create dictionary    parameterName=actIntraFreqInterGnbMobilityNSA3x    operation=update    value=${Actual_value_8}
    ${dict_5}    create dictionary    parameterName=actIntraFreqIntraGnbMobilityNSA    operation=update    value=${Actual_value_9}
    ${dict_6}    create dictionary    parameterName=actIntraMeNBMobility    operation=update    value=${Actual_value_10}
    ${list}    create list    ${dict_1}    ${dict_2}    ${dict_3}    ${dict_4}    ${dict_5}    ${dict_6}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]   COAM Teardown gnb connections

Start Catch BTS Log
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Start Catch BTS Log
    __Make empty BTS logs dir      bts_logs_dir=${bts_logs_dir}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Stop BTS Log and Check Timer Start and Stop
    Log To Console    Stop and collect btslog on local machine
    Stop and collect btslog on local machine
    Check Timer Start and Stop

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    Log To Console    Stop and collect btslog on local machine
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check Timer Start and Stop
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check Timer Start and Stop
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'Start RLF Guard Timer'
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    should not be empty    ${output}
    [Teardown]    ssh.disconnect    connection=VM

Check 4G throughput during timer start
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check Timer Start and Stop
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep -i datapdu | awk '/UL/ {print $18,$19,$20}'
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    ${output}    replace string    ${output}   \n    ${SPACE}
    ${output_list}    String.split string   ${output}    ${SPACE}
    ${max_flag}    set variable    ${False}
    FOR    ${item}    IN    @{output_list}
        ${item}    Evaluate    int(${item})
        ${max_flag}    run keyword if    ${item}>100    set variable    ${True}
        exit for loop if    ${max_flag}
    END
    should be true    ${max_flag}
    [Teardown]    ssh.disconnect    connection=VM

Start UE Traffic
    [Arguments]    ${throughput}    ${ue_index}=${0}    ${connection}=cpc_${ue_index}
    Log To Console    Start UE Traffic
    ssh.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=${connection}
    ssh.send_command    command=adb shell iperf -u -t 100 -i 1 -p ${server_port} -P 1 -f m -b ${throughput} -l 1400B -T 64 -c ${server_ip} &
    ...    connection=${connection}
    [Teardown]    ssh.disconnect    connection=${connection}



Analysis X2Log and Check Scell Selection in Messages
    [Arguments]    ${filename}=${2056_L_X2_1}    ${PCI}=${36}    ${filename_1}=${2056_L_X2_1_T}
    Stop and Download Log 2
    ${connection}    AHAC_Common.Connect to TestPc
    Analysis X2Log And Get Element Vlaue again    source=${gnb_tmp_log_dir}/${filename}    target=${gnb_tmp_log_dir}/${filename_1}
    ...                                           filter=x2ap.protocolIEs == 4 && nr-rrc.physCellId    PCI=36    connection=${connection}


Start to Capture X2 Log on ASIB
    [Arguments]    ${filename}
    Connect to Common Unit Master
    csn.send command    command=killall tcpdump    connection=ASIK Master
    Start to Capture wireshark Log    listen_port=fp0    log_dir=${gnb_tmp_log_dir}    filename=${filename}
    ...    connection=ASIK Master

Start to Capture wireshark Log
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}    ${connection}
    csn.Send Command   command=ifconfig |grep br |head -1|cut -d ':' -f 1     connection=${connection}
    ${br}    csn.Read Output    connection=${connection}
    ${br}    strip_string    ${br}
    csn.send command    command=tcpdump -n -i ${br} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    3s

Save TXT Log In UTE
    [Arguments]    ${pcap_filename}    ${txt_filename}    ${filter1}
    ssh.Connect to    hostname=${gNB_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...               alias=DU
    Stop And Copy Log To UTE    connection=DU    filename=${pcap_filename}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    [Teardown]    ssh.disconnect    connection=UTE

Stop And Copy Log To UTE
    [Arguments]    ${connection}    ${filename}
    Log To Console    Stop And Copy Log To UTE
    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${LOG_PATH}/${filename}    connection=${connection}
    [Teardown]    ssh.disconnect    connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    Log To Console    Conver pcap to text
    ssh.send_command
    ...    command=tshark -X lua_script:${luashark_path} -V -r ${source} -T text -Y ${filter} > ${target}
    ...    connection=${connection}
    ssh.await execution end    connection=${connection}  timeout=30min

Grep Text Content
    [Arguments]    ${txt_filename}    ${item}    ${connection}
    ssh.send_command    command=cat ${LOG_PATH}/${txt_filename} | grep '${item}'    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=UTE
    [Return]    ${output}

Check gNB PCI
    [Arguments]    ${txt_filename}    ${PCI_ID}
    Log To Console    Check gNB PCI...
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=physCellId    connection=UTE
    should be equal as numbers    ${output.split(":")[1]}    ${SPACE}${PCI_ID}
    [Teardown]    ssh.disconnect    connection=UTE

TRANS Common Setup
    [Documentation]  TRANS Common Setup
    Set Library Search Order   trans_comm
    TRANS Test Common Setup
    _Install Packages
    Run Keyword And Ignore Error    _Init_Global_Variable
    Run Keyword And Ignore Error   _Init_BTS_Info_Variable

Tests_suite_Teardown
    [Documentation]  TRANS Common Teardown, called by 'suite teardown'
    TRANS Test Common Teardown

TRANS Test Common Setup
    FOR  ${keyword}  IN   firefox   geckodriver
       ${out}   Run Process   ps -ef | grep ${keyword} | grep -v grep | awk '{print $2}' | xargs kill -9   shell=True
    END
    ${res}=    Run Keyword And Ignore Error    Get System Time From BTS
    ${START_TIME}=    Get Time    exclude_millis=yes
    ${START_TIME}=    Set Variable If    '${res[0]}'=='PASS'    ${res[1]}    ${START_TIME}
    Set Suite Variable    ${START_TIME}

Get System Time From BTS
    [Teardown]   Run Keyword And Ignore Error   ssh.Disconnect    connection=myconn
    [Documentation]    Get System Time from BTS
    ssh.Connect_To    hostname=${DU_OAM_IP}   username=${DU_OAM_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}   alias=myconn
    ${ret}   ssh.Execute   command=date +"%Y-%m-%d %H:%M:%S"   connection=myconn
    ${bts_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    [Return]    ${bts_time[0]}

TRANS Test Common Teardown
    [Documentation]  TRANS Test Common Teardown, called by 'test teardown'
    Run Keyword And Ignore Error   COAM Teardown gnb connections
    Run Keyword And Ignore Error  selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  WEBUI Logout
    Run Keyword And Ignore Error  selenium_coam.Disable_Virtual_Display
    FOR  ${keyword}  IN   firefox   geckodriver
       ${out}   Run Process   ps -ef | grep ${keyword} | grep -v grep | awk '{print $2}' | xargs kill -9   shell=True
    END

_Install Packages
    ${cmd}  Set Variable   sudo apt list --installed | grep tshark
    ${out}   Run Process   ${cmd}  shell=True
    Run Keyword If  ${out.rc}!=0  Log To Console  Please install tshark in UTE firstly(Linux command: sudo apt-get install tshark --yes)
    Should Be True   ${out.rc}==0

_Init_Global_Variable
    ${result}   ${DU_OAM_IP}   Run Keyword And Ignore Error
    ...   Set Variable   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Set Suite Variable   ${DU_OAM_IP}
    ${result}  ${DU_OAM_SSH_USERNAME}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    Set Suite Variable   ${DU_OAM_SSH_USERNAME}
    ${result}  ${DU_OAM_SSH_PASSWORD}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Set Suite Variable   ${DU_OAM_SSH_PASSWORD}
    ${result}  ${DU_OAM_WEBUI_URL}        Run Keyword And Ignore Error
    ...   Set Variable  https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}/
    Set Suite Variable   ${DU_OAM_WEBUI_URL}
    ${result}  ${DU_OAM_WEBUI_USER}      Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.username}
    Set Suite Variable   ${DU_OAM_WEBUI_USER}
    ${result}  ${DU_OAM_WEBUI_PASSWORD}   Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    Set Suite Variable   ${DU_OAM_WEBUI_PASSWORD}
    ${result}  ${UTE_ADDRESS}       Run Keyword And Ignore Error
    ...   Set Variable    ${tl.test_pc.default_ssh_connection_details.addr}
    Set Suite Variable   ${UTE_ADDRESS}
    ${result}  ${UTE_USERNAME}       Run Keyword And Ignore Error
    ...   Set Variable    ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable   ${UTE_USERNAME}
    ${result}  ${UTE_PASSWORD}        Run Keyword And Ignore Error
    ...   Set Variable  ${tl.test_pc.default_ssh_connection_details.password}
    Set Suite Variable   ${UTE_PASSWORD}
    ${BOOLEAN_TRUE}  Convert To Boolean  True
    Set Suite Variable   ${BOOLEAN_TRUE}
    ${BOOLEAN_FALSE}  Convert To Boolean  False
    Set Suite Variable   ${BOOLEAN_FALSE}
    ${result}   ${TRANS_PARA}   Run Keyword And Ignore Error    Set Variable  ${tl._trans_para}
    Set Suite Variable   ${TRANS_PARA}
    Run Keyword If  """${TRANS_PARA}"""=="""${NONE}"""   _Disp_Global_Variable
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""

_Disp_Global_Variable
    Log To Console  DU_OAM_IP:${DU_OAM_IP}
    Log To Console  DU_OAM_SSH_USERNAME:${DU_OAM_SSH_USERNAME}
    Log To Console  DU_OAM_SSH_PASSWORD:${DU_OAM_SSH_PASSWORD}
    Log To Console  DU_OAM_WEBUI_URL:${DU_OAM_WEBUI_URL}
    Log To Console  DU_OAM_WEBUI_USER:${DU_OAM_WEBUI_USER}
    Log To Console  DU_OAM_WEBUI_PASSWORD:${DU_OAM_WEBUI_PASSWORD}
    Log To Console  UTE_USERNAME:${UTE_USERNAME}
    Log To Console  UTE_PASSWORD:${UTE_PASSWORD}

_Init_BTS_Info_Variable
    [Arguments]   ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${gNB_OAM_IP}
    ${SCF_BACKUP_DIR}    Get A Directory  scfbackup
    ${DU_SCF_BACKUP_FILE}   Get A File    ${SCF_BACKUP_DIR}    scf_backup.xml
    coam.Get_Current_Scf_File  local_dir_path=${SCF_BACKUP_DIR}   file_name=scf_backup.xml   timeout=60
    Set Suite Variable   ${DU_SCF_BACKUP_FILE}
    ${DU_BTS_ID}  Get MRBTS Id   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_BTS_ID}
    ${DU_MRBTS_VER}  Get MRBTS Version   scf_path=${DU_SCF_BACKUP_FILE}
    Set Suite Variable  ${DU_MRBTS_VER}
    Get Existing Fault Id List
    Get Existing History Fault Id List
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Get Existing Fault Id List
    [Arguments]   ${alias}=default
    #Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1x   0s   Alarm Should Not Contain Fault ID   ${EMPTY_FAULT_ID}
    ${active_alarm_info}   Get Active Alarm REST  alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}
    ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}    Create List
    FOR    ${i}    IN    @{active_alarm_keys}
        ${FaultId}   Set Variable    ${active_alarm_info[${i}]['fault_id']}
        Append To List   ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}   ${FaultId}
    END
    Set Suite Variable     ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}

Get Active Alarm REST
    [Arguments]  ${alias}=default
    [Documentation]   Get Active Alarm,
    ...   The fault id 9999 stands for alarm whose fault id is empty
    ${rtn}  Create Dictionary
    ${active_alarm_info}    coam.Get_Active_Alarms   connection=${alias}
    ${active_alarm_length}   Get Length   ${active_alarm_info}
    FOR    ${i}    IN RANGE    0    ${active_alarm_length}
        ${tmp_dict}   Copy Dictionary   ${active_alarm_info[${i}]}
        ${str_faultId}  Evaluate   str(${tmp_dict['faultId']})
        Set To Dictionary    ${tmp_dict}    fault_id     ${str_faultId}
        #Set To Dictionary    ${tmp_dict}    severity    ${tmp_dict['Severity']}
        Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['alarmName']}
        Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['faultName']}
        Set To Dictionary    ${tmp_dict}    appeared      ${tmp_dict['btsObservationTime']}
        Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['alarmId']}
        Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['notifier']}
        Log To Console  ${tmp_dict}
        Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END
    [Return]   ${rtn}

Get Existing History Fault Id List
    [Arguments]   ${alias}=default
    ${active_alarm_info}   Get History Alarm REST  alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}
    ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}    Create List
    FOR    ${i}    IN    @{active_alarm_keys}
        Append To List   ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}   ${active_alarm_info[${i}]['fault_id']}
    END
    ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}   Unique List   input_list=${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}
    Set Suite Variable     ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}

Unique List
    [Arguments]  ${input_list}
    [Documentation]  Unique List, make list member unique
    ${rtn_list}   Evaluate   list(set(${input_list}))
    [Return]  ${rtn_list}

Get History Alarm REST
    [Arguments]  ${alias}=default
    [Documentation]   Get History Alarm REST
    ...   The fault id 9999 stands for alarm whose fault id is empty
    ${rtn}  Create Dictionary
    ${active_alarm_info}    coam.Get_Historic_Alarms  connection=${alias}   timeout=60
    ${active_alarm_length}   Get Length   ${active_alarm_info}
    FOR    ${i}    IN RANGE    0    ${active_alarm_length}
       ${tmp_dict}   Copy Dictionary   ${active_alarm_info[${i}]}
        ${str_faultId}  Evaluate   str(${tmp_dict['faultId']})
        Set To Dictionary    ${tmp_dict}    fault_id   ${str_faultId}
        #Set To Dictionary    ${tmp_dict}    severity    ${tmp_dict['severity']}
        Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['alarmName']}
        Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['faultName']}
        Set To Dictionary    ${tmp_dict}    appeared      ${tmp_dict['btsObservationTime']}
        Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['alarmId']}
        Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['notifier']}
        Set To Dictionary    ${tmp_dict}    btsLastUpdateTimezone    ${tmp_dict['btsLastUpdateTimezone']}
        Log To Console  ${tmp_dict}
        Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END
    [Return]   ${rtn}

Get A Directory
    [Arguments]  @{paths}
    [Documentation]   Get A Directory
    ${rtn}   TRANS Get A Directory   @{paths}
    [Return]  ${rtn}

Get A File
    [Arguments]  @{paths_or_filename}
    [Documentation]   Get A File
    ${rtn}  TRANS Get A File   @{paths_or_filename}
    [Return]  ${rtn}

Get MRBTS ID
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
    ...   ELSE   set variable  ${scf_path}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*MRBTS"\\s+distName="MRBTS-(\\d+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}

Get MRBTS Version
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
    ...   ELSE   set variable  ${scf_path}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*MRBTS"\\s+distName="MRBTS-\\d+"\\s+version="(\\S+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}

REST Get SCF File
    [Arguments]  ${alias}=default
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections
    Connect to gnb coam via ssl     bts_host=${gNB_OAM_IP}
    ${scf_dir}   Get A Directory  scf
    ${scf_file}  Get A File   ${scf_dir}  tmpscf.xml
    coam.Get_Current_Scf_File  local_dir_path=${scf_dir}    file_name=${scf_file}  connection=${alias}
    [Return]  ${scf_file}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
#    Run Keyword If     ${virtual_enable}     Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Log To Console  Try to logout before login...
    Run Keyword And Ignore Error    selenium_coam.Logout
    Log To Console  Logout successfully...
    Log To Console  Try to login...
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    1s
    Log To Console  END:WEBUI Logout!

Check BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections
    Log To Console  Check BTS Should Be Normal
    Connect to gnb coam via ssl     bts_host=${gNB_OAM_IP}
    Wait Until BTS Should Be Normal

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    COAM Check GNB cell on air

Change ActInterMeNBMobility
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}
    Log To Console    Change ActInterMeNBMobility
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actInterMeNBMobility    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    COAM Teardown gnb connections

Change ActHoWoSnChg
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${BTS_ID}     ${connection}=GNB_OAM
    Log To Console    Change ActHoWoSnChg
    Connect to gnb coam via ssl     bts_host=${gNB_OAM_IP}
    ${dict}    create dictionary    parameterName=actHoWoSnChg    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]   COAM Teardown gnb connections

Adjust HBTE Attenuation
    [Arguments]    ${port_value1}    ${port_value2}    ${port_value3}
    Log To Console    Adjust HBTE Attenuation
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_5}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation    port=${att_port_5}    value=${port_value1}
    att.set_attenuation    port=${att_port_6}    value=${port_value1}
    att.set_attenuation    port=${att_port_7}    value=${port_value2}
    att.set_attenuation    port=${att_port_8}    value=${port_value2}
    att.set_attenuation    port=${att_port_11}    value=${port_value3}
    att.set_attenuation    port=${att_port_12}    value=${port_value3}
    att.set_attenuation    port=${att_port_13}    value=${port_value2}
    att.set_attenuation    port=${att_port_14}    value=${port_value2}

Askey Attach and start traffic and check throughput
    Log To Console    Askey Attach
    power_ue.Prepare UE    ue_type=askey_sigspark    ue_index=${1}
    ${5Grach_ed_0}    power_ue.UE Attach   ue_type=askey_sigspark    ue_index=${1}
    power_ue.Verify attach    ue_type=askey_sigspark    5Grach_ed=${5Grach_ed_0}    4G_check=False    ue_index=${1}
    power_ue.Start traffic    ue_type=askey_sigspark    direction=ul    throughput=10MKbits/sec    duration=1000
    ...    ue_index=${1}    ue_mode=NSA
    power_ue.Check throughput    ue_type=askey_sigspark    direction=ul    throughput=2    ue_index=${1}

Case UE detach And Teardown
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${1}
    CI_interface.Common Case Teardown

Prepare Askey
    [Arguments]    ${ue_index}=${0}    ${reset_sol}=${True}    &{kwargs}
    Log To Console    Prepare Askey
    ${reboot_ue}    set variable if    '${reset_sol}'!='none'    ${True}    ${False}
    Prepare At Cmd UE AI    ue_index=${ue_index}    reboot_ue=${reboot_ue}

Prepare At Cmd UE AI
    [Arguments]  ${ue_index}=${0}    ${reboot_ue}=${False}
    _Prepare Askey Variables    ue_index=${ue_index}
    ssh.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${ue_index}
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities[0]}

_Prepare Askey Variables
    [Arguments]  ${ue_index}=${0}
    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    set suite variable    ${cpc_ip}     ${ue_config['cpc_ip']}
    set suite variable    ${cpc_username}    ${ue_config['cpc_username']}
    set suite variable    ${cpc_password}    ${ue_config['cpc_password']}
    set suite variable    ${serial}    ${ue_config['serial_number']}
    set suite variable    ${capabilities}    ${ue_config['capabilities']}

Catch Trace Log And Convert To Text
    [Arguments]    ${DU_OAM_IP}    ${command}    ${time}    ${pcap_filename}    ${txt_filename}    ${filter1}
    ${connection}    Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}     command=${command}    time=${time}
    Save TXT Log In UTE    connection=${connection}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}
    ...    filter1=${filter1}

Start Catch Trace Log
    [Arguments]    ${DU_OAM_IP}    ${command}   ${time}=5s
    Log To Console    Start Catch Trace Log
    ${connection}    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    command=${command}   connection=${connection}
    sleep    ${time}
    [Return]    ${connection}

Check eNB Attach Request
    [Arguments]    ${txt_filename}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=cell-ID    connection=UTE
    ${cell-ID}    Evaluate    int(int('${output.split(":")[1].split("\n")[0]}', 16)/256)    connection=UTE
    should be equal as numbers    ${cell-ID}    ${BTS_ID}
    [Teardown]    ssh.disconnect    connection=UTE

Check eNB Reject Signalling
    [Arguments]    ${pcap_filename}    ${txt_filename}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${filter1}=    CATENATE  x2ap || s1ap && x2ap.procedureCode == 0
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    ${output1}    Grep Text Content    txt_filename=${txt_filename}    item=HandoverRequest   connection=UTE
    should not be empty    ${output1}
    ${filter2}=    CATENATE  x2ap || s1ap && x2ap.procedureCode == 27
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter2}"    connection=UTE
    ${output2}    Grep Text Content    txt_filename=${txt_filename}    item=SgNBAdditionRequest   connection=UTE
    should not be empty    ${output2}
    ${output3}    Grep Text Content    txt_filename=${txt_filename}    item=SgNBAdditionRequestReject   connection=UTE
    should not be empty    ${output3}
    [Teardown]    ssh.disconnect    connection=UTE

Check gNB RejectRequest
    [Arguments]    ${txt_filename}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=radioNetwork: unspecified    connection=UTE
    should not be empty    ${output}
    [Teardown]    ssh.disconnect    connection=UTE

test
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${output}    cap.read_cap    enb3_false.pcap
    cap.check_expression
    [Teardown]    ssh.disconnect    connection=UTE





