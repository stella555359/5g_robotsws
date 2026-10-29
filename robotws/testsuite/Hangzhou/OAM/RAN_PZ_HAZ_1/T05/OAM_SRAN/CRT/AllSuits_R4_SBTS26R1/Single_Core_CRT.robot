*** Settings ***
Documentation     [PURPOSE]
Suite Setup       Suite setup
#Suite Setup       Suite setup   skip_build_download=${TRUE}
Suite Teardown    Suite Teardown
Force Tags        4G_TDD    QCD_MN_RAN     QCP_RAN_VRF  3_5_UTE4G502

Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.robot
Resource          ../SWM/SWM__SW_update_for_new_RF_unit_uncommissioned.robot
# Resource          ../SWM/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource          ../SWM/RP001362.robot
Resource 	  ../SWM/BOAM_ET/RP002324/Automated__FPGA_SW_Update_and_Activation.robot
Resource 	  ../SWM/BOAM_ET/RP002324/RP002324_ASIL.robot
Resource          ../SWM/BOAM_ET/RP002324/Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot
Resource          ../SWM/BOAM_ET/RP002324/ABIO_OAM_LBT2679_Collect_SW_download_and_activation_files_after_SW_update_fails.robot


*** Variables ***
${target_release}    SBTS26R1


*** Test Cases ***
#T
#    [Tags]    QC_11111    10_5_UTESRAN287
#    [Setup]    run keywords    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC_Custom Setup
#    ...    AND    Set Library Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
#    _Get Scf By Admin default    /home/ute/scf_bak.xml
#    [Teardown]   SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC_Custom Teardown
#    taf.sbts.oam.coam.admin.Teardown Admin    name=get_scf

SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Tags]    QC_251904    10_5_UTESRAN287
    [Setup]    run keywords    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC_Custom Setup
    ...    AND    Set Library Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Teardown]    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC_Custom Teardown

RP001362_SWM__fallback_to_3rd_Airscale_partition
    [Tags]    QC_251936    10_5_UTESRAN287
    [Setup]    run keywords    TC Setup    AND    Set Library Search Order    RP001362
    RP001362_SWM__fallback_to_3rd_Airscale_partition
    [Teardown]    TC Teardown

Automated__FPGA_SW_Update_and_Activation
    [Tags]    QC_251892    10_5_UTESRAN287
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order     Automated__FPGA_SW_Update_and_Activation
    Automated FPGA SW Update And Activation
   [Teardown]    Custom TC Teardown

OAM_LBT2679_Collect SW download and activation files after SW update fails
    [Tags]    QC_251889    10_5_UTESRAN287
    [Setup]    run keywords  TC Setup   AND  Set Library Search Order
    ...  ABIO_OAM_LBT2679_Collect_SW_download_and_activation_files_after_SW_update_fails
    OAM_LBT2679_Collect SW download and activation files after SW update fails
   [Teardown]    TC Teardown

SWM__SW_update_for_new_RF_unit_uncommissioned
    [Tags]    QC_251903    10_5_UTESRAN287
    [Setup]    run keywords    SWM__SW_update_for_new_RF_unit_uncommissioned.TC_Custom Setup
    ...    AND    Set Library Search Order    SWM__SW_update_for_new_RF_unit_uncommissioned
    TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Teardown]    SWM__SW_update_for_new_RF_unit_uncommissioned.TC_Custom Teardown
