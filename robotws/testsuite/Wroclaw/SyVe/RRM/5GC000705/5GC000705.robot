*** Settings ***
Documentation
...  Feature 5GC000705
...
...  author/contact: sebastian.lupkowski@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.Res705And8806
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Update swconfig and prepare source gNB
Test Setup       Prepare UE and start logging
Test Teardown    Run Keywords    Cleanup the setup and collect logs if the test failed    AND
                 ...     Make Sure Ue Actions Are Cleared
Suite Teardown    Cleanup Environment and Collect snapshot if execution fails

Force Tags        CLOUD_5G_CLASSICAL_SA_ANDROID_ASIKR_ABILB1_AZQI    STATE_SW_UPLOADED    CRT    RAN_5G    RAN_5G_MP
...               SBTS00    SBTS22R3    SBTS23R4    SBTS23R1    SBTS23R2

*** Test Cases ***
5GC000705-B#B7 Successful inter-gNB Ng based Handover with blind SCells addition after handover completion (5GC000711 dependent)
    Given Commissioned Target gNB With Feature 5GC000705 Activated with blind Scell addition
    And Commissioned Source gNB With Feature 5GC000705 Activated with blind Scell addition
    And Target gNB is in OnAir state
    And Source gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    When Pcap Capturing Is Started On Source And Target gNB
    And Slave Pcap Capturing Is Started
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Slave Pcap Capturing Is Stopped
    And Successful Handover with blind Scell addition attempt Log Is Stored In Pcap

5GC000705-A#B2 Deactivation of the feature 5GC000705 Intra and Inter-frequency handover via NG
    Given Commissioned Target gNB With Feature 5GC000705 Activated
    And Target gNB is in OnAir state
    And Commissioned Source gNB With Feature 5GC000705 Activated
    And Source gNB is in OnAir state
    When Parameters For Ngap Handover Are Deactivated
    And gNB is Not Restarted
    And Target gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    And Pcap Capturing Is Started On Source And Target gNB
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Unsuccessful Handover Attempt Log Is Stored In Pcap

5GC000705-A#B1 Activation and configuration of the feature 5GC000705 Intra and Inter-frequency handover via NG
    Given Commissioned Target gNB With Feature 5GC000705 Deactivated
    And Target gNB is in OnAir state
    And Commissioned Source Gnb With Feature 5GC000705 Activated
    And Source gNB is in OnAir state
    When Parameters For Ngap Handover Are Activated
    And gNB is Not Restarted
    And Target gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    And Pcap Capturing Is Started On Source And Target gNB
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Successful Handover Attempt Log Is Stored In Pcap

5GC000705 - Successful Inter-gNB NG based Handover based on A3 A5 measurements with indirect DL data forwarding (5GC000711 dependent)
    Given Commissioned Target gNB With Feature 5GC000705 Activated
    And Commissioned Source gNB With Feature 5GC000705 Activated
    And Target gNB is in OnAir state
    And Source gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    When Pcap Capturing Is Started On Source And Target gNB
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Successful Handover Attempt Log Is Stored In Pcap
    And Counters Are Incremented AB3

5GC000705 - Handover preparation rejection (5GC000711 dependent)
    Given Commissioned Target gNB With Feature 5GC000705 Activated with reject handover preparation set
    And Target gNB is in OnAir state
    And Commissioned Source gNB With Feature 5GC000705 Activated
    And Source gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    When Pcap Capturing Is Started On Source And Target gNB
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Handover Preparation Rejection Attempt Log Is Stored In Pcap
    And Counter Is Incremented AEC1
