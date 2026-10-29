*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    CLOUD_HRAN_RFS_AILR_B1-B4_MTNRL61_3AHPMDB_3AHEGC
Documentation  Test Suite

Resource  testsuite/Timisoara/SBTS/PS/PS/Testcases/PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset/test.robot
Resource  testsuite/Timisoara/SBTS/PS/PS/Testcases/PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window/test.robot
Resource  testsuite/Timisoara/SBTS/PS/PS/Testcases/PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset/test.robot

*** Variables ***
#${SKIP_INTEGRATION}    ${TRUE}
#${IS_RFS_ENV}     ${TRUE}
${NETACT_ID}     cl5012
@{rezultate_from_RU_reset}
@{rezultate_during_the_time_window}
@{rezultate_from_rat_reset}


*** Test Cases ***
[01][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[01][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[01][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}

[2][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[2][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[2][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[3][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[3][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[3][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[4][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[4][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[4][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[5][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[5][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[5][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}

[6][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[6][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[6][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[7][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[7][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[7][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[8][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[8][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[8][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[9][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[9][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[9][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[10][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[10][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[10][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}

[11][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[11][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[11][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[12][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[12][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[12][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[13][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[13][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[13][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[14][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[14][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[14][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}


[15][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  Run Keywords  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_RU_reset}

[15][1.0] Automated__PS_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  Run Keywords  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    ...    AND    Get Status  ${rezultate_during_the_time_window}

[15][1.0] Automated__PPS_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Timeout]    14400
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]  Run Keywords  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    ...    AND    Get Status  ${rezultate_from_rat_reset}

[1][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    Evaluare Status    ${rezultate_from_RU_reset}

[1][1.0] Automated__PS__CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    Evaluare Status    ${rezultate_during_the_time_window}

[1][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    Evaluare Status    ${rezultate_from_rat_reset}

*** Keywords ***
Get Status
    [Arguments]    ${lista_rezultate}
    Append To List    ${lista_rezultate}  ${TEST_STATUS}

Evaluare status
    [Arguments]    ${lista_rezultate}
    Set Test Variable    ${test_passed}    0
    Set Test Variable    ${test_total}    0
    FOR    ${status}    IN    @{lista_rezultate}
        ${test_total}=    Evaluate    ${test_total} + 1
        IF    '${status}'=='PASS'
            ${test_passed}=    Evaluate    ${test_passed} + 1
        END
    END
    IF    ${test_total} != ${test_passed}
        Log    Rezultat FAIL, au trecut doar ${test_passed} din ${test_total} teste.    console=True
        FAIL
    ELSE
    	Log    Rezultat PASS, au trecut toate ${test_passed} din ${test_total} teste.    console=True
    END
