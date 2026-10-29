*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB006536/SWM/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource          ../SWM/CB006536/SWM/CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_330185    SEC    3_5_UTE4G884
    [Setup]    run keywords    Set Library Search Order    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...  taf.sbts.oam.coam.admin
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_330184      NEW    3_5_UTE4G884
    [Setup]    run keywords    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup
    ...    AND    Set Library Search Order    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
