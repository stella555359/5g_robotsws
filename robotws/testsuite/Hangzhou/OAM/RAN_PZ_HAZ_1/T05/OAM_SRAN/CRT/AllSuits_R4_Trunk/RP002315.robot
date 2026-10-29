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
#Resource          ../SWM/SWM__SW_pre_check_successful.robot
Resource          ../SWM/SWM__SW_pre_check_insufficient_disc_space.robot
Resource          ../SWM/SWM__SW_pre_check_critical_alarm_active.robot
Resource          ../SWM/SWM__SW_post_check_successful.robot
#Resource          ../SWM/SWM__SW_post_check_RAT_status_fail.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
SWM__SW_pre_check_insufficient_disc_space
    [Tags]    QC_422934    3_5_UTE4G502
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__SW_pre_check_insufficient_disc_space
    TC__SWM__SW_pre_check_insufficient_disc_space
    [Teardown]    SWM__SW_pre_check_insufficient_disc_space.Custom Test Teardown

SWM__SW_pre_check_critical_alarm_active
    [Tags]    QC_422933    3_5_UTE4G502
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__SW_pre_check_critical_alarm_active
    TC__SWM__SW_pre_check_critical_alarm_active
    [Teardown]    SWM__SW_pre_check_critical_alarm_active.Custom Test Teardown

SWM__SW_post_check_successful
    [Tags]    QC_71287    3_5_UTE4G502
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM__SW_post_check_successful
    TC__SWM__SW_post_check_successful
    [Teardown]    TC Teardown

#SWM__SW_post_check_RAT_status_fail
#    [Tags]    QC_422932    3_5_UTE4G502
#    [Setup]    run keywords    hran_frame_sbts.TC Setup
#    ...    AND    Set Library Search Order    SWM__SW_post_check_RAT_status_fail
#    TC__SWM__SW_post_check_RAT_status_fail
#    [Teardown]    SWM__SW_post_check_RAT_status_fail.Custom Test Teardown
