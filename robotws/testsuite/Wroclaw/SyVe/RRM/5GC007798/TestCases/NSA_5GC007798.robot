*** Settings ***
Documentation
...  7798 feature auto test
...
...  author/contact: jakub.kaszczyszyn@nokia.com based on krzysztof.1.wrobel@nokia.com's work with 7220 feature

Library         testsuite.Wroclaw.SyVe.RRM.5GC007798.TestCases.Res7798
Library         taf.ue
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation                 AND
...                            Right Scf File is Chosen And Gnb Commissioned  20MHz  enabled  ol    AND
...                            Prepare Enb                                                          AND
...                            Set No Attenuation On Gnb Ports Cell 6                               AND
...                            Set No Attenuation On Lte Ports

Suite Teardown    Collect Snapshots If Suite Fails
Test Setup    Prepare Ue And Start Logging
Test Teardown    Run keywords    Stop And Collect Logs If Test Fails and do the common step    AND
                 ...             Cleanup Ue Traffic Files

Force Tags      CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHIB_2xAHLOA_ENB    STATE_SW_UPLOADED
...             RAN_5G    CRT    SBTS00    RAN_5G_MP    RAN_5G_MP_CUSTOMER    SBTS23R2    SBTS23R3    SBTS23R1
...             SBTS23R4

*** Test Cases ***
CB007798-A_A-CSI_NSA_single_UE_single_carrier_20MHz_FDD_with_traffic_cdrx_enabled_OL
    Flags are set For Test Uci Only Disabled
    Right Scf File is Chosen And Gnb Commissioned  20MHz  enabled  ol
    Gnb Is Up And Running
    Add scout external execution id to the reporting portal
    Not Needed Cells For Test Nsa Are Blocked
    Uplane Pcap Trace Collecting Is Started
    Ue Attached
    Data Traffic Open Loop Is Launched
    Uplane Pcap Trace Collecting Is Stopped
    Uplane File Open Loop Is Validated

CB007798-E_A-CSI_NSA_single_UE_single_carrier_256QAM_UL_and_DMRS_FDM
    Flags are set For Test Uci Only Disabled
    Right Scf File is Chosen And Gnb Commissioned  20MHz  DMRS  FDM
    Gnb Is Up And Running
    Add scout external execution id to the reporting portal
    Not Needed Cells For Test Nsa Are Blocked
    Uplane Pcap Trace Collecting Is Started
    Ue Attached
    Data Traffic In Dl And Ul For The Ue Is Launched
    Uplane Pcap Trace Collecting Is Stopped
    Uplane File Close Loop Is Validated
