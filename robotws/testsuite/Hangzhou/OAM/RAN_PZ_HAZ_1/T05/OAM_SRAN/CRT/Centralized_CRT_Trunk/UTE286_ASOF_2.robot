*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/CB006536/HWM/ASOF_CB006147_SFP_QSFP_control.robot
Resource          ../HWM/LTE4498/CB006053_LTE4498.robot
Resource          ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
TC_CB006147_05_01_Lock_Unlock of [Q]SFP
    [Tags]    QC_33438    SFP    10_5_CLOUD602
    [Setup]    run keywords    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    TC_CB006147_05_01_Lock_Unlock_of_SFP
    [Teardown]    TC Teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_33437    3_5_UTESRAN201    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown

CB009469_LBT5358_01_SFP monitoring in BTS SM(ADMIN)&Netact-Static Dynamic SFP Parameters
    [Tags]    QC_33439    10_5_UTESRAN286    HWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
    ...    AND    TC setup
    LBT5358-1_CB007425
    [Teardown]    TC teardown
