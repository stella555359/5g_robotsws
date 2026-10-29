# @Time    : 2023/6/5 14:26
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB008132-10UE.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB008132-10UE

Suite Setup         Run Keywords    robot_common_operations.Common Suite Setup
...    AND          CI_interface.Common Suite Setup
Suite Teardown      Run Keywords    robot_common_operations.Common Suite Teardown
...    AND          Change PA
Test Setup          Run Keywords    robot_common_operations.Common Case Setup    allowed_faults_ids=1933,4298
...    AND          Connect to gnb coam via ssl
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Library    taf.sw.scout    WITH NAME    scout
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Variables    ${CURDIR}/8ue_profile.py
Variables    spark_ue_config.py

*** Variables ***
${UE01}    ${UE1}
${UE02}    ${UE2}
${UE03}    ${UE3}
${UE04}    ${UE1}
${UE05}    ${UE1}
${UE06}    ${UE1}
${UE07}    ${UE7}
${UE08}    ${UE7}

${TEST_RESULT_REPORT_TEMPLATE}    /home/ute/MMW_SG5/test_result_report_template.xlsx
@{BTS_CUSTOM_PROFILE}    immediateSnapshot
@{CUSTOM_PROFILE}    condor5gSyslog    cp_5g
#@{CUSTOM_PROFILE}    condor5gSyslog    cp_5g    L2Lo_Component    L2HiRlc_Component    L2HiPdcp_Component
@{CUSTOM_PROFILE_2}    condor5gSyslog    Tracer_5g    cp_5g    L2Ps_Component    L2Lo_Component    L2HiRlc_Component    L2HiPdcp_Component
${DCAP_NR_CELLS}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${NRBTS_ID}/NRCELL_R-3
${IWK_SCF}        ${CURDIR}/resources/IWK_golden_qos_scf_delete_8232.xml

#@{UE_ALIAS}    ue1    ue2    ue3    ue4    ue5    ue6    ue7    ue8
${UE_ALIAS}    SPARK_UE
@{UE_INDEX}    0    1    2    3    4    5    6    7
@{SCOUT_REPORTS}    EUE_QOS_VRF_HAZ3_5_PDCP_RLC_DELAY    2362
...    List1_KPI_TMO_24R1_SA_SG6    1565
...    EUE_QOS_VRF_HAZ3_5_FAILUE_COUNTER_WITHOUT_DEPLAY    2361
...    EUE_QOS_VRF_HAZ3_5_SYSTEM_PERFORMANCE    2360
...    EUE_QOS_VRF_HAZ3_5_PDCP_TROUBLESHOOT    2359

*** Test Cases ***
DL_UL PA29
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c01
    COMMON DL_UL    pa=15    environment=PA29    rsrp=RSRP=-80

DL_UL PA49
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c02
    COMMON DL_UL    pa=33    environment=PA49    rsrp=RSRP=-105

*** Keywords ***
COMMON DL_UL
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/05/28 15:27
    [Arguments]    ${pa}=15    ${environment}=PA29    ${rsrp}=RSRP=-80

    # 1-Modify PA, clear iperf
    Close Iperf On Appserver And Control PC
    Log to console    \n*****change PA, test in quality signal of ${environment}*****
    Change PA    pa=${pa}

    # 2-Get scout report time
    Log to console    \n*****wait for until time is integer multiple of one quarter......*****
    ${attach_time}    wait_until_latest_quarter_time
    ${traffic_time1}    DateTime.add_time_to_date    date=${attach_time}    time=15m
    ${traffic_time2}    DateTime.add_time_to_date    date=${traffic_time1}    time=15m
    ${traffic_time3}    DateTime.add_time_to_date    date=${traffic_time2}    time=15m
    ${traffic_time4}    DateTime.add_time_to_date    date=${traffic_time3}    time=15m
    ${detach_time}    DateTime.add_time_to_date    date=${traffic_time4}    time=15m
    Log to console    \n*****Caculated timestamps are :*****
    Log to console    \n*****attach_time = ${attach_time}*****
    Log to console    \n*****traffic_time1 = ${traffic_time1}*****
    Log to console    \n*****traffic_time2 = ${traffic_time2}*****
    Log to console    \n*****traffic_time3 = ${traffic_time3}*****
    Log to console    \n*****traffic_time4 = ${traffic_time4}*****
    Log to console    \n*****detach_time = ${detach_time}*****

    # 3-DCAP capture log start
    Run Keyword And Ignore Error    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}
    ...    bts_profile_list=${BTS_CUSTOM_PROFILE}    host=10.57.195.96
    Log to console    \n*****start to capture trace via DCAP*****

    # 4-Prepare UE
    Log to console    \n*****UEs attach*****
    sparkMultiUE_yiyuan.require_ue    ue_alias=${UE_ALIAS}    multiue_traffic_config=${TLCommonConfig["MultiUECFG"]}
    ...    restart_ue=${True}    get_spark_license=${False}    is_need_reconnect_spark=${False}
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${UE_ALIAS}
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${UE_ALIAS}
    Wait Until Keyword Succeeds    3min    10s    Verify Ue Status Normal
    Log to console    \n*****UEs attach successfully*****

    # 5-UE start UL&DL UDP traffic
    # reserve code to capture L2 component trace for long time
#    Collect L2 trace

    ${start_tput_time}    DateTime.get_current_date
    Log to console    \n*****Start UL traffic at ${start_tput_time}*****
    Multi-UES Start UL UDP
    Log to console    \n*****Start DL traffic at ${start_tput_time}*****
    Multi-UES Start DL UDP

    # 6-Wait 75min and check iperf status
    # Collect L2 trace
    Repeat Keyword    75 minutes    Multi-UES Check DL UDP

    # 7-Detach UE, close iperf
    ${stop_tput_time}    DateTime.get_current_date
    Log to console    \n*****Stop UL&DL traffic at ${stop_tput_time}*****
    Close Iperf On Appserver And Control PC
    # wait for 1 second before detatch UEs
    Sleep    1s
    Log to console    \n*****UEs detach*****
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${UE_ALIAS}
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID
    # 8-Wait 35min
    Sleep    35min

    # 9-Generate scout report 6*4
    Log to console    \n*****generate KPI report*****
    Generate KPI Report To Scout    scout_reports=${SCOUT_REPORTS}    start_time=${attach_time}    rsrp=${rsrp}    time=1
    Generate KPI Report To Scout    scout_reports=${SCOUT_REPORTS}    start_time=${traffic_time1}    rsrp=${rsrp}    time=2
    Generate KPI Report To Scout    scout_reports=${SCOUT_REPORTS}    start_time=${traffic_time2}    rsrp=${rsrp}    time=3
    Generate KPI Report To Scout    scout_reports=${SCOUT_REPORTS}    start_time=${traffic_time3}    rsrp=${rsrp}    time=4
    Generate KPI Report To Scout    scout_reports=${SCOUT_REPORTS}    start_time=${traffic_time4}    rsrp=${rsrp}    time=5
    Generate KPI Report To Scout    scout_reports=${SCOUT_REPORTS}    start_time=${detach_time}    rsrp=${rsrp}    time=6

    add_operation_history_for_qos    time=${start_tput_time}    operation="start Tput"    environment=${environment}
    add_operation_history_for_qos    time=${traffic_time1}    operation="generate KPI report1"    environment=${environment}
    add_operation_history_for_qos    time=${traffic_time2}    operation="generate KPI report2"    environment=${environment}
    add_operation_history_for_qos    time=${traffic_time3}    operation="generate KPI report3"    environment=${environment}
    add_operation_history_for_qos    time=${traffic_time4}    operation="generate KPI report4"    environment=${environment}
    add_operation_history_for_qos    time=${stop_tput_time}    operation="stop Tput"    environment=${environment}

    ${scf_file_path}    coam.get_current_scf_file    local_dir_path=${TS_LOG_PATH_BASE}
    ...    file_name=1970_cur_scf.xml    connection=GNB_OAM    timeout=60
    ${sw_version}    coam.get_sw_version    connection=GNB_OAM
    add_cur_scf_for_8132_via_http_request    ${scf_file_path}    ${sw_version}

    [Teardown]    Run Keyword    Common TearDown

Common TearDown
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID
    #reserve code to capture L2 component trace for long time
    # Run Keyword And Ignore Error    csn.Disconnect    connection=LOG_UTE

Collect L2 trace
    csn.Connect to    hostname=10.57.159.138
    ...               username=ute
    ...               password=iW_K#8.ute%A10h0m0ra
    ...               alias=LOG_UTE
    csn.send command    command=cd gnb_logs/ && sudo ./gnb_logs 10.71.202.138 -e 4500 -o l2lo -o l2ps -C3&    connection=LOG_UTE
    csn.Read Output Until    match=Now monitoring ongoing, would collect    timeout=180s    connection=LOG_UTE

Capturing Aasyslog with duration
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                Author: Civen Chen
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU   ${duration}=20s    ${Teardown_after_finished}=${True}
    ...            ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738    ${filter}=${EMPTY}
    ...            ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                      aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                      host=${host}    username=${username}    password=${password}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                 gnb_path=${gnb_path}    log_name=${log_name}
    ...                                 host=${host}    username=${username}    password=${password}
    ...                                 log_ip=${log_ip}    timeout=${duration}
    sleep    ${duration}
    ${current_time}    DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${local_path}    set variable    /home/ute/MMW_SG5/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                gnb_index=${gnb_index}    du_index=${du_index}
    ...                                host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    run keyword if    '${Teardown_after_finished}'=='${True}'
    ...           Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                  host=${host}    username=${username}    password=${password}

Generate KPI Report To Scout
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${scout_reports}
    ...    ${start_time}
    ...    ${rsrp}=RSRP=-105
    ...    ${time}=1
    ...    ${scout_testline_name}=7_5_UTE5G402T1970
    ...    ${api_key}=8bfe8faa-b101-4283-8a7f-6e684b8c929f
    ${end_time}    DateTime.add_time_to_date    date=${start_time}    time=15m
    ${start_time_tz}    Set Variable    ${start_time}-00:00
    ${end_time_tz}    Set Variable    ${end_time}-00:00
    scout.setup_scout    scout_testline_name=${scout_testline_name}    timeout=900    api_key=${api_key}

    ${fiveqi_dict}    Create Dictionary    &{EMPTY}
    FOR    ${report_name}    ${template_id}    IN    @{scout_reports}
        ${kpi_reports}    scout.generate_kpi_report    report_name=${rsrp}_${time}    template_id=${template_id}
        ...    start_time=${start_time_tz}    end_time=${end_time_tz}
        Get KPI For All Templates    fiveqi_dict=${fiveqi_dict}    reports=${kpi_reports[0]["report"]}
    END
    ${sw_version}    coam.get_sw_version    connection=GNB_OAM
    add_new_line_to_target_sheet_for_8132_via_http_request
    ...    rsrp=${rsrp}    build=${sw_version}    time=${time}    fiveqi_dict=${fiveqi_dict}    testline=${scout_testline_name}

Get KPI For All Templates
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/05/29 11:23
    [Arguments]    ${fiveqi_dict}    ${reports}
    FOR    ${report}    IN    @{reports}
        Set To Dictionary    ${fiveqi_dict}    ${report["code"]}=${report["global_result"]["value"]}
    END

Close Iperf On Appserver And Control PC
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Connect to APPserver
    FOR    ${port}    IN    @{all_5qi_ports}
        Close the iperf process on APPserver    port=${port}
    END
    Connect to control pc enhanced    ue_index=0
    csn.send_command    command=ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9
    ...    connection=cpc_0

Multi-UES Start DL UDP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${8ues_name_ip_dict}    Get UE IPS From Control PC
    ${8ues_name_ip_list}    Get Dictionary Items    ${8ues_name_ip_dict}
    FOR    ${ue_name}    ${ue_ip}    IN    @{8ues_name_ip_list}
        UE Start Multi-Ports DL UDP    ue_ip=${ue_ip}    dl_port_params=${${ue_name}}[dl]
    END

UE Start Multi-Ports DL UDP
    [Documentation]    changed by zihao.li@nokia-sbell.com due to using new profile 2024-4-15
    [Arguments]    ${ue_ip}    ${dl_port_params}    ${dl_time}=5400    ${cpc}=APPserver
    Connect to APPserver
    FOR    ${d}    IN    @{dl_port_params}
        csn.send command
        ...    command=iperf -c ${ue_ip} -u -t ${dl_time} -i 1 -p ${d["port"]} -P 1 -f m -b ${d["throughput"]} -l ${d["size"]} -T 64&
        ...    connection=${cpc}
    END

Multi-UES Check DL UDP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Sleep    5min
    ${8ues_name_ip_dict}    Get UE IPS From Control PC
    ${8ues_name_ip_list}    Get Dictionary Items    ${8ues_name_ip_dict}
    FOR    ${ue_name}    ${ue_ip}    IN    @{8ues_name_ip_list}
        UE Check Multi-Ports DL UDP    ue_ip=${ue_ip}    dl_port_params=${${ue_name}}[dl]
    END

UE Check Multi-Ports DL UDP
    [Documentation]    changed by zihao.li@nokia-sbell.com due to using new profile 2024-4-15
    [Arguments]    ${ue_ip}    ${dl_port_params}    ${dl_time}=5400    ${cpc}=APPserver
    Connect to APPserver
    FOR    ${d}    IN    @{dl_port_params}
        csn.send command
        ...    command=ps -ef | grep 'iperf -c ${ue_ip}' | grep ${d["port"]}
        ...    connection=${cpc}
        ${check_iperf}    csn.Read Output    connection=${cpc}
        Run Keyword And Ignore Error    Should Contain    ${check_iperf}
        ...    iperf -c ${ue_ip} -u -t ${dl_time} -i 1 -p ${d["port"]} -P 1 -f m -b ${d["throughput"]} -l ${d["size"]} -T 64
    END

Multi-UES Start UL UDP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${8ues_name_ip_dict}    Get UE IPS From Control PC
    ${8ues_name_ip_list}    Get Dictionary Items    ${8ues_name_ip_dict}
    FOR    ${ue_name}    ${ue_ip}    IN    @{8ues_name_ip_list}
        UE Start Multi-Ports UL UDP    ue_ip=${ue_ip}    ul_port_params=${${ue_name}}[ul]
    END

UE Start Multi-Ports UL UDP
    [Documentation]    changed by zihao.li@nokia-sbell.com due to using new profile 2024-4-15
    [Arguments]    ${ue_ip}    ${ul_port_params}    ${ul_time}=5400    ${cpc}=cpc_0
    ...    ${appserver}=10.71.207.139
    FOR    ${u}    IN    @{ul_port_params}
        csn.send command
        ...    command=iperf -c ${appserver} -t ${ul_time} -P 1 -p ${u["port"]} -i 1 -l ${u["size"]} -b ${u["throughput"]} -u -B ${ue_ip}&
        ...    connection=${cpc}
    END

Verify Ue Status Normal
    [Documentation]    check UE status if it's normal, namely attach successfully.
    [Arguments]    ${cpc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[0].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[0].ssh_connection_details.password}

    Log to console    \n*****verify UE status is normal*****
    Connect to control pc enhanced    cpc_ip=${cpc_ip}
    ...    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    # get UE number in init file
    ${numberOfUe}    Get Length    ${tl.ues}
    ${ue_ips}    Get UE IPS From Control PC
    ${ue_ips_keys}    Get Dictionary Keys    ${ue_ips}
    ${ip_num}    Get Length    ${ue_ips_keys}
    ${numberOfUe}    Evaluate    ${numberOfUe} - 2
    Should Be Equal As Integers    ${numberOfUe}    ${ip_num}
    Log to console    \n*****all ue status are successful, obtain PDU session IP*****

Change PA
    [Arguments]    ${pa}=15
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    13=${pa}    14=${pa}    15=${pa}    16=${pa}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}

