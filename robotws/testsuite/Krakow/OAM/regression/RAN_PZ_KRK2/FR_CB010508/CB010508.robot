*** Settings ***
Documentation
...    Author: Przemyslaw Kusa, przemyslaw.kusa@nokia.com
...    Maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com

Resource    ./resources/keywords.robot

Force Tags    CA_VRF_KRK

Suite Setup       Suite Setup Custom
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
                  ...    collect_syslog=${False}
                  ...    collect_ru_console_log=${False}
Test Teardown     Custom Test Teardown

*** Test Cases ***
[1][1.0] SW upgrade and rollback_TL55_3x_supercell_with_3_subcells_2x_5Mhz_and_1x_20Mhz_N-2-N
    [Tags]    N-2-N    UUF
    [Timeout]    24h
    Update All Necessary Variables    source=${SW_SOURCE_N-2-N}    build=${SW_SOURCE_N-2-N}
    Create UUF_SW Directory With Proper Release
    Prepare Source SW    proper_sw=${SW_SOURCE_N-2-N}
    Wait For BTS To Be OnAir
    Upgrade Rollback with OAM KPI    Target_build=${TARGET_SW}
    Remove SW Package    build=${SW_SOURCE_N-2-N}
    ...                  path=${SW_PATH}

[1][1.0] SW upgrade and rollback_TL55_3x_supercell_with_3_subcells_2x_5Mhz_and_1x_20Mhz_N-1-N
    [Tags]    N-1-N    UUF
    [Timeout]    24h
    Update All Necessary Variables    source=${SW_SOURCE_N-1-N}    build=${SW_SOURCE_N-1-N}
    Create UUF_SW Directory With Proper Release
    Prepare Source SW    proper_sw=${SW_SOURCE_N-1-N}
    Wait For BTS To Be OnAir
    Upgrade Rollback with OAM KPI    Target_build=${TARGET_SW}
    Remove SW Package    build=${SW_SOURCE_N-1-N}
    ...                  path=${SW_PATH}

[1][1.0] SW upgrade and rollback_TL55_3x_supercell_with_3_subcells_2x_5Mhz_and_1x_20Mhz_N-N
    [Tags]    N-N    UUF
    [Timeout]    24h
    Update All Necessary Variables    source=${SW_SOURCE_N-N}    build=${SW_SOURCE_N-N}
    Create UUF_SW Directory With Proper Release
    Prepare Source SW    proper_sw=${SW_SOURCE_N-N}
    Wait For BTS To Be OnAir
    Upgrade Rollback with OAM KPI    Target_build=${TARGET_SW}
    Remove SW Package    build=${SW_SOURCE_N-N}
    ...                  path=${SW_PATH}
