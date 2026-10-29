*** Settings ***
Documentation     [SUITE PURPOSE]  CB008124 "UL Resource Reservation and Scheduling by Configured Grants Type 2"
...               Scope : TCs for step C
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 16-Mar-2022
...               Last Modified by            : Yann HERVE
...               Modification:
...                       16-Mar-2022         | Creation

Resource                            ./resources/robot/CB008124-C_keywords.robot

Force Tags                          CA_5G_SW_FR-Villarceaux    RRM
...                                 PY36
...                                 master_classicalbts_all       SBTS00
...                                 STATE_CONFIGURED    5G_RAN    RAN_5G

Suite Setup                         Suite Setup from scratch            listBackupFiles=${FD_ALL}
Suite Teardown                      Suite Teardown

Test Setup                          CB008124 Test Setup
Test Teardown                       CB008124 Test Teardown_V2


*** Variables ***
${TestSharkTool}        MC_SHARK


*** Test Cases ***
[1]CB008124_C_10_B13_ulCgMaxNumUeUl_online_change_TDD
    [Tags]                    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT
    CB008124_TC_C_10_B13_ulCgMaxNumUeUl_online_change_TDD
    Produce Scout Data

[1]CB008124_C_12_B15_Interaction_with_adaptive_retransmission_FDD
    [Documentation]             This TCs is used for checking interaction between ULCG and adaptive retransmission.
    ...                         In case of ULCG, adaptive retransmission should not be used. However, it should still be used
    ...                         in case of DG (legacy) scheduling.
    ...                         This scenario only checks the first part (no adaptive retransmission used in case if ULCG)
    ...                         by adding BLER on CG PUSCH by using an AP test mode.
    ...                         It checks that adaptive retransmissions MCS (28..31 in case of 256QAM, 29..31 in case of 64QAM)
    ...                         are not used for ULCG retransmissions.
    ...                         However, it does not check the second part (adaptive retransmission still used for DG). This
    ...                         part was tested by hand.
    [Tags]                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT
    CB008124_TC_C_12_B15_Interaction_adaptive_retrans
    Produce Scout Data
