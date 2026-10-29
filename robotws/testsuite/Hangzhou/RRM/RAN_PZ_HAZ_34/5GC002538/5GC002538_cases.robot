*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02
Suite Setup
Suite Teardown
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          ../5GC001655/Resources/5GC001116_MTK_common_keyword.robot
Resource          ../5GC000534_EB/Resources/MCS.robot
Resource          Resources/2538_keyword.robot


*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${_scf_file_path}    ${tl_path}/common.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
@{beamset_horizontal}    -19    -19    19    19    19    19    -19    -19    -19    -19    19    19    19    19    -19    -19
@{beamset_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96


*** Test Cases ***
5GC002538_BWP_multi_UE
    [Tags]    CRT_22R2    CRT_22R3    CRT_Trunk
    [Setup]    Case Setup
    import variables    ${CURDIR}/Resources/2538_variables.py
    Modify Case SCF and Commission    PARAMS_TO_MODIFY_SCF=${MODIFY_SCF_2538_BWP}    scf_file=${_scf_file_path}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    MCS Set Beam    begin_output_port=1    end_output_port=16    vertical_angle=@{beamset_vertical}    horizontal_angle=@{beamset_horizontal}
    UE Attach For Dingli    ue_index=${0}
    UE Attach For Dingli    ue_index=${1}
    UE Send DL Traffic    ue_index=${0}    send_traffic=1500M/sec    send_duration=1800
    UE Send DL Traffic    ue_index=${1}    send_traffic=1500M/sec    send_duration=1800
    sleep    10s
    ${fst_tput}    UE Check DL Traffic    ue_index=${0}
    ${sec_tput}    UE Check DL Traffic    ue_index=${1}
    ${fbb_type}    COAM Get FBB Type
    Run keyword if    '${fbb_type}'=='ABIL'    Common Capture BIP log and download    ELSE    Capture BIP log and download on ABIO
    ${rest}    Get filter num
    ${filter_expression}    Set Variable    DlData_PdschSendReq.grants_item_${rest}.isCsirsRateMatching==0x00000001 
    ${sfn_value}    ${mcs_value}    Check Csirs result    sfn_period=4    filter_expression=${filter_expression}    
    ...    multi_ue=True    multiply=${12}    ue_num=${2}
    Check MCS degrade    input_sfn=${sfn_value}    input_mcs=${mcs_value}
    [Teardown]    Case Teardown

5GC002538_BWP_single_UE
    [Tags]    CRT_22R2    CRT_22R3    CRT_Trunk
    [Setup]    Case Setup
    import variables    ${CURDIR}/Resources/2538_variables.py
    Modify Case SCF and Commission    PARAMS_TO_MODIFY_SCF=${MODIFY_SCF_2538_BWP}    scf_file=${_scf_file_path}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    MCS Set Beam    begin_output_port=1    end_output_port=16    vertical_angle=@{beamset_vertical}    horizontal_angle=@{beamset_horizontal}
    UE Attach For Dingli    ue_index=${0}
    UE Send DL Traffic    ue_index=${0}    send_traffic=1500M/sec    send_duration=1800
    sleep    10s
    ${tput}    UE Check DL Traffic    ue_index=${0}
    ${fbb_type}    COAM Get FBB Type
    Run keyword if    '${fbb_type}'=='ABIL'    Common Capture BIP log and download    ELSE    Capture BIP log and download on ABIO
    ${rest}    Get filter num
    ${filter_expression}    Set Variable    DlData_PdschSendReq.grants_item_${rest}.isCsirsRateMatching==0x00000001
    ${sfn_value}    ${mcs_value}    Check Csirs result    sfn_period=4    filter_expression=${filter_expression}   
    ...    multi_ue=False    multiply=${12}    ue_num=${1}
    Check MCS degrade    input_sfn=${sfn_value}    input_mcs=${mcs_value}
    [Teardown]    Case Teardown

5GC002538_52RB_single_UE
    [Tags]    CRT_22R2    CRT_22R3    CRT_Trunk
    [Setup]    Case Setup
    import variables    ${CURDIR}/Resources/2538_variables.py
    Modify Case SCF and Commission    PARAMS_TO_MODIFY_SCF=${MODIFY_SCF_2538_52RB}    scf_file=${_scf_file_path}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    MCS Set Beam    begin_output_port=1    end_output_port=16    vertical_angle=@{beamset_vertical}    horizontal_angle=@{beamset_horizontal}
    UE Attach For Dingli    ue_index=${0}
    UE Send DL Traffic    ue_index=${0}    send_traffic=1500M/sec    send_duration=1800
    sleep    10s
    ${tput}    UE Check DL Traffic    ue_index=${0}
    ${fbb_type}    COAM Get FBB Type
    Run keyword if   '${fbb_type}'=='ABIL'    Common Capture BIP log and download    ELSE    Capture BIP log and download on ABIO
    ${rest}    Get filter num
    ${filter_expression}    Set Variable    DlData_PdschSendReq.grants_item_${rest}.isCsirsRateMatching==0x00000001
    ${sfn_value}    ${mcs_value}    Check Csirs result    sfn_period=4    filter_expression=${filter_expression}  
    ...    multi_ue=False    multiply=${192}/${225}    ue_num=${1}
    [Teardown]    Case Teardown

*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
	${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
	Run keyword if    'SBTS21B' in ${result}    set test variable    ${luashark_path}    ${luashark_path_21B}
    ...    ELSE IF    'SBTS22R1' in ${result}    set test variable    ${luashark_path}    ${luashark_path_22R1}
    ...    ELSE IF    'SBTS22R2' in ${result}    set test variable    ${luashark_path}    ${luashark_path_22R2}
	Run keyword if    'SBTS21B' in ${result}    set test variable    ${command_temp}    ${command_temp_21B}
    ...    ELSE IF    'SBTS22R1' in ${result}    set test variable    ${command_temp}    ${command_temp_22R1}
    ...    ELSE IF    'SBTS22R2' in ${result}    set test variable    ${command_temp}    ${command_temp_22R2}
    COAM Check GNB cell on air
    robot_common_operations.Common Suite Setup

Case Teardown
    Comment    Run Keyword And Ignore Error    Recover swconfig file
    Comment    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${_scf_file_path}
	Run Keyword And Ignore Error    Dingli Stop traffic    ue_index=${0}
	Run Keyword And Ignore Error    Dingli Stop traffic    ue_index=${1}
	Run Keyword And Ignore Error    UE Detach For Dingli    ue_index=${0}
	Run Keyword And Ignore Error    UE Detach For Dingli    ue_index=${1}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    COAM Teardown gnb connections
    robot_common_operations.Common Suite Teardown


Modify Element Value
    [Arguments]    ${input_scf}    ${parameter_list}    ${output_scf}
    scf.load scf    ${input_scf}
    FOR    ${item}    IN    @{parameter_list}
        scf.modify_scf_element    dist_name=${item}[dist_name]    list_name=${item}[list_name]    value=${item}[value]
    END
    scf.save scf    ${output_scf}

MCS Set Beam
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${vertical_angle}    ${horizontal_angle}
    MCS Setup    ip=${tl.mcses.ip_addr}    vendor=hbte
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
	    ${index}    evaluate    ${num}-1
        MCS Set Phases According to Angles    vertical_angle=${${vertical_angle}[${index}]}
    ...    horizontal_angle=${${horizontal_angle}[${index}]}    vertical_distance=${2.1}    horizontal_distance=${0.5}    output_group_id=${num}
    END
    MCS Teardown

Check throughput reduce
    [Arguments]    ${origin_value}
	${new_dl_tput}    UE Check DL Traffic
	should be true    ${origin_value}*${0.6}>${new_dl_tput}

Check throughput recover
    [Arguments]    ${origin_value}
	${new_dl_tput}    UE Check DL Traffic
	should be true    ${new_dl_tput}>${origin_value}*${0.6}

UE Attach For Dingli
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_NSA
    ${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
	${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    [Teardown]
	
UE Send DL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=1500M/sec    ${send_duration}=180   ${ue_mode}=NSA
	${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    
	...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}

UE Check DL Traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=dl
    ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
    [return]    ${tput}

Dingli Stop traffic
	[Arguments]    ${ue_index}=${0}    ${direction}=dl    ${ue_mode}=NSA    ${apn_address}=wap1.nokia.com
	${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}    
	...    ue_index=${ue_index}    apn_address=${apn_address}

UE Detach For Dingli
    [Arguments]    ${ue_index}=${0}
	${ue_type}    Get UE type    ue_index=${ue_index}
	power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
