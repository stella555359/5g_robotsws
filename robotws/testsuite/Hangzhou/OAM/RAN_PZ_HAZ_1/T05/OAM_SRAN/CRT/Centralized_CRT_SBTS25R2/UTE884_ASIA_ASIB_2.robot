*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/RP00913/RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW.robot
Resource          ../SWM/SWM__Local_SW_Update_Fallbackcause_removal.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_SWversion_not_supported.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot
Resource          ../SWM/SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF.robot
Resource          ../SWM/SWM__Local_Software_Download.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/RP00913/RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS.robot
Resource          ../SWM/RRM_SWM_ASMI/RRM_Airscale_Reset_BTS_after_SW_update_successfully.robot
Resource          ../SWM/RRM_SWM_ASMI/RRM_Airscale_Reset_BTS_after_SW_update_successfully.robot
Resource         ../SWM/CB007425/LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource          ../SWM/SWM__SW_post_check_RAT_status_fail.robot
Resource            ../SWM/CB006536/ASIB_ASIB/SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot
Resource          ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
SWM__SBTS_upgrade_fails_due_to_hash_verification_failure_for_downloaded_software_file
    [Tags]    QC_146413     original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order    RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC_RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS
    [Teardown]    TC Teardown

SWM__Local_Software_Download
    [Tags]    QC_amli      original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-3
    [Setup]    run keywords  Set Library Search Order    SWM__Local_Software_Download     taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC__SWM__Local_Software_Download
    [Teardown]    TC Teardown

SWM__Local_SW_Update_Fallbackcause_removal
    [Tags]    QC_146388    original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order    SWM__Local_SW_Update_Fallbackcause_removal    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC__SWM__Local_SW_Update_Fallbackcause_removal
    [Teardown]    TC Teardown

LTE655-a_RRM_Airscale_FDD_EDA_CAS-55561-R0L0_Reset BTS after SW update successfully
    [Tags]    QC_146396    original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords        Set Library Search Order    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    [Teardown]    TC Teardown

SWM__Local_Software_Download_and_Activation_SWversion_not_supported
    [Tags]    QC_146393    original:3_5_UTE4G500      1st:3_5_UTE4G884      prio-3
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__Local_Software_Download_and_Activation_SWversion_not_supported
    TC__SWM__Local_Software_Download_and_Activation_SWversion_not_supported
    #rollback case put here, to make sure back to lower version
    [Teardown]    TC Teardown

SWM__SBTS_Signed_SW_SignedSWtoUnSignedSW
    [Tags]    QC_146414     original:3_5_UTE4G500      1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order    RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND   TC Setup
    TC_RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW
    [Teardown]    TC Teardown

SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    [Tags]    QC_146389    3_5_UTE4G204      1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords   Set Library Search Order    SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC__SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    [Teardown]    TC Teardown

CB008325_LTE4934-C_ST_05_16_Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_146380      original:3_5_UTE4G884      1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords      Set Library Search Order    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND   NR_Switch_Open
    ...    AND  SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
    TC_SWM_rollback_Software_for_multi-MRBTS
    [Teardown]    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown

LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Tags]    QC_146379    original:3_5_UTESRAN602    1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords     Set Library Search Order
    ...    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    NR_Switch_Open
    ...    AND     LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown

CB007425_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_146418    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...  taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

CB007425_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_146417    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords     Set Library Search Order    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND     NR_Switch_Open
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup

    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown

LTE1685-A Autonomous removal of Neighbor eNBs and Neighbor Cells - basic scenario
    [Tags]    QC_146478    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    Set Library Search Order    SWM__Local_Software_Download    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND   TC Setup
    TC__SWM__Local_Software_Download
    [Teardown]    TC Teardown
