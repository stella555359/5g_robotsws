*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness
...
...               Test Case Scenario author   : denis.taupin@nokia.com
...               Test Case Scenario author   : denis.taupin@nokia.com
...               Test Case automation author : denis.taupin@nokia.com
...               Test Case automation contact: denis.taupin@nokia.com
...               Creation Date               : 18-June-2024
...               Modified Date               : 18-June-2024
...               Last Modified by            : denis.taupin@nokia.com

Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          resources/robot/CB008661_Keywords.robot

Variables         ../../../resources/SWENG/python/ReadConfig.py

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39    TOOLS_PROFILE_TTI_LEGACY
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${False}


*** Test Cases ***

[0]TranRob_bhsEndur_FR1_Campaign1_Prelude
    Init Sequence          _
    Step                   Step_TL_Init    ${CURDIR}    BHS_ENDURANCE    bhsEndur    FR1_3CELLS    no_sherpa    no_tti    fifo_debug=0
    Step                   Step_TL_Restart
    Step                   Step_Cell_Setup

[1]TranRob_RLF_2CC_110UE_DlMedTputBler0_UlMedTputBler0
    [Timeout]              100hours
    Step                   Step_Endurance    timeout=100hours    repeat_kw=Step_RLF_2CC_110UE_DlMedTputBler0_UlMedTputBler0    nb_loop=150
    Run Keyword if         '${Verdict_Endurance}' == 'FAILED'    FAIL    dependencies issue

[0]TranRob_bhsEndur_Campaign1_Postlude
    Step                   Step_Postlude
