# *** Settings ***
# Documentation    author:Liu Tiffany
# ...              contact: n5liu@nokia-sbell.com
# ...                History: Do some adaption for CB006443 by LiuNing
# ...                History: Do some adaption for CB008181 by LiuNing
# ...               feature : CB008181
# Suite Setup    	robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# Force Tags        
#    
# Library     OperatingSystem
# Library     Collections
# Library     String
# Library     BuiltIn
# Library     DateTime
# Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/common/siso_resource.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# ###CI_interface.robot is defined ,${commissionings_path} and ${testline_name} can be used#####
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# 
# *** Variables ***
# ##GNB##
# ${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBEM_User}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_Password}           ${tl.gnbs[0].cu.oam_http_connection_details.password} 
# ##SCF##
# @{SCF_IWK}                      SCF_IWK_Trunk.xml
# ${SCF_IWK_Trunk}        ${commissionings_path}/HGZ/${testline_name}/SCF_IWK/
# 
# 
# 
# *** Test Cases ***
# [1]TC.Full_Commission_With_IWK_SCF_UTE
#     [Documentation]     test
#     [Setup]     log to console    Just for IWK TL
#     [Teardown]      log to console    prepare IWK TL end
#    [Timeout]    15min
#     Log To Console    \n *** run case Full_Commission_With_IWK_SCF
#     Prepare IWK testline to cell onair    localFilePath=${SCF_IWK_Trunk}    tl_scf_filename=${SCF_IWK[0]}
# 
# 
# 
# *** Keywords ***
# Prepare IWK testline to cell onair
#     [Arguments]      ${localFilePath}    ${tl_scf_filename}
# 	Connect to gnb coam via ssl   bts_host=${DU_OAM_IP}    username=${WEBEM_User}    password=${WEBEM_Password}
# 	COAM Commission with scf file    scf_file_path=${localFilePath}${tl_scf_filename}    timeout=500    is_pdl_checking_needed=${False}
#     Wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
#     [Teardown]    COAM Teardown gnb connections
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
