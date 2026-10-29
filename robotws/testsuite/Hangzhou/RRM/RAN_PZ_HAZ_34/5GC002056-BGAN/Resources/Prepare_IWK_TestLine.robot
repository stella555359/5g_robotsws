*** Settings ***
Documentation    author:Liu Tiffany
...              contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                History: Do some adaption for CB008181 by LiuNing
...               feature : CB008181
#Suite Setup    	robot_common_operations.Common Suite Setup
#Suite Teardown    robot_common_operations.Common Suite Teardown


Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
##GNB##
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_User}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_Password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
##SCF##
@{SCF_IWK}                      SCF_IWK_Trunk.xml       SCF_IWK_enegy_saving.xml
...     SCF_IWK_enegy_saving_NSA.xml      SCF_IWK_enegy_saving_SA.xml
${SCF_IWK_path}                commissionings/HGZ/7_5_UTE5G402T926/SCF_IWK/



#*** Test Cases ***
#[1]TC.Full_Commission_With_IWK_SCF
#    [Documentation]     test
#    [Tags]     CDRT_TRUNK
#    [Setup]     log to console    Just for IWK TL
#    [Teardown]      log to console    prepare IWK TL end
#    [Tags]
#   [Timeout]    15min
#    Log To Console    \n *** run case Full_Commission_With_IWK_SCF
#    Prepare IWK testline to cell onair    localFilePath=${SCF_IWK_Trunk}    tl_scf_filename=${SCF_IWK[0]}



*** Keywords ***
Prepare IWK testline to cell onair
    [Arguments]      ${SCF_IWK_Trunk}=${SCF_IWK_path}     ${file_index}=${0}
	wait until keyword succeeds   60x   10s
    ...    Connect to gnb coam via ssl   bts_host=${DU_OAM_IP}
    ...     username=${WEBEM_User}    password=${WEBEM_Password}
	COAM Commission with scf file    scf_file_path=${SCF_IWK_Trunk}${SCF_IWK[${file_index}]}    timeout=500    is_pdl_checking_needed=${False}
    Wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

