*** Settings ***
Documentation
...   author: kaijia.chen@nokia-sbell.com
...   contact: kaijia.chen@nokia-sbell.com

Library    taf.analyzer.pcap    WITH NAME   cap
Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.ue                       WITH NAME    ute_ue
Library    taf.hw.rf_attenuator           WITH NAME    att
#Library    ../python/ue.py
#Library    ../../5GC002236_FA/resources/trans/translib.py
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
#Library    AHAC_Wire.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot


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
#${BTS_ID}    727
${att_ipaddr}    ${tl.attenuator.ip_addr}
${att_api_port}    ${tl.attenuator.port}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${vendor}    HBTE
${max_attenuation_value}    ${127}
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
${2056_AHAC_default_scf}          ${CURDIR}/../../../../commissionings/HGZ/${testline_name}/SCF_10.1100_DU.xml
${server_port}      ${tl.appserver.iperf_details.port}
${server_ip}         ${tl.appserver.iperf_details.network_interface_address}
${a}    a4ba5818
${appserver_addr}    ${tl.ues[1].iperf_details.ssh_connection_details.addr}






*** Keywords ***
Tests_suite_setup
    Log To Console                  \n Start Tests suite needed configuration
#    Input default SCF
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
    [Arguments]    ${DU_OAM_IP}    ${Actual_value_1}    ${Actual_value_2}    ${Actual_value_3}    ${Actual_value_4}
    Log To Console    Change Threshold in progress
    Rest Login DU    ip_address=${DU_OAM_IP}
    ${dict_1}    create dictionary    parameterName=rlpDetCsiBsiThreshold    operation=update    value=${Actual_value_1}
    ${dict_2}    create dictionary    parameterName=rlpDetDlHarqThreshold    operation=update    value=${Actual_value_2}
    ${dict_3}    create dictionary    parameterName=rlpRecCsiBsiThreshold    operation=update    value=${Actual_value_3}
    ${dict_4}    create dictionary    parameterName=rlpRecDlHarqThreshold    operation=update    value=${Actual_value_4}
    ${list}    create list    ${dict_1}    ${dict_2}    ${dict_3}    ${dict_4}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change InitRlf
    [Arguments]    ${DU_OAM_IP}    ${Actual_value_5}    ${Actual_value_6}    ${Actual_value_7}
    ...            ${Actual_value_8}    ${Actual_value_9}    ${Actual_value_10}
    Log To Console    Change InitRlf in progress
    Rest Login DU    ip_address=${DU_OAM_IP}
    ${dict_1}    create dictionary    parameterName=actGnbInitRlf    operation=update    value=${Actual_value_5}
    ${dict_2}    create dictionary    parameterName=actUeInitRlf    operation=update    value=${Actual_value_6}
    ${dict_3}    create dictionary    parameterName=actInterMeNBMobility    operation=update    value=${Actual_value_7}
    ${dict_4}    create dictionary    parameterName=actIntraFreqInterGnbMobilityNSA3x    operation=update    value=${Actual_value_8}
    ${dict_5}    create dictionary    parameterName=actIntraFreqIntraGnbMobilityNSA    operation=update    value=${Actual_value_9}
    ${dict_6}    create dictionary    parameterName=actIntraMeNBMobility    operation=update    value=${Actual_value_10}
    ${list}    create list    ${dict_1}    ${dict_2}    ${dict_3}    ${dict_4}    ${dict_5}    ${dict_6}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

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
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'Stop RLF Guard Timer'
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    should not be empty    ${output}
    [Teardown]    ssh.disconnect    connection=VM

Start UE Traffic
    [Arguments]    ${throughput}    ${ue_index}=${0}    ${connection}=cpc_${ue_index}
    Log To Console    Start UE Traffic
    ssh.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=${connection}
    ssh.send_command    command=adb -s ${a} shell iperf -u -t 100 -i 1 -p ${server_port} -P 1 -f m -b ${throughput} -l 1400B -T 64 -c ${server_ip} &
    ...    connection=${connection}
    [Teardown]    ssh.disconnect    connection=${connection}



Analysis X2Log and Check Scell Selection in Messages
    [Arguments]    ${filename}=${2056_L_X2_1}    ${PCI}=${63}    ${filename_1}=${2056_L_X2_1_T}
    Stop and Download Log 2
    ${connection}    AHAC_Common.Connect to TestPc
    Analysis X2Log And Get Element Vlaue again    source=${gnb_tmp_log_dir}/${filename}    target=${gnb_tmp_log_dir}/${filename_1}
    ...                                           filter=x2ap.protocolIEs == 4 && nr-rrc.physCellId    PCI=63    connection=${connection}


Analysis X2Log And Get Element Vlaue
    log to console  Analysis X2Log And Get Element Vlaue
    [Arguments]  ${source}    ${target}    ${filter}    ${PCI}    ${filename}=${2056_L_X2}    ${connection}=${connection}
    ...          ${filename_1}=${2056_L_X2}
    Convert pcap to text    source=${gnb_tmp_log_dir}/${filename}    target=${gnb_tmp_log_dir}/${filename_1}
    ...                     filter=x2ap.protocolIEs == 4 && nr-rrc.physCellId    connection=${connection}
    ${return_value}    tmp    file_path=${gnb_tmp_log_dir}/${filename_1}
    should be true     ${return_value}==${PCI}
    [Return]    ${return_value}

Connect to TestPc
    [Arguments]   ${hostname}=${UTE_ADDRESS}    ${username}=${UTE_USERNAME}    ${password}=${UTE_PASSWORD}
    ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=TESTPC
    [Return]   ${connection}

Analysis X2Log And Get Element Vlaue again
    log to console  Analysis X2Log And Get Element Vlaue
    [Arguments]  ${source}    ${target}    ${filter}    ${PCI}    ${filename}=${2056_L_X2_1}    ${connection}=${connection}
    ...          ${filename_1}=${2056_L_X2_1}
    Convert pcap to text    source=${gnb_tmp_log_dir}/${filename}    target=${gnb_tmp_log_dir}/${filename_1}
    ...                     filter=x2ap.protocolIEs == 5 && nr-rrc.physCellId     connection=${connection}
    ${return_value}    tmp    file_path=${gnb_tmp_log_dir}/${filename_1}
    should be true     ${return_value}==${PCI}
    [Return]    ${return_value}

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    [Return]    ${value}

Start to Capture X2 Log on ASIB
    [Arguments]    ${filename}
    Connect to Common Unit Master
    csn.send command    command=killall tcpdump    connection=ASIK Master
    Start to Capture wireshark Log    listen_port=fp0    log_dir=${gnb_tmp_log_dir}    filename=${filename}
    ...    connection=ASIK Master

Start to Capture wireshark Log
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}    ${connection}
    csn.send command    command=tcpdump -n -i br1 -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    3s

Read Wireshark Log
    [Arguments]    ${filename}=${2056_L_X2}    ${filter}=${None}
    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}

Stop and Download Log
    [Arguments]    ${filename}=${2056_L_X2}    ${asik}=ASIK Master
    Connect to Common Unit Master
    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ...    connection=${asik}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill -2 ${PID}    connection=${asik}
    csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${asik}
    sleep    2s
    csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
    Csn.Disconnect	connection=${asik}

Stop and Download Log 2
    [Arguments]    ${filename}=${2056_L_X2_1}    ${asik}=ASIK Master
    Connect to Common Unit Master
    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ...    connection=${asik}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill -2 ${PID}    connection=${asik}
    csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${asik}
    sleep    2s
    csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
    Csn.Disconnect	connection=${asik}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}    ${connection}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y ${filter}
    ...  connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min



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
    Run Keyword And Ignore Error   Rest Logout DU
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
    [Teardown]    Run Keyword And Ignore Error    Rest Logout DU
    Rest Login DU
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
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU
    Rest Login DU
    ${scf_dir}   Get A Directory  scf
    ${scf_file}  Get A File   ${scf_dir}  tmpscf.xml
    coam.Get_Current_Scf_File  local_dir_path=${scf_dir}    file_name=${scf_file}  connection=${alias}
    [Return]  ${scf_file}

Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}   coam.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

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
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be true    '${operationalState}'=='Enabled' or '${operationalState}'=='Disabled'
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be true    '${proceduralState}'=='OnAir' or '${proceduralState}'=='Configured'
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be true    '${operationalState}'=='Enabled' or '${operationalState}'=='enabled'
#    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
#    Should Be Equal    ${tmp}    Online
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Wait until enb cell on air status
    [Timeout]  20 min
    [Arguments]    ${connection}    ${timeout}=10 min
    wait until keyword succeeds    ${timeout}    20 sec    Check enb status is in cell on air status    enb_alias=${connection}

Check enb status is in cell on air status
    [Arguments]    ${enb_alias}
    ${bts_status}    coam.get_bts_statuses    connection=${enb_alias}
    ${enb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Should be equal as strings    ${enb_cell_status}    OnAir    msg=ENB is not on air, Current status is ${enb_cell_status}
    ...    ignore_case=${True}

Change ActInterMeNBMobility
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}
    Log To Console    Change ActInterMeNBMobility
    Rest Login DU    ip_address=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actInterMeNBMobility    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change ActHoWoSnChg
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${BTS_ID}
    Log To Console    Change ActHoWoSnChg
    ${connection}    Rest Login DU    ip_address=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actHoWoSnChg    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait until enb cell on air status    connection=${connection}
    [Teardown]    Rest Logout DU

Adjust HBTE Attenuation
    [Arguments]    ${port_value1}
    Log To Console    Adjust HBTE Attenuation
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation    port=${att_port_1}    value=${port_value1}
    att.set_attenuation    port=${att_port_2}    value=${port_value1}
    att.set_attenuation    port=${att_port_3}    value=${port_value1}
    att.set_attenuation    port=${att_port_4}    value=${port_value1}

Askey Attach
    Log To Console    Askey Attach
    Prepare Askey
    ${5Grach_ed}    inseego.UE Attach
    Verify attach    5Grach_ed=${5Grach_ed}    4G_check=False

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
#    run keyword if    '${reboot_ue}'=='${True}'    _Reboot_UE    connection=cpc_${ue_index}
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities[0]}

_Prepare Askey Variables
    [Arguments]  ${ue_index}=${0}
    ${ue_config}   ue.get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
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

Save TXT Log In UTE
    [Arguments]    ${connection}    ${pcap_filename}    ${txt_filename}    ${filter1}
    Stop And Copy Log To UTE    connection=${connection}    filename=${pcap_filename}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    [Teardown]    ssh.disconnect    connection=UTE

Stop And Copy Log To UTE
    [Arguments]    ${connection}    ${filename}
    ssh.send_command    command=sudo pkill tcpdump    connection=${connection}
    ssh.send_command    command=scp /tmp/${filename} ${UTE_USERNAME}@${UTE_ADDRESS}:/${LOG_PATH} -- ${UTE_PASSWORD}
    ...    connection=${connection}
    [Teardown]    ssh.disconnect    connection=${connection}

#Convert pcap to text
#    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
#    ssh.send_command
#    ...    command=tshark -X lua_script:${luashark_path} -V -r ${source} -T text -Y ${filter} > ${target}
#    ...    connection=${connection}
#    ssh.await execution end    connection=${connection}  timeout=30min

Grep Text Content
    [Arguments]    ${txt_filename}    ${item}    ${connection}
    ssh.send_command    command=cat ${LOG_PATH}/${txt_filename} | grep '${item}'    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=UTE
    [Return]    ${output}

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





