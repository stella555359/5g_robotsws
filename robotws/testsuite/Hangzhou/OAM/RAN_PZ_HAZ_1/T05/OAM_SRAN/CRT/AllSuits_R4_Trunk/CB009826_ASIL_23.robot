*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup    #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007425/SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource          ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
CB009826_LBT5358_01_SFP monitoring in BTS SM(ADMIN)&Netact-Static Dynamic SFP Parameters
    [Tags]    QC_33463    3_5_UTESRAN665    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
    ...    AND    TC setup
    LBT5358-1_CB007425
    [Teardown]    TC teardown

CB009826_LTE4934-C_ST_05_17_ Flat SOAM_Software Management_SWM_Trigger NE Initiated Software Update
    [Tags]    QC_33462   3_5_UTESRAN201    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
    ...    AND    Set Library Search Order    SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    TC__CB007425_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Teardown]    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown
