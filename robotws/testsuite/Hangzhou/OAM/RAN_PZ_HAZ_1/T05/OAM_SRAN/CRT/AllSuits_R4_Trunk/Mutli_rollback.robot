*** Settings ***
Documentation
Suite Setup       hran_frame_sbts.suite setup    #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB006053/CB006053_LTE655.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
[CB006053]LTE4934_C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi_MRBTS
    [Tags]    QC_681514   3_5_UTESRAN251    SWM    bat1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE655
    ...    AND    TC Setup
    CB006053.TD.OM.LTE655_05_11_01_Remote_mass_eNB_Rollback_request
    [Teardown]    TC Teardown

[CB007425]LTE4934_C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi_MRBTS
    [Tags]    QC_685409   3_5_UTESRAN704    SWM    bat2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE655
    ...    AND    TC Setup
    CB007425.TD.OM.LTE655_05_11_01_Remote_mass_eNB_Rollback_request
    [Teardown]    TC Teardown
