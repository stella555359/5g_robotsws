*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1

Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../HWM/LTE3656/LTE3656_V_10_reset_FHS_in_fullrack_BTS.robot
Resource          ../HWM/LTE4498/Dualcore_LTE4498.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Tags]    QC_33325   21    3_5_UTE4G217
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Dualcore_LTE4498
    ...    AND    TC setup
    Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Teardown]    TC teardown

LTE3656_V_10 reset FHS in fullrack BTS
    [Tags]    QC_33326    0401    3_5_UTE4G217
    [Setup]    run keywords    Set Library Search Order    LTE3656_V_10_reset_FHS_in_fullrack_BTS   taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    [LTE3656_V_10] reset FHS in fullrack BTS
    [Teardown]    TC Teardown
