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
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Download_failure.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Distribution_fail.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails
    [Tags]    QC_71221    change_download    1    10_5_UTESRAN702
    [Setup]    run keywords    TC Setup
    ...  AND  Set Library Search Order  SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails
    TC_SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails
    [Teardown]    TC Teardown

SWM__Local_Software_Download_and_Activation_Distribution_fail
    [Tags]    QC_71222    re    conflict    10_5_UTESRAN702
    [Setup]    run keywords    TC Setup
    ...     AND    Set Library Search Order    SWM__Local_Software_Download_and_Activation_Distribution_fail
    TC__SWM__Local_Software_Download_and_Activation_Distribution_fail
    [Teardown]    SWM__Local_Software_Download_and_Activation_Distribution_fail.Custom Test Teardown

SWM__Local_Software_Download_and_Activation_Download_failure
    [Tags]    QC_71223    W23_re    10_5_UTESRAN702
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__Local_Software_Download_and_Activation_Download_failure
    TC__SWM__Local_Software_Download_and_Activation_Download_failure
    [Teardown]    TC Teardown
