*** Settings ***
Documentation
...  Feature 5GC000705
...
...  author/contact: sebastian.lupkowski@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.Res705And8806
Library         testsuite.Wroclaw.SyVe.RRM.CB008806.Res8806_ANR
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Update swconfig and prepare source gNB
Test Setup       Prepare UE and start logging
Test Teardown    Run Keywords    Cleanup the setup and collect logs if the test failed    AND
                 ...    Make Sure Ue Actions Are Cleared
Suite Teardown   Cleanup Environment and Collect snapshot if execution fails

Force Tags        CLOUD_5G_CLASSICAL_SA_ANDROID_ASIL_ABIO_AHIB    STATE_SW_UPLOADED    CRT    RAN_5G    RAN_5G_MP
...               SBTS00    SBTS22R3    SBTS22R4    SBTS23R1    SBTS23R2

*** Test Cases ***
CB008806-A_5GC000705-A#B7 Intra-frequency inter-gNB NG based Handover interaction with ANR
    Given Commissioned Target gNB With Feature CB008806 Anr Activated
    And Commissioned Source gNB With CB008806 Anr Activated
    And Target gNB is in OnAir state
    And Source gNB is in OnAir state
    And Extended Log Reporting For Anr On Source Is Set
    And Add scout external execution id to the reporting portal
    And Environment For Anr Test Is Prepared
    When Ue Data Traffic Is Started
    And Anr Handover Is Performed
    Then Cp Ue Log From Source Is Downloaded
    And Cp Ue Log From Source Contains Anr Entry
