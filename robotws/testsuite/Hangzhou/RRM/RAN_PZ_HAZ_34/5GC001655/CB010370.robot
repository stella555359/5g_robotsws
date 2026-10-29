*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          Resources/5GC001116_MTK_common_keyword.robot
Resource          ../5GC000534_EB/Resources/MCS.robot
Resource          ../5GC002538/Resources/2538_keyword.robot
Resource          Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot


*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${scf_path}       /home/ute/Downloads/SCF
${_scf_file_path}    ${scf_path}/common_10370.xml
${_scf_file_path_recover}    ${scf_path}/common.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${tshark_path}    /usr/bin/tshark

@{check_print}    ERR/

*** Test Cases ***
[1]TDD mMIMO Chile AEHC 5GNR Only 3 multiply 3CC_90M_16D8U_50M_8D4U_10M_8D4U_2ABIO_3sectors_L3_Call_TSN
    [Tags]    CB010370    CRT_TRUNK
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    Reload Case SCF and Commission    scf_file=${scf_path}/${build_version}/common_10370.xml
    Wait Until Keyword Succeeds   15 min  5 sec    Verify all cells should be onair
    ${cellid}    Create List    ${43811917}
    Set Test Variable    ${cellid}
    Reboot cpe for test    ue_index=${0}
    Sleep    5min
    CPE Attach And Check Tput
    [Teardown]    Case Teardown


*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${result}    String.split string    string=${target_version}    separator=_
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${build_version}     ${result}[0]
    robot_common_operations.Common Case Setup
    check pdl after sw update    download_dir=${TS_CASE_LOG_PATH}

Case Teardown
    Run Keyword And Ignore Error    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Comment    Run Keyword And Ignore Error    Recover swconfig file
    Run Keyword If    '${build_version}' == 'SBTS26R1'    Reload Case SCF and Commission
    ...     scf_file=${scf_path}/${build_version}/SCF_trunk_971_golden.xml
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown


Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'


UE Attach and Start Original Traffic
    [Arguments]     ${direction}     ${throughput}     ${duration}
    wait until keyword succeeds    15min    10s
     Common UE Attach
    power_ue.Start traffic     ue_type=${ue_type}     direction=${direction}     throughput=${throughput}     duration=${duration}
    sleep    10s
    Get original Mcs and Throughput
    [Teardown]     Run Keyword And Continue On Failure     Run keywords
    ...    Common Capture BIP log and download to testPC
    ...    AND    Check MCS Value    bip_log=${bip_log_path}
    ...    AND    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    ...    AND    power_ue.UE Detach     ue_type=${ue_type}

Start Traffic and Check Throughput
    [Arguments]     ${throughput}    ${direction}=dl     ${duration}=900    ${Expected_Throughput_DL}=100
    wait until keyword succeeds    15min    10s    Common UE Attach    #zhe shi wei le deng ji zhan qi lai?
    power_ue.Start traffic     ue_type=${ue_type}     direction=${direction}     throughput=${throughput}     duration=${duration}
    sleep    10s    #shi jian bu gou?
	${tput_log}    Run Keyword And Continue On Failure    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m
	${real_dl_tput}    Run Keyword And Continue On Failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}    target_throughput=${Expected_Throughput_DL}
    Log To Console    \nreal_dl_tput=${real_dl_tput}\n             #ke yi bu da yin ma ?
    Log To Console    \naverage_dl_tput=${real_dl_tput[0]['average']}\n     #shen mo yi si?
    [Teardown]     Run Keyword And Continue On Failure     Run keywords
    ...    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    ...    AND    power_ue.UE Detach     ue_type=${ue_type}
    [Return]  ${real_dl_tput[0]['average']}

Updata with Multiple parameter
    [Arguments]    ${MODIFY_SCF_list}    ${is_gnb_restrat_after_online_modify}=True
    #FOR     ${PARAMS_TO_MODIFY_SCF}    IN     ${MODIFY_SCF_list}
        COAM Update several parameters via webUI
        ...    parameters_to_update_via_webui=${MODIFY_SCF_list}
        ...    download_dir=${TS_CASE_LOG_PATH}
        ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
		...		is_need_to_check_validation_errors=${True}
    #END

Get original Mcs and Throughput
    Wait until keyword succeeds    2 min    5 s    Teardown the Aasyslog save progress     gnb_index=${0}     du_index=${0}
    ${origin_throughput}=     Caculate DL throughput from L2lo
    ${origin_mcs}=     Run Keyword And Continue On Failure     Get Mcs value in WebUI
    set test variable    ${origin_throughput}
    set test variable    ${origin_mcs}
    log to console    \n origin_throughput=${origin_throughput}Mbps
    log to console    \n origin_mcs=${origin_mcs}
    [Return]     ${origin_throughput}     ${origin_mcs}

Caculate DL throughput from L2lo
    Teardown the Aasyslog save progress     gnb_index=${0}     du_index=${0}
    Aasyslog precondition     gnb_index=${0}     du_index=${0}
    Start the Aasyslog save progress     gnb_index=${0}     du_index=${0}     filter=L2Lo     log_name=data_dl.txt
    ${throughput}=     Caculate DL throughput on gnb L2Lo with re     log_type=Aasyslog     sample=${50}
    [Return]     ${throughput}

COAM Update CB008004 Parameter Via WebUI
    [Arguments]    ${parameter_need_to_update}    ${download_dir}
	COAM Navigate to login page via webUI    download_dir=${download_dir}
	FOR  ${cur_para_to_update}  IN  @{parameter_need_to_update}
        ${cur_para_value}    selenium_coam.get_parameter_value
    ...    dist_name=${cur_para_to_update['dist_name']}
    ...    abbr=${cur_para_to_update['abbr']}
    ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
    ...    Log to console    current value is ${cur_para_value}, no need to update
    ...    ELSE    selenium_coam.set_parameter_value
    ...    dist_name=${cur_para_to_update['dist_name']}
    ...    abbr=${cur_para_to_update['abbr']}
    ...    filter_param=${cur_para_to_update['filter_param']}
    ...    new_value=${cur_para_to_update['new_value']}
	END
	selenium_coam.validate_plan
	COAM check validation errors from webui    is_need_to_check_validation_errors=${True}
	selenium_coam.activate_plan    activate_plan_despite_errors=${True}
	[Teardown]    COAM selenium logout

UE Attach For CPE
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
#	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
	${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    [Teardown]

UE Send Traffic
    [Arguments]    ${ue_index}=${0}    ${dl_traffic}=1500M/sec    ${ul_traffic}=200M/sec    ${send_duration}=900
	${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
	...    throughput=${dl_traffic}    duration=${send_duration}
	power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
	...    throughput=${ul_traffic}    duration=${send_duration}    process_num=5

UE Check Traffic
    [Arguments]    ${ue_index}=${0}    ${dl_target}=${1300}    ${ul_target}=${120}    ${duration}=2m
	${ue_type}    Get UE type    ue_index=${ue_index}
	${full_log_path}    power_ue.Collect Tput    ue_type=${ue_type}    ue_index=${ue_index}    duration=${duration}    check_source=Aasyslog
	run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    cells=${cellid}
    ...    target_throughput=${dl_target}    log=${full_log_path}    check_source=Aasyslog
	run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    cells=${cellid}
    ...    target_throughput=${ul_target}    log=${full_log_path}    check_source=Aasyslog

UE Detach For CPE
    [Arguments]    ${ue_index}=${0}
	${ue_type}    Get UE type    ue_index=${ue_index}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

CPE Attach And Check Tput
    [Arguments]
	UE Attach For CPE
	UE Send Traffic
	sleep    20s
	UE Check Traffic
	[Teardown]    UE Detach For CPE
