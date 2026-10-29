*** Settings ***
Documentation
...    Test suite for regression testing for feature CB012144
...    author: Jakub Bialon
...    contact: jakub.bialon@nokia.com
...    group: MN_RAN_RD_VRF_KRK_7


Library   BuiltIn
Library    taf/rfrl/bts/devices/du/logs_collecting/basic_logs.py
Library    taf/rfrl/bts/devices/du/du_operations.py
Library    taf/rfrl/bts/devices/ru/ru_operations.py
Library    ./resources/tools.py
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    Common Suite Teardown
Test Setup    Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Test Cases ***
[1]CB012144-B_02_System_module_Black_Box_enhancements_for_POST_data
    [Tags]    T01
    ${MRBTS_ID}=    sg7keywords.Get Mrbts Id
    ${fault_4592}=    Create Dictionary    alarm_id=7115
    ...                                    fault_id=4592
    ...                                    fault_name=BTS Reset Cause
    ...                                    severity=Warning
    ${expected_alarms}=    Create List    ${fault_4592}
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    ${start_date}    Get Current Date
    gnbbbu.Power Reset Bts    reset_with_snapshot=False
    ...                       wait_for_reconnection=True
    ...                       cold_reset_secondary_core_via_backplane=False
    ...                       graceful_cell_shutdown=False
    ...                       timeout=1200
    gnbbbu.Wait For Site To Be Onair
    gnbbbu.Reset Bts
    gnbbbu.Wait For Site To Be Onair
    gnbbbu.Reset Bts
    gnbbbu.Wait For Site To Be Onair
    Sleep    3min    Waiting for FID 4592
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}
    ${end_date}    Get Current Date
    ${snapshot_path}=    gnblog.Collect Snapshot    log_dir=${OUTPUT_DIR}/Test_Case_T01
    ${blackbox_post_regex}    Set Variable    ^\ \ \ \ BTS${MRBTS_ID}_1011_blackbox_post_result_A.xz$
    ${blackbox_post}=    tools.Get And Ectract Xz File From Snap    snap_path=${snapshot_path}
    ...                                                             file_name=${blackbox_post_regex}
    tools.Check Blackbox Post Result A File Content    file_path=${blackbox_post}
    ...                                                site_module=SMOD
    ...                                                start_time=${start_date}
    ...                                                end_time=${end_date}
    ${blackbox_reset_regex}    Set Variable    ^\ \ \ \ BTS${MRBTS_ID}_1011_blackbox_reset.xz$
    ${blackbox_reset}=    tools.Get And Ectract Xz File From Snap    snap_path=${snapshot_path}
    ...                                                              file_name=${blackbox_reset_regex}
    tools.Check Blackbox Reset File Content    file_path=${blackbox_reset}
    ...                                        site_module=SMOD
    ...                                        start_time=${start_date}
    ...                                        end_time=${end_date}


[1]CB012144-A_01_Radio_module_Black_Box_enhancements_for_POST_data
    [Tags]    T02
    ${fault_10}=    Create Dictionary    alarm_id=7116
    ...                                  fault_id=10
    ...                                  fault_name=No connection to unit
    ...                                  severity=Critical
    ${fault_4589}=    Create Dictionary    alarm_id=7115
    ...                                    fault_id=4589
    ...                                    fault_name=Unit power reset
    ...                                    severity=Warning
    ${expected_alarms}=    Create List    ${fault_10}    ${fault_4589}
    gnbbbu.Wait For Site To Be Onair
    ${start_date}    Get Current Date
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    gnb_rus.Power Reset Radio Unit    radio_unit_id=0
    gnbbbu.Wait For Site To Be Onair
    gnb_rus.Reset Radio Unit    radio_unit_id=1    timeout=600    reset_type=Soft
    gnbbbu.Wait For Site To Be Onair
    gnb_rus.Reset Radio Unit    radio_unit_id=1    timeout=600    reset_type=Soft
    gnbbbu.Wait For Site To Be Onair
    gnb_rus.Reset Radio Unit    radio_unit_id=1    timeout=600    reset_type=Soft
    gnbbbu.Wait For Site To Be Onair
    ${end_date}    Get Current Date
    ${snapshot_path}=    gnblog.Collect Snapshot    log_dir=${OUTPUT_DIR}/Test_Case_T02
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}
    ${blackbox_file_regex}    Set Variable    ^.*BBOX5.*$
    ${bbox5_file}=    tools.Get And Ectract Xz File From Snap    snap_path=${snapshot_path}
    ...                                                          file_name=${blackbox_file_regex}
    tools.Check Bbox5 File Content    file_path=${bbox5_file}
    ...                               start_time=${start_date}
    ...                               end_time=${end_date}
    ...                               branch=${ENB_BRANCH}


[1]CB012144-C_03_Baseband_module_Black_Box_enhancements_for_POST_data
    [Tags]    T03
    ${MRBTS_ID}=    sg7keywords.Get Mrbts Id
    ${fault_4592}=    Create Dictionary    alarm_id=7115
    ...                                    fault_id=4592
    ...                                    fault_name=BTS Reset Cause
    ...                                    severity=Warning
    ${expected_alarms}=    Create List    ${fault_4592}
    gnbbbu.Wait For Site To Be Onair
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    ${start_date}    Get Current Date
    gnbbbu.Power Reset Bts    reset_with_snapshot=False
    ...                       wait_for_reconnection=True
    ...                       cold_reset_secondary_core_via_backplane=False
    ...                       graceful_cell_shutdown=False
    ...                       timeout=1200
    gnbbbu.Wait For Site To Be Onair
    gnbbbu.Reset Bbmod
    gnbbbu.Wait For Site To Be Onair
    gnbbbu.Reset Bbmod
    gnbbbu.Wait For Site To Be Onair
    ${end_date}    Get Current Date
    ${snapshot_path}=    gnblog.Collect Snapshot    log_dir=${OUTPUT_DIR}/Test_Case_T03
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}
    ${blackbox_file_regex}    Set Variable    ^\ \ \ \ BTS${MRBTS_ID}_123D_blackbox_post_result_A.xz$
    ${blackbox_post}=    tools.Get And Ectract Xz File From Snap    snap_path=${snapshot_path}
    ...                                                             file_name=${blackbox_file_regex}
    tools.Check Blackbox Post Result A File Content    file_path=${blackbox_post}
    ...                                                site_module=BBMOD
    ...                                                start_time=${start_date}
    ...                                                end_time=${end_date}
    ${blackbox_reset_file_regex}    Set Variable    ^\ \ \ \ BTS${MRBTS_ID}_123D_blackbox_reset.xz$
    ${blackbox_reset}=    tools.Get And Ectract Xz File From Snap    snap_path=${snapshot_path}
    ...                                                              file_name=${blackbox_reset_file_regex}
    tools.Check Blackbox Reset File Content    file_path=${blackbox_reset}
    ...                                        site_module=BBMOD
    ...                                        start_time=${start_date}
    ...                                        end_time=${end_date}
