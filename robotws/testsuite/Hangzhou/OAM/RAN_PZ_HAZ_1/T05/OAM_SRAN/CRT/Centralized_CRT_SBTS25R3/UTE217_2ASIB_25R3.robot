*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../SWM/CB006536/ASIB_ASIB/CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource    ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource    ../SWM/CB006536/ASIB_ASIB/SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot
Resource    ../HWM/LTE4498/Dualcore_LTE4498.robot
Resource          ../SWM/RRM_SWM_ASMI/RRM_Airscale_Reset_BTS_after_SW_update_successfully.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot

*** Variables ***
${target_release}    SBTS25R3


*** Test Cases ***
Downgrade_To_SBTS25R3
    [Tags]    QC_amli
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND   Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    Run keyword and ignore error    Change parameter to disconnect netact with BTS
    prepare lower build on SBTS    sw_release=25R3    target_path=/home/ute/btsauto/
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
CB006536_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_204109  feature:6056  original:3_5_UTESRAN232  1st:3_5_UTE4G217  Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006536
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown


CB006536_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback_Software_for_multi-MRBTS
    [Tags]    QC_204107  feature:6056  original:3_5_UTESRAN232  1st:3_5_UTE4G217  Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
    ...    AND    Set Library Search Order    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    TC_SWM_rollback_Software_for_multi-MRBTS
    [Teardown]    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown


LTE655-a_RRM_Airscale_FDD_EDA_CAS-55561-R0L0_Reset BTS after SW update successfully
    [Tags]    QC_204082    original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords        Set Library Search Order    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    [Teardown]    TC Teardown
CB007425_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_204104    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order
    ...    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...  taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

CB007425_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_204103    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords     Set Library Search Order    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND     NR_Switch_Open
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup

    TC_LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown
