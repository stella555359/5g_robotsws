*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Library    xml
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
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
Resource    ../SWM/CB007500/CB007500.robot
Resource    ../SWM/CB007500/CB007500ET.robot
Resource 	  ../SWM/BOAM_ET/RP002324/Automated__FPGA_SW_Update_and_Activation.robot
Resource 	  ../SWM/BOAM_ET/RP002324/RP002324_ASIL.robot
Resource    ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot
Resource    ../SWM/CB007335/CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation.robot
Resource      ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot


*** Variables ***
${target_release}    SBTS25R1_1.0PD


#*** Test Cases ***
#HZ.OM.SU.05_01_RP002315_Software Precheck from NetAct for single SBTS
#    [Tags]    QC_848062    10_5_UTESRAN604
#    [Setup]    run keywords    hran_frame_sbts.TC Setup
#    ...    AND    Set Library Search Order    RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS
#    RP002315_05_01_Software Precheck from NetAct for single SBTS
#    [Teardown]    TC Teardown
#
#CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset_inCMplan_ASIL_DualCore
#    [Tags]    QC_848052    3_5_UTESRAN665
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation
#    ...    AND    TC Setup
#    TC_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset
#    [Teardown]    TC Teardown
#
#CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
#    [Tags]    QC_848051   3_5_UTESRAN665
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration
#    ...    AND    TC Setup
#    TC_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
#    [Teardown]    TC Teardown
#
#CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_WithoutHealthCheck
#    [Tags]    QC_848053    10_5_CLOUD602    SWM
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck
#    ...    AND    TC Setup
#    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
#    [Teardown]    TC Teardown
#
#LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Tags]    QC_848048    10_5_UTESRAN604
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order  LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
#    ...    taf.sbts.oam.coam.admin    Mrat_resource_new
#    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Teardown]    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
#
#LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Tags]    QC_848047    10_5_UTESRAN604
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND   LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082    Mrat_resource_new
#    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown
#
#LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
#    [Tags]    QC_848049    disconnect_Netact    10_5_UTESRAN604
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    TC Setup
#    ...    AND    Set Library Search Order
#    ...  SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
#    [Teardown]    TC Teardown
#
#CB007425_LTE2866-R_01_06_ST BTS SW fallback in dual core with fault 4082
#    [Tags]    QC_848044    disconnect_Netact    3_5_UTESRAN704     SWM
#    [Setup]    run keywords   NR_Switch_Open
#    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Setup
#    ...    AND    Set Library Search Order    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082
#    LTE2866-R_01_06_ST BTS SW fallback in fullcore with fault 4082
#    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Teardown_table
#
#LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
#    [Tags]    QC_848045    10_5_UTESRAN604    re
#    [Setup]    run keywords   NR_Switch_Open
#    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...  LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW    Mrat_resource_new
#    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
#    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
#
#CB009826_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
#    [Tags]    QC_848050   10_5_UTESRAN604
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
#
#CB009826_LTE4934_C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi_MRBTS
#    [Tags]    QC_848046    10_5_UTESRAN604    Need_UTE201
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB006053_LTE655
#    ...    AND    TC Setup
#    CB007425.TD.OM.LTE655_05_11_01_Remote_mass_eNB_Rollback_request
#    [Teardown]    TC Teardown
#
#CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
#    [Tags]    QC_848078      3_5_UTE4G502
#    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#    [Timeout]    3600s
#    CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
#    [Teardown]  CB007500 TC teardown
#
#CB007500_ST_05_06_Software management procedures on D&RSW
#    [Tags]    QC_848077
#    [Setup]     run keywords    set library search order    CB007500ET    AND    TC Setup
#    [Timeout]    3600s
#    CB007500_ST_05_06_Software management procedures on D&RSW
#    [Teardown]  TC teardown
#
#Automated__FPGA_SW_Update_and_Activation
#    [Tags]    QC_847954    3_5_UTE4G502
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order     Automated__FPGA_SW_Update_and_Activation
#    Automated FPGA SW Update And Activation
#   [Teardown]    Custom TC Teardown
