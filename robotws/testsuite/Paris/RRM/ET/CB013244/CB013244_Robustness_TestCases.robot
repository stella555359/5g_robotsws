*** Settings ***
Documentation     [SUITE PURPOSE]  CB013244 "Dynamic BWP adaptation robustness improvement"
...               Scope : Robustness TCs
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 01-Nov-2025
...               Last Modified by            :
...               Modification:
...                       01-Nov-2025         | Creation


Resource                            ./resources/robot/CB013244_Robustness_keywords.robot

Force Tags                          CA_5G_SW_FR-Villarceaux    RRM
...                                 PY36
...                                 master_classicalbts_all    SBTS00
...                                 STATE_CONFIGURED    5G_RAN    RAN_5G

Suite Setup                         Suite Setup from scratch    listBackupFiles=${FD_ALL}    keepAllUeDataInCfgFile=${True}
Suite Teardown                      Suite Teardown

Test Setup                          CB013244 Test Setup
Test Teardown                       CB013244 Test Teardown



*** Test Cases ***

CB013244_A_17_B2_Robustness_check_case1
    [Tags]                    CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    TC_CB013244_A_17_B2_Robustness_check_case1

CB013244_A_18_B2_Robustness_check_case2
    [Tags]                    CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    TC_CB013244_A_18_B2_Robustness_check_case2

CB013244_A_19_B2_Robustness_check_case3
    [Tags]                    CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    TC_CB013244_A_19_B2_Robustness_check_case3

CB013244_A_20_B2_Robustness_check_case4
    [Tags]                    CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    TC_CB013244_A_20_B2_Robustness_check_case4
