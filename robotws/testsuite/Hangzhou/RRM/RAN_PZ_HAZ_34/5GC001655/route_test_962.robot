*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup     Common Suite Setup for COAM
Suite Teardown
Force Tags        5G_RRM    QCD_MN_5G    QCP_5G
Test Timeout  8h
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           taf.transport.ssh    WITH NAME    csn
Library           testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.log.GnbLog    WITH NAME    GnbLog
Library           taf.rfrl.common_resources.python.TTI_Trace    WITH NAME    TTI_Trace
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          ../5GC001655/Resources/5GC001116_MTK_common_keyword.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/log.py
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/topyoung.robot
Resource          Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/5GC000679_common_keyword_Dingli.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${_scf_file_path}    ${tl_path}/common.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt

@{dl_file_list}
@{ul_file_list}
${ReportGenerationPath}   C:\\Logfiles

${data_transfer_dl}     800Mbits/sec
${data_transfer_ul}     100Mbits/sec
${Expected_Throughput_DL}     100
${Expected_Throughput_UL}     10

${scf_path}          /home/ute/Downloads/SCF

@{pa_value}     84    83    82
...      81    80    79    78    77    76    75    74    73    72    71    70    69    68    67    66    65    64
...      63    62    61    60    59    58    57    56    55    54    53    52    51    50    49    48    47    46
...      45    44    43    42    41    40    39    38    37    36    35    34    33    32    31    30    29    28
...      27    26    25    24    23    22    21    20    19    18    17    16    15    14    13    12    11    10
...      9    8    7    6    5    4    3    2    1    0

*** Test Cases ***
Attach_100
    [Tags]    5GC000534    11.800
    [Timeout]  5h
    [Setup]    Case Setup
    FOR    ${i}    IN RANGE    100
        Run Keyword And Ignore Error    UE Attach For spark    ue_index=${0}    attach_mode=5G_NSA
        sleep      3s
        Run Keyword And Ignore Error    UE detach For Spark
    END
    [Teardown]    Case Teardown

Route_4UEs_DLUL_962
    [Tags]    5GC000534
    [Timeout]  2h
    [Setup]    Case Setup
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    log to console      "4UE_attach_Tput"
    All spark UEs attach and start DLUL traffic
    sleep    5s
    log to console      "4UE_check_Tput"
    Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=40
    Run Keyword And Ignore Error    Check throughput on gNB    direction=ul    throughput=5
    Run Keyword And Ignore Error    All UEs Check Tput    num=4
    start_test_record    host=${tl.ues[0].ssh_connection_details.addr}    logpath=C:\\Logfiles\\    logname=${dl_file_name}
    Adjust topyoung PA value for cycle
    stop_test_record    host=${tl.ues[0].ssh_connection_details.addr}
    check iperf process in Appserver
    set test variable    ${dl_file_name}    ${dl_file_name}-1.saf
    get saf log from spark    filename=${dl_file_name}
    export pic report from spark    DLUL=DL_2    dlul_file_list=C:\\Logfiles\\${dl_file_name}
    Append To List	${dl_file_list}   C:\\Logfiles\\${dl_file_name}
    [Teardown]    Case Teardown

Route_DL_962
    [Tags]    5GC000534    11.800
    [Timeout]  2h
    [Setup]    Case Setup
    UE Attach For spark    ue_index=${0}    attach_mode=5G_NSA
    check iperf process in Appserver
    UE Start Traffic     ue_index=${0}    ue_mode=NSA
    sleep    10s
    ${ul_tput}    ${dl_tput}    UE Check Traffic    ue_index=${0}
    start_test_record    host=${tl.ues[2].ssh_connection_details.addr}    logpath=C:\\Logfiles\\    logname=${dl_file_name}
    Adjust topyoung PA value for cycle
    stop_test_record    host=${tl.ues[2].ssh_connection_details.addr}
    check iperf process in Appserver
    set test variable    ${dl_file_name}    ${dl_file_name}-1.saf
    get saf log from spark    filename=${dl_file_name}
    export pic report from spark    DLUL=DL_2    dlul_file_list=C:\\Logfiles\\${dl_file_name}
    Append To List	${dl_file_list}   C:\\Logfiles\\${dl_file_name}
    [Teardown]    Case Teardown

Route_UL_962
    [Tags]    5GC000534    11.800
    [Timeout]  2h
    [Setup]    Case Setup
    UE Attach For spark    ue_index=${0}    attach_mode=5G_NSA
    UE Start UL Traffic    ue_index=${0}    ue_mode=NSA
    sleep    10s
    ${ul_tput}    ${dl_tput}    UE Check Traffic     ue_index=${0}
    start_test_record    host=${tl.ues[2].ssh_connection_details.addr}    logpath=C:\\Logfiles\\    logname=${ul_file_name}
    Adjust topyoung PA value for cycle
    stop_test_record    host=${tl.ues[2].ssh_connection_details.addr}
    set test variable    ${ul_file_name}    ${ul_file_name}-1.saf
    get saf log from spark    filename=${ul_file_name}
    export pic report from spark    DLUL=UL_2    dlul_file_list=C:\\Logfiles\\${ul_file_name}
    Append To List	${ul_file_list}   C:\\Logfiles\\${ul_file_name}
    [Teardown]    Case Teardown

Route_DL_1_962
    [Tags]    5GC000534    11.800
    [Timeout]  2h
    [Setup]    Case Setup
    UE Attach For spark    ue_index=${0}    attach_mode=5G_NSA
    check iperf process in Appserver
    UE Start Traffic     ue_index=${0}    ue_mode=NSA
    sleep    10s
    ${ul_tput}    ${dl_tput}    UE Check Traffic    ue_index=${0}
    start_test_record    host=${tl.ues[2].ssh_connection_details.addr}    logpath=C:\\Logfiles\\    logname=${dl_file_name}
    Adjust topyoung PA value for cycle
    stop_test_record    host=${tl.ues[2].ssh_connection_details.addr}
    check iperf process in Appserver
    set test variable    ${dl_file_name}    ${dl_file_name}-1.saf
    get saf log from spark    filename=${dl_file_name}
    export pic report from spark    DLUL=DL_2    dlul_file_list=C:\\Logfiles\\${dl_file_name}
    Append To List	${dl_file_list}   C:\\Logfiles\\${dl_file_name}
    [Teardown]    Case Teardown

Route_UL_1_962
    [Tags]    5GC000534    11.800
    [Timeout]  2h
    [Setup]    Case Setup
    UE Attach For spark    ue_index=${0}    attach_mode=5G_NSA
    UE Start UL Traffic    ue_index=${0}    ue_mode=NSA
    sleep    10s
    ${ul_tput}    ${dl_tput}    UE Check Traffic     ue_index=${0}
    start_test_record    host=${tl.ues[2].ssh_connection_details.addr}    logpath=C:\\Logfiles\\    logname=${ul_file_name}
    Adjust topyoung PA value for cycle
    stop_test_record    host=${tl.ues[2].ssh_connection_details.addr}
    set test variable    ${ul_file_name}    ${ul_file_name}-1.saf
    get saf log from spark    filename=${ul_file_name}
    export pic report from spark    DLUL=UL_2    dlul_file_list=C:\\Logfiles\\${ul_file_name}
    Append To List	${ul_file_list}   C:\\Logfiles\\${ul_file_name}
    [Teardown]    Case Teardown

Export DL UL Report_962
    [Timeout]  2h
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${split_result}    String.split string    string=${build}    separator=_
    ${big_build}    get from list    ${split_result}    0
    ${first_name}    Replace String    ${big_build}    SBTS    5G
    Set Test Variable    ${first_name}
    export excel from spark    first_name=${first_name}
    [Teardown]    Case Teardown for exceport

*** Keywords ***
Case Setup
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
    Set Test Variable    ${dl_file_name}    ${first_name}_${small_build}_ROUTE_DL_${timestamp}
    Set Test Variable    ${ul_file_name}    ${first_name}_${small_build}_ROUTE_UL_${timestamp}
    reset_spark_ue    host=${tl.ues[0].ssh_connection_details.addr}    ue=1
    sleep    30s
    Run Keyword And Ignore Error    UE detach For Spark

Case Teardown
    Comment    Run Keyword And Ignore Error    Recover swconfig file
    Comment    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${_scf_file_path}
    sleep    20s
    Run Keyword And Ignore Error    Dingli Stop traffic    ue_index=${0}
    Run Keyword And Ignore Error    stop_spark_ul_traffic    ${tl.ues[0].ssh_connection_details.addr}    ue=-1
    Run Keyword And Continue On Failure    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    COAM Teardown gnb connections

Common Suite Setup for COAM
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Suite Variable     ${version}     ${result}[0]
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/scf_route_test.xml
    power_off_for_spark    host=${tl.ues[2].ssh_connection_details.addr}    ue_index=1
    sleep    5s
    power_on_for_spark     host=${tl.ues[2].ssh_connection_details.addr}    ue_index=1
    sleep    35s

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='NSA'

Modify Element Value
    [Arguments]    ${input_scf}    ${parameter_list}    ${output_scf}
    scf.load scf    ${input_scf}
    FOR    ${item}    IN    @{parameter_list}
        scf.modify_scf_element    dist_name=${item}[dist_name]    list_name=${item}[list_name]    value=${item}[value]
    END
    scf.save scf    ${output_scf}

Adjust topyoung PA value for cycle
    [Documentation]    semulate UE from good ponit to bad point
    log to console      "get PA init value"
    ${initial_att_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    Set Test Variable    ${initial_att_values}
    log to console      "Set PA value from good ponit to bad point"
    FOR    ${i}    IN RANGE    85
        Adjust PA value for topyoung11    n=${i}
        sleep      10s
    END
    FOR    ${i}    IN RANGE    85
        Adjust PA value for topyoung    n=${i}
        sleep      10s
    END
    gnb_classical_hangzhou.Restore Attenuation Values For RU  initial_att_values=${initial_att_values}

Adjust PA value for topyoung11
    [Documentation]    set PA to planned value, @{pa_value}[0],@{pa_value}[1],@{pa_value}[2],...
    [Arguments]    ${n}
    log to console      "set PA value${n}"
    &{channels_to_modify}    create dictionary    1=${n}    2=${n}    3=${n}    4=${n}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}

Adjust PA value for topyoung
    [Documentation]    set PA to planned value, @{pa_value}[0],@{pa_value}[1],@{pa_value}[2],...
    [Arguments]    ${n}
    log to console      "set PA value${n}"
    &{channels_to_modify}    create dictionary    1=${pa_value}[${n}]    2=${pa_value}[${n}]    3=${pa_value}[${n}]    4=${pa_value}[${n}]
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}

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

get pic log from spark
    [Arguments]
    ...     ${spark_name}=${tl.ues[2].ssh_connection_details.username}
    ...     ${spark_addr}=${tl.ues[2].ssh_connection_details.addr}
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass -p spark scp ${spark_name}@${spark_addr}:/cygdrive/c/Logfiles/*.png ${OUTPUT DIR}/   shell=yes
    Sleep    10s
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${OUTPUT DIR}/*.png
    Sleep    3s

export pic report from spark
    [Arguments]    ${DLUL}    ${dlul_file_list}
    [Timeout]  5min
    dele_report_on_pc    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
    ...                  filename=\/cygdrive\/c\/Logfiles\/*.png
    export_line_chartPic_for_T962    host=${tl.ues[2].ssh_connection_details.addr}   Logfiles=${dlul_file_list}
    ...              Template=${DLUL}    ExportPath=${ReportGenerationPath}
    get pic log from spark
    dele_report_on_pc    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
    ...                  filename=\/cygdrive\/c\/Logfiles\/*.png

get saf log from spark
    [Arguments]  ${filename}
    ...     ${spark_name}=${tl.ues[2].ssh_connection_details.username}
    ...     ${spark_addr}=${tl.ues[2].ssh_connection_details.addr}
    Run Keyword And Ignore Error    run process
    ...     sudo sshpass -p spark scp ${spark_name}@${spark_addr}:/cygdrive/c/Logfiles/${filename} ${TS_CASE_LOG_PATH}/${filename}   shell=yes
    Sleep    10s
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${TS_CASE_LOG_PATH}/${filename}
    Sleep    3s

get report from spark
    [Arguments]
    ...     ${spark_name}=${tl.ues[2].ssh_connection_details.username}
    ...     ${spark_addr}=${tl.ues[2].ssh_connection_details.addr}
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass -p spark scp ${spark_name}@${spark_addr}:/cygdrive/c/Logfiles/*.xlsx ${OUTPUT DIR}/   shell=yes
    Sleep    10s
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo chmod 777 ${OUTPUT DIR}/*.xlsx
    Sleep    3s

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

export excel from spark
    [Arguments]  ${first_name}
    [Timeout]  5min
    dele_report_on_pc    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
    ...                  filename=\/cygdrive\/c\/Logfiles\/*.xlsx
    export_report_for_T10812    host=${tl.ues[2].ssh_connection_details.addr}   Logfiles=${dl_file_list}
    ...            ReportName=C:\\Logfiles\\${first_name}_T962_TA_DL.rpt
    ...            ReportGenerationPath=${ReportGenerationPath}
    export_report_for_T10812    host=${tl.ues[2].ssh_connection_details.addr}   Logfiles=${ul_file_list}
    ...            ReportName=C:\\Logfiles\\${first_name}_T962_TA_UL.rpt
    ...            ReportGenerationPath=${ReportGenerationPath}
    get report from spark
    dele_report_on_pc    host=${tl.ues[2].ssh_connection_details.addr}    username=spark    password=spark
    ...                  filename=\/cygdrive\/c\/Logfiles\/*.xlsx

Case Teardown for exceport
    Run Keyword If Timeout Occurred    export excel from spark    first_name=${first_name}

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