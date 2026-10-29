# *** Settings ***
# Suite Setup          Run Keywords    9077 SISO Coam Suite Setup
# Suite Teardown       9077 SISO Coam Suite Teardown
# Test Setup           9077 SISO Coam Test Setup
# Test Teardown        9077 SISO Coam Test Teardown
# Test Timeout         200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
# Library      taf.sbts.oam.coam.admin       WITH NAME    coam
# Library      taf.pdu    WITH NAME    pdu
# Library      String
# Library      Resources/get_time.py
# Library      taf.transport.ssh      WITH NAME    csn
# Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/webui_coam.robot
# 
# Documentation
# ...    Author:lijun.j.xu@nokia-sbell.com
# ...    contact:lijun.j.xu@nokia-sbell.com
# ...    squad group:mmw03
# ...    Feature CB009077 in 24R3
# 
# Force Tags            5G_RAN    5G_RAN_TDD    STATE_GNB_COMMISSIONED    5G_CLASSICAL_ASIB_ABIL_AWHHD
# ...    PY36
# 
# *** Variables ***
# ${WEBUI_URL}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${ssh_user}        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${ssh_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${type}     gNB
# ${searchName}    BTS_AH205100745_RMOD_L_2_permanent.xml.gz
# ${connection}    COAM
# 
# 
# *** Test Cases ***
# [1]CB009077_E_06_Store_Location_info_during_run-time_ASMR
#      Disable CB009077
#      Configured RU Location    operation=delete
#      ${Permanent_size_OFF}    Check Permanent File Exist in snapshot
#      Log To Console    Disable CB009077 Permanent file size: ${Permanent_size_OFF}
#      Enable CB009077
#      ${Permanent_size_ON}    Check Permanent File Exist in snapshot
#      Log To Console    Disable CB009077 Permanent file size: ${Permanent_size_ON}
#      Configured RU Location
#      ${Permanent_size_Config}    Check Permanent File Exist in snapshot
#      Log To Console    Disable CB009077 Permanent file size: ${Permanent_size_Config}
#      Should be true    ${Permanent_size_Config}>${Permanent_size_ON}>${Permanent_size_OFF}
#      ...     msg=Permanent file has incorrect size: ${Permanent_size_ON}
# 
# 
# *** Keywords ***
# Check Permanent File Exist in snapshot
#     Log To Console    SaveSnapshot_Started
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     Log To Console    SaveSnapshot_Finished
#     ${retrun_fault}    Extract Permanent from snapshot    searchName=${searchName}
#     ...    snapshot_file=${snapshot_file_path}
#     [Return]  ${retrun_fault}
# 
# Extract Permanent from snapshot
#     [Documentation]   Auther:lijian.xia@nokia-sbell.com
#     [Arguments]    ${searchName}    ${snapshot_file}
#     Log To Console    ExtractSnapshot_Started
#     ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
#     ${zipout}    Set Variable    zipout_${timestamp}
#     Log To Console    ExtractSnapshot_Started1
#     Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
#     ${result_zip}    searchFile      filename=${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${searchName}
#     ${return_status}    run keyword and return status   should be equal as strings    ${result_zip}   not find
#     ${permanent_path}     Run keyword if     ${return_status}
#     ...   Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
#     ...   ELSE     Extract Zip File     ${TS_CASE_LOG_PATH}/${zipout}/${result_zip.split(":")[0]}       ${TS_CASE_LOG_PATH}/${zipout}
#     ${permanent_path}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};ls | grep -i ${searchName}
#     Log To Console    CheckFileSize_Started
#     ${file_size}    OperatingSystem.Get File Size    ${TS_CASE_LOG_PATH}/${zipout}/${permanent_path}
#     Should be true    ${file_size}>1    msg=Permanent file has incorrect size: ${file_size}
#     [Return]    ${file_size}
# 
# Enable CB009077
#     log to console    Enable CB009077
#     Conect to DU COAM
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
#     ...    parameter=actLocInfoStore
#     ...    operation=update
#     ...    value=true
#     ...    skip_parameter_relation_errors=True
#     ...    connection=${connection}
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
#     ...    parameter=accLevSet
#     ...    operation=update
#     ...    value=High
#     ...    skip_parameter_relation_errors=True
#     ...    connection=${connection}
#     [teardown]    Run Keyword And Ignore error    COAM Logout
# 
# Disable CB009077
#     log to console    Disable CB009077
#     Conect to DU COAM
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
#     ...    parameter=actLocInfoStore
#     ...    operation=update
#     ...    value=false
#     ...    skip_parameter_relation_errors=True
#     ...    connection=${connection}
#     [teardown]    Run Keyword And Ignore error    COAM Logout
# 
# Remove CB009077
#     log to console    Enable CB009077
#     Conect to DU COAM
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
#     ...    parameter=actLocInfoStore
#     ...    operation=delete
#     ...    value=true
#     ...    skip_parameter_relation_errors=True
#     ...    connection=${connection}
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
#     ...    parameter=accLevSet
#     ...    operation=delete
#     ...    value=High
#     ...    skip_parameter_relation_errors=True
#     ...    connection=${connection}
#     [teardown]    Run Keyword And Ignore error    COAM Logout
# 
# Configured RU Location
#     log to console    Configured Location
#     [Arguments]      ${operation}=update
#     Conect to DU COAM
#     ${RU_location}=    Create Dictionary
#     ...     altitude=12345
#     ...     latitude=798654321
#     ...     longitude=123456789
#     @{list}=    create list    ${RU_location}
#     coam.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#     ...    parameter=modulePositionInformation
#     ...    operation=${operation}
#     ...    value=@{list}
#     ...    skip_parameter_relation_errors=True
#     ...    connection=${connection}
#     [teardown]    Run Keyword And Ignore error    COAM Logout
# 
# Conect to DU COAM
#     [Arguments]    ${connection}=${connection}
#     coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#                   ...      username=${WEBUI_USER}
#                   ...      password=${WEBUI_PASSWORD}
#                   ...      name=${connection}
# 
# Get target Version
#     Log To Console    Get Target Version
#     ${connection}    coam.connect_to    bts_host=${WEBUI_URL}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${target_version}    set variable    ${version_list[3]}
#     [Return]    ${target_version}
#     [Teardown]    coam.Teardown    connection=${connection}
# 
# Get Version
#     Log To Console    Get Version
#     ${connection}    coam.connect_to    bts_host=${WEBUI_URL}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${versiontitle}    set variable    ${version_list[0]}
#     [Return]    ${versiontitle}
#     [Teardown]    coam.Teardown  connection=${connection}
# 
# 9077 SISO Coam Suite Teardown
#     log to console    \n***SISO Coam Suite Teardown***
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#     ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#     COAM Teardown gnb connections
#     Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
# 
# 9077 SISO Coam Suite Setup
#     log to console    \n***SISO Coam Suite Setup***
#     Connect to gnb coam via ssl
#     ${Active_SW_version}    Get Active SW Version
#     ${gNb_CuType}   Get gNB CU type
#     set suite variable      ${gNb_CuType}
#     Generate suite log path
#     set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
#     ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
#     log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
#     set suite variable  ${mrbtsID}
#     set suite variable  ${nrbtsID}
# 
# 9077 SISO Coam Test Teardown
#     log to console    \n***SISO Coam Test Teardown***
#     Remove CB009077
# 
# 9077 SISO Coam Test Setup
#     log to console    \n***SISO Coam Test Setup***
#     Generate test case log path
#     ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
#     set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
#     create directory   ${TS_CASE_LOG_PATH}
#     Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${ru_info}    COAM get all ru detail info
#     &{ru_info}    Set variable    ${ru_info['1']}
#     ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#     ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#     Run Keyword And Ignore Error    selenium_coam.close_browser
# 
# Disconnect from DU
#     [Arguments]    ${alias}=default
#     coam.teardown     connection=${alias}
# 
# Get bts version
#     ${connection}    Rest Login DU
#     ${version}    coam.get_sw_version     connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R4
#     ${searchName}    set variable if    ${if_common_load}    BTS_EB1944R0007_RMOD_L_2_faultLogs.zip
#     ...    BTS_EB1944R0007_RMOD_L_1_faultLogs.zip
#     [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${connection}
#     [Return]    ${searchName}
