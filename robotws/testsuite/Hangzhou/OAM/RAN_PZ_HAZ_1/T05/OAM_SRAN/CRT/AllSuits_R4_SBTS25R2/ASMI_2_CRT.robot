*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1

Library           taf.sbts.oam.coam.admin
Resource          ../HWM/LTE2508/LTE2508.robot
Resource          ../SWM/RRM_SWM_ASMI/SWM_eNB_reboot_during_SWDL.robot
Resource          ../SWM/RRM_SWM_ASMI/RRM_Airscale_Reset_BTS_after_SW_update_successfully.robot
#Resource          ../SWM/RRM_SWM_ASMI/SWM__UPG_Fallback_of_eNB_to_previous_customer_release.robot
Resource          ../SWM/RP00913/RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS.robot
Resource          ../SWM/RP00913/RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
LTE655-a_RRM_Airscale_FDD_EDA_CAS-55561-R0L0_Reset BTS after SW update successfully
    [Tags]    QC_71322    3_5_UTE4G500
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    RRM_Airscale_Reset_BTS_after_SW_update_successfully
    [Teardown]    TC Teardown

SWM__SBTS_upgrade_fails_due_to_hash_verification_failure_for_downloaded_software_file
    [Tags]    QC_474873     3_5_UTE4G500
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS
    TC_RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS
    [Teardown]    TC Teardown

SWM__SBTS_Signed_SW_SignedSWtoUnSignedSW
    [Tags]    QC_258853     3_5_UTE4G500
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW
    TC_RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW
    [Teardown]    TC Teardown

# LTE2508_ST_01_01_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_disabled
#    [Tags]    QC_71116    3_5_UTE4G500
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    ta_ssh_telnet
#    LTE2508_ST_01_01_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_disabled
#    [Teardown]    TC Teardown

# LTE2508_ST_01_02_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_enabled_and_RF_support_HW_ASMI
#    [Tags]    QC_71117    3_5_UTE4G500
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    ta_ssh_telnet
#    LTE2508_ST_01_02_Tri_energy_counter_reporting_Energy_consumption_LTE2508_is_enabled_and_RF_support_HW_ASMI
#    [Teardown]    TC Teardown
# LTE3340-A_RRM_Airscale_FDD_SWHWM OM.0394 eNB reboot during SWDL
#    [Tags]    QC_71140    3_5_UTE4G500
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM_eNB_reboot_during_SWDL
#    SWM_eNB_reboot_during_SWDL
#    [Teardown]    TC Teardown
