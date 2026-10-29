*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB006536/SWM/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource          ../SWM/CB006536/SWM/CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot
Resource          ../SWM/BOAM_ET/OAM_LTE2866-R-g_SW_update_end_dueto_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid.robot
Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot


*** Variables ***
${target_release}    SBTS25R1


#*** Test Cases ***
#OAM_LTE2866-R-g_SW_update_end_due_to_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid
#    [Tags]    QC_474673        3_5_UTE4G253
#    [Setup]    run keywords    Set Library Search Order
#    ...  OAM_LTE2866-R-g_SW_update_end_dueto_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid
#    ...  taf.sbts.oam.coam.admin
#    ...    AND    TC Setup
#    OAM_LTE2866-R-g_SW_update_end_due_to_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid
#    [Teardown]     TC Teardown
#
#LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Tags]    QC_356019    SEC    3_5_UTE4G253
#    [Setup]    run keywords    Set Library Search Order    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
#    ...  taf.sbts.oam.coam.admin
#    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
#    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
#
#LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
#    [Tags]    QC_356021    SWM    3_5_UTE4G253
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    [Teardown]    TC Teardown
#
#LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Tags]    QC_356020      CRT    3_5_UTE4G253
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
#    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Teardown]    CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown
#
#LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
#    [Tags]    QC_356017      NEW    3_5_UTE4G253
#    [Setup]    run keywords    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
#    ...    AND    Set Library Search Order    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
#    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
#    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
#
#TC_CB006147_05_01_Lock_Unlock of [Q]SFP
#    [Tags]    QC_330161    SFP    3_5_UTE4G253
#    [Setup]    run keywords    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
#    ...    AND    TC Setup
#    TC_CB006147_05_01_Lock_Unlock_of_SFP
#    [Teardown]    TC Teardown
