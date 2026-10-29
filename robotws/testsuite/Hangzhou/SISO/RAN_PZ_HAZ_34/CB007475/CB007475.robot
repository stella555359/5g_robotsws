*** Settings ***
Documentation    author: Gao Ge, Hu Caoli
...              contact: ge.gao@nokia-sbell.com; caoli.hu@nokia-sbell.com
...              squad group: SG_01
...              feature: CB007475
Suite Setup       Setup Suite
Suite Teardown    Teardown Suite
Force Tags
...   PY36
Resource           Resource/CB007475_Resource.robot

*** Test Cases ***
[1]CB007475_B_07_NRTDD_LTE_FDD_Concurrent_with_NR_TDD_eCPRI_RF_Fiber_Split_on_Fullrack
    [Tags]    CRT_22R3     CDRT_22R3    CRT_TRUNK    CRT_22R4
    [Setup]   Setup case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND  Teardown case
    TC.CB007475_B_07_NRTDD_LTE_FDD_Concurrent_with_NR_TDD_eCPRI_RF_Fiber_Split_on_Fullrack

[1] Baseband module reset from BTSSM WebEM
    [Tags]    CRT_22R3   CDRT_22R3    CRT_TRUNK    CRT_22R4
    [Setup]   Setup case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND  Teardown case
    TC.Baseband module reset from BTSSM WebEM

[1] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Tags]    CRT_22R3   CDRT_22R3   CRT_TRUNK    CRT_22R4
    [Setup]   Setup case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND  Teardown case
    TC.General_SiSo_Auto_gNB_Site_Reset_From_WebUI

