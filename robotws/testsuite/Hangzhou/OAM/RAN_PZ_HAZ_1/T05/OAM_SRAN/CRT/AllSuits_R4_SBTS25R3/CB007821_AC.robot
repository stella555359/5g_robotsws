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
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.robot
Resource          ../SWM/CB007821/CB007821_CB006147_SFP_QSFP_control.robot


*** Variables ***
${target_release}   SBTS25R3


#*** Test Cases ***
#[CB007821] CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    [Tags]    QC_684680    0610    3_5_UTE4G243
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    [Teardown]    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

#[CB007821] CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
#    [Tags]    QC_684684    0610    3_5_UTE4G243
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
#    LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
#    [Teardown]    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown

#[CB007821] CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
#    [Tags]    QC_83634    0610    3_5_UTE4G243
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
#    LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
#    [Teardown]    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.TC_Custom Teardown

#[CB007821] CB007821_CB006147_SFP_QSFP_control
#    [Tags]    QC_416820    0611    3_5_UTE4G243
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    TC Setup
#    ...    AND    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
#    TC_CB006147_05_01_Lock_Unlock_of_SFP
#    [Teardown]    TC Teardown
