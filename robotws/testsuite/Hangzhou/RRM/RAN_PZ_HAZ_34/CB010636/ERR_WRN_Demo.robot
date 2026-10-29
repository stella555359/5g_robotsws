*** Settings ***
Suite Setup
Suite Teardown
#ERR_WRN_start
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
#ERR_WRN_end
Resource          ./Resources/CB010636_CDE.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Library           ./Resources/demo.py
Variables         ./Resources/BTS_info.py

*** Variables ***
#${UTE_logs_path}        /home/ute/ERR_WRN_logs/

*** Test Cases ***
[1]CB010636_A_01_RLC_PDU_volume_counters_SA_IGNB
    [Setup]     #Case Setup
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    sleep     3s
    Stop BTSlogs Collection And Download Logs To Log Server
    log to console      UTE_logs_path is : ${UTE_syslogs_path}
    Run Keyword And Continue On Failure      Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}
    ...      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.15      Delete_old_ERR_WRN=0
   ...       Fail_Case=False       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.7

*** Keywords ***


