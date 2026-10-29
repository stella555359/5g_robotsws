*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1

Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Fault_29.robot
Resource          ../SWM/SWM__SW_Verify_Fault_2056_Suppression.robot
Resource          ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Download_failure.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Distribution_fail.robot
Resource          ../SWM/SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails.robot
Resource          ../SWM/BOAM_ET/RP002324/Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot


*** Variables ***
${target_release}    SBTS25R2


#*** Test Cases ***
#SWM__SW_download_and_activation__SBTS_to_SBTS
#    [Tags]    QC_amli    robot:no-dry-run   5_10_SRAN600
#    [Setup]    run keywords     Set Library Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS    hran_general
#     ...    AND      SWM__SW_download_and_activation__SBTS_to_SBTS.TC_Custom Setup
#    #To make sure update to the latest version before CRT Start
#    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
#    [Teardown]    SWM__SW_download_and_activation__SBTS_to_SBTS.TC_Custom Teardown
#
#SWM_Local_Software_Download_and_Activation_Fault_29
#    [Tags]    QC_146384   original:10_5_UTESRAN702    1st:10_5_UTESRAN702    Prio-2
#    [Setup]    run keywords      Set Library Search Order    SWM__Local_Software_Download_and_Activation_Fault_29
#    ...    AND  TC Setup
#    TC__SWM_Local_Software_Download_and_Activation_Fault_29
#    [Teardown]    SWM__Local_Software_Download_and_Activation_Fault_29.Custom Test Teardown
#
#SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails
#    [Tags]    QC_146386    change_download    1    10_5_UTESRAN702
#    [Setup]    run keywords   Set Library Search Order  SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails
#    ...  AND   TC Setup
#    TC_SWM__Local_Software_Download_and_Activation_Distribution_IntegrityCheck_fails
#    [Teardown]    TC Teardown
#
#SWM__Local_Software_Download_and_Activation_Distribution_fail
#    [Tags]    QC_146385    re    conflict    10_5_UTESRAN702      tt
#    [Setup]    run keywords      Set Library Search Order    SWM__Local_Software_Download_and_Activation_Distribution_fail
#    ...     AND  TC Setup
#    TC__SWM__Local_Software_Download_and_Activation_Distribution_fail
#    [Teardown]    SWM__Local_Software_Download_and_Activation_Distribution_fail.Custom Test Teardown
#
#SWM__Local_Software_Download_and_Activation_Download_failure
#    [Tags]    QC_146387    W23_re    10_5_UTESRAN702
#    [Setup]    run keywords      Set Library Search Order    SWM__Local_Software_Download_and_Activation_Download_failure
#    ...    AND  TC Setup
#    TC__SWM__Local_Software_Download_and_Activation_Download_failure
#    [Teardown]    TC Teardown
#
#SWM__SW_Verify_Fault_2056_Suppression
#    [Tags]    QC_146394    feature:2315    original:10_5_UTESRAN702    1st:10_5_UTESRAN702    Prio-2
#    [Setup]    run keywords      Set Library Search Order    SWM__SW_Verify_Fault_2056_Suppression
#    ...    AND     TC Setup
#    TC__SWM__SW_Verify_Fault_2056_Suppression
#    [Teardown]    run keywords    Step3: Recovery actions
#    ...    AND    TC Teardown
#
#Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#    [Tags]    QC_146367    10_5_UTESRAN287
#    [Setup]    run keywords        Set Library Search Order
#    ...    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#    ...   AND    TC Setup
#    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#   [Teardown]    TC Teardown
