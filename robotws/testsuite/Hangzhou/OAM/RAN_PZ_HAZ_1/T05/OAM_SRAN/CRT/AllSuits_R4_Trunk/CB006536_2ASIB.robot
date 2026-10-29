*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB006536/ASIB_ASIB/CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource    ../SWM/CB006536/SWM/CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource    ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource    ../SWM/CB006536/ASIB_ASIB/SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot
Resource    ../SWM/LTE4934-C/LTE4934-C-a_1_2.robot
Resource    ../SWM/LTE4934-C/LTE4934-C-d_1_3.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
CB006536_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_33351  3_5_UTESRAN232
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006536
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

CB006536_LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Tags]    QC_33354  3_5_UTESRAN232  123
    [Setup]    run keywords    NR_Switch_Open
    ...    AND  CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
    ...    AND  Set Library Search Order  CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082
    LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Teardown]    CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown

CB006536_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_33352  3_5_UTESRAN232
    [Setup]    run keywords    Set Library Search Order
    ...  CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082   taf.sbts.oam.coam.admin
    ...  AND    CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

CB006536_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback_Software_for_multi-MRBTS
    [Tags]    QC_334343  3_5_UTESRAN232
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
    ...    AND    Set Library Search Order    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    TC_SWM_rollback_Software_for_multi-MRBTS
    [Teardown]    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown
