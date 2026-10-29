*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness
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
...               CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
#Suite Teardown    Setup.Suite Teardown       reset_ap=${False}


*** Test Cases ***

[1]TranRob_HO_2CC_10UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Init Sequence          _
    Step                   Step_TL_Init    ${CURDIR}    CB008661    cb8661    FR1_3CELLS    activate_sherpa    no_tti    fifo_debug=0
    Step                   Step_Configure_HO_And_Restart
    Step                   Step_Cell_Setup
    Step                   Step_Endurance    timeout=12hours    repeat_kw=Step_HO_2CC_10UE_DlHighTputBler0_UlBler0
    Step                   Step_Postlude
    #[Teardown]             GenericTest.Display diagnosis
