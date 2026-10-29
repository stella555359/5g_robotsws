*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot
Resource          ../SWM/BOAM_ET/OAM_LTE2866-R-g_SW_update_end_dueto_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid.robot
Resource          ../SWM/CB007821/CB007821_CB006147_SFP_QSFP_control.robot
Resource          ../SWM/CB007010/CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data.robot
Resource          ../SWM/CB007010/CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1.robot
Resource          ../HWM/LTE4498/CB006053_LTE4498.robot
Resource          ../SWM/Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource          ../SWM/5_All_HW_ET/LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio.robot
Resource          ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot
Resource          ../SWM/CB007425/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
OAM_LTE2866-R-g_SW_update_end_due_to_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid
    [Tags]    QC_136370       original:3_5_UTE4G253     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    Set Library Search Order
    ...    OAM_LTE2866-R-g_SW_update_end_dueto_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid
    ...    taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    OAM_LTE2866-R-g_SW_update_end_due_to_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid
    [Teardown]     TC Teardown

CB008325_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_WithoutHealthCheck
    [Tags]    QC_146376      original:3_5_UTESRAN602    1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    Set Library Search Order
    ...  CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck
    ...    AND    TC Setup
    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
    [Teardown]    TC Teardown

CB006536_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_146378       original:3_5_UTE4G253      1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    Set Library Search Order
    ...    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...    taf.sbts.oam.coam.admin
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_146426      original:3_5_UTESRAN602     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...    taf.sbts.oam.coam.admin
    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_146427          original:3_5_UTE4G253      1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords   Set Library Search Order
    ...    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    ...    AND    NR_Switch_Open
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown

OAM LTE2866-R-g SW Update fails in dual core mode due to SW distribution failure to radio connected to the secondary core Log
    [Tags]    QC_146369    original:3_5_UTE4G225      1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    Set Library Search Order   LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio
    ...    AND    LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio.TC_Custom Setup
   TC LTE2866-R-g SW Update Fail With SW Distribution To Radio
    [Teardown]   LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio.TC_Custom Teardown

CB009469_LBT5358_01_SFP monitoring in BTS SM(ADMIN)&Netact-Static Dynamic SFP Parameters
    [Tags]    QC_146496     original:3_5_UTE4G253      1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
    ...    AND    TC setup
    LBT5358-1_CB007425
    [Teardown]    TC teardown

CB006147_05_01_Lock_Unlock of [Q]SFP
    [Tags]    QC_146495    original:10_5_UTESRAN286     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    TC Setup
    CB007821_CB006147_SFP_QSFP_control.TC CB006147 05 01 Lock Unlock Of SFP
    [Teardown]    TC Teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_146494    original:10_5_UTESRAN286     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND   TC Setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown

CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data
    [Tags]    QC_146479     original:3_5_UTE4G253     1st:3_5_UTE4G225      prio-2
    [Setup]   Run Keywords   Set Library Search Order    CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data
    ...    AND    TC Setup
    TC_CB007010_ST_HWM_05_01_Upload_Actual_Configuration_and_State_Data
    [Teardown]    TC Teardown

CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1
    [Tags]    QC_146480     original:3_5_UTE4G253      1st:3_5_UTE4G225      prio-2
    [Setup]   Run Keywords   Set Library Search Order
    ...    CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1
    ...    AND    TC Setup
    TC_CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1
    [Teardown]    Customs TearDown

Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]    QC_146483   original:3_5_UTESRAN704     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    ...    AND    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
    TC__Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Teardown]    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown
