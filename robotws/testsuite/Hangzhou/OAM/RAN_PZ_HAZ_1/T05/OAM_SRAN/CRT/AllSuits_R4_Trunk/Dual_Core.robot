*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1  robot:no-dry-run

Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB006053/LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.robot
Resource    ../SWM/CB006053/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource    ../SWM/CB006053/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
[CB006053]LTE2866-R_01_07_ST BTS SW fallback in dual core with fault 4083
    [Tags]    QC_33324    disconnect_Netact     bat3    10_5_CLOUD602
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    TC Setup
    ...    AND    Set Library Search Order
    ...  SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    TC__SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed
    [Teardown]    TC Teardown

[CB006053] LTE2866-R_01_06_ST BTS SW fallback in dual core with fault 4082
    [Tags]    QC_33322    disconnect_Netact     bat3    10_5_CLOUD602
    [Setup]    run keywords   NR_Switch_Open
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Setup
    ...    AND    Set Library Search Order    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082
    LTE2866-R_01_06_ST BTS SW fallback in fullcore with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.TC_Custom Teardown_table

[CB006053] LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    [Tags]    QC_33323     bat2    10_5_CLOUD602
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    ...    AND    Set Library Search Order    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
