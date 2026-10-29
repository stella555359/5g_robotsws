*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1

Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/BOAM_ET/RP002324/Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot
Resource          ../SWM/BOAM_ET/RP002324/ASIL_Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00.robot
Resource          ../SWM/BOAM_ET/RP002324/ASIL_Automated__SW_Management_File__Corrupted_in_SW_Download_targetBD_FL00.robot
Resource          ../SWM/BOAM_ET/RP002324/ASIL_Automated__SW_Management__BTS_SW_Fallback_Consistent_4082_Trunk_Trunk.robot
Resource          ../SWM/BOAM_ET/RP002324/ABIO_OAM_LBT2679_Collect_SW_download_and_activation_files_after_SW_update_fails.robot
Resource 	  ../SWM/BOAM_ET/RP002324/RP002324_ASIL.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
OAM_LBT2679_Collect SW download and activation files after SW update fails
    [Tags]    QC_475192    3_5_UTE4G204
    [Setup]    run keywords  TC Setup   AND  Set Library Search Order
    ...  ABIO_OAM_LBT2679_Collect_SW_download_and_activation_files_after_SW_update_fails
    OAM_LBT2679_Collect SW download and activation files after SW update fails
   [Teardown]    TC Teardown

#Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#    [Tags]    QC_475196    3_5_UTE4G204
#    [Setup]    run keywords    TC Setup    AND    Set Library Search Order
#    ...    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
#   [Teardown]    TC Teardown

#Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00
#    [Tags]    QC_475171
#    [Setup]    run keywords    TC Setup  AND  Set Library Search Order  ASIL_Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00
#    Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00
#   [Teardown]    Custom TC Teardown

#Automated__SW_Management_File__Corrupted_in_SW_Download_targetBD_FL00
#    [Tags]    QC_475169
#    [Setup]    run keywords    TC Setup  AND  Set Library Search Order  ASIL_Automated__SW_Management_File__Corrupted_in_SW_Download_targetBD_FL00
#    Automated__SW_Management_File__Corrupted_in_SW_Download_targetBD_FL00
#   [Teardown]    Custom TC Teardown

#Automated__SW_Management__BTS_SW_Fallback_Consistent_4082_Trunk_Trunk
#    [Tags]    QC_475170
#    [Setup]    run keywords    TC Setup  AND  Set Library Search Order  ASIL_Automated__SW_Management__BTS_SW_Fallback_Consistent_4082_Trunk_Trunk
#    Automated__SW_Management__BTS_SW_Fallback_Consistent_4082_Trunk_Trunk
#   [Teardown]    Custom TC Teardown
