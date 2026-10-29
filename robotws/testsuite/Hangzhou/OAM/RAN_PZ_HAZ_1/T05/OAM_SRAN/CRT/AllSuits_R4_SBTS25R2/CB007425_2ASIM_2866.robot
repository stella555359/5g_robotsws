*** Settings ***
Documentation     [PURPOSE]
Suite Setup          hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007425/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***

CB007425_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_146447    original:3_5_UTESRAN704    1st:3_5_UTESRAN704     prio-2
    [Setup]    run keywords   NR_Switch_Open
    ...    AND    Set Library Search Order
    ...    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    ...     Mrat_resource_new    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
