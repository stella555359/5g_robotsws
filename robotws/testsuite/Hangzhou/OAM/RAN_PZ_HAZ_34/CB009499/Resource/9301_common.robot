*** Settings ***
Documentation
...  author: ruiyu.han
...  contact: ruiyu.han@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Keywords ***
9301 Common Suite Setup for COAM
    robot_common_operations.Common Suite Setup
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}
    Create directory    ${epc_log_path}
    Siso Common Suite Setup
    run keyword and ignore error    UnBlock other cells except L3CALL    l3call_cell_list=None

9301 COAM Teardown gnb connections
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   3x   6s   COAM Login
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='false'    COAM Change actEcpriDelayMeasurement Value    value=true
    run keyword if   '${9301_flag}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Logout

Case Setup for 9301
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup    allowed_faults_ids=${SISO_FAULT_allowed}
    Wait Until Keyword Succeeds   3x   6s   COAM Login
    Recovery At Case Setup if Fault Occurs
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='true'    COAM Change actEcpriDelayMeasurement Value    value=false
    run keyword if   '${9301_flag}'=='true'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    ${L3CALL_enable}    run keyword if  '${MRBTS_ID}' in @{L3CALL_TL.keys()}    set variable   ${True}    ${False}
    Set Suite Variable    ${L3CALL_enable}

Case Teardown for 9301
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    Check Extra Reset From Blackbox
    run keyword and ignore error   Wait Until Keyword Succeeds   3x   6s   COAM Login
    Siso Common Save Logs
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='false'    COAM Change actEcpriDelayMeasurement Value    value=true
    run keyword if   '${9301_flag}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Logout

Case Setup for 9301 CRT
    [Documentation]   crt case setup, which will allow some specific faults and do some preparation for CRT cases
    robot_common_operations.Common Case Setup    allowed_faults_ids=${SISO_FAULT_allowed}

Case Teardown for 9301 CRT
    [Documentation]   crt case teardown, which will do some cleanup work for CRT cases
    CI_interface.Common Suite Setup
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   3x   6s   COAM Login
    Wait Until Keyword Succeeds    20m   30s   COAM Check All Cells Onair
    robot_common_operations.Common Case Teardown
    Run Keyword and Ignore Error   COAM Logout

COAM Change actEcpriDelayMeasurement Value
    [Arguments]    ${value}
    ${dict_param}    Create Dictionary    value=${value}    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actEcpriDelayMeasurement
    ${list_param}    Create List    ${dict_param}
    ${param_dic_to_change}    Create Dictionary    update=${list_param}
    COAM Commission Prameters Operation    param_dic_to_change=${param_dic_to_change}

Each Session Status Should be NoError
    [Arguments]    ${logpath}    ${filter}=SBbbMsg5DelayResult
    ${command}   Catenate   SEPARATOR=
    ...   cat ${logpath}
    ...   | grep ${filter}
    ${output}   RUN   command=${command}
    Should Not Be Empty   ${output}    ${filter} not in syslog!
    ${output_list}    Split String    ${output}    \n
    ${session_dic}    Create Dictionary
    FOR  ${line}   IN   @{output_list}
        ${session_id}    Get Regexp Matches    ${line}    sessionId: (\\d+),    1
        ${sessionid}    Set Variable    ${session_id[0]}
        ${status}    Get Regexp Matches    ${line}    status: (\\S+)}    1
        ${status}    Set Variable    ${status[0]}
        ${isoutctime}    Get Regexp Matches    ${line}
        ...   \\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\.\\d+Z
        ${isoutctime}    Set Variable    ${isoutctime[0]}
        ${datetime}   DateTime.Convert Date   date=${isoutctime}+0000   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S.%fZ%z
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        ${timestamp_list}   Create List    ${timestamp}    ${status}
        ${status}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${session_dic}     ${sessionid}
        run keyword if   ${status}    Set To Dictionary    ${session_dic}    ${sessionid}=${timestamp_list}
        run keyword if    '${timestamp}'>'${session_dic['${sessionid}'][0]}'    Set To Dictionary
        ...    ${session_dic}    ${sessionid}=${timestamp_list}
    END
    FOR   ${session}   IN   @{session_dic}
        ${status}    Set Variable    ${session_dic['${session}'][1]}
        Should Be Equal    ${status}    EStatus_NoError
    END

Each Periodic delay Should be In Range
    [Arguments]    ${delay_threshold}=300   ${filter}=Periodic delay measurement result
    Log To Console   //TODO: Siso Common Syslog Should Not Contain
    ${test_pc_addr}   Get Variable Value   ${TESTPC_ADDR}   ${EMPTY}
    ${test_pc_username}   Get Variable Value   ${TESTPC_user}   ${EMPTY}
    ${test_pc_password}   Get Variable Value   ${TESTPC_pwd}   ${EMPTY}
    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"
    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}
    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}
    Log To Console   Check Syslog Error On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}
    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep '${filter}'
    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${filter} not in syslog!
    ${output}    strip string    ${output}
    ${output_list}    Split String    ${output}    \n
    &{periodic_dic}    Create Dictionary
    FOR  ${line}   IN   @{output_list}
        ${line}    Strip String    ${line}
        Continue For Loop If    ${line.count("no responses")}>0
        ${session_id}    Get Regexp Matches    ${line}    sessionId (\\d+)\\s    1
        ${session_id}    Set Variable    ${session_id[0]}
        ${list_diff}    create list
        ${value_dic}    Get Variable Value    ${periodic_dic['${session_id}']}
        run keyword if   ${value_dic}==${None}   Set To Dictionary   ${periodic_dic}   ${session_id}=${list_diff}
    END
    FOR  ${line}   IN   @{output_list}
        ${line}    Strip String    ${line}
        ${t12min}    Get Regexp Matches    ${line}    t12Min =?\\s?(\\d+)    1
        ${t12min}    Set Variable    ${t12min[0]}
#        ${delay_threshold}    set variable if     ${${t12min}}>${100000}    1000    ${delay_threshold}
        ${t34Min}    Get Regexp Matches    ${line}    t34Min =?\\s?(\\d+)    1
        ${t34Min}    Set Variable    ${t34Min[0]}
        ${session_id}    Get Regexp Matches    ${line}    sessionId (\\d+)    1
        ${session_id}    Set Variable    ${session_id[0]}
        ${difference}    Evaluate    abs(int(${t12min}) - int(${t34Min}))
        append to list    ${periodic_dic["${session_id}"]}    ${difference}
    END
    FOR  ${session}   IN   @{periodic_dic}
        ${count}    Set Variable    ${0}
        FOR  ${difference}   IN    @{periodic_dic['${session}']}
            Continue For Loop If    ${difference}<${delay_threshold}
            ${count}    Evaluate    ${count}+1
        END
        Should Not Be Equal     ${count}    len(${periodic_dic['${session}']})     msg=abs(int(${t12min}) - int(${t34Min}))>${delay_threshold}!
    END
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}

CB009301_feature_enable_disable_loops
    [Documentation]   Modify actEcpriDelayMeasurement in loop
    [Arguments]    ${times}=${1}
    Case Setup for 9301
    FOR   ${index}    IN RANGE    ${times}
        Single_CB009301_feature_enable_disable
    END
    [Teardown]     Case Teardown for 9301

Single_CB009301_feature_enable_disable
    Wait Until Keyword Succeeds   3x   5s   Start Syslog Collection
    COAM Change actEcpriDelayMeasurement Value    value=true
    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
#    wait until keyword succeeds   5m   1m
#    ...   Siso Common Syslog Should Not Contain    filter=SBbbMsg5DelayResult    shouldnotcontain_str=EStatus_Timeout
    Coam Check FHLKDLY_R Object Enough
    sleep   1min
    Each Periodic delay Should be In Range
    COAM Change actEcpriDelayMeasurement Value    value=false
    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    Siso Common Syslog Should Contain    filter=DELETE MO    shouldcontain_str=FHLKDLY_R
    [Teardown]     Siso Common Each Time Teardown    syslog_check=${False}

Case Setup for CB009301_L3CALL_with_Traffic
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds   3x   6s   COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='false'    COAM Change actEcpriDelayMeasurement Value    value=true
    run keyword if   '${9301_flag}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    ${L3CALL_enable}    run keyword if  '${MRBTS_ID}' in @{L3CALL_TL.keys()}    set variable   ${True}    ${False}
    Set Suite Variable    ${L3CALL_enable}

Case Teardown for CB009301_L3CALL_with_Traffic
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    robot_common_operations.Common Case Teardown
    Check Extra Reset From Blackbox
    run keyword and ignore error   Wait Until Keyword Succeeds   3x   6s   COAM Login
    Siso Common Save Logs
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='false'    COAM Change actEcpriDelayMeasurement Value    value=true
    run keyword if   '${9301_flag}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Reset Site
    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Logout

CB009301_L3CALL_with_Traffic
    Case Setup for CB009301_L3CALL_with_Traffic
    run keyword if  ${L3CALL_enable}   9301 L3CALL with traffic
    [Teardown]     Case Teardown for 9301

9301 L3CALL with traffic
    FOR    ${cell}    IN    @{L3CALL_TL["${MRBTS_ID}"]}
        ${nrcellid}    Get cellid by Globlecellid    ${cell}
        Log To Console    START L3CALL AT CELL:${cell}...
        ${cell_list}    Create List    ${nrcellid}
        Change other cells qrxlevmin when L3CALL    l3call_cell=${cell}
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x   1min    Call Setup and check tput
        ...   ue_index=${L3CALL_TL["${MRBTS_ID}"]["${cell}"]["ue_index"]}
        ...   duration=${L3CALL_TL["${MRBTS_ID}"]["${cell}"]["duration"]}
        ...   dl_deviation=${L3CALL_TL["${MRBTS_ID}"]["${cell}"]["dl_tp_ratio"]}
        ...   ul_deviation=${L3CALL_TL["${MRBTS_ID}"]["${cell}"]["ul_tp_ratio"]}
        ...   peak_ul=${L3CALL_TL["${MRBTS_ID}"]["${cell}"]["peak_tp_ul"]}
        ...   tput=${L3CALL_TL["${MRBTS_ID}"]["${cell}"]["peak_tp_dl"]}
        ...   method=PEAK
        ...   cell_list=${cell_list}
        ...   check_source=Aasyslog
    END

Case Setup:CB009301_siso_common_bbmod_reset
   ${egen_exist}    run keyword if   '${tl.gnbs[0].global_bts_id}' in @{egen_TL}    Set Variable    ${True}    ${False}
   set test variable    ${egen_exist}
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    COAM Backup Full SCF   file_name=siso_scf_bbmod_reset.xml
    ${bbmodreset_siso_scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/siso_scf_bbmod_reset.xml
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${bbmodreset_siso_scf_xml}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${bbmodreset_siso_scf_xml}
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${bbmodreset_siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${bbmodreset_siso_scf_xml}
    ${bbmods_info}     Get BBMODs info
    set suite variable    ${bbmodreset_siso_scf_xml}
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    set suite variable    ${rmod_cell_mapping}
    set suite variable    ${rmod_serial_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    ##set the flag to true
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='false'    COAM Change actEcpriDelayMeasurement Value    value=true
    run keyword if   '${9301_flag}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair

Case Teardown:CB009301_siso_common_bbmod_reset
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
    [Teardown]    COAM Logout

CB009301_siso_common_bbmod_reset
   [Timeout]  48h
   [Arguments]    ${times}=${10}
   Case Setup:CB009301_siso_common_bbmod_reset
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{BB_ignore_TL}
       log to console     //this is index：${index} time do All BBMODs Reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['bbmod_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
        CB009301 All BBMODs Reset
    END
    [Teardown]   Case Teardown:CB009301_siso_common_bbmod_reset

CB009301 All BBMODs Reset
    [Arguments]    ${keycheck}=${False}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    ${w_g_rat_bbmods}     Check If WCDMA Or GSM Deployed On BBMOD    source=${siso_scf_xml}
    FOR     ${bbmod}     IN     @{bbmods_info}
        ${bbmod_r}      fetch from right     ${bbmod['internal']}     /
        continue for loop if   '${bbmod_r}' not in ${bbmod_cell_mapping}
        continue for loop if     '${bbmod['product_name']}' == 'ABIA' and '${bbmod_r}' in ${w_g_rat_bbmods}
        run keyword and ignore error    COAM Reset BBMOD      dist_name=${bbmod['internal']}     timeout=${20}
        Wait Until Keyword Succeeds   5m   30s   BBMOD RU Cell Status should Disabled   dist_name=${bbmod['configuration']}
        run keyword if   ${egen_exist}    Start Egen Log
        ...   egen_server=${tl.test_pcs[0].default_ssh_connection_details.addr}
        ...   egen_username=${tl.test_pcs[0].default_ssh_connection_details.username}
        ...   egen_password=${tl.test_pcs[0].default_ssh_connection_details.password}
        sleep    30s
#        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
        Wait Until Keyword Succeeds   20m   1m   BBMOD RU Cell Status should Enabled   dist_name=${bbmod['configuration']}
        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
     END
    Siso Common Syslog Should Not Contain    filter=SBbbMsg5DelayResult    shouldnotcontain_str=EStatus_Timeout
    sleep   1min
    Each Periodic delay Should be In Range
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}    syslog_check=${False}

Case Setup:CB009301_siso_common_Power_Reset
     Set test Variable    ${Siso_Common_LOG_PATH}    ${OUTPUT_DIR}/siso_common_Power_Reset
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
         ##set the flag to true
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='false'    COAM Change actEcpriDelayMeasurement Value    value=true
    run keyword if   '${9301_flag}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair

Case Teardown:CB009301_siso_common_Power_Reset
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout

CB009301_siso_common_Power_Reset
   [Timeout]  8h
   [Arguments]    ${times}=${10}
   Case Setup:CB009301_siso_common_Power_Reset
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do power reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['power_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       CB009301 All Site Power Reset
    END
    [Teardown]    Case Teardown:CB009301_siso_common_Power_Reset

CB009301 All Site Power Reset
    [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    ${status}    run keyword and return status    coam.Power_Reset    connection=COAM
    Should Be Equal    ${status}    ${true}
    Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    Siso Common Syslog Should Not Contain    filter=SBbbMsg5DelayResult    shouldnotcontain_str=EStatus_Timeout
    sleep   1min
    Each Periodic delay Should be In Range
    [Teardown]    Siso Common Each Time Teardown     keycheck=${keycheck}   syslog_check=${False}

Case Setup:CB009301_siso_common_Block_Site
     Set test Variable    ${Siso_Common_LOG_PATH}    ${OUTPUT_DIR}/siso_common_Block_Site
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
         ##set the flag to true
    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actEcpriDelayMeasurement
    run keyword if   '${9301_flag}'=='false'    COAM Change actEcpriDelayMeasurement Value    value=true
    run keyword if   '${9301_flag}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair

Case Teardown:CB009301_siso_common_Block_Site
   Siso Common Save Logs
    ${block_state}    COAM Get Parameter Value By XPath
    ...   xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID}"]/p[@name="blockingState"]
    ${status}    run keyword and return status    should be equal    ${block_state}    Unblocked
    run keyword if   ${status}==${false}    Wait Until Keyword Succeeds   3x   30s
    ...   coam.unblock    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1    connection=${connection}   timeout=${600}

    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    COAM Logout

CB009301_siso_common_Block_Site
   [Timeout]  8h
   [Arguments]    ${times}=${1}
   Case Setup:CB009301_siso_common_Block_Site
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do siso_common_Block_Site...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['block_site']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
        CB009301 Single time Block Site
    END
    [Teardown]    Case Teardown:CB009301_siso_common_Block_Site

CB009301 Single time Block Site
    [Arguments]    ${keycheck}=${False}    ${connection}=COAM
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    coam.block    dist_name=MRBTS-${MRBTS_ID}    connection=${connection}   timeout=${600}
   ${block_state}    COAM Get Parameter Value By XPath
   ...   xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID}"]/p[@name="blockingState"]
    should be equal    ${block_state}    Blocked
    coam.unblock    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1    connection=${connection}   timeout=${600}
    Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    Siso Common Syslog Should Not Contain    filter=SBbbMsg5DelayResult    shouldnotcontain_str=EStatus_Timeout
    sleep   1min
    Each Periodic delay Should be In Range
    [Teardown]    Siso Common Each Time Teardown     keycheck=${keycheck}    syslog_check=${False}

Change other cells qrxlevmin when L3CALL
    [Arguments]    ${l3call_cell}
    &{cell_value}    Create Dictionary
    FOR    ${cell}    IN    @{L3CALL_TL["${MRBTS_ID}"]}
        Run Keyword If    '${cell}'=='${l3call_cell}'    Set To Dictionary    ${cell_value}  ${cell}=-50
        ...   ELSE   Set To Dictionary    ${cell_value}  ${cell}=-22
    END

    FOR   ${cell}    IN    @{cell_value}
        ${dict_param}    Create Dictionary    value=${cell_value['${cell}']}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cell}
        ...    parameter=qRxLevMin
        ${list_param}    Create List    ${dict_param}
        ${param_dic_to_change}    Create Dictionary    update=${list_param}
        COAM Commission Prameters Operation    param_dic_to_change=${param_dic_to_change}
    END

Coam Check FHLKDLY_R Object Enough
    [Arguments]    ${FHLKDLY_COUNT}=${11}
    COAM Backup Full SCF    file_name=cellonair_full_commission.xml
    ${source}   XML.Parse XML   ${OUTPUT_DIR}/cellonair_full_commission.xml
    ${FHLKDLY_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:FHLKDLY_R"]
    ${length} =    Get Length    ${FHLKDLY_r_list}
    should be equal    ${length}   ${FHLKDLY_COUNT}