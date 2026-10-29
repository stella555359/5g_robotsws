*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot
Resource    ../SWM/CB007335/CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation.robot
Resource    ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource    ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot
#Resource    ../SWM/CB007944/CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space.robot
Resource    ../SWM/CB007944/CB007944_ST_05_05_sw_precheck_succeed_on_Netact_when_there_is_not_enough_space_in_passive_disk.robot


*** Variables ***
${target_release}    SBTS25R1


#*** Test Cases ***
#CB008325_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset_inCMplan_ASIL_DualCore
#    [Tags]    QC_848052    3_5_UTESRAN704
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation
#    ...    AND    TC Setup
#    TC_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset
#    [Teardown]    TC Teardown
#
#CB008325_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
#    [Tags]    QC_848051    3_5_UTESRAN704
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration
#    ...    AND    TC Setup
#    TC_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
#    [Teardown]    TC Teardown
#
#CB008325_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
#    [Tags]    QC_848050   3_5_UTESRAN704
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
#
#CB008325_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_WithoutHealthCheck
#    [Tags]    QC_848053    3_5_UTESRAN704    SWM
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck
#    ...    AND    TC Setup
#    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
#    [Teardown]    TC Teardown
