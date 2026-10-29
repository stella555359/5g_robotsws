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
Library    taf.pdu                      WITH NAME    pdu
Library    ../../5GC002236_FA/resources/trans/translib.py
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${DU_OAM_IP}
${DU_OAM_SSH_USERNAME}
${DU_OAM_SSH_PASSWORD}
${DU_OAM_WEBUI_URL}
${DU_OAM_WEBUI_USER}
${DU_OAM_WEBUI_PASSWORD}
${UTE_ADDRESS}
${UTE_USERNAME}
${UTE_PASSWORD}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${DU_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${DU_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.port_numbers}
${PDU_MODEL}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}

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
    ...   Set Variable   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
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
    Run Keyword If     ${virtual_enable}     Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
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
    Should Be Equal    ${operationalState}    Enabled
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${tmp}    Enabled
    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
    Should Be Equal    ${tmp}    Online
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Add And Change Sync Input Type
    [Arguments]    ${synctype1}    ${synctype2}
    Log To Console    Add And Change Sync Input Type
    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
    ${parameter}    get from dictionary     ${object_list}[0]    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    ${structure2}    create dictionary     syncInputPrio=2    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Log To Console    sleep 5min
    sleep    5min
    [Teardown]    Rest Logout DU

Delete And Change Sync Input Type
    [Arguments]    ${synctype}
    Log To Console    Delete And Change Sync Input Type
    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
    ${parameter}    get from dictionary     ${object_list}[0]    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    remove from list    ${syncInputList}    1
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    30s
    [Teardown]    Rest Logout DU

Change Sync Input Priority
    [Arguments]    ${syncInputPrio1}    ${syncInputPrio2}
    Log To Console    Change Sync Input Priority
    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
    ${parameter}    get from dictionary     ${object_list}[0]    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${syncInputPrio1}
    set to dictionary    ${syncInputList}[1]     syncInputPrio=${syncInputPrio2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    30s
    [Teardown]    Rest Logout DU

Check Syncs Status
    [Arguments]    ${expect_syncInputType1}    ${expect_syncInputType2}
    ...    ${expect_isActive1}    ${expect_isActive2}
    ...    ${expect_availability1}    ${expect_availability2}
    ...    ${expect_usability1}    ${expect_usability2}    ${expect_tuningMode}
    Log To Console    Check Sync Status
    ${connection}    Rest Login DU
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=${connection}
    Log To Console    Check syncMode
    ${bts_syncMode}    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    Check SyncSourceInfo Status    bts_sync_status=${bts_sync_status}    SN=${0}    expect_syncInputPrio=${1}
    ...    expect_syncInputType=${expect_syncInputType1}    expect_isActive=${expect_isActive1}
    ...    expect_availability=${expect_availability1}    expect_usability=${expect_usability1}
    Check SyncSourceInfo Status    bts_sync_status=${bts_sync_status}    SN=${1}    expect_syncInputPrio=${2}
    ...    expect_syncInputType=${expect_syncInputType2}    expect_isActive=${expect_isActive2}
    ...    expect_availability=${expect_availability2}    expect_usability=${expect_usability2}
    Log To Console    Check tuningMode
    ${tuningMode}    Get From Dictionary    ${bts_sync_status}    tuningMode
    should be equal    ${tuningMode}    ${expect_tuningMode}
    [Teardown]    Rest Logout DU

Check SyncSourceInfo Status
    [Arguments]    ${bts_sync_status}    ${SN}    ${expect_syncInputPrio}    ${expect_syncInputType}
    ...    ${expect_isActive}    ${expect_availability}    ${expect_usability}
    Log To Console    Check syncSourceInfo
    ${syncSourceInfo}    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${isActive}    Get From Dictionary    ${syncSourceInfo}[${SN}]    isActive
    should be equal    ${isActive}    ${expect_isActive}
    ${status}    Get From Dictionary    ${syncSourceInfo}[${SN}]    status
    ${availability}    Get From Dictionary    ${status}    availability
    should be equal    ${availability}    ${expect_availability}
    ${usability}    Get From Dictionary    ${status}    usability
    should be equal    ${usability}    ${expect_usability}
    ${syncInputPrio}    Get From Dictionary    ${syncSourceInfo}[${SN}]    syncInputPrio
    should be equal    ${syncInputPrio}    ${expect_syncInputPrio}
    ${syncInputType}    Get From Dictionary    ${syncSourceInfo}[${SN}]    syncInputType
    should be equal    ${syncInputType}    ${expect_syncInputType}

Power Off DU And Wait Until DU Up
    Log To Console    Power Off DU
    pdu.setup_pdu    model=${PDU_MODEL}    host=${DU_PDU_IP}    alias=pdu
    pdu.power_off    port=${DU_PDU_PORT}[0]    pdu_device=pdu
    sleep    10s
    Log To Console    Power On DU
    pdu.power_on    port=${DU_PDU_PORT}[0]    pdu_device=pdu
    Log To Console    wait until login DU
    wait until keyword succeeds    5min    200ms    Rest Login DU
    [Teardown]    Rest Logout DU

Check GNSS Fisrt Recovery And TOPP Second Recovery
    Log To Console   Check GNSS Fisrt Recovery
    Rest Login DU
    wait until keyword succeeds    3min    50ms    Check Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver
    ...    expect_syncInputType2=TOPP
    ...    expect_isActive1=${True}    expect_isActive2=${False}    expect_availability1=Available   expect_availability2=Unavailable
    ...    expect_usability1=Usable    expect_usability2=Usable    expect_tuningMode=Fast tuning
    Log To Console   Check TOPP Second Recovery
    wait until keyword succeeds    5min    200ms    Check Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver
    ...    expect_syncInputType2=TOPP
    ...    expect_isActive1=${True}    expect_isActive2=${False}    expect_availability1=Available   expect_availability2=Available
    ...    expect_usability1=Usable    expect_usability2=Usable    expect_tuningMode=Normal tuning
    [Teardown]    Rest Logout DU
