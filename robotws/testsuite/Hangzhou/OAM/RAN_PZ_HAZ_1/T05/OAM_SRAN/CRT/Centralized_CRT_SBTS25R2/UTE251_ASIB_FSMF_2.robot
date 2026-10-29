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
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/CB006053/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot
Resource          ../SWM/CB006053/LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.robot
Resource          ../SWM/CB006053/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB006053/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource          ../SWM/SWM__SW_pre_check_insufficient_disc_space.robot
Resource          ../SWM/SWM__SW_pre_check_critical_alarm_active.robot
Resource          ../SWM/SWM__SW_post_check_successful.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
[CB006053] LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_146407         original:3_5_UTESRAN251    1st:3_5_UTESRAN251      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    ...    AND    Set Library Search Order   LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]   LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

[CB006053]LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
    [Tags]    QC_146403             original:3_5_UTESRAN251    1st:3_5_UTESRAN251      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    TC Setup
    ...    AND    Set Library Search Order    SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    [Teardown]    TC Teardown

[CB006053] LTE2866-R_01_06_ST BTS SW fallback in dual core with fault 4082
    [Tags]    QC_146402         original:3_5_UTESRAN251    1st:3_5_UTESRAN251      prio-2
    [Setup]    run keywords   NR_Switch_Open
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Setup
    ...    AND    Set Library Search Order    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082
    LTE2866-R_01_06_ST BTS SW fallback in fullcore with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Teardown_table

[CB006053] LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_146405           original:3_5_UTESRAN251    1st:3_5_UTESRAN251      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
    ...    AND    Set Library Search Order   LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    TC_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW_R3R4
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown

[CB006053] CB006053_LTE4934-C_ST_05_15_Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_146406       original:3_5_UTESRAN251    1st:3_5_UTESRAN251      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND   CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
    [Teardown]   CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

SWM__SW_pre_check_insufficient_disc_space
    [Tags]    QC_146392      original:3_5_UTE4G502    1st:3_5_UTESRAN251      prio-2
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__SW_pre_check_insufficient_disc_space
    TC__SWM__SW_pre_check_insufficient_disc_space
    [Teardown]    SWM__SW_pre_check_insufficient_disc_space.Custom Test Teardown

SWM__SW_pre_check_critical_alarm_active
    [Tags]    QC_146390        original:3_5_UTE4G502     1st:3_5_UTESRAN251      prio-2
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__SW_pre_check_critical_alarm_active
    TC__SWM__SW_pre_check_critical_alarm_active
    [Teardown]    SWM__SW_pre_check_critical_alarm_active.Custom Test Teardown

SWM__SW_post_check_successful
    [Tags]    QC_146391      original:3_5_UTE4G502     1st:3_5_UTESRAN251      prio-2
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__SW_post_check_successful
    TC__SWM__SW_post_check_successful
    [Teardown]    TC Teardown
