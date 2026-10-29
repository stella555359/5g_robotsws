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
Resource          ../CB008661/resources/robot/CB008661_Keywords.robot

Variables         ../../../resources/SWENG/python/ReadConfig.py

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_MO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_SA+NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_PRIVATE_NSA_FS_ECPRI_MMWV_TDD_SWENG
...               CLOUD_5G_I_BOO_AP_LOO_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}


*** Test Cases ***

[0]TranRob_FR2_Campaign2_Prelude
    Init Sequence     _
    Step              Step_TL_Init    ${CURDIR}    CB009092    cb9092    FR2    activate_sherpa    no_tti    fifo_debug=0
    Step              Step_TL_Restart
    Step              Step_Cell_Setup
    #[Teardown]        GenericTest.Display diagnosis

[1][1.0] TranRob_04_DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0
    Step              Step_DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0    timeout=12hours
    Run Keyword if    '${Verdict_DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0}' == 'FAILED'   FAIL   dependencies issue

[1]TranRob_DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0
    Step              Step_DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0    timeout=12hours
    Run Keyword if    '${Verdict_DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0}' == 'FAILED'   FAIL   dependencies issue

[1]TranRob_CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0
    Step              Step_CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0        timeout=12hours
    Run Keyword if    '${Verdict_CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[0]TranRob_FR2_Campaign2_Postlude
    Step              Step_Postlude
