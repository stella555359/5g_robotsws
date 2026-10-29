*** Settings ***
Documentation
...  7798 feature auto test
...
...  author/contact: jakub.kaszczyszyn@nokia.com based on krzysztof.1.wrobel@nokia.com's work with 7220 feature

Library         testsuite.Wroclaw.SyVe.RRM.5GC007798.TestCases.Res7798
Library         taf.ue
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot


Test Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation    AND
...                            Prepare Ue And Start Logging                            AND
...                            Set No Attenuation On Gnb Ports Cell 6

Test Teardown    Run keywords    Stop And Collect Logs If Test Fails And Do the common step    AND
                 ...             Make Sure Nsa Cell Is Unblocked                               AND
                 ...             Attenuation Scell Is Set To Maximum                           AND
                 ...             Cleanup Ue Traffic Files

Force Tags      CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHIB_2xAHLOA_ENB    STATE_SW_UPLOADED
...             RAN_5G    CRT    SBTS00    RAN_5G_MP    RAN_5G_MP_CUSTOMER    SBTS23R2    SBTS23R3    SBTS23R1
...             SBTS23R4

*** Test Cases ***
CB007798-B_TC01_A-CSI_SA_single_UE_F+F_CA_20MHz_PSCell_1SCell
    Flags are set For Test Uci Only Disabled
    Right Scf File is Chosen And Gnb Commissioned  20MHz  PSCell  1SCell
    Gnb Is Up And Running
    Add scout external execution id to the reporting portal
    Attenuation Scell Is Set To High
    Make Sure Nsa Cell Is Blocked
    Uplane Pcap Trace Collecting Is Started
    Ue Attached
    Attenuation Scell Is Set To Minimum
    Data Traffic In Dl And ul For The Ue Is Launched Scell
    Uplane Pcap Trace Collecting Is Stopped
    Uplane File Close Loop Is Validated
    Traffic Pcell Scell is Checked
