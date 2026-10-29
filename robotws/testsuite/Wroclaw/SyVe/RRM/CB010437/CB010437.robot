*** Settings ***
Documentation
...  Feature CB010437
...
...  author/contact: sebastian.lupkowski@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.CB010437.Res10437
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Prepare remote gNB
...                            Download nsetapx plugin
Test Setup       Prepare Ues
Test Teardown    Cleanup the setup and collect logs if the test fails
Suite Teardown    Cleanup remote VM

Force Tags     CLOUD_5G_CLASSICAL_SA_ANDROID_ASIBL_ABIAB1_ABIOB2_AQQE_AHCA    STATE_SW_UPLOADED    CRT    RAN_5G
...            RAN_5G_MP
...            SBTS00

*** Test Cases ***
CB010437-A#1 Activation of the PCMD trace content related to CB010437 RIM Remote Interference Management report _ DL mitigation
    Given Commissioned Victim Gnb With Feature CB010437 Activated
    And Commissioned Agressor Gnb With Feature CB006991C Activated
    And Victim Gnb Is In Onair State
    And Agressor Gnb Is In Onair State
    And Victim Ue Is Attached
    And Aggressor Ue Is Attached
    And Add scout external execution id to the reporting portal
    When Syslog Capturing Is Started
    And Pcmd Capturing Is Started
    And Traffic On Victim Ue Is Started
    And Traffic On Aggressor Ue Is Started
    And Syslog Is Being Collected
    Then Syslog Capturing Is Stopped
    And Pcmd Capturing Is Stopped
    And RimRs Report Is In Pcmd
    And RimRs Alarm Is Active
    And RimRsManager Is Stored In Syslog

CB010437-A#5 Deactivation of the PCMD trace content related to CB010437 RIM Remote Interference Management report via actNrRim flag
    Given Commissioned Victim Gnb With RIM Deactivated
    And Commissioned Agressor Gnb With Feature CB006991C Activated
    And Victim Gnb Is In Onair State
    And Agressor Gnb Is In Onair State
    And Victim Ue Is Attached
    And Aggressor Ue Is Attached
    And Add scout external execution id to the reporting portal
    When Syslog Capturing Is Started
    And Traffic On Victim Ue Is Started
    And Traffic On Aggressor Ue Is Started
    And Syslog Is Being Collected
    Then Syslog Capturing Is Stopped
    And RimRs Alarm Is Inactive
    And RimRs Is Not Stored In Syslog
