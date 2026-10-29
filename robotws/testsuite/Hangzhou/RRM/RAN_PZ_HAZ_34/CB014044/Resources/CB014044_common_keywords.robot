*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB014044
Library     DateTime
Library     OperatingSystem
Library     Process
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_Common_Keywords.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/upgrade_rollback_keywords.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/SFE_TMO_HO_common_keywords.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_pionner_mtu_keywords.py
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_Variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/dingli_multiUE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/spark_multiUE.robot


*** Variables ***
${case_logs_path}    /opt/workspace/CRT/Master/Case_Logs/
${btslog_ini_file_path}    /opt/workspace/SCF/
${gnb_instance}     ${tl.gnbs[0].instance_id}
${path}    /opt/workspace/SCF/SA_kpi_report.yml
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/

${UEPC_host}                                 ${tl.ues[0].ssh_connection_details.addr}
${UEPC_username}                             ${tl.ues[0].ssh_connection_details.username}
${UEPC_password}                             ${tl.ues[0].ssh_connection_details.password}
${MRBTS_ID}                 ${tl.gnbs[0].global_bts_id}


*** Keywords ***
Common Suite Setup for CB014044
    [Arguments]    ${wts_command}=${set_wts_configuration_file_command}
    robot_common_operations.Common Suite Setup
    Common Suite Setup for COAM
    Get sagnb version for selenium
    IF    '${tl.gnbs[0].instance_id}' == '34511'
         Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
         Connect to gnb coam via ssl
         COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_gnb1_scf_${sw_version}}    skip_parameter_relation_errors=${False}
         Set edaemon and egate
         Set WTS configuration file    wts_command=${wts_command}
         Set x2 link up
         COAM Wait for gnb ready and cell setup
    ELSE
         IF    '${sw_version}' == 'SBTS26R2'
             Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    MRBTS-10175_${sw_version}_ENB_0000.xml
         ELSE
             Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    MRBTS-10175_${sw_version}_ENB_9999.xml
         END
         Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
         ...    scf_dir_path=${btslog_ini_file_path}
    END
    Get gnb release info

Get bts package version
    [Arguments]
    ...    ${gnb_index}=${0}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=version_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=version_info
    ${package_version}     set variable    ${info.split('_', 1)[1].split('.')[0]}
    Set Suite Variable    ${package_version}
    [Teardown]   csn.Disconnect   connection=version_info
    [Return]    ${package_version}

generate new report and get report id
    [Arguments]
    ...    ${file_path}
    ...    ${report_name}
    ...    ${tl_id}
    ...    ${package_version}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${comments}=${EMPTY}
    ...    ${check_out_entry}=false
    ${report_id}    generate_new_report_on_compass
    ...    file_path=${file_path}
    ...    report_name=${report_name}
    ...    tl_id=${tl_id}
    ...    package_version=${package_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    comments=${comments}
    ...    check_out_entry=${check_out_entry}
    [Return]    ${report_id}

Setup for Env cell on-air for 2 gnb
    [Arguments]    ${tl_scf_file_name}    ${scf_dir_path}=${tl_scf_dir_path}    ${is_commission}=True    ${is_commission_for_second_gnb}=True
    Common Case TestLine Setup    is_commission=${is_commission}    is_commission_for_second_gnb=${is_commission_for_second_gnb}
    ...    scf_path=${scf_dir_path}    golden_scf_name=${tl_scf_file_name}

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Common Suite Teardown for CB014044
    Common Suite Teardown for COAM    gnb_list=${gnb_list}

Common Test Setup for CB014044
    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,8000,61009,4741,4681
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=61009
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=4741
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    Create folder name of syslog for per case

Common Test Teardown for CB014044
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4459
    AlarmWatchdog.remove_allow_alarms    fault_id=61009
    AlarmWatchdog.remove_allow_alarms    fault_id=8000
    AlarmWatchdog.remove_allow_alarms    fault_id=4741
    AlarmWatchdog.remove_allow_alarms    fault_id=4681
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Common Test Setup for CB014044 without AP
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291

Common Test Teardown for CB014044 without AP
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Check edaemon and egate process
    ${RC}    ${output_egate}    Run And Return Rc And Output    ps -ef | grep egate | grep -v grep
    Should Contain    ${output_egate}    ./egate --port 20000
    ${RC}    ${output_edaemon}    Run And Return Rc And Output    ps -ef | grep edaemon | grep -v grep
    Should Contain    ${output_edaemon}    ./edaemon --port 22222

Execute edaemon and egate process
#    ${RC}=    Run And Return Rc    cd /opt/iphy/latest/;bash killUTE
#    ${RC}    ${output_execute_edaemon}    Run And Return Rc And Output    cd /opt/iphy/latest;sudo ./edaemon --port 22222
#    ${RC}    ${output_execute_egate}    Run And Return Rc And Output    cd /opt/iphy/latest;./egate --port 20000
    ${RC}=    Run And Return Rc    cd /opt/wts/latest;bash killUTE
    ${RC}    ${output_execute_edaemon}    Run And Return Rc And Output    cd /opt/wts/latest;sudo ./edaemon --port 22222
    ${RC}    ${output_execute_egate}    Run And Return Rc And Output    cd /opt/wts/latest;./egate --port 20000

Set edaemon and egate
    Execute edaemon and egate process

Set WTS configuration file
    [Arguments]    ${wts_command}=${set_wts_configuration_file_command}
    execute_set_wts_configuration_file    command=${wts_command}

Set x2 link up
    [Arguments]    ${x2_link_up_command}=${set_x2_link_up_command}
    execute_set_x2_link_up    command=${x2_link_up_command}

check cell on-air status
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    Wait until keyword succeeds    2m    10s    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}

Create folder name of syslog for per case
    ${is_exist}=    Run Keyword And Return Status    Directory Should Exist    path=${case_logs_path}/${TEST NAME}
    IF    ${is_exist} == ${True}
        Remove Directory    path=${case_logs_path}/${TEST NAME}    recursive=${True}
    END
    Create Directory    path=${case_logs_path}/${TEST NAME}

Copy syslog to common case log path
    [Arguments]    ${syslog_file_name}
    ${is_exist}=    Run Keyword And Return Status    File Should Exist    path=/home/ute/BTS_logs/SYSLOG.tgz
    IF    ${is_exist} == ${True}
        Copy File    /home/ute/BTS_logs/SYSLOG.tgz    ${case_logs_path}/${TEST NAME}/${syslog_file_name}.tgz
        ${is_exist}=    Run Keyword And Return Status    File Should Exist    path=${case_logs_path}/${TEST NAME}/${syslog_file_name}.tgz
        IF    ${is_exist} == ${True}
            Log    /home/ute/BTS_logs/SYSLOG.tgz copy to ${case_logs_path}/${TEST NAME}/${syslog_file_name}.tgz success
        END
    END
    ${Rc}    ${output}=    Run And Return Rc And Output
    ...    command=tar zxvf "${case_logs_path}/${TEST NAME}/${syslog_file_name}.tgz" -C ${case_logs_path}
    IF    ${Rc} == ${0}
        ${syslogs_name_list}=    Split String    string=${output}    separator=\n
        ${syslogs_name_str}=    Evaluate    ",".join(${syslogs_name_list})
        ${syslogs_name}=    Evaluate    "${syslogs_name_str}".replace("./", "")
    END
    [Return]    ${syslogs_name}

Check err on syslog file
    [Arguments]    ${syslog_files}
    run_and_generate_log_file    files_path=${case_logs_path}    log_name=ERR
    ...    syslog_files=${syslog_files}    analysis_str=ERR/
    ...    log_path=${case_logs_path}/${TEST NAME}

Check SentDataMeasurementCounting on syslog file
    [Arguments]    ${syslog_files}
    run_and_generate_log_file    files_path=${case_logs_path}    log_name=SentDataMeasurementCounting
    ...    syslog_files=${syslog_files}    analysis_str=SentDataMeasurementCounting
    ...    log_path=${case_logs_path}/${TEST NAME}

check syslog for err
    [Arguments]    ${syslog_file_name}
    ${syslogs_name}=    Copy syslog to common case log path    syslog_file_name=${syslog_file_name}
    Check err on syslog file    syslog_files=${syslogs_name}
    File Should Be Empty    path=${case_logs_path}/${TEST NAME}/ERR.log    msg=there are ERR print, need to check!

check syslog for traffic
    [Arguments]    ${syslog_file_name}
    ${syslogs_name}=    Copy syslog to common case log path    syslog_file_name=${syslog_file_name}
    Check SentDataMeasurementCounting on syslog file    syslog_files=${syslogs_name}
    ${avg_traffic}=    get_traffic_info    log_file=${case_logs_path}/${TEST NAME}/SentDataMeasurementCounting.log
    [Return]    ${avg_traffic}

UEs attach and Bears established
    [Arguments]    ${pdu_commands}    ${slice_commands}
    execute_attach    commands=${at_commands}
    Sleep    5s
    FOR    ${pdu_command}    IN    @{pdu_commands}
        execute_set_pdu    commands=${pdu_command}
    END
    Sleep    5s
    FOR    ${slice_command}    IN    @{slice_commands}
#        execute_required_commands    commands=${slice_command}    regexp=.*?rrcReconfigurationComplete
        execute_slice_setup    commands=${slice_command}
    END
#    execute_slice_setup    commands=${slice_commands}

UEs make traffic
    [Arguments]    ${traffic_commands}
    FOR    ${traffic_command}    IN    @{traffic_commands}
        execute_make_traffic    commands=${traffic_command}
    END

UEs release pdu and detach
    [Arguments]    ${release_pdu_commands}
    FOR    ${release_pdu_command}    IN    @{release_pdu_commands}
        execute_release_pdu    commands=${release_pdu_command}
    END
    execute_detach    commands=${detach_commands}

UEs detach
    execute_detach    commands=${detach_commands}

UEs attach and Bears established on Ba#B1_001
    execute_attach    commands=${ba_b1_001_atttach_commands}
    execute_set_pdu    commands=${ba_b1_001_pdu_commands_1_8}
    execute_slice_setup    commands=${ba_b1_001_slice_commands_1_8}

UEs make traffic on Ba#B1_001
    execute_make_traffic    commands=${ba_b1_001_traffic_commands_1_8}

UEs stop traffic on Ba#B1_001
    execute_stop_traffic    commands=${ba_b1_001_stop_traffic_commands_1_8}

UEs release pdu and detach on Ba#B1_001
    execute_release_pdu    commands=${ba_b1_001_release_pdu_commands_1_8}
    execute_detach    commands=${ba_b1_001_detach_commands}

cp bts_ini file
    ${RC}    ${output}    Run And Return Rc And Output    cp -r ${btslog_ini_file_path}btslog.ini /home/ute/btslog2/btslog.ini
    Should Be Equal As Integers    ${RC}    ${0}

Check if KPI meets the requirements
    [Arguments]    ${kpi_name}    ${dist_name}    ${json_path}    &{kwargs}
    ${kpis}=    get_kpi_value    kpi_name=${kpi_name}    dist_name=${dist_name}    json_path=${json_path}
    FOR    ${kpi}    IN    ${kpis}

8UEs attach
    prepare MultilUE and MCS    att_value_UE0=${20}    att_value_UE1=${20}
#    #####pioneer part#####
#    Prepare MultiUE with client
#    Set Multi UE to SA mode
#    MultiUEs Attach with client
#    #####pioneer part#####
    #####Spark part#####
    Spark_multiUE.prepare UE
    FOR    ${i}    IN RANGE    ${8}
        Spark_multiUE.attach UE    ue_index=${i}
    END
    #####Spark part#####

Set Multi UE to SA mode
    FOR    ${ue}    IN    @{uegroup}
        client.sendat    command=AT+GTSET="5GSACTR",1    until_timeout=${300}    ue=${ue}
        client.sendat    command=AT+GTACT=14    until_timeout=${300}    ue=${ue}
    END

8UEs transfer data
#    #####pioneer part#####
#    Start multiUEs traffic with appserver for diff throughput    dl_tput_multiue=${dl_diff_tput}
#    Start UL Data Transfer with pioneer client for diff throughput    ues_index=${used_ues_index}    ul_throughput=${ul_diff_tput}
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=ul
#    #####pioneer part#####
    #####Spark part#####
    Start spark multiUEs traffic with appserver for diff throughput    dl_tput_multiue=${dl_diff_tput}
    Start UL Data Transfer with spark client for diff throughput    ues_index=${used_ues_index}    ul_throughput=${ul_diff_tput}
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=MACDL
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=MACUL
    #####Spark part#####

8UEs detach
#    #####pioneer part#####
#    Detach MultiUEs with client
#    #####pioneer part#####
    #####Spark part#####
    Detach MultiUEs with spark client
    #####Spark part#####
    prepare MultilUE and MCS    att_value_UE0=${90}    att_value_UE1=${90}

8UEs stop transfer data
#    #####pioneer part#####
#    Stop multiues traffic with appserver
#    Stop UL Data Transfer with pioneer client    ues_index=${used_ues_index}
#    #####pioneer part#####
    #####Spark part#####
    Stop spark multiues traffic with appserver
    Stop UL Data Transfer with spark client    ues_index=${used_ues_index}
    #####Spark part#####

Set MCS for MulitUE
    ${mcs_type}=    mcs_common.Get MCS Type
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    [Return]    ${mcs_type}

HAOJIN MCS change UE Position
    [Arguments]     ${mcs_type}    ${begin_output_port_1}    ${end_output_port_2}    ${vertical_angle_1}    ${horizontal_angle_1}
    ...    ${begin_output_port_3}    ${end_output_port_4}
    ...    ${vertical_angle_2}     ${horizontal_angle_2}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_1}    end_output_port=${end_output_port_2}     input_group_id=${0}
    ...    vertical_angle=${vertical_angle_1}
    ...    horizontal_angle=${horizontal_angle_1}    vertical_distance=${2.0}    horizontal_distance=${0.5}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_3}    end_output_port=${end_output_port_4}     input_group_id=${0}
    ...    vertical_angle=${vertical_angle_2}
    ...    horizontal_angle=${horizontal_angle_2}    vertical_distance=${2.0}    horizontal_distance=${0.5}

HAOJIN MCS SETUP AND SET ATT for MultiUE
    [Arguments]    ${mcs_type}    ${att_value_UE0}    ${att_value_UE1}
    ...    ${P1_out}    ${P2_out}    ${P3_out}    ${P4_out}    ${vertical_1}    ${horizontal_1}    ${horizontal_2}    ${vertical_2}
    ...    ${P5_out}    ${P6_out}    ${P7_out}    ${P8_out}    ${vertical_3}    ${horizontal_3}    ${horizontal_4}    ${vertical_4}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P1_out}    end_output_port_2=${P2_out}    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_3=${P3_out}    end_output_port_4=${P4_out}    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P5_out}    end_output_port_2=${P6_out}    vertical_angle_1=${vertical_3}    horizontal_angle_1=${horizontal_3}
    ...    begin_output_port_3=${P7_out}    end_output_port_4=${P8_out}    vertical_angle_2=${vertical_4}    horizontal_angle_2=${horizontal_4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0}
    ...    begin_output_port=${13}    end_output_port=${16}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1}
    ...    begin_output_port=${9}    end_output_port=${12}

MCS 2UE AND SET ATT
    [Arguments]
    ...    ${mcs_type}
    ...    ${att_value_UE0}=${90}    ${att_value_UE1}=${90}    ${att1_value_UE0}=${90}    ${att1_value_UE1}=${90}
    ...    ${vertical_1}=${87}    ${horizontal_1}=${14}   ${vertical_2}=${86}    ${horizontal_2}=${29}
    ...    ${vertical_3}=${82}    ${horizontal_3}=${-14}    ${vertical_4}=${80}    ${horizontal_4}=${-30}
    ...    ${vertical_5}=${-7}    ${horizontal_5}=${-57}   ${vertical_6}=${-16}    ${horizontal_6}=${-57}
    ...    ${vertical_7}=${3}    ${horizontal_7}=${11}    ${vertical_8}=${-9}    ${horizontal_8}=${11}
    HAOJIN MCS SETUP AND SET ATT for MultiUE    mcs_type=${mcs_type}
    ...    att_value_UE0=${att_value_UE0}    att_value_UE1=${att_value_UE1}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${vertical_1}    horizontal_1=${horizontal_1}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${vertical_2}    horizontal_2=${horizontal_2}
    ...    P5_out=${9}     P6_out=${10}    vertical_3=${vertical_3}    horizontal_3=${horizontal_3}
    ...    P7_out=${11}    P8_out=${12}    vertical_4=${vertical_4}    horizontal_4=${horizontal_4}
    Log    ${att1_value_UE0}
    Log    ${att1_value_UE1}
    Log    ${vertical_5}
    Log    ${horizontal_5}
    Log    ${vertical_6}
    Log    ${horizontal_6}
    Log    ${vertical_7}
    Log    ${horizontal_7}
    Log    ${vertical_8}
    Log    ${horizontal_8}

prepare MultilUE and MCS
    [Arguments]    ${att_value_UE0}=${10}    ${att_value_UE1}=${90}    ${att1_value_UE0}=${0}    ${att1_value_UE1}=${90}
    ...    ${vertical_1}=${87}    ${horizontal_1}=${14}   ${vertical_2}=${86}    ${horizontal_2}=${29}
    ...    ${vertical_3}=${82}    ${horizontal_3}=${-14}    ${vertical_4}=${80}    ${horizontal_4}=${-30}
    ...    ${vertical_5}=${-7}    ${horizontal_5}=${-57}   ${vertical_6}=${-16}    ${horizontal_6}=${-57}
    ...    ${vertical_7}=${3}    ${horizontal_7}=${11}    ${vertical_8}=${-9}    ${horizontal_8}=${11}
    ${mcs_type}=    Set MCS for MulitUE
    MCS 2UE AND SET ATT    mcs_type=${mcs_type}
    ...    att_value_UE0=${att_value_UE0}    att_value_UE1=${att_value_UE1}
    ...    att1_value_UE0=${att1_value_UE0}    att1_value_UE1=${att1_value_UE1}
    ...    vertical_1=${vertical_1}    horizontal_1=${horizontal_1}    vertical_2=${vertical_2}    horizontal_2=${horizontal_2}
    ...    vertical_3=${vertical_3}    horizontal_3=${horizontal_3}    vertical_4=${vertical_4}    horizontal_4=${horizontal_4}
    ...    vertical_5=${vertical_5}    horizontal_5=${horizontal_5}    vertical_6=${vertical_6}    horizontal_6=${horizontal_6}
    ...    vertical_7=${vertical_7}    horizontal_7=${horizontal_7}    vertical_8=${vertical_8}    horizontal_8=${horizontal_8}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Start multiUEs traffic with appserver for diff throughput
    [Arguments]    ${dl_tput_multiue}=${dl_tput_multiue}    ${DL_PORT}=${DL_PORT}    ${UE_define}=NULL    ${process_num}=${1}
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'   ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Start MUE dltraffic with appserver    ue_addr=${${uegroup}[${i}]_IP}     dl_port=${DL_PORT}    dl_throughput=${dl_tput_multiue}[${i}]
        ...    process_num=${process_num}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

Start UL Data Transfer with pioneer client for diff throughput
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=2500000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${1}
    ...            ${refine_ue_port}=${None}
    ...            ${appserver_addr}=${tl.ues[${ue_index_in_tl}].iperf_details.ssh_connection_details.addr}
    Log To Console    ${\n}INFO:-- start to UL call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${ue_port}    Set Variable If    '${refine_ue_port}'=='None'    ${tl.ues[${ue_index_in_tl}].iperf_details.port}    ${refine_ue_port}
    FOR    ${index}    IN    @{ues_index}
        Log To Console    ${\n}INFO:-- start to UL call for ${uegroup}[${index}]--
        Run Keyword And Continue On Failure    client.startultraffic
        ...    protocol=${ul_protocol}
        ...    address=${appserver_addr}
        ...    port=${ue_port}
        ...    testtime=9999
        ...    bandwidth=${ul_throughput}[${index}]
        ...    buffersize=${ul_buffersize}
        ...    packetsize=${packetsize}
        ...    until_timeout=${300}
        ...    ue=${uegroup}[${index}]
        ${ue_port}    Evaluate    ${ue_port}+1
        Sleep   15sec
    END

Check traffic with pioneer client with pioneer client for diff throughput
    [Arguments]    ${tput_target}    ${ues_index}=${${0},${1},${2},${3}}   ${direction}=ul
    Log To Console    ${\n}INFO:-- start to check ${direction} tput --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        ${tput_dic}    Run Keyword And Continue On Failure    client.getparammac    ue=${uegroup}[${index}]
        ${tput_output}    run keyword if    '${direction}'=='ul'    Evaluate    ${tput_dic['Param']['MACUL']} / 1000 / 1000
        ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${tput_dic['Param']['MACDL']} / 1000 / 1000
        Run Keyword And Continue On Failure    should be true    ${tput_output} > ${tput_target}[${index}]
    END

Detach MultiUEs with client
    [Arguments]    ${until_timeout}=${300}
    ${ue_num}      get length    ${uegroup}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        client.poweroff     ue=${uegroup}[${i}]    until_timeout=${until_timeout}
    END

Detach MultiUEs with spark client
    [Arguments]    ${until_timeout}=${300}
    ${ue_num}      get length    ${uegroup}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Spark_multiUE.detach UE     ue_index=${i}    timeout=${until_timeout}
    END

Start spark multiUEs traffic with appserver for diff throughput
    [Arguments]    ${dl_tput_multiue}=${dl_tput_multiue}    ${DL_PORT}=${DL_PORT}    ${UE_define}=NULL    ${process_num}=${1}
    # ${uegroup} get from keyword Spark_multiUE.prepare UE
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'   ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Spark_multiUE.start DL traffic    dl_throughput=${dl_tput_multiue}[${i}]    ue_index=${i}    dl_port=${DL_PORT}
        ...    process_num=${process_num}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

Start UL Data Transfer with spark client for diff throughput
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=2500000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${1}
    ...            ${refine_ue_port}=${None}
    ...            ${appserver_addr}=${tl.ues[${ue_index_in_tl}].iperf_details.ssh_connection_details.addr}
    Log To Console    ${\n}INFO:-- start to UL call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${ue_port}    Set Variable If    '${refine_ue_port}'=='None'    ${tl.ues[${ue_index_in_tl}].iperf_details.port}    ${refine_ue_port}
    FOR    ${index}    IN    @{ues_index}
        Log To Console    ${\n}INFO:-- start to UL call for ${uegroup}[${index}]--
        Spark_multiUE.start UL traffic
        ...    ue_index=${index}
        ...    traffic_protocol=${ul_protocol}
        ...    target_iperf_server=${appserver_addr}
        ...    target_port=${ue_port}
        ...    testtime=9999
        ...    bandwidth=${ul_throughput}[${index}]
        ...    buffersize=${ul_buffersize}
        ...    packetsize=${packetsize}
        ${ue_port}    Evaluate    ${ue_port}+1
    END

Check traffic with spark client with spark client for diff throughput
    [Arguments]    ${tput_target}    ${ues_index}=${${0},${1},${2},${3}}   ${direction}=MACDL
    Log To Console    ${\n}INFO:-- start to check ${direction} tput --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        ${tput_output}    Run Keyword And Continue On Failure
        ...    Spark_multiUE.get traffic from ue side    ue_index=${index}    tput_direction=${direction}
        Run Keyword And Continue On Failure    should be true    ${tput_output} > ${tput_target}[${index}]
    END

Stop spark multiues traffic with appserver
    [Arguments]    ${appserver}=APPserver    ${DL_PORT}=${DL_PORT}    ${UE_define}=NULL
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'   ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Close the iperf process on APPserver    port=${DL_PORT}    appserver=${appserver}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

Stop UL Data Transfer with spark client
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    Log To Console    ${\n}INFO:-- start to stop call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Continue On Failure    Spark_multiUE.stop UL traffic    ue_index=${index}
        Sleep   5sec
    END
