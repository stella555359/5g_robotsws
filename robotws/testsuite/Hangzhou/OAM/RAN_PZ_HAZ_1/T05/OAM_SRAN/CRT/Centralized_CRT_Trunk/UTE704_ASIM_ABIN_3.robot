*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
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
Resource          ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB007425/SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource          ../HWM/LTE2508/LTE2508.robot
Resource          ../SWM/CB006053/CB006053_LTE655.robot
Resource          ../HWM/LTE4498/CB006053_LTE4498.robot
Resource          ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot
Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
CB009826_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_33452   original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order   CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    ...    Mrat_resource_new
    ...     AND     CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
    [Teardown]   CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

CB009826_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
    [Tags]    QC_33460    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    Set Library Search Order
    ...    CB007335_02_05_Health_check_before_copy_BTS_SW_and_configurationGet Software Inf
    ...     taf.nms.netact
    ...    AND    TC Setup
    TC_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
    [Teardown]    TC Teardown

CB009826_LBT5358_01_SFP monitoring in BTS SM(ADMIN)&Netact-Static Dynamic SFP Parameters
    [Tags]    QC_33463      original:3_5_UTESRAN201     1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
    ...    AND    TC setup
    LBT5358-1_CB007425
    [Teardown]    TC teardown

CB007425_LBT5358_03_Dynamic SFP parameters saved into PM counters
    [Tags]    QC_33395    original:3_5_UTESRAN201     1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
    ...    AND    TC setup
    LBT5358-3
    [Teardown]    TC teardown

CB007425_LTE4498_ST_04_Do HW inverntory upload from Netact independently form CM
    [Tags]    QC_33397       original:3_5_UTESRAN201     1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    ASMI_LTE4498_ST_04_Do HW inverntory upload from Netact independently form CM
    [Teardown]    TC teardown

CB009826_LTE4934_C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi_MRBTS
    [Tags]    QC_33456    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE655
    ...    AND    TC Setup
    CB007425.TD.OM.LTE655_05_11_01_Remote_mass_eNB_Rollback_request
    [Teardown]    TC Teardown

CB007425_LTE2508_ST_01_01_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_disabled
    [Tags]    QC_33400   original:3_5_UTESRAN201     1st:3_5_UTESRAN704     prio-3
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    LTE2508
    ...    AND    TC setup
    LTE2508_ST_01_01_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_disabled
    [Teardown]    TC teardown

CB007425_LTE2508_ST_01_02_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_enabled_and_RF_support_HW_ASMI
    [Tags]    QC_33399    original:3_5_UTESRAN201     1st:3_5_UTESRAN704     prio-3
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    LTE2508
    ...    AND    TC setup
    LTE2508_ST_01_02_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_enabled_and_RF_support_HW_ASMI
    [Teardown]    TC teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_33398    original:3_5_UTESRAN201    1st:3_5_UTESRAN704     prio-3
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown

CB009826_LTE4934-C_ST_05_17_ Flat SOAM_Software Management_SWM_Trigger NE Initiated Software Update
    [Tags]    QC_33462       original:3_5_UTESRAN201     1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    ...    Mrat_resource_new
    ...    AND    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
    TC__CB007425_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Teardown]   SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown

TC_CB006147_05_01_Lock_Unlock of [Q]SFP
    [Tags]    QC_33476    SFP    10_5_UTESRAN263
    [Setup]    run keywords    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    TC_CB006147_05_01_Lock_Unlock_of_SFP
    [Teardown]    TC Teardown
