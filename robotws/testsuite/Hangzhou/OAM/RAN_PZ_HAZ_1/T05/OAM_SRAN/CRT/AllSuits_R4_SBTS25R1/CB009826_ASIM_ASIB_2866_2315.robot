*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
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
Resource      ../SWM/CB006053/CB006053_LTE655.robot
Resource      ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource      ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot
Resource      ../SWM/SWM__SW_post_check_RAT_status_fail.robot
Resource      ../SWM/RP002315/RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS.robot
Resource      ../SWM/CB007500/CB007500ET.robot


*** Variables ***
${target_release}    SBTS25R1


#*** Test Cases ***
#CB007500_ST_05_06_Software management procedures on D&RSW
#    [Tags]    QC_83676
#    [Setup]     run keywords    set library search order    CB007500ET    AND    TC Setup
#    ${release}=    Evaluate    "${target_release}"[4:]
#    ${SWRelease}    taf.sbts.oam.coam.admin.get_sw_release_name
#    run keyword if    '${SWRelease}'!='${target_release}'    prepare pre release build on SBTS    ${release}    ${SW_path_T2_package}
#    [Teardown]  TC teardown
#
#CB009826_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Tags]    QC_83727    10_5_UTESRAN604
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
#    ...    taf.sbts.oam.coam.admin    Mrat_resource_new
#    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Teardown]    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
#
#CB009826_LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Tags]    QC_83728    10_5_UTESRAN604    re
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082    Mrat_resource_new
#    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown
#
#CB009826_LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
#    [Tags]    QC_83725    disconnect_Netact    10_5_UTESRAN604
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    TC Setup
#    ...    AND    Set Library Search Order
#    ...  SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    [Teardown]    TC Teardown
#
#CB009826_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
#    [Tags]    QC_83724    10_5_UTESRAN604
#    [Setup]    run keywords   NR_Switch_Open
#    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...  LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW    Mrat_resource_new
#    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
#    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
#
#CB009826_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
#    [Tags]    QC_83729   10_5_UTESRAN604    re
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
#
#CB009826_LTE4934_C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi_MRBTS
#    [Tags]    QC_83726    10_5_UTESRAN604    Need_UTE201    re
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB006053_LTE655
#    ...    AND    TC Setup
#    CB007425.TD.OM.LTE655_05_11_01_Remote_mass_eNB_Rollback_request
#    [Teardown]    TC Teardown
#
#CB009469_LBT5358_01_SFP monitoring in BTS SM(ADMIN)&Netact-Static Dynamic SFP Parameters
#    [Tags]     QC_83733      1st:10_5_UTESRAN604      prio-2    re
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
#    ...    AND    TC setup
#    LBT5358-1_CB007425
#    [Teardown]    TC teardown
