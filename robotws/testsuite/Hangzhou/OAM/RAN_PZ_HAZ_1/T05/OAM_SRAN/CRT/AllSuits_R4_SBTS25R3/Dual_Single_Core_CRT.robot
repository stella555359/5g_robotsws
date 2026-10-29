*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/SWM__DSC_Local_Software_Fallback_RLC_first_core.robot
Resource          ../SWM/BOAM_ET/RP002324/Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot
Resource 	  ../SWM/BOAM_ET/RP002324/RP002324_ASIL.robot


*** Variables ***
${target_release}    SBTS25R3


#*** Test Cases ***
#Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#    [Tags]    QC_475196    3_5_UTE4G502
#    [Setup]    run keywords    TC Setup    AND    Set Library Search Order
#    ...    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#   [Teardown]    TC Teardown

#SWM__DSC_Local_Software_Fallback_RLC_first_core
#    [Tags]    QC_71110    3_5_UTE4G502
#    [Setup]    run keywords    Custom Test Setup
#    ...    AND    Set Library Search Order    SWM__DSC_Local_Software_Fallback_RLC_first_core
#    [Timeout]    2 hours
#    SWM__DSC_Local_Software_Fallback_RLC_first_core
#    [Teardown]    TC Teardown
