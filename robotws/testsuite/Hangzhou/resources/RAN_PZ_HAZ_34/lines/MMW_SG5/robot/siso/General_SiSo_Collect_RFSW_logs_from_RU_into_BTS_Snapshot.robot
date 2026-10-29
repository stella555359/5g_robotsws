# @Time    : 2023/8/11 9:53
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_3.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/11 09:54
    # Step 1~6: same as 2.0
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_2.0

    # Step 7: collect snapshot with l3call
    UE Attach With Verify Attach
    ${snapshot_file_list_4st}    ${snapshot_start_time_4st}    Collect_Snapshot_Return_Content_And_Start_Time
    Check_Content_OF_Radio_Unit_Logs_IN_Snapshot    ${snapshot_file_list_4st}
    ${ue_type}    translate power ue type from testline
    power_ue.UE Detach    ue_type=${ue_type}

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/11 09:54
    # Step 1,2,3: collect snapshot 1st
    ${snapshot_file_list_1st}    ${snapshot_start_time_1st}    Collect_Snapshot_Return_Content_And_Start_Time
    Check_Content_OF_Radio_Unit_Logs_IN_Snapshot    ${snapshot_file_list_1st}

    # Step 4: collect snapshot and cancel
    Snapshot_Cancelled_Normally_And_Collect_Partial_Log

    # Step 5: collect snapshot 2st, check 2st start time is newer
    ${snapshot_file_list_2st}    ${snapshot_start_time_2st}    Collect_Snapshot_Return_Content_And_Start_Time
    Should Be True    '${snapshot_start_time_2st}'>'${snapshot_start_time_1st}'
    Check_Content_OF_Radio_Unit_Logs_IN_Snapshot    ${snapshot_file_list_2st}

#    # Step 6: collect snapshot with Most important log files mode
#    ${snapshot_file_list_3st}    ${snapshot_start_time_3st}    Collect_Snapshot_Return_Content_And_Start_Time
#    ...    coverage=Most important log files
#    Check_Content_OF_Radio_Unit_Logs_IN_Snapshot    ${snapshot_file_list_3st}

Snapshot_Cancelled_Normally_And_Collect_Partial_Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/09 15:11
    [Arguments]    ${coverage}=All log files    ${save_location}=Local
    Selenium Login And Disable Screen Lock    download_dir=${TS_CASE_LOG_PATH}
    Run   rm -rf ${TS_CASE_LOG_PATH}/Snapshot_MRBTS-${MRBTS_ID}*
    selenium_sbts.snapshot_collection_settings    coverage=${coverage}    save_location=Local
    ${collect_result}    selenium_sbts.collect_snapshot    snapshot_waiting_timeout=20
    Should Be Equal As Strings    ${collect_result}    Collect Snapshot Failed
    ${cancel_result}    selenium_sbts.cancel_collect_snapshot
    Should Be Equal As Strings    ${cancel_result}    Snapshot Collection Canceled Successfully
    # wait the snapshot download to local
    Sleep    30s
    ${cancel_snapshot_file}    Run   ls ${TS_CASE_LOG_PATH}/Snapshot_MRBTS-${MRBTS_ID}*
    Should Contain    ${cancel_snapshot_file}    _partial.zip
    Run Keyword And Ignore Error    selenium logout and close browser

Collect_Snapshot_Return_Content_And_Start_Time
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init  Define: 2023/08/10 14:00
    [Arguments]    ${coverage}=All log files    ${save_location}=Local
    Selenium Login And Disable Screen Lock    download_dir=${TS_CASE_LOG_PATH}

    # empty snapshot log
    Run   rm -rf ${TS_CASE_LOG_PATH}/Snapshot_MRBTS-${MRBTS_ID}*
    selenium_sbts.snapshot_collection_settings    coverage=${coverage}    save_location=Local
    Run Keyword And Ignore Error    selenium_sbts.collect_snapshot
    sleep    30s
    ${collect_result}    Run    ls ${TS_CASE_LOG_PATH}/Snapshot_MRBTS-${MRBTS_ID}*

    # wait the snapshot download to local
    Sleep    30s
    ${snapshot_file}    Run   ls ${TS_CASE_LOG_PATH}/Snapshot_MRBTS-${MRBTS_ID}*

    # unzip snapshot log and get file list
    ${snapshot_unzip_file_path}    Remove String    ${snapshot_file}    .zip
    Run Process    unzip ${snapshot_file} -d ${snapshot_unzip_file_path}    shell=True
    ${snapshot_file_list}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt


    # get snapshot collect start time
    ${metadata_file}    Run   ls ${snapshot_unzip_file_path}/*metadata.txt
    ${snapshot_start_time}    Grep File    ${metadata_file}    Start Time : *T*Z

    # empty snapshot log
    Run   rm -rf ${TS_CASE_LOG_PATH}/Snapshot_MRBTS-${MRBTS_ID}*
    Run Keyword And Ignore Error    selenium logout and close browser
    [Return]    ${snapshot_file_list}    ${snapshot_start_time}

Check_Content_OF_Radio_Unit_Logs_IN_Snapshot
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/10 17:18
    [Arguments]    ${snapshot_file_list}    ${connection}=GNB_OAM
    ${smod_list}    coam.get_all_items_by_class_name    class_name=SMOD    connection=${connection}
    ${left_or_right}    coam.get_smod_position    connection=${connection}
    ${smod_length}    Get Length    ${smod_list}
    Run Keyword If    '${smod_length}'=='2'    Run Keywords
    ...    Check RU Info From Target Core    position=left    check_rfsw_log=${True}
    ...    snapshot_file_list=${snapshot_file_list}    AND
    ...    Check RU Info From Target Core    position=right    check_rfsw_log=${True}
    ...    snapshot_file_list=${snapshot_file_list}
    Run Keyword If    '${smod_length}'=='1'
    ...    Check RU Info From Target Core    position=${left_or_right}    check_rfsw_log=${True}
    ...    snapshot_file_list=${snapshot_file_list}


