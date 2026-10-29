*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.collectors.btslog        WITH NAME    btslog
Library    ../../5GC002236_FA/resources/trans/translib.py
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${DU_OAM_IP}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}                https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${UTE_ADDRESS}                     ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}                    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}                    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}                          ${tl.gnbs[0].instance_id}
${SLAVE_DU_OAM_IP}                 ${tl.gnbs[0].slave[0].airscale.common_units[0].lmp_connection.addr}
${SLAVE_BTS_ID}                    ${tl.gnbs[0].slave[0].instance_id}


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
    [Arguments]       ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}
    ${scf_dir}   Get A Directory  scf
    ${scf_file}  Get A File   ${scf_dir}  tmpscf.xml
    coam.Get_Current_Scf_File  local_dir_path=${scf_dir}    file_name=${scf_file}  connection=${connection}
    [Return]  ${scf_file}
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections


WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Run Keyword If     ${virtual_enable}     Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
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

Change Sync Input Type
    [Arguments]    ${DU_IP}    ${BTS_ID}    ${synctype}    ${connection}=GNB_OAM
    Log To Console    Change Sync Input Type
    Connect to gnb coam via ssl    bts_host=${DU_IP}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A     connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
        ${object}     set variable if    ${sync_list}!=[]    ${item}
        Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1     connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    60s
    [Teardown]    COAM Teardown gnb connections

Change GNSS Operation Mode
    [Arguments]    ${Actual_value}     ${connection}=GNB_OAM
    Log To Console    Change GNSS Operation Mode
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}
    ${dict}    create dictionary    parameterName=gnssControlMode    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1     connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    120s
    Wait until keyword succeeds     15min    30s     COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Check Sync Status
    [Arguments]    ${expect_syncInputType}    ${connection}=GNB_OAM
    Log To Console    Check Sync Status
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}
    Wait until keyword succeeds     15min    30s     COAM Check GNB cell on air
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=${connection}
    Log To Console    Check syncMode
    ${bts_syncMode}    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    Log To Console    Check syncSourceInfo
    ${syncSourceInfo}    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${isActive}    Get From Dictionary    ${syncSourceInfo}[0]    isActive
    should be equal    ${isActive}    ${True}
    ${status}    Get From Dictionary    ${syncSourceInfo}[0]    status
    ${availability}    Get From Dictionary    ${status}    availability
    should be equal    ${availability}    Available
    ${usability}    Get From Dictionary    ${status}    usability
    should be equal    ${usability}    Usable
    ${syncInputType}    Get From Dictionary    ${syncSourceInfo}[0]    syncInputType
    should be equal    ${syncInputType}    ${expect_syncInputType}
    Log To Console    Check tuningMode
    ${tuningMode}    Get From Dictionary    ${bts_sync_status}    tuningMode
    should be equal    ${tuningMode}    Normal tuning
    [Teardown]    COAM Teardown gnb connections

Check GNSS Product Name And status
    [Arguments]  ${expect_product_name}
    WEBUI Login
    Log To Console    Get GNSS Info
    ${Get_information_GNSS}    selenium_coam.get_gnss_info
    ${product_name}    get from dictionary    ${Get_information_GNSS}    Product name
    ${product_code}    get from dictionary    ${Get_information_GNSS}    Product code
    ${serial_num}    get from dictionary    ${Get_information_GNSS}     Serial number
    ${Location_mode}    get from dictionary    ${Get_information_GNSS}     Location mode
    ${Position}    get from dictionary    ${Get_information_GNSS}    Position
    ${Latitude}    get from dictionary    ${Position}    Latitude
    ${Longitude}    get from dictionary    ${Position}    Longitude
    ${Altitude}    get from dictionary    ${Position}    Altitude
    ${Control mode}    get from dictionary    ${Get_information_GNSS}     Constellation mode
    Log To Console    Check status
    should not be equal    ${Control mode}    -
    should not be equal    ${product_code}    -
    should not be equal    ${serial_num}    -
    should not be equal    ${Latitude}    -
    should not be equal    ${Longitude}    -
    should not be equal    ${Altitude}    -
    Should be equal as strings    ${Location_mode}    automatic
    Should be equal as strings    ${product_name}    ${expect_product_name}
    [Teardown]    WEBUI Logout

Delete TOPP And Change Sync Input Type To GPS
    [Arguments]    ${synctype}     ${connection}=GNB_OAM
    Log To Console    Delete TOPP And Change Sync Input Type To GPS
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A     connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
        ${object}     set variable if    ${sync_list}!=[]    ${item}
        Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    remove from list    ${syncInputList}    1
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    30s
    [Teardown]    COAM Teardown gnb connections

Add And Change Sync Input Type To TOPP
    [Arguments]    ${synctype1}    ${synctype2}     ${connection}=GNB_OAM
    Log To Console    Add And Change Sync Input Type To TOPP
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A     connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
        ${object}     set variable if    ${sync_list}!=[]    ${item}
        Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    ${structure2}    create dictionary     syncInputPrio=${2}    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1     connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    [Teardown]    COAM Teardown gnb connections
