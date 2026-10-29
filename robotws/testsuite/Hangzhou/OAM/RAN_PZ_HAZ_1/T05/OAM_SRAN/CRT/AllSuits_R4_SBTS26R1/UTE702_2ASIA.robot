*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS26R1    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1

Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Fault_29.robot
Resource          ../SWM/SWM__SW_Verify_Fault_2056_Suppression.robot
Resource          ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Download_failure.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Distribution_fail.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails.robot
Resource          ../SWM/BOAM_ET/RP002324/Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot


*** Variables ***
${target_release}    SBTS26R1


*** Test Cases ***




SWM__Local_Software_Download_and_Activation_Distribution_fail
    [Tags]    QC_251910    re    conflict    10_5_UTESRAN702      tt
    [Setup]    run keywords      Set Library Search Order    SWM__Local_Software_Download_and_Activation_Distribution_fail
    ...     AND  TC Setup
    TC__SWM__Local_Software_Download_and_Activation_Distribution_fail
    [Teardown]    SWM__Local_Software_Download_and_Activation_Distribution_fail.Custom Test Teardown

