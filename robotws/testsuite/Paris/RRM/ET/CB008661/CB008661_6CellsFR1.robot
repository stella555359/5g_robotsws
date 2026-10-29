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
...               CLOUD_5G_I_BOO_AP_LOO    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${False}


*** Test Cases ***

[0]TranRob_6CellsFR1_Campaign1_Prelude
    Init Sequence     _
    Step              Step_TL_Init    ${CURDIR}    CB008661    cb8661    FR1_IBCA    activate_sherpa    no_tti    fifo_debug=0
    Step              Step_TL_Restart
    Step              Step_Cell_Setup
    #[Teardown]        GenericTest.Display diagnosis

[1]TranRob_Traffic_4CC_10UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_4CC_10UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_4CC_10UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_16_Traffic_4CC_20UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_4CC_20UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_4CC_20UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_4CC_40UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_4CC_40UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_4CC_40UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_4CC_60UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_4CC_60UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_4CC_60UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_4CC_80UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_4CC_80UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_4CC_80UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_15_Traffic_4CC_100UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_4CC_100UE_DlHighTputBler0_UlBler0              timeout=12hours
    Run Keyword if    '${Verdict_Traffic_4CC_100UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_4CC_100UE_DlHighTputBler9_UlBler0
    Step              Step_Traffic_4CC_100UE_DlHighTputBler9_UlBler0              timeout=12hours
    Run Keyword if    '${Verdict_Traffic_4CC_100UE_DlHighTputBler9_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_1UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_1UE_DlHighTputBler0_UlBler0                timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_5UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_5UE_DlHighTputBler0_UlBler0                timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_5UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_10UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_10UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_10UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_20UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_20UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_20UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_30UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_30UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_30UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_40UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_40UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_50UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_50UE_DlHighTputBler0_UlBler0               timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0
    Step              Step_Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0        timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_100UE_DlHighTputBler0_UlBler0
    Step              Step_Traffic_2CC_100UE_DlHighTputBler0_UlBler0              timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_100UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Traffic_2CC_100UE_DlHighTputBler9_UlBler0
    Step              Step_Traffic_2CC_100UE_DlHighTputBler9_UlBler0              timeout=12hours
    Run Keyword if    '${Verdict_Traffic_2CC_100UE_DlHighTputBler9_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0
    Step              Step_TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0           timeout=12hours
    Run Keyword if    '${Verdict_TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0
    Step              Step_ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0         timeout=12hours
    Run Keyword if    '${Verdict_ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0
    Step              Step_ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0       timeout=12hours
    Run Keyword if    '${Verdict_ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_09_ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0
    Step              Step_ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0       timeout=12hours
    Run Keyword if    '${Verdict_ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_10_SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0
    Step              Step_SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0            timeout=12hours
    Run Keyword if    '${Verdict_SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_06_MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0
    Step              Step_MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0    timeout=12hours
    Run Keyword if    '${Verdict_MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_RLF_2CC_6UE_DlHighTputBler0_UlBler0
    Step              Step_RLF_2CC_6UE_DlHighTputBler0_UlBler0                    timeout=12hours
    Run Keyword if    '${Verdict_RLF_2CC_6UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_RLF_2CC_10UE_DlHighTputBler0_UlBler0
    Step              Step_RLF_2CC_10UE_DlHighTputBler0_UlBler0                   timeout=12hours
    Run Keyword if    '${Verdict_RLF_2CC_10UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_07_Multiple_Cell_Block_Unblock
    Step              Step_Multiple-Cell-Block-Unblock                            timeout=12hours
    Run Keyword if    '${Verdict_Multiple-Cell-Block-Unblock}' == 'FAILED'    FAIL    dependencies issue

[0]TranRob_6CellsFR1_Campaign1_Postlude
    Step              Step_Postlude
