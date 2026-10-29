*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot

Resource    ../SWM/CB006053/LTE2866-R_01_06_ST_BTS_SW_fallback_in_fullcore_with_fault_4082.robot
Resource    ../SWM/CB006053/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource    ../SWM/CB006053/SWM__DC_Fallback_SBTS_sOAM_to_SBTS_sOAM_IMS_corruption_consistent_IM_sync_failed.robot
Resource          ../SWM/BOAM_ET/RP002324/Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot
Resource          ../SWM/CB007500/CB007500.robot
Resource          ../SWM/CB007500/CB007500ET.robot
Resource          ../SWM/BOAM_ET/RP002324/RP002324_ASIL.robot


*** Variables ***
${target_release}    SBTS25R2


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

Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
    [Tags]    QC_475196        original:3_5_UTE4G502    1st:3_5_UTE4G243     prio-2
    [Setup]    run keywords       Set Library Search Order
    ...    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
    ...    AND     TC Setup
    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
   [Teardown]    TC Teardown

CB007500_ET_05_04_Execute shell script to trigger configuration reset
    [Tags]    QC_547595     original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    set library search order    CB007500     CB007500ET    taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    CB007500_ET_05_04_Execute shell script to trigger configuration reset
    [Teardown]  TC teardown
