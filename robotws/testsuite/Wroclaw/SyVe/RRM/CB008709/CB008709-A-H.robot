*** Settings ***
Documentation
...  Feature  CB008709 - Dynamic Slice aware scheduler in uplink
...
...  author/contact: rafal.skrok@nokia.com

Library    testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib
Resource   testsuite/Wroclaw/SyVe/RRM/features/SliceSchedulingScenarios.robot
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager


Suite Setup    Run Keywords
...                  Switch on ues pdu port
...                  Prepare BTS for feature testing

Test Setup     Prepare Environment and start logging for feature    ${UL_SAS_FEATURE}
Test Teardown     Cleanup Environment and stop logging for the feature

Suite Teardown     Run Keywords
...                  Switch off ues pdu port
...                  Collect logs in case of suite setup failure


*** Variables ***
${UL_SAS_FEATURE}     CB008709


*** Test Cases ***
CB008709-A-AUTO_SLICE_AWARE_UPLINK_SCHEDULER_FOR_THE_SPECIAL_CASE_OF_SINGLE_RG_PER_UE
    Scenario_CB008709-A#AUTO_SLICE_AWARE_UPLINK_SCHEDULER_FOR_THE_SPECIAL_CASE_OF_SINGLE_RG_PER_UE


CB008709-H-AUTO_SLICE_AWARE_SCHEDULER_NBR
    [Setup]     Run Keywords
    ...         Prepare Environment and start logging for feature    ${UL_SAS_FEATURE}    AND
    ...         Commission UL SAS feature with NBR interworking
    Scenario_CB008709-H-AUTO_SLICE_AWARE_UPLINK_SCHEDULER_INTERACTS_WITH_NBR
