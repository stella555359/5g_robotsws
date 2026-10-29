*** Settings ***
Documentation     [SUITE PURPOSE]  CB008124 "UL Resource Reservation and Scheduling by Configured Grants Type 2"
...               Scope : TCs for step F
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 17-Jul-2023
...               Last Modified by            : Laurent Puchelle
...               Modification:
...                       17-Jul-2022         | Creation


Resource                            ./resources/robot/CB008124-F_keywords.robot

Force Tags                          CA_5G_SW_FR-Villarceaux    RRM
...                                 PY36
...                                 master_classicalbts_all    SBTS00
...                                 STATE_CONFIGURED    5G_RAN    RAN_5G

Suite Setup                         Suite Setup from scratch            listBackupFiles=${FD_ALL}
Suite Teardown                      Suite Teardown

Test Setup                          CB008124 Test Setup
Test Teardown                       CB008124 Test Teardown


*** Variables ***
${TestSharkTool}        MC_SHARK


*** Test Cases ***
[1]CB008124_F_05_B3_CG_interaction_with_PRB_pooling_TDD
    [Tags]                    CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD    CRT
    CB008124_TC_F_05_B3_CG_interaction_with_PRB_pooling_TDD
