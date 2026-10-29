*** Settings ***
Documentation
...  Feature  5GC001118 - Uplink 256QAM
...
...  author/contact: rafal.skrok@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.5GC001118.Res1118
Library         taf.ue
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Make sure mcshark plugin exists
...                            Confirm SW version and make sure BBU modules are enabled after installation
...                            Prepare TDD enb for 1118 feature testing
...                            Prepare TDD gnb for 1118 feature testing

Test Setup     Run Keywords    Prepare Environment and start logging for 1118 feature  AND
...                            Add Enb NSA Build data to the reporting portal

Test Teardown     Cleanup the setup and collect logs if the test fails

Suite Teardown   Collect snapshots if suite fails and log active faults

Force Tags        RAN_5G    SBTS00    CRT


*** Test Cases ***
TC07_Interaction between 256QAM and FR1 DFT-s-OFDM for TDD PUSCH
    [Tags]    CDRT
    Given Cell deployment type is SA Standalone
      And Active Use of Uplink DFT_S_OFDM is activated
      And Uplink 256QAM is activated
      And Add scout external execution id to the reporting portal
      And Ue is attached
      And Data transfer has been started in uplink with both uplink parameters enabled
      And Environment conditions are getting worse
      And L1 common pusch Transform Precoder Flag T is enabled
    When Environment conditions are improving
    Then L1 common pusch Transform Precoder Flag T is disabled and L1 common mcs Table T is max256QAM
      And Data transfer is stopped in uplink with both uplink parameters enabled
      [Teardown]  Run Keywords    Deactivate Use Of Uplink Dft S Ofdm
                  ...             Cleanup the setup and collect logs if the test fails

TC16_5G_UL_and_DL_L1_Throughput_on_non_BF_SA_cell
    [Tags]    CDRT
     Given Cell Deployment type is SA Standalone
      And Uplink 256QAM is deactivated
      And Add scout external execution id to the reporting portal
      And Ue Is Attached
      And Data has been sent in both directions with maximum throughput without 256QAM in uplink
    When Uplink 256QAM is activated
      And Ue Is Attached
      And Data has been sent in both directions with maximum throughput with 256QAM in uplink
    Then Uplink throughput is 133 and nine tenth percent higher with expected gain
      And PUSCH 256TBL PM Counters are updated
      And PUSCH CP RANK2 256TBL PM Counter is updated
      And L1 common modulation order is 256qam and average mcs value is as expected
      And Pm Conters for EDA02715164 are verified

*** Keywords ***

Pm Conters for EDA02715164 are verified
      And New PM counter cycle is started
      And Ue Is Attached
      And Data of the size 1gb has been sent in both directions with maximum throughput with 256QAM in uplink
      And EDA pm counters are collected and verified
