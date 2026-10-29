*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup    #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007425/SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource        ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot
#Resource          ../HWM/CB007215/CB007425_CB007215.robot
Resource          ../HWM/LTE2508/LTE2508.robot
Resource          ../HWM/LTE4498/CB006053_LTE4498.robot
Resource          ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
#CB007425_CB007215_ST_HWM_05_01 Duration of HW Inventory Change Notification for single BTS
#    [Tags]    QC_468103   3_5_UTESRAN201    HWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB007425_CB007215
#    ...    AND    TC Setup
#    CB007215_ST_HWM_05_01 Duration of HW Inventory Change Notification for single BTS
#    [Teardown]    TC Teardown

CB007425_LTE2508_ST_01_01_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_disabled
    [Tags]    QC_468089   3_5_UTESRAN201    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    LTE2508
    ...    AND    TC setup
    LTE2508_ST_01_01_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_disabled
    [Teardown]    TC teardown

CB007425_LTE2508_ST_01_02_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_enabled_and_RF_support_HW_ASMI
    [Tags]    QC_468091    3_5_UTESRAN201    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    LTE2508
    ...    AND    TC setup
    LTE2508_ST_01_02_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_enabled_and_RF_support_HW_ASMI
    [Teardown]    TC teardown

CB007425_LTE4498_ST_04_Do HW inverntory upload from Netact independently form CM
    [Tags]    QC_468101   3_5_UTESRAN201    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    ASMI_LTE4498_ST_04_Do HW inverntory upload from Netact independently form CM
    [Teardown]    TC teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_468100    3_5_UTESRAN201    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown

CB007425_LBT5358_01_SFP monitoring in BTS SM(ADMIN)&Netact-Static Dynamic SFP Parameters
    [Tags]    QC_677029    3_5_UTESRAN201    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
    ...    AND    TC setup
    LBT5358-1_CB007425
    [Teardown]    TC teardown

CB007425_LBT5358_03_Dynamic SFP parameters saved into PM counters
    [Tags]    QC_677030    3_5_UTESRAN201    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
    ...    AND    TC setup
    LBT5358-3
    [Teardown]    TC teardown

CB007425_LTE4934-C_ST_05_17_ Flat SOAM_Software Management_SWM_Trigger NE Initiated Software Update
    [Tags]    QC_467997   3_5_UTESRAN201    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
    ...    AND    Set Library Search Order    SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    TC__CB007425_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Teardown]    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown
