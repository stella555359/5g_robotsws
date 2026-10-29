# *** Settings ***
# 
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Variables         ./Resources/5GC002056_AGBX_modify.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Library           Resources/common_keyword.py
# 
# Suite Setup       run keywords    CI_interface.Common Suite Setup    AND    robot_common_operations.Common Suite Setup
# Test Teardown     run keywords    CI_interface.Common Case Teardown    
# ...     AND    robot_common_operations.Common Suite Teardown
# 
# Force Tags              5G_RAN_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB   SBTS00   5G_RAN
# ...    PY36
# ...    RAN_5G_TDD    RAN_5G
# 
# *** Variables ***
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
# ${parameter1}    actUlOpenLoopPwrCtrl
# ${connection}    GNB_connection
# ${target}       ${CURDIR}/Log/CELL_INFO.txt
# 
# *** Test Cases ***
# [1]5GC002056-AGBX_5GC001983_001_Online_Modification_ulMimoMode_cmW_COAM
#     [Documentation]    Online Modification ulMimoMode cmW COAM
#     [Tags]        CRT_22R2     CRT_TRUNK
#     Modify Common parameter via Coam    input_list=${Modify_011case_step5_3}
#     Check cell on air
#     [Teardown]
# #
# #[1]5GC002056-AGBX_5GC001983_002_Online_Modification_p0NominalSrs_cmW_COAM
# #    [Documentation]    Online Modification p0NominalSrs cmW_COAM
# #    [Tags]     CRT_21A
# #    Modify Value On DU     structure_modify_list=${Modify_011case_step5_4}    class_name=NRCELL_A    keywords_list=${keywords_list1}
# #    Check cell on air
# #    [Teardown]    Recovery modify parammeter    Modify_011case_step5_1=${Modify_011case_step5_5}    keywords_list1=${keywords_list1}
# #
# #[1]5GC002056-AGBX_5GC001983_004_Online_Modification_actUlOpenLoopPwrCtrl_cmW_COAM
# #    [Documentation]    Online Modification actUlOpenLoopPwrCtrl cmW COAM
# #    [Tags]      CRT_21A
# #    Modify Value On DU     structure_modify_list=${Modify_011case_step5_2}    class_name=NRCELL_A    keywords_list=${keywords_list1}
# #    Check cell on air
# #    [Teardown]    Recovery modify parammeter    Modify_011case_step5_1=${Modify_011case_step5_1}    keywords_list1=${keywords_list1}
# 
# *** Keywords ***
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${connection}=GNB_connection    ${gNB_ip}=${DU_OAM_IP_TL}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}   connection=${connection}
#     FOR    ${item}   IN    @{input_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     END
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
# 
# Modify Structure parameter via Coam
#     [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
#     ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
#     ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
#     ...    keywords_list=${keywords_list}
#     FOR    ${item}  IN  @{output_dict_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#          sleep  2min
#     END
# 
# Get Content From Input Dict
#     [Arguments]  ${input_dict}
#     ${dist_name}    get from dictionary     ${input_dict}    dist_name
#     ${parammeter}    get from dictionary    ${input_dict}    parameter
#     ${new_value}     get from dictionary    ${input_dict}    value
#     ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#     [Return]  ${value_list}
# 
# Check cell on air
#     [Arguments]   ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${DU_OAM_IP_TL}
#     ${INFO}    coam.get_bts_statuses    connection=${connection}
#     ${proceduralState}    get from dictionary    ${INFO}    proceduralState
#     log to console    ${proceduralState}
#     Should be equal as strings    ${proceduralState}    OnAir
#     [Teardown]    COAM Teardown gnb connections
# 
# Modify Value On DU
#     [Arguments]    ${structure_modify_list}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
#     ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0    ${gNB_ip}=${DU_OAM_IP_TL}
#     coam.connect_to    bts_host=${gNB_ip}   name=${connection}
#     run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
#     ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
# 
# Recovery modify parammeter
#     [Arguments]  ${Modify_011case_step5_1}    ${keywords_list1}
#     Modify Value On DU     structure_modify_list=${Modify_011case_step5_1}    class_name=NRCELL_A    keywords_list=${keywords_list1}
#     Check cell on air
# 
