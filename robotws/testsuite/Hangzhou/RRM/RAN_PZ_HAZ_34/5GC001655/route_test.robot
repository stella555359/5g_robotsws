*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02
Suite Setup    Common Suite Setup for COAM
Suite Teardown   robot_common_operations.Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_5G    QCP_5G
Test Timeout  8.5h
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Library    taf.transport.ssh    WITH NAME    csn
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.log.GnbLog    WITH NAME    GnbLog
Library    taf.rfrl.common_resources.python.TTI_Trace    WITH NAME    TTI_Trace
Library    taf.sw.scout    WITH NAME    scout
Resource   ../5GC001655/Resources/1347_common_keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/log.py
Resource   taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource   Resources/common_keyword_RRM_SG2.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${_scf_file_path}    ${tl_path}/common.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${scout_api_key}    16f117f7-24ca-4c34-8a64-ac892e74d6be
@{dl_ul_file_list}

${ReportGenerationPath}   C:\\Logfiles
${scf_path}    /home/ute/Downloads/SCF

# if using UE with spark in order:
# >>> ue_index + 1 = eq_index, spark eq_index start from 1, ue_index which used to refer tl.ues[] start from 0
# >>> selected_ue_index = eq_index, selected_ue_index is used to mapping physical ue in spark, starting form 1
${selected_ue_index}    ${1}
${num_of_ue_for_mue}    ${4}

${control_pc_ipaddr}    ${tl.ues[0].ssh_connection_details.addr}
${control_pc_username}  ${tl.ues[0].ssh_connection_details.username}
${appserver_ipaddr}     ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${appserver_username}   ${tl.ues[0].iperf_details.ssh_connection_details.username}
${appserver_password}   ${tl.ues[0].iperf_details.ssh_connection_details.password}
${topyoung_path}    \/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324

@{check_print}    ERR/

@{gap_time}    ${0}   ${15}   ${30}   ${45}
${TESTING_START_TIME}
${TESTING_END_TIME}

*** Test Cases ***
Route_DL_UL
    [Timeout]  1h
    [Setup]    Case Setup
    ${ue_index}    Evaluate  ${selected_ue_index}-1
    Route DL UL Run    log_file_name=${dl_ul_file_name}    timestamp=${timestamp}    ue_index=${ue_index}
    [Teardown]    Case Teardown

Route_DL_UL_MUE
    [Timeout]  1h
    [Setup]    Case Setup
    Route DL UL Run MultiUE     log_file_name=${dl_ul_file_name}    timestamp=${timestamp}
    [Teardown]    Case Teardown MultiUE

Export DL UL Report
    [Timeout]  1h
    COAM Create log directory
    Connect to gnb coam via ssl
    ${time} =   Get Time   min
    ${time}    Convert To Integer    ${time}
    ${wait}     sinmple_timer_2    min=${time}
    Log To Console    wait ${wait} minutes to collect snapshot and generate kpi report ...
    sleep    ${wait}m
    ${UTC_time}  DateTime.Get Current Date  result_format=%Y-%m-%dT%H:%M:%S  time_zone=UTC
    Set Global Variable    ${TESTING_END_TIME}    ${UTC_time}
    Log To Console    Testing is ended at UTC time: ${TESTING_END_TIME}
    Run Keyword And Continue On Failure    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure     Generate Scout KPI report

Generate_Hardcode_Report
    Set Global Variable    ${TESTING_START_TIME}    2025-12-30T07:15:42+00:00
    Set Global Variable    ${TESTING_END_TIME}    2025-12-30T08:00:10+00:00
    Generate Scout KPI report

*** Keywords ***
Case Setup
    #robot_common_operations.Common Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    COAM Check GNB cell on air
    ${build}    Coam Get Active SW Version
    ${split_result}    String.split string    string=${build}    separator=_
    ${big_build}    get from list    ${split_result}    0
    ${small_build}    get from list    ${split_result}    3
    ${first_name}    Replace String    ${big_build}    SBTS    5G
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${timestamp}
    set test variable    ${dl_ul_file_name}    ${first_name}_${small_build}_ROUTE_DL_UL_${timestamp}
    Run keyword and ignore error    recover MCS

Case Teardown
    Case Teardown Common    ue_num=1

Case Teardown MultiUE
    Case Teardown Common    ue_num=${num_of_ue_for_mue}

Generate Scout KPI report
    ${start_iso_time}=    Catenate    SEPARATOR=    ${TESTING_START_TIME}    +00:00
    ${end_iso_time}=    Catenate    SEPARATOR=    ${TESTING_END_TIME}    +00:00

    log to console   KPI_report_start_time ISO time: ${start_iso_time}
    log to console   KPI_report_end_time ISO time: ${end_iso_time}
    log to console    sleep for another 15 mins to keep scout happy
    sleep    15 min
    ${report_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${report_date}    Get Substring    ${report_time}    0    10

    ${build}    Coam Get Active SW Version
    ${kpi_report_name}   Catenate    SEPARATOR=_   VRF_SG02   ${report_date}   7_5_UTE5G402T10812   ${build}

    scout.setup_scout    scout_testline_name=7_5_UTE5G402T10812    api_key=${scout_api_key}    timeout=1800
    log to console    start to generate scout kpi report
    ${report}    scout.generate kpi report    report_name=${kpi_report_name}
    ...                                       template_id=1565
    ...                                       start_time=${start_iso_time}
    ...                                       end_time=${end_iso_time}

Case Teardown Common
    [Arguments]    ${ue_num}=1
    Comment    Run Keyword And Ignore Error    Recover swconfig file
    Comment    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${_scf_file_path}
    Run Keyword And Ignore Error    start or stop DL traffic in Appserver
    ...           command=ps -ef |grep '52228' | grep -v grep | awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    stop_spark_ul_traffic    ${control_pc_ipaddr}    ue=-1
    FOR    ${eq_index}    IN RANGE    1    ${ue_num}+1
        Run Keyword And Ignore Error    detach_spark_ue    host=${control_pc_ipaddr}    ue=${eq_index}
    END

    ${first_name}    Get gNB Release
    export excel from spark    first_name=${first_name}
    export pic report from spark

    robot_common_operations.Common Case Teardown
    check iperf process in Appserver
    Run keyword and ignore error    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    check syslog print    log_prefix=syslog_files    path=${TS_CASE_LOG_PATH}/btslog
    ...     log_path=${TS_CASE_LOG_PATH}    need_fail_case=${False}    target_print=${check_print}
    COAM Teardown gnb connections

Common Suite Setup for COAM
    Connect to gnb coam via ssl
    #check pdl after sw update    download_dir=/home/ute/Downloads
    robot_common_operations.Common Suite Setup
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Suite Variable     ${version}     ${result}[0]
    Run keyword and ignore error    Start Btslog Collect
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/scf_route_test.xml
    Run keyword and ignore error    Stop Btslog Collect    target_dir=${OUTPUT DIR}

Get gNB Release
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${split_result}    String.split string    string=${build}    separator=_
    ${big_build}    get from list    ${split_result}    0
    ${first_name}    Replace String    ${big_build}    SBTS    5G
    [return]    ${first_name}

Route DL UL Run
    [Arguments]    ${log_file_name}    ${timestamp}    ${ue_index}
    Run keyword and ignore error    Start Btslog Collect
    ${time} =   Get Time   min
    ${time}    Convert To Integer    ${time}
    ${wait}     sinmple_timer_2    min=${time}
    Log To Console    wait ${wait} minutes to start VDT ...
    sleep    ${wait}m
    ${UTC_time}  DateTime.Get Current Date  result_format=%Y-%m-%dT%H:%M:%S  time_zone=UTC
    Set Global Variable    ${TESTING_START_TIME}    ${UTC_time}
    Log To Console    Testing is started at UTC time: ${TESTING_START_TIME}
    UE Attach For spark    ue_index=${ue_index}
    check iperf process in Appserver
    UE Start Traffic     ue_index=${ue_index}
    sleep    10s
    ${ul_tput}    ${dl_tput}    UE Check Traffic    ue_index=${ue_index}
    start_test_record    host=${control_pc_ipaddr}    logpath=C:\\Logfiles\\    logname=${log_file_name}
    run_python_script_on_TestPC    host=${control_pc_ipaddr}    username=spark    password=spark
    ...    scriptpath=${topyoung_path}
    ...    script=python TPY.py \> result_${timestamp}.txt
    stop_test_record    host=${control_pc_ipaddr}
    check iperf process in Appserver
    set test variable    ${dl_ul_file_name}    ${log_file_name}-1.saf
    get saf log from spark    filename=${dl_ul_file_name}
    Append To List  ${dl_ul_file_list}   C:\\Logfiles\\${dl_ul_file_name}

Route DL UL Run MultiUE
    [Arguments]    ${log_file_name}    ${timestamp}
    Run keyword and ignore error    Start Btslog Collect
    UE Attach For MTU    num=${num_of_ue_for_mue}
    start_test_record    host=${control_pc_ipaddr}    logpath=C:\\Logfiles\\    logname=${log_file_name}
    run_python_script_on_TestPC    host=${control_pc_ipaddr}    username=spark    password=spark
    ...    scriptpath=${topyoung_path}
    ...    script=python TPY.py \> result_${timestamp}.txt
    stop_test_record    host=${control_pc_ipaddr}
    check iperf process in Appserver
    FOR    ${eq_index}    IN RANGE    1    ${num_of_ue_for_mue}+1
        set test variable    ${dl_ul_file_name}    ${log_file_name}-${eq_index}.saf
        get saf log from spark    filename=${dl_ul_file_name}
        Append To List  ${dl_ul_file_list}   C:\\Logfiles\\${dl_ul_file_name}
    END

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Modify Element Value
    [Arguments]    ${input_scf}    ${parameter_list}    ${output_scf}
    scf.load scf    ${input_scf}
    FOR    ${item}    IN    @{parameter_list}
        scf.modify_scf_element    dist_name=${item}[dist_name]    list_name=${item}[list_name]    value=${item}[value]
    END
    scf.save scf    ${output_scf}


UE Attach For Spark
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=False    power_reset=True
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}    power_reset=True
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    # wait for UE to setup PDU session
    Sleep    10s
    [Teardown]

UE Start Traffic
    [Arguments]    ${ue_index}=${0}    ${dl_traffic}=1500M/sec    ${send_duration}=1900   ${ue_mode}=SA
    ...    ${apn}=dxdata2    ${ul_traffic}=200M/sec
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    throughput=${dl_traffic}    duration=${send_duration}    ue_mode=${ue_mode}    apn_address=${apn}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_traffic}    duration=${send_duration}    ue_mode=${ue_mode}    apn_address=${apn}

UE Start UL Traffic
    [Arguments]    ${ue_index}=${0}    ${ul_traffic}=200M/sec    ${send_duration}=1900   ${ue_mode}=SA
    ...    ${apn}=dxdata2
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_traffic}    duration=${send_duration}    ue_mode=${ue_mode}    apn_address=${apn}

UE Check Traffic
    [Arguments]    ${ue_index}=${0}
    ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
    ${ul_tput}    Evaluate    ${output[0]} / 1024 / 1024
    ${dl_tput}    Evaluate    ${output[1]} / 1024 / 1024
    [return]    ${ul_tput}    ${dl_tput}


Dingli Stop traffic
    [Arguments]    ${ue_index}=${1}    ${dl}=dl    ${ul}=ul    ${ue_mode}=SA    ${apn}=dxdata2
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${dl}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${ul}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn}

Connect to ABIL
    [Arguments]    ${command}=bsh1:1    ${asik_alias}=ASIK Master
    ${connection}    csn.Execute    ${command}    connection=${asik_alias}
    [Return]    ${connection}

UE Attach For MTU
    [Arguments]    ${num}=8    ${attach_mode}=5G_SA    ${dl_traffic}=500M/sec    ${ul_traffic}=50M/sec
    FOR    ${ue_index}    IN RANGE    0    ${num}
        ${ue_type}    Get UE type    ue_index=${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=False
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
        power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
        UE Start Traffic    ue_index=${ue_index}    dl_traffic=${dl_traffic}    ul_traffic=${ul_traffic}
    END

get saf log from spark
    [Arguments]  ${filename}
    ...     ${spark_name}=${control_pc_username}
    ...     ${spark_addr}=${control_pc_ipaddr}
    Run Keyword And Ignore Error    run process
        ...  sudo sshpass scp ${spark_name}@${spark_addr}:/cygdrive/c/Logfiles/${filename} ${TS_CASE_LOG_PATH}/${filename}   shell=yes
    Sleep    10s
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${TS_CASE_LOG_PATH}/${filename}
    Sleep    3s

get report from spark
    [Arguments]
    ...     ${spark_name}=${control_pc_username}
    ...     ${spark_addr}=${control_pc_ipaddr}
    Run Keyword And Ignore Error    run process
        ...  sudo sshpass scp ${spark_name}@${spark_addr}:/cygdrive/c/Logfiles/*.xlsx ${OUTPUT DIR}/   shell=yes
    Sleep    10s
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${OUTPUT DIR}/*.xlsx
    Sleep    3s

check iperf process in Appserver
   [Arguments]
   ...     ${appserver_host}=${appserver_ipaddr}
   ...     ${appserver_username}=${appserver_username}
   ...     ${appserver_password}=${appserver_password}
   csn.connect_to    hostname=${appserver_host}    username=${appserver_username}
   ...               password=${appserver_password}    alias=APPserver
   set test variable    ${check_iperf_cmd}   ps -aux|grep iperf
   csn.send_command     command=${check_iperf_cmd}    connection=APPserver
   csn.Read Output  connection=APPserver
   csn.Disconnect    connection=APPserver

start or stop DL traffic in Appserver
   [Arguments]
   ...     ${command}
   ...     ${appserver_host}=${appserver_ipaddr}
   ...     ${appserver_username}=${appserver_username}
   ...     ${appserver_password}=${appserver_password}
   csn.connect_to    hostname=${appserver_host}    username=${appserver_username}
   ...               password=${appserver_password}    alias=APPserver
   csn.send_command     command=${command}    connection=APPserver
   csn.Disconnect    connection=APPserver

export excel from spark
    [Arguments]  ${first_name}
    [Timeout]  10min
    dele_report_on_pc    host=${control_pc_ipaddr}    username=spark    password=spark
    ...                  filename=\/cygdrive\/c\/Logfiles\/*.xlsx
    export_report_for_T10812  host=${control_pc_ipaddr}  Logfiles=${dl_ul_file_list}
    ...            ReportName=C:\\Logfiles\\${first_name}_TA_DL.rpt
    ...            ReportGenerationPath=${ReportGenerationPath}
    export_report_for_T10812  host=${control_pc_ipaddr}  Logfiles=${dl_ul_file_list}
    ...            ReportName=C:\\Logfiles\\${first_name}_TA_UL.rpt
    ...            ReportGenerationPath=${ReportGenerationPath}
    get report from spark

export pic report from spark
    [Arguments]
    [Timeout]  10min
    dele_report_on_pc    host=${control_pc_ipaddr}    username=spark    password=spark
    ...                  filename=\/cygdrive\/c\/Logfiles\/*.png
    FOR    ${per_ue_log_file}    IN    @{dl_ul_file_list}
        # {"CMD": "ExportLineChartPic", "Param":
        #     {"Logfile": "C:\\Logfiles\\5G26R2_251028_ROUTE_DL_UL_20251029-123129-1.saf",
        #      "Template": "DL_UL_route", "Minutes": 30, "ExportPath": "C:\\Logfiles"}
        # }
        export_line_chartPic_for_T962    host=${control_pc_ipaddr}   Logfiles=${per_ue_log_file}
        ...              Template=DL_UL_route    ExportPath=${ReportGenerationPath}    minutes=${30}
        Sleep    3s
    END
    get pic log from spark

get pic log from spark
    [Arguments]
    ...     ${spark_name}=${control_pc_username}
    ...     ${spark_addr}=${control_pc_ipaddr}
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass scp ${spark_name}@${spark_addr}:/cygdrive/c/Logfiles/*.png ${TS_CASE_LOG_PATH}/   shell=yes
    Sleep    10s
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${TS_CASE_LOG_PATH}/*.png
    Sleep    3s

recover MCS
    run_python_script_on_TestPC    host=${control_pc_ipaddr}    username=spark    password=spark
    ...    scriptpath=${topyoung_path}
    ...    script=python TPY.py TOPYOUNG_128x16_2023_0908_151324_firstframe.csv \> result_firstframe_${timestamp}.txt