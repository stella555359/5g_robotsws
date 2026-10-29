*** Settings ***
Documentation
...   Author: xiaowei.1.chen@nokia-sbell.com
...   Contact: xiaowei.1.chen@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Run keywords   Common Suite Setup For RRM  AND  Update bsr package
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    120 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../../T01/Resources/RRM2_RRM_Resource.robot
*** Variables ***
${QoS Routing Table}
...    QoS Routing Table :
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
@{field_names_1}         _ws.col.No.     _ws.col.Source    _ws.col.Info
${extra_conditions}      -E header=y -E separator=, -E quote=d -E occurrence=a

&{rad_param_dict1}    name=rdFeatureFlagBitmap6   value=0000000001
&{rad_param_dict2}    name=rdFeatureFlagBitmapLevel   value=4
@{rad_param_list}     ${rad_param_dict1}    ${rad_param_dict2}
${MAX_RETRIES}                 3
*** Test Cases ***
Case_Precondition
    Case Precondition
    Run Keyword And Ignore Error   Scout_cli start
    Prepare Netrc On VM
    Set L2PS Rad Debug Paramters     ${rad_param_list}

[1][1.0] CB008118_B#B3_TC11__GBR_congestion_detection_and_handling_for_UL
   [Tags]    QC_251200       QCD_MN_RAN      QCP_RAN_VRF
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118_RJIO
   FOR     ${ue_id}    IN RANGE     1    6
       ${index}    Set Variable    ${ue_id}
       Establish mcs-PriorityAccess    ue_id=${ue_id}
   END
   FOR    ${i}    IN RANGE    ${MAX_RETRIES}
       Log To Console    === (UL) Counter 第 ${i+1} 次采集尝试 ===
       UE Deregister From gNB      ue_id=1-180    cell=1
       ${ue_id}    Set Variable    1-5
       Run Keyword And Ignore Error    UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=17
       ...    pass_regexp=${QoS Routing Table}
       Run Keyword And Ignore Error    Send UL GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
       Start Collect Mutli Counter For UL     cell=1
       sleep    600s
        ${status}    ${message}=    Run Keyword And Ignore Error    Stop Collect Mutli Counter
        Log To Console    Stop Collect 第 ${i+1} 次输出: status=${status}, message=${message}
        Run Keyword If    '${status}'=='PASS'    Log To Console    check_result 通过，继续执行后续步骤
        Run Keyword If    '${status}'=='PASS'    Exit For Loop
        Run Keyword If    '${status}'=='FAIL' and 'check_result is False' in """${message}"""
        ...    Log To Console    check_result False，重新开始采集
        Run Keyword If    '${status}'=='FAIL' and 'check_result is False' in """${message}"""
        ...    Continue For Loop
        Log To Console    Stop Collect 失败且非 check_result False，终止用例: ${message}
        Fail    Stop Collect 异常: ${message}
   END
   Run Keyword Unless    '${status}'=='PASS'    Fail    Counter 规则连续 ${MAX_RETRIES} 次未满足

*** Keywords ***
Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=CB008118_RJIO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    log_to_console    Plugin download
    start_dcap_controller_common

Set L2PS Rad Debug Paramters
    [Arguments]    ${rad_param_list}   ${timeout}=60   ${alias}=gnb_conn
    [Documentation]  Keyword for setting rnd parameter values
    coam.setup_admin   bts_host=192.168.255.129    alias=${alias}
    sleep    10s
    ${res_1}   coam.set_multiple_rad_debug_parameters    domain=L2PS   persistency=Persistent   rad_parameters=${rad_param_list}
    ...           timeout=${timeout}  connection=${alias}
    [Teardown]   coam.teardown_admin   alias=${alias}
UE Deregister From gNB
    [Arguments]    ${ue_id}=1    ${cell}=6
    Airphone Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep    2s
    Airphone Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}
    sleep     5s
UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${qos_flow}=5  ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep   5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal default_qos_flow=${qos_flow}
    sleep   5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}
    sleep   5s
UE PDU Session Setup
    [Arguments]    ${ue_id}=1  ${pdu}=2  ${qos_flow}=5  ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal default_qos_flow=${qos_flow}
    sleep   5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=1    pass_regexp=${pass_regexp}
    sleep   5s
Send NonGBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=1 protocol=udp mbps=20
#    ...    pass_regexp=UE ${ue_id}: UDP DL
    sleep   2s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=2 protocol=udp mbps=10
#    ...    pass_regexp=UE ${ue_id}: UDP UL
    sleep   2s
Send GBR Throughput
    [Arguments]    ${ue_id}=${ue_id}    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3 protocol=tcp mbps=1
    ...    pass_regexp=UE ${ue_id}: TCP DL
    sleep   5s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4 protocol=tcp mbps=1
    ...    pass_regexp=UE ${ue_id}: TCP UL
    sleep   5s
Send DL GBR Throughput
    [Arguments]    ${ue_id}=${ue_id}    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3 protocol=tcp mbps=1
    ...    pass_regexp=UE ${ue_id}: TCP DL
    sleep   5s
Send UL GBR Throughput
    [Arguments]    ${ue_id}=${ue_id}    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4 protocol=tcp mbps=30
    ...    pass_regexp=UE ${ue_id}: TCP UL
    sleep   5s
Establish mcs-PriorityAccess
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mcs-PriorityAccess
    Sleep   2s
Check Traffic
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command     ue_stats_nr id=${ue_id} type=pdsch
    Airphone Execute Egate Command     ue_stats_nr id=${ue_id} type=pusch
Start Collect Wireshark For GNB
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep     5s
    sleep     5s
Stop Wireshark log For GNB
    sleep    8s
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
    sleep    2s
    [Return]    ${local_file_path}
Analyze Wireshark log
    [Arguments]    ${local_file_path}    ${wireshark_analysis_dict}
    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${wireshark_analysis_dict}
    Log To Console    \nAnalyze log: ${result}
Start TTI For GNB
    [Arguments]    ${cell_num}=6
    ${nrCells}    Catenate    NRCELL_R-    ${cell_num}
    ${dcap_argument}   Create Dictionary   nrCells=${nrCells}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti+syslog    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    #emil+tti+syslog+snapshot
Stop TTI For GNB
    ${local_file_path}    Log Collection    stop_and_download    tti+syslog   product_type=gnb    bts_index=${0}    cudu_index=${0}
Modify Parameter
    [Arguments]    ${para}    ${mo_list}     ${value}
    @{para_list}          Create List    ${para}
    @{mo_list}            Create List    ${mo_list}
    @{value_list_true}    Create List    ${value}
    ${out}                Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list}
    Log To Console        gnb paramter update result: ${out}
    sleep   10s

Modify Parameter maxNumOfSCellAlloc
    [Arguments]    ${value}
    @{para_list}          Create List    maxNumOfRrcSA     maxNumOfSCellAlloc
    @{mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    @{value_list_true}    Create List    ${value}    ${value}
    ${out}                Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list}
    Log To Console        gnb paramter update result: ${out}
    sleep   10s

Check NonGBR UE Tput
    [Arguments]    ${ue_id}=1
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=1    dir=dl    trf_id=1    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} DL ave tput is ${ave_tput_str.lower()}
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=1    dir=ul    trf_id=2    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} UL ave tput is ${ave_tput_str.lower()}
Check GBR UE Tput
    [Arguments]    ${ue_id}=1  ${qfi}=1
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=${qfi}    dir=dl    trf_id=3    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} DL ave tput is ${ave_tput_str.lower()}
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}
    ...                                                  qfi=${qfi}    dir=ul    trf_id=4    type=l3
    ...                                                  call_type=SA    pdu_id=1
    ${ave_tput_str}    Convert To String    ${ave_tput}
    log_to_console     UE${ue_id} UL ave tput is ${ave_tput_str.lower()}
    sleep   5s
Start Collect Mutli Counter For DL
    [Arguments]    ${cell}=6
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-${cell};
    ...         Counter: M55300C00049;
    ...         Counter rule:avg(M55300C00049)>=0;
    append to list  ${rule_list}    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Start Collect Mutli Counter For UL
    [Arguments]    ${cell}=6
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-${cell};
    ...         Counter: M55370C00050;
    ...         Counter rule:avg(M55370C00050)>=0;
    append to list  ${rule_list}    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Stop Collect Mutli Counter
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    [Return]    ${value1}

Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin
Teardown
    coam.teardown admin