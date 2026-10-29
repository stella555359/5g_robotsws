*** Settings ***
Documentation
...  Feature  CB008132 - Dynamic Slice aware scheduler
...
...  author/contact: rafal.skrok@nokia.com

Library    testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib
Resource   testsuite/Wroclaw/SyVe/RRM/features/SliceSchedulingScenarios.robot
Library    testsuite.Wroclaw.SyVe.RRM.resources.StartupManager


Suite Setup    Run Keywords
...                  Switch on ues pdu port
...                  Prepare BTS for feature testing

Test Setup     Prepare Environment and start logging for feature    CB008132
Test Teardown     Cleanup Environment and stop logging for the feature

Suite Teardown     Run Keywords
...                  Switch off ues pdu port
...                  Collect logs in case of suite setup failure

*** Test Cases ***

[1]CB008132_TC_B02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_FDD_FDM_ON
    Scenario_B02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_FDD_FDM_ON

[1]CB008132_TC_B04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_TDD_FDM_ON
    Scenario_B04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_TDD_FDM_ON

[1]CB008132_TC_B07_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_FDD
    [Tags]    SBTS00
    Scenario_B07_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_FDD
    [Teardown]    Cleanup Environment And Stop Logging For The Feature And Restore Base Scf If Test Fails

[1]CB008132_TC_B08_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_TDD
    [Tags]    SBTS00
    Scenario_B08_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_TDD
    [Teardown]    Cleanup Environment And Stop Logging For The Feature And Restore Base Scf If Test Fails

[1]CB008132_TC_C01_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_FDD
    [Tags]    SBTS00
    Scenario_C01_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_FDD
    [Teardown]    Cleanup environment and stop logging for the feature and restore base SCF

[1]CB008132_TC_C02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_TDD
    [Tags]    SBTS00
    Scenario_C02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_TDD
    [Teardown]    Cleanup environment and stop logging for the feature and restore base SCF

[1]CB008132_TC_C05_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_FDD
    [Tags]    SBTS00
    Scenario_C05_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_FDD
    [Teardown]    Cleanup Environment And Stop Logging For The Feature And Restore Base Scf If Test Fails

[1]CB008132_TC_C06_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_TDD
    [Tags]    SBTS00
    Scenario_C06_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_TDD
    [Teardown]    Cleanup Environment And Stop Logging For The Feature And Restore Base Scf If Test Fails

[1]CB008132_TC_C09_SAS_with_no_interworkings_in_NSA+SA
    EDA02753244_EDA03030618_Dynamic_slice_aware_scheduler_with_low_trafic_DRBs
    [Teardown]    Cleanup Environment And Stop Logging For The Feature And Restore Base Scf If Test Fails
