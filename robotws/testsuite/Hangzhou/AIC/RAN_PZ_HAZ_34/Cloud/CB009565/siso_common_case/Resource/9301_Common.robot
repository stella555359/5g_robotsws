*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot

*** Keywords ***
Case Setup for CB009301
    COAM VDU Login
    ${status_onair}    run keyword and return status     COAM VDU Check All Cell Status
    ${status_fault}    run keyword and return status     COAM VDU Check Active Alarms
    run keyword if  ${status_onair}==${False} or ${status_fault}==${False}   run keywords
    ...   Run Keyword And Ignore Error   COAM VDU Reset
    ...   AND   Wait Until Keyword Succeeds   15m   1m   COAM VDU Check All Cell Status

#    ${9301_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
#    ...   parameter=actEcpriDelayMeasurement
#    run keyword if   '${9301_flag}'=='true'    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=false
   [Teardown]    Run Keyword And Ignore Error   COAM VDU Logout


Case Teardown for CB009301
    Run Keyword And Ignore Error   COAM VDU Logout

Single Online Modify actEcpriDelayMeasurement
    [Arguments]    ${actEcpriDelayMeasurement_value}
    COAM VDU Login
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].global_bts_id}
    ${delta_str}    COAM VDU Create Single Parameter Delta String
    ...    distName=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameterName=actEcpriDelayMeasurement
    ...    value=${actEcpriDelayMeasurement_value}
    ${delta_dict}   Evaluate   json.loads('${delta_str}')   json
    ${delta_list}    create list    ${delta_dict}
    ${delta_str}   Evaluate   json.dumps(${delta_list})   json
    Wait Until Keyword Succeeds    3x    1min    COAM VDU Perform Delta commission    delta_file=${delta_str}
    run keyword if   ${egen_exist} and '${actEcpriDelayMeasurement_value}'=='true'   VDU Start Egen Log
    Wait Until Keyword Succeeds    30min    1min    COAM VDU Check All Cell Status
    [Teardown]    Run Keyword And Ignore Error   COAM VDU Logout


VDU Each Session Status Should be OK
    [Arguments]    ${filter}=SBbbMsg5DelayResult
    ...    ${test_pc_addr}=${tl.test_pc.default_ssh_connection_details.addr}
    ...   ${test_pc_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}

    Log To Console   //TODO: CHECK VDU Each Session Status Should be OK

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    Log To Console   VDU Syslog Should Contain On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
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

    FOR   ${session}   IN  @{session_dic}
        ${status}    Set Variable    ${session_dic['${session}'][1]}
        Should Be Equal    ${status}    EStatus_NoError
    END

VDU Each Periodic delay Should be In Range
    [Arguments]    ${delay_threshold}=300   ${filter}=Periodic delay measurement result
    ...    ${test_pc_addr}=${tl.test_pc.default_ssh_connection_details.addr}
    ...   ${test_pc_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}

    Log To Console   //TODO: CHECK VDU Each Periodic delay Should be In Range

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    Log To Console   VDU Syslog Should Contain On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep '${filter}'

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${filter} not in syslog!

    ${output_list}    Split String    ${output}    \n

    FOR  ${line}   IN   @{output_list}
        ${t12min}    Get Regexp Matches    ${line}    t12Min (\\d+)\\s    1
        ${t12min}    Set Variable    ${t12min[0]}
        ${t34Min}    Get Regexp Matches    ${line}    t34Min (\\d+)\\s    1
        ${t34Min}    Set Variable    ${t34Min[0]}
        ${difference}    Evaluate    abs(int(${t12min}) - int(${t34Min}))
        Should Be True    ${difference}<${delay_threshold}    msg=abs(int(${t12min}) - int(${t34Min}))>300!
    END


Single_Cloud_Modify_actEcpriDelayMeasurement_with_RU_Rest
        ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
        Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
        Set Test Variable   ${CASE_PROCESS_START}
        Clear Coredump files in OCP

        Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
        ##enable 9301 and check syslog
        Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true
        VDU Syslog Should Not Contain    filter=SBbbMsg5DelayResult    shouldnotcontain_str=EStatus_Timeout
        run keyword if   ${egen_exist}    VDU Stop Egen Log


        ##reset ru
        Log To Console    | Start to Reset RU...
        COAM VDU Login
        @{rmods_list}   COAM VDU Get RMOD ID List
        COAM VDU Reset RU   rmods_list=${rmods_list}
        run keyword if  ${rulog_exist}    Wait Until Keyword Succeeds    5min   10s   VDU Enable LMI RU at ControlPC
        Wait Until Keyword Succeeds   30m   1m   COAM VDU Check All Cell Status
        COAM VDU Logout
        ##disable 9301
        Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=false
        VDU Syslog Should Contain    filter=DELETE MO    shouldcontain_str=FHLKDLY_R

        ##siso check
        [Teardown]    VDU Siso Common Each Time Teardown


Single_Modify_actEcpriDelayMeasurement_in_loop
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Clear Coredump files in OCP

    Wait Until Keyword Succeeds   3x   10s   Remote Start Syslog Collection
    ##enable 9301 and check syslog
    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=true
    VDU Syslog Should Not Contain    filter=SBbbMsg5DelayResult    shouldnotcontain_str=EStatus_Timeout
    run keyword if   ${egen_exist}    VDU Stop Egen Log


    ##disable 9301
    Single Online Modify actEcpriDelayMeasurement    actEcpriDelayMeasurement_value=false
    VDU Syslog Should Contain    filter=DELETE MO    shouldcontain_str=FHLKDLY_R

    ##siso check
#    [Teardown]    VDU Siso Common Each Time Teardown