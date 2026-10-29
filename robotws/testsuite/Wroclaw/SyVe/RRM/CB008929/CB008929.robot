*** Settings ***
Documentation
...  Feature  CB008929 - Uplink 256QAM for ABIL
...
...  author/contact: rafal.skrok@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.CB008929.Res8929
Library         taf.ue
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot


Suite Setup    Run Keywords    Make sure mcshark plugin exists
...                            Confirm SW version and make sure BBU modules are enabled after installation
...                            Prepare TDD gnb for 8929 feature testing
...                            Prepare TDD enb for 8929 feature testing

Test Setup     Prepare Environment and start logging for 8929 feature
Test Teardown     Cleanup the setup and collect logs if the test fails

Suite Teardown   Collect snapshots if suite fails and log active faults

Force Tags        CRT    RAN_5G    SBTS00

*** Test Cases ***
CB008929-B_TC_01_PUSCH_mapping_type_A_co-existence_with_PUSCH_256QAM_for_TDD_SA
    Given Cell deployment type is SA Standalone
      And Uplink 256QAM is activated
      And Pusch Mapping Type A is configured
      And Add scout external execution id to the reporting portal
      And Ue is attached
      And Data transfer has been sent in both directions with mapping type A configured
    When Pusch Mapping Type B is configured
      And Ue is attached
      And Data transfer has been sent in both directions with mapping type B configured
    Then Stable transfers with both mapping types are achieved
    [Teardown]     Run Keywords      Pusch Mapping Type A is configured
    ...                              Cleanup the setup and collect logs if the test fails

CB008929-W_TC_03_Avg_5G_UL_Tput_Non_BF_SA
    Given Cell Deployment Type Is SA Standalone
      And Uplink 256QAM is deactivated
      And Add scout external execution id to the reporting portal
      And Ue is attached
      And Data has been sent in both directions with maximum throughput without 256QAM in uplink
      And Data transfer with changing conditions is started in uplink with uplink 256QAM deactivated
    When Uplink 256QAM is activated
      And ue is attached
      And Data has been sent in both directions with maximum throughput with 256QAM in uplink
      And Data transfer with changing conditions is started in uplink with uplink 256QAM activated
    Then Uplink throughput is 8 and four tenths percent better with expected gain
      And Uplink throughput gain percentage compared to 64QAM is at least as expected
      And PUSCH 256TBL PM Counters are updated
      And PUSCH CP RANK2 256TBL PM Counter is updated
      And L1 common modulation order is 256qam and average mcs value is as expected

C2_UL_throughput_and_coverage_verification_of_adaptive_SU-MIMO_with_2TX_capable_UE_for_4Rx_GoB_beamforming_cells_eCPRI only_and_256QAM_for_PUSCH
    Given Cell deployment type is 2x4 sa standalone with 256QAM
      And Add scout external execution id to the reporting portal
      And Ue is attached
      And Data has been sent with maximum throughput in 2x4 uplink
      And L1 common num CeAxC shows 2 pipes and 256QAM in use
    When Bts Configuration is updated to 4 uplink antenna pipes
      And Ue is attached
      And Data has been sent with maximum throughput in 4x4 uplink
    Then L1 common num CeAxC shows 4 pipes and 256QAM in use
      And Stable transfers with both configurations of antenna pipes are achieved
    [Teardown]     Run Keywords      Restore default BTS configuration if the test fails
    ...                              Cleanup the setup and collect logs if the test fails