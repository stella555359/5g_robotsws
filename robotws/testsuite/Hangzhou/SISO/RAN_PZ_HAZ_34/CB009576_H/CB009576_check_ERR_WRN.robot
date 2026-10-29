*** Settings ***
Suite Setup
Suite Teardown     Run keywords        Scf commission
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB009576_Robust_Common_Keyword.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${testline_name}    7_5_UTE5G402T2068
${scf_file}    SCF_SBTS00.xml
${UTE_logs_path}    /home/ute/Case_Logs/ERR_WRN_analysis

*** Test Cases ***
[1]TL2068_General_robust_testing_err_wrn_check
    [Setup]    robot_common_operations.Common Case Setup
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    sleep    60s
    Scf commission and wait on-air    scf_name=SCF_SBTS00_check_err_wrn.xml
	sleep    60s
    [Teardown]    Run Keyword And Ignore error   Stop btslog and check btslog

