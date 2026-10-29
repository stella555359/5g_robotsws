*** Settings ***
Force Tags    PY36
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/5GC002413-A/Resources/5GC002413_A_common_keywords.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Suite Setup     Run Keywords     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}
...                     AND    5GC0002413_A Suit Setup

*** Variables ***
@{listen_port}     arb0p1   arb0p0   arb0p3    arb0p2

*** Test Cases ***
[1][1.0] 5GC002413-A_04_Content_of_the_synchronization_log
    [Tags]    5GC002413-A   CIT_TRUNK    CIT_22R4
    [Setup]    5GC002413-A Case Setup
    Start Btslog Collect
    Sleep    50min
    Clear the cache and reconnect
    COAM Check GNB Sync status
    ${file_path}    Get RFSW Log File On RU
    Run Keyword And Continue On Failure     Check Content of Synchronization Log    file_path=${file_path}
    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    Check Timer Is Work of Synchronization Log    file_path=${file_path}
    Run Keyword And Continue On Failure    Check Preserved Parameters    file_path=${file_path}
    Run Keyword And Continue On Failure    Check for unexpected alarms for 2413-A
    Run Keyword And Continue On Failure    Save Coam Snapshot
    [Teardown]    Run Keyword And Ignore Error    5GC002413-A Case Teardown

[1]5GC002413-A_09_Monitoring_recovery_of_PTP_signal
    [Tags]    5GC002413-A   CIT_TRUNK    CIT_22R4
    [Setup]    5GC002413-A Case Setup
    COAM Check GNB Sync status
    COAM Create log directory for 561
    Connect to gnb coam via ssl
    ${listen_port_index}    Get listen_port
    Check Log in Locked State for 5GC002413    file_name=${ptp_locked_log}    listen_port=${listen_port}[${listen_port_index}]    &{ssmType_ITU}
    Check topGMasterClockIdentity    filename=${ptp_locked_log}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_561_ACCEPTEDCLOCKCLASS}
    Check Log in Holdover and Phase Error within specification for 5GC002413    file_name=${ptp_holdover_log}
    ...                                                                         listen_port=${listen_port}[${listen_port_index}]
    ...                                                                         &{ssmType_ITU}
#    Change Clockclass and Syncin on Enb
    wait until keyword succeeds    5min    2sec     Check TOP Alarm Raised in COAM
#    Recover Clockclass and Syncin on Enb
    Recover ENV syncInputType 2413-A    listen_port=${listen_port}[${listen_port_index}]
    Sleep   5min
    Run Keyword And Continue On Failure    Check for unexpected alarms for 2413-A
    Run Keyword And Continue On Failure    Save Coam Snapshot
    [Teardown]    Run Keyword And Ignore Error    5GC002413-A Case Teardown
