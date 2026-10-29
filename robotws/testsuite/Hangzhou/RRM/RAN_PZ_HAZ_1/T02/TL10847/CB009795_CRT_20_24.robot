*** Settings ***
Documentation
...    Author: shuangfeng.f.sun@nokia-sbell.com
...    Contact: shuangfeng.f.sun@nokia-sbell.com
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***
${config_path}   /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10847/CB009795
${failure_pod_name_upue}    upue
${failure_pod_name_cpnrt}    cpnrt
${failure_pod_name_cpue}    cpue
${failure_pod_name_cpcl}    cpcl
${failure_pod_name_cpnb}    cpnb
${Message_start_recording}    NsetapX_StartRecordingSession
${Message_stop_recording}    NsetapX_StopRecordingSession
${message_filter}    Create List    Message name=${Message_start_recording}    Message name=${Message_stop_recording}

*** Test Cases ***
CB009795_20_behavior_of_Trace_content_after_TCM_failure_in_gNB-CU-CP_during_new_NRMTRACECU_activation
    [Tags]    CRT    CB009795_20
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.20, sun shuangfeng, initial create case.
    ...    This case is to test the handling of the trace sessions and trace recording sessions in case of CP-NB instance failure.
    [Setup]    Case Precondition
    Add NRMTRACECU-2 in vCU
    Initialize PA Signal For TL10847
    Open DCAP
    Initialize PA Signal For TL10847 Cell4
#    ute_ue.Require Ue    ue_alias=UE_1    capabilities=samsung
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    FOR    ${index}    IN RANGE    1
        Log to Console    \n***The ${index} time to trigger TCC failure***
#        Prepare And Attach UE    ue_index=1    ui_version=S21
        Prepare And Attach UE For Qualcomm    ue_index=0
        Start DL Call For UE    ue_index=0    ue_type=qualcomm
        sleep    10s    reason=wait call stable
        Trigger BTC failure    instance_abbr=TCM
        sleep    180s    reason=wait All TCM or TCC instance restarted
#        Prepare And Attach UE    ue_index=1    ui_version=S21
        Prepare And Attach UE For Qualcomm    ue_index=0
        Start DL Call For UE    ue_index=0    ue_type=qualcomm
        sleep    10s    reason=wait call stable
#        Prepare And Attach UE    ue_index=1    ui_version=S21
        Prepare And Attach UE For Qualcomm    ue_index=0
        Start DL Call For UE    ue_index=0    ue_type=qualcomm
        sleep    10s    reason=wait call stable
        Detach UE    ue_index=${0}
        Log to Console    \n***${index} time test done***
    END
    sleep    10s    reason=wait log generated
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Log For CB009795_20    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition_20

CB009795_24_Cell_trace_resiliency_after_TC_Configurator_failure_in_both_gNB-CU-CP_and_gNB-CU-UP
    [Tags]    CRT    CB009795_24
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.20, sun shuangfeng, initial create case.
    ...    This case is to test the handling of the trace sessions and trace recording sessions in case of CP-NB instance failure.
    [Setup]    Case Precondition
    Initialize PA Signal For TL10847
    Open DCAP
    Initialize PA Signal For TL10847 Cell4
#    ute_ue.Require Ue    ue_alias=UE_1    capabilities=samsung
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    FOR    ${index}    IN RANGE    1
        Log to Console    \n***The ${index} time to trigger TCC failure***
#        Prepare And Attach UE    ue_index=1    ui_version=S21
        Prepare And Attach UE For Qualcomm    ue_index=0
        Start DL Call For UE    ue_index=0    ue_type=qualcomm
        sleep    10s    reason=wait call stable
        Trigger BTC failure    instance_abbr=TCC
        sleep    180s    reason=wait All TCM or TCC instance restarted
#        Prepare And Attach UE    ue_index=1    ui_version=S21
        Prepare And Attach UE For Qualcomm    ue_index=0
        Start DL Call For UE    ue_index=0    ue_type=qualcomm
        sleep    10s    reason=wait call stable
#        Prepare And Attach UE    ue_index=1    ui_version=S21
        Prepare And Attach UE For Qualcomm    ue_index=0
        Start DL Call For UE    ue_index=0    ue_type=qualcomm
        sleep    10s    reason=wait call stable
        Detach UE    ue_index=${0}
        Log to Console    \n***${index} time test done***
    END
    sleep    10s    reason=wait log generated
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Log For CB009795_24    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC

Case Postcondition_20
    log to console    Case Postcondition
    Common Test Teardown For AIC
    Del NRMTRACECU-2 in vCU

Initialize PA Signal For TL10847
    SetInitializePAValue    pa_port=1-32;    pa_value=120;

Initialize PA Signal For TL10847 Cell4
    SetInitializePAValue    pa_port=1-4;5;6-8;9-12;13-16;13-16;17-32;    pa_value=120;0;120;120;120;120;120;

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Start DL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    ...            ${RemoteHost}=10.108.237.194    ${Account}=ute    ${Password}=Ut3pa5s#ff97
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
    ...              throughput=2000M    duration=${600}    RemoteHost=${RemoteHost}
    ...              Account=${Account}     Password=${Password}

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    Log to Console    \n***Prepare to attach.***
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    Log to Console    \n***UE attached.***
    [Return]     ${ue_${ue_index}_type}

Check Alarm Exist
    &{expected_alarm1}        Create Dictionary    fault_id=4350    fault_name=VNFC unavailable
    &{expected_alarm2}        Create Dictionary    fault_id=4695    fault_name=gNB Capacity Degraded
    @{expected_list}          Create List     ${expected_alarm1}    ${expected_alarm2}
    #&{ignored_alarms}         Create Dictionary    fault_id=4001    fault_name=BTS reset required
    #@{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    #...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Delete pod
    [Arguments]    ${vcu_namespace}=cran10    ${pod_name}=po-cran10-cpnb-0
    Trigger cmd    cmd=kubectl delete pod ${pod_name} -n ${vcu_namespace}
    Check Alarm    fault_id=4350    fault_name=VNFC unavailable    severity=critical    fault_status=active
    sleep    30s
    Check Alarm    fault_id=4350    fault_name=VNFC unavailable    severity=critical    fault_status=inactive

Modify PA Signal For Source And Target
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     127    20
    ${target_pa_port_list}     Create List    5    6    9
    ${target_pa_value_list}    Create List    0    127
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}    ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
    ...    ${TRUE}    dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${webem_info}

    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vcu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
    Log To Console     Trace Collection start on DCAP
    [Return]    ${trace_id}

Get Trace Log
    [Arguments]    ${btsip}
    ${trace_file_path}    Download Trace File    btsip=${btsip}
    @{zip_file_name}    OperatingSystem.List Files In Directory    ${trace_file_path}    *.zip
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name}[0]
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.lcbin
    [Return]    ${log_file_paths}

Get WebEM Info
    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...                                   '${ne_type.upper()}'=='VCU'
    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
    [return]    ${webem_info}

Check Emil Log For CB009795
    [Arguments]    ${trace_file}    ${connection}    ${start_counter}    ${stop_counter}
    log to console    Check Emil log for CB009795
    ${message_filter}    catenate   SEPARATOR="Message name"="NsetapX_StartRecordingSession";"Message name"="NsetapX_StopRecordingSession"
    ${StartRecordingSession_counter}    set variable    ${0}
    ${StopRecordingSession_counter}    set variable    ${0}
    FOR    ${trace}    IN    @{trace_file}
        ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace}    connection=${connection}
        ...                                                   filter=${message_filter}
        ${StartRecordingSession_counter}    Get Counters Of Message Name    filter_name=NsetapX_StartRecordingSession
        ...                                                                 json_file=${json_file_path}
        ...                                                                 counter=${StartRecordingSession_counter}
        ${StopRecordingSession_counter}    Get Counters Of Message Name    filter_name=NsetapX_StopRecordingSession
        ...                                                                json_file=${json_file_path}
        ...                                                                counter=${StopRecordingSession_counter}
    END
    Should Be Equal    ${start_counter}    ${StartRecordingSession_counter}
    Should Be Equal    ${stop_counter}    ${StopRecordingSession_counter}

Get Counters Of Message Name
    [Arguments]    ${filter_name}    ${json_file}    ${counter}
    &{json_content}   evaluate    json.load(open("${json_file}", "r"))    json
    ${row_data}     set variable    ${json_content["emil_data"]["rows"]}
    FOR  ${content}   IN    @{row_data}
        run keyword if    "${content["Message_name"]}"=="${filter_name}"     Set Test Variable    ${counter}    ${counter + 1}
    END
    [Return]    ${counter}

Trigger cmd
    [Arguments]    ${cmd}    ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${alias}=vcu_master
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    tafssh.execute    command=${cmd}    connection=${conn}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=${alias}

Check Alarm
    [Arguments]    ${fault_id}=4350    ${fault_name}=VNFC unavailable    ${severity}=critical    ${fault_status}=active
    &{expected_alarm}        Create Dictionary    fault_id=${fault_id}    fault_name=${fault_name}
    @{expected_list}          Create List     ${expected_alarm}
    &{CRITICAL_ALARM}        Create Dictionary    severity=${severity}
    @{CRITICAL}               Create List     ${CRITICAL_ALARM}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          critical_alarms=${CRITICAL}
    ${result}    Set Variable if    '${fault_status}'=='active'    True    False
    should be equal    '${res["flag_expect_alarm"]}'    '${result}'

Check Log For CB009795
    [Arguments]    ${trace_files}    ${connection}
    ${trace_message_count}    Create Dictionary    NsetapX_Configure=0    NsetapX_StartSession=0    NsetapX_IsAlive=0
    ...                                      NsetapX_StartRecordingSession=0    NsetapX_StopRecordingSession=0
    FOR    ${trace_file}    IN    @{trace_files}
        Get Trace Sessions related messages    ${trace_file}    ${trace_message_count}    ${connection}
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}
    Should Be True    ${trace_message_count}[NsetapX_Configure] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_StartSession] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_IsAlive] > ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartRecordingSession] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_StopRecordingSession] > ${0}

Check Log For CB009795_24
    [Arguments]    ${trace_files}    ${connection}
    ${trace_message_count}    Create Dictionary    NsetapX_Configure=0    NsetapX_StartSession=0    NsetapX_IsAlive=0
    ...                                      NsetapX_StartRecordingSession=0    NsetapX_StopRecordingSession=0
    FOR    ${trace_file}    IN    @{trace_files}
        Get Trace Sessions related messages    ${trace_file}    ${trace_message_count}    ${connection}
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}
    Should Be True    ${trace_message_count}[NsetapX_Configure] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_StartSession] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_IsAlive] > ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartRecordingSession] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_StopRecordingSession] > ${0}

Check Log For CB009795_20
    [Arguments]    ${trace_files}    ${connection}
    ${trace_message_count}    Create Dictionary    NsetapX_Configure=0    NsetapX_StartSession=0    NsetapX_IsAlive=0
    ...                                      NsetapX_StartRecordingSession=0    NsetapX_StopRecordingSession=0
    FOR    ${trace_file}    IN    @{trace_files}
        Get Trace Sessions related messages    ${trace_file}    ${trace_message_count}    ${connection}
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}
#    Should Be True    ${trace_message_count}[NsetapX_Configure] > ${0}
#    Should Be True    ${trace_message_count}[NsetapX_StartSession] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_IsAlive] > ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartRecordingSession] > ${0}

Get Trace Sessions related messages
    [Arguments]    ${trace_file}    ${message_count_dict}    ${connection}
    ${ts_filter}    catenate   SEPARATOR=    "Message name"="NsetapX_Configure";
    ...                            "Message name"="NsetapX_StartSession";
    ...                            "Message name"="NsetapX_IsAlive";
    ...                            "Message name"="NsetapX_StartRecordingSession";
    ...                            "Message name"="NsetapX_StopRecordingSession"
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${ts_filter}
    ${parsed_json}    OperatingSystem.Get File    ${json_file_path}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    FOR    ${trace}    IN    @{trace_info}
        ${message_name}=    Set Variable    ${trace}[Message_name]
        Run Keyword If    '${message_name}' in ${message_count_dict}
        ...                Add Value To Dictionary Key    ${message_count_dict}    ${message_name}    1
    END

Add Value To Dictionary Key
    [Arguments]    ${message_count_dict}    ${update_key}    ${add_value}
    ${new_value}    Evaluate    ${message_count_dict}[${update_key}] + ${add_value}
    Set To Dictionary    ${message_count_dict}    ${update_key}=${new_value}

Add NRMTRACECU-2 in vCU
    [Arguments]  ${delta_file_path}=${config_path}/case20_delta_add.json
    Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${True}

Del NRMTRACECU-2 in vCU
    [Arguments]  ${delta_file_path}=${config_path}/case20_delta_del.json
    Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${False}



