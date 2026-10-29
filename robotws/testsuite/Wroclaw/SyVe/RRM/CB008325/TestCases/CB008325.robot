*** Settings ***
Documentation
...  UL and DL for feature 7220 ABIP parity
...
...  author/contact: krzysztof.1.wrobel@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.CB008325.TestCases.CB008325
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Prepare Ue Pc Test

Force Tags      CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AEHC_AHIB    STATE_SW_UPLOADED    CRT

*** Test Cases ***
[3]CB007220-A_A-CSI_SA_single_UE_single_carrier_burst_UL_DL
    Given Prepare Environment For Sa Scenario
    And Add scout external execution id to the reporting portal
    And Uplane Pcap Trace Collection Is Started
    And Ue Attached
    Then Start Burst Ul Dl Traffic
    And Stop To Collect Uplane Pcap Trace
    Then Uplane File Is Validated And Checked For Proper Acsi_Quantity
    [Teardown]    Run Keywords    Ue Detach    AND
    ...                           Cleanup The Setup And Collect Logs If The Test Fails

[3][1.0] CB007220-C_A-CSI_NSA_single_UE_single_carrier_low_data
    Given Prepare Environment For Nsa Scenario
    And Add scout external execution id to the reporting portal
    And Uplane Pcap Trace Collection Is Started
    And Ue Attached
    And Start Script Ue Pc Attenuator Jitter
    Then Generate Traffic Vi Ping
    And Stop To Collect Uplane Pcap Trace
    Then Uplane File Is Validated And Checked For Proper Acsi_Quantity
    Then Check The Asp Jitter Tdd Abip
    [Teardown]    Run Keywords    Ue Detach    AND
    ...                           Clear Ue Pc Nsa Test    AND
    ...                           Collect Remote Enb Snapshot If Execution Fails    suite_level=False    AND
    ...                           Cleanup The Setup And Collect Logs If The Test Fails

