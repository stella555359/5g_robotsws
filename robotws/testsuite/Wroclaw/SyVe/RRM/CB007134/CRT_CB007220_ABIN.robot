*** Settings ***
Documentation
...  UL and DL for feature 7220
...
...  author/contact: krzysztof.1.wrobel@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.Res7220And7134    CB007134
Library         ute_ue
Library         testsuite.Wroclaw.SyVe.RRM.resources.Rfrl   WITH NAME   rfrl
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Prepare Ue Pc To Test

Force Tags      CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AHCA_AEQN    STATE_SW_UPLOADED    CRT
...             RAN_5G    RAN_5G_MP    RAN_5G_MP_CUSTOMER    SBTS00    SBTS23R3    SBTS23R1    SBTS23R2    SBTS23R4

*** Test Cases ***
[2][1.0] CB007220-CA_A-CSI_SA_single_UE_single_carrier_UL_DL_256QAM
    [Setup]   Run keywords    Start Syslog Collection      AND
    ...                       Make Sure Nsa Cell Is Blocked    AND
    ...                       Find Scf And Commission Gnb    MRBTS-50440  256QAM  SA    AND
    ...                       Wait Until Gnb Reach Onair State    AND
    ...                       Reboot Ue Askey    AND
    ...                       Check If Acsi Are Enabled In Cells
    Add scout external execution id to the reporting portal
    Start To Collect Uplane Pcap Trace
    Ue Prepare
    Ue Attached
    Start Brush Traffic Ul Dl
    Stop To Collect Uplane Pcap Trace
    Validate ACSI Uplane Logs
    [Teardown]    Run Keywords        Stop Syslog Collection    AND
    ...                               Collect Bts Gnb Snapshot    AND
    ...                               Ue Detach    AND
    ...                               Common Step Trigger    AND
    ...                               Cleanup Ue traffic files

[2][1.0] CB007220-A_A-CSI_SA_single_UE_single_carrier_burst_UL_DL
    [Setup]   Run keywords    Start Syslog Collection      AND
    ...                       Make Sure Nsa Cell Is Blocked    AND
    ...                       Find Scf And Commission Gnb    MRBTS-50440  64QAM  SA    AND
    ...                       Wait Until Gnb Reach Onair State    AND
    ...                       Reboot Ue Askey    AND
    ...                       Check If Acsi Are Enabled In Cells
    Add scout external execution id to the reporting portal
    Start To Collect Uplane Pcap Trace
    Ue Prepare
    Ue Attached
    Start Brush Traffic Ul Dl
    Stop To Collect Uplane Pcap Trace
    Validate ACSI Uplane Logs
    [Teardown]    Run Keywords        Stop Syslog Collection    AND
    ...                               Collect Bts Gnb Snapshot    AND
    ...                               Ue Detach    AND
    ...                               Common Step Trigger    AND
    ...                               Cleanup Ue traffic files

[2][1.0] CB007220-C_A-CSI_NSA_single_UE_single_carrier_low_data
    [Setup]   Run keywords    Prepare Enb    AND
    ...                       Make Sure Nsa Cell Is Unblocked    AND
    ...                       Start Syslog Collection      AND
    ...                       Update Swconfig File Abin Nsa    AND
    ...                       Find Scf And Commission Gnb    MRBTS-50440  64QAM  NSA    AND
    ...                       Wait Until Gnb Reach Onair State    AND
    ...                       Reboot Ue Askey    AND
    ...                       Check If Acsi Are Enabled In Cells
    Add scout external execution id to the reporting portal
    Start To Collect Uplane Pcap Trace
    Start Script Ue Pc Attenuator Jitter
    Ue Prepare
    Ue Attached
    Generate Traffic Vi Ping
    Stop To Collect Uplane Pcap Trace
    Validate ACSI Uplane Logs
    Check The Asp Jitter Tdd Abin
    [Teardown]    Run Keywords        Stop Syslog Collection    AND
    ...                               Collect Bts Gnb Snapshot    AND
    ...                               Collect Remote Enb Snapshot If Execution Fails    suite_level=False    AND
    ...                               Ue Detach    AND
    ...                               Clear Ue Pc Nsa Test              AND
    ...                               Make Sure Nsa Cell Is Blocked     AND
    ...                               Common Step Trigger               AND
    ...                               Cleanup Ue traffic files
