*** Settings ***
Documentation
...  Feature  CB008709 - Dynamic Slice aware scheduler in uplink
...
...  author/contact: rafal.skrok@nokia.com/sylwia.pawlak@nokia.com

Library    testsuite.Wroclaw.SyVe.RRM.CB008709.Res8709Tmo

Resource   testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot


Suite Setup   Prepare BTS for feature testing

Test Setup     Prepare Environment and start logging
Test Teardown     Cleanup Environment and stop logging for the feature

Suite Teardown     Collect logs in case of suite setup failure


*** Test Cases ***

CB008709-A-TMO_SLICE_AWARE_UPLINK_SCHEDULER_FOR_THE_SPECIAL_CASE_OF_SINGLE_RG_PER_UE
     Given GNB is up and running in a SA NSA mode in TDD with uplink SAS enabled with proper quotas for NRRGs
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
    When Data Rx of the nonGBR DRBs is started for the UEs at different times
    Then PM counters for uplink are checked to be collected when tput was active with achieved share per NRRG
      And Data tput is stopped and UEs are detached

