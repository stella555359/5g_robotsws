*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Fault_29.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
SWM_Local_Software_Download_and_Activation_Fault_29
    [Tags]    QC_71213    5    10_5_UTESRAN702
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__Local_Software_Download_and_Activation_Fault_29
    TC__SWM_Local_Software_Download_and_Activation_Fault_29
    [Teardown]    SWM__Local_Software_Download_and_Activation_Fault_29.Custom Test Teardown
