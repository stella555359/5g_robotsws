*** Settings ***
Documentation
...  Feature EDA02617033
...
...  author/contact: sebastian.lupkowski@nokia.com

Library      testsuite.Wroclaw.SyVe.RRM.CB008120.Res8120
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot


Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Update swconfig and prepare source gNB
Test Setup       Prepare UE and start logging
Test Teardown    Cleanup the setup and collect logs if the test fails
Suite Teardown   Cleanup Environment and Collect snapshot if execution fails

Force Tags        CLOUD_5G_CLASSICAL_SA_ANDROID_ASIML_ABIOB1_AZQO    STATE_SW_UPLOADED    CRT    RAN_5G    RAN_5G_MP
...               SBTS00    SBTS23R2

*** Test Cases ***
Successful intra-frequency NG based handover with per slice counter incrementation
    Given Commissioned Target gNB With Feature CB008120 Activated
    And Commissioned Source gNB With Feature CB008120 Activated
    And Target gNB is in OnAir state
    And Source gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    When Pcap Capturing Is Started On Source And Target gNB
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Successful Ngap Handover Attempt Log Is Stored In Pcap
    And Hanover Per Slice Counters Are Incremented On Source
