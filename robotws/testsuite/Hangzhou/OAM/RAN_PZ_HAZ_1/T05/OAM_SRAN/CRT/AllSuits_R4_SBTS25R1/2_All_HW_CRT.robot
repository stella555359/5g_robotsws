*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource          ../SWM/SWM__Local_SW_Update_Fallbackcause_removal.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_SWversion_not_supported.robot
Resource          ../SWM/SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF.robot
Resource          ../SWM/SWM__Local_Software_Download.robot
Resource          ../SWM/SWM__Local_Software_Activation.robot


*** Variables ***
${target_release}    SBTS25R1

#
#*** Test Cases ***
#SWM__Local_Software_Download
#    [Tags]    QC_475121     3_5_UTE4G500
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM__Local_Software_Download
#    TC__SWM__Local_Software_Download
#    [Teardown]    TC Teardown
#
#SWM__Local_Software_Activation
#    [Tags]    QC_475130    3_5_UTE4G500
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM__Local_Software_Activation
#    TC__SWM__Local_Software_Activation
#    [Teardown]    TC Teardown
#
#SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
#    [Tags]    QC_71220    3_5_UTE4G204
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
#    TC__SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
#    [Teardown]    TC Teardown
#
#SWM__Local_SW_Update_Fallbackcause_removal
#    [Tags]    QC_71228    3_5_UTE4G500
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM__Local_SW_Update_Fallbackcause_removal
#    TC__SWM__Local_SW_Update_Fallbackcause_removal
#    [Teardown]    TC Teardown
#
#SWM__Local_Software_Download_and_Activation_SWversion_not_supported
#    [Tags]    QC_71292    3_5_UTE4G500
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM__Local_Software_Download_and_Activation_SWversion_not_supported
#    TC__SWM__Local_Software_Download_and_Activation_SWversion_not_supported
#    #rollback case put here, to make sure back to lower version
#    [Teardown]    TC Teardown
#
#SWM__SW_update_for_RMOD_with_fault_23
#    [Tags]    QC_71298    3_5_UTE4G500
#    [Setup]    run keywords    SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Setup
#    ...    AND    Set Library Search Order    SWM__SW_update_for_RMOD_with_fault_23    hran_general
#    TC__SWM__SW_update_for_RMOD_with_fault_23
#    [Teardown]    SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Teardown
