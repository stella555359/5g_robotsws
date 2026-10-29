*** Settings ***
Documentation    This is for Spark MTU UE type
...    Author: Ding Binmei
...    Team conference Guide: https://confluence.ext.net.nokia.com/pages/editpage.action?pageId=1848066445
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot


*** Keywords ***
Keyword for search
    SSH connect to ue pc
    SSH disconnect to ue pc
    MTU ue attach and verify
    MTU ue detach
    MTU teardown ue   # Release socket connection, please use it carefully. can only for once in one case
    L3_call_MTU_Demo  # Show a demo with for L3 call with MTU


SSH connect to ue pc
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${ue_index}    ${ssh_alias}=ssh_ue_${ue_index}
    ssh.connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${ssh_alias}

SSH disconnect to ue pc
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${ue_index}    ${ssh_alias}=ssh_ue_${ue_index}
    ssh.disconnect    connection=${ssh_alias}

MTU prepare UE
    [Documentation]    Author: Ding Binmei
    ...    param list_ue_index: will convert to a list if string is provided.
    ...    In order to improve the efficiency for prepare ue for multiple ues, we must define our ue sequence in init file in order
    ...    like: ue 0 in init file, it's eq_index should be 1. IMSI should match
    [Arguments]    ${list_ue_index}    ${ue_type}=huawei_sigspark
    @{list_ue_index}    string_list.string2list    input_str=${list_ue_index}
    FOR    ${ue_index}    IN    @{list_ue_index}
        ${eq_index}    Evaluate    ${ue_index}+1
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True    get_spark_license=${False}
        ...    detach_request=${true}    force_check_ue=${True}    eq_index=${eq_index}
    END

MTU ue attach and verify
    [Timeout]    25 min
    [Documentation]    Author: Ding Binmei
    ...    param ue_config_map: should be a dict. E.G
    ...        {"ue_index1": {"attach_mode": "5G_SA", "apn_addr": "dxdata1"},
    ...        {"ue_index2": {},
    ...        {"ue_index3": {}}
    ...    param list_ue_index: will convert to a list if string is provided.
    ...    param is_prepare_ue_needed: ${True}, ${False}
    ...    param retry_time: retry time for ue attach
    [Arguments]    ${ue_config_map}    ${list_ue_index}=${0}    ${is_prepare_ue_needed}=${True}    ${ue_type}=huawei_sigspark
    ...    ${retry_time}=3
    @{list_ue_index}    string_list.string2list    input_str=${list_ue_index}
    run keyword if    ${is_prepare_ue_needed}==${True}    MTU prepare UE    list_ue_index=${list_ue_index}    ue_type=${ue_type}
    FOR    ${ue_index}    IN    @{list_ue_index}
         Retry attach if failed for single ue    ue_index=${ue_index}    retry_time=${retry_time}    ue_type=${ue_type}
         ...    attach_mode=${ue_config_map['${ue_index}']['attach_mode']}    ue_mode=MultiUE_SA
         ...    apn_addr=${ue_config_map['${ue_index}']['apn_addr']}
    END

Retry attach if failed for single ue
    [Documentation]    Author: Ding Binmei
    ...    param ue_index: The list index from tl.ues[]
    ...    param retry_time: retry time for ue attach
    ...    param attach_mode: 5G_SA,5G_NSA
    ...    param ue_mode: SA, LTE, MultiUE_SA; Used for get ue ip. For multi UE, please select MultiUE_SA
    ...    param apn_addr: should get rid of dot, e.g.:'wap1.nokia.com' should be set as 'wap1nokiacom'; used for get ue ip
    [Arguments]    ${ue_index}    ${retry_time}=3    ${ue_type}=huawei_sigspark
    ...    ${attach_mode}=5G_SA    ${ue_mode}=SA    ${apn_addr}=dtdata2
    ${attach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${attach_status}    run keyword and return status    Power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
         ...    attach_mode=${attach_mode}    power_reset=True
         ${attach_time}    Evaluate    ${attach_time}+1
         Run keyword if    ${attach_status}==${False}    Log to console    UE_${ue_index} attach failed due to attach response failed. Retry:${i}
         Continue For Loop If    ${attach_status}==${False}
        ${ue_ip}    spark.get_ue_ip_on_ue    ue_alias=UE_${ue_index}    apnaddress=${apn_addr}    ue_mode=${ue_mode}
        Log to console    Attach: UE IP for UE_${ue_index} is: ${ue_ip}
        ${ue_ip_status}    run keyword and return status    Wait Until Keyword Succeeds    1 min  5 sec
        ...    Verify ue ip exist after attach    ue_ip=${ue_ip}    ue_index=${ue_index}
        Exit for loop if    ${attach_status} and ${ue_ip_status}
        run keyword and continue on failure    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True
        Log to console   UE_${ue_index} attach failed due to ue ip verify failed. Retry:${i}
    END
    Should be true    ${attach_time} < ${retry_time}    msg=Retry UE_${ue_index} attach with ${retry_time} times and still failed

Verify ue ip exist after attach
    [Documentation]    Author: Ding Binmei
    ...    Verify if UE IP can be found from cmd ipconfig command after attach
    [Arguments]    ${ue_ip}    ${ue_index}    ${ssh_alias}=ssh_ue_${ue_index}
    Should Not Be Empty    ${ue_ip}    msg=UE IP is empty, please check if attach is OK
    SSH connect to ue pc    ue_index=${ue_index}    ssh_alias=${ssh_alias}
    ${cmd_check_ue_ip_exist}    Set variable    ipconfig|grep -ai ${ue_ip}
    ${output_ue_ip}    ssh.execute    command=${cmd_check_ue_ip_exist}    connection=${ssh_alias}
    ${output_ue_ip}    fetch_from_right    string=${output_ue_ip}    marker=:
    ${output_ue_ip}    strip_string    ${output_ue_ip}
    Should Be Equal As Strings    ${output_ue_ip}    ${ue_ip}    msg=UE index:${ue_index}, UE IP is not found from cmd after attach
    [Teardown]    SSH disconnect to ue pc    ue_index=${ue_index}    ssh_alias=${ssh_alias}

MTU ue detach
    [Documentation]    Author: Ding Binmei
    ...    param list_ue_index: will convert to a list if string is provided.
    [Arguments]    ${list_ue_index}=${0}    ${ue_type}=huawei_sigspark
    @{list_ue_index}    string_list.string2list    input_str=${list_ue_index}
    FOR    ${ue_index}    IN    @{list_ue_index}
        Run keyword and continue on failure    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True
    END

MTU teardown ue
    [Documentation]    Author: Ding Binmei
    ...    For multi UEs on one ue pc, just need to call for once. Purpose is to release sokect connection.
    ...    param ue_index: just input any ue_index which has called for prepare ue
    [Arguments]    ${ue_index}=0    ${ue_type}=huawei_sigspark
    spark.teardown    ue_alias=UE_${ue_index}

################################It's a demo for L3 call usage
L3_call_MTU_Demo
    [Documentation]    Author: Ding Binmei
    ...    Demo for L3 call with 2UEs attached. And tput check from both UE and aasyslog
    ...    For UE side, it only include 1 time tput record
    ...    : param UE_CONFIG_MAP: you can define in a python file to include all required UEs,
    ...        This info is used for prepare UE and format should be as bellow:
    ...            {"0": {
    ...                    "attach_mode": "5G_SA",
    ...                    "apn_addr": "dxdata2"},
    ...                "3": {
    ...                    "attach_mode": "5G_SA",
    ...                    "apn_addr": "dxdata2"}}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    run keyword if    '${has_cbts}'=='${True}'    Create log directory on cloud
    ...    ELSE    COAM Create log directory
    ${connection}    Set variable if    '${has_cbts}'=='${True}'  OAM_gnb0_du0    GNB_OAM
    ${UE_TYPE}    ue.translate_power_ue_type_from_testline
    set suite variable    ${UE_TYPE}
    ${UE_CONFIG_MAP}    Catenate   SEPARATOR=${EMPTY}     {"0": {"attach_mode": "5G_SA", "apn_addr": "dxdata2"},
    ...    "3": {"attach_mode": "5G_SA", "apn_addr": "dxdata2"}}
    ${UE_CONFIG_MAP}    Evaluate    dict(${UE_CONFIG_MAP})
    MTU prepare UE    list_ue_index=0,3
    Start capture F1AP log    tcpdump_collector_name=verify_attach    options=-i any sctp
    MTU ue attach and verify    ue_config_map=${UE_CONFIG_MAP}    list_ue_index=0,3    is_prepare_ue_needed=${False}
    ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=verify_attach
    Log to console    traffic started for UE 1
    Start data transfer based on direction     dl_tput=20Mbit/sec    ul_tput=20Mbit/sec    duration=300    ue_index=0
    Log to console    traffic started for UE 4
    Start data transfer based on direction     dl_tput=20Mbit/sec    ul_tput=20Mbit/sec    duration=300    ue_index=3
    Log to console    Monitor tput after 60s
    Sleep    60s
    Log to console    Check tput from UE
    ${tput_spark_result_UE0}       power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=1s    check_source=spark    ue_index=0
    ${tput_spark_result_UE3}       power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=1s    check_source=spark    ue_index=3
    Run Keyword And Continue On Failure    power_ue.Check Bi Tput    ue_type=${ue_type}   log=${tput_spark_result_UE0}
    ...        cells=3   ultarget_throughput=20    dltarget_throughput=20     customized_log_name=check_tput    check_source=spark
        Run Keyword And Continue On Failure    power_ue.Check Bi Tput    ue_type=${ue_type}   log=${tput_spark_result_UE3}
    ...        cells=3   ultarget_throughput=20    dltarget_throughput=20     customized_log_name=check_tput    check_source=spark
    Log to console    Check tput from GNB

    run keyword if    '${has_cbts}'=='${True}'    Connect to vdu via rest api
    ...    ELSE    Connect to gnb coam via ssl
    ${tput_log_path}       run keyword if    '${has_cbts}'=='${True}'
    ...    Cloud Standard Capturing Kubectl Throughput
    ...       gnb_index=${0}   vdu_index=${0}
    ...       duration=30s    check_tput_ignore_time=10s
    ...    ELSE        power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=30s
    ...                   ignore_time=10s    filter=L2Lo    check_source=aasyslog
    Check tput via power UE optimized    cell_index=3    tput_log_path=${tput_log_path}    direction=both
    ...    exp_ul=40    exp_dl=40
    ...    exp_ul_indiv=${None}    exp_dl_indiv=${None}    connection=${connection}
    ...    customized_log_name=validate_tput    is_need_to_fail_keyword=${True}
    ...    is_analysis_log_captured=${False}
    ...    connection=OAM_gnb0_du0
    [Teardown]    _Teardown L3 call

_Teardown L3 call
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword And Ignore Error    Stop Tcpdump via collector    tcpdump_collector_name=verify_attach

    Stop data transfer based on direction    data_transfer_direction=both    ue_index=0
    Stop data transfer based on direction    data_transfer_direction=both    ue_index=3
    MTU ue detach    list_ue_index=0,3
#    MTU teardown ue    ue_index=0
    run keyword if    '${has_cbts}'=='${True}'    vDU.Teardown vdu connection
    ...    ELSE    COAM Teardown gnb connections
