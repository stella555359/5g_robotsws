*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource          ../SWM/SWM__Local_Software_Activation.robot
Resource          ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB007425/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../HWM/LTE4498/Dualcore_LTE4498.robot
#Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot
Resource          ../SWM/SWM__SW_post_check_successful.robot
Resource          ../SWM/SWM__Local_Software_Download.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
SWM__Local_Software_Download
    [Tags]    QC_33306     original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    Set Library Search Order    SWM__Local_Software_Download     taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND   TC Setup
    TC__SWM__Local_Software_Download
    [Teardown]    TC Teardown

SWM__Local_Software_Activation
    [Tags]    QC_33305   original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    Set Library Search Order    SWM__Local_Software_Activation     taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC__SWM__Local_Software_Activation
    [Teardown]    TC Teardown

SWM__SW_update_for_RMOD_with_fault_23
    [Tags]    QC_146395    original:3_5_UTE4G500      1st:3_5_UTE4G884      prio-1      test
    [Setup]    run keywords    Set Library Search Order    SWM__SW_update_for_RMOD_with_fault_23    hran_general
    ...    AND     SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Setup
    TC__SWM__SW_update_for_RMOD_with_fault_23
    [Teardown]    SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_146468     original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown

LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Tags]    QC_146470     original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Dualcore_LTE4498
    ...    AND    TC setup
    Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Teardown]    TC teardown

#TC_CB006147_05_01_Lock_Unlock of [Q]SFP
#    [Tags]    QC_33409     original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
#    [Setup]    run keywords    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
#    ...    AND    TC Setup
#    TC_CB006147_05_01_Lock_Unlock_of_SFP
#    [Teardown]    TC Teardown
