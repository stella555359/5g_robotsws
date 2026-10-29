# *** Settings ***
# Force Tags    PY36
# 
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Zhouqun Wang
# ...              contact: zhouqun.wang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Variables         ./Resources/5G000320_modify_para.py
# Library           ./Resources/5G000320_common_keywords.py
# Library           BuiltIn
# Library           ute_syslog
# Library           taf.collectors.btslog    WITH NAME   btslog
# Library           taf.collectors.core   WITH NAME   core
# Library           taf.transport.ssh    WITH NAME    ssh
# Resource          ../CB005750_EA/Resources/common_keyword.robot
# Library           ../CB005750_EA/Resources/5G000313_common_keywords.py
# 
# *** Variables ***
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# 
# 
# *** Test Cases ***
# [1]CB005750-5G-EAAL_5GC000320_03_Phase_Synchronization_Holdover_Performance_No_Sufficient_TuningHistory
#     [Documentation]    Phase_Synchronization_Holdover_Performance_No_Sufficient_TuningHistory
#     [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
#     [Setup]    common_keyword.Setup Commission SCF
#     Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
#     Start btslog on ute and Check btslog    time=2min   ppb_value=20  ns_value_scope=500
#     Modify TOP Domain Number
#     Check Information On WebUI And Check Btslog    expect_topp_list=${step2_expect_topp_list}
#     ...    expect_other_list=${step2_expect_other_list}    expect_value=False    ns_value_scope=500
#     Modify Common parameter via Coam   input_list=${PARAMS_TO_MODIFY_DomainNumber1}
#     Check Information On WebUI And Check Btslog    expect_topp_list=${step3_expect_topp_list}
#     ...    expect_other_list=${step3_expect_other_list}    expect_value=True    ns_value_scope=500
#     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    expect_topp_list=${step3_expect_topp_list}
#     ...   expect_other_list=${step3_expect_other_list}
#     Modify Common parameter via Coam   input_list=${PARAMS_TO_MODIFY_DomainNumber2}
#     Check Information On WebUI And Check Btslog    expect_topp_list=${step2_expect_topp_list}
#     ...    expect_other_list=${step2_expect_other_list}    expect_value=False    ns_value_scope=500
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Check Error infor
#     [Arguments]    ${relation_errors}    ${expected_error}    ${keys}
#     ${error}    get from dictionary    ${relation_errors}    ${keys}
#     ${true_error}    get from dictionary    ${expected_error}    ${keys}
#     Should Be Equal As Strings    ${error}     ${true_error}    msg=the error info is not correct
# 
# Setup Ready
#     Du login page via webUI
#     ${bkp_scf_file}    selenium_coam.Save Bts Configuration
#     set suite variable    ${bkp_scf_file}
#     [Teardown]    Run keyword and ignore error     selenium_coam.logout
# 
# Teardown Case
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     COAM Commission with scf file    scf_file_path=${bkp_scf_file}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections
# 
# Du login page via webUI
#     [Documentation]  Author: Wu Jerry
#     ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
#     [Arguments]  ${download_dir}=/home/ute/robotws5g/testsuite/TRS/Hangzhou/5GC002236_316/backup/
#     selenium_coam.enable_virtual_display
#     selenium_coam.login    url=https://${gNB_ip}
#     ...                    username=${gNB_username}
#     ...                    password=${gNB_password}
#     ...                    download_dir=${download_dir}
#     selenium_coam.disable_message_box
# 
# Modify parameters online And Get Relation Error
#     [Arguments]    ${PARAMS_TO_MODIFY}
#     Du login page via webUI
#     log    ${PARAMS_TO_MODIFY}
#     FOR    ${item}    IN    @{PARAMS_TO_MODIFY}
#          Log    ${item}
#          ${dist_name}       get from dictionary     ${item}     dist_name
#          ${filter_param}    get from dictionary     ${item}     filter_param
#          ${new_value}       get from dictionary     ${item}     value
#          selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}
#     END
#     selenium_coam.validate_plan
#     ${relation_errors}      selenium_coam.get_relation_errors
#     [Return]     ${relation_errors}
#     [Teardown]    selenium_coam.logout
# 
# Check logfile if message is right
#     [Arguments]    ${ppb_value}   ${ns_value_scope}   ${btslog_name}=btslog.log
#     csn.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=TESTPC
#     ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${TEST NAME}/${btslog_name}    Estimator output
#     ${ns_result}    5G000320_common_keywords.check_parameter_ns_in_btslog_file    input_content=${message}
#     ...    expect_value=${ns_value_scope}    parameter=phase_error:
#     ${ppb_result}    5G000320_common_keywords.check_parameter_ns_in_btslog_file    input_content=${message}
#     ...    expect_value=${ppb_value}    parameter=frequency_deviation:
#     should be equal as strings    ${ppb_result}    True
#     should be equal as strings    ${ns_result}    True
#     [Teardown]    Csn.Disconnect	connection=TESTPC
# 
# start btslog capture on ute
#     [Arguments]    ${log_dir}=${OUTPUT_DIR}/${TEST NAME}    ${connection}=ute    ${btslog_name}=btslog.log
#     csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
#     log to console    start syslog...
#     Start Syslog    log_dir=${log_dir}      log_name=${btslog_name}
#     ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    alias=${connection}
# 
# Start btslog on ute and Check btslog
#     [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}     ${btslog_name}=btslog.log
#     start btslog capture on ute     btslog_name=${btslog_name}
#     sleep    ${time}
#     stop syslog     alias=ute
#     Check logfile if message is right    ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}   btslog_name=${btslog_name}
# 
# 
# Modify TOP Domain Number
#     [Arguments]    ${alias}=cOAM_toor4nsn
#     ${connection}    Connect to cOAM as toor4nsn    ip_address=${gNB_ip}     alias=${alias}
#     ssh.Send Command    command=iptables -I INPUT -s 10.57.249.62 -j DROP    connection=${connection}
#     sleep    2s
#     ssh.Send Command    command=iptables -D INPUT -s 10.57.249.62 -j DROP    connection=${connection}
#     sleep    1s
#     ssh.Send Command    command=iptables -D INPUT -s 10.57.249.62 -j DROP    connection=${connection}
#     ssh.disconnect      connection=${alias}
#     log to console      block top less than 5s
#     sleep    3min
# 
# COAM Check TOP Synchronization source info
#     [Arguments]                     ${bts_addr}    ${expect_topp_list}    ${expect_other_list}
#     Connect to gnb coam via ssl     bts_host=${bts_addr}     connection=coam_admin
#     log to console                  bts_host:${bts_addr}
#     ${bts_sync_status}=             coam.get_bts_sync_source_status          connection=coam_admin
#     log to console                  bts_sync_source_dict=${bts_sync_status}
#     ${bts_syncMode}=                Get From Dictionary                  ${bts_sync_status}         syncMode
#     should be equal                 ${bts_syncMode}                      PhaseSync
#     ${tuning_Mode}=                 Get From Dictionary                  ${bts_sync_status}         tuningMode
#     should be equal                 ${tuning_Mode}                       Normal tuning
#     ${syncSourceInfo}=              Get From Dictionary                  ${bts_sync_status}         syncSourceInfo
#     ${syncSourceInfo_list}    5G000320_common_keywords.check_syncSourceInfo_if_right    ${syncSourceInfo}
#     log    ${syncSourceInfo_list}
#     should be equal    ${expect_topp_list}    @{syncSourceInfo_list}[0]
#     should be equal    ${expect_other_list}    @{syncSourceInfo_list}[1]
#     [Teardown]     coam.teardown      connection=coam_admin
# 
# Connect to cOAM as toor4nsn
#     [Arguments]  ${ip_address}   ${alias}
#     ${connection}=  ssh.Connect to  hostname=${ip_address}
#     ...                             username=toor4nsn
#     ...                             password=oZPS0POrRieRtu
#     ...                             alias=${alias}
#     [Return]  ${connection}
# 
# Get Content From Input Dict
#     [Arguments]  ${input_dict}
#     ${dist_name}    get from dictionary     ${input_dict}    dist_name
#     ${parammeter}    get from dictionary    ${input_dict}    parameter
#     ${new_value}     get from dictionary    ${input_dict}    value
#     ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#     [Return]  ${value_list}
# 
# Get Active Alarm number
#     [Arguments]    ${keywords}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     ${alarm_list}    coam.get_active_alarms     connection=GNB_OAM
#     ${fault_id_list}  5G000320_common_keywords.get_active_alarms_faultId    alarms_list=${alarm_list}    keyword=${keywords}
#     COAM Teardown gnb connections
#     [Return]  ${fault_id_list}
# 
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${gNB_ip}
#     Connect to gnb coam via ssl    bts_host=${bts_ip}   connection=${connection}
#     FOR    ${item}  IN    @{input_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#          sleep  2min
#     END
#     sleep    3min
#     [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}
# 
# 
# Check Information On WebUI And Check Btslog
#     [Arguments]    ${expect_topp_list}    ${expect_other_list}   ${expect_value}  ${ns_value_scope}
#     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    expect_topp_list=${expect_topp_list}
#     ...     expect_other_list=${expect_other_list}
#     ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
#     ${return_value}    5G000320_common_keywords.check_active_alarms_faultId     faultId_list=${FaultID_list}    faultId=4298
#     should be equal as strings    ${return_value}    ${expect_value}
#     Start btslog on ute and Check btslog    time=2min   ppb_value=20   ns_value_scope=${ns_value_scope}
# 
# 
# Clear Log And Dir
#     [Arguments]   ${root_path}=${output_dir}
#     ${del_path}    Get_File_And_Dir    root_path=${root_path}
#     csn.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=connection_ute
#     FOR   ${item}  IN  @{del_path}
#          csn.Execute   command=rm -rf ${item}   connection=connection_ute
#     END
#     csn.Execute   command=rm -rf ${root_path}/*.txt    connection=connection_ute
#     csn.Execute   command=rm -rf ${root_path}/*.pcap    connection=connection_ute
#     CI_interface.Common Case Teardown
#     [Teardown]    Run keyword and ignore error   csn.Disconnect    connection=connection_ute
