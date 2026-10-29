*** Settings ***
Documentation
...  Feature EDA02554471
...
...  author/contact: sebastian.lupkowski@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.Res705And8806
Library         testsuite.Wroclaw.SyVe.RRM.EDA02554471.ResEda02554471
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Update swconfig and prepare source gNB
Test Setup       Prepare UE and start logging
Test Teardown    Cleanup the setup and collect logs if the test failed
Suite Teardown   Cleanup Environment and Collect snapshot if execution fails

Force Tags        CLOUD_5G_CLASSICAL_SA_ANDROID_ASIKR_ABILB1_AZQI    STATE_SW_UPLOADED    CRT    RAN_5G    RAN_5G_MP
...               SBTS00    SBTS23R2

*** Test Cases ***
Successful Inter-gNB NG based Handover with gNBs having different TAC
    Given Commissioned Target gNB With Feature 5GC000705 Activated
    And Commissioned Source gNB With Feature 5GC000705 Activated
    And Target gNB is in OnAir state
    And Source gNB is in OnAir state
    And Commissioned Source gNB With Adj Nrplmnset Sa
    And Target gNB is in OnAir state
    And Source gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    When Pcap Capturing Is Started On Source And Target gNB
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Successful Handover Attempt Log Is Stored In Pcap
    And Tac Entry Is Stored In Pcap From Source
    And Counters Are Incremented AB3
    And Counters Are Incremented AB3 CB008806
