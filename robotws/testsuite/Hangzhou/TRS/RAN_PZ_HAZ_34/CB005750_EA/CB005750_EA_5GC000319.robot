# *** Settings ***
# Force Tags    PY36
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          ./Resources/common_keyword.robot
# Variables         ./Resources/5G000316_modify_para.py
# Library           ./Resources/5G000316_common_keywords.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${LOG_PATH}               ${output_dir}
# ${gnb_id}                 ${tl.gnbs[0].global_bts_id}
# 
# 
# *** Test Cases ***
# [1]CB005750-5G-EAAK_5GC000319_008_Selection_of_Sync_Hub_as_sync_input_with_phase
#     [Documentation]  Selection of Sync Hub as sync input with phase
#     [Tags]  CRT_TRUNK     CRT_22R3   CRT_22R2
#     [Setup]    Setup Commission SCF
#     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${step2_except_topp_list}
#     ...   except_other_list=${step2_except_other_list}
#     ${fault_id_list}    Get Active Alarm number    keywords=additionalFaultID
#     Modify Structure parameter via Coam   class_name=CLOCK_A   modify_list=${case319_modify_sync1}
#     ...    keywords_list=${modify_keywords_list1}    index=${index_list}
#     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${step4_except_topp_list}
#     ...   except_other_list=${step4_except_other_list}
#     Check Alarm List Not Change    input_alarm_list=${fault_id_list}
#     Modify Structure parameter via Coam   class_name=CLOCK_A   modify_list=${case319_modify_sync2}
#     ...    keywords_list=${modify_keywords_list1}    index=${index_list}
#     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${step2_except_topp_list}
#     ...   except_other_list=${step2_except_other_list}
#     Check Alarm List Not Change    input_alarm_list=${fault_id_list}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# COAM Check TOP Synchronization source info
#     [Arguments]                     ${bts_addr}    ${except_topp_list}    ${except_other_list}    ${connection}=coam_admin
#     Connect to gnb coam via ssl     bts_host=${bts_addr}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
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
# Modify Structure parameter via Coam
#     [Arguments]   ${class_name}   ${modify_list}    ${keywords_list}    ${index}   ${connection}=GNB_CON
#     Connect to gnb coam via ssl     bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
#     ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
#     ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}    modify_list=${modify_list}
#     ...    keywords_list=${keywords_list}    index=${index}
#     FOR    ${item}  IN  @{output_dict_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#          sleep  2min
#     END
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
# 
# Check Alarm List Not Change
#     [Arguments]  ${input_alarm_list}
#     ${fault_id_list}    Get Active Alarm number    keywords=additionalFaultID
#     ${return_value}    Judge_List_Is_Change    input_list1=${input_alarm_list}  input_list2=${fault_id_list}
#     should be equal as strings    ${return_value}    ${True}
# 
