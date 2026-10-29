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
USCB008120-C#B2 Successful Release VoNR with no influence of NRDRB_drbInactivityTimerSA
    Given Commissioned Source gNB With Feature CB008120 Activated
    And Source gNB is in OnAir state
    And Nrdrb Drb Inactivity Timer Is Set
    And Add scout external execution id to the reporting portal
    When Pcap Capturing Is Started On Source gNB
    And Successful Attach With VoNR Is Peformed
    And Phone Call Is Established
    And Phone Call Is Ended
    And Drb Timeout Is Reached
    Then Pcap Capturing Is Stopped On Source gNB
    And Successful Release Attempt Log Is Stored In Pcap
