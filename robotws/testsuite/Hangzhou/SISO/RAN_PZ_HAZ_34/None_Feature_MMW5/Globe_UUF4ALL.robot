*** Settings ***
Documentation    Author: chun.li@nokia-sbell.com


Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
#...    AND     GlobeCommon_Suite_Setup   is_commission=${False}
Suite Teardown       robot_common_operations.Common Suite Teardown
Test Setup           robot_common_operations.Common Case Setup 
Test Teardown        robot_common_operations.Common Case Teardown

Force Tags    5G_SISO    mmw_05    CRT_22R1    CRT_23R1    CRT_Trunk
...   PY36

Resource    Resources/Globe_keywords_common.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
#Library           taf.transport.ssh    WITH NAME    csn
#Library           taf.sbts.oam.coam.admin   WITH NAME   coam

*** Variables ***
@{customers}             Globe
#${5g_target_sw}          ${target_version}
${runs_of_uuf_upgrade}   ${1}
${runs_of_uuf_reset}     ${1}
${runs_of_bbmod_reset}   ${10}
${runs_of_rmod_reset}    ${20}
${runs_of_nrcel_lock}    ${3}
${restore_to_target_sw}    False
${remote_node_update}   True
${is_enb_test}     True
${should_be_reported}       True
#${L3_CALL}   Make Call With All UE for Sleepingcell
${disable_syslog_check}   True
${runs_of_delta_commission}    ${1}
@{critical_faults}       16    1806    1868    4341    4352    4383    4329    4330
@{custom_alarms}         7312    7313
${testline_name}
${CONFIGURATION}    HGZ.${testline_name}
${TS_CASE_LOG_PATH}   ${OUTPUT DIR}


*** Test Cases ***
[1]E2E_gNB_SW_Upgrade_loops_with_WebUI
    ${5g_current_version}    Get_Current_Active_SW_Version
    ${4g_current_version}    Get_Current_Active_SW_Version   url=https://${tl.enbs[0].oam_ip.v4}
    Set Test Variable    ${4g_source_sw}    ${4g_current_version}
    Set Test Variable    ${5g_source_sw}    ${5g_current_version}
    log to console   \n5Gsource:${5g_source_sw}
    log to console   \n4Gsource:${4g_source_sw}
    set suite variable    ${upgrade_package_path}    ${SW_build_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    ${upgrade_package_path}
    run keyword if  not ${status}     Fetch SW Package
    ${5g_target_sw_path}   Set Variable   ${upgrade_package_path}
    ${4g_target_sw_path}   Set Variable   ${5g_target_sw_path}
    UUF4ALL_SW_UPGRADE_TEST
    ...    test_iteration=${runs_of_uuf_upgrade}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    5g_source_sw=${5g_source_sw}
    ...    5g_target_sw=${target_version}
    ...    use_builds_storage=${False}
    ...    restore_to_target_sw=${restore_to_target_sw}
    ...    custom_alarms=@{custom_alarms}
    ...    4g_source_sw=${4g_source_sw}
    ...    4g_target_sw=${target_version}
    ...    use_remote_node=${is_enb_test}
    ...    remote_node_update=${remote_node_update}
    ...    should_be_reported=${should_be_reported}
#    ...    local_node_attach_test_keyword=${L3_CALL}
#    ...    remote_node_attach_test_keyword=${L3_CALL}
    ...    disable_syslog_check=${disable_syslog_check}
    ...    5g_target_sw_path=${5g_target_sw_path}
    ...    4g_target_sw_path=${4g_target_sw_path}


[1]E2E_Reset_with_HWF_deletion
    [Tags]    CRT_TRUNK    CRT_22R1    CRT_23R1
    UUF4ALL_SITE_RESET_TEST
    ...    test_iteration=${runs_of_uuf_reset}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    custom_alarms=@{custom_alarms}
    ...    use_remote_node=${is_enb_test}
    ...    should_be_reported=${should_be_reported}
#    ...    attach_test_keyword=${L3_CALL}
    ...    disable_syslog_check=${disable_syslog_check}


*** Keywords ***
