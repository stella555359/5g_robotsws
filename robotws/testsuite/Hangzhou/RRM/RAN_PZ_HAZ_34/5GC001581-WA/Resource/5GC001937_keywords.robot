*** Settings ***
Documentation
...    author: shenrao
...    contact: shengrong.rao@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC001937_OTA program

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***

#ssh CU (oam VM)
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}             # oam ip
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}         # robot
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}         # rastre1
${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../commissionings/HGZ/${testline_name}/5GC001937
${gnb_index}    0
${SCF_Template_path_CU}    ${CURDIR}/../../../../commissionings/HGZ/${testline_name}/5GC001937/CU_0.400_SCF.xml
${TestCase_Log_Path}    /home/ute/
${ue_type}    ${tl.ues[0].capabilities[1]}

*** Keywords ***
Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}
CU Commission	
	CU Rest Login    gnb_index=${gnb_index}
	CU Full Commission    path_of_commission_file=${SCF_Template_path_CU}    plan_name=CU_SCF    gnb_index=${gnb_index}	


Scf commission and wait for on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    #Conect to CU by ssh and reset cu
    CU Commission
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${SCF_TEMPLATE_PATH}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair
    Get cell numbers

Get cell numbers
    Conect to DU COAM
    ${bts_info}   coam.get_bts_info   connection=COAM   timeout=10
    ${cell_list}   Run Keyword If   ${bts_info.has_key('requestMessage')}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}   
    ${cell_numbers}    get length    ${cell_list}
    ${sample_times}=    Evaluate    ${cell_numbers}*10
    Log To Console    current env cell number is ${cell_numbers}
    Log To Console    current env sample times is ${sample_times}
    set suite variable       ${cell_numbers}
    set suite variable       ${sample_times}

COAM Check GNB_DU cell on air
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    Conect to DU COAM
    COAM Check All Cells Onair
    [Teardown]   admin_cli.teardown    connection=${connection}

CaseTeardown
    [Arguments]       ${connection}=COAM
    Log To Console    \n *** Case teardown
    Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
    Run Keyword And Ignore Error    Stop BIP Capture On ASOD
	Run Keyword And Ignore Error    CI_interface.Common Case Teardown
   
Get ul and dl peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False} 
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

pdml check
    [Arguments]    ${log_path}=/home/ute/shushu/asod_bip_2020_0716_0801_21.pcap0    ${sample}=1
    ${ave_value_list}    Create List
    ${length}=    get length     ${log_path}
    FOR    ${i}    IN RANGE    0    ${length}    ${sample}
        ${status}    ${ave_value}=    Run Keyword And Ignore Error
        ...    Get ul dl mcs beamid bler value from output pdml files    file_path=${log_path[${i}]}
        run keyword if    '${status}'=='PASS' and '${ave_value}'!='${EMPTY}'    Append To List    ${ave_value_list}    ${ave_value}
    END
    [Teardown]    Run Keyword And Ignore Error    Remove big log files    filename=${log_path}
    [Return]    ${ave_value_list}

Case Preparation to Cell on air
    [Arguments]   ${SCF_TEMPLATE_PATH_DU}        ${SCF_TEMPLATE_PATH_CU}    ${act_xcc_cell_number}
    ...       ${is_pdl_checking_needed}=${False}
    COAM Create log directory
    Cloud DU connect to gnb coam via ssl
    &{pre_env_xcc_config}    get_relation_mapping_between_cell_index_and_other_ids
    ${pre_env_xcc_config}    get length    ${pre_env_xcc_config}
	${cell_status}=   run_keyword_and_return_status    Verify all cells should be onair    connection=GNB_OAM   	
    run keyword if    ${act_xcc_cell_number}!=${pre_env_xcc_config} or ${cell_status}!= ${True}
    ...    COAM Commission with scf file    scf_file_path=${SCF_TEMPLATE_PATH_DU}/DU_${act_xcc_cell_number}CC_AEWD_0.400.xml   
	...    is_pdl_checking_needed=${False}
    run keyword if    ${act_xcc_cell_number}!=${pre_env_xcc_config} or ${cell_status}!= ${True}
    ...    CU Full Commission    path_of_commission_file=${SCF_TEMPLATE_PATH_CU}   plan_name=CU_SCF    gnb_index=${gnb_index}
	sleep    60s
	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections	