*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot





*** Test Cases ***
CB009795_07_Monitoring_behavior_of_MBA_Trace_Session_with_PCMD_content_after_L3_layer_failure_in_gNB-CU-UP
    [Tags]    CRT    CB009795_07
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Download Wireshark Plugin Nsetapx
    Set Initialize PA Value    pa_port=5-8;1,2;9;    pa_value=0;127;127;
    Parameter Updated In vDU For CB009795
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Delete Pod    pod_name=cpnrt
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log For CB009795_07    wireshark_path=${local_file_path}
    [Teardown]    Case Postcondition

CB009795_03_PCMD_and_Cell_trace_both_resiliency_during_CP-NB_failure_in_gNB-CU-CP
    [Tags]    CRT    CB009795_03
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Set Initialize PA Value    pa_port=5-8;1,2;9;    pa_value=0;127;127;
    Parameter Updated In vDU For CB009795
    Start Counter In vCU
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    ne_type=vcu
    ...                                             vcu_custom_profile=${vcu_profile}
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Trigger cmd    cmd=kubectl delete pod po-cran8-cpnrt-0 -n cran8
    Check Alarm Exist
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    Check Emil Log For CB009795    ${trace_file_path}[0]    dcap-master
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Check Alarm Not Exist
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Parameter Updated In vDU For CB009795
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu

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

Check Wireshark Log For CB009795_07
    [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
    &{analysis_dict}       Create Dictionary    filter_conditions=NsetapX
    ${expect_message}=    Set Variable    NsetapX_StopRecordingSession
    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
    ...                           analysis_dict=${analysis_dict}
    Should Contain    ${result}    ${expect_message}

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}    ${ne_type}=vdu   ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    ...            ${gnb_index}=0    ${vdu_index}=0
    Log To Console    ${ne_type}
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
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
    ${zip_file_path}    Set Variable    ${trace_file_path}/@{zip_file_name}[0]
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
    [Arguments]    ${trace_file}    ${connection}
    ${message_filter}    Create List    User data=CUUP: CuUpPduSessionResourceInfoTraceRecord
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}
    Check Message In JSON File    ${json_file_path}

Check Message In JSON File
    [Arguments]    ${trace_file}
    ${parsed_json}    OperatingSystem.Get File    ${trace_file}
    ${context_dict}    json.Loads    ${parsed_json}
    ${flag}    Set Variable    False
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    FOR    ${trace}    IN    @{trace_info}
        ${return_info}    Run Keyword And Ignore Error    Check Jsoncontent in Emil Log    ${trace}
        ${flag}=    set variable if    '${return_info[0]}'=='PASS'    True
        exit for loop if    '${flag}'=='True'
    END
    should be equal    ${flag}    True    Check emil log failed!

Check Jsoncontent in Emil Log
    [Arguments]    ${emil_data}
    ${trace_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${trace_info}[CuUpVendorExtensionRecordDataType][pduSessionResourceInfoRecord][data]
    ${trigger}=    Set Variable    ${record_data}[trigger]
    ${result}=    Set Variable    ${record_data}[result]
    ${modified_pdu_sessions}=    Set Variable    ${record_data}[modifiedPduSessionResources]

    Should Be Equal    ${trigger}    pduSessionResourceModifyOperation
    Should Be Equal    ${result}    success

    ${pdu_session1_qfis}    Create List    ${1}    ${2}    ${3}
    ${pdu_session2_qfis}    Create List    ${1}
    FOR    ${session}    IN    @{modified_pdu_sessions}
        ${pdu_session_id}=    Set Variable    ${session}[pduSessionId]
        ${forwarding_qos_flows}=    Set Variable    ${session}[forwardingQosFlows]
        ${qfi_info}    Get qfi id in forwardingQosFlows list    ${forwarding_qos_flows}
        Run Keyword If    ${pdu_session_id}==1    Should Be Equal    ${pdu_session1_qfis}    ${qfi_info}
        ...    ELSE IF    ${pdu_session_id}==2    Should Be Equal    ${pdu_session2_qfis}    ${qfi_info}
    END

Get qfi id in forwardingQosFlows list
    [Arguments]    ${forwarding_qos_flows}
    ${qfi_list}    Create List
    FOR    ${qfi_info}    IN    @{forwarding_qos_flows}
        ${qfi}=    Set Variable    ${qfi_info}[qfi]
        append to list    ${qfi_list}    ${qfi}
    END
    [Return]   ${qfi_list}

Trigger cmd
    [Arguments]    ${cmd}    ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${pod_name}=up    ${alias}=vcu_master
    Log To Console    ${pod_name}
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    tafssh.execute    command=${cmd}    connection=${conn}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=${alias}

Check Alarm Exist
    &{expected_alarms}        Create Dictionary    fault_id=7523    fault_name=Cell Activation timeout at gNB-vDU
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary    fault_id=4001    fault_name=BTS reset required
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm Not Exist
    &{expected_alarms}        Create Dictionary    fault_id=7523    fault_name=Cell Activation timeout at gNB-vDU
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary    fault_id=4001    fault_name=BTS reset required
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${False}

Start Counter In vCU
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55119C00011,M55119C00014,M55150C00008,M55150C00009;
    ...         Counter rule: max(M55119C00011,M55119C00014,M55150C00008,M55150C00009)>=0
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}