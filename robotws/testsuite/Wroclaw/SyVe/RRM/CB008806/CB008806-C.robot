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
                 ...    Make Sure Ue Actions Are Cleared
Suite Teardown   Cleanup Environment and Collect snapshot if execution fails

Force Tags        CLOUD_5G_CLASSICAL_SA_ANDROID_ASIKR_ABILB1_AZQI    STATE_SW_UPLOADED    CRT    RAN_5G    RAN_5G_MP
...               SBTS00    SBTS22R3    SBTS22R4    SBTS23R1    SBTS23R2

*** Test Cases ***
CB008806-C_5GC000705-C#C1 Unsuccessful inta-gNB handover based on A3 A5 measurements
    Given Commissioned Target gNB With Feature 5GC000705 Activated
    And Target gNB is in OnAir state
    And Add scout external execution id to the reporting portal
    And Environment For Unsuccessful Handover Is Prepared
    When Pcap Capturing Is Started On Target gNB
    And Ue Data Traffic Is Started
    And Intra Handover Is Performed
    Then Pcap Capturing Is Stopped On Target gNB
    And No Successful Handover Attempt Log Is Stored In Pcap
