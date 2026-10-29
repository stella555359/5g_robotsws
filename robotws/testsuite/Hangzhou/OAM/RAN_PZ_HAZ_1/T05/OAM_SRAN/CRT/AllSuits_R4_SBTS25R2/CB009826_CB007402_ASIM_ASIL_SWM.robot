*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup    #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007402/CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem.robot
Resource          ../SWM/CB007402/CB007402_ST_02_03_upgradeCfgDataValidCheck_failed_on_Webem_remot_toll_when_PDL_err_exists.robot
Resource          ../SWM/CB007402/CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact.robot
Resource          ../SWM/CB007402/CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists.robot
Resource          ../SWM/CB007402/CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core.robot
#Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    [Tags]    QC_146533    7402    10_5_UTESRAN263
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    ...  AND    TC Setup
    TC_CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    [Teardown]    TC Teardown

CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists
    [Tags]    QC_146531    7402    10_5_UTESRAN263
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists
    ...  AND    TC Setup
    TC_CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists
    [Teardown]    TC Teardown

CB007402_ST_05_07_execute SW fullcheck on Netact before and after SW download on Dual core
    [Tags]    QC_146532    7402    10_5_UTESRAN263
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core
    ...  AND    TC Setup
    TC_CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core
    [Teardown]    TC Teardown

#TC_CB006147_05_01_Lock_Unlock of [Q]SFP
#    [Tags]    QC_33476    SFP    10_5_UTESRAN263
#    [Setup]    run keywords    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
#    ...    AND    TC Setup
#    TC_CB006147_05_01_Lock_Unlock_of_SFP
#    [Teardown]    TC Teardown
