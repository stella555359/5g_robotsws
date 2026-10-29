*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03

Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB013125_Robust_Common_Keyword.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
#${testline_name}    7_5_UTE5G402T901
${scf_file}    SCF_SBTS00.xml
${UTE_logs_path}    /home/ute/Case_Logs/ERR_WRN_analysis

*** Test Cases ***

[1]CB013598_robust_site_reset
    [Setup]
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog

	Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Run Keyword and Continue on Failure    Site reset 1 times

    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.1    Clear_log=True
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}
    [Teardown]    Run Keyword And Ignore error    COAM Logout

