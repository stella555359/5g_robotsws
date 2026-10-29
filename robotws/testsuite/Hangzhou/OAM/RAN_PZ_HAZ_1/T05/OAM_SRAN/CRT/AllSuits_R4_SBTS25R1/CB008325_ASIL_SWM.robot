*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
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
Resource      ../SWM/SWM__SW_post_check_RAT_status_fail.robot
Resource      ../SWM/RP002315/RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS.robot
Resource      ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot
Resource      ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot
Resource      ../SWM/SWM__SW_post_check_RAT_status_fail.robot
Resource      ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource      ../SWM/CB006536/ASIB_ASIB/SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot


*** Variables ***
${target_release}   SBTS25R1


#*** Test Cases ***
#CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
#    [Tags]    QC_83576    10_5_CLOUD602
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration
#    ...    AND    TC Setup
#    TC_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
#    [Teardown]    TC Teardown
#
#CB008325_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_WithoutHealthCheck
#    [Tags]    QC_83577    10_5_CLOUD602    SWM
#    [Setup]    run keywords    Set Library Search Order
#    ...  CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck
#    ...    AND    TC Setup
#    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
#    [Teardown]    TC Teardown
#
#CB008325_RP002315_05_01_Software Precheck from NetAct for single SBTS
#    [Tags]    QC_83580    10_5_CLOUD602    SWM    bat1
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    TC Setup
#    RP002315_05_01_Software Precheck from NetAct for single SBTS
#    [Teardown]    TC Teardown

#LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
#    [Tags]    QC_847960  10_5_CLOUD602
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006536
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

#LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback Software for multi-MRBTS
#    [Tags]    QC_681432  10_5_CLOUD602
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
#    ...    AND    Set Library Search Order    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
#    TC_SWM_rollback_Software_for_multi-MRBTS
#    [Teardown]    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown
#
#LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Tags]    QC_83578   10_5_CLOUD602    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
#    ...    taf.sbts.oam.coam.admin
#    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
#    LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
#    [Teardown]    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
#
#LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Tags]    QC_83579    10_5_CLOUD602    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
#    ...    AND    Set Library Search Order
#    ...    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
#    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
#    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown
