# *** Settings ***
# Force Tags    PY36
# 
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          ./Resources/common_keyword.robot
# Variables         ./Resources/5G000316_modify_para.py
# Library           ./Resources/5G000316_common_keywords.py
# Library           BuiltIn
# Library           taf.collectors.btslog    WITH NAME   btslog
# Library           taf.collectors.core   WITH NAME   core
# Library           taf.transport.ssh    WITH NAME    ssh
# Library           ute_syslog
# 
# *** Variables ***
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${Test_Case_Name}         5GC000316_02
# ${list}                   51000
# 
# 
# *** Test Cases ***
# [1]CB005750-5G-EAAH_5GC000316_02_Synchronization_Mode_ReferenceSource_Switching
#     [Documentation]    Synchronization Mode ReferenceSource Switching
#     [Tags]    CRT_TRUNK    CRT_22R4   CRT_22R2
#     [Setup]   Setup Commission SCF
#     Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
#     Run Keyword And Continue On Failure      Start btslog on ute and Check btslog for 316    time=2min   ppb_value=20  ns_value_scope=500
#     Modify TOP Domain Number
#     Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
#     ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500
#     Modify Common parameter via Coam   input_list=${PARAMS_TO_MODIFY_DomainNumber1}
#     sleep   3min
#     Check Information On WebUI And Check Btslog    except_topp_list=${step3_except_topp_list}
#     ...    except_other_list=${step3_except_other_list}    except_value=True    ns_value_scope=500
#     Modify TOP Domain Number
#     Run Keyword And Continue On Failure     Start btslog on ute and Check btslog for 316    time=2min   ppb_value=20  ns_value_scope=1500
#     ...     btslog_name=btslog3.log
#     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${step3_except_topp_list}
#     ...   except_other_list=${step3_except_other_list}
#     Modify Common parameter via Coam   input_list=${PARAMS_TO_MODIFY_DomainNumber2}
#     sleep   3min
#     Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
#     ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500
#     [Teardown]    Clear Log And Dir
# 
# *** Keywords ***
# Teardown gNB cOAM SSL Connection
#     [Arguments]    ${connection}=GNB_OAM
#     coam.teardown    connection=GNB_OAM
# 
# Modify parameters Set syncInputType And btsSyncMode
#     [Arguments]  ${param_to_modify}    ${expected_error}
#     [Documentation]    *****************
#     ...    The purpose of this test is to verify the ability to clock sync
#     ...    gNB-DU configuration set TOPF and PhaseSync.
#     ...    ******************
#     ...    *******************
#     ${relation_errors}     Modify parameters online And Get Relation Error    PARAMS_TO_MODIFY=${param_to_modify}
#     ${key_List}    get dictionary keys    ${relation_errors}
#     ${expect_error_key_list}    get dictionary keys    ${expected_error}
#     FOR    ${keys}    IN    @{key_List}
#          ${status}    run keyword and return status    list should contain value    ${expect_error_key_list}    ${keys}
#          Run keyword if   ${status}   Check Error infor    relation_errors=${relation_errors}    expected_error=${expected_error}    keys=${keys}
#     END
# 
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${gNB_ip}
#     Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
#     FOR    ${item}  IN    @{input_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#          sleep  2min
#     END
#     [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}
# 
# Get Content From Input Dict
#     [Arguments]  ${input_dict}
#     ${dist_name}    get from dictionary     ${input_dict}    dist_name
#     ${parammeter}    get from dictionary    ${input_dict}    parameter
#     ${new_value}     get from dictionary    ${input_dict}    value
#     ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#     [Return]  ${value_list}
# 
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
#     selenium_coam.logout
# 
# 
# Teardown Case
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     COAM Commission with scf file    scf_file_path=${bkp_scf_file}
#     COAM Teardown gnb connections
# 
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
# Modify TOP Domain Number
#     [Arguments]    ${alias}=cOAM_toor4nsn
#     ${connection}    Connect to cOAM as toor4nsn    ip_address=${gNB_ip}     alias=${alias}
#     ssh.Send Command    command=iptables -I INPUT -s 10.57.249.62 -j DROP    connection=${connection}
#     ssh.Send Command    command=iptables -D INPUT -s 10.57.249.62 -j DROP    connection=${connection}
#     ssh.disconnect    connection=${alias}
# 
# COAM Check TOP Synchronization source info
#     [Arguments]                     ${bts_addr}    ${except_topp_list}    ${except_other_list}
#     Connect to gnb coam via ssl     bts_host=${bts_addr}    username=${gNB_username}    password=${gNB_password}    connection=coam_admin
#     log to console                  bts_host:${bts_addr}
#     ${bts_sync_status}=             coam.get_bts_sync_source_status          connection=coam_admin
#     log to console                  bts_sync_source_dict=${bts_sync_status}
#     ${bts_syncMode}=                Get From Dictionary                  ${bts_sync_status}         syncMode
#     should be equal                 ${bts_syncMode}                      PhaseSync
#     ${tuning_Mode}=                 Get From Dictionary                  ${bts_sync_status}         tuningMode
#     should be equal                 ${tuning_Mode}                       Normal tuning
#     ${syncSourceInfo}=              Get From Dictionary                  ${bts_sync_status}         syncSourceInfo
#     ${syncSourceInfo_list}    check_syncSourceInfo_if_right    ${syncSourceInfo}
#     log    ${syncSourceInfo_list}
#     should be equal    ${except_topp_list}    @{syncSourceInfo_list}[0]
#     should be equal    ${except_other_list}    @{syncSourceInfo_list}[1]
#     [Teardown]        coam.teardown      connection=coam_admin
# 
# Connect to cOAM as toor4nsn
#     [Arguments]  ${ip_address}   ${alias}
#     ${connection}=  ssh.Connect to  hostname=${ip_address}
#     ...                             username=toor4nsn
#     ...                             password=oZPS0POrRieRtu
#     ...                             alias=${alias}
#     [Return]  ${connection}
# 
# 
# Get Active Alarm number
#     [Arguments]    ${keywords}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     ${alarm_list}    coam.get_active_alarms     connection=GNB_OAM
#     ${fault_id_list}  get_active_alarms_faultId    alarms_list=${alarm_list}    keyword=${keywords}
#     Teardown gNB cOAM SSL Connection
#     [Return]  ${fault_id_list}
# 
# Modify parameters online and Active Plan
#     [Arguments]    ${PARAMS_TO_MODIFY}
#     selenium_coam.enable_virtual_display
#     Du login page via webUI
#     FOR    ${item}    IN    @{PARAMS_TO_MODIFY}
#          ${dist_name}       get from dictionary     ${item}     dist_name
#          ${filter_param}    get from dictionary     ${item}     filter_param
#          ${new_value}       get from dictionary     ${item}     value
#          selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}
#     END
#     selenium_coam.validate_plan
#     Sleep  5s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     Sleep  10min
# 
# Check Information On WebUI And Check Btslog
#     [Arguments]    ${except_topp_list}    ${except_other_list}   ${except_value}  ${ns_value_scope}
#     Wait until keyword succeeds   15min   1min     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}
#     ...    except_topp_list=${except_topp_list}    except_other_list=${except_other_list}
#     ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
#     ${return_value}    check_active_alarms_faultId     faultId_list=${FaultID_list}    faultId=4298
#     should be equal as strings    ${return_value}    ${except_value}
#     Start btslog on ute and Check btslog for 316    time=2min   ppb_value=20   ns_value_scope=${ns_value_scope}     btslog_name=btslog2.log
# 
# Check Relation Errors When Right Config
#     [Arguments]    ${relation_errors}    ${excpect_list}
#     ${relation_errors_key_list}   Get Dictionary Keys    ${relation_errors}
#     ${except_value}    check_relation_error    input_list=${relation_errors_key_list}    excpect_list=${excpect_list}
#     should be equal as strings    ${except_value}   True
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
