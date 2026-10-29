*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1
##Library           hran_ssh
##Library           hran_compa
#Library           hran_tools

Library           taf.sbts.oam.coam.admin
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot
#Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.robot
Resource          ../SWM/CB007425/SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource          ../SWM/CB007821/CB007821_CB006147_SFP_QSFP_control.robot
Resource          ../SWM/CB014041/CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
[CB007821] CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    [Tags]    QC_33370    0610    3_5_UTE4G243
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    [Teardown]    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

[CB007821] CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    [Tags]    QC_33369    0610    3_5_UTE4G243
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    [Teardown]    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown

[CB007821] CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
    [Tags]    QC_33368    0610    3_5_UTE4G243
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
    ...    AND    Set Library Search Order    SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    TC__CB007425_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Teardown]    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown

[CB007821] CB007821_CB006147_SFP_QSFP_control
    [Tags]    QC_33383    0611    3_5_UTE4G243
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    TC Setup
    ...    AND    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
    TC_CB006147_05_01_Lock_Unlock_of_SFP
    [Teardown]    TC Teardown

[CB0014041] CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed
    [Tags]    QC_176886      0611    3_5_UTE4G243
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    TC Setup
    ...    AND    Set Library Search Order    CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed
    ...    taf.sbts.oam.coam.admin
    TC_CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed
    [Teardown]    TC Teardown
