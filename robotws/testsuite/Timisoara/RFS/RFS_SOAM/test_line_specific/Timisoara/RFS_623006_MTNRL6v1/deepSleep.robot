*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    CLOUD_HRAN_RFS_ASOE_MTNRL6_3xAVQA_1xAHPB_1xAHPJ
Documentation  Test Suite

Resource  testsuite/Timisoara/SBTS/PS/PS/Testcases/PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset/test.robot
Resource  testsuite/Timisoara/SBTS/PS/PS/Testcases/PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window/test.robot
Resource  testsuite/Timisoara/SBTS/PS/PS/Testcases/PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset/test.robot

*** Variables ***
#${IS_RFS_ENV}     ${TRUE}
#${NETACT_ID}     cl2002
${NETACT_ID}     cl5012
${SKIP_FAULT}    4569

*** Test Cases ***
[1][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown

[1][1.0] Automated__PS__CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown

[1][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown