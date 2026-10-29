*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness CRT test from Krakow
...
...               Test Case author   : imported from Krakow team
...               Test Case contact  : denis.taupin@nokia.com
...               Creation Date      : 19-March-2024
...               Modified Date      : 02-April-2024
...               Last Modified by   : denis.taupin@nokia.com

Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          ./resources/robot/common_Keywords.robot

Variables         ../../../resources/SWENG/python/ReadConfig.py

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
# ...               CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}


*** Test Cases ***

[0]TranRob_FR1_Campaign1_Prelude
    Init Sequence     _
    Step              Step_TL_Init    ${CURDIR}    TranRobKrk    tranrobkrk    FR1_3CELLS    activate_sherpa    no_tti    fifo_debug=0
    Step              Step_TL_Restart
    Step              Step_Cell_Setup
    #[Teardown]        GenericTest.Display diagnosis

[1][1.0] TranRob_11_Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9
    Step              Step_Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9                  timeout=12hours
    Run Keyword if    '${Verdict_Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_12_Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release
    Step              Step_Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release                  timeout=12hours
    Run Keyword if    '${Verdict_Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_14_Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release
    Step              Step_Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release                  timeout=12hours
    Run Keyword if    '${Verdict_Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_13_Traffic_1CC_20UE_FR1_DL_UL_Bler_During_Attach_And_Release
    Step              Step_Traffic_1CC_20UE_FR1_DL_UL_Bler_During_Attach_And_Release                  timeout=12hours
    Run Keyword if    '${Verdict_Traffic_1CC_20UE_FR1_DL_UL_Bler_During_Attach_And_Release}' == 'FAILED'    FAIL    dependencies issue

[0]TranRob_FR1_Campaign1_Postlude
    Step              Step_Postlude
