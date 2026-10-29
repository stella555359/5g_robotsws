# *** Settings ***
# Documentation
# ...    author: meiya.cheng
# ...    contact: meiya.cheng@nokia-sbell.com
# ...    squad group: RAN_PZ_MMW_CN_3_SG02
# ...    Feature :  CB007199-5G-C
# 
# Force Tags      CRT_TRUNK
# ...    PY36
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
# Library           taf.ul.vdu.helm                       WITH NAME    helm
# Library           taf.transport.ssh                     WITH NAME    tafssh
# Library           Collections
# Library           OperatingSystem
# Library           Process
# Library           String
# Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/python/basic.py
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_BTS.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_Common_Resource.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_Common_Setup_Teardown.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_trs_conn.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${WEBUI_URL}          ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
# ${WEBUI_USER}         ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
# ${WEBUI_PASSWORD}     ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
# ${head}               curl https://${WEBUI_URL}/api/licensed/v1/cells/operations
# ${status_head}        curl https://${WEBUI_URL}/api/licensed/v1/vdu-cells/
# 
# ${MRBTS_ID}         ${tl.gnbs[0].dus[0].instance_id}
# ${NRBTS_ID}       ${tl.gnbs[0].dus[0].instance_id}
# 
# ${TEST_LOG_DIRECTORY}    /home/ute/cmy_logsAIC/
# *** Test Cases ***
# [1]CNI-73019_2_Cell_mapping_information_could_be_find_in_vDU_WebEM
#     [Documentation]
#     ...    this test case is to verify if appropriate information about subcells mapping information on vDU WebEM GUI is displayed. 
#     [Setup]     robot_common_operations.Common Case Setup
#     Get vDU subcells info
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1]CNI-73019_5_Cell_mapping_information_included_in_M2MCLI
#     [Documentation]
#     ...    Purpose of this test is to verify if appropriate information about cells mapping is present in M2M CLI.
#     [Setup]     robot_common_operations.Common Case Setup
#     ${cell_number}=    Get cell number
#     FOR  ${i}  IN RANGE  ${cell_number}
#         ${alias}=    get unique id
# 	    Set Suite Variable    ${alias}
#         Get Cellmapping in M2M    ${i+1}    alias=${alias}
#         should contain     ${operation_output}    "subCellDirection":"DL","subCellId":${i}
#         should contain     ${operation_output}    "subCellDirection":"UL","subCellId":${i}
#     END   
#     #Run Keyword And Ignore Error   tafssh.Reset Cache
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# *** Keywords ***
# Get cell number
#     [Arguments]    ${vdu_index}=0    ${gnb_index}=0
#     ${cell_number}    Get VDU Cell Number From SCF    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#     [Return]    ${cell_number}
# 
# Case Precondition
#     vDU Check All Cells Status Should Be Onair
# 
# Case Postcondition
#     #log to console   Case Test Teardown
#     Run Keyword And Ignore Error    Disconnect All SSH Connections
# 
# Get Cellmapping in M2M
#     [Arguments]     ${cell_id}    ${alias}=${alias}
#     Connect To K8s Master In vDU    alias=${alias}
#     ${Token}     Get Token via M2M    alias=${alias}
#     ${command_1}=  set variable    curl https://${WEBUI_URL}/api/licensed/v1/vdu-cells/${cell_id}
#     ${command_2}=  set variable    -k -X GET -H "Accept: application/json" -H "Authorization: Bearer ${Token}"
# 	${operation_output}    issh.Execute    ${command_1} ${command_2}    alias=${alias}
#     [Return]    ${operation_output}
#     Set Suite Variable    ${operation_output}
#  
# Get Token via M2M
#     [Arguments]     ${alias}=${alias}
#     ${TOKEN_COMMAND_1}=  set variable    curl https://${WEBUI_URL}/api/licensed/sec/v1/login -k -X POST -H
#     ${TOKEN_COMMAND_2}=  set variable    "Accept: application/json" -H "Content-Type: application/json" -H
# 	${base64_code}    issh.Execute    command=echo -n Nemuadmin:Nokia@123| base64    alias=${alias}
# 	${base64_code}    Replace String    ${base64_code}    \r\n    ${EMPTY}
# 	#${base64_code}    Replace String    ${base64_code}    [core@oe20-dx-b-2ih02-1-1l ~]$        ${EMPTY}
# 	${base64_code}    Replace String    ${base64_code}    [core@hzdx-pz-10-71-223-210 ~]$        ${EMPTY}
# 	${base64_code}    Replace String    ${base64_code}    \n    ${EMPTY}
# 	${Token_output}    issh.Execute    command=${TOKEN_COMMAND_1} ${TOKEN_COMMAND_2} "Authorization: Basic ${base64 code}"        alias=${alias}
# 	${Token_output}    Replace String    ${Token_output}    va2lhQDEyMw=="\r\n    ${EMPTY}
#     log to console    ${Token_output}
#     ${Token}=    Run   echo "${Token_output}"|grep "Token"| awk -F ":" '{print $2}' | tr -d ',' | tr -d ' '
#     [Return]    ${Token}
# 
# 
# Get vDU subcells info
#     [Arguments]    ${vdu_index}=0    ${gnb_index}=0
#     ${cell_number}=    Get cell number
#     ${alias}=    get unique id
#     vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
#     FOR  ${i}  IN RANGE  ${cell_number}
#         log    ${i}
#         ${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i+1}
#         ${vdu_subcells_summary}=    vdu.get_cell_mapping_info_by_nr_cell_dn    nr_cell_dn=${mo_dn}    vdu_connection=${alias}
#         ${subCellDirection}    Get From Dictionary    ${vdu_subcells_summary}    sub_cells
#         Should Be true    '${subCellDirection[0]['subCellDirection']}'=='DL'
#         Should Be true    ${subCellDirection[0]['subCellId']}==${i}
#         Should Be true    '${subCellDirection[1]['subCellDirection']}'=='UL'
#         Should Be true    ${subCellDirection[1]['subCellId']}==${i}
#     END
#     Run Keyword And Ignore Error    vdu.disconnect    ${alias}