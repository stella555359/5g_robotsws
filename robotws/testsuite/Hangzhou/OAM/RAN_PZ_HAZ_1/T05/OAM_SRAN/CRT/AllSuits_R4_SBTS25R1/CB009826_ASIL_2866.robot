*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource      ../SWM/CB007425/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource      ../SWM/CB007425/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource      ../SWM/CB007425/LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource      ../SWM/CB007425/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot
Resource      ../SWM/CB007425/LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.robot
Resource      ../SWM/SWM__SW_post_check_RAT_status_fail.robot
Resource      ../SWM/RP002315/RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS.robot


*** Variables ***
${target_release}   SBTS25R1


#*** Test Cases ***
#CB009826_RP002315_05_01_Software Precheck from NetAct for single SBTS
#    [Tags]    QC_83716    3_5_UTESRAN665
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    TC Setup
#    RP002315_05_01_Software Precheck from NetAct for single SBTS
#    [Teardown]    TC Teardown

#CB009826_SWM__SW_post_check_RAT_status_fail
#    [Tags]    QC_848117    3_5_UTESRAN665
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    hran_frame_sbts.TC Setup
#    ...    AND    Set Library Search Order    SWM__SW_post_check_RAT_status_fail
#    TC__SWM__SW_post_check_RAT_status_fail
#    [Teardown]    SWM__SW_post_check_RAT_status_fail.Custom Test Teardown
#
#CB009826_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Tags]    QC_83714    3_5_UTESRAN665
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
#    ...    taf.sbts.oam.coam.admin
#    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Teardown]    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
#
#CB009826_LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Tags]    QC_83712    3_5_UTESRAN665
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
#    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown
#
#CB009826_LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
#    [Tags]    QC_83710    disconnect_Netact    3_5_UTESRAN665
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    TC Setup
#    ...    AND    Set Library Search Order
#    ...  SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    [Teardown]    TC Teardown
#
#CB009826_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
#    [Tags]    QC_83711    3_5_UTESRAN665
#    [Setup]    run keywords   NR_Switch_Open
#    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...  LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
#    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
#    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
