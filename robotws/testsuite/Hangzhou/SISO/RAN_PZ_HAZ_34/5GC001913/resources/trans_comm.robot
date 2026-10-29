*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam_rest
Library     ../../../../TRS/RAN_PZ_HAZ_34/5GC002236_LA/resources/trans/translib.py      WITH NAME    translib


Library     String
Library     Collections
Library     OperatingSystem
Library     Process
Library     XML
Library     DateTime
Library     Telnet

Library    Collections
Library    ArchiveLibrary
Library    taf.pdu       WITH NAME    pdu
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

Library           ../../5GC001278/Library/get_bts_info.py    WITH NAME    lib
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           XML   WITH NAME    ParseXML
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.collectors.snapshot      WITH NAME    snapshot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot


*** Variables ***
######## testline related value ############
${DU_OAM_IP}
${DU_OAM_SSH_USERNAME}
${DU_OAM_SSH_PASSWORD}
${DU_OAM_WEBUI_URL}
${DU_OAM_WEBUI_USER}
${DU_OAM_WEBUI_PASSWORD}
${UTE_ADDRESS}
${UTE_USERNAME}
${UTE_PASSWORD}
${TRANS_PARA}                   ${NONE}
${LMP_IP}
${pb_model_ru}                ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.__class__.__name__}
${alarm_filter_1}           No connection to unit
${DU_OAM_INTERFACE}    fp0
${BTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
TRANS Common Setup
    [Documentation]  TRANS Common Setup
    Set Library Search Order   trans_comm
    TRANS Test Common Setup
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

    ${result}  ${LMP_IP}        Run Keyword And Ignore Error
    ...   Set Variable  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Set Suite Variable   ${LMP_IP}

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

    coam_rest.Get_Current_Scf_File  local_dir_path=${SCF_BACKUP_DIR}   file_name=scf_backup.xml   timeout=60
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
    ${active_alarm_info}    coam_rest.Get_Active_Alarms   connection=${alias}
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
    ${active_alarm_info}    coam_rest.Get_Historic_Alarms  connection=${alias}   timeout=60
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
    coam_rest.Get_Current_Scf_File  local_dir_path=${scf_dir}    file_name=${scf_file}  connection=${alias}
    [Return]  ${scf_file}

Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}   coam_rest.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam_rest.Teardown  connection=${alias}

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
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    COAM Check GNB cell on air

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam_rest.Get_Bts_Statuses   connection=${alias}

    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${operationalState}    Enabled

    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked

    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir

    #cell info
    ${cell_status}     coam_rest.Get_Cells_Info   cell_type=${cell_type}

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

Ping
    [Documentation]    ping ip address from UTE to DU LMP
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    command=ping ${LMP_IP} -c 5 -i 2    connection=VM
    sleep    3s
    ${output_log_0}    ssh.read output    connection=VM
    ssh.disconnect    connection=VM
    [Return]  ${output_log_0}

Change Ethernet port security enabled to true
    Log To Console     Change Ethernet port security enabled to true
    WEBUI Login
    coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    filter_param=Ethernet port security enabled    abbr=ethernetPortSecurityEnabled    new_value=true
    coam.validate_plan    timeout=30
    coam.activate_plan    activate_plan_despite_errors=true
    sleep    30s
    WEBUI Logout

Change Activate service account SSH to false
    Log To Console     Change Activate service account SSH to false
    WEBUI Login
    coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    filter_param=Activate service account SSH    abbr=actServiceAccountSsh    new_value=false
    coam.validate_plan    timeout=30
    coam.activate_plan    activate_plan_despite_errors=true
    sleep    30s
    WEBUI Logout

SSH connect sucess
   [Documentation]    SSH connect sucess
   ssh.Connect to     hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
   ...   password=${UTE_PASSWORD}    alias=VM

SSH connect fail
   [Documentation]    SSH connect fail
   run keyword and expect error    *    ssh.Connect to     hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
   ...   password=${UTE_PASSWORD}    alias=VM

Check ASOD is UP
   ##### run keyword and ignore error    WEBUI Logout
    run keyword and ignore error    WEBUI Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
#    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
#    ${output_tmp}    set variable    &{output}[Runtime parameters]
#    ${P_name_smod}    set variable    &{output_tmp}[Product name]
#    run keyword if    '${P_name_smod}' == 'ASOD AirScale Common'    Check ASOD State

Check RU Alarm Info
    Wait Until Keyword Succeeds    15min    10s    Check Alarm Info     #alarm_filter=${alarm_filter_1}

Check Alarm Info
#    [Arguments]    ${alarm_filter}
    @{alarms}    selenium_coam.get_active_alarm_info    timeout=${100}    #alarm_filter=${alarm_filter}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    Fault ID
        ${fault_name}    get from dictionary    ${item}    Fault name
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    list should contain value     ${fault_id_list}    10
    list should contain value     ${fault_name_list}    No connection to unit
    #${alarms_string}=    Convert To String    ${alarms}
    #Should Contain    ${alarms_string}    No connection to unit
    #should not be empty    ${alarms}

check RU STATUS
    [Arguments]   ${expected_status}=Unlocked
    admin_login
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
         run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
         ${output_tmp}    selenium_coam.get_ru_info     type_=RMOD_R    ru_index=${ru_id}
         ${RU_info}    set variable    ${output_tmp}[Status]
         should match regexp    ${RU_info}[Operational state]    Enabled
         should match regexp    ${RU_info}[Availability status]    Online
         should match regexp    ${RU_info}[Procedural status]    configured
         run keyword if    '${expected_status}'=='Unlocked'
         ...    should match regexp    ${RU_info}[Administrative state]    Unlocked
         ...    ELSE IF   '${expected_status}'=='Locked'
         ...    should match regexp    ${RU_info}[Administrative state]    Locked
         ...    ELSE   log to console   WRN: RU_${ru_id} status is ${RU_info}[Administrative state], not Unlocked or Locked.
    END

admin_login
    [Arguments]  ${connection}=admin_GNB_OAM    ${bts_host}=${DU_OAM_WEBUI_URL}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=443    username=${username}    password=${password}
    ...   name=${connection}

Perform RU Power Off
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
    ${ru_index}    Convert to integer    ${ru_index}
    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    BuiltIn.Log    Reset RU via Power off and Power On.

Check RU Disabled
    [Arguments]    ${ru_index}=${1}
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_ru_info    ru_index=${ru_index}
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    disabled
    Check RU Alarm Info

Perform RU Power On
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
    ${ru_index}    Convert to integer    ${ru_index}
    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.port_no}
    pdu.setup_pdu    model=${model}    host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
