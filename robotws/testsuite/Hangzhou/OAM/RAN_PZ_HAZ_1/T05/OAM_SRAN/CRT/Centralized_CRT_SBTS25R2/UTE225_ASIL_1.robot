*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/CB006536/SWM/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource          ../SWM/CB006536/SWM/CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource         ../SWM/RP002315/RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS.robot
Resource          ../SWM/SWM__SW_post_check_successful.robot
Resource         ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
CB008325_LTE4934-C_ST_05_15_Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_146377   original:3_5_UTE4G884      1st:3_5_UTE4G225      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND   CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software     CB006053
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

CB008325_RP002315_05_01_Software Precheck from NetAct for single SBTS
    [Tags]    QC_146374   original:10_5_CLOUD602         1st:3_5_UTE4G225      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND     Set Library Search Order     RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS
    ...    AND    TC Setup
    RP002315_05_01_Software Precheck from NetAct for single SBTS
    [Teardown]    TC Teardown

CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
    [Tags]    QC_146375      original:10_5_CLOUD602         1st:3_5_UTE4G225      prio-1
    [Setup]    run keywords    Set Library Search Order     taf.nms.netact
    ...  CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration
    ...    AND    TC Setup
    TC_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
    [Teardown]    TC Teardown

[1]CB007215_ST_05_02 Max Duration of SW Post-check - single BTS
    [Tags]    QC_146373   original:10_5_CLOUD602      1st:3_5_UTE4G225      prio-1
    [Setup]    run keywords    Set Library Search Order   SWM__SW_post_check_successful
    ...    AND    TC Setup
    TC__SWM__SW_post_check_successful
    [Teardown]    TC Teardown

LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
    [Tags]    QC_146425        original:3_5_UTE4G253    1st:3_5_UTE4G225       prio-1      pronto
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    [Teardown]    TC Teardown

LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Tags]    QC_146424        original:3_5_UTE4G253     1st:3_5_UTE4G225       prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
    ...    AND    Set Library Search Order    CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Teardown]    CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown
