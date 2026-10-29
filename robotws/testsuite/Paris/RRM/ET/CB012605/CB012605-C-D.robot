*** Settings ***
Documentation     [SUITE PURPOSE] CB012605 Test suite for Subfeature C and D
...                               Cell deletion/addition and counters checks in DL and UL
...
...               Test Case Scenario author   : blandine.garnier@nokia.com
...               Test Case automation author : blandine.garnier@nokia.com / laurent.puchelle@nokia.com
...               Creation Date               : 2024-07-01
...               Modified Date               : 2024-10-15
...               Last Modified by            : laurent.puchelle@nokia.com
...               Modification:
...                       2024-07-01          | Creation
...                       2024-10-15          | refactoring, implementation of KPI and TTI checks


Resource          ./resources/robot/CB012605-C-D-Keywords.robot

Force Tags        CA_5G_SW_FR-Villarceaux    RRM    PY36
...               master_classicalbts_all    SBTS00
...               5G_RAN    RAN_5G    CRT


Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}

Test Teardown     Test Teardown


*** Test Cases ***
[1]CB012605-C-D-Cell_Deletion_Addition_Counters
    [Tags]                      CLOUD_5G_I_MP_AP_LOOO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
	TC_CB012605_C_D_Cell_Deletion_Addition_Counters
