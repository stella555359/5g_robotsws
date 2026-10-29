*** Settings ***
Documentation     [PURPOSE]
Suite Setup          hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS26R1    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
#Resource          ../SWM/CB007425/LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.robot
Resource          ../SWM/CB007425/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB007425/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource          ../SWM/CB007425/LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource          ../SWM/CB007425/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot
Resource          ../SWM/SWM__SW_post_check_RAT_status_fail.robot
Resource          ../SWM/CB007944/CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space.robot
Resource          ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot
Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot


*** Variables ***
${target_release}    SBTS26R1


*** Test Cases ***
#CB009826_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Tags]    QC_33451    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order   LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
#    ...    taf.sbts.oam.coam.admin     taf.nms.netact
#    ...      Mrat_resource_new
#    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Teardown]    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
#
#CB009826_LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Tags]    QC_33454    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords    NR_Switch_Open
#    ...      AND    Set Library Search Order   LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
#    ...     Mrat_resource_new    taf.sbts.oam.coam.admin     taf.nms.netact
#    ...    AND    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown
#
#CB009826_LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
#    [Tags]    QC_33453     original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order     taf.sbts.oam.coam.admin     taf.nms.netact
#    ...    SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    ...    AND    TC Setup
#    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    [Teardown]    TC Teardown
#
#CB008325_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_WithoutHealthCheck
#    [Tags]    QC_33393   original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords    Set Library Search Order     taf.sbts.oam.coam.admin     taf.nms.netact
#    ...    CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHealthCheck
#    ...    AND    TC Setup
#    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
#    [Teardown]    TC Teardown
##CB007425_LTE2866-R_01_06_ST BTS SW fallback in dual core with fault 4082
#    [Tags]    QC_33389   original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords   NR_Switch_Open
#    ...    AND    Set Library Search Order   LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082
#    ...     taf.sbts.oam.coam.admin     taf.nms.netact
#    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_06_ST BTS SW fallback in fullcore with fault 4082
#    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Teardown_table

CB009826_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_252026    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords   NR_Switch_Open
    ...    AND    Set Library Search Order
    ...    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    ...     Mrat_resource_new    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown

#CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space
#    [Tags]    QC_33295    original:10_5_UTESRAN264     1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order  CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space
#    ...    taf.sbts.oam.coam.admin     taf.nms.netact
#    ...    AND    TC Setup
#    TC_CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_spac
#    [Teardown]    TC Teardown
##
#CB009826_CB007944_ST_05_05_sw precheck succeed on Netact when there is not enough space in passive disk
#    [Tags]    QC_33459    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order   CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space
#    ...    taf.sbts.oam.coam.admin     taf.nms.netact
#    ...    AND    TC Setup
#    TC_CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_spac
#    [Teardown]    TC Teardown
#
#CB009826_SWM__SW_post_check_RAT_status_fail
#    [Tags]    QC_33458    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    SWM__SW_post_check_RAT_status_fail     taf.sbts.oam.coam.admin     taf.nms.netact
#    ...    AND    hran_frame_sbts.TC Setup
#    TC__SWM__SW_post_check_RAT_status_fail
#    [Teardown]    SWM__SW_post_check_RAT_status_fail.Custom Test Teardown
