*** Settings ***
Suite Setup    Run keywords    PCMD Coam Suite Setup    AND    robot_common_operations.Common Suite Setup
Suite Teardown     Run keywords    Suite Teardown with SCF    AND    robot_common_operations.Common Suite Teardown
Test Timeout    100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ../common/RRH_common_keyword.robot
Resource    Resources/5GC001358-D_keyword.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature 5GC001358-D in 5G22R2 program

Force Tags    STATE_SW_UPLOADED    CRT_UTE    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ASKEY_ASIBR_ABIOB4_3xAZQG    SBTS00    SBTS22R2
...    PY36    SBTS22R3

Library             taf.config.scf        WITH NAME    scf
Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli



*** Variables ***
${testline_name}    7_5_UTE5G402T924
${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}


${UE_TYPE}    askey
${UTE_logs_path}    /home/ute/Case_Logs/ERR_WRN_analysis


*** Test Cases ***
[1]TL924_robust_testing_err_wrn_check
    [Documentation]
    [Tags]
    [Setup]
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}    Login_UTE=True
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Set PA prepare
    L3 call setup for CB008124
    Start Traffic UL
    Handover and check syslog_1
    Stop Traffic UL
    L3 call detach
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    teardown for CB008124    AND
     ...    Stop btslog and check btslog

*** Keywords ***
Handover and check syslog_1
    ${range}    set variable    2
    FOR    ${i}    IN RANGE    1    ${range}
        Set PA HO from cell1 to cell2
        Set PA HO from cell2 to cell1
    END



Stop btslog and check btslog
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.1    Clear_log=True
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}

