*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness
...
...
...               Test Case Scenario author   : jacob.velasco_mendez@nokia.com
...               Test Case Scenario author   : jacob.velasco_mendez@nokia.com
...               Test Case automation author : jacob.velasco_mendez@nokia.com
...               Test Case automation contact: jacob.velasco_mendez@nokia.com
...               Creation Date               : 10-December-2021
...               Modified Date               : 13-December-2021
...               Last Modified by            : jacob.velasco_mendez@nokia.com

Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          resources/robot/CB008661_Keywords.robot

Variables         ../../../resources/SWENG/python/ReadConfig.py

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CRT
...               CLOUD_5G_I_BOO_AP_LOO    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${False}


*** Test Cases ***

[1]TranRob_Traffic_4CC_20UE_DlHighTputBler0_UlBler0
    Init Sequence          _
    Step                   Step_TL_Init    ${CURDIR}    CB008661    cb8661    FR1_IBCA    activate_sherpa    no_tti    fifo_debug=0
    Step                   Step_TL_Restart
    Step                   Step_Cell_Setup
    Step                   Step_Traffic_4CC_20UE_DlHighTputBler0_UlBler0               timeout=12hours
    Step                   Step_Postlude
    [Teardown]             GenericTest.Display diagnosis
