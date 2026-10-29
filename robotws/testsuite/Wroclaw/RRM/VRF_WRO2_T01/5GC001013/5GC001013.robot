*** Settings ***
Documentation
...  author:        Maciej Cupial
...  contact:       maciej.cupial@nokia.com
...  maintainer:    maciej.cupial@nokia.com
...  description:   Selected REG FDD TCs for the trunk (2nd_file)


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC001013/resources/tests_1013.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC001013/resources/tests_1013_refactored.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot

Force Tags  CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  STATE_SW_UPLOADED  CRT
...         SBTS00__WITH__CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1_AHFIB_3xAHLOA


Suite Setup       Suite Setup for 5GC001013
Suite Teardown    Suite Teardown for 5GC001013
Test Setup        Test Setup for 5GC001013
Test Teardown     Test Teardown for 5GC001013


*** Test Cases ***
[1]5GC001013-A.B2_FDD_RRM_Classical_MG_setup_SgNB_Addition_CP
    [Tags]  CDRT  newTrunk
    run_keyword_and_allow_retest  [1]5GC001013-A.B2_FDD_RRM_Classical_MG_setup_SgNB_Addition_CP_REF

[1]5GC001013-B#B1_01_FDD_Classical_MG_release_during_SgNB_Modification_noDRX_offSRB3_CP
    [Tags]  newTrunk
    [1]5GC001013-A.B1_FDD_RRM_Classical_MG_setup_SgNB_Modification_DRX_CP_REF

[1]5GC001013-B#B1_03_FDD_Classical_MG_release_during_SgNB_Modification_activDRX_offSRB3_CP
    [Tags]  CDRT  newTrunk
    run_keyword_and_allow_retest
    ...  [1]5GC001013-B#B1_03_FDD_Classical_MG_release_during_SgNB_Modification_activDRX_offSRB3_CP_REF
