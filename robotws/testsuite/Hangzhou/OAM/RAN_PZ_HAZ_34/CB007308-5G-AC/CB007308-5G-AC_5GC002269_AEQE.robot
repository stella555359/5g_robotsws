# *** Settings ***
# Force Tags    PY36
# Documentation     author: Chen Kaijia
# ...               contact: kaijia.chen@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Suite Setup       Input default SCF
# 
# Library           taf.selenium.sbts    WITH NAME    selenium_coam
# #Library           taf.sbts.oam.coam.admin    WITH NAME    coam
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${ROOT_USERNAME}       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${ROOT_PASSWORD}       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${MRBTS_ID}            MRBTS-${tl.gnbs[0].instance_id}
# ${NRBTS_ID}            NRBTS-${tl.gnbs[0].global_bts_id}
# ${DU_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${LMP_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
# ${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# @{all_cell_info}       ${0}    ${1}
# ${scf_path}          ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/
# 
# 
# *** Test Cases ***
# 
# 
# 
# *** Keywords ***
# WEBUI Login
#     [Arguments]      ${virtual_enable}=${True}    ${version}=5G21B
#     [Documentation]   WEBUI Login
#     Log To Console  START:WEBUI Login
#     Log To Console  Try to login...
#     selenium_coam.Enable Virtual Display
#     selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     ...    version=${version}
#     Log To Console  Login successfully...
#     Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
#     Sleep    15s
#     Log To Console  END:WEBUI Login!
#     ${start_exits}    selenium_coam.start_up_view_window_exists
#     Run Keyword If     ${start_exits} == ${TRUE}     selenium_coam.close_start_up_view_window
# 
# WEBUI_Logout
#     [Arguments]     ${virtual_disable}=${True}
#     [Documentation]   WEBUI Logout
#     Log To Console  Try to logout...
#     Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
#     Run Keyword And Ignore Error  selenium_coam.Logout
#     Log To Console  Logout successfully...
#     Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
#     Sleep    1s
#     Log To Console  END:WEBUI Logout!
# 
# WebEM ValidateAndActiveParameters
#     [Documentation]  WebEM ValidateAndActiveParameters
#     ${error}    selenium_coam.validate_plan
#     Log To Console    ${error}
#     selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${300}
# 
# Check BTS is in On Air
#     Connect to DU
#     Log To Console  Checking onair...
#     ADMIN Wait Until BTS OnAir
#     [Teardown]    Disconnect from DU
# 
# Check 2 cell both onair
#     Connect to DU
#     Log To Console  Checking 2 cell both onair without BTS reset...
#     Gnb Cell Should Be Onair
#     [Teardown]    Disconnect from DU
# 
# Connect to DU
#     [Arguments]    ${alias}=cOAM_admin
#     Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
#     ${conn}    set variable    ${alias}
#     [Return]    ${conn}
# 
# Disconnect from DU
#     [Arguments]    ${alias}=cOAM_admin
#     coam.teardown     connection=${alias}
# 
# ADMIN Wait Until BTS OnAir
#     [Arguments]    ${timeout}=2 s
#     ...            ${interval}=0.01 sec
#     ...            ${alias}=cOAM_admin
#     Wait Until Keyword Succeeds    ${timeout}
#     ...                            ${interval}
#     ...                            ADMIN Check onair
#     ...                            admin_alias=${alias}
# 
# ADMIN Check onair
#     [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
#     ${dict_info}=    coam.Get Bts Info    connection=${admin_alias}
#     ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
#     Should be equal    ${state}    OnAir
# 
# Case teardown
#     run keyword and continue on failure    selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
#     run keyword and continue on failure    selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/NRCELLGRP-1
#     run keyword and continue on failure    selenium_coam.remove_element   dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1
#     ...    filter_param=Reference to cell group    node_index=${1}    abbr=refNrCellGroup
#     run keyword and continue on failure    selenium_coam.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
#     Log To Console  Validate And Activate parameters
#     WebEM ValidateAndActiveParameters
#     Log To Console  Activated plan
#     Check BTS is in On Air
#     Log To Console  Cell deleted without BTS reset
#     WEBUI_Logout
#     CI_interface.Common Case Teardown
# 
# Gnb Cell Should Be Onair
#     [Arguments]    ${alias}=cOAM_admin
#     [Documentation]  Gnb Cell Should Be Onair, check method is via REST
#     ${status}      coam.Get_Bts_Statuses   connection=${alias}
#     ${operationalState}    Get From Dictionary    ${status}    operationalState
#     Should Be Equal    ${operationalState}    Enabled
#     ${blockingState}   Get From Dictionary    ${status}    blockingState
#     Should Be Equal    ${blockingState}    Unblocked
#     ${proceduralState}   Get From Dictionary    ${status}   proceduralState
#     Should Be Equal    ${proceduralState}    OnAir
# #    Repeat keyword    20    Run Keywords    Check 2 CELL status
#     Wait Until Keyword Succeeds    2min    2s    Check 2 CELL status
# 
# Check 2 CELL status
#     [Arguments]    ${alias}=cOAM_admin    ${cell_type }=nr
#     ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
#     FOR    ${item}    IN    @{all_cell_info}
#         ${Status}    Get From Dictionary    ${cell_status[${item}]}    status
#         ${tmp}   Get From Dictionary    ${status}    operationalState
#         ${status_1}    run keyword and return status    Should Be Equal    ${tmp}    Enabled
#         ${status_2}    run keyword and return status    Should Be Equal    ${tmp}    enabled
#         should be true    ${status_1} or ${status_2}
#         ${tmp}   Get From Dictionary    ${status}  administrativeState
#         Should Be Equal    ${tmp}    Unlocked
#         ${tmp}   Get From Dictionary    ${status}  blockingState
#         Should Be Equal    ${tmp}    Unblocked
#         ${tmp}   Get From Dictionary    ${status}  usageState
#         Should Be Equal    ${tmp}    Active
#     END
# 
# Input default SCF
#     [Timeout]  20 min
#     [Arguments]      ${timeout}=10 min
#     ${connection}    Connect to DU
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
#     ${default_scf}    set variable if    ${if_common_load}   ${scf_path}SCF_1cc_22R2.xml
#     ...    ${scf_path}SCF_1cc_22R3.xml
#     set suite variable    ${default_scf}
#     BuiltIn.Log    \n Input default SCF \n    console=yes
#     run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
#     BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
#     wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${connection}
#     wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${connection}
#     [Teardown]     Disconnect from DU
