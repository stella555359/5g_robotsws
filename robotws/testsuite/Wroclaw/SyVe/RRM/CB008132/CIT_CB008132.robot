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
...                  Prepare SA BTS for feature testing

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
