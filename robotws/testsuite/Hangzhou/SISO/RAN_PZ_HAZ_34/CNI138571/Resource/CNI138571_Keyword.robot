*** Settings ***
Documentation    This is for CNI138571 Keyword
...              Author: Yuxing Zhai
...              Squard: VRF HAZ 1

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue    WITH NAME    taf_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py


*** Variables ***
${common_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
${download_username}    ca_5Gauto
${download_password}    AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc

*** Keywords ***

General_SISO_RU_Lock_Unlock_VRF1
    [Documentation]   lock unlock RU and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${1}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Lock all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Lock all RMODs SG08
        sleep    10
        Check status after lock RMODs
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unLock all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Unlock all RMODs SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 5 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    loop_times=${1}    duration=${duration}
    ...    ui_version=${ui_version}
   [Teardown]    run keyword and ignore error   COAM Teardown gnb connections



Check status after lock RMODs
    Wait Until Keyword Succeeds    10min    60s    Check SMOD status    usageState=idle
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check RMOD status    rmod_index=${ru_index}    adminState=locked    usageState=idle
    END
    Wait Until Keyword Succeeds    10min    60s    check bts status by coam SG8    lte_status=integrated to ran    nr_status=integrated to ran
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status    operationalState=disabled    usageState=idle
