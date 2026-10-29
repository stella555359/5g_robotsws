*** Settings ***
Documentation     [SUITE PURPOSE]  CB008124 "UL Resource Reservation and Scheduling by Configured Grants Type 2"
...               Scope : TCs for step D
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 20-Mar-2023
...               Last Modified by            : L. Puchelle
...               Modification:
...                       20-Mar-2023         | Creation, delivery of TC D06


Resource                            ./resources/robot/CB008124-D_keywords.robot

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
[1]CB008124_D_06_B3_CG_interaction_with_A-CSI_5ms_FDD
    [Tags]                    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT
    CB008124_TC_D_06_B3_CG_interaction_with_A-CSI_5ms_FDD
