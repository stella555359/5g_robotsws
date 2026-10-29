*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.robot


*** Variables ***
${target_release}    SBTS25R3_1.0PD

#
#*** Test Cases ***
#[CB007821] CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
#    [Tags]    QC_848030    0610    3_5_UTE4G243
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
#    LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
#    [Teardown]    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.TC_Custom Teardown
