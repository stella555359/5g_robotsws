*** Settings ***
Documentation
...  Feature  CB008709 Uplink SLice Aware Scheduler. DSS and Handover
...
...  author/contact: rafal.skrok@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.SasSpidDssHoPoolingLib
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Prepare UL SAS Suite

Suite Teardown   Teardown Suite

*** Test Cases ***

CB008709-D-AUTO_SLICE_AWARE_UPLINK_SCHEDULER_DSS
    [Setup]    Run Keywords  Prepare test
    ...                      Prepare UL DSS Test
    Add scout external execution id to the reporting portal
    Given Multiple ues are attached to the dss cell
    When Data Rx started for the all ues
      And Pm Counters Are Collected For UL DSS Case
    Then Uplink Spid Pm Counters Meets Quota
    [Teardown]   Run Keywords    Teardown 2 NSA BTSs test
    ...                          Restore Default Config After DSS Test

CB008709-J_INTER_GNB_INTRA_FREQ_HO_NSA_FOR_CONFIGURED_RG_IN_TARGET_CELL
    [Setup]    Run Keywords  Prepare test
    ...                      Environment For Successful Handover Is Prepared
    Add scout external execution id to the reporting portal
    Given Multiple Ues Are Detached From Cell
    When Multiple ues are attached to the cell
      And Data Rx started for the all ues
      And Source GNB PM Counters are collected for UL handover case
    Then Spid Pm Counters Meets Quota For Handover On Source Gnb in Uplink
    When Pcap capturing is started on source gNB
      And Handover is performed
    Then Pcap Capturing Is Stopped And Downloaded From Source Gnb
      And Successful Handover Attempt Log Is Stored In Pcap
    When Target GNB PM Counters are collected for UL handover case
    Then Spid Pm Counters Meets Quota For Handover On Target Gnb in Uplink
    [Teardown]   Run Keywords  Stop Tcp Dump If Test Failed
    ...                        Teardown 2 NSA BTSs test
