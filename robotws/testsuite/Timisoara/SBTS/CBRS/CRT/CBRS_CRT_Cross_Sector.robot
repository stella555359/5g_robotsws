*** Settings ***
Documentation    CBRS CRT suite for Cross Sector configuration
...              Suite designed CBRS_2 deploy only!

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/CB010564/CB010564-E_FeVe_01-Pre-Tx_RSSI_measurements_with_cross-sector_configuration_in_use.robot
Resource    ./../Tests/CB010564/CB010564-E_FeVe_02-random_AZQC_power_outage_when_cross-sector_enabled.robot
Resource    ./../Tests/CB010564/CB010564-E_FeVe_03-BTS_startup_after_Reset_Site_when_cross-sector_enabled.robot
Resource    ./../Tests/CB010564/CB010564-E_FeVe_04-Recommission_3x_AZQC_with_M-type_configuration_to_N-type.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT

*** Test Cases ***

[1][1.0] CB010564-E_FeVe_04-Recommission_3x_AZQC_with_M-type_configuration_to_N-type
    [Timeout]     35min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB010564
    CB010564-E_FeVe_04-Recommission_3x_AZQC_with_M-type_configuration_to_N-type

[1][1.0] CB010564-E_FeVe_01-Pre-Tx_RSSI_measurements_with_cross-sector_configuration_in_use
    [Timeout]     35min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB010564
    CB010564-E_FeVe_01-Pre-Tx_RSSI_measurements_with_cross-sector_configuration_in_use

[1][1.0] CB010564-E_FeVe_02-random_AZQC_power_outage_when_cross-sector_enabled
    [Timeout]     25min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        CB010564
    CB010564-E_FeVe_02-random_AZQC_power_outage_when_cross-sector_enabled

[1][1.0] CB010564-E_FeVe_03-BTS_startup_after_Reset_Site_when_cross-sector_enabled
    [Timeout]     45min
    [Setup]       Test Precondition    clean_bts=false
    [Teardown]    Test Postcondition
    [Tags]        CB010564
    CB010564-E_FeVe_03-BTS_startup_after_Reset_Site_when_cross-sector_enabled
