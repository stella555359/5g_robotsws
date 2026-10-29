*** Settings ***
Documentation     author: yulu
...               contact: lu.1.yu@nokia-sbell.com
...               squad group: SG_02
Suite Setup    Common Suite Setup for COAM
Suite Teardown   robot_common_operations.Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_5G    QCP_5G
Test Timeout  8.5h
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           taf.transport.ssh    WITH NAME    csn
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.log.GnbLog    WITH NAME    GnbLog
Library    taf.rfrl.common_resources.python.TTI_Trace    WITH NAME    TTI_Trace
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          ../5GC001655/Resources/5GC001116_MTK_common_keyword.robot
Library          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/log.py
#Resource          ../5GC000534_EB/Resources/MCS.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/topyoung.robot
Resource          Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${_scf_file_path}    ${tl_path}/common.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
@{beamset_horizontal}    -19    -19    19    19    19    19    -19    -19    -19    -19    19    19    19    19    -19    -19
@{beamset_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96

@{dl_ul_file_list}

${ReportGenerationPath}   C:\\Logfiles

${scf_path}    /home/ute/Downloads/SCF

${mcs_ip}    ${tl.mcses[0].ip_addr}
${server_port}    ${tl.mcses[0].port}
${mcs_model}    ${tl.mcses[0].model}

@{out_port}     ${13}    ${14}    ${15}    ${16}

@{check_print}    ERR/

@{gap_time}    ${0}   ${15}   ${30}   ${45}

*** Test Cases ***
mutiue_Route_DL_UL
	[Timeout]  1.5h
    [Setup]    Case Setup
    Run keyword and ignore error    Start Btslog Collect
	UE Attach For spark
	check iperf process in Appserver
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python iperf_mutiue.py
	start or stop DL traffic in Appserver    command=sh regression_iperf.sh 4
	Set Test Variable     ${ue_mode}    SA
	sleep    10s
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=1
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=2
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=3
	Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=4
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python TPY_ok.py \> result_${timestamp}.txt
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python iperf_mutiue_kill.py
	start or stop DL traffic in Appserver    command=sh regression_iperf.sh kill_iperf
	check iperf process in Appserver
    [Teardown]    Case Teardown

mutiue_Route_DL_UL_1
    [Timeout]  1h
    [Setup]    Case Setup
	Run keyword and ignore error    Start Btslog Collect
	UE Attach For spark
	check iperf process in Appserver
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python iperf_mutiue.py
	start or stop DL traffic in Appserver    command=sh regression_iperf.sh 4
	Set Test Variable     ${ue_mode}    SA
	sleep    10s
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=1
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=2
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=3
	Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=4
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python TPY_ok.py \> result_${timestamp}.txt
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python iperf_mutiue_kill.py
	start or stop DL traffic in Appserver    command=sh regression_iperf.sh kill_iperf
	check iperf process in Appserver
    [Teardown]    Case Teardown

mutiue_Route_DL_UL_2
    [Timeout]  1h
    [Setup]    Case Setup
	Run keyword and ignore error    Start Btslog Collect
	UE Attach For spark
	check iperf process in Appserver
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python iperf_mutiue.py
	start or stop DL traffic in Appserver    command=sh regression_iperf.sh 4
	Set Test Variable     ${ue_mode}    SA
	sleep    10s
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=1
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=2
    Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=3
	Run Keyword And Continue On Failure    get_tput_from_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=4
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python TPY_ok.py \> result_${timestamp}.txt
	run_python_script_on_TestPC    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
	...    scriptpath=\/cygdrive\/c\/Users\/spark\/Desktop\/TOPYOUNG_128x16_2023_0908_151324
	...    script=python iperf_mutiue_kill.py
	start or stop DL traffic in Appserver    command=sh regression_iperf.sh kill_iperf
	check iperf process in Appserver
    [Teardown]    Case Teardown

*** Keywords ***
Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    COAM Check GNB cell on air
	${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
	Set Test Variable    ${timestamp}
	reset_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=1
	reset_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=2
	reset_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=3
	reset_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=4
	sleep    30s

Case Teardown
	robot_common_operations.Common Case Teardown
	Run Keyword And Ignore Error    detach_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=1
	Run Keyword And Ignore Error    detach_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=2
	Run Keyword And Ignore Error    detach_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=3
	Run Keyword And Ignore Error    detach_spark_ue    host=${tl.ues[2].ssh_connection_details.addr}    ue=4
	Run keyword and ignore error    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
	Run Keyword And Continue On Failure    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    COAM Teardown gnb connections

Common Suite Setup for COAM
    Connect to gnb coam via ssl
	check pdl after sw update    download_dir=/home/ute/Downloads
	robot_common_operations.Common Suite Setup
	${time} =	Get Time   min
	${time}    Convert To Integer    ${time}
    sinmple_timer    min=${time}    gap_time=${gap_time}
    ${build}    Coam Get Active SW Version
	${result}    String.split string    string=${build}    separator=_
	Set Suite Variable     ${version}     ${result}[0]
	Run keyword and ignore error    Start Btslog Collect
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/scf_route_test.xml
	Run keyword and ignore error    Stop Btslog Collect    target_dir=${OUTPUT DIR}

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

UE Attach For Spark
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${7}    get_spark_license=False
	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    get_spark_license=False
	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    get_spark_license=False
	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}    get_spark_license=False
	sleep    10s
	${5Grach_ed}    wait until keyword succeeds    4x    3s    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${7}
	...    attach_mode=${attach_mode}
	${5Grach_ed}    wait until keyword succeeds    4x    3s    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}
	...    attach_mode=${attach_mode}
	${5Grach_ed}    wait until keyword succeeds    4x    3s    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}
	...    attach_mode=${attach_mode}
	${5Grach_ed}    wait until keyword succeeds    4x    3s    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${2}
	...    attach_mode=${attach_mode}
	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${7}
	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${1}
	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${0}
	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${2}
    [Teardown]

Connect to ABIL
    [Arguments]    ${command}=bsh1:1    ${asik_alias}=ASIK Master
	${connection}    csn.Execute    ${command}    connection=${asik_alias}
	[Return]    ${connection}

check iperf process in Appserver
   [Arguments]
   ...     ${appserver_host}=${tl.ues[2].iperf_details.ssh_connection_details.addr}
   ...     ${appserver_username}=${tl.ues[2].iperf_details.ssh_connection_details.username}
   ...     ${appserver_password}=${tl.ues[2].iperf_details.ssh_connection_details.password}
   csn.connect_to    hostname=${appserver_host}    username=${appserver_username}
   ...               password=${appserver_password}    alias=APPserver
   set test variable    ${check_iperf_cmd}   ps -ef|grep iperf
   csn.send_command     command=${check_iperf_cmd}    connection=APPserver
   csn.Read Output  connection=APPserver
   csn.Disconnect    connection=APPserver

start or stop DL traffic in Appserver
   [Arguments]
   ...     ${command}
   ...     ${appserver_host}=${tl.ues[2].iperf_details.ssh_connection_details.addr}
   ...     ${appserver_username}=${tl.ues[2].iperf_details.ssh_connection_details.username}
   ...     ${appserver_password}=${tl.ues[2].iperf_details.ssh_connection_details.password}
   csn.connect_to    hostname=${appserver_host}    username=${appserver_username}
   ...               password=${appserver_password}    alias=APPserver
   csn.send_command     command=${command}    connection=APPserver
   csn.Disconnect    connection=APPserver
