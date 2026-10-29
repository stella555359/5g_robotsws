*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup      ${True}
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../CRT/SWM/CB007944/CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***

CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space
    [Tags]    QC_dante   HW_DualCore
    [Setup]    Log    STart
    TC_loop_7944
    [Teardown]    Log    STop
