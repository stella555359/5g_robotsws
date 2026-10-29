*** Settings ***
Documentation
...  Feature CNI91473
...
...  author/contact: maciej.futyma@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.CNI91473.ResCni91473
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup       Prepare bts for testing

Test Setup      Prepare default configuration
Test Teardown    Make sure logs collection and traffic stopped if test fails

Suite Teardown    Cleanup the setup and collect logs if the suite fails

*** Test Cases ***
[1]CNI-91473_01_Fullpower_Mode_Enabled_For_PC1.5
    Add scout external execution id to the reporting portal
    Given Set Attenuation For RU
    When Start Tcpdump Capturing On Gnb
      And Attach Ue
    Then Tcpdump Capturing Is Stopped And Downloaded From Gnb
      And Expected Power Mod Log Is Stored In Pcap
    Given UE throughput started
    When Collect BIP logs on gnb
      And Check Bip Logs For High Attenuation
      And Change Full Power Mode
    Then Collect BIP logs on gnb
      And Check Bip Logs For Low Attenuation
