*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/CB006053/LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource          ../SWM/CB006053/CB006053_LTE655.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
[CB006053] LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Tags]    QC_33333         original:3_5_UTESRAN251    1st:3_5_UTESRAN251      prio-1
    [Setup]    run keywords      NR_Switch_Open
    ...    AND       Set Library Search Order    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
    ...     Mrat_resource_new
    ...    AND     LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Teardown]     LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown

[CB006053]LTE4934-C_ST_05_16_Flat SOAM_Software Management_SWM_rollback Software for multi-MRBTS
    [Tags]    QC_33329    original:3_5_UTESRAN251     1st:3_5_UTESRAN251      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE655
    ...    AND    TC Setup
    CB006053.TD.OM.LTE655_05_11_01_Remote_mass_eNB_Rollback_request
    [Teardown]    TC Teardown
