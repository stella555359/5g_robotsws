*** Settings ***
Documentation     [SUITE PURPOSE]  CB008124 "UL Resource Reservation and Scheduling by Configured Grants Type 2"
...               Scope : TCs for step B
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 17-Oct-2022
...             \nLast Modified by            : vincent.boulet@nokia.com
...             \nModification:
...                       17-Oct-2022         | Creation
...                       13-Feb-2023         | Add TC B11
...                       03-Mar-2023         | Add TC B12, remove B11
...                       08-Mar-2023         | Add TC B09
...                       14-Mar-2023         | Add TCs B08 and B25
...                     \n29-Apr-2024         | Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC


Resource                            ./resources/robot/CB008124-B_keywords.robot

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

[1]CB008124_B_08_B4_CG_activation_deactivation_reactivation_and_UE_release_TDD_MP
    [Tags]                    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT
    CB008124_TC_B_08_B4_CG_activation_deactivation_reactivation_and_UE_release_TDD
