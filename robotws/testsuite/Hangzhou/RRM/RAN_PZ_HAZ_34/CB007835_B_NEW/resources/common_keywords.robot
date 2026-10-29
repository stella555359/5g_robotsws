*** Settings ***
Documentation
...   author: pengliang.wu@nokia-sbell.com
...   contact: pengliang.wu@nokia-sbell.com

Library    taf.selenium.sbts       WITH NAME    selenium_coam
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ../../5GC001937_OTA/resources/5GC001937_keywords.robot
Resource    ../../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
Variables   ../../5GC001937_OTA/resources/5GC001937_mmw4_modify_para.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Library     taf.rfrl.common_resources.python.SWConfig
Variables    modify_para.py



*** Variables ***
${DU_OAM_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}             ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}            ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}            ${tl.test_pc.default_ssh_connection_details.password}
${GNB_MRBTS_ID}            ${tl.gnbs[0].instance_id}
${GNB_NRBTS_ID}            ${tl.gnbs[0].global_bts_id}
#${eNB_DU_OAM_IP}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#${ENB_MRBTS_ID}            ${tl.enbs[0].instance_id}
#${ENB_NRBTS_ID}            ${tl.enbs[0].global_bts_id}
${eNB_DU_OAM_IP}           ${tl.ues[2].airscale.common_units[0].lmp_connection.addr}
${ENB_MRBTS_ID}            ${tl.ues[2].instance_id}
${ENB_NRBTS_ID}            ${tl.ues[2].global_bts_id}

${SW_build_path}     /home/ute/Downloads
#${target_version}
${package_link}      https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
#${package_version_1525-CA}    ${target_version}
${testpc_host}    ${UTE_ADDRESS}
${testpc_user}    ${UTE_USERNAME}
${testpc_pswd}    ${UTE_PASSWORD}

*** Keywords ***
Check BTS Should Be Normal
    [Arguments]  ${bts_host}=${DU_OAM_IP}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log To Console  Check BTS Should Be Normal
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair    cell_type=${cell_type}    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Save Snapshot Log
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=600s    ${ip_address}=${DU_OAM_IP}
    Log To Console    Save Snapshot Log
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    set variable    ${OUTPUT DIR}/snapshot/${timestamp}_snapshot.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    [Return]    ${snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Get BTS Alarm FaultID
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    Log To Console    get active alarm
    ${alarm_info}    coam.get_active_alarms    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Check Alarm after OAM opraetion
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    #Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

Reset LTE
    [Arguments]    ${alias}=enb
    Log To Console    Reset LTE And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${alias}
    sleep    2s
    coam.reset_site    connection=${alias}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${alias}

4G site reset
    Log To Console    4G site reset
    Check Alarm after OAM opraetion
    Reset LTE
    sleep    30s
    Check BTS Should Be Normal    cell_type=lte    bts_host=${eNB_DU_OAM_IP}
    Check BTS Should Be Normal
    Check Alarm after OAM opraetion

UE attach by Spark by Index
    [Arguments]  ${ue_index}=${0}    ${ue_type}=huawei_sigspark    ${try_time}=${4}
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
    Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    sleep    5s
    ${5Grach_ed}    wait until keyword succeeds    ${try_time}X    2min    Prepare UE and Attach UE by spark1    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False

Start UE data traffic and Record TP Log and Aasys Log
    [Arguments]  ${ue_index}    ${ul_throughput}   ${dl_throughput}   ${ul_duration}    ${dl_duration}    ${protocol}    ${time}
    ...    ${if_ul}=${True}    ${if_dl}=${False}    ${buffer_size}=1400B    ${buffer_size_ul}=1300B    ${process_num}=${5}
    ...    ${syslog_check}=${True}
    start Signal power ue traffic ul and dl by spark attach    ue_index=${ue_index}    ul_throughput=${ul_throughput}
    ...    dl_throughput=${dl_throughput}    process_num=${process_num}
    ...    ul_duration=${ul_duration}    dl_duration=${dl_duration}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    ...    buffer_size=${buffer_size}    buffer_size_ul=${buffer_size_ul}
    sleep    60s
    Spark Start UE Log    ue_index=${ue_index}
    ${log_path}    set variable    ${None}
    ${log_path}    run keyword if    ${syslog_check}==${True}    power_ue.Collect Tput
    ...    ue_type=samsung    duration=${time}    ignore_time=10s
    [Return]    ${log_path}

Stop UE traffic and Stop Record TP Log in spark
    [Arguments]  ${ue_index}    ${if_ul}    ${if_dl}    ${protocol}    ${spark_log_name}    ${ue_type}=samsung    ${syslog_check}=${True}
    Run keyword if    ${syslog_check}==${True}    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Spark Stop UE Log    ue_index=${ue_index}    log_name=${TS_CASE_LOG_PATH}/${spark_log_name}_UE0.xml
    run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}
    ...    direction=ul    protocol=${protocol}
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}
    ...    direction=dl    protocol=${protocol}
    Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}

start Signal power ue traffic ul and dl by spark attach
    [Arguments]    ${ue_index}=${0}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${buffer_size}=1400B    ${buffer_size_ul}=1300B    ${process_num}=${5}
    log to console      Start traffic    console=yes
    run keyword and continue on failure    run keyword if    ${if_dl}    Signal UE start dl traffic    ue_index=${ue_index}
    ...    dl_throughput=${dl_throughput}    dl_duration=${dl_duration}    protocol=${protocol}    buffer_size=${buffer_size}
    ...    process_num=${process_num}
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_ul}    Signal UE start ul traffic    ue_index=${ue_index}
    ...    ul_throughput=${ul_throughput}    ul_duration=${ul_duration}    protocol=${protocol}    buffer_size_ul=${buffer_size_ul}

Signal UE start ul traffic
    [Arguments]  ${ue_index}    ${ul_throughput}    ${ul_duration}    ${protocol}    ${buffer_size_ul}
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung
    ...    iperf_type=via_command    protocol=${protocol}    buffer_size=${buffer_size_ul}

Signal UE start dl traffic
    [Arguments]  ${ue_index}    ${dl_throughput}    ${dl_duration}    ${protocol}    ${buffer_size}=1400B    ${process_num}=${5}
    Start DL traffic via spark attach    ue_index=${ue_index}    traffic=${dl_throughput}    time=${dl_duration}
    ...    protocol=${protocol}    buffer_size=${buffer_size}    process_num=${process_num}

login
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb
    ...    ${enb_index}=${0}
    Run Keyword If    '${node_type}'=='gnb'
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE IF    '${node_type}'=='enb'
    ...    Connect to eNB coam via ssl    connection=${connection}    enb_index=${enb_index}

logout
    [Arguments]    ${connection}=GNB_OAM
    COAM Teardown gnb connections    connection=${connection}

Get BTS Software Version
    [Arguments]    ${connection}=GNB_OAM
    login    connection=${connection}
    ${parameters}    coam.get_parameters_for_all    class_name=BTS    timeout=20s    connection=${connection}
    ${ActiveVersion}    set variable    ${parameters}[${0}][activeSoftwareVersion]
    ${PassiveVersion}    set variable    ${parameters}[${0}][passiveSoftwareVersion]
    log to console    ------BTS Software Build version------
    log to console    Active: ${ActiveVersion}
    log to console    Passive: ${PassiveVersion}
    [Teardown]    Run Keyword And Ignore Error    logout    connection=${connection}

Gnb upgraded via WEBUI
#    [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${protocol}=udp
    ${result1}    Run Keyword And Return Status    SWM supports provision SW build package via WebUI
    sleep    60s
    run keyword if    '${result1}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#    run keyword and continue on failure    L3 call    protocol=${protocol}    ue_index=${ue_index}    pcmd=${pcmd}
#    ...    target_avg_percent=${non_peak_target_avg_percent}
    ${result2}    Run Keyword And Return Status    Classical gNB Software Rollback successfully via WebUI
    run keyword if    '${result2}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
    sleep    60s

L3 call
    [Arguments]    ${protocol}=udp    ${log_time}=${log_time}    ${ul_enable}=${True}    ${dl_enable}=${True}    ${total_count}=${total_count}
    ...    ${exp_ul_tp}=${exp_ul}    ${exp_dl_tp}=${exp_dl}    ${ue_index}=0    ${ul_list}=@{ulcell_list}    ${dl_list}=@{dlcell_list}
    ...    ${pcmd}=${False}    ${4G_pcmd}=${False}    ${buffer_size}=1400B    ${buffer_size_ul}=1300B    ${process_num}=${5}
    ...    ${target_avg_percent}=${1}    ${syslog_check}=${True}    ${ul_throughput}=${ul_tput_udp}    ${dl_throughput}=${dl_tput_udp}
    Log To Console    start L3 call
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark by Index    ue_index=${ue_index}
    ${log_path}    Start UE data traffic and Record TP Log and Aasys Log
    ...    ue_index=${ue_index}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    ...    ul_duration=${duration}    dl_duration=${duration}     process_num=${process_num}
    ...    protocol=${protocol}    if_ul=${ul_enable}    if_dl=${dl_enable}    time=${log_time}
    ...    buffer_size=${buffer_size}    buffer_size_ul=${buffer_size_ul}    syslog_check=${syslog_check}
    run keyword if    ${pcmd}==${True}    start collect pcmd logs    cmd=${tcpdump_interface}
    run keyword if    '${pcmd}'=='${True}' and '${4G_pcmd}'=='${True}'    start collect pcmd logs    hostip=${eNB_DU_OAM_IP}    filename=4G_pcmd.pcap
    ...    cmd=br1
    run keyword and continue on failure    Stop UE traffic and Stop Record TP Log in spark    ue_index=${ue_index}    if_ul=${ul_enable}
    ...    if_dl=${dl_enable}    protocol=${protocol}    spark_log_name=spark_ul_dl_udp    syslog_check=${syslog_check}
    sleep    10s
    run keyword and continue on failure    run keyword if    ${pcmd}==${True}    Stop and download pcmd log
    run keyword and continue on failure    run keyword if    '${pcmd}'=='${True}' and '${4G_pcmd}'=='${True}'    Stop and download pcmd log
    ...    hostip=${eNB_DU_OAM_IP}    filename=4G_pcmd.pcap
    run keyword and continue on failure    run keyword if    ${ul_enable}==${True} and ${syslog_check}==${True}
    ...    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${dl_enable}==${True} and ${syslog_check}==${True}
    ...    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=0
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${1}    spark_log_name=spark_ul_dl_udp    list_length=${total_count}
    ...    row_list=${row_list}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
    ...    should be true    ${total_result_dict[0]['DL_bler'][0]} < 8.0
    run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
    ...    should be true    ${total_result_dict[0]['DL_tp'][0]} > ${exp_dl_tp}*${target_avg_percent}
    run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
    ...    should be true    ${total_result_dict[0]['UL_bler'][0]} < 8.0
    run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
    ...    should be true    ${total_result_dict[0]['UL_tp'][0]} > ${exp_ul_tp}*${target_avg_percent}
    run keyword and continue on failure    run keyword if    ${pcmd}==${True}    pcmd log analysis
    run keyword and continue on failure    run keyword if    '${pcmd}'=='${True}' and '${4G_pcmd}'=='${True}'    LTE pcmd log analysis
    Log to console    DL_BLER: ${total_result_dict[0]['DL_bler'][0]}%
    Log to console    DL_Tput: ${total_result_dict[0]['DL_tp'][0]}M
    Log to console    UL_BLER: ${total_result_dict[0]['UL_bler'][0]}%
    Log to console    UL_Tput: ${total_result_dict[0]['UL_tp'][0]}M
    [Return]    ${total_result_dict}

#*** UUF4ALL Keywords ***
SWM supports provision SW build package via WebUI
    step1:Login WebUI
    step2:check current sw version 1
    step3:upgrade site with active
    step4:check SW version after upgrade
    step6:check site status
    check site alarm
    [Teardown]    Run Keyword and Ignore Error    step7:logout webui

Classical gNB Software Rollback successfully via WebUI
    step1:Login WebUI
    step2:check current sw version 2
    step3:execute rollback
    step5:ENV recovery
    step6:check site status
    check site alarm
    [Teardown]    Run Keyword and Ignore Error    step7:logout webui

check site alarm
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

step1:Login WebUI
    log to console    step1:Login WebUI
    Wait Until Keyword Succeeds    2min    10s    WEBUI Login    ${TRUE}

step2:check current sw version 1
    log to console   step2:check current sw version 1
    ${pre_active_version_1}    wait until keyword succeeds    1min    10s    check SW version    Active
    set suite variable    ${pre_active_version_1}
    sleep    5s

step2:check current sw version 2
    log to console    step2:check current sw version 2
    ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
    ${pre_active_version_2}    set variable    ${output}
    set suite variable    ${pre_active_version_2}
    ${pre_passive_version_2}    set variable    ${version}[Passive]
    set suite variable    ${pre_passive_version_2}
    sleep    5s

step3:upgrade site with active
    log to console    step3:upgrade site with active
    set suite variable    ${upgrade_package_path}    ${SW_build_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    ${upgrade_package_path}
    run keyword if  not ${status}     download_upgrade_package
    csn.disconnect    connection=TESTPC
    wait until keyword succeeds     5 min   10 sec
    ...     coam.connect to       bts_host=${asik_addr}     name=coam_admin
    log to console    start upgrade...
    wait until keyword succeeds     20 min   30 sec
    ...    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=coam_admin
    [Teardown]    Run Keyword and Ignore Error    logout    connection=coam_admin

download_upgrade_package
    log to console    SW package does not exist in ute server
    ${package_full_link}    Get link For Download from external value
    ${upgrade_package_path}    Download SW Build to VM     package_full_link=${package_full_link}

Get link For Download from external value
    @{result}    string.split string    string=${target_version}    separator=_
    ${result5}     convert to string    ${result}[-5]
    ${if_SBTS21B}     convert to string    ${result}[-3]
    set suite variable    ${result5}
    set suite variable    ${if_SBTS21B}
    ${package_full_link}    Set Variable    ${package_link}${result5}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}
    OperatingSystem.Create Directory    ${SW_build_path}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${md5_file}     set variable    ${output}[0]
    ${md5_value}      OperatingSystem.get file    ${md5_file}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link} -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${upgrade_package_path}     set variable    ${output}[0]
#    sleep    5min
    wait until keyword succeeds    15min    10s    check the download completed    ${upgrade_package_path}     ${md5_value}
    [Return]      ${upgrade_package_path}

step4:check SW version after upgrade
    log to console    step4:check SW version after upgrade
    wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully

Check if Airscal Upgrade Successfully
    ${If_SBTS00}    Run Keyword and Ignore Error    should contain    ${target_version}    SBTS00
    run keyword if     '${If_SBTS00[0]}' == 'PASS'       Check Common Load Version
    ...    ELSE      Check 21B Version

Check Common Load Version
#    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    ${str}=	    Remove String	    ${target_version}    SBTS00
    should contain    ${result}    ${str}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=asik


Check 21B Version
#    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    should contain    ${result}    ${target_version}
   [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=asik

step5:ENV recovery
    log to console    step5:ENV recovery

step6:check site status
    log to console    step6:check site status
    Check BTS Should Be Normal
    run keyword and ignore error     selenium_coam.enable_screen_lock

step3:execute rollback
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
 #   ...    ${timeout}=10 min    ${retry_interval}=5 sec    ${du_index}=0
#    ...    ${is_x2_check_from_gnb_needed}=${True}
#    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
    login    node_type=${node_type}    connection=${connection}    gnb_index=${index}    enb_index=${index}
    Log to console    1.check current version
    Get current version to check    connection=${connection}
    Log to console    2.rollback
    sleep    30s
    rollback_build    connection=${connection}
    sleep    1min
    Log to console    3. check version after rollback
    wait until keyword succeeds     40min    2min    Check if rollback Successfully    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    tearDown for logout    connection=${connection}

Get current version to check
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${current_activate_version}    ${current_passive_version}    ${current_planned_version}    Get software versions
    ...    connection=${connection}
    Set Suite Variable    ${current_activate_version}
    Set Suite Variable    ${current_passive_version}
    Set Suite Variable    ${current_planned_version}
    [Teardown]    Run Keyword And Ignore Error    logout    connection=${connection}

Get software versions
    [Arguments]    ${connection}=GNB_OAM
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${passive_version}    Set Variable    ${software}[Passive SW version]
    ${planned_version}    Set Variable    ${software}[Planned SW version]
    [Return]    ${activate_version}    ${passive_version}    ${planned_version}

rollback_build
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    wait until keyword succeeds     20min    30s
    ...    coam.rollback_software    timeout=2400    connection=${connection}
    [Teardown]    Run Keyword and Ignore Error    logout    connection=${connection}

Check if rollback Successfully
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${after_activate_version}    ${after_passive_version}    ${after_planned_version}    Get software versions
    ...    connection=${connection}
    Should Be Equal    ${current_passive_version}    ${after_activate_version}
    Should Be Equal    ${current_activate_version}    ${after_passive_version}
    [Teardown]    Run Keyword and Ignore Error    logout    connection=${connection}

tearDown for logout
    [Arguments]    ${connection}=GNB_OAM
    FOR    ${count}    IN RANGE    2
        logout    connection=${connection}
    END

step7:logout webui
    log to console    step7:logout webui
    run keyword and ignore error    WEBUI Logout    virtual_disable=${TRUE}

Common Case Teardown
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${is_save_snapshot}=True    ${is_save_snapshot_for_second_gnb}=False
    ...             ${connection}=GNB_OAM0    ${connection_for_second_gnb}=GNB_OAM1
    ...             ${timeout}=900    ${alais}=ASIK Master0    ${alais_for_second_gnb}=ASIK Master1
    Run Keyword If    ${is_save_snapshot}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    Connect to Common Unit Master    alias=${alais}    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api    connection=${connection}
    ...                                                                                                     timeout=${timeout}
    Run Keyword If    ${is_save_snapshot_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    Connect to Common Unit Master    alias=${alais_for_second_gnb}    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    ...                                                                  connection=${connection_for_second_gnb}
    ...                                                                  timeout=${timeout}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=ps -ef | grep admin_api |awk '{print $2}' | xargs kill -9
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais_for_second_gnb}    AND
    ...    csn.Reset Cache    AND    CI_interface.Common Case Teardown

check the download completed
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${sum}=        Set Variable     sha256sum ${upgrade_package_path}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.split string    ${output}
    should be equal    ${md5_value}    ${res}[0]

Connect to eNB coam via ssl
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${enb_index}=${0}
    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}
    Log to console    \nINFO:connect to eNB successfully

Change parameter which need bts restart
    [Arguments]  ${ue_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
    ${bts_objects}    coam.get_managed_objects    class_name=NRBTS_A    connection=${connection}
    ${bts_parameters}    coam.get_parameters    dist_name=${bts_objects}[${0}][distName]    connection=${connection}
    ${parameter_status}    get from dictionary    ${bts_parameters}     actGnbInitRlf
    Log to console    Current parameter: actGnbInitRlf = ${parameter_status}
    Log to console    Change parameter ongoing...
    Run keyword if    '${parameter_status}'=='True'    Modify Common parameter via Coam
    ...    input_list=${MODIFY_Parameter_disable_GnbInitRlf}    connection=${connection}
    Run keyword if    '${parameter_status}'=='False'    Modify Common parameter via Coam
    ...    input_list=${MODIFY_Parameter_enable_GnbInitRlf}    connection=${connection}
    Log to console    Change parameter done.
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}
    [Teardown]  Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

start collect pcmd logs
    [Arguments]    ${hostip}=${DU_OAM_IP}    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master    ${filename}=pcmd.pcap    ${cmd}=fp0
    csn.connect_to
    ...    hostname=${hostip}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    csn.send command    command=rm /tmp/${filename}    connection=${asik_alias}
    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=${asik_alias}
    csn.Send Command    command=tcpdump -i ${cmd} -C 300 -w /tmp/${filename}    connection=${asik_alias}
    sleep    2s
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=${asik_alias}
    ${output}    Csn.read_output    connection=${asik_alias}
    Should not be empty    ${output}
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${asik_alias}

Stop and download pcmd log
    [Arguments]    ${hostip}=${DU_OAM_IP}    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master    ${filename}=pcmd.pcap
    csn.connect_to
    ...    hostname=${hostip}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 | awk '{print $2}'    connection=${asik_alias}
    ${output}    Csn.read_output    connection=${asik_alias}
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 | awk '{print $2}'| xargs kill -9    connection=${asik_alias}
    ${output}    Csn.read_output    connection=${asik_alias}
    Should be empty    ${output}
    ${time1}    DateTime.get current date
    ${time1_stamp}    convert Date    ${time1}    epoch
    csn.download_file   remote_path=/tmp/${filename}    local_path=${OUTPUT_DIR}/${filename}
    ...     connection=${asik_alias}
    csn.execute    command=rm -rf /tmp/${filename}     connection=${asik_alias}
    OperatingSystem.Run    cp ${OUTPUT_DIR}/${filename} ${OUTPUT_DIR}/${time1_stamp}_${filename}
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${asik_alias}
    [Return]    ${OUTPUT_DIR}/${filename}

pcmd log analysis
    [Arguments]    ${filename}=${OUTPUT_DIR}/pcmd.pcap
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUePduRx >${OUTPUT_DIR}/1.pmdl
    ${timeOfUePduRx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUeSched >${OUTPUT_DIR}/1.pmdl
    ${timeOfUeSched}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUePduTx >${OUTPUT_DIR}/1.pmdl
    ${timeOfUePduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfBad1stMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOfBadPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfBadLastMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOfMacPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOf1stMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOf1stMacPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfRlcPduRxBytes >${OUTPUT_DIR}/1.pmdl
    ${sumOfRlcPduRxBytes}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfRlcPduTxBytes >${OUTPUT_DIR}/1.pmdl
    ${sumOfRlcPduTxBytes}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfWbCqi >${OUTPUT_DIR}/1.pmdl
    ${sumOfWbCqi}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfWbCqiSamples >${OUTPUT_DIR}/1.pmdl
    ${numOfWbCqiSamples}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "x2ap" -T fields -e x2ap.SgNBReconfigurationComplete_element >${OUTPUT_DIR}/1.pmdl
    ${SgNBReconfigurationComplete_element}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "x2ap" -T fields -e x2ap.SNStatusTransfer_element >${OUTPUT_DIR}/1.pmdl
    ${SNStatusTransfer_element}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "x2ap" -T fields -e x2ap.SgNBReleaseRequest_element >${OUTPUT_DIR}/1.pmdl
    ${SgNBReleaseRequest_element}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    run keyword and continue on failure    Should not be empty    ${timeOfUePduRx}
    run keyword and continue on failure    Should not be empty    ${timeOfUeSched}
    run keyword and continue on failure    Should not be empty    ${timeOfUePduTx}
    run keyword and continue on failure    Should not be empty    ${numOfBadPduTx}
    run keyword and continue on failure    Should not be empty    ${numOfMacPduTx}
    run keyword and continue on failure    Should not be empty    ${numOf1stMacPduTx}
    run keyword and continue on failure    Should not be empty    ${sumOfRlcPduRxBytes}
    run keyword and continue on failure    Should not be empty    ${sumOfRlcPduTxBytes}
    run keyword and continue on failure    Should not be empty    ${sumOfWbCqi}
    run keyword and continue on failure    Should not be empty    ${numOfWbCqiSamples}
    #run keyword and continue on failure    Should not be empty    ${SgNBReconfigurationComplete_element}
    run keyword and continue on failure    Should not be empty    ${SNStatusTransfer_element}
    run keyword and continue on failure    Should not be empty    ${SgNBReleaseRequest_element}

LTE pcmd log analysis
     [Arguments]    ${filename}=${OUTPUT_DIR}/pcmd.pcap    ${4G_filename}=${OUTPUT_DIR}/4G_pcmd.pcap
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sgnb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${sgnb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.menb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${menb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${4G_filename} -Y "nsetap.TraceMessage" -T fields -e nsetap.sgnb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${LTE_sgnb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${4G_filename} -Y "nsetap.TraceMessage" -T fields -e nsetap.menb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${LTE_menb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    should be true    ${sgnb_ue_x2ap_Id.split()[-1]}==${LTE_sgnb_ue_x2ap_Id.split()[-1]}
    should be true    ${menb_ue_x2ap_Id.split()[-1]}==${LTE_menb_ue_x2ap_Id.split()[-1]}

All configured NRCells lock and unlock stability testing
    Log To Console    All configured NRCells lock/unlock stability testing
#    [Arguments]  ${ue_index}=0    ${pcmd}=${False}
    Cell Lock/Unlock And Wait Until On Air
    Check Alarm after OAM opraetion
#    run keyword and continue on failure    L3 call    ue_index=${ue_index}    pcmd=${pcmd}
#    ...    target_avg_percent=${non_peak_target_avg_percent}

Cell Lock/Unlock And Wait Until On Air
    [Arguments]   ${connection}=GNB_OAM
    Log To Console    Cell Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock Cell
    FOR    ${item}    IN    @{cell_info_List}
        coam.lock    dist_name=MRBTS-${GNB_MRBTS_ID}/NRBTS-${GNB_NRBTS_ID}/NRCELL-${item}    timeout=${60}    connection=${connection}
    END
    sleep    3s
    Log To Console    Unlock Cell
    FOR    ${item}    IN    @{cell_info_List}
        coam.unlock    dist_name=MRBTS-${GNB_MRBTS_ID}/NRBTS-${GNB_NRBTS_ID}/NRCELL-${item}    timeout=${60}    connection=${connection}
    END
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Stability Reset with HWF deletion
    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    Modify Swconfig File   para_update=${swconfig_list}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    Run Keyword And Continue On Failure    start btslog capture  name=btslog
    Reset BTS And Wait Until On Air
    Run Keyword And Continue On Failure    stop btslog and collect logs   status=FAIL
    ${bts_log_path}=   set variable   ${OUTPUT_DIR}/btslog/syslog_files.tgz
    Run Keyword And Continue On Failure    Check_btslog_After_Reset   log_path=${bts_log_path}
    Wait Until Keyword Succeeds    3 min    5 sec  Check_gNB_Startup_log
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

Modify Swconfig File
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${para_update}    ${local_path}=${OUTPUT_DIR}
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    csn.send command    command=touch /ffs/run/swconfig.txt    connection=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{para_update}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check_gNB_Startup_log
    [Documentation]   tingting.1.liu@nokia-sbell.com
#    [Arguments]  ${connection}=GNB_OAM
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    ${startup_command} =    set variable    cat /tmp/startup_BTSOM.log |grep -i 'startService loading from hwf is disabled'
    ${startup_xz_command} =  set variable
    ...       xzcat /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz |grep -i 'startService loading from hwf is disabled'
    sleep    30s
    ${startup_log} =    Check Startup Defualt Log On ASIK
    ...    startup_cmd=${startup_command}    startup_xz_cmd=${startup_xz_command}    info=startService loading from hwf is disabled
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check_btslog_After_Reset
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]   ${log_path}
    ${bts_gz_command1} =  set variable
        ...   gunzip -c ${log_path} |grep -i 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
	${bts_gz_command2} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4329'
	${bts_gz_command3} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4330'
	${bts_gz_command4} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4329'
	${bts_gz_command5} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4330'
	${bts_gz_command6} =  set variable   gunzip -c ${log_path} |grep -i 'active 4329'
	${bts_gz_command7} =  set variable   gunzip -c ${log_path} |grep -i 'active 4330'
	${bts_gz_command8} =  set variable
	   ...   gunzip -c ${log_path} |grep -i '4230 Radio memory consumption exceeds critical threshold'
	${common_list}    create list   ${bts_gz_command1}  ${bts_gz_command2}  ${bts_gz_command3}  ${bts_gz_command4}
	...                             ${bts_gz_command5}  ${bts_gz_command6}  ${bts_gz_command7}  ${bts_gz_command8}
	${status_list}    create list
	FOR   ${common}   IN   @{common_list}
	    ${offline_output}   RUN    ${common}
	    ${status}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
	    Append To List    ${status_list}    ${status}
	END
	list should not contain value    ${status_list}    ${False}

Reset BTS And Wait Until On Air
    [Arguments]  ${connection}=GNB_OAM
    Log To Console    Reset BTS And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Separately CELL block unblock
    [Arguments]    ${connection}=GNB_OAM    ${if_given}=${False}     ${given_cell_list}=${EMPTY}
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${cell_list1}    Get All Cell Id    connection=${connection}
    ${cell_list}    set variable if    ${if_given}    ${given_cell_list}    ${cell_list1}
#    Get X2 link shutdown waiting time
    COAM Teardown gnb connections    connection=${connection}
    Selenium Login And Disable Screen Lock    version=${release_sbts}
    ${status}    run keyword and return status    NR Block and UnBlock Cells    block_list=${cell_list}
    run keyword if    not ${status}    Run Keyword And Ignore Error    NR UnBlock Cells and check status
    ...    block_list=${cell_list}
    should be true    ${status}
    Check Alarm after OAM opraetion
#    run keyword and continue on failure    L3 call    protocol=udp    log_time=3m    ue_index=${ue_index}
#    ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}    target_avg_percent=${non_peak_target_avg_percent}
    [Teardown]     run keywords    selenium logout and close browser     AND
    ...    run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

NR Block and UnBlock Cells
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${block_list}   ${technology}=NR
    NR Block cells and check status    block_list=${block_list}
    ...     technology=${technology}
    NR UnBlock Cells and check status   block_list=${block_list}
    ...     technology=${technology}

NR Block cells and check status
    [Documentation]  pengliang.wu@nokia-sbell.com
    [Arguments]  ${block_list}   ${technology}=NR   ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    log to console  \n***Block cells and check status***
    FOR    ${idx}  IN  @{block_list}
        log to console  \nBlock Global cell ID : ${idx} for ${technology} and check status
        selenium_coam.block_cell    cell_idx=${idx}    technology=${technology}
        Wait Until Keyword Succeeds   3 min  10 sec   check single cell should be blocked   cell_idx=${idx}   cell_type=${technology.lower()}
        Wait For Expect Fault Present    faultId=49    timeout=30
    END
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

NR UnBlock Cells and check status
    [Documentation]  pengliang.wu@nokia-sbell.com
    [Arguments]  ${block_list}   ${technology}=NR   ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    log to console  \n***unblock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        log to console  \nunBlock Global cell ID : ${idx} for ${technology} and check status
        selenium_coam.unblock_cell    cell_idx=${idx}    technology=${technology}
        Wait Until Keyword Succeeds   5 min  10 sec   check single cell should be unblocked   cell_idx=${idx}   cell_type=${technology.lower()}
    END
    Wait For Expect Fault To Disappear  faultId=49    timeout=60
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Get CU Type
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    [Teardown]   Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get SBTS Release Version
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    set suite variable    ${release_sbts}
    Get CU Type

Get eNB Release Version
    [Arguments]  ${connection}=ENB_BTS
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${parameters}    coam.get_parameters_for_all    class_name=BTS    timeout=20s    connection=${connection}
    ${ActiveVersion}    set variable    ${parameters}[${0}][activeSoftwareVersion]
    ${sw_version_list}    Split String    ${ActiveVersion}     _
    ${release_enb}    Set Variable if    ${sw_version_list[2]}==9999    SBTS00    ${sw_version_list[0]}
    set suite variable    ${release_enb}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

RF module reset
    Log To Console    RF module reset
#    [Arguments]  ${ue_index}=0    ${pcmd}=${False}
    Reset RU And Wait Until On Air
    Check Alarm after OAM opraetion
#    run keyword and continue on failure    L3 call    ue_index=${ue_index}    pcmd=${pcmd}
#    ...    target_avg_percent=${non_peak_target_avg_percent}

Reset RU And Wait Until On Air
    [Arguments]    ${RU_index}=${3}    ${connection}=GNB_OAM
    Log To Console    Reset RU And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    coam.reset_unit    dist_name=MRBTS-${GNB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}    force_radio_reset=${True}
    ...    timeout=${300}    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Each single Baseband module reset
 #   [Arguments]  ${ue_index}=0
    Log To Console    Each single Baseband module reset
    Restart BBMOD
    Check BTS Should Be Normal
    Check Alarm after OAM opraetion
#    run keyword and continue on failure    L3 call    protocol=udp    target_avg_percent=${non_peak_target_avg_percent}
#    ...    ue_index=${ue_index}

Restart BBMOD
    [Arguments]    ${connection}=GNB_OAM
    Log To Console    Restart BBMOD
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    FOR    ${i}    IN    @{BBMOD_list}
        coam.reset_unit    dist_name=MRBTS-${GNB_MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    reset_type=Warm    force_radio_reset=${True}
        ...    timeout=600s    connection=${connection}
        Log To Console    wait until bts should be normal
        Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

#eNB common keywords#
ENB RU Lock Unlock And Wait Until On Air
    [Arguments]    ${RMOD_idx}=${1}    ${connection}=ENB
    Log To Console    RU Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock RU
    coam.lock    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${120}    connection=${connection}
    sleep    3s
    Log To Console    Ulock RU
    coam.unlock    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${120}    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=lte    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

4G RU Lock Unlock then L3call
    Log To Console    4G RU Lock Unlock
 #   [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${4G_pcmd}=${True}
    ${fault_id_list_1}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
    ENB RU Lock Unlock And Wait Until On Air
    sleep    30s
    Check BTS Should Be Normal
    ${fault_id_list_2}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion

ENB Block and UnBlock Cells
    [Arguments]  ${block_list}
    common_keywords.ENB Block cells and check status    block_list=${block_list}
    common_keywords.ENB UnBlock Cells and check status   block_list=${block_list}
ENB Block cells and check status
    [Arguments]  ${block_list}   ${connection}=ENB_OAM
    connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    connection=${connection}
    log to console  \n***Block cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.block_cell    cell_idx=${idx}    timeout=120    technology=LTE
        Wait For Expect Fault Present    faultId=49    timeout=30    connection=${connection}    is_need_to_setup_gnb_connection=${False}
    END
    Wait Until Keyword Succeeds   3 min  10 sec   ENB Cell Should Be Blocked or UNBlocked    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

ENB UnBlock Cells and check status
    [Arguments]  ${block_list}   ${connection}=ENB_OAM
    connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    connection=${connection}
    log to console  \n***UnLock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.unblock_cell    cell_idx=${idx}    timeout=120    technology=LTE
    END
    Wait Until Keyword Succeeds   3 min  10 sec   ENB Cell Should Be Blocked or UNBlocked    if_lock=${False}    connection=${connection}
    Wait For Expect Fault To Disappear  faultId=49    timeout=60    connection=${connection}    is_need_to_setup_gnb_connection=${False}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

4G CELL block unblock then L3call
    [Arguments]    ${connection}=ENB_OAM
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ${fault_id_list_1}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
    Selenium Login And Disable Screen Lock    url=https://${eNB_DU_OAM_IP}    version=${release_enb}
    ${status}    run keyword and return status    common_keywords.ENB Block and UnBlock Cells    block_list=${ENB_CELL_ID}
    run keyword if    not ${status}    Run Keyword And Ignore Error    common_keywords.ENB UnBlock Cells and check status    block_list=${ENB_CELL_ID}
    should be true    ${status}
    ${fault_id_list_2}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    [Teardown]     run keywords    selenium logout and close browser     AND
    ...    run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

ENB Cell Should Be Blocked or UNBlocked
    [Documentation]   Author: lanwen.cai@nokia-sbell.com
    [Arguments]    ${if_lock}=${True}    ${cell_type}=lte    ${connection}=ENB_OAM
    ${disabled}    Set Variable If    ${if_lock}    disabled    enabled
    ${iflocked}    Set Variable If    ${if_lock}    Blocked    Unblocked
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}     ${disabled}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['blockingState']}     ${iflocked}
    END

ENB Reset RU And Wait Until On Air
    [Arguments]    ${RU_index_list}=${RMOD_list}    ${connection}=ENB_OAM
    Log To Console    Reset RU And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    FOR    ${RU_index}    IN    @{RU_index_list}
        coam.reset_unit    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}    force_radio_reset=${True}    timeout=${300}
        ...    connection=${connection}
    END
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=lte    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

ENB Lock and unlock BBMOD
    [Arguments]    ${list}=${BBMOD_list}    ${connection}=ENB_OAM
    Log To Console    Lock and unlock BBMOD
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    FOR    ${i}    IN    @{list}
        coam.lock    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${connection}
        sleep    20s
        coam.unlock    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${connection}
        Log To Console    wait until bts should be normal
        Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=lte    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

ENB L3 call
    [Arguments]    ${protocol}=udp    ${log_time}=${log_time}    ${ul_enable}=${True}    ${dl_enable}=${True}
    ...    ${exp_ul_tp}=${cmw_exp_ul}    ${exp_dl_tp}=${cmw_exp_dl}    ${ue_index}=0    ${total_count}=${total_count}
    ...    ${buffer_size}=1400B    ${buffer_size_ul}=1300B    ${process_num}=${5}
    ...    ${ul_tput_udp_value}=${ul_tput_udp}    ${dl_tput_udp_value}=${dl_tput_udp}
    Log To Console    start L3 call
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark by Index    ue_index=${ue_index}
    ${log_path}    Start UE data traffic and Record TP Log and Aasys Log
    ...    ue_index=${ue_index}    ul_throughput=${ul_tput_udp_value}    dl_throughput=${dl_tput_udp_value}
    ...    ul_duration=${duration}    dl_duration=${duration}     process_num=${process_num}
    ...    protocol=${protocol}    if_ul=${ul_enable}    if_dl=${dl_enable}    time=${log_time}
    ...    buffer_size=${buffer_size}    buffer_size_ul=${buffer_size_ul}
    run keyword and continue on failure    Stop UE traffic and Stop Record TP Log in spark    ue_index=${ue_index}    if_ul=${ul_enable}
    ...    if_dl=${dl_enable}    protocol=${protocol}    spark_log_name=spark_ul_dl_udp
    sleep    10s
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${1}    spark_log_name=spark_ul_dl_udp
    ...    list_length=${total_count}    row_list=${row_list}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    #NR PHY Thr. DL [Mbps]
    run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
    ...    should be true    ${total_result_dict[0]['DL_bler'][0]} < 5.0
    #NR PDCP Thr. DL [Mbps]
    run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
    ...    should be true    ${total_result_dict[0]['DL_tp'][0]} > ${exp_dl_tp}
    #NR PHY Thr. UL [Mbps]
    run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
    ...    should be true    ${total_result_dict[0]['UL_bler'][0]} < 5.0
    #NR PDCP Thr. UL [Mbps]
    run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
    ...    should be true    ${total_result_dict[0]['UL_tp'][0]} > ${exp_ul_tp}
    [Return]    ${total_result_dict}

ENB CELL Lock Unlock And Wait Until On Air
    [Arguments]    ${CELL_idx}=${1}    ${connection}=ENB
    Log To Console    CELL Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock CELL
    coam.lock    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_NRBTS_ID}/LNCEL-${CELL_idx}    timeout=${120}    connection=${connection}
    sleep    3s
    Log To Console    Ulock CELL
    coam.unlock    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_NRBTS_ID}/LNCEL-${CELL_idx}    timeout=${120}    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=lte    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

4G CELL Lock Unlock then L3call
    Log To Console    4G CELL Lock Unlock
 #   [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${4G_pcmd}=${False}
    ${fault_id_list_1}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
    ENB CELL Lock Unlock And Wait Until On Air
    sleep    30s
    Check BTS Should Be Normal
    ${fault_id_list_2}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion

ENB Case X2U
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
    log to console    Modify_NR_BTS_DRB_4_split_mode_To_X2U
    Modify Common parameter via Coam      input_list=${MODIFY_Parameter_FOR_SPLIT_MODE_X2U}    connection=${connection}
    [Teardown]  COAM Teardown gnb connections    connection=${connection}

ENB Case F1U
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
    log to console    Recovery_NR_BTS_DRB_4_split_mode_To_F1U
    Modify Common parameter via Coam      input_list=${MODIFY_Parameter_FOR_SPLIT_MODE_F1U}     connection=${connection}
    [Teardown]  COAM Teardown gnb connections    connection=${connection}

Each RF module lock and unlock
    Log To Console    Each RF module lock/unlock
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}
    RU Lock/Unlock And Wait Until On Air
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=udp    ue_index=${ue_index}    pcmd=${pcmd}
    ...    target_avg_percent=${non_peak_target_avg_percent}

RU Lock/Unlock And Wait Until On Air
    [Arguments]    ${RMOD_idx}=${3}    ${connection}=GNB_OAM
    Log To Console    RU Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock RU
    coam.lock    dist_name=MRBTS-${GNB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    sleep    3s
    Log To Console    Ulock RU
    coam.unlock    dist_name=MRBTS-${GNB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Each single Baseband module lock and unlock
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}
    Log To Console    Each single Baseband module lock and unlock
    Lock and unlock BBMOD
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=udp    ue_index=${ue_index}    pcmd=${pcmd}
    ...    target_avg_percent=${non_peak_target_avg_percent}

Lock and unlock BBMOD
    [Arguments]    ${alias}=GNB_OAM
    Log To Console    Lock and unlock BBMOD
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${alias}
    FOR    ${i}    IN    @{BBMOD_List}
        coam.lock    dist_name=MRBTS-${GNB_MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${alias}
        sleep    20s
        coam.unlock    dist_name=MRBTS-${GNB_MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${alias}
        Log To Console    wait until bts should be normal
        Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${alias}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${alias}

Separately site block unblock then L3call
    [Arguments]     ${ue_index}=0    ${pcmd}=${False}    ${connection}=GNB_OAM
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${cell_list}    Get All Cell Id    connection=${connection}
    Selenium Login And Disable Screen Lock    version=${release_sbts}
    selenium_coam.block_site
    FOR     ${cell_id}    IN     @{cell_list}
        Wait until keyword succeeds    1min   10s    common_keywords.Check cell should be disabled    cell_id=${cell_id}   connection=${connection}
    END
    COAM Teardown gnb connections    connection=${connection}
    selenium_coam.unblock_site
    Wait Until Keyword Succeeds    20min    60s    Check BTS Should Be Normal
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=udp    ue_index=${ue_index}    pcmd=${pcmd}
    ...    target_avg_percent=${non_peak_target_avg_percent}
    [Teardown]     run keywords     selenium logout and close browser     AND
    ...    run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Check cell should be disabled
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]  ${cell_id}   ${connection}=GNB_OAM
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=${connection}
    Cell Should Be Disabled   cell_idx=${cell_id}   cell_group_idx=${cellgrp_id}    connection=${connection}

NRCell group lock and unlock stability testing
    Log To Console    NRCell group lock/unlock stability testing
    [Arguments]  ${ue_index}=0
    Cell Group Lock/Unlock And Wait Until On Air
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}    protocol=udp
    ...    target_avg_percent=${non_peak_target_avg_percent}

Cell Group Lock/Unlock And Wait Until On Air
    [Arguments]    ${cellgroup_idx}=${2}    ${connection}=GNB_OAM
    Log To Console    Cell Group Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock Cell Group
    coam.lock_cell_group    dist_name=MRBTS-${GNB_MRBTS_ID}/NRBTS-${GNB_NRBTS_ID}/NRCELLGRP_A-${cellgroup_idx}
    ...    timeout=${60}    connection=${connection}
    sleep    10s
    Log To Console    Unlock Cell Group
    coam.unlock_cell_group    dist_name=MRBTS-${GNB_MRBTS_ID}/NRBTS-${GNB_NRBTS_ID}/NRCELLGRP_A-${cellgroup_idx}
    ...    timeout=${60}    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

X2 link lock and unlock
    Log To Console    Check X2Link Lock And Unlock
    [Arguments]  ${ue_index}=0
    ${status}    run keyword and return status    X2Link lock/Unlock And Wait Until On Air
    Run Keyword If    '${status}'=='False'    Modify X2Link Parameter    Actual_value=unlocked
    Check Alarm after OAM opraetion
    L3 call    ue_index=${ue_index}    target_avg_percent=${non_peak_target_avg_percent}

X2Link lock/Unlock And Wait Until On Air
    [Arguments]  ${connection}=GNB_OAM
    Log To Console    X2Link lock/Unlock And Wait Until On Air
    sleep    2s
    Log To Console    Lock X2Link
    Modify X2Link Parameter    Actual_value=locked
    sleep    30s
    Log To Console    Unlock X2Link
    Modify X2Link Parameter    Actual_value=unlocked
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Modify X2Link Parameter
    [Arguments]    ${Actual_value}    ${LTE_idx}=${0}    ${alias}=enb
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${alias}
    ${dict}    create dictionary    parameterName=administrativeState    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_NRBTS_ID}/LNADJGNB-${LTE_idx}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${alias}
    sleep    10s
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${alias}

RF module poweroff on
    Log To Console    RF module reset
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}
    Poweroff On RU And Wait Until On Air
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}    pcmd=${pcmd}
    ...    target_avg_percent=${non_peak_target_avg_percent}

Poweroff On RU And Wait Until On Air
    [Arguments]    ${ru_index}=${0}    ${gnb_index}=0    ${connection}=GNB_OAM
    Log To Console    Poweroff On RU And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    log to console    \n***RF Index ${ru_index} in Testline File Power OFF***
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].pdu_port.pdu.vendor}
    sleep    10s
    log to console    \n***RF Index ${ru_index} in Testline File Power ON***
    Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].pdu_port.pdu.vendor}
    sleep    2s
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

LED status check after site reset
    [Documentation]    return led status: Online - green, Failed - red, Degraded - yellow, Not installed / Offline - gray
    Log To Console    LED status check after site reset
    Reset BTS And Wait Until On Air
    Selenium Login And Disable Screen Lock    version=${release_sbts}
    ${SMOD_state}    selenium_coam.get_led_status_of_an_unit     unit=SMOD-${1}
    should be true    '${SMOD_state}'=='Online' or '${SMOD_state}'=='Enabled'
    FOR    ${index}    IN    @{BBMOD_list}
        ${BBMOD_state}    selenium_coam.get_led_status_of_an_unit     unit=BBMOD-${index}
        should be true    '${BBMOD_state}'=='Online' or '${BBMOD_state}'=='Enabled'
    END
    FOR    ${index}    IN    @{RMOD_List}
        ${RMOD_state}    selenium_coam.get_led_status_of_an_unit     unit=RMOD-${index}
        should be true    '${RMOD_state}'=='Online' or '${RMOD_state}'=='Enabled'
    END
    [Teardown]   Run Keyword And Ignore Error    selenium logout and close browser

Separately Filber break then L3call
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
	[Arguments]      ${connection}=GNB_OAM}    ${S_RFs}=${break_SRF}
	...    ${loki}=1    ${bbmod_number}=2    ${ue_index}=0
    Connect to GNB with ssh
    ${bbmod_info}    Get BBMOD INFO DICT
    ${bsh_command}    Get BBMOD BSH Command    bbmod_info_dict=${bbmod_info}    bbmod_number=${bbmod_number}    loki=${loki}
    ${sfpd}    Get SFPD ID    bsh_command=${bsh_command}
    FOR    ${RF}    IN    @{S_RFs}
        ${original_Transceiver}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${RF}    bsh_command=${bsh_command}
        should be true    ${original_Transceiver}>0
        Change one optical transmission by command    sfpd=${sfpd}    switch=1    S_RF=${RF}    bsh_command=${bsh_command}
    END
    Wait until keyword succeeds    5min   20s     Check fault id should be appear    connection=${connection}    check_fault_id=${10}
    FOR    ${RF}    IN    @{S_RFs}
        Change one optical transmission by command    sfpd=${sfpd}    switch=0    S_RF=${RF}    bsh_command=${bsh_command}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
    Wait Until Keyword Succeeds    2min    10s    Run Keyword And Expect Error   *
    ...    Check fault id should be appear    connection=${connection}    check_fault_id=${10}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=udp    log_time=3m    ue_index=${ue_index}
    ...    ul_enable=${True}    dl_enable=${True}    total_count=${100}    target_avg_percent=${non_peak_target_avg_percent}
    [Teardown]  run keywords    selenium logout and close browser     AND
    ...    Run Keyword And Ignore Error    Disconnect SMOD with ssh    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Connect to GNB with ssh
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${timeout}=240s    ${alias_gnb}=gnb_connect
    csn.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    alias=${alias_gnb}    timeout=${timeout}

Disconnect SMOD with ssh
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]      ${alias_gnb}=gnb_connect
    csn.disconnect    connection=${alias_gnb}

Get SFPD ID
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${bsh_command}    ${timeout}=240s   ${alias_gnb}=gnb_connect
    ${sfpd}    csn.Execute    command=bsh ${bsh_command} syscomctl stats list client | grep sfpd | cut -d " " -f 1
    ...    connection=${alias_gnb}    timeout=${timeout}
    ${sfpd}    Strip String    ${sfpd}
    ${sub_sfpd}    Get Substring    ${sfpd}    0    4
    [Return]     ${sub_sfpd}

Get BBMOD INFO DICT
    [Documentation]    Owner_pengliang.wu@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${BBMOD_info_list}    coam.get_fbb_info    connection=${connection}
    ${bbmod_info_dict}    create dictionary
    FOR    ${BBMOD_INFO}    IN    @{BBMOD_info_list}
        @{bbmod_name_split}    string.split string    string=${BBMOD_INFO['productName']}    separator=${SPACE}
        @{bbmod_id_split}    string.split string    string=${BBMOD_INFO['id']['configuration']}    separator=/
        set to dictionary      ${bbmod_info_dict}    ${bbmod_id_split}[${-1}]    ${bbmod_name_split}[${0}]
    END
    Log to console    BBmod infomation:${bbmod_info_dict}
    [Return]    ${bbmod_info_dict}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Get BBMOD BSH Command
    [Documentation]    Owner_pengliang.wu@nokia-sbell.com
    [Arguments]     ${bbmod_info_dict}    ${bbmod_number}=2    ${loki}=1
    ${bbmod_name}    set variable    ${bbmod_info_dict['BBMOD-${bbmod_number}']}
    ${command}    set variable if    '${bbmod_name}'=='ABIL'    ${bbmod_number}:2    ${bbmod_number}:${loki}
    [Return]    ${command}


Get TransceiverTXBiasCurrent value
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param switch: 1: turn off,  0: turn on
    ...                :param S_RF: 3: S_RF1,  4: S_RF2
    [Arguments]     ${sfpd}    ${S_RF}   ${bsh_command}    ${timeout}=240s    ${alias_gnb}=gnb_connect
    ${Transceiver}    csn.Execute
    ...    command=bsh ${bsh_command} sfp_tester get_pti ${S_RF} ${sfpd} | grep Bias | grep TransceiverTXBiasCurrent |cut -d " " -f 2
    ...    connection=${alias_gnb}    timeout=${timeout}
    ${Transceiver}    Strip String    ${Transceiver}
    [Return]   ${Transceiver}

#Change two optical transmission by command
#    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
#    ...                :param switch: 1: turn off,  0: turn on
#    ...                :param S_RF: 3: S_RF1,  4: S_RF2
#    [Arguments]     ${bsh_command}  ${sfpd}    ${alias_gnb}=gnb_connect
#    ...    ${S_RF1}=3   ${S_RF2}=4   ${switch}=1     ${timeout}=240s
#    csn.Execute    command=bsh ${bsh_command} sfp_tester set_tx ${S_RF1} 1 ${switch} ${sfpd}
#    ...    connection=${alias_gnb}    timeout=${timeout}
#    csn.Execute    command=bsh ${bsh_command} sfp_tester set_tx ${S_RF2} 1 ${switch} ${sfpd}
#    ...    connection=${alias_gnb}    timeout=${timeout}
#    sleep   3s
#    ${Transceiver1}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF1}    bsh_command=${bsh_command}
#    ${Transceiver2}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF2}    bsh_command=${bsh_command}
#    run keyword if   '${switch}'=='0'    should be true    ${Transceiver1}>0    ELSE    should be true    ${Transceiver1}==0
#    run keyword if   '${switch}'=='0'    should be true    ${Transceiver2}>0    ELSE    should be true    ${Transceiver2}==0

Change one optical transmission by command
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param switch: 1: turn off,  0: turn on
    ...                :param S_RF: 3: S_RF1,  4: S_RF2(ABIO)    S_RF: 1: S_RF1,  2: S_RF2(ABIL)
    [Arguments]     ${bsh_command}    ${sfpd}    ${alias_gnb}=gnb_connect
    ...    ${S_RF}=3     ${switch}=1     ${timeout}=240s
    csn.Execute    command=bsh ${bsh_command} sfp_tester set_tx ${S_RF} 1 ${switch} ${sfpd}
    ...    connection=${alias_gnb}    timeout=${timeout}
    sleep   3s
    ${Transceiver}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF}    bsh_command=${bsh_command}
    run keyword if   '${switch}'=='0'    should be true    ${Transceiver}>0    ELSE    should be true    ${Transceiver}==0

Check fault id should be appear
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${check_fault_id}    ${connection}=GNB_OAM
    ${active_fault_list}    Get BTS Alarm FaultID     connection=${connection}
    run keyword and continue on failure    list should contain value      ${active_fault_list}     ${check_fault_id}

BTS_whether_need_rollback_before_upgrade
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ${activate_version}    ${passive_version}    ${planned_version}    Get software versions    connection=${connection}
    ${Y_active_string}=    Get SubString    ${activate_version}    4    6
    ${R_active_string}=    Get SubString    ${activate_version}    7    8
    ${Y_passive_string}=    Get SubString    ${passive_version}    4    6
    ${R_passive_string}=    Get SubString    ${passive_version}    7    8
    ${Y_active}    Evaluate    int(${Y_active_string})
    ${R_active}    Evaluate    int(${R_active_string})
    ${Y_passive}    Evaluate    int(${Y_passive_string})
    ${R_passive}    Evaluate    int(${R_passive_string})
    ${Is_need_rollback}    Set variable if    ${Y_active}>${Y_passive}    ${True}
    ...    ${Y_active}==${Y_passive} and ${R_active}>${R_passive}    ${True}    ${False}
    Log to console    Is_need_rollback:${Is_need_rollback}
    [Return]    ${Is_need_rollback}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${target_version}   set variable if      '${testline_name}' == '${EMPTY}'    ${ENB_BUILD}    ${target_version}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${target_version}
    Set Suite Variable    ${TLNAME}
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}


CI_Common_Case_Setup
    Run Keyword And Ignore Error    robot_common_operations.Common Case Setup
    Run Keyword And Ignore Error    CI_interface.Common Case Setup

CI_Common_Case_Teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

CI_Common_Suit_Setup
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    CI_interface.Common Suite Setup

CI_Common_Suit_Teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Teardown

Online change parameter for delta dommissioning and L3 call
    [Arguments]  ${ue_index}=0    ${connection}=GNB_OAM_2
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
    ${new_pci_dic}    create dictionary
    ...    dist_name=${MR_NR_BTS_NAME}/NRCELL-${TestLineList['${TLNAME}']['mmw_lcrid_list']}[${0}]
    ...    parameter=physCellId    value=232    operation=update
    ${old_pci_dic}    create dictionary
    ...    dist_name=${MR_NR_BTS_NAME}/NRCELL-${TestLineList['${TLNAME}']['mmw_lcrid_list']}[${0}]
    ...    parameter=physCellId    value=225    operation=update
    ${MODIFY_Parameter_physCellId}    create list    ${new_pci_dic}
    ${Recover_Parameter_physCellId}    create list    ${old_pci_dic}
    Log to console    Change pci to ${MODIFY_Parameter_physCellId}[${0}][value]
    Modify BTS Parameters with json    input_list=${MODIFY_Parameter_physCellId}    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    Verify PCI was modified successfully    expected_value=${MODIFY_Parameter_physCellId}[${0}][value]    connection=${connection}
    Log to console    Change pci done.
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}
    ...    target_avg_percent=${non_peak_target_avg_percent}
    Log to console    recovery pci to ${Recover_Parameter_physCellId}[${0}][value]
    Modify BTS Parameters with json    input_list=${Recover_Parameter_physCellId}    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    Verify PCI was modified successfully    expected_value=${Recover_Parameter_physCellId}[${0}][value]    connection=${connection}
    Log to console    Change pci done.
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}
    ...    target_avg_percent=${non_peak_target_avg_percent}
    [Teardown]  Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify PCI was modified successfully
    [Arguments]    ${expected_value}    ${connection}=GNB_OAM
    ${nrcells_objects}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}
    ${nrcell_id}    set variable    ${TestLineList['${TLNAME}']['mmw_lcrid_list']}[${0}]
    FOR    ${Item}    IN    @{nrcells_objects}
        ${dist_Name}    set variable    ${Item}[distName]
        ${NRCELL_A}    String.Fetch From Right    ${dist_Name}    marker=/
        ${pci}    set variable if    '${NRCELL_A}'=='NRCELL_A-${nrcell_id}'    ${Item}[parameters][physCellId]    ${EMPTY}
        Exit For Loop If    '${NRCELL_A}'=='NRCELL_A-${nrcell_id}'
    END
    Should be true    '${pci}'=='${expected_value}'

Modify BTS Parameters with json
    [Documentation]    Owner_pengliang.wu@nokia-sbell.com
    [Arguments]    ${input_list}    ${delta_id}=update_parameter    ${connection}=GNB_OAM    ${time}=10s
    coam.create_delta    delta_id=${delta_id}
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}: ${item['value']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    480
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}
    sleep    ${time}

RAT Reset and L3 call
    [Arguments]  ${ue_index}=0    ${rat_type}=nr    ${connection}=SBTS_OAM
    Log To Console    RAT Reset And Wait Until On Air
    # rat_type: nr or lte
    ${op_du_ip}    set variable if     '${rat_type}'=='nr'    ${DU_OAM_IP}    ${eNB_DU_OAM_IP}
    Connect to gnb coam via ssl    bts_host=${op_du_ip}    connection=${connection}
    sleep    2s
    ${rat_type_2}    set variable if     '${rat_type}'=='nr'    NR    LTE
    coam.reset_rat    rat_type=${rat_type_2}    connection=${connection}    timeout=1800
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=lte    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=nr    connection=${connection}
    Check Alarm after OAM opraetion
    Run keyword if    '${rat_type}'=='nr'    L3 call    ue_index=${ue_index}
    ...    target_avg_percent=${non_peak_target_avg_percent}
    ...    ELSE    ENB L3 call
    ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
    ...    total_count=${100}    exp_ul_tp=${5}    exp_dl_tp=${5}    ue_index=${ue_index}
    ...    dl_tput_udp_value=20M    ul_tput_udp_value=20M
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Iptables UDP destination port ACCEPT
    [Arguments]    ${port1}=51001    ${port2}=51000   ${connection}=ute
    csn.connect_to   hostname=${testpc_host}
        ...    username=${testpc_user}    password=${testpc_pswd}    alias=${connection}
    csn.Send Command
    ...    command=sudo iptables -I INPUT -i eth0 -p udp --destination-port ${port1} -j ACCEPT
    ...    connection=${connection}
    csn.Send Command
    ...    command=sudo iptables -I INPUT -i eth0 -p udp --destination-port ${port2} -j ACCEPT
    ...    connection=${connection}
    [Teardown]       csn.Disconnect  	connection=${connection}

Select and setup Commission SCF
    Run Keyword And Ignore Error    Select and setup eNB Commission SCF
    Run Keyword And Ignore Error    Select and setup gNB Commission SCF

Select and setup gNB Commission SCF
    [Arguments]     ${gnb_index}=0    ${connection}=GNB_OAM
    ${host_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ${username}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].airscale.common_units[0].lmp_connection.username}
    ${password}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].airscale.common_units[0].lmp_connection.password}
    ${default_scf}    Get sw build version for scf name    host_name=${host_ip}    username=${username}    password=${password}
    ...    addition_str=gNB
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    log to console    Start commission with gNB SCF
    COAM Commission with scf file      scf_file_path=${default_scf}    connection=${connection}    timeout=600
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Select and setup eNB Commission SCF
    [Arguments]     ${connection}=ENB_OAM
    ${host_ip}    set variable    ${tl.ues[2].airscale.common_units[0].lmp_connection.addr}
    ${username}    set variable    ${tl.ues[2].airscale.common_units[0].lmp_connection.username}
    ${password}    set variable    ${tl.ues[2].airscale.common_units[0].lmp_connection.password}
    ${default_scf}    Get sw build version for scf name    host_name=${host_ip}    username=${username}    password=${password}
    ...    addition_str=eNB
    coam.connect_to    bts_host=${host_ip}    bts_port=${443}
    ...    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}   name=${connection}
    log to console    Start commission with eNB SCF
    COAM Commission with scf file      scf_file_path=${default_scf}    connection=${connection}    timeout=600
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair    cell_type=lte    connection=${connection}
    [Teardown]    Run keyword and ignore error     coam.teardown    connection=${connection}

Get sw build version for scf name
    [Arguments]     ${host_name}    ${username}    ${password}    ${addition_str}=gNB
    ssh.Connect to    hostname=${host_name}    username=${username}    password=${password}    alias=ASIK Master
    ssh.force_reconnect    connection=ASIK Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    Run keyword and ignore error    Remove values From List     ${sw_version_list}    BSR
    ${sw_version_list}    Strip string    ${sw_version_list[0]}
    ${if_Trunk_SBTS}    run keyword and return status    should contain    ${sw_file_name}     9999
    ${sw_version}    set variable if    ${if_Trunk_SBTS}    SBTS00    ${sw_version_list}
    ${default_scf_name}    Catenate    SCF_${sw_version}_${addition_str}.xml
    log to console    Selected SCF name: ${default_scf_name}
    ${default_scf}    set variable    ${CURDIR_path}/${default_scf_name}
    set suite variable    ${default_scf}
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error     csn.disconnect    connection=ASIK Master

Prepare UE and Attach UE by spark1
    [Arguments]  ${ue_index}
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
    samsung_spark.enable_ue_data_service    ue_alias=UE_${ue_index}
    ${5Grach_ed}    samsung_spark.attach_ue    ue_alias=UE_${ue_index}   attach_mode=5G_NSA     power_reset=False    timeout=90000
    log to console    UE_${ue_index}
    log to console    ${5Grach_ed}
    [Return]  ${5Grach_ed}
