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
Resource          ../HWM/LTE3656/LTE3656_V_10_reset_FHS_in_fullrack_BTS.robot
Resource          ../HWM/LTE4498/Dualcore_LTE4498.robot
Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot
Resource          ../SWM/SWM__SW_post_check_successful.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Tags]    QC_528887   21    10_5_CLOUD602
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Dualcore_LTE4498
    ...    AND    TC setup
    Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Teardown]    TC teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_528888    10_5_CLOUD602    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown

TC_CB006147_05_01_Lock_Unlock of [Q]SFP
    [Tags]    QC_532859    SFP    10_5_CLOUD602
    [Setup]    run keywords    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    TC_CB006147_05_01_Lock_Unlock_of_SFP
    [Teardown]    TC Teardown

[1]CB007215_ST_05_02 Max Duration of SW Post-check - single BTS
    [Tags]    QC_553429    BTS_Side    10_5_CLOUD602
    [Setup]    run keywords    Set Library Search Order   SWM__SW_post_check_successful
    ...    AND    TC Setup
    TC__SWM__SW_post_check_successful
    [Teardown]    TC Teardown

LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_528888    original:10_5_UTESRAN286     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND   TC Setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown
