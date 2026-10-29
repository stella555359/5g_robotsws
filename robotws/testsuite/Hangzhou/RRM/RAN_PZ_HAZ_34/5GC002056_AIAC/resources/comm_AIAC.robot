*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.ue                       WITH NAME    ute_ue
Library    taf.hw.rf_attenuator           WITH NAME    att
Library    ../../../../TRS/RAN_PZ_HAZ_34/5GC002236_FA/resources/trans/translib.py
Library    ./4g_throughput.py
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${gNB_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${eNB1_OAM_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB2_OAM_IP}    ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${DU_OAM_SSH_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.enbs[0].instance_id}
${BTS_ID2}    ${tl.enbs[1].instance_id}
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
${NRDRB_A-Number}    NRDRB_A-4
${NRBTS}    ${tl.gnbs[0].global_bts_id}
${NRDRB}    ${4}
${vendor}    HBTE
${max_attenuation_value}    ${127}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_PORT}    ${tl.appserver.iperf_details.port}
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
${appserver_addr}    ${tl.ues[1].iperf_details.ssh_connection_details.addr}
${cpc_ip}    ${tl.ues[1].ssh_connection_details.addr}
${cpc_usrname}    ${tl.ues[1].ssh_connection_details.username}
${cpc_passwd}    ${tl.ues[1].ssh_connection_details.password}
${EMIL_EXE_PATH}    "C:/Program Files/Emil/Emil.exe"
${SACK_PATH}        "C:\\tools\\SBTS20C_ENB_0000_000556_000000"
${PROFILE_PATH}     "C:\\Program Files\\Emil\\profiles\\LTE"

*** Keywords ***
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
    Connect to gnb coam via ssl     bts_host=${gNB_OAM_IP}    connection=${alias}
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
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU
    Log To Console  Check BTS Should Be Normal
    Connect to gnb coam via ssl     bts_host=${gNB_OAM_IP}
    Wait Until BTS Should Be Normal

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    COAM Check GNB cell on air

Change ActInterMeNBMobility
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${connection}=GNB_OAM
    Log To Console    Change ActInterMeNBMobility
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actInterMeNBMobility    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}     connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    COAM Teardown gnb connections

Change actDlDataForwardingX2
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${connection}=GNB_OAM
    Log To Console    Change actDlDataForwardingX2
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actDlDataForwardingX2    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    COAM Teardown gnb connections

Change ULData
    [Arguments]    ${DU_OAM_IP}    ${Actual_value1}    ${Actual_value2}    ${connection}=GNB_OAM
    Log To Console    Change ULData
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}    connection=${connection}
    ${object_list}    coam.get_managed_objects    class_name=NRDRB_A    connection=${connection}
    ${index}    set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${dist_name}    get from dictionary    ${item}    distName
         ${index}   get index from list    ${object_list}    ${item}
         exit for loop if    '${NRDRB_A-Number}' in '${dist_name}'
    END
    ${parameters}    get from dictionary    ${object_list}[${index}]    parameters
    ${nsaDrbParam}    get from dictionary    ${parameters}    nsaDrbParam
    set to dictionary    ${nsaDrbParam}     ulDataPath=${Actual_value1}    ulDataSplitThreshold=${Actual_value2}
    remove from dictionary    ${nsaDrbParam}    ulDataPathForUlSplitNotCapableUe
    ${nsaDrbParam_list}    create list   ${nsaDrbParam}
    ${dict}    create dictionary    parameterName=nsaDrbParam    operation=update    value=${nsaDrbParam_list}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDRB-${NRDRB}    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    COAM Teardown gnb connections

Change DLData SplitMode
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${connection}=GNB_OAM
    Log To Console    Change DLData SplitMode
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${object_list}    coam.get_managed_objects    class_name=NRDRB_A     connection=${connection}
    ${index}    set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${dist_name}    get from dictionary    ${item}    distName
         ${index}   get index from list    ${object_list}    ${item}
         exit for loop if    '${NRDRB_A-Number}' in '${dist_name}'
    END
    ${parameters}    get from dictionary    ${object_list}[${index}]    parameters
    ${nsaDrbParam}    get from dictionary    ${parameters}    nsaDrbParam
    set to dictionary    ${nsaDrbParam}     dlDataSplitMode=${Actual_value}
    remove from dictionary    ${nsaDrbParam}    ulDataPathForUlSplitNotCapableUe
    ${nsaDrbParam_list}    create list   ${nsaDrbParam}
    ${dict}    create dictionary    parameterName=nsaDrbParam    operation=update    value=${nsaDrbParam_list}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDRB-${NRDRB}     connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    COAM Teardown gnb connections

Change DLData GainThreshold
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${connection}=GNB_OAM
    Log To Console    Change DLData GainThreshold
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${object_list}    coam.get_managed_objects    class_name=NRDRB_A    connection=${connection}
    ${index}    set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${dist_name}    get from dictionary    ${item}    distName
         ${index}   get index from list    ${object_list}    ${item}
         exit for loop if    '${NRDRB_A-Number}' in '${dist_name}'
    END
    ${parameters}    get from dictionary    ${object_list}[${index}]    parameters
    ${nsaDrbParam}    get from dictionary    ${parameters}    nsaDrbParam
    set to dictionary    ${nsaDrbParam}     dlDataSplitGainThreshold=${Actual_value}
    remove from dictionary    ${nsaDrbParam}    ulDataPathForUlSplitNotCapableUe
    ${nsaDrbParam_list}    create list   ${nsaDrbParam}
    ${dict}    create dictionary    parameterName=nsaDrbParam    operation=update    value=${nsaDrbParam_list}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDRB-${NRDRB}    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    COAM Teardown gnb connections

Change ActHoWoSnChg
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${BTS_ID}    ${LNBTS}    ${connection}=GNB_OAM
    Log To Console    Change ActHoWoSnChg
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actHoWoSnChg    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/LNBTS-${LNBTS}    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]   COAM Teardown gnb connections

Adjust HBTE Attenuation
    [Arguments]    ${port_value1}    ${port_value2}   ${port_value3}   ${port_value4}
    Log To Console    Adjust HBTE Attenuation
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_5}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation    port=${att_port_5}    value=${port_value1}
    att.set_attenuation    port=${att_port_6}    value=${port_value1}
    att.set_attenuation    port=${att_port_7}    value=${port_value2}
    att.set_attenuation    port=${att_port_8}    value=${port_value2}
    att.set_attenuation    port=${att_port_11}    value=${port_value3}
    att.set_attenuation    port=${att_port_12}    value=${port_value3}
    att.set_attenuation    port=${att_port_13}    value=${port_value4}
    att.set_attenuation    port=${att_port_14}    value=${port_value4}

Askey Attach
    Log To Console    Askey Attach
    Prepare Askey
    ${5Grach_ed}    inseego.UE Attach
    Log To Console    Verify attach
    inseego.Verify attach    5Grach_ed=${5Grach_ed}    4G_check=False

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
    run keyword if    '${reboot_ue}'=='${True}'    _Reboot_UE    connection=cpc_${ue_index}
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities[0]}

_Prepare Askey Variables
    [Arguments]  ${ue_index}=${0}
    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    set suite variable    ${cpc_ip}     ${ue_config['cpc_ip']}
    set suite variable    ${cpc_username}    ${ue_config['cpc_username']}
    set suite variable    ${cpc_password}    ${ue_config['cpc_password']}
    set suite variable    ${serial}    ${ue_config['serial_number']}
    set suite variable    ${capabilities}    ${ue_config['capabilities']}

Start UE Traffic
    [Arguments]    ${throughput}    ${ue_index}=${0}    ${connection}=cpc_${ue_index}
    Log To Console    Start UE Traffic
    ssh.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=${connection}
    ssh.send_command
    ...    command=adb shell iperf -u -t 1800 -i 1 -p ${IPERF_PORT}  -P 1 -f m -b 100M -l 1400B -T 64 -c ${IPERF_ADDR} &
    ...    connection=${connection}
    [Teardown]    ssh.disconnect    connection=${connection}

Stop UE Traffic
    [Arguments]    ${ue_index}=${0}    ${connection}=cpc_${ue_index}
    Log To Console    Stop UE Traffic
    ssh.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=${connection}
    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
    ...    command=ps -ef | grep adb | grep -v grep | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    [Teardown]    ssh.Disconnect	connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Catch Trace Log And Convert To Text
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${command}    ${pcap_filename}    ${txt_filename}    ${filter1}
    ...    ${throughput}    ${direction}
    Log To Console    Prepare UE
    power_ue.Prepare UE    ue_type=askey_sigspark    ue_index=${1}
    Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=${connection}     command=${command}
    Log To Console    UE Attach
    power_ue.UE Attach    ue_type=askey_sigspark    ue_index=${1}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=askey_sigspark    ue_index=${1}
    Log To Console    Start traffic
    power_ue.Start traffic    ue_type=askey_sigspark    direction=${direction}    throughput=${throughput}    ue_index=${1}   ue_mode=NSA
    ...     duration=300s
    Save TXT Log In UTE    connection=${connection}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}
    ...    filter1=${filter1}
    power_ue.Check throughput    ue_type=askey_sigspark    direction=${direction}    throughput=2    ue_index=${1}

Start Catch Trace Log
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${command}   ${time}=10s
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    ssh.send_command    command=${command}   connection=${connection}
    sleep    ${time}
    [Return]    ${connection}

Save TXT Log In UTE
    [Arguments]    ${connection}    ${pcap_filename}    ${txt_filename}    ${filter1}
    Stop And Copy Log To UTE    connection=${connection}    filename=${pcap_filename}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    comm_AIAC.Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    [Teardown]    ssh.disconnect    connection=UTE

Stop And Copy Log To UTE
    [Arguments]    ${connection}    ${filename}
    Log To Console    Stop And Copy Log To UTE
    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${LOG_PATH}/${filename}    connection=${connection}
    sleep    10s
    [Teardown]    ssh.disconnect    connection=${connection}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    Log To Console    Convert pcap to text
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

Grep newUE_Identity
    [Arguments]    ${txt_filename}    ${connection}
    ssh.send_command    command=cat ${LOG_PATH}/${txt_filename} |grep newUE-Identity: |tail -n 1|awk '{print $2}'
    ...    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=UTE
    [Return]    ${output}

Check eNB Attach Request
    [Arguments]    ${txt_filename}    ${BTS_ID}
    Log To Console    Check eNB Attach Request
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=cell-ID    connection=UTE
    ${cell-ID}    Evaluate    int(int('${output.split(":")[1].split("\n")[0]}', 16)/256)
    should be equal as numbers    ${cell-ID}    ${BTS_ID}
    [Teardown]    ssh.disconnect    connection=UTE

Check eNB Reject Signalling
    [Arguments]    ${pcap_filename}    ${txt_filename}
    Log To Console    Check eNB Reject Signalling
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${filter1}=    CATENATE  x2ap.procedureCode == 0
    comm_AIAC.Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    ${output1}    Grep Text Content    txt_filename=${txt_filename}    item=HandoverRequest   connection=UTE
    should not be empty    ${output1}
    ${filter2}=    CATENATE  x2ap.procedureCode == 27
    comm_AIAC.Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter2}"    connection=UTE
    ${output2}    Grep Text Content    txt_filename=${txt_filename}    item=SgNBAdditionRequest   connection=UTE
    should not be empty    ${output2}
    ${output3}    Grep Text Content    txt_filename=${txt_filename}    item=SgNBAdditionRequestReject   connection=UTE
    should not be empty    ${output3}
    [Teardown]    ssh.disconnect    connection=UTE

Check gNB RejectRequest
    [Arguments]    ${txt_filename}
    Log To Console    Check gNB RejectRequest
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=radioNetwork: unspecified    connection=UTE
    should not be empty    ${output}
    [Teardown]    ssh.disconnect    connection=UTE

Catch Attach Log
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${command}    ${direction}
    ...    ${throughput}    ${pcap_filename}    ${txt_filename}
    Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=${connection}     command=${command}    time=3s
    Log To Console    UE Attach
    power_ue.UE Attach    ue_type=askey_sigspark    ue_index=${1}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=askey_sigspark    ue_index=${1}
    Log To Console    Start traffic
    power_ue.Start traffic    ue_type=askey_sigspark    direction=${direction}    throughput=${throughput}    duration=300
    ...    ue_index=${1}   ue_mode=NSA
    ${filter1}=    CATENATE  s1ap.procedureCode == 12
    Save TXT Log In UTE    connection=${connection}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}
    ...    filter1=${filter1}

Save Handovered Attach Log And Analysis
    [Arguments]    ${connection}    ${pcap_filename}    ${txt_filename}
    Stop And Copy Log To UTE    connection=${connection}    filename=${pcap_filename}
    Check eNB Holdover Request    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}

Check eNB Holdover Request
    [Arguments]    ${pcap_filename}    ${txt_filename}
    Log To Console    Check eNB Holdover Request
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE
    ${filter1}=    CATENATE  x2ap.procedureCode == 0 && x2ap.radioNetwork == 0
    comm_AIAC.Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    ${output1}    Grep Text Content    txt_filename=${txt_filename}    item=HandoverRequest   connection=UTE
    ${output_ID1}    Grep newUE_Identity    txt_filename=${txt_filename}    connection=UTE
    should not be empty    ${output1}
    ${filter2}=    CATENATE  x2ap.procedureCode == 0 && x2ap.X2AP_PDU == 1 && x2ap.protocolIEs == 5
    comm_AIAC.Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter2}"    connection=UTE
    ${output2}    Grep Text Content    txt_filename=${txt_filename}    item=HandoverRequestAcknowledge    connection=UTE
    ${output_ID2}    Grep newUE_Identity    txt_filename=${txt_filename}    connection=UTE
    should not be empty    ${output2}
    should not be true    ${output_ID1.split('\n')[0]} == ${output_ID2.split('\n')[0]}
    ${filter3}=    CATENATE  x2ap.procedureCode == 28
    comm_AIAC.Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter3}"    connection=UTE
    ${output3}    Grep Text Content    txt_filename=${txt_filename}    item=SgNBReconfigurationComplete    connection=UTE
    should not be empty    ${output3}
    [Teardown]    ssh.disconnect    connection=UTE

Get peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for AIAC  gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${dl_zero_number}
    ...    Calculate Throughput and retrun results    data=${dl_traffic_data}    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    ${ul_zero_number}
    ...    Calculate Throughput and retrun results    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${dl_zero_number}
    ...    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    ${ul_zero_number}

Get traffic data from aasys log for AIAC
    [Documentation]    Get traffic data from aasys log with dl and ul direction.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param cell_id: grep by cell id if needed.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${cell_id}=${EMPTY}    ${log_name}=data_dl.txt
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${release_version}    Get gnb release in rrm for AIAC   host=${host}    username=${username}    password=${password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=sed 's/\\x00//g' -i /tmp/${log_name}    connection=ASIK_Master
    csn.Execute
    ...    command=cat /tmp/${log_name} |grep "DataPdu:" |grep "nrCellId" > /tmp/data.txt
    ...    connection=ASIK_Master
    csn.download_file   remote_path=/tmp/data.txt     local_path=${output_dir}/data.txt    connection=ASIK_Master
    ${dl_traffic_data}    analysis_dl_data_from_aasyslog     log_path=${output_dir}/data.txt
    ${ul_traffic_data}    csn.Execute    command=cat /tmp/${log_name} |grep "rlcPduBytes" |grep "${cell_id}" |awk '{print $10}'|cut -d '(' -f 2
    ...    connection=ASIK_Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
    [Return]    ${dl_traffic_data}    ${ul_traffic_data}

Get gnb release in rrm for AIAC
    [Arguments]   ${host}   ${username}   ${password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[4]}
    ${release_is_SBTS}     set variable    ${info.split('_')[1]}
    ${if_common_load}     run keyword and return status    should contain     ${release_is_SBTS}    SBTS
    ${release_info_result}    set variable if    ${if_common_load}    ${release_is_SBTS}      ${release_info}
    set suite variable    ${release_info_result}    ${release_info_result}
    [Return]    ${release_info_result}
    [Teardown]   csn.Disconnect   connection=release_info

Calculate Throughput and retrun results
    [Arguments]    ${data}=${dl_traffic_data}    ${cell_numbers}=1
    @{lines}    Split To Lines    ${data}
    ${count}    get length    ${lines}
    ${mod}    Evaluate    ${count}%${cell_numbers}
    ${lines}    Set Variable    ${lines[:int(${count}-${mod})]}
    ${count}    get length    ${lines}
    ${lines}    Evaluate    map(eval, ${lines})
    ${Throughput}    Create List
    FOR   ${i}    IN RANGE    0    ${count}    ${cell_numbers}
         ${total}    Evaluate    sum(${lines[${i}:${i}+${cell_numbers}]})
         Append To List    ${Throughput}    ${total}
    END
    ${count}    get length    ${Throughput}
    ${zero_number}    evaluate    ${Throughput}.count(${0})
    ${max}    Evaluate    max(${Throughput})
    ${min}    Evaluate    min(${Throughput})
    ${total}    Evaluate    sum(${lines})/${count}
    ${average_tp}=    Evaluate    round((${total}*8/1024/1024.0), 3)
    ${minimum_tp}=    Evaluate    round((${min}*8/1024/1024.0), 3)
    ${peak_tp}=    Evaluate    round((${max}*8/1024/1024.0), 3)
    [Return]    ${peak_tp}    ${average_tp}    ${minimum_tp}    ${zero_number}

Connect to emil server
    [Arguments]   ${telnet}=${true}
    Log To Console    Connect to emil server
    ${cpc_status}    run keyword and return status    Wait Until Keyword Succeeds    5min    20s
    ...   ssh.Connect to   hostname=${cpc_ip}    username=${cpc_usrname}    password=${cpc_passwd}    alias=emil_server
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...               reset cpc sshd services    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...               ssh.Connect to   hostname=${cpc_ip}    username=${cpc_usrname}    password=${cpc_passwd}    alias=emil_server

Collect 4G Log Collect by EMIL
    [Arguments]    ${ue_index}=${0}    ${emil_exe_path}=${EMIL_EXE_PATH}    ${sack_path}=${SACK_PATH}    ${profile_path}=${PROFILE_PATH}
    ...    ${duration_time}=${200}
    Connect to emil server
    Log To Console    Collect 4G Log Collect by EMIL
    run keyword and ignore error    ssh.Execute    command=rm -rf /cygdrive/c/temp/*Ltput.csv    connection=emil_server
    ${command}    set variable     ${emil_exe_path} -SackPath ${sack_path} -ProfilePath ${profile_path} &
    Log To Console    ${command}
    ${result}   ssh.send_command  command=${command}  connection=emil_server     timeout=200
    ${4g_wait_to_stop_monitoring}    evaluate    ${duration_time}+300
    sleep    ${4g_wait_to_stop_monitoring}
    [Teardown]    Run keyword and ignore error    ssh.disconnect    connection=emil_server

Check 4G Throughput Logs Exist
    Connect to emil server
    Log To Console    Check 4G Throughput Logs Exist
    sleep    200s
    ${dl_log_empty}    is file empty    file_path=/cygdrive/c/temp/DLtput.csv    connection=emil_server
    ${ul_log_empty}    is file empty    file_path=/cygdrive/c/temp/ULtput.csv    connection=emil_server
    ${are_4g_tput_file_generated_successfully}    set variable if    ${dl_log_empty}==${True} or ${ul_log_empty}==${True}    ${False}    ${True}
    should be true    ${are_4g_tput_file_generated_successfully}==${True}
    [Teardown]    Run keyword and ignore error    ssh.disconnect    connection=emil_server
    [Return]    ${are_4g_tput_file_generated_successfully}

Download And Analysis 4G Throughput
    Download 4G throughput
    Log To Console    Download And Analysis 4G Throughput
    ${dl_tput}    get_dl_throughput_for_each_cell    tput_file=${LOG_PATH}/DLtput.csv
    ${ul_tput}    get_ul_throughput_for_each_cell    tput_file=${LOG_PATH}/ULtput.csv
    ${4g_dl_average_tp}    set variable    ${dl_tput['cell1_average_tp']}
    ${4g_ul_average_tp}    set variable    ${ul_tput['cell1_average_tp']}
    should be true    ${4g_dl_average_tp} > ${0}
    should be true    ${4g_ul_average_tp} > ${0}

Download 4G throughput
    Connect to emil server
    Log To Console   downloading 4G throughput log file...
    @{4g_tput_list}    create list    /cygdrive/c/temp/DLtput.csv    /cygdrive/c/temp/ULtput.csv
    ssh.download file
    ...   remote_path=${4g_tput_list}
    ...   local_path=${LOG_PATH}
    ...   connection=emil_server
    Run keyword and continue on failure    ssh.execute    command=rm -rf /cygdrive/c/temp/*Ltput.csv    connection=emil_server
    [Teardown]  Run keyword and ignore error    ssh.disconnect    connection=emil_server

Case UE detach And Teardown
    Log To Console    UE Detach
    run keyword and ignore error     COAM Teardown gnb connections
    run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${1}
    CI_interface.Common Case Teardown
