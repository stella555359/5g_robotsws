*** Settings ***
Documentation    This is common keywords for BW related cases
...              Please do not modify the file without notification to author
...              Author: cai lanwen
...              Contact: lanwen.cai@nokia-sbell.com

Resource    lib/BW_step_keywords.robot
Resource   ../CI_Operations/CI_interface.robot
Variables   variable/BW_variable.py
Library     lib/tti_log_analysis.py

*** Variables ***
${if_commissioning}   True
${if_pdl_check}       True

${testline_name}      null
${CONFIGURATION}      null
@{timezone_list}      (GMT+8) Asia/Shanghai    (GMT+0) Europe/London
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog      none

# RU log
${ru_runtime_zip}     1011_runtime.zip
${ru_runtime_xz}      runtime_DEFAULT.log.xz
${ru_runtime_log}     runtime_DEFAULT.log
${TS_LOG_PATH_BASE}   ${OUTPUT DIR}

#gNB info
${bts_id_tl}          ${tl.gnbs[0].instance_id}
${asik_addr}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}      #toor4nsn
${asik_password}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}      #oZPS0POrRieRtu

${ru_addr}            ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${ru_username}        ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${ru_password}        ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${ru_type_init}       ${tl.gnbs[0].dus[0].rus[0].radio_type.value}  # the 1st RU by default if mulitiple RUs used

${ASIK}                 ASIK Master
${ABIL_MASTER_ALIAS}    ABIL Master
${ABIL_SLAVE_ALIAS}     ABIL Slave
${tti_log_path_testpc}    ${TS_LOG_PATH_BASE}
${srs_log_path_testpc}    ${TS_LOG_PATH_BASE}

#bts id
${MRBTS_ID}           ${tl.gnbs[0].instance_id}
${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}

# HangZhou artifactory
${arti}=    https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/

#jianhua
${att_port_0}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2]}
${att_port_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3]}

*** Keywords ***
Get Ue Network Type
    ${testline_name}    Get Testline Name
    ${ue_network_type}    get_ue_network_type_from_ue_mapping_file    testline_name=${testline_name}
    Should contain    ${ue_network_type} 	SA
    Set Suite Variable    ${ue_network_type}

Get Feature ID
    ${result}    split string    ${TEST_NAME}    _
    ${feature}    String.Get Substring    ${result[0]}    -4
    Set Suite Variable    ${feature}

BW common Suite Setup
    [Arguments]    ${MIMO}=22
    log to console    \n***BW common Suite Setup***
    run keyword if    '${testline_name}' == 'null'
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ELSE         Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    set suite variable      ${MIMO}
    Log to console    \n***Commissioning SCF***
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Get Ue Network Type
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}   timeout=15min
    Log to console    \n***Check cell onair***
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${ue_network_type}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    ${PA_original_value}    Get HBTE Attenuation value
    run keyword if    '${MIMO}' == '22'   Set HBTE Attenuation port12 to max

BW Coam Suite Teardown
    log to console    \n***BW Coam Suite Teardown***
    run keyword if    '${MIMO}' == '22'    recover HBTE Attenuation value
    ...    PA_original_value=${PA_original_value}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

BW common test setup
    log to console    \n***BW common test setup***
    Generate test case log path
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_info}    COAM get all ru detail info
    &{ru_info}    Set variable    ${ru_info['1']}
    run keyword and ignore error  should contain  ${TEST_NAME}  ${ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

BW Coam Test Teardown
    log to console    \n***BW Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

UL_and_DL_LA_data_traffic_QAM256_2x2MIMO
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_256}
    ...           tput=${NSA_QAM256_2X2_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           connection=GNB_OAM

UL_and_DL_LA_data_traffic_QAM64_2x2MIMO
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_64}
    ...           tput=${NSA_QAM64_2X2_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           connection=GNB_OAM

UL_and_DL_LA_Peak_QAM256_2x2MIMO
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_256}
    ...           tput=${NSA_QAM256_2X2_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           connection=GNB_OAM

UL_and_DL_LA_data_traffic_QAM64_2x2MIMO_SA
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_64}
    ...           tput=${SA_QAM64_2X2_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           gnb_type=SA
    ...           connection=GNB_OAM

UL_and_DL_LA_data_traffic_QAM256_2x2MIMO_SA
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_64}
    ...           tput=${SA_QAM256_2X2_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           gnb_type=SA
    ...           connection=GNB_OAM

DL_LA_data_traffic_TCP_QAM256_4x4MIMO
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_256}
    ...           tput=${NSA_QAM256_4X4_TPUT_TCP}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           protocol=tcp
    ...           connection=GNB_OAM

UL_and_DL_LA_Peak_QAM256_4x4MIMO
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_256}
    ...           tput=${NSA_QAM256_4X4_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           connection=GNB_OAM

UL_and_DL_LA_data_traffic_QAM256_4x4MIMO_SA
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_256}
    ...           tput=${SA_QAM256_4X4_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           gnb_type=SA
    ...           connection=GNB_OAM

UL_and_DL_LA_Peak_QAM256_4x4MIMO_SA
    UL_and_DL_LA_data_traffic
    ...           modify_scf_paratmer=${modify_scf_paratmer_256}
    ...           tput=${SA_QAM256_4X4_TPUT}
    ...           target_avg_percent=${TPUT_PERCENTAGE['target_avg_percent']}
    ...           min_percent=${TPUT_PERCENTAGE['min_percent']}
    ...           gnb_type=SA
    ...           connection=GNB_OAM
