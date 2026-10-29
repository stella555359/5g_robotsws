*** Settings ***
Documentation      author: Lixia Wang
...                 contact: lixia.wang@nokia-sbell.com
...                This robot file is for 5GC002479 C&P Subfeature -J,to be test on dual core configuration.

Suite Setup        Run Keywords    robot_common_operations.Common Suite Setup    AND    KW.TestSuilt.Start
Suite Teardown     Run Keywords    robot_common_operations.Common Suite Teardown    AND   KW.TestSuilt.Stop
Force Tags        RAN_5G  RAN_5G_TDD   STATE_SW_UPLOADED  SBTS00  SBTS22R2
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIKL_ABILB1_AHPE-ASIKR_ABILB4_AEHC    PY36
Resource           ../5GC002479/Resources/5GC002479_CP_Resource_ute.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
TEST
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    #TC.5GC002479_IA_04_OAM_KPI_2c_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
    #TC.5GC002479_AA_05_CM_Delta_Plan_Provision_Operation_No_Service_Outage
#    run keyword and ignore error     Basic.GetStreamInfo
#    run keyword and ignore error     Basic.GetStreamInfo    vstring=SBTS00_ENB_9999_210413_000018
#    run keyword and ignore error     Basic.GetStreamInfo    vstring=SBTS21A_ENB_9999_210413_000018
    log     test
################################## Following case are CRT case    ####################################################
[1]5GC002479_AJ_03_CM_Configuration_File_Backup_Dual_Core
    [Documentation]    OM_GEN_SFS_PERF_CAP.6819 in 21A.Target is 30s
    ...
    [Tags]     CRT_TRUNK    CRT_21A    C&P    CRT_21B    CRT_22R1    CRT_22R2    CRT_UTE
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND   TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_AA_03_CM_Configuration_File_Backup

[1]5GC002479_BJ_01_PM_Collection_Dual_Core
     [Documentation]    OM_GEN_SFS_PERF_CAP.7659
    ...    The duration for the PM result file creation at the BTS/DU/CU/vDU shall be <= 1 min:
    ...    - Starting condition: End of PM reporting period.
    ...    - Finishing condition: PM result file ready for upload.
     [Tags]     CRT_TRUNK    CRT_21A    C&P    CRT_21B    CRT_22R1    CRT_22R2    CRT_UTE
     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND   TestCase.Start
     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    BA_01_Teardown case
     TC.5GC002479_BA_01_PM_Collection

[1]5GC002479_CJ_01_FM_Duration_of_Alarm_Event_Reporting_Dual_Core
    [Documentation]    OM_GEN_SFS_PERF_CAP.2821
     ...    Upon the detection of an alarming condition at a BTS/DU/CU/vDU the system shall transmit the alarm information to
     ...    the NMS (NE3S) / WebEM (SOAMIF or REST) and present it in its FM user interface within 60 seconds
    [Tags]     CRT_TRUNK    CRT_21A    C&P    CRT_21B    CRT_22R1    CRT_22R2    CRT_UTE
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND   TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_CA_01_FM_Duration_of_Alarm_Event_Reporting

[1]5GC002479_DJ_01_LOG_Manual_Trigger_Snapshot_Dual_Core
    [Documentation]    OM_GEN_SFS_PERF_CAP.2836
     ...    the system shall complete the collection and upload of the troubleshooting data from the BTS/DU to the NMS/LSS/local PC
     ...    within 7 minutes for files of average size and 15 minutes for files of maximum size
    [Tags]     CRT_TRUNK    CRT_21A    C&P    CRT_21B    CRT_22R1    CRT_22R2    CRT_UTE
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND   TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_DA_01_LOG_Manual_Trigger_Snapshot

[1]5GC002479_FJ_04_WebEM_Duration_of_Login_WebEM_Application_Dual_Core
    [Documentation]    OM_GEN_SFS_PERF_CAP.10492
     ...    The WebEM application shall be able to login the operator within the times defined in the following table (in seconds):
     ...    -starting at the moment the operator initiates the login after inserting the login credentials and click the respective button
     ...    - ending at the moment the WebEM application logins the user into the full WebEM application and present the legal notice
    [Tags]     CRT_TRUNK    CRT_21A    C&P    CRT_21B    CRT_22R1    CRT_22R2    CRT_UTE
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND   TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_FA_04_WebEM_Duration_of_Login_WebEM_Application

############################ following case are for feature testing ##########################################
#[1]5GC002479_AJ_01_CM_Full_Plan_Download_Validation_Activation_Operations_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_01_CM_Full_Plan_Download_Validation_Activation_Operations
#
#[1]5GC002479_AJ_02_CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_02_CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage
#
#[1]5GC002479_AJ_04_CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_04_CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage
#
#[1]5GC002479_AJ_05_CM_Delta_Plan_Provision_Operation_No_Service_Outage_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_05_CM_Delta_Plan_Provision_Operation_No_Service_Outage
#
#[1]5GC002479_AJ_06_CM_Full_Config_Plan_Provision_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_06_CM_Full_Config_Plan_Provision
#
#[1]5GC002479_AJ_07_CM_Delta_Plan_Pre-Activate_Successful_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_07_CM_Delta_Plan_Pre-Activate_Successful
#
#[1]5GC002479_AJ_08_CM_Delta_Plan_Download_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_08_CM_Delta_Plan_Download
#
#[1]5GC002479_AJ_09_CM_Delta_Plan_Provision_Operation_Site_Service_Outage_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_09_CM_Delta_Plan_Provision_Operation_Site_Service_Outage
#
#[1]5GC002479_AJ_10_CM_Upload_CM_Configuration_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_10_CM_Upload_CM_Configuration
#
#[1]5GC002479_AJ_11_CM_Duration_of_CM_Change_Notification_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_AA_11_CM_Duration_of_CM_Change_Notification
#
#[1]5GC002479_BJ_02_PM_Retention_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_BA_02_PM_Retention
#
#[1]5GC002479_BJ_03_PM_Data_File_Size_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_BA_03_PM_Data_File_Size
#
#[1]5GC002479_BJ_04_PM_CPU_Impact_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_BA_04_PM_CPU_Impact
#
#[1]5GC002479_CJ_02_FM_Alarm_Upload_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_CA_02_FM_Alarm_Upload
#
#[1]5GC002479_DJ_02_LOG_Automatically_Triggered_Snapshot_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_DA_02_LOG_Automatically_Triggered_Snapshot
#
#[1]5GC002479_DJ_03_Remote_Syslog_Session_Start_and_Stop_Latency_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_DA_03_Remote_Syslog_Session_Start_and_Stop_Latency
#
#[1]5GC002479_FJ_01_WebEM_Memory_Consumption_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_01_WebEM_Memory_Consumption
#
#[1]5GC002479_FJ_02_WebEM_Number_of_Concurrent_WebEM_User_Sessions_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_02_WebEM_Number_of_Concurrent_WebEM_User_Sessions
#
#[1]5GC002479_FJ_03_WebEM_Duration_of_Loading_WebEM_Application_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_03_WebEM_Duration_of_Loading_WebEM_Application
#
#[1]5GC002479_FJ_05_WebEM_Duration_of_Loading_WebEM_Runtime_View_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_05_WebEM_Duration_of_Loading_WebEM_Runtime_View
#
#[1]5GC002479_FJ_06_WebEM_WebEM_Remote_Tool_User_Session_Capacity_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_06_WebEM_WebEM_Remote_Tool_User_Session_Capacity
#
#[1]5GC002479_FJ_07_WebEM_WebEM_Remote_Tool_Connection_Request_Latency_Standalone_mode_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_07_WebEM_WebEM_Remote_Tool_Connection_Request_Latency_Standalone_mode
#
#[1]5GC002479_FJ_08_WebEM_WebEM_Remote_Tool_Connection_Latency_Server_mode_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_08_WebEM_WebEM_Remote_Tool_Connection_Latency_Server_mode
#
#[1]5GC002479_FJ_09_WebEM_WebEM_Remote_Tool_Request_Latency_Server_mode_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_FA_09_WebEM_WebEM_Remote_Tool_Request_Latency_Server_mode
#
#[1]5GC002479_HJ_05_OAM_KPI_16_Cell_Lock_Unclock_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_HA_07_OAM_KPI_16_Cell_Lock_Unclock


#[1]5GC002479_IJ_04_OAM_KPI_2c_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_04_OAM_KPI_2c_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
#
#[1]5GC002479_IJ_01_SWM_Max_Duration_of_SW_Download_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_01_SWM_Max_Duration_of_SW_Download
#
#
#[1]5GC002479_IJ_05_OAM_KPI_2d_SWM_Outage_Duration_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_06_OAM_KPI_2d_SWM_Outage_Duration_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
#
#[1]5GC002479_IJ_06_OAM_KPI_2e_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade_with_RU_SW_Upgrade_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_08_OAM_KPI_2e_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade_with_RU_SW_Upgrade
#
#[1]5GC002479_IJ_09_OAM_KPI_62c_SWM_Success_Rate_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_12_OAM_KPI_62c_SWM_Success_Rate_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
#
#[1]5GC002479_IJ_10_OAM_KPI_62d_SWM_Success_Rate_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_13_OAM_KPI_62d_SWM_Success_Rate_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
#
#[1]5GC002479_IJ_11_OAM_KPI_62e_SWM_Success_Rate_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade_with_RU_SW_Upgrade_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_14_OAM_KPI_62e_SWM_Success_Rate_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade_with_RU_SW_Upgrade
#
#[1]5GC002479_IJ_12_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release
#
#[1]5GC002479_IJ_14_OAM_KPI_64_SWM_SW_Upgrade_Success_Rate_Intra_Release_Dual_Core
#    [Documentation]
#    [Tags]     C&P
#   [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
#    TC.5GC002479_IA_18_OAM_KPI_64_SWM_SW_Upgrade_Success_Rate_Intra_Release