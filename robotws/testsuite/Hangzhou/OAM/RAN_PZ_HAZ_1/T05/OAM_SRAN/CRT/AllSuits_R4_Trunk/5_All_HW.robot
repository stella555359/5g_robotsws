*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1  robot:no-dry-run
##Library           hran_ssh
##Library           hran_compa
#Library           hran_tools

Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/5_All_HW_ET/LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio
    [Tags]    QC_33292    3_5_UTE4G225
    [Setup]    run keywords
    ...    LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio
    TC__LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio
    [Teardown]    LTE2866-R-g_SW_Update_fail_with_SW_distribution_to_radio.TC_Custom Teardown
