*** Settings ***
Documentation
...    Author: shunxin.jin@nokia-sbell.com
...    Contact: shunxin.jin@nokia-sbell.com
...    Please do not modify the file without notification to author


Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Start DCAP Container    node_id=${0}   node_type=gnb
Suite Teardown    Run keywords    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***
${failure_pod_name}    cpue
${Message_start_recording}    NsetapX_StartRecordingSession
${Message_stop_recording}    NsetapX_StopRecordingSession
${message_filter}    Create List    Message name=${Message_start_recording}    Message name=${Message_stop_recording}

*** Test Cases ***
CB009795_03_PCMD_and_Cell_trace_both_resiliency_during_CP-NB_failure_in_gNB-CU-CP
    [Tags]    CRT    CB009795_03
    [Documentation]
    ...    Author: shunxin.jin@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.10, Jin Shunxin, initial create case.
    ...    This case is to test the handling of the trace sessions and trace recording sessions in case of CP-NB instance failure.

    [Setup]    Case Precondition
    Open DCAP
    Initialize PA Signal For TL11071 Cell3
#    Start Counter In vCU
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    Prepare And Attach UE    ue_index=${0}    ui_version=S21
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=${0}    capabilities=samsung
    sleep    10s    reason=wait call stable
    Delete pod    pod_name=po-cpnb-0
    Check VONR Call Status Active
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Emil Log For CB009795    ${trace_file_path}    dcap-master    start_counter=${1}    stop_counter=${0}
#    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Stop VONR Call For UE    ue_index=${0}
    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
    sleep    600s
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    Prepare And Attach UE    ue_index=1    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    Start VONR Call For UE    ue_index=1    capabilities=huawei_m40
    sleep    10s    reason=wait call stable
    Stop VONR Call For UE    ue_index=${1}
    Run Keyword And Ignore Error    Detach UE    ue_index=${1}
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Emil Log For CB009795    ${trace_file_path}    dcap-master    start_counter=${1}    stop_counter=${1}
#    Delete pod    pod_name=po-cpnb-1
    [Teardown]    Case Postcondition

CB009795_04_Cell_resources_register_deregistration_successfully_In_case_of_cell_activation_deactivation_after_CP-NB_failure_in_gNB-CU-CP
    [Tags]    CRT    CB009795_04
    [Documentation]
    ...    Author: shunxin.jin@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.10, Jin Shunxin, initial create case.
    ...    This case is to test the handling of the trace sessions and trace recording sessions in case of CP-NB instance failure.
    [Setup]    Case Precondition
    Open DCAP
    Initialize PA Signal For TL11071 Cell3
	Start Counter In vCU
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    Delete pod    pod_name=po-cpnb-0
    BTS Operation    operation=cell_lock            product_type=vcu    bts_index=0    distname_id=NRCELL-ALL     need_verify=yes
    BTS Operation    operation=cell_unlock          product_type=vcu    bts_index=0    distname_id=NRCELL-ALL     need_verify=yes
    Prepare And Attach UE    ue_index=${0}    ui_version=S21
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=${0}    capabilities=samsung
    sleep    20s    reason=wait call stable
    Stop VONR Call For UE    ue_index=${0}
	sleep    5s
    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Emil Log For CB009795    ${trace_file_path}    dcap-master    start_counter=${1}    stop_counter=${1}
	Check Emil Log For Trace Session Status    ${trace_file_path}    dcap-master    start_session=${3}    stop_session=${3}
#    Delete pod    pod_name=po-cpnb-1
    [Teardown]    Case Postcondition

CB009795_06_PCMD_and_Cell_trace_both_resiliency_during_CP-CL_CP-UE_CP-NB_failure_in_gNB-CU-CP
    [Tags]    CRT    CB009795_06
    [Documentation]
    ...    Author: shunxin.jin@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.10, Jin Shunxin, initial create case.
    ...    This case is to test the handling of the trace sessions and trace recording sessions in case of CP-UE instance failure,
	...    CP-CL instance failure and CP-NB instance failure in gNB-CU-CP.
    [Setup]    Case Precondition
    ${time}    DateTime.Get Current Date    result_format=timestamp
    ${start_time}=    Convert Time    ${time}
    Set Test Variable    ${start_time}
    Initialize PA Signal For TL11071 Cell3
    Start Counter In vCU
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
	Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=S21
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=${0}    capabilities=samsung
    sleep    10s    reason=wait call stable
    Delete pod    pod_name=po-cpnb-0
    Check VONR Call Status Active
    Delete pod    pod_name=po-cpue-0    fault_severity=major
    Check VONR Call Status Active
    Delete pod    pod_name=po-cpue-1    fault_severity=major
    Check VONR Call Status Active
	Stop VONR Call For UE    ue_index=${0}
    Delete pod    pod_name=po-cpcl-0    cell_enable_number=${0}    cell_disable_number=${3}
    Detach UE    ue_index=${0}
    Wait Until Keyword Succeeds    5min    1min    Check Cells status    enable_number=${3}    disable_number=${0}
	sleep    300s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Prepare And Attach UE    ue_index=1    ui_version=MATE40PROUI1.0
    Start DL and UL Call For UE    ue_index=${1}
    Start VONR Call For UE    ue_index=1    capabilities=huawei_m40
    sleep    10s    reason=wait call stable
    Stop VONR Call For UE    ue_index=${1}
	Detach UE    ue_index=${1}
    ${wireshark_cp_log_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
	Check Emil Log For Trace Session Status    ${trace_file_path}    dcap-master    start_session=${3}    stop_session=${3}
    Check Emil Log For CB009795    ${trace_file_path}    dcap-master    start_counter=${3}    stop_counter=${3}
    [Teardown]    Case Postcondition

CB009795_28_interaction_test_CB_FIM_46544
    [Tags]    CRT    CB009795_28_29
    [Documentation]
    ...    Author: shunxin.jin@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...                    2024.12.10, Jin Shunxin, initial create case.
    ...    This user scenario describes the handling of the trace sessions and trace recording sessions in case of
	...    active CP-CL instance failure in gNB-CU-CP.
    [Setup]    Case Precondition
	Parameter Updated In vCU
    ${time}    DateTime.Get Current Date    result_format=timestamp
    ${start_time}=    Convert Time    ${time}
	Set Test Variable    ${start_time}
    Initialize PA Signal For TL11071 Cell3
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
	Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=${0}    ui_version=S21
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=${0}    capabilities=samsung
    sleep    10s    reason=wait call stable
	Stop VONR Call For UE    ue_index=${0}
    Delete pod    pod_name=po-cpcl-0    cell_enable_number=${0}    cell_disable_number=${3}
	sleep    10s
    Detach UE    ue_index=${0}
    Wait Until Keyword Succeeds    5min    1min    Check Cells status    enable_number=${3}    disable_number=${0}
    ${wireshark_cp_log_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
	Check Emil Log For Trace Session Status    ${trace_file_path}    dcap-master    start_session=${3}    stop_session=${3}
    Check Emil Log For CB009795    ${trace_file_path}    dcap-master    start_counter=${1}    stop_counter=${1}
    [Teardown]    Case Postcondition

CB009795_12_PCMD_Trace_resiliency_during_TC_Master_instance_failure_in_gNB-CU-UP
    [Tags]    CRT    CB009795_12
    [Documentation]
    ...    Author: Sudi.lou@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition for TC12 TC21
    Initialize PA Signal For TL11071 Cell4
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    ute_ue.Require Ue    ue_alias=UE_1    capabilities=huawei_m40
    Prepare And Attach UE    ue_index=1    ui_version=MATE40PROUI1.0
    Start VONR Call Without Require UE    ue_index=${1}    vc_alias=VC_1
    sleep    30s    reason=wait call stable
    Trigger BTC failure    instance_abbr=TCM
    sleep    60s    reason=wait All TCM or TCC instance restarted
    Stop VONR Call For UE    ue_index=1
    Detach UE    ue_index=${1}
    Prepare And Attach UE    ue_index=1    ui_version=MATE40PROUI1.0
    Start VONR Call Without Require UE    ue_index=${1}    vc_alias=VC_1
    sleep    30s    reason=wait call stable
    Stop VONR Call For UE    ue_index=1
    Detach UE    ue_index=${1}
    sleep    30s    reason=wait log generated
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Log For CB009795_TC12    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition for TC12 TC21

CB009795_21_PCMD_and_Cell_trace_both_content_after_TCC_failure_in_gNB-CU-UP
    [Tags]    CRT    CB009795_21
    [Documentation]
    ...    Author: Sudi.lou@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition for TC12 TC21
    Initialize PA Signal For TL11071 Cell4
    ute_ue.Require Ue    ue_alias=UE_1    capabilities=huawei_m40
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu    syslogVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    FOR    ${index}    IN RANGE    1
        Log to Console    \n***The ${index} time to trigger TCC failure***
        Prepare And Attach UE    ue_index=1    ui_version=MATE40PROUI1.0
        Start VONR Call Without Require UE    ue_index=${1}    vc_alias=VC_1
        sleep    10s    reason=wait call stable
        Trigger BTC failure    instance_abbr=TCC
        sleep    180s    reason=wait All TCM or TCC instance restarted
        Stop VONR Call For UE    ue_index=1
        Detach UE    ue_index=${1}
        Prepare And Attach UE    ue_index=1    ui_version=MATE40PROUI1.0
        Start VONR Call Without Require UE    ue_index=${1}    vc_alias=VC_1
        sleep    10s    reason=wait call stable
        Stop VONR Call For UE    ue_index=1
        Detach UE    ue_index=${1}
        Log to Console    \n***${index} time test done***
    END
    sleep    10s    reason=wait log generated
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Log For CB009795_TC12    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition for TC12 TC21

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
#	vCU Online Delete MO Via Rest    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCUUP-1/NRCTRLTSCUUP-1    gnb_index=${0}
	Delete pod    pod_name=po-cpnb-1
	Delete pod    pod_name=po-cpcl-1
	Delete pod    pod_name=po-cpue-1

Case Postcondition
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Stop Trace In DCAP    btsip=${webem_info['host']}
	Delete pod    pod_name=po-cpnb-1
	Delete pod    pod_name=po-cpcl-1
	Delete pod    pod_name=po-cpue-1
#    vDU Login By Rest
#    Parameter Operation    operation=full_commission    product_type=vcu
#	...                    scf_path=${TEST_LOG_DIRECTORY}/backup_scf_vcu/vCU_scf.xml
#    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
#    Run Keyword And Ignore Error    Detach UE    ue_index=${1}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Convert Time
    [Arguments]    ${time_string}
    ${time_string}=    Replace String    ${time_string}    T    SPACE
    ${time_string}=    Replace String    ${time_string}    +00:00    EMPTY
    ${time_object}=    DateTime.Convert Date    ${time_string}    result_format=%Y-%m-%d %H:%M:%S.%f
    ${time_stamp}=    DateTime.Convert Date    ${time_object}    epoch
    [Return]    ${time_stamp}

Case Precondition for TC12 TC21
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition for TC12 TC21
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Stop Trace In DCAP    btsip=${webem_info['host']}
    Run Keyword And Ignore Error    Detach UE    ue_index=${1}
    Common Test Teardown For AIC

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    Log to Console    \n***UE detached.***

Initialize PA Signal For TL11071 Cell3
    SetInitializePAValue    pa_port=1-8;9;10;11;12-16;    pa_value=120;0;120;0;120;

Start VONR Call Without Require UE
    [Arguments]    ${ue_index}=${0}    ${vc_alias}=VC_2
    Start Voice Call    vc_alias=${vc_alias}   ue_alias=UE_${ue_index}    to=004488    duration=1800s

Check VONR Call Status Active
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check VONR Call Status Active***
    ${vc_status}    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Voice Call is not expected!

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Delete pod
    [Arguments]    ${vcu_namespace}=cran10    ${fault_severity}=critical    ${pod_name}=po-cpnb-0
    ...            ${cell_enable_number}=${3}    ${cell_disable_number}=${0}
    Trigger cmd    cmd=kubectl delete pod ${pod_name} -n ${vcu_namespace}
#    Wait Until Keyword Succeeds    300s    5s    Check Alarm    fault_id=4350
#	...                            fault_name=VNFC unavailable    severity=${fault_severity}    fault_status=active
	Run Keyword If    ${cell_disable_number}!=${0}    Check Cells status    enable_number=${cell_enable_number}    disable_number=${cell_disable_number}
    sleep    30s
    Check Alarm    fault_id=4350    fault_name=VNFC unavailable    severity=${fault_severity}    fault_status=inactive

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
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${cell_trace_log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.lcbin
    [Return]    ${cell_trace_log_file_paths}

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
    Should Be TRUE    ${start_counter}<=${StartRecordingSession_counter}
    Should Be TRUE    ${stop_counter}<=${StopRecordingSession_counter}

Check Emil Log For Trace Session Status
    [Arguments]    ${trace_file}    ${connection}    ${start_session}    ${stop_session}
    log to console    Check Emil log for CB009795
	${message_filter}    catenate   SEPARATOR="Message name"="NsetapX_StartSession";"Message name"="NsetapX_StopSession"
	${StartSession_counter}    set variable    ${0}
	${StopSession_counter}    set variable    ${0}
	FOR    ${trace}    IN    @{trace_file}
        ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace}    connection=${connection}
        ...                                                   filter=${message_filter}
	    ${StartSession_counter}    Get Counters Of Message Name    filter_name=NsetapX_StartSession
        ...                                                                 json_file=${json_file_path}
	    ...                                                                 counter=${StartSession_counter}
        ${StopSession_counter}    Get Counters Of Message Name    filter_name=NsetapX_StopSession
        ...                                                                json_file=${json_file_path}
	    ...                                                                counter=${StopSession_counter}
	END
    Should Be Equal    ${start_session}    ${StartSession_counter}
    Should Be Equal    ${stop_session}    ${StopSession_counter}

Get Counters Of Message Name
    [Arguments]    ${filter_name}    ${json_file}    ${counter}
    &{json_content}   evaluate    json.load(open("${json_file}", "r"))    json
    ${row_data}     set variable    ${json_content["emil_data"]["rows"]}
    FOR  ${content}   IN    @{row_data}
	    ${time}    Set Variable    ${content}[Time]
#		${message_time}    DateTime.Convert Date    ${time}    result_format=iso
		${message_time}=    Convert Time    ${time}
        run keyword if    "${content["Message_name"]}"=="${filter_name}" and ${message_time}>${start_time}
		...                Set Test Variable    ${counter}    ${counter + 1}
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


Start Counter In vCU
    ${counter1_list}    Create List    M55121C00501    M55121C00502
	${counter2_list}    Create List    M55119C00011    M55119C00014
	${counter3_list}    Create List    M55150C00008    M55150C00009
    ${rule_list}    Create List
    FOR    ${counter1_id}    IN    @{counter1_list}
       ${rule1}    Catenate
        ...         Distname: MRBTS-11071/NRBTS-11071;
        ...         Counter: ${counter1_id};
        ...         Counter rule: max(${counter1_id})>0;
        Append to list    ${rule_list}    ${rule1}
    END
	FOR    ${counter2_id}    IN    @{counter2_list}
       ${rule2}    Catenate
        ...         Distname: MRBTS-11071/NRBTS-11071;
        ...         Counter: ${counter2_id};
        ...         Counter rule: max(${counter2_id})>0;
        Append to list    ${rule_list}    ${rule2}
    END
	FOR    ${counter3_id}    IN    @{counter3_list}
       ${rule3}    Catenate
        ...         Distname: MRBTS-11071/NRBTS-11071/NRDU-2;
        ...         Counter: ${counter3_id};
        ...         Counter rule: max(${counter3_id})>0;
        Append to list    ${rule_list}    ${rule3}
    END
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}

Check Cells status
    [Arguments]    ${vdu_index}=1    ${gnb_index}=0    ${enable_number}=${3}    ${disable_number}=${0}
    ${alias}=    get unique id
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}    raw=True
	Should Be Equal As Numbers    ${vdu_cells_summary['basicCellsSummary']['operationalState']['enabled']}    ${enable_number}
    Should Be Equal As Numbers    ${vdu_cells_summary['basicCellsSummary']['operationalState']['disabled']}    ${disable_number}
	[Teardown]  vdu.disconnect    ${alias}

Parameter Updated In vCU
    @{para_list}          Create List    actSegUeCapUl    actCli
    @{mo_list_vcu}        Create List    MRBTS-11071/NRBTS-11071    MRBTS-11071/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list_true}    Create List    true    true
	Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu

VONR Call For Commercial UE
    [Arguments]    ${ue_index}=${1}    ${call_number}=004488    ${capabilities}=huawei_m40    ${vc_alias}=default
    ...            ${duration}=20s
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    ute_ue.detach_ue    UE_${ue_index}
    ute_ue.attach_ue    UE_${ue_index}
    Start Voice Call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=${call_number}    duration=${duration}
    Sleep    10s
    Stop Voice Call    vc_alias=${vc_alias}
    ute_ue.detach_ue    UE_${ue_index}

Initialize PA Signal For TL11071 Cell4
	SetInitializePAValue    pa_port=1-9;10;11;12;13-16;    pa_value=120;0;120;0;120;

Check Log For CB009795_TC12
    [Arguments]    ${trace_files}    ${connection}
    ${trace_message_count}    Create Dictionary    NsetapX_Configure=0    NsetapX_StartSession=0    NsetapX_IsAlive=0
    ...                                      NsetapX_StartRecordingSession=0    NsetapX_StopRecordingSession=0

    FOR    ${trace_file}    IN    @{trace_files}
        Get Trace Sessions related messages    ${trace_file}    ${trace_message_count}    ${connection}
    END

    Log To Console    The trace_message_count dict is: ${trace_message_count}

    Should Be True    ${trace_message_count}[NsetapX_Configure] >= ${0}
    Should Be True    ${trace_message_count}[NsetapX_StartSession] >= ${1}
    Should Be True    ${trace_message_count}[NsetapX_IsAlive] >= ${1}
    Should Be True    ${trace_message_count}[NsetapX_StartRecordingSession] >= ${1}
    Should Be True    ${trace_message_count}[NsetapX_StopRecordingSession] >= ${1}

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