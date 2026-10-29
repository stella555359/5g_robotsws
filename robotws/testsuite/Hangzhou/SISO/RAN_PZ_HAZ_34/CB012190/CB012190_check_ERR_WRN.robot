*** Settings ***

Documentation
...   author: shushu huang
...   squad group: MMW_SG3
...   Feature CB012190

Suite Setup
Suite Teardown     Run keywords        Scf commission
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB012190_Robust_Common_Keyword.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${testline_name}    7_5_UTE5G402T904
${scf_file}    SCF_SBTS00.xml
${UTE_logs_path}    /home/ute/Case_Logs/ERR_WRN_analysis

*** Test Cases ***
[1]CB012190_General_robust_testing_err_wrn_check
    [Setup]    robot_common_operations.Common Case Setup
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Scf commission and wait on-air    scf_name=SCF_CB012190_2CC_ERR_WRN.xml
    Conect to DU COAM
    Modify the normal cell to slim cell 49.5MHz    key_dl=slimRfFilterDL    key_ul=slimRfFilterUL    value=49.5MHz    cell_ID=2
    Collect snapshot logs for check soap info
    Extract Permanent from snapshot     snapshot_file=${TS_CASE_LOG_PATH}/Snapshot.zip
    Check Soap log    distName=NR10044.RX2_1_6    expected_bandwidth=49500000
    Check Soap log    distName=NR10044.RX1_1_6    expected_bandwidth=49500000
    attach power ue
    start power ue traffic dl      dl_throughput=310M
    sleep    30s
    stop multi power ue traffic ul and dl
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND     COAM Logout    AND
     ...    Stop btslog and check btslog


