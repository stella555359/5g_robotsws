*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1

Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007010/CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data.robot
Resource          ../SWM/CB007010/CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1.robot


*** Variables ***
${target_release}    SBTS25R3

#
#*** Test Cases ***
#CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data
#    [Tags]    QC_552985
#    [Setup]   Run Keywords   TC Setup
#    ...    AND    Set Library Search Order    CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data
#    TC_CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data
#    [Teardown]    TC Teardown
#
#CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1
#    [Tags]    QC_552986
#    [Setup]   Run Keywords   TC Setup
#    ...    AND    Set Library Search Order    CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1
#    TC_CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1
#    [Teardown]    Customs TearDown
