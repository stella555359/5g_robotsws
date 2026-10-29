*** Settings ***
Documentation
...  Feature  CB007134-5G-CL_CB008132_Slice_aware_scheduler
...
...  author/contact: rafal.skrok@nokia.com

Library    testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib
Resource   testsuite/Wroclaw/SyVe/RRM/features/SliceSchedulingScenarios.robot
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager

Suite Setup    Run Keywords
...                  Switch on ues pdu port
...                  Prepare bts for feature parity 7134 testing

Test Setup     Prepare Environment and start logging for feature    CB007134
Test Teardown     Cleanup Environment and stop logging for the feature

Suite Teardown     Run Keywords
...                  Switch off ues pdu port
...                  Collect logs in case of suite setup failure

*** Test Cases ***

[2]CB008132_TC_B04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_TDD_FDM_ON
    Scenario_B04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_TDD_FDM_ON

[2]CB008132_TC_B08_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_TDD
    Scenario_B08_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_TDD
    [Teardown]    Cleanup Environment And Stop Logging For The Feature And Restore Base Scf If Test Fails

[2]CB008132_TC_C02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_TDD
    Scenario_C02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_TDD
    [Teardown]    Cleanup environment and stop logging for the feature and restore base SCF

[2]CB008132_TC_C06_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_TDD
    Scenario_C06_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_TDD
    [Teardown]    Cleanup Environment And Stop Logging For The Feature And Restore Base Scf If Test Fails
