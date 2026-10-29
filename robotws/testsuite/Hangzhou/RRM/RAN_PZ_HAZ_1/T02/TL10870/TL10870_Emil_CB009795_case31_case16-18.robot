*** Settings ***
Documentation
...    Author: Qianqian Guo
...    Contact: qianqian.guo@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Start DCAP Container    node_id=${0}   node_type=gnb
Suite Teardown    Run keywords    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    150 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***
#${config_path}   /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10870/CB009795
${failure_pod_name_upue}    upue
${failure_pod_name_cpnrt}    cpnrt
${failure_pod_name_cpue}    cpue
${failure_pod_name_cpcl}    cpcl
${failure_pod_name_cpnb}    cpnb
${Message_start_recording}    NsetapX_StartRecordingSession
${Message_stop_recording}    NsetapX_StopRecordingSession
${message_filter}    Create List    Message name=${Message_start_recording}    Message name=${Message_stop_recording}


*** Test Cases ***

CB009795_31_HA_all_CP-UE_Pod_Failure
    [Tags]    CRT    CB009795_31    CB009795
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2024/11/28,qianqian Guo,add CB009795 case31
    ...    This case is to test CP-UE pod failure with site reset.

    [Setup]    Case Precondition
    Log to Console    \n***Open DCAP***
    Open DCAP
    Set Initialize PA Value    pa_port=9-10;11;12;15;    pa_value=127;0;127;127;
    Log to Console    \n***Start Counter In vCU***
    Start Counter In vCU
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    log to console    trigger cpue-0 failuer
    Trigger cmd    cmd=kubectl delete pod po-cpue-0 -n ${VCU_NAMESPACE}
    #log to console    check fault 4350 VNFC unavailable and 4695 VNFC unavailable
    #Check Alarm Exist
    sleep    60s
    log to console    trigger cpue-1 failuer
    Trigger cmd    kubectl delete pod po-cpue-1 -n ${VCU_NAMESPACE}
    #log to console    check fault 4350 VNFC unavailable and 4695 VNFC unavailable
    #Check Alarm Exist
    #sleep    60s

    log to console    trigger cpue-0 and cpue-1 failuer
	${kill_all_pods_cmd}    Catenate
    ...    kubectl delete pod po-cpue-0 -n ${VCU_NAMESPACE}
    ...    && kubectl delete pod po-cpue-1 -n ${VCU_NAMESPACE}
    Trigger cmd    cmd=${kill_all_pods_cmd}
	sleep    60s
	#Check Alarm Not Exist
    log to console    stop DCAP Trace
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
	Detach UE    ue_index=${1}
    Check Log For CB009795    ${trace_file_path}    dcap-master
	sleep    300s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}
    [Teardown]    Case Postcondition

CB009795_16_Monitoring_behavior_of_Cell_trace_content_after_TC_Configurator_failure_in_gNB-CU-CP
    [Tags]    CRT    CB009795_16    CB009795
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: <25-12-2024>,<Qianqian Guo>,<CB009795_CASE16>
    ...    This case includes case16(cell trace in CU-CP) case17（MDT in CU-CP) and case18(PCMD in CU-CP),
    ...    we configure cell trace, MDT and PCMD in SCF.
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=9-10;11;12;15;    pa_value=127;0;127;127;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    Trigger BTC failure    instance_abbr=TCC
    sleep    300s    reason=wait All TCM or TCC instance restarted
    Detach UE    ue_index=${1}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    sleep    10s    reason=wait log generated
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Detach UE    ue_index=${1}
    Check Log For CB009795 TCC    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition

CB009795_20_behavior_of_Trace_content_after_TCM_failure_in_gNB-CU-CP_during_new_NRMTRACECU_activation
    [Tags]    CRT    CB009795_20
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.20, sun shuangfeng, initial create case.
    ...    This case is to test the handling of the trace sessions and trace recording sessions in case of CP-NB instance failure.
    [Setup]    Case Precondition
#    Add NRMTRACECU-2 in vCU
    Open DCAP
    Set Initialize PA Value    pa_port=9-10;11;12;15;    pa_value=127;0;127;127;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    Trigger BTC failure oamext    instance_abbr=TCM
    sleep    300s    reason=wait All TCM or TCC instance restarted
    Detach UE    ue_index=${1}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    sleep    10s    reason=wait log generated
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Detach UE    ue_index=${1}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Log For CB009795_20    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition

CB009795_24_Cell_trace_resiliency_after_TC_Configurator_failure_in_both_gNB-CU-CP_and_gNB-CU-UP
    [Tags]    CRT    CB009795_24
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.20, sun shuangfeng, initial create case.
    ...    This case is to test the handling of the trace sessions and trace recording sessions in case of CP-NB instance failure.
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=9-10;11;12;15;    pa_value=127;0;127;127;
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    Trigger BTC failure oamext    instance_abbr=TCC
    sleep    300s    reason=wait All TCM or TCC instance restarted
    Detach UE    ue_index=${1}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    sleep    10s    reason=wait log generated
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Detach UE    ue_index=${1}
    Check Log For CB009795_24    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    #Run Keyword And Ignore Error    Detach UE    ue_index=${1}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Prepare And Attach UE
    [Arguments]    ${ue_index}=${1}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    Log to Console    \n***Detach UE***
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully

Set PA Value
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters    pa_port=9;10-12;15;    pa_value=0;127;127;
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${3}
    PA Operation    operation=Initialize PA Value    source=&{source}


Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller startLS


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
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
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
	Set Test Variable    ${webem_info}
    [return]    ${webem_info}

Check Emil Log For CB009795
    [Arguments]    ${trace_file}    ${connection}
    log to console    Check Emil log for CB009795 TCM
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
    #...                filter=@{message_filter}
    Check Message In JSON File    ${json_file_path}
    should not be empty    ${json_file_path}


Check Message In JSON File
    [Arguments]    ${trace_file}
    ${parsed_json}    OperatingSystem.Get File    ${trace_file}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    Should Contain X Times    ${trace_info}    'Message_name': '${Message_start_recording}'    ${3}
    Should Contain X Times    ${trace_info}    'Message_name': '${Message_stop_recording}'    ${3}
    Should Contain X Times    ${trace_info}    'User_data': '${User_data_RRCReconfigurationComplete}'    ${3}
    Should Contain X Times    ${trace_info}    'User_data': '${User_data_PDUSessionResourceSetupResponse}'    ${3}

Check Emil Log For CB009795 TCC
    [Arguments]    ${trace_file}    ${connection}
    log to console    Check Emil log for CB009795 TCC
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
    #...                filter=@{message_filter}
    Check Message In JSON File TCC    ${json_file_path}
    should not be empty    ${json_file_path}


Check Message In JSON File TCC
    [Arguments]    ${trace_file}
    ${parsed_json}    OperatingSystem.Get File    ${trace_file}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    Should Contain X Times    ${trace_info}    'Message_name': '${Message_start_recording}'    ${2}
    Should Contain X Times    ${trace_info}    'Message_name': '${NsetapX_IsAlive}'    ${10}
    Should Contain X Times    ${trace_info}    'Message_name': '${NsetapX_Configure}'    ${1}
    Should Contain X Times    ${trace_info}    'Message_name': '${NsetapX_StartSession}'    ${1}
    Should Contain X Times    ${trace_info}    'User_data': '${User_data_RRCReconfigurationComplete}'    ${2}
    Should Contain X Times    ${trace_info}    'User_data': '${User_data_PDUSessionResourceSetupResponse}'    ${2}

Check Jsoncontent in Emil Log
    [Arguments]    ${emil_data}
    ${trace_info}=    Set Variable    ${emil_data}
    ${record_data}=    Set Variable    ${trace_info}[NgAP: PDUSessionResourceSetupResponse][PDUSessionResourceSetupResponse][data]
    #${trigger}=    Set Variable    ${record_data}[trigger]
    ${result}=    Set Variable    ${record_data}[result]
    #${modified_pdu_sessions}=    Set Variable    ${record_data}[modifiedPduSessionResources]
    #Should Be Equal    ${trigger}    pduSessionResourceModifyOperation
    Should Be Equal    ${result}    success


Trigger cmd
    [Arguments]    ${cmd}    ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${alias}=vcu_master
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    tafssh.execute    command=${cmd}    connection=${conn}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=${alias}

Get Active Pod Name For Redundant layout of CNF
    [Arguments]    ${pod_abbr}=oamext    ${connection}=${None}
#    oc get pods --selector='healing-controller.rcpha/service-selector' | grep oamext | awk '{print $1}'
    ${get_active_pod}=    Catenate    oc get pods --selector='healing-controller.rcpha/service-selector' |
    ...                               grep ${pod_abbr} | awk '{print \$1}'
    ${active_pod}    tafssh.execute    command=${get_active_pod}    connection=${connection}
    ${active_pod_list}=    split_string    ${active_pod}    \r\n
    ${active_pod_name}    set variable    ${active_pod_list}[0]
    [Return]    ${active_pod_name}

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

Check Alarm Not Exist
    &{expected_alarm1}        Create Dictionary    fault_id=4350    fault_name=VNFC unavailable
    &{expected_alarm2}        Create Dictionary    fault_id=4695    fault_name=gNB Capacity Degraded
    @{expected_list}          Create List     ${expected_alarm1}    ${expected_alarm2}
    &{ignored_alarms}         Create Dictionary    fault_id=7301    fault_name=Xn SCTP setup fail
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${None}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${False}

Start Counter In vCU
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID};
    ...         Counter: M55119C00011,M55119C00014,M55121C00501,M55121C00502;
    ...         Counter rule: max(M55119C00011)>=1 and max(M55119C00014)>=1 and
    ...         max(M55121C00501)>=1 and max(M55121C00502)>=1;
	${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1;
    ...         Counter: M55150C00008,M55150C00009;
    ...         Counter rule: max(M55150C00008)>=2 and max(M55150C00009)>=2;
    ${rule_list}    Create List    ${rule2}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}

Check Log For CB009795
    [Arguments]    ${trace_files}    ${connection}
    ${trace_message_count}    Create Dictionary    NsetapX_Configure=0    NsetapX_StartSession=0    NsetapX_IsAlive=0
    ...                                      NsetapX_StartRecordingSession=0    NsetapX_StopRecordingSession=0
    FOR    ${trace_file}    IN    @{trace_files}
        Get Trace Sessions related messages    ${trace_file}    ${trace_message_count}    ${connection}
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}
    Should Be True    ${trace_message_count}[NsetapX_Configure] == ${0}
    Should Be True    ${trace_message_count}[NsetapX_StartSession] == ${0}
    Should Be True    ${trace_message_count}[NsetapX_IsAlive] > ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartRecordingSession] > ${4}
    Should Be True    ${trace_message_count}[NsetapX_StopRecordingSession] > ${4}

Check Log For CB009795 TCC
    [Arguments]    ${trace_files}    ${connection}
    ${trace_message_count}    Create Dictionary    NsetapX_Configure=0    NsetapX_StartSession=0    NsetapX_IsAlive=0
    ...                                      NsetapX_StartRecordingSession=0    NsetapX_StopRecordingSession=0
    FOR    ${trace_file}    IN    @{trace_files}
        Get Trace Sessions related messages    ${trace_file}    ${trace_message_count}    ${connection}
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}
    Should Be True    ${trace_message_count}[NsetapX_Configure] >= ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartSession] >= ${1}
    Should Be True    ${trace_message_count}[NsetapX_IsAlive] > ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartRecordingSession] > ${1}
    #Should Be True    ${trace_message_count}[NsetapX_StopRecordingSession] > ${0}

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

Case Postcondition_20
    log to console    Case Postcondition
    Common Test Teardown For AIC
    Del NRMTRACECU-2 in vCU

Check Log For CB009795_24
    [Arguments]    ${trace_files}    ${connection}
    ${trace_message_count}    Create Dictionary    NsetapX_Configure=0    NsetapX_StartSession=0    NsetapX_IsAlive=0
    ...                                      NsetapX_StartRecordingSession=0    NsetapX_StopRecordingSession=0
    FOR    ${trace_file}    IN    @{trace_files}
        Get Trace Sessions related messages    ${trace_file}    ${trace_message_count}    ${connection}
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}
    #Should Be True    ${trace_message_count}[NsetapX_Configure] > ${0}
    #Should Be True    ${trace_message_count}[NsetapX_StartSession] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_IsAlive] > ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartRecordingSession] > ${0}
    Should Be True    ${trace_message_count}[NsetapX_StopRecordingSession] > ${0}

Trigger BTC failure oamext
    [Arguments]    ${instance_abbr}=TCM
    [Documentation]    this kw is used to Trigger BTC failure
    ...    | Input Parameters | Man. | Description |
    ...	   | instance_abbr | yes | TCM or TCC |
    ${ns}    Get vCU Namespace From Config File

    ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
    ...                             username=${VCU_USERNAME}
    ...                             password=${VCU_PASSWORD}
    ...                             alias=vcu_master
    ${pod_name}=    Run Keyword If    '${instance_abbr}' == 'TCC'
        ...    Get Active Pod Name For Redundant layout of CNF    pod_abbr=oamext    connection=${conn}
    ...    ELSE IF    '${instance_abbr}' == 'TCM'
        ...    Get Pod Name    ${ns}    pod_abbr=tracecontroller    connection=${conn}

    ${container_name}=    Set Variable If    '${instance_abbr}' == 'TCC'
        ...    ctr-${ns}-tracecontrollerconfigurator
    ...    '${instance_abbr}' == 'TCM'
        ...    ctr-${ns}-tracecontrollermaster

    Log To Console    Trigger BTC failure
    Run Keyword If    '${instance_abbr}'=='TCM'   Trigger TCM instance failure    ${pod_name}    ${container_name}    ${conn}
    ...    ELSE IF    '${instance_abbr}'=='TCC'    Trigger TCC instance failure    ${pod_name}    ${container_name}    ${conn}
    ...    ELSE    Log To Console    Invalid instance abbreviation
    [Teardown]    Run Keyword And Ignore Error    tafssh.disconnect    connection=${conn}
