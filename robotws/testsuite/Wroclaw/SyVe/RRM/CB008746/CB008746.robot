*** Settings ***
Documentation
...  Feature  CB008746 - SPID based NSA slicing
...
...  author/contact: maciej.futyma@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.SasSpidDssHoPoolingLib
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Prepare Suite

Test Setup     Prepare Test

Test Teardown     Teardown Test

Suite Teardown   Teardown Suite

*** Test Cases ***
[1]CB008746-A#B5_ONLINE_ACTIVATION_DEACTIVATION_OF_SPID_BASED_NSA_SLICING_FEATURE_WEBEM
    Add scout external execution id to the reporting portal
    Given Multiple ues are attached to the cell
    When Data tx started for the all ues
      And Plmn Pm Counters Are Collected Before Feature Activation
    Then Plmn Pm Counters Meets Quota Before Feature Activation
    When Configuration Is Changed With Feature Activated
      And Spid Pm Counters Are Collected After Activation
    Then Spid Pm Counters Meets Quota For Online Activation
    When Change configuration to deactivate feature
      And Plmn Pm Counters Are Collected After Feature Deactivation
    Then Plmn Pm Counters Meets Quota After Feature Deactivation

CB008746-A#IWK10_INTER_GNB_MOBILITY_WITH_SPID_BASED_NSA_SLICING_ENABLED
    [Setup]    Run Keywords  Prepare test
    ...                      Environment For Successful Handover Is Prepared
    Add scout external execution id to the reporting portal
    Given Multiple Ues Are Detached From Cell
      And Configuration Is Changed With Feature Activated
    When Multiple ues are attached to the cell
      And Data tx started for the all ues
      And Spid Pm Counters Are Collected For Source Gnb
    Then Spid Pm Counters Meets Quota For Handover On Source Gnb
    When Pcap capturing is started on source gNB
      And Handover is performed
    Then Pcap Capturing Is Stopped And Downloaded From Source Gnb
      And Successful Handover Attempt Log Is Stored In Pcap
    When Spid Pm Counters Are Collected For Target Gnb
    Then Spid Pm Counters Meets Quota For Handover On Target Gnb
    [Teardown]   Run Keywords  Stop Tcp Dump If Test Failed
    ...                        Teardown 2 NSA BTSs test

[1]CB008746-B#IWK3_SAS_WITH_DSS_ENABLED_FDD_ONLY_15_MHz
    [Setup]    Run Keywords  Prepare test
    ...                      Environment For DSS test is prepared
    Add scout external execution id to the reporting portal
    Given Multiple ues are attached to the cell
    When Data tx started for the all ues
      And Spid Pm Counters Are Collected For DSS Case
    Then Spid Pm Counters Meets Quota
    [Teardown]   Run Keywords  Teardown 2 NSA BTSs test
    ...                        Restore Default Config After DSS Test