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
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py     WITH NAME    nrdim


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          Resources/5GC001116_MTK_common_keyword.robot
Resource          ../5GC000534_EB/Resources/MCS.robot
Resource          ../5GC002538/Resources/2538_keyword.robot
Resource          Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot


*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${scf_path}       /home/ute/Downloads/SCF
${_scf_file_path}    ${scf_path}/common.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${tshark_path}    /usr/bin/tshark
${expression_ul}    \"uldata_puschreceivereq\"

@{check_print}    ERR/

*** Test Cases ***
[1]CB006878_A_1_02_cell_on_air_when_enable_CB006878_NSA_singleBWP
    [Tags]    CRT_Trunk
    [Setup]    Case Setup
	import variables    ${CURDIR}/Resources/CB006878_variables.py
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    Reload Case SCF and Commission   scf_file=${scf_path}/${build_version}/common.xml
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    ${cellid}    Create List    ${43810917}
    Set Test Variable    ${cellid}
    COAM Update CB006878 Parameter Via WebUI    parameter_need_to_update=${MODIFY_6878_TRUE}
    ...    download_dir=${TS_CASE_LOG_PATH}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   15 min  5 sec    Verify all cells should be onair
    sleep    60s
    Reboot cpe for test    ue_index=${0}
    Sleep    5min
    CPE Attach And Check Tput    dl_target=1350    ul_target=150
    [Teardown]    Case Teardown

[1]CB006878_B_1_16_L3call_verification_NSA_multiBWP_100MHz_interworking_with_CB008662_Adaptive_re-transmission_true
    [Tags]    CRT_Trunk
    [Setup]    Case Setup
    import variables    ${CURDIR}/Resources/CB006878_variables.py
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    Reload Case SCF and Commission   scf_file=${scf_path}/${build_version}/common.xml
    Wait Until Keyword Succeeds   15 min  5 sec    Verify all cells should be onair
    ${cellid}    Create List    ${43810917}
    Set Test Variable    ${cellid}
    Reboot cpe for test    ue_index=${0}
    Sleep    5min
    CPE Attach And Check Tput    dl_target=1350    ul_target=150
    ${max_prb_false}    Check PUSCH PRB Numbers
    COAM Update CB006878 Parameter Via WebUI    parameter_need_to_update=${MODIFY_6878_TRUE}
    ...    download_dir=${TS_CASE_LOG_PATH}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   15 min  5 sec    Verify all cells should be onair
    CPE Attach And Check Tput    dl_target=1350    ul_target=150
    ${max_prb_true}    Check PUSCH PRB Numbers
    Should Be True    ${max_prb_true}>${max_prb_false}
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
    Comment    Run Keyword And Ignore Error    Recover swconfig file
    Comment    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${_scf_file_path}
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run Keyword If    '${build_version}' == 'SBTS26R1'    Reload Case SCF and Commission
    ...     scf_file=${scf_path}/${build_version}/SCF_trunk_971_golden.xml
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

MCS Set Beam
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${vertical_angle}    ${horizontal_angle}
    MCS Setup    ip=${tl.mcses.ip_addr}    vendor=hbte
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
        ${index}    evaluate    ${num}-1
        MCS Set Phases According to Angles    vertical_angle=${${vertical_angle}[${index}]}
        ...    horizontal_angle=${${horizontal_angle}[${index}]}    vertical_distance=${2.1}
        ...    horizontal_distance=${0.5}    output_group_id=${num}
    END
    MCS Teardown

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Get original Mcs and Throughput
    Wait until keyword succeeds    2 min    5 s    Teardown the Aasyslog save progress     gnb_index=${0}     du_index=${0}
    ${origin_throughput}=     Caculate DL throughput from L2lo
    ${origin_mcs}=     Run Keyword And Continue On Failure     Get Mcs value in WebUI
    set test variable    ${origin_throughput}
    set test variable    ${origin_mcs}
    log to console    \n origin_throughput=${origin_throughput}Mbps
    log to console    \n origin_mcs=${origin_mcs}
    [Return]     ${origin_throughput}     ${origin_mcs}

COAM Update CB006878 Parameter Via WebUI
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
    Run keyword if    '${build_version}' == 'SBTS25R1'
    ...    COAM check validation errors from webui    is_need_to_check_validation_errors=${True}
    ...    ELSE IF    '${build_version}' == 'SBTS24R3'
    ...                 COAM check validation errors from webui    is_need_to_check_validation_errors=${True}
    ...     ELSE    COAM check validation errors from webui for CB012840
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    2min
    [Teardown]    COAM selenium logout

UE Attach For CPE
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    wait until keyword succeeds    2x    3s    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    pci=181
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    [Teardown]

UE Send Traffic
    [Arguments]    ${ue_index}=${0}    ${dl_traffic}=1500M/sec    ${ul_traffic}=260M/sec    ${send_duration}=900
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    throughput=${dl_traffic}    duration=${send_duration}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_traffic}    duration=${send_duration}     process_num=5

UE Check Traffic
    [Arguments]    ${ue_index}=${0}    ${dl_target}=${1400}    ${ul_target}=${180}    ${duration}=300s
    ${ue_type}    Get UE type    ue_index=${ue_index}
    ${full_log_path}    power_ue.Collect Tput    ue_index=${ue_index}    ue_type=${ue_type}    duration=${duration}    check_source=Aasyslog
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    cells=${cellid}
    ...    target_throughput=${dl_target}    log=${full_log_path}    target_avg_percent=0.98    check_source=Aasyslog
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    cells=${cellid}
    ...    target_throughput=${ul_target}    log=${full_log_path}    target_avg_percent=0.98    check_source=Aasyslog

UE Detach For CPE
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

CPE Attach And Check Tput
    [Arguments]    ${dl_target}=1400    ${ul_target}=180
    UE Attach For CPE
    sleep    20s
    UE Send Traffic
    Capture BIP Log and Download By Web    duration=2s
    UE Check Traffic    dl_target=${dl_target}    ul_target=${ul_target}
    [Teardown]    UE Detach For CPE

Get ul pdml from bip
    [Arguments]    ${pcap_file}=${bip_log_path}    ${expression}=${expression_ul}
    ${timeslot}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${output}    ${TS_CASE_LOG_PATH}/result_${timeslot}.pdml
    Set Test Variable    ${ul_command}    ${tshark_path} -r ${pcap_file} -Y ${expression} -T pdml > ${output}
    Run    ${ul_command}

Check PUSCH PRB Numbers
    [Arguments]    ${check_item0}=showname="numOfPrb+.*: (\\d*)"
    ...    ${check_item1}=showname="rnti+.*: (\\d*)"
    Get ul pdml from bip
    ${prb}    get_value_from_log_file    file_path=${output}     check_item=${check_item0}
    ${rnti}    get_value_from_log_file    file_path=${output}     check_item=${check_item1}
    ${new_prb}    type_change_string_to_ini    ${prb}
    ${max_prb}    get_max_value_in_list    ${new_prb}
    [Return]    ${max_prb}

CPE Attach And Capture Bip
    [Arguments]
    UE Attach For CPE
    sleep    20s
    UE Send Traffic
    Capture BIP Log and Download By Web    duration=2s
    [Teardown]    UE Detach For CPE
