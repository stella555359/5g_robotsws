*** Settings ***
Documentation
...  Feature CB006991
...
...  author/contact: sebastian.lupkowski@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.CB006991.Res6991
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Update swconfig flags on victim
...                            Prepare remote gNB
Test Setup        Prepare Ues
Test Teardown     Cleanup the setup and collect logs if the test fails
Suite Teardown    Cleanup remote VM

Force Tags     CLOUD_5G_CLASSICAL_SA_ANDROID_ASIBL_ABIAB1_ABIOB2_AQQE_AHCA    STATE_SW_UPLOADED    CRT    RAN_5G
...            RAN_5G_MP
...            SBTS00    SBTS23R2    SBTS23R4

*** Test Cases ***
CB006991-A_TC01_Start_RIM-RS_transmission_regardless_of_RI_detection
    Given Commission Victim Gnb With Feature CB006991 Activated To Onair
    And Victim Ue Is Attached
    And Add scout external execution id to the reporting portal
    When Syslog Capturing Is Started
    And Traffic On Victim Ue Is Started
    And Syslog Is Being Collected
    Then Syslog Capturing Is Stopped
    And RimRsSendReq Is Stored In Syslog

CB006991-C_TC06_Start_RIM-RS_Detection_with_eCPRI_RF
    Given Commissioned Victim Gnb With Feature CB006991C Activated
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
    And RimRs Alarm Is Active
    And RimRsManager Is Stored In Syslog

CB006991-D_TC09_Starts_DL_mitigation_based_on_single_detected_RIM-RS_type_1_signal
    Given Commissioned Victim Gnb With Feature CB006991C Activated
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
    And RimRs Alarm Is Active
    And DlMitigation Is Stored In Syslog
