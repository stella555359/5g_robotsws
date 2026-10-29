*** Settings ***
Documentation     [PURPOSE]
Suite Setup          hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007425/LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.robot
Resource          ../SWM/CB007425/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB007425/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource          ../SWM/CB007425/LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource          ../SWM/CB007425/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
CB007425_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_33387    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order   LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...      Mrat_resource_new
    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

CB007425_LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Tags]    QC_33386    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...      AND    Set Library Search Order   LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
    ...     Mrat_resource_new    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown

CB007425_LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
    [Tags]    QC_33388     original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order     taf.sbts.oam.coam.admin     taf.nms.netact
    ...    SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    ...    AND    TC Setup
    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    [Teardown]    TC Teardown

CB007425_LTE2866-R_01_06_ST BTS SW fallback in dual core with fault 4082
    [Tags]    QC_33389   original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords   NR_Switch_Open
    ...    AND    Set Library Search Order   LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082
    ...     taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in fullcore with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Teardown_table

CB007425_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_33390    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords   NR_Switch_Open
    ...    AND    Set Library Search Order
    ...    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    ...     Mrat_resource_new    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
