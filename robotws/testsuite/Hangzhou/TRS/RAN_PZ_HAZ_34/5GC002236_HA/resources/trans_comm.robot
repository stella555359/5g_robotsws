*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam
Library    ../../5GC002236_FA/resources/trans/translib.py
#Library    taf.analyzer.pcap    WITH NAME    cap
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Library    random
Library    ./HAkeywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.password}
${DU_OAM_WEBUI_URL}
${DU_OAM_WEBUI_USER}
${DU_OAM_WEBUI_PASSWORD}
${UTE_ADDRESS}
${UTE_USERNAME}
${UTE_PASSWORD}
${CU_OAM_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${TRANS_PARA}                   ${NONE}
${LMP_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_OAM_INTERFACE}    fp0
${VLAN_ID}    ${tl.gnbs[0].cu.f1u.vlan_id}
${VLANIF_ID}    ${tl.gnbs[0].cu.f1u.vlan_id}
${VLAN_IP}    192.168.204.100
${VLANIP_PRELENGTH}    24
${TESTCENTER_IP}    192.168.204.127
${Ethernet}    Ethernet
${BTS_ID}    ${tl.gnbs[0].global_bts_id}
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
${IPIF_ID}    3
${IP_Mtu}    9200
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}

*** Keywords ***
TRANS Common Setup
    [Documentation]  TRANS Common Setup
    Set Library Search Order   trans_comm
    TRANS Test Common Setup
    _Install Packages
    Run Keyword And Ignore Error    _Init_Global_Variable
    Run Keyword And Ignore Error   _Init_BTS_Info_Variable

TRANS Common Teardown
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
    ...   Set Variable   ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}
    Set Suite Variable   ${DU_OAM_IP}
    ${result}  ${DU_OAM_SSH_USERNAME}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    Set Suite Variable   ${DU_OAM_SSH_USERNAME}
    ${result}  ${DU_OAM_SSH_PASSWORD}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Set Suite Variable   ${DU_OAM_SSH_PASSWORD}
    ${result}  ${DU_OAM_WEBUI_URL}        Run Keyword And Ignore Error
    ...   Set Variable  https://${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}/
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
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
    should be equal as strings    ${tmp}    Online    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  blockingState
    should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  usageState
    should be equal as strings    ${tmp}    Active    ignore_case=${True}

Setup Commission SCF
    ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    COAM Commission with scf file    scf_file_path=${default_scf}
    Wait Until Keyword Succeeds   16min   2min   Check cell on air

Check cell on air
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses       connection=GNB_OAM
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir
    coam.teardown    connection=GNB_OAM

Get BTS Version And Perare SCF
    [Arguments]    ${CURDIR_path}
    ${connection}    coam.connect_to    bts_host=${DU_OAM_IP}     name=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check add vlan ID like 0 or 4095 fail
    Log To Console   Check add vlan ID like 0 or 4095 fail
    ${connection}    Rest Login DU
    ${dict_vlanif0}    create dictionary    parameterName=vlanIfId    operation=update    value=${VLANIF_ID}
    ${dict_vlan0}    create dictionary    parameterName=vlanId    operation=update    value=0
    ${list1}    create list    ${dict_vlanif0}    ${dict_vlan0}
    ${dict_vlanif4095}    create dictionary    parameterName=vlanIfId    operation=update    value=${VLANIF_ID}
    ${dict_vlan4095}    create dictionary    parameterName=vlanId    operation=update    value=4095
    ${list2}    create list    ${dict_vlanif4095}    ${dict_vlan4095}
    run keyword and expect error    *VALUE_IS_TOO_SMALL*    coam.perform_object_recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${VLANIF_ID}
    ...    parameter=${list1}    operation=create
    ...    skip_parameter_relation_errors=${True}    should_activate=${False}    connection=${connection}
    run keyword and expect error    *VALUE_IS_TOO_BIG*    coam.perform_object_recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${VLANIF_ID}
    ...    parameter=${list2}    operation=create
    ...    skip_parameter_relation_errors=${True}    should_activate=${False}    connection=${connection}
    [Teardown]    Rest Logout DU

Add vlan in WEB success
    Log To Console    add vlan in WEB success
    Rest Login DU
    ${dict_vlanif}    create dictionary    parameterName=vlanIfId    operation=update    value=${VLANIF_ID}
    ${dict_vlan}    create dictionary    parameterName=vlanId    operation=update    value=${VLAN_ID}
    ${list3}    create list    ${dict_vlanif}    ${dict_vlan}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${VLANIF_ID}
    ...    parameter=${list3}    operation=create     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Add vlan IP
    Log To Console    add vlan IP
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    command=ip address add ${VLAN_IP}/${VLANIP_PRELENGTH} dev ${DU_OAM_INTERFACE}.${VLAN_ID}    connection=VM
    sleep    2s
    ssh.send_command    command=ip a   connection=VM
    ${output}    ssh.read output    connection=VM
    should contain    ${output}    ${DU_OAM_INTERFACE}.${VLAN_ID}
    should contain    ${output}    ${VLAN_IP}
    [Teardown]    ssh.disconnect    connection=VM

Login Testcenter
    Log To Console    Login Testcenter
    [Arguments]    ${File_Name}
    ${connection}    Connect to UTE
    csn.Send Command  command=sudo tclsh ${CURDIR}/${File_Name} &    connection=${connection}
    sleep    5s
    [Teardown]    Csn.Disconnect	connection=${connection}

Logout Testcenter
    Log To Console    Logout Testcenter
    ${connection}    Connect to UTE
    ${PID}  csn.Execute  command=ps -ef |grep TestCenter|awk '{print $2}'|head -n 1
    ...    connection=${connection}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=sudo kill -9 ${PID}    connection=${connection}
    [Teardown]    Csn.Disconnect	connection=${connection}

Ping
    [Documentation]    ping ip address from A To B
    [Arguments]    ${hostname}    ${username}    ${password}    ${desIP}    ${time}
    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=VM
    sleep    2s
    ssh.send_command    command=ping ${desIP} -c 5 -i 2    connection=VM
    sleep    ${time}
    ${output_log_0}    ssh.read output    connection=VM
    [Teardown]    ssh.disconnect    connection=VM
    [Return]  ${output_log_0}

Wireshark contain vlan tag
    Log To Console    Capture Wireshark Log And Download
    Capture Wireshark Vlan Log And Download     filename=testcase1.pcap    time=8s    listen_port=${Ethernet}
    Log To Console    Convert pcap to text And Get txt Content
    Convert pcap to text And Get txt Content   pacp_filename=testcase1.pcap    txt_filename=testcase1.txt

Capture Wireshark Vlan Log And Download
    [Arguments]    ${filename}    ${time}    ${listen_port}
    Connect to control pc via cygwin
    Start to Capture DU_EIF1 Log on Control PC    filename=${filename}   connection=cygwin   listen_port=${listen_port}   time=${time}
    Ping     hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    desIP=${TESTCENTER_IP}    time=5s
    Stop and Download Log    filename=${filename}    connection=cygwin   LOG_PATH=${LOG_PATH}

Connect to control pc via cygwin
    [Arguments]    ${ue_index}=${1}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${alias}=cygwin
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=${alias}

Start to Capture DU_EIF1 Log on Control PC
    [Arguments]    ${filename}    ${connection}    ${listen_port}    ${time}
    csn.send command    command=tshark -i ${listen_port} -w ${filename}  connection=${connection}
    sleep    ${time}

Stop and Download Log
    [Arguments]    ${filename}    ${connection}    ${LOG_PATH}
    ${PID}    wait until keyword succeeds    1min    2s    Get PID
    csn.Execute    command=kill -9 ${PID}    connection=${connection}
    csn.download_file    remote_path=/home/nokia5G/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${connection}
    sleep    2s
    csn.send command    command=rm /home/nokia5G/${filename}    connection=${connection}
    [Teardown]    Csn.Disconnect	connection=${connection}

Get PID
    [Arguments]      ${connection}=cygwin
    ${PID}  csn.Execute  command=ps -ef |grep shark|awk '{{print $2}}'|head -n 1
    ...    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Convert pcap to text And Get txt Content
    [Arguments]      ${pacp_filename}  ${txt_filename}    ${expect_result}=True
    ${connection}    Connect to UTE
    ${filter1}=    CATENATE  ip.src ==  ${VLAN_IP}
    Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   filter="${filter1}"  connection=${connection}
    ${result}    Get_txt_file_content    ${LOG_PATH}/${txt_filename}    802.1Q    ${VLAN_ID}
    should be equal as strings    ${result}    ${expect_result}
    [Teardown]    csn.Disconnect	  connection=${connection}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    ssh.send_command
    ...    command=tshark -X lua_script:${luashark_path} -V -r ${source} -T text -Y ${filter} > ${target}
    ...  connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Connect to UTE
    [Arguments]  ${hostname}=${UTE_ADDRESS}    ${username}=${UTE_USERNAME}    ${password}=${UTE_PASSWORD}
    ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=UTE
    [Return]   ${connection}

Delete vlan
    [Arguments]    ${BTS_ID}    ${VLANIF_ID}
    ${empty_list}    create list
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${VLANIF_ID}
    ...    parameter=${empty_list}    operation=delete     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
	
Delete IPIF
    [Arguments]    ${BTS_ID}    ${IPIF_ID}
    ${empty_list}    create list
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${IPIF_ID}
    ...    parameter=${empty_list}    operation=delete     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal

Wireshark contain no vlan tag
    Log To Console    Capture Wireshark Log And Download
    Capture Wireshark Ethernet Log And Download     filename=testcase2.pcap    time=8s    listen_port=${Ethernet}
    Log To Console    Convert pcap to text And Get txt Content
    Convert pcap to text And Get txt Content    pacp_filename=testcase2.pcap    txt_filename=testcase2.txt    expect_result=False

Capture Wireshark Ethernet Log And Download
    [Arguments]    ${filename}    ${time}    ${listen_port}
    Connect to control pc via cygwin
    Start to Capture DU_EIF1 Log on Control PC    filename=${filename}   connection=cygwin   listen_port=${listen_port}   time=${time}
    Ping     hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    desIP=${CU_OAM_IP}    time=5s
    Stop and Download Log    filename=${filename}    connection=cygwin   LOG_PATH=${LOG_PATH}

Reset DU and wait until BTS be normal
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
    sleep    2s
    Log To Console    Reboot DU
    ssh.send_command    command=reboot    connection=VM
    sleep    600s
    Rest Login DU
    Wait Until BTS Should Be Normal
    Add vlan IP

Wireshark contain vlan tag again
    Log To Console    Capture Wireshark Log And Download
    Capture Wireshark Vlan Log And Download     filename=testcase3.pcap    time=8s    listen_port=${Ethernet}
    Log To Console    Convert pcap to text And Get txt Content
    Convert pcap to text And Get txt Content   pacp_filename=testcase3.pcap    txt_filename=testcase3.txt

Add new IPIF success
    [Arguments]    ${BTS_ID}    ${VLANIF_ID}    ${IP_Mtu}
    Log To Console    Add new IPIF success
    Rest Login DU
    ${dict_DN}    create dictionary    parameterName=interfaceDN    operation=update
    ...    value=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${VLANIF_ID}
    ${dict_IPIFid}    create dictionary    parameterName=ipIfId    operation=update    value=${IPIF_ID}
    ${dict_Mtu}    create dictionary    parameterName=ipMtu    operation=update    value=${IP_Mtu}
    ${list4}    create list    ${dict_DN}    ${dict_IPIFid}    ${dict_Mtu}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${IPIF_ID}
    ...    parameter=${list4}    operation=create     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Add IPADDRESS4 success
    [Arguments]    ${BTS_ID}    ${VLAN_ID}    ${IPIF_ID}    ${VLANIP_PRELENGTH}
    Log To Console    Add IPADDRESS4 success
    Rest Login DU
    ${dict_Method}    create dictionary    parameterName=ipAddressAllocationMethod    operation=update    value=MANUAL
    ${dict_IPV4id}    create dictionary    parameterName=ipAddressV4Id    operation=update    value=1
    ${dict_Addr}    create dictionary    parameterName=localIpAddr    operation=update    value=${VLAN_IP}
    ${dict_PreLen}    create dictionary    parameterName=localIpPrefixLength    operation=update    value=${VLANIP_PRELENGTH}
    ${list5}    create list    ${dict_Method}    ${dict_IPV4id}    ${dict_Addr}    ${dict_PreLen}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${IPIF_ID}/IPADDRESSV4-1
    ...    parameter=${list5}    operation=create     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Check add DSCP2PCPMAP Success
    [Arguments]    ${BTS_ID}
    Log To Console    Check add DSCP2PCPMAP Success
    WEBUI Login
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/QOS-1    object_class_name=DSCP2PCPMAP
    ...     is_load_default_values=${True}
    selenium_coam.validate_plan    timeout=10
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    Du Check cell on air via WebUI without login
    [Teardown]    WEBUI Logout

Convert pcap to text And Get Vlan_priority DSCP Value
    [Arguments]      ${pacp_filename}  ${txt_filename}
    ${connection}    Connect to UTE
    ${filter1}=    CATENATE  ip.src ==  ${VLAN_IP}
    Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   filter="${filter1}"  connection=${connection}
    ${vlanpri_list}    ${DSCP_list}    get_piority_dscp_content    file_path=${LOG_PATH}/${txt_filename}
    [Return]    ${vlanpri_list}    ${DSCP_list}
    [Teardown]    csn.Disconnect	  connection=${connection}

Modify Vlan priority value
    [Arguments]    ${Pri_value}    ${DSCP_list}
    Log To Console    Modify Vlan priority value
    Rest Login DU
    ${value_list}    create list    0    1    2    3    4    5    6    7
    remove values from list    ${value_list}    ${Pri_value}
    ${lenght}    get length    ${value_list}
    ${newdscp_value}   evaluate   random.randint(0,${lenght}-1)    random
    ${DSCP_value}    set variable    ${DSCP_list}[0]
    ${dict}    create dictionary    parameterName=vlanPrioForDscp0${DSCP_value}    operation=update    value=${newdscp_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/QOS-1/DSCP2PCPMAP-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU
    [Return]    ${newdscp_value}

Get New Vlan_priority Vlaue
    [Arguments]    ${pacp_filename}    ${txt_filename}
    Log To Console    Get New Vlan_priority Vlaue
    ${vlanpri_list2}    ${DSCP_list2}    Convert pcap to text And Get Vlan_priority DSCP Value   pacp_filename=${pacp_filename}
    ...    txt_filename=${txt_filename}
    ${Pri_value2}    set variable    ${vlanpri_list2}[0]
    [Return]    ${Pri_value2}
