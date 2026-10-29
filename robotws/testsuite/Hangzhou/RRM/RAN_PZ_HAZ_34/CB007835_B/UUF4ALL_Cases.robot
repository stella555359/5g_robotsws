# *** Settings ***
# Documentation
# ...   author: Wu Pengliang
# ...   contact: pengliang.wu@nokia-sbell.com
# 
# #Suite Setup       robot_common_operations.Common Suite Setup
# #Suite Teardown    robot_common_operations.Common Suite Teardown
# #Test Teardown     robot_common_operations.Common case Teardown
# #Test Setup        robot_common_operations.Common case Setup
# 
# 
# Library      String
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Library     taf.transport.ssh    WITH NAME    csn
# Force Tags     RAN_HZ_PZ_3_SG4  PY36
# 
# 
# *** Variables ***
# ${target_version}
# ${testline_name}
# ${UPGRADE_TEST_ITERATION}=      3
# ${RESET_TEST_ITERATION}=        3
# @{CUSTOM_ALARMS}=               @{EMPTY}
# ${REMOTE_VM_IP}=                ${None}
# ${REMOTE_MPLANE}=               ${None}
# ${LABEL}=                       HZ3_SG4_E2E_ASIK_3xABIL_2xAWHQF_2xAEQV_1xAWEUA
# ${HOSTNAME}=                    ${testline_name}
# @{CRITICAL_FAULTS}=             10    16    1806    1868    4341    4352    4383
# ${SHOULD_BE_REPORTED}=          ${False}    #report to rep
# @{CUSTOMERS_LIST}=              KDDI Japan
# ${5G_SOURCE_SW}=                ${None}    #source packet should same as BTS current version
# ${5G_TARGET_SW}=                ${None}
# ${5G_TARGET_SW_PATH}=           ${None}
# ${4G_SOURCE_SW}=                ${None}
# ${4G_TARGET_SW}=                ${None}
# ${4G_TARGET_SW_PATH}=           ${None}
# ${REMOTE_NODE_UPDATE}=          ${False}
# ${USE_REMOTE_NODE}=             ${False}
# ${DOWNLOAD_PATH}=               ${None}
# ${USE_BUILDS_STORAGE}=          ${False}
# ${RESTORE_TARGET_SW}=           ${True}    #BTS will restore target version if true
# ${PERFORM_UBOOT_DOWNGRADE}=     ${True}
# ${DISABLE_SYSLOG_CHECK}=        ${False}
# @{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
# ${REPORT_COMMENT}=              ${None}
# ${ONLINE_PARAMETER_DELTA}=      ${None}
# ${SITE_RESET_DELTA}=            ${None}
# ${NR_RAT_RESET_DELTA}=          ${None}
# ${LTE_RAT_RESET_DELTA}=         ${None}
# ${WCDMA_RAT_RESET_DELTA}=       ${None}
# ${GSM_RAT_RESET_DELTA}=         ${None}
# ${GSM_RAT_RESET_DELTA}=         ${None}
# ${GSM_RAT_RESET_DELTA}=         ${None}
# ${GSM_RAT_RESET_DELTA}=         ${None}
# ${QC_DOMAIN}=  MN_RAN_ST
# ${TEST_QC_ID}=  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
# ${QC_PROJECT}=  RAN_ST
# 
# ${HZ_Server}    http://10.135.157.75:8081/artifactory/mn5gran_hzlog-local
# ${UTE_IP}                       ${tl.test_pc.default_ssh_connection_details.addr}
# ${UTE_USERNAME}                 ${tl.test_pc.default_ssh_connection_details.username}
# ${UTE_PASSWORD}                 ${tl.test_pc.default_ssh_connection_details.password}
# ${SW_build_path}                /home/ute/Downloads/UUF_SW
# 
# *** Test Cases ***
# E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#     [Timeout]   24h
#     ${Currnet_BTS_Version}    Get Current BTS Vresion
#     ${5G_TARGET_SW_Download_link}    Get BTS packet and download to UTE
#     Set Test Variable    ${5G_SOURCE_SW}    ${Currnet_BTS_Version}
#     Set Test Variable    ${5G_TARGET_SW}    ${target_version}
#     Set Test Variable    ${5G_TARGET_SW_PATH}    ${5G_TARGET_SW_Download_link}
#     UUF4ALL_SW_UPGRADE_TEST
#     ...          test_iteration=${UPGRADE_TEST_ITERATION}
#     ...          custom_alarms=${CUSTOM_ALARMS}
#     ...          remote_vm_ip=${REMOTE_VM_IP}
#     ...          remote_mplane=${REMOTE_MPLANE}
#     ...          label=${LABEL}
#     ...          hostname=${HOSTNAME}
#     ...          critical_faults=${CRITICAL_FAULTS}
#     ...          should_be_reported=${SHOULD_BE_REPORTED}
#     ...          customers_list=${CUSTOMERS_LIST}
#     ...          5g_source_sw=${5G_SOURCE_SW}
#     ...          5g_target_sw=${5G_TARGET_SW}
#     ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
#     ...          use_builds_storage=${USE_BUILDS_STORAGE}
#     ...          restore_to_target_sw=${RESTORE_TARGET_SW}
#     ...          remote_node_update=${REMOTE_NODE_UPDATE}
#     ...          use_remote_node=${USE_REMOTE_NODE}
#     ...          use_test_packages=${False}
#     ...          download_path=${DOWNLOAD_PATH}
#     ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
#     ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#     ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#     ...          report_comment=${REPORT_COMMENT}
#     ...          qc_domain=${QC_DOMAIN}
#     ...          qc_id=${TEST_QC_ID}
#     ...          qc_project=${QC_PROJECT}
# 
# E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#     [Timeout]   24h
#     UUF4ALL_SITE_RESET_TEST
#     ...          test_iteration=${RESET_TEST_ITERATION}
#     ...          custom_alarms=${CUSTOM_ALARMS}
#     ...          remote_vm_ip=${REMOTE_VM_IP}
#     ...          remote_mplane=${REMOTE_MPLANE}
#     ...          label=${LABEL}
#     ...          hostname=${HOSTNAME}
#     ...          critical_faults=${CRITICAL_FAULTS}
#     ...          should_be_reported=${SHOULD_BE_REPORTED}
#     ...          customers_list=${CUSTOMERS_LIST}
#     ...          use_remote_node=${USE_REMOTE_NODE}
#     ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#     ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#     ...          report_comment=${REPORT_COMMENT}
#     ...          qc_domain=${QC_DOMAIN}
#     ...          qc_id=${TEST_QC_ID}
#     ...          qc_project=${QC_PROJECT}
# 
# *** Keywords ***
# Get BTS packet and download to UTE
#     [Arguments]    ${BTS_Version}=${5G_TARGET_SW}
#     ${release_para}    Split String    ${BTS_Version}     _
#     ${release}    set variable    ${release_para[0]}
#     ${package_full_link}    set variable
#     ...    ${HZ_Server}/${release}_packages/${BTS_Version}/${BTS_Version}_release_BTSSM_downloadable_A54.zip
#     csn.Connect to    hostname=${UTE_IP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=TESTPC
#     OperatingSystem.Create Directory    ${SW_build_path}
#     OperatingSystem.Empty Directory    ${SW_build_path}
#     Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
#     ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
#     ${md5_file}     set variable    @{output}[0]
#     ${md5_value}      OperatingSystem.get file    ${md5_file}
#     OperatingSystem.Empty Directory    ${SW_build_path}
#     Log to console    Start download packet
#     Run And Return Rc And Output    wget --no-proxy ${package_full_link} -P ${SW_build_path}
#     ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
#     ${upgrade_package_path}     set variable    @{output}[0]
#     Log to console    sleep 3min, wait for packet download complete.
#     sleep    3min
#     wait until keyword succeeds    10min    10s    check the download completed    ${upgrade_package_path}     ${md5_value}
#     Log to console    Download packet compelete
#     [Return]      ${upgrade_package_path}
#     [Teardown]    csn.disconnect    connection=TESTPC
# 
# check the download completed
#     [Arguments]    ${upgrade_package_path}    ${md5_value}
#     ${sum}=        Set Variable     sha256sum ${upgrade_package_path}
#     ${res}    ${output}    Run And Return Rc And Output    ${sum}
#     ${res}    String.split string    ${output}
#     should be equal    ${md5_value}    @{res}[0]
# 
# Get Current BTS Vresion
#     [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=${0}
#     Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#     ${parameters}    coam.get_parameters_for_all    class_name=BTS    timeout=20s    connection=${connection}
#     ${ActiveVersion}    set variable    ${parameters}[${0}][activeSoftwareVersion]
#     ${sw_version_list}    Split String    ${ActiveVersion}     _
#     ${ActiveVersion_trunk}    replace string    ${ActiveVersion}    ${sw_version_list[0]}    STS00
#     ${ActiveVersion}    Set Variable if    ${sw_version_list[2]}==9999    ${ActiveVersion_trunk}
#     [Return]    ${ActiveVersion}
#     [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
