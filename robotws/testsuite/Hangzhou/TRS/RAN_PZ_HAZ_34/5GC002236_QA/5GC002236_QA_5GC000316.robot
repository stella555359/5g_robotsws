# *** Settings ***
# Force Tags    PY36
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
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
# ${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${Test_Case_Name}         5GC000316_02
# ${list}         51000
# 
# 
# *** Test Cases ***
# [1]5GC002236_5GC000316_01_Synchronization_Mode_Configuration
#     [Documentation]    Synchronization Mode Configuration
#     [Tags]    CRT_21B    CRT_22R2
#     [Setup]  Setup Commission SCF
#     Modify parameters Set syncInputType And btsSyncMode    param_to_modify=${PARAMS_TO_MODIFY_TOPF_PhaseSync}    expected_error=${TOPF_PhaseSync}
#     Modify parameters Set syncInputType And btsSyncMode    param_to_modify=${PARAMS_TO_MODIFY_TOPF_FreqSync}      expected_error=${TOPF_FreqSync}
#     ${relation_errors}     Modify parameters online And Get Relation Error    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_TOPP_PhaseSync}
#     Check Relation Errors When Right Config    relation_errors=${relation_errors}     excpect_list=${excpect_list}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]5GC002236_5GC000316_02_Synchronization_Mode_ReferenceSource_Switching
#     [Documentation]    Synchronization Mode ReferenceSource Switching
#     [Tags]     CRT_21B    CRT_22R2
#     [Setup]   Setup Commission SCF
#     Run Keyword And Continue On Failure    Start btslog on ute and Check btslog for 316    time=2min   ppb_value=20  ns_value_scope=500
#     Modify TOP Domain Number
#     Run Keyword And Continue On Failure    Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
#     ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500       btslog_name=bts_log11.log
#     Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}
#     sleep   3min
#     Run Keyword And Continue On Failure    Check Information On WebUI And Check Btslog    except_topp_list=${step3_except_topp_list}
#     ...    except_other_list=${step3_except_other_list}    except_value=True    ns_value_scope=500      btslog_name=bts_log12.log
#     Modify TOP Domain Number
#     Run Keyword And Continue On Failure    Start btslog on ute and Check btslog for 316    time=2min   ppb_value=20  ns_value_scope=500
#     Run Keyword And Continue On Failure    COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}
#     ...   except_other_list=${step3_except_other_list}    except_topp_list=${step3_except_topp_list}
#     Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}
#     sleep   3min
#     Run Keyword And Continue On Failure    Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
#     ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500      btslog_name=bts_log13.log
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Check cell on air
#     coam.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
#     ${status}       coam.get_bts_statuses          connection=GNB_OAM
#     ${BTS_Status}     Get From Dictionary    ${status}     proceduralState
#     should be equal    ${BTS_Status}     OnAir
#     [Teardown]     coam.Teardown  connection=GNB_OAM
# 
# Teardown gNB cOAM SSL Connection
#     [Arguments]    ${connection}=GNB_OAM
#     coam.teardown    connection=GNB_OAM
# 
# Setup Commission SCF
#      ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
#      Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#      COAM Commission with scf file    scf_file_path=${default_scf}
#      Wait Until Keyword Succeeds   16min   2min   Check cell on air
# 
# Get BTS Version And Perare SCF
#     [Arguments]    ${CURDIR_path}
#     ${connection}    coam.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${scf_name}    5G000316_common_keywords.Covert_BTS_Version    version=${version}
#     ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
#     log to console   ${default_scf}
#     [Return]    ${default_scf}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
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
#          run keyword and continue on failure    Run keyword if   ${status}  Check Error infor    relation_errors=${relation_errors}
#          ...     expected_error=${expected_error}    keys=${keys}
#     END
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
# BTSLOG Start btslog on local machine
#     [Arguments]   ${name}=btslog
#     ...           ${bts_logs_dir}=/tmp/btslog2
#     __Make empty BTS logs dir      ${bts_logs_dir}
#     btslog.create_btslog_collector
#     ...    name=${name}
#     ...    log_dir=${bts_logs_dir}
#     core.setup_collectors        names=${name}
#     core.start_collectors        names=${name}
#     btslog.set_suite_alias       ${name}
# 
# BTSLOG Collect btslog
#     [Arguments]  ${bts_logs_dir}=/tmp/btslog2
#     __Stop and collect btslog on local machine
#     __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}
# 
# __Stop and collect btslog on local machine
#     [Arguments]   ${name}=btslog
#     core.stop_collectors         names=${name}
#     core.collect_collectors      names=${name}
#     core.teardown_collectors     names=${name}
# 
# __Make empty BTS logs dir
#     [Arguments]     ${bts_logs_dir}=/tmp/btslog2
#     Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi
# 
# __Copy btslog to logs dir and clean BTSlog workspace
#     [Arguments]     ${bts_logs_dir}=/tmp/btslog2
# 	Run  mkdir ${OUTPUT_DIR}/${TEST_NAME}
# 	Run  mkdir ${OUTPUT_DIR}/${Test_Case_Name}
#     Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz
#     Run  rm ${bts_logs_dir}/*
# 
# Check logfile if message is right
#     [Arguments]    ${ppb_value}   ${ns_value_scope}    ${btslog_name}
#     csn.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=TESTPC
#     ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${btslog_name}    Estimator output
#     ${ppb_result}   check_parameter_value_in_btslog_file    input_content=${message}   keyword=frequency_deviation    except_value=${ppb_value}
#     ${ns_result}    check_parameter_value_in_btslog_file    input_content=${message}   keyword=phase_error    except_value=${ns_value_scope}
#     should be equal as strings    ${ppb_result}    True
#     should be equal as strings    ${ns_result}    True
#     [Teardown]    Csn.Disconnect	connection=TESTPC
# 
# Start btslog on ute and Check btslog
#     [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}    ${btslog_name}
#     Start Syslog    log_dir=${OUTPUT_DIR}
#     ...    log_name=${btslog_name}   host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}
#     ...    ports=${list}    alias=ute
#     sleep    ${time}
#     Stop syslog    alias=ute
#     Check logfile if message is right    ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}    btslog_name=${btslog_name}
# 
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
#     coam.connect_to                 bts_host=${bts_addr}    name=coam_admin
#     log to console                  bts_host:${bts_addr}
#     ${bts_sync_status}=             coam.get_bts_sync_source_status          connection=coam_admin
#     log to console                  bts_sync_source_dict=${bts_sync_status}
#     ${bts_syncMode}=                Get From Dictionary                  ${bts_sync_status}         syncMode
#     should be equal                 ${bts_syncMode}                      PhaseSync
#     ${tuning_Mode}=                 Get From Dictionary                  ${bts_sync_status}         tuningMode
#     should be equal                 ${tuning_Mode}                       Normal tuning
#     ${syncSourceInfo}=              Get From Dictionary                  ${bts_sync_status}         syncSourceInfo
#     ${syncSourceInfo_list}    5G000316_common_keywords.check_syncSourceInfo_if_right    ${syncSourceInfo}
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
#     ${fault_id_list}      5G000316_common_keywords.get_active_alarms_faultId    alarms_list=${alarm_list}    keyword=${keywords}
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
# 
# Check Information On WebUI And Check Btslog
#     [Arguments]    ${except_topp_list}    ${except_other_list}   ${except_value}  ${ns_value_scope}     ${btslog_name}
#     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
#     ...     except_other_list=${except_other_list}
#     ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
#     ${return_value}    5G000316_common_keywords.check_active_alarms_faultId     faultId_list=${FaultID_list}    faultId=4298
#     should be equal as strings    ${return_value}    ${except_value}
#     Start btslog on ute and Check btslog for 316    time=2min   ppb_value=20   ns_value_scope=${ns_value_scope}     btslog_name=${btslog_name}
# 
# Check Relation Errors When Right Config
#     [Arguments]    ${relation_errors}    ${excpect_list}
#     ${relation_errors_key_list}   Get Dictionary Keys    ${relation_errors}
#     ${except_value}    check_relation_error    input_list=${relation_errors_key_list}    excpect_list=${excpect_list}
#     should be equal as strings    ${except_value}   True