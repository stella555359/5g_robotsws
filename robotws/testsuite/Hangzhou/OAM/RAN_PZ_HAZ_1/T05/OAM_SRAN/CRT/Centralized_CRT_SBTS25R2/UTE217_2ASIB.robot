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

*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
Downgrade_To_SBTS25R2
    [Tags]    QC_amli
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND   Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    Run keyword and ignore error    Change parameter to disconnect netact with BTS
    prepare lower build on SBTS    sw_release=25R2     target_path=/home/ute/btsauto/
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
CB006536_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_146422  feature:6056  original:3_5_UTESRAN232  1st:3_5_UTE4G217  Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006536
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown


CB006536_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_146421  feature:6056  original:3_5_UTESRAN232  1st:3_5_UTE4G217  Prio-2
    [Setup]    run keywords    Set Library Search Order
    ...  CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082   taf.sbts.oam.coam.admin
    ...  AND    CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

CB006536_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback_Software_for_multi-MRBTS
    [Tags]    QC_146420  feature:6056  original:3_5_UTESRAN232  1st:3_5_UTE4G217  Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
    ...    AND    Set Library Search Order    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    TC_SWM_rollback_Software_for_multi-MRBTS
    [Teardown]    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown

LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Tags]    QC_146400   21    3_5_UTE4G217
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Dualcore_LTE4498
    ...    AND    TC setup
    Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Teardown]    TC teardown
LTE655-a_RRM_Airscale_FDD_EDA_CAS-55561-R0L0_Reset BTS after SW update successfully
    [Tags]    QC_146396    original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords        Set Library Search Order    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    [Teardown]    TC Teardown
CB007425_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_146418    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order
    ...    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...  taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown
