# *** Settings ***
# Force Tags    PY36
# Documentation     author: Chen Kaijia
# ...               contact: kaijia.chen@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Suite Setup       CB007308-5G-AB_common_keywords_AEQE.Input default SCF
# 
# Resource          ./Resources/CB007308-5G-AB_FID4657_keywords_AEQE.robot
# Resource          ./Resources/CB007308-5G-AB_common_keywords_AEQE.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
# Library           ./Resources/test.py
# 
# *** Variable ***
# ${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
# 
# *** Test Cases ***
# [1]CB007308-5G-AB_CB006942_3_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
#     [Tags]    CB007308    CRT_22R4    CRT_22R2    CRT_TRUNK    CRT_22R3
#     CB007308-5G-AB_common_keywords_AEQE.Check BTS is in On Air
#     Check no unexpected alarm in WebEM
#     ${snapshot_file}    Collect snapshot coam
#     Extract logs from snapshot        snapshot_file=${snapshot_file}
#     CB007308-5G-AB_common_keywords_AEQE.BTS detects cooled SFP+/SFP28
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB007308-5G-AB_CB006942_7_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
#     [Tags]    CB007308    CRT_22R4    CRT_22R2    CRT_TRUNK    CRT_22R3
#     CB007308-5G-AB_FID4657_keywords_AEQE.Set SFPWhiteList File Name
#     CB007308-5G-AB_FID4657_keywords_AEQE.Create dir
#     CB007308-5G-AB_FID4657_keywords_AEQE.Download whitelist file
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=AOSD
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=AOZEB
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=AOZEA
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=FOTB
#     CB007308-5G-AB_FID4657_keywords_AEQE.Upload whitelist file
#     ...    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Reset DU
#     sleep    10s
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check fault 4657
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     CB007308-5G-AB_FID4657_keywords_AEQE.change sfpOperatorMode to true
#     sleep    2s
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check none fault 4657
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     sleep    60s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     CB007308-5G-AB_FID4657_keywords_AEQE.Reset DU
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check none fault 4657
#     sleep    10s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     sleep    5s
#     CB007308-5G-AB_FID4657_keywords_AEQE.change sfpOperatorMode to false
#     sleep    20s
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check fault 4657
#     sleep    2s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     sleep    60s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     [Teardown]    Case Teardown
# 
# [1]CB007308-5G-AB_CB006942_9_The_BTS_shall_support_NIDD_parameter_SFPOperatorMode_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
#     [Tags]    CB007308    CRT_22R1    CRT_22R2    CRT_TRUNK    CRT_22R3
#     [Setup]
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Case Teardown
#     sleep    15s
#     CB007308-5G-AB_FID4657_keywords_AEQE.Upload whitelist file
#     ...    upload_whitelist_path=${SFPwhitelist_PATH}SFPwhitelist.xml
#     CB007308-5G-AB_FID4657_keywords_AEQE.Reset DU
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check none fault 4657
#     sleep    3s
#     ssh.Connect to    hostname=${test_pc_host}    username=${test_pc_username}
#     ...   password=${test_pc_password}    alias=test_pc
#     ssh.send command    command=rm -rf ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
#     ...    connection=test_pc    timeout=15 s
#     ssh.send command    command=rm -rf ${SFPwhitelist_PATH}log
#     ...    connection=test_pc    timeout=15 s
#     CI_interface.Common Case Teardown
#     [Teardown]    ssh.Disconnect    connection=test_pc
# 
# Collect snapshot coam
#     [Arguments]    ${snapshot_path}=${OUTPUT DIR}
#     CB007308-5G-AB_common_keywords_AEQE.Connect to DU
#     ${date}    Get current date    result_format=%Y%m%d_%H%M%S
#     coam.Collect snapshot
#     ...        target_file_name=${snapshot_path}/snapshot_${date}.zip
#     ...        coverage=Full
#     ...        force=True
#     ...        timeout=720
#     ...        connection=cOAM_admin
#     CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU
#     [Return]    ${snapshot_path}/snapshot_${date}.zip
# 
# Extract logs from snapshot
#     [Documentation]   Auther:lijian.xia@nokia-sbell.com
#     [Arguments]    ${snapshot_file}    ${filter_para}='{print $3}'|cut -d "<" -f 2|cut -d ">" -f 1|cut -d "." -f 1|cut -d "T" -f 2
#     ...    ${Ready}="Initializing, to: Ready"    ${Cooled}="Cooled transceiver detected"
#     ...    ${file}=snapshot_file_list.txt    ${f_length}=-E -w "[^[:space:]]{36}"
#     ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
#     ${zipout}    Set Variable    zipout_${timestamp}
#     Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
#     ${searchName}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};find . -name ${file} |xargs grep "_startup" |grep "_RMOD" |grep ${f_length}
#     ${searchName}   split string   ${searchName}    \n
#     log to console     ${searchName}
#     FOR     ${item}    IN     @{searchName}
#         ${item}    Remove String    ${item}     ${SPACE}
#         ${result_zip}    searchFile      filename=${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${item}
#         Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${result_zip.split(":")[0]}       ${TS_CASE_LOG_PATH}/${zipout}
#         Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${item}       ${TS_CASE_LOG_PATH}/${zipout}
#         Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};unxz startup_DEFAULT.log.xz
#         ${Initializing_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Ready}|tail -1 |awk ${filter_para}
#         ${Detecting_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Cooled} |tail -1 |awk ${filter_para}
#         ${Initializing_time}    DateTime.Convert Time    ${Initializing_time}
#         ${Detecting_time}      DateTime.Convert Time      ${Detecting_time}
#         ${return_deviation}      Evaluate    ${Initializing_time}-${Detecting_time}
#         should be true    ${return_deviation}<90
#    END
# 
# Rest Login DU
#     [Arguments]    ${ip_address}=${DU_IP}    ${username}=${WEBEM_USERNAME}
#     ...    ${password}=${WEBEM_PASSWORD}    ${alias}=default
#     [Documentation]   Rest Login DU
#     Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
#     ${connection}     set variable    ${alias}
#     [Return]    ${connection}
# 
# Disconnect from DU
#     [Arguments]    ${alias}=default
#     coam.teardown     connection=${alias}
# 
# Check no unexpected alarm in WebEM
#     Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#     Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#     [Teardown]   run keyword and ignore error    COAM Teardown gnb connections
