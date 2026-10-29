*** Settings ***
Documentation
...  Feature CNI95601
...
...  author/contact: sebastian.lupkowski@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.CNI95601.ResCni95601
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup       Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation    AND
                  ...             Update swconfig flags on victim    AND
                  ...             Prepare remote gNB    AND
                  ...             Given Commissioned Victim Gnb With Feature CNI95601 Activated     AND
                  ...             Prepare Ues
Suite Teardown    Run Keywords    Cleanup the setup and collect logs if the test fails    AND
                  ...             Cleanup remote VM

Force Tags     CLOUD_5G_CLASSICAL_SA_ANDROID_ASIBL_ABIAB1_ABIOB2_AQQE_AHCA    STATE_SW_UPLOADED    CRT    RAN_5G
...            RAN_5G_MP
...            SBTS00

*** Test Cases ***
CNI-95601#1 - RIM Framework-0 Interwork with CB007113 Uplink BB pooling
    Given Commissioned Agressor Gnb With Feature CB006991C Activated
    And Commissioned Victim Gnb With Feature CNI95601 Activated
    And Victim Gnb Is In Onair State
    And Agressor Gnb Is In Onair State
    And Victim Ue Is Attached
    And Aggressor Ue Is Attached
    And Add scout external execution id to the reporting portal
    When Syslog Capturing Is Started
    And Traffic On Victim Ue Is Started
    And Traffic On Aggressor Ue Is Started
    And RimRi Alarm Is Active
    Then Syslog Capturing Is Stopped
    And RimRiManager Is Stored In Syslog
