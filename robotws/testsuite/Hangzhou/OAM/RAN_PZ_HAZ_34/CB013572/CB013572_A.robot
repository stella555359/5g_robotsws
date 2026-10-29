*** Settings ***
Documentation      author: Ge Gao
...                contact: ge.gao@nokia-sbell.com
...                This robot file is for CB013572_SR_A C&P.

#Suite Setup       KW.TestSuilt.Start
#Suite Teardown    KW.TestSuilt.Stop
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    KW.TestSuilt.Start
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND    KW.TestSuilt.Stop
Force Tags               SG_01   5G_RAN
Resource           ../5GC002479/Resources/5GC002479_CP_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB013572_SR_A_01_CM_Delta_Plan_Download_Activation_Operations_No_Service_Outage
    [Documentation]
    [Tags]     C&P    CB013572-A     CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  AA_Teardown case
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    AA_Teardown case
    TC.5GC002479_AA_02_CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage

[1]CB013572_SR_A_02_CM_Duration_Of_Full_Plan_Download_Validation_Activation
    [Documentation]
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  AA_Teardown case
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    AA_Teardown case
    TC.5GC002479_AA_01_CM_Full_Plan_Download_Validation_Activation_Operations

[1]CB013572_SR_A_03_CM_Delta_Plan_Activation_Operations_Site_Level_Service_Outage
    [Documentation]    OM_GEN_SFS_PERF_CAP.6819 in 21A.Target is 30s
    ...
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_AA_04_CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage

[1]CB013572_SR_A_04_CM_Configuration_File_Backup
    [Documentation]
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_AA_03_CM_Configuration_File_Backup

[1]CB013572_SR_A_05_CM_Delta_Plan_Validation
    [Documentation]
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown Case
    TC.CB008181_AA_12_CM_Duration_of_Delta_Plan_Validation

[1]CB013572_SR_A_06_CM_Delta_Plan_Pre-Activate_Successful
    [Documentation]
    [Tags]     C&P    CB013572-A     CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown Case
    TC.5GC002479_AA_07_CM_Delta_Plan_Pre-Activate_Successful

[1]CB013572_SR_A_07_CM_Delta_Plan_Provision_Operation_No_Service_Outage
    [Documentation]
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_AA_05_CM_Delta_Plan_Provision_Operation_No_Service_Outage

[1]CB013572_SR_A_08_CM_Delta_Plan_Provision_Operation_Site_Service_Outage
    [Documentation]
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_AA_09_CM_Delta_Plan_Provision_Operation_Site_Service_Outage

[1]CB013572_SR_A_09_CM_Full_Config_Plan_Provision
    [Documentation]
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_AA_06_CM_Full_Config_Plan_Provision

[1]CB013572_SR_A_10_CM_Upload_CM_Configuration
    [Documentation]
    [Tags]     C&P    CB013572-A   CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.5GC002479_AA_10_CM_Upload_CM_Configuration

[1]CB013572_SR_A_11_CM_Duration_of_CM_Change_Notification
    [Documentation]
    [Tags]     C&P     CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  AA_Teardown case
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    AA_Teardown case
    TC.5GC002479_AA_11_CM_Duration_of_CM_Change_Notification

[1]CB013572_SR_A_43_CM_Duration_of_CM_Activation_Operation_RAT_Level_Service_Outage
    [Documentation]
    [Tags]     C&P    CB013572-A   CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  AA_Recovery_Teardown case
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    AA_Recovery_Teardown case
    TC.CB008962_SR_A_43_CM_Duration_of_CM_Activation_Operation_RAT_Level_Service_Outage

[1]CB013572_SR_A_44_CM_Delta_Plan_Provision_Operation_RAT_Level_Service_Outage
    [Documentation]
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  AA_Recovery_Teardown case
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    AA_Recovery_Teardown case
    TC.CB008962_SR_A_44_CM_Delta_Plan_Provision_Operation_RAT_Level_Service_Outage

[1]CB013572_SR_A_12_SWM_Duration_of_Fully_PreCheck
    [Documentation]     SWM
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    SetUp Case
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.CB008181_SR_A_12_SWM_Duration_of_Fully_PreCheck

[1]CB013572_SR_A_13_SWM_Duration_of_PostCheck
    [Documentation]     SWM
    [Tags]     C&P    CB013572-A   CNF_5G_27
#    [Setup]    SetUp Case
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.CB008181_SR_A_13_SWM_Duration_of_PostCheck

[1]CB013572_SR_A_15_SWM_Duration_of_SW_Rollback
    [Documentation]     SWM
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    SetUp Case
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.CB008181_SR_A_15_SWM_Duration_of_SW_Rollback

[1]CB013572_SR_A_16_SWM_Duration_of_Upload_SW_Configuration
    [Documentation]     SWM
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    SetUp Case
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.CB008181_SR_A_16_SWM_Duration_of_ Upload_SW_Configuration

[1]CB013572_SR_A_17_SWM_Duration_of_ Cancel_SW_Management
    [Documentation]     SWM
    [Tags]     C&P    CB013572-A    CNF_5G_27
#    [Setup]    SetUp Case
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.CB008181_SR_A_17_SWM_Duration_of_ Cancel_SW_Management

[1]CB013572_SR_A_18_SWM_Duration_of_Copy_SW_from_Active_to_Passive_Partition_Manually_Triggered
    [Documentation]     SWM
    [Tags]     C&P    CB013572-A    CNF_5G_4c   CNF_5G_23    CNF_5G_26    CNF_5G_27
#    [Setup]    SetUp Case
#    [Teardown]  TestteardownforWebEM
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
    TC.CB008181_SR_A_18_SWM_Duration_of_Copy_SW_from_Active_to_Passive_Partition_Manually_Triggered

#[1]CB013572_SR_A_28_Troubleshooting_duration_of_snapshot_collection_manually_trggered
#    [Documentation]     Troubeshooting
#    [Tags]     C&P    CB013572-A   CNF_5G_27
##    [Setup]    SetUp Case
##    [Teardown]  TestteardownforWebEM
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
#    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
#    TC.5GC002479_DA_01_LOG_Manual_Trigger_Snapshot

#[1]CB013572_SR_A_29_Troubleshooting_duration_of_snapshot_collection_automatically_trggered
#    [Documentation]     Troubeshooting
#    [Tags]     C&P    CB013572-A    CNF_5G_27
##    [Setup]    SetUp Case
##    [Teardown]  AA_Teardown case
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
#    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    AA_Teardown case
#    TC.5GC002479_DA_02_LOG_Automatically_Triggered_Snapshot

#[1]CB013572_SR_A_31_Troubleshooting_Maximum_number_of_simultaneous_DCC_user_sessions_in_the_BTS
#    [Documentation]     Troubeshooting
#    [Tags]     C&P    CB013572-A    CNF_5G_27
##    [Setup]    SetUp Case
##    [Teardown]  TestteardownforWebEM
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
#    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
#    TC.CB008181_SR_A_31_Troubleshooting_Maximum_number_of_simultaneous_DCC_user_sessions_in_the_BTS

#[1]CB013572_SR_A_32_Troubleshooting_Remote_Syslog_Session_Start_and_Stop_Latency
#    [Documentation]     Troubeshooting
#    [Tags]     C&P    CB013572-A   CNF_5G_27
##    [Setup]    SetUp Case
##    [Teardown]  TestteardownforWebEM
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
#    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestteardownforWebEM
#    TC.5GC002479_DA_03_Remote_Syslog_Session_Start_and_Stop_Latency

#[1]CB013572_SR_A_33_Troubleshooting_IP_connectivity_test
#    [Documentation]     Troubeshooting
#    [Tags]     C&P    CB013572-A    CNF_5G_27
##    [Setup]    SetUp Case
##    [Teardown]  Teardown Case
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
#    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown Case
#    TC.CB008181_SR_A_33_Troubleshooting_IP_connectivity_test

#[1]CB013572_SR_A_34_Troubleshooting_System_Module_Sanity_Checker
#    [Documentation]     Troubeshooting
#    [Tags]     C&P    CB013572-A    CNF_5G_27
##    [Setup]    SetUp Case
##    [Teardown]  Teardown Case
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp Case
#    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown Case
#    TC.CB008181_SR_A_34_Troubleshooting_System_Module_Sanity_Checker

[1]CB013572_SR_A_45_Max_Duration_of_ALD_Reset
    [Documentation]
    [Tags]     C&P    CB013572-C    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  Teardown Case
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
    TC.CB009402_SR_A_45_Max_Duration_of_ALD_Reset

[1]CB013572_SR_A_53_Max_Duration_of_GNSSE_Reset
    [Documentation]
    [Tags]     C&P    CB013572-C    CNF_5G_27
#    [Setup]    TestCase.Start_2479
#    [Teardown]  Teardown Case
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
    TC.CB013276_SR_A_53_Max_Duration_of_GNSSE_Reset
