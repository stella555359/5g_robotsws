*** Settings ***
Documentation
...    author: zhang lusha
...    contact: lusha.zhang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007501_CB007503/Resource/CB007501_CB007503_resource.robot

Library    BuiltIn
Library    Collections


*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ue_type}    ${tl.ues[0].capabilities[2]}      
${BASIC_PATH_5G}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
${UTE_syslogs_path}   /home/ute

*** Keywords ***
CB006915 Start Syslog
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    sleep     2s


CB006915 Stop Syslog And Check ERR WRN
    Stop BTSlogs Collection And Download Logs To Log Server
    log to console      UTE_logs_path is : ${UTE_syslogs_path}
    Run Keyword And Continue On Failure      Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}
    ...      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.08      Delete_old_ERR_WRN=1
   ...       Fail_Case=False       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.7