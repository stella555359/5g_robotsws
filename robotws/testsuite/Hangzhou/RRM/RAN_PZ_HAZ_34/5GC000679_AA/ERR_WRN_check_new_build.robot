*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup     Common Suite Setup for COAM
Suite Teardown
Force Tags        5G_RRM
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           taf.transport.ssh    WITH NAME    csn
Library           testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.log.GnbLog    WITH NAME    GnbLog
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/log.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/5GC000679_common_keyword_Dingli.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${_scf_file_path}    ${tl_path}/common.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${ReportGenerationPath}   C:\\Logfiles
${data_transfer_dl}     800Mbits/sec
${data_transfer_ul}     100Mbits/sec
${Expected_Throughput_DL}     100
${Expected_Throughput_UL}     10
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}          /home/ute/Downloads/SCF

*** Test Cases ***
[1]ERR_WAR_check_after_sw_build_upgraded
    [Tags]    5GC0006667    ERR_WAR
    [Timeout]  7h
    [Setup]    Case Setup
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    UE Attach For spark    ue_index=${0}    attach_mode=5G_NSA
    check iperf process in Appserver
    UE Start Traffic
    UE Start UL Traffic
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    ${ul_tput}    ${dl_tput}    UE Check Traffic    ue_index=${0}
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=/home/ute/BTS_logs      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    ...       Fail_Case=${False}       Clear_log=${True}
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Case Teardown

*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    COAM Check GNB cell on air
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    robot_common_operations.Common Case Setup

Case Teardown
    Run Keyword And Ignore Error    Dingli Stop traffic    ue_index=${0}
    Run Keyword And Continue On Failure    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    COAM Teardown gnb connections

Common Suite Setup for COAM
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Suite Variable     ${version}     ${result}[0]
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/siso_default_scf.xml

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='NSA'

UE detach For Spark
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=False
	sleep    10s
	power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    ue_alias=UE_${ue_index}
    [Teardown]

UE Attach For Spark
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=False
	sleep    10s
	${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
#	spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=UE_${ue_index}
#	sleep    15s
	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    [Teardown]

UE Start Traffic
    [Arguments]    ${ue_index}=${0}    ${dl_traffic}=1300M/sec    ${send_duration}=6000   ${ue_mode}=NSA
	...    ${apn}=dxdata2
	${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
	...    throughput=${dl_traffic}    duration=${send_duration}    ue_mode=${ue_mode}    apn_address=${apn}

UE Start UL Traffic
    [Arguments]    ${ue_index}=${0}    ${ul_traffic}=130M/sec    ${send_duration}=6000   ${ue_mode}=NSA
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
	[Arguments]    ${ue_index}=${0}    ${dl}=dl    ${ul}=ul    ${ue_mode}=NSA    ${apn}=dxdata2
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
    [Arguments]    ${num}=8    ${attach_mode}=5G_SA    ${dl_traffic}=500M/sec    ${ul_traffic}=100M/sec
	FOR    ${ue_index}    IN RANGE    ${num}
	    ${ue_type}    Get UE type    ue_index=${ue_index}
		power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=False
		${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
		power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
		UE Start Traffic    ue_index=${ue_index}    dl_traffic=${dl_traffic}    ul_traffic=${ul_traffic}
	END

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

Spark UE attach
    [Arguments]    ${n}    ${attach_mode}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "attach_UE${n}"
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}     attach_mode=${attach_mode}    ue_index=${n}
    power_ue.Verify attach     ue_type=${ue_type}    4G_check=True    5Grach_ed=${5Grach_ed}     ue_index=${n}


spark attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
    ...             ${apn_address}    ${ue_mode}    ${attach_mode}
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    run keyword and ignore error    Spark UE attach    n=${n}    attach_mode=${attach_mode}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=7200
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=7200
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}

All spark UEs attach and start DLUL traffic
    [Arguments]     ${apn_address}=dxdata2    ${ue_mode}=NSA    ${attach_mode}=5G_NSA
    FOR    ${i}    IN RANGE    4
        spark attach and start DLUL traffic     data_transfer_dl=${data_transfer_dl}
        ...                                     data_transfer_ul=${data_transfer_ul}
        ...                                     n=${i}
        ...                                     ue_mode=${ue_mode}
        ...                                     attach_mode=${attach_mode}
        ...                                     apn_address=${apn_address}
    END