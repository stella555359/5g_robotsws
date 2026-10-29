*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.ue                       WITH NAME    ute_ue
Library    taf.hw.rf_attenuator           WITH NAME    att
#Library    ../python/ue.py
Library    ../../../../TRS/RAN_PZ_HAZ_34/5GC002236_FA/resources/trans/translib.py
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
${DU_OAM_SSH_USERNAME}
${DU_OAM_SSH_PASSWORD}
${DU_OAM_WEBUI_URL}
${DU_OAM_WEBUI_USER}
${DU_OAM_WEBUI_PASSWORD}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.enbs[0].instance_id}
${BTS_ID2}    ${tl.enbs[1].instance_id}
${att_ipaddr}    ${tl.attenuator.ip_addr}
${att_api_port}    ${tl.attenuator.port}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_5}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_6}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${NRDRB_A-Number}    NRDRB_A-4
${NRBTS}    ${tl.gnbs[0].global_bts_id}
${NRDRB}    ${4}
${vendor}    HBTE
${max_attenuation_value}    ${127}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_PORT}    ${tl.appserver.iperf_details.port}
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${ue_type}    ${tl.ues[0].capabilities[1]}

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
    ...   Set Variable   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Set Suite Variable   ${DU_OAM_IP}
    ${result}  ${DU_OAM_SSH_USERNAME}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    Set Suite Variable   ${DU_OAM_SSH_USERNAME}
    ${result}  ${DU_OAM_SSH_PASSWORD}    Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Set Suite Variable   ${DU_OAM_SSH_PASSWORD}
    ${result}  ${DU_OAM_WEBUI_URL}        Run Keyword And Ignore Error
    ...   Set Variable  https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
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
    Should be equal as strings    ${operationalState}      Enabled      ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${tmp}    Enabled    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Wait until Enb cell on air
    [Timeout]  20 min
    [Arguments]    ${connection}    ${timeout}=10 min
    wait until keyword succeeds    ${timeout}    20 sec    Check Enb status is in cell on air    enb_alias=${connection}

Check Enb status is in cell on air
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
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID2}/NRBTS-${NRBTS}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change actDlDataForwardingX2
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}
    Log To Console    Change actDlDataForwardingX2
    Rest Login DU    ip_address=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actDlDataForwardingX2    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID2}/NRBTS-${NRBTS}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change ULData
    [Arguments]    ${DU_OAM_IP}    ${Actual_value1}    ${Actual_value2}
    Log To Console    Change ULData
    Rest Login DU    ip_address=${DU_OAM_IP}
    ${object_list}    coam.get_managed_objects    class_name=NRDRB_A
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
    remove from dictionary    ${nsaDrbParam}    inactPeriodX2PdcpDuplication
    remove from dictionary    ${nsaDrbParam}    reTxPrioritizationType
    ${nsaDrbParam_list}    create list   ${nsaDrbParam}
    ${dict}    create dictionary    parameterName=nsaDrbParam    operation=update    value=${nsaDrbParam_list}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID2}/NRBTS-${NRBTS}/NRDRB-${NRDRB}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change DLData SplitMode
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}
    Log To Console    Change DLData SplitMode
    Rest Login DU    ip_address=${DU_OAM_IP}
    ${object_list}    coam.get_managed_objects    class_name=NRDRB_A
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
    remove from dictionary    ${nsaDrbParam}    inactPeriodX2PdcpDuplication
    remove from dictionary    ${nsaDrbParam}    reTxPrioritizationType
    ${nsaDrbParam_list}    create list   ${nsaDrbParam}
    ${dict}    create dictionary    parameterName=nsaDrbParam    operation=update    value=${nsaDrbParam_list}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID2}/NRBTS-${NRBTS}/NRDRB-${NRDRB}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change DLData GainThreshold
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}
    Log To Console    Change DLData GainThreshold
    Rest Login DU    ip_address=${DU_OAM_IP}
    ${object_list}    coam.get_managed_objects    class_name=NRDRB_A
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
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDRB-${NRDRB}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Change ActHoWoSnChg
    [Arguments]    ${DU_OAM_IP}    ${Actual_value}    ${BTS_ID}    ${LNBTS}
    Log To Console    Change ActHoWoSnChg
    ${connection}    Rest Login DU    ip_address=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=actHoWoSnChg    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/LNBTS-${LNBTS}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait until Enb cell on air    connection=${connection}
    [Teardown]    Rest Logout DU

Adjust HBTE Attenuation
    [Arguments]    ${port_value1}    ${port_value2}   ${port_value3}   ${port_value4}
    Log To Console    Adjust HBTE Attenuation
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_5}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation    port=${att_port_1}    value=${port_value1}
    att.set_attenuation    port=${att_port_2}    value=${port_value1}
    att.set_attenuation    port=${att_port_5}    value=${port_value3}
    att.set_attenuation    port=${att_port_6}    value=${port_value3}
    att.set_attenuation    port=${att_port_11}    value=${port_value4}
    att.set_attenuation    port=${att_port_12}    value=${port_value4}

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
    ...    command=adb shell iperf -u -t 1800 -i 1 -p ${IPERF_PORT} -P 1 -f m -b 100M -l 1400B -T 64 -c ${IPERF_ADDR} &
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
    power_ue.Prepare UE    ue_type=${ue_type}
    Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=${connection}     command=${command}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    Start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}    throughput=${throughput}    ue_mode=NSA
    Save TXT Log In UTE    connection=${connection}    pcap_filename=${pcap_filename}    txt_filename=${txt_filename}
    ...    filter1=${filter1}
    power_ue.Check throughput    ue_type=${ue_type}    direction=${direction}    throughput=2

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
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    ${output1}    Grep Text Content    txt_filename=${txt_filename}    item=HandoverRequest   connection=UTE
    should not be empty    ${output1}
    ${filter2}=    CATENATE  x2ap.procedureCode == 27
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
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
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    Start traffic
    wait until keyword succeeds    10min    10s    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}
    ...    throughput=${throughput}    duration=3000    ue_mode=NSA
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
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter1}"    connection=UTE
    ${output1}    Grep Text Content    txt_filename=${txt_filename}    item=HandoverRequest   connection=UTE
    ${output_ID1}    Grep newUE_Identity    txt_filename=${txt_filename}    connection=UTE
    should not be empty    ${output1}
    ${filter2}=    CATENATE  x2ap.procedureCode == 0 && x2ap.X2AP_PDU == 1
    Convert pcap to text    source=${LOG_PATH}/${pcap_filename}
    ...  target=${LOG_PATH}/${txt_filename}    filter="${filter2}"    connection=UTE
    ${output2}    Grep Text Content    txt_filename=${txt_filename}    item=HandoverRequestAcknowledge    connection=UTE
    ${output_ID2}    Grep newUE_Identity    txt_filename=${txt_filename}    connection=UTE
    should not be empty    ${output2}
    should not be equal as strings    ${output_ID1.split('\n')[0]}    ${output_ID2.split('\n')[0]}
    [Teardown]    ssh.disconnect    connection=UTE

Get peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${dl_zero_number}
    ...    Calculate Throughput and retrun results    data=${dl_traffic_data}    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    ${ul_zero_number}
    ...    Calculate Throughput and retrun results    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${dl_zero_number}
    ...    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    ${ul_zero_number}

Calculate Throughput and retrun results
    [Arguments]    ${data}=${dl_traffic_data}    ${cell_numbers}=1
    @{lines}    Split To Lines    ${data}
    ${count}    get length    ${lines}
    ${mod}    Evaluate    ${count}%${cell_numbers}
    ${lines}    Set Variable    ${lines[:int(${count}-${mod})]}
    ${count}    get length    ${lines}
    ${lines}    Evaluate    list(map(eval, ${lines}))
    ${Throughput}    Create List
    FOR    ${i}    IN RANGE    0    ${count}    ${cell_numbers}
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

Case UE detach And Teardown
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
    CI_interface.Common Case Teardown
