*** Settings ***
Documentation
...  Feature CB008120
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
...               SBTS00    SBTS23R1    SBTS23R2    SBTS23R4

*** Test Cases ***
USCB008120-A#B1 Successful Slice configuration with SST value from new range
    Given Commissioned Source gNB With Feature CB008120 Activated
    And Source gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    When Pcap Capturing Is Started On Source gNB
    And Successful Attach Is Performed
    Then Pcap Capturing Is Stopped On Source gNB
    And Successful Attach Attempt Log Is Stored In Pcap

USCB008120-A#B3 Successful NG based handover with Slice configuration with SST value from new range
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
    And Counters Are Incremented For Successful Ng Ho

USCB008120-A#B2 Successful Xn handover with Slice configuration with SST value from new range
    Given Commissioned Target gNB With Xn Handover Enabled
    And Commissioned Source gNB With Xn Handover Enabled
    And Target gNB is in OnAir state
    And Source gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Successful Handover Is Prepared
    When Pcap Capturing Is Started On Source And Target gNB
    And Ue Data Traffic Is Started
    And Handover Is Performed
    Then Pcap Capturing Is Stopped On Source And Target gNB
    And Successful Xnap Handover Attempt Log Is Stored In Pcap
