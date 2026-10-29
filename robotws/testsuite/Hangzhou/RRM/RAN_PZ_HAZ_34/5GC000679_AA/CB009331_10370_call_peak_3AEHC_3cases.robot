*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/5GC000679_common_keyword_Dingli.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot

*** Variables ***
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${scf_path}    /home/ute/Downloads/SCF

${tshark_path}         /usr/bin/tshark
${type}                nokia_fastmile

${MAX_LOOP}        5

@{check_print}    ERR/

*** Test Cases ***
[1]CB009331-B_09_General_SiSo_Auto_basic_L3call_NR_100MHz+3xLTE_20MHz
    [Tags]    CRT    CB009331
    [Setup]    Case Setup for 9331
#    BTS_site_reset accord release for 9331
    Reboot cpe for test for T788    ue_index=${0}
    Sleep    5min
    Run keyword and ignore error    Single UE Attach And Send Traffic
    RU Lock And Unlock
    sleep    80s
    Run keyword and ignore error    Single UE Attach And Send Traffic
    [Teardown]    Case Teardown

[1]TDD mMIMO Chile AEHC Concurrent_MUMIMO_enabled_4UE
    [Tags]    CRT    CB0010867
    [Setup]    Case Setup
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/10867_case2.xml
    Reboot cpe for test for T788    ue_index=${0}
    Sleep    5min
    Run keyword and ignore error    Single UE Attach And Send Traffic
    RU Lock And Unlock
    sleep    80s
    Run keyword and ignore error    Single UE Attach And Send Traffic
    [Teardown]    Case Teardown

[1]TDD mMIMO Chile AEHC 5GNR Only 3 multiply 3CC_90M_16D8U_50M_8D4U_10M_8D4U_2ABIO_3sectors_L3_Call_TSN
    [Tags]    CRT    CB0010370
    [Setup]    Case Setup for 10370
    Reboot cpe for test for T788    ue_index=${0}
    Sleep    5min
    Run keyword and ignore error    Single UE Attach And Send Traffic     pci=822    i=7
    RU Lock And Unlock many times
    sleep    80s
    Run keyword and ignore error    Single UE Attach And Send Traffic     pci=822    i=7
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    Set Test Variable     ${version}     ${result}[0]

Case Setup for 9331
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/9331_case1.xml
    robot_common_operations.Common Case Setup

Case Setup for 10370
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/10370_case3.xml
    robot_common_operations.Common Case Setup

BTS_site_reset accord release for 9331
    Run keyword and ignore error    Start Btslog Collect
    Run Keyword And Continue On Failure    BTS reset many times for 9331
    Sleep     10min
    Run keyword and ignore error    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    Save Coam Snapshot
    check syslog print    log_prefix=syslog_files    path=${TS_CASE_LOG_PATH}/btslog
    ...     log_path=${TS_CASE_LOG_PATH}    need_fail_case=${False}    target_print=${check_print}
    Connect to Common Unit Master
    Connect to gnb coam via ssl

BTS reset many times for 9331
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        Connect to Common Unit Master
        Connect to gnb coam via ssl
        Set Global Variable    ${TEST_LOOP}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset for 9331
        sleep    5min
        Run Keyword And Continue On Failure    COAM Wait for gnb ready and cell setup and sync status
        Run keyword and ignore error    COAM Teardown gnb connections
        Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    END

Perform BTS Site Reset for 9331
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Run Keyword And Continue On Failure    selenium_coam.reset_site     with_graceful=${False}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_coam.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${OUTPUT DIR}
    sleep    2min
    [Teardown]  COAM selenium logout

Case Teardown
    Run keyword and ignore error    Multi UE Stop Traffic
    robot_common_operations.Common Case Teardown
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run Keyword If    '${version}' == 'SBTS26R1'    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/SCF_trunk_788_golden.xml
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Single UE Attach And Send Traffic
    [Arguments]    ${ul_tp}=200M    ${dl_tp}=1500M    ${duration}=3000    ${pci}=817    ${i}=1
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[${i}]
    log to console    \n***Prepare UE_0***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    Run keyword and ignore error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}     log_type=Iperf    pci=${pci}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${0}
    ...                       process_num=5
#    &{tti_log_path}    Capture TTI log
    Connect to gnb coam via ssl
    ${tti_log_path}    Run keyword and ignore error    Capture And Decode TTitrace Log
    ...     duration=1    format_tti_log=${True}
    Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}    dl_target=500    ul_target=70
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${0}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${0}

Check DL UL Throughput On Site
    [Arguments]    ${cells}    ${dl_target}=1000    ${ul_target}=80
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=2m    ignore_time=0min    ue_index=${0}
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=${dl_target}
    ...    ue_index=${0}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=${ul_target}
    ...    ue_index=${0}

Common UE Attach and traffic
    [Arguments]    ${ue_index}=${0}    ${duration}=600    ${dl_tp}=1500M    ${ul_tp}=100M    ${pci}=815
    log to console    \n***Attach UE_${ue_index}***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    log_type=Iperf    pci=${pci}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${ue_index}

Multi UE Stop Traffic
    FOR    ${ue_index}    IN RANGE    2
        log to console    \n***Stop traffic ***
        power_ue.Prepare UE    ue_type=${type}    ue_index=${ue_index}
        power_ue.Stop traffic    ue_type=${type}    direction=dl    ue_index=${ue_index}
        power_ue.Stop traffic    ue_type=${type}    direction=ul    ue_index=${ue_index}
    END

Lock Cell and Check Status
    Connect to gnb coam via ssl
    Perform cell lock via rest api    cell_idx=815
    Wait until keyword succeeds    3min    20 sec    Cell Should Be Locked    cell_idx=815    cell_group_idx=0

Unlock Cell and Check Status
    Connect to gnb coam via ssl
    Perform cell unlock via rest api    cell_idx=815
    sleep    60s
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    5min    20 sec    Cell Should Be Unlocked    cell_idx=815    cell_group_idx=0

RU Lock And Unlock
    Run keyword and ignore error    Perform RU Lock    ru_index=1
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min    20sec    RU Should Be Locked
    Run keyword and ignore error    Perform RU Unlock    ru_index=1
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min    20sec    RU Should Be Unlocked

RU Lock And Unlock many times
    Run keyword and ignore error    Start Btslog Collect
    Run Keyword And Continue On Failure    RU Lock And Unlock many times for 10370
    Sleep     10min
    Run keyword and ignore error    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    check syslog print    log_prefix=syslog_files    path=${TS_CASE_LOG_PATH}/btslog
    ...     log_path=${TS_CASE_LOG_PATH}    need_fail_case=${False}    target_print=${check_print}

RU Lock And Unlock many times for 10370
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        RU Lock And Unlock
     END

Reboot cpe for test for T788
    [Arguments]    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True
