*** Settings ***
Documentation
...  Feature  CB008132 - Dynamic Slice aware scheduler
...
...  author/contact: rafal.skrok@nokia.com

Library    testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib
Resource   testsuite/Wroclaw/SyVe/RRM/features/SliceSchedulingScenarios.robot
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager


Suite Setup    Run Keywords
...                  Switch on ues pdu port
...                  Prepare BTS for feature testing

Test Setup     Prepare Environment and start logging for feature    ${BASE_FEATURE}
Test Teardown     Cleanup Environment and stop logging for the feature

Suite Teardown     Run Keywords
...                  Switch off ues pdu port
...                  Collect logs in case of suite setup failure


*** Variables ***
${BASE_FEATURE}     CB008132


*** Test Cases ***
CB009084_TC_C03_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA+SA_mode_FDD
    Scenario_C03_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA+SA_mode_FDD

CB009084_TC_C04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA+SA_mode_TDD
    Scenario_C04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA+SA_mode_TDD
