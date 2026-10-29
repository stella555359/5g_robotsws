*** Settings ***
Documentation
...  UL and DL for feature 7220
...
...  author/contact: krzysztof.1.wrobel@nokia.com

Resource      testsuite/Wroclaw/SyVe/RRM/5GCB007220/resources/res_7220_A.robot
Library         testsuite.Wroclaw.SyVe.RRM.resources.Rfrl   WITH NAME   rfrl
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot


Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Prepare Ue Pc To Test

Force Tags      CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AHCA_AEQN    STATE_SW_UPLOADED    CRT
...             RAN_5G    RAN_5G_MP    RAN_5G_MP_CUSTOMER    SBTS00    SBTS23R3    SBTS23R1    SBTS23R2
...             SBTS23R4

*** Test Cases ***
[1][1.0] CB007220-CA_A-CSI_SA_single_UE_single_carrier_UL_DL_256QAM
    [Tags]    SBTS22R3
    [Setup]   Run keywords    Create connection to gNB and eNB SA      AND
    ...                       Make Sure Nsa Cell Is Blocked    AND
    ...                       Log Software Info
    Prepare gNB    modulation_qam=256QAM  sansa=SA
    Add scout external execution id to the reporting portal
    Start To Collect Uplane Pcap Trace
    Ue Prepare
    Ue Attached
    Start Brush Traffic Ul Dl
    Stop To Collect Uplane Pcap Trace
    Validate ACSI Uplane Logs
    [Teardown]    Run Keywords    Disconnect from gNB and eNB SA    AND
                  ...             Common Step Trigger               AND
                  ...             Cleanup Ue traffic files

[1][1.0] CB007220-A_A-CSI_SA_single_UE_single_carrier_burst_UL_DL
    [Tags]   SBTS00    SBTS23R2    SBTS22R4    SBTS23R1
    [Setup]   Run keywords    Create connection to gNB and eNB SA      AND
    ...                       Make Sure Nsa Cell Is Blocked
    Prepare gNB    modulation_qam=64QAM  sansa=SA
    Add scout external execution id to the reporting portal
    Start To Collect Uplane Pcap Trace
    Ue Prepare
    Ue Attached
    Start Brush Traffic Ul Dl
    Stop To Collect Uplane Pcap Trace
    Validate ACSI Uplane Logs
    [Teardown]   Run Keywords     Disconnect from gNB and eNB SA     AND
                 ...              Common Step Trigger                AND
                 ...              Cleanup Ue traffic files

[1][1.0] CB007220-C_A-CSI_NSA_single_UE_single_carrier_low_data
    [Tags]   SBTS00    SBTS23R2    SBTS22R4    SBTS23R1
    [Setup]   Run keywords    Create connection to gNB and eNB SA    AND
    ...                       Prepare Enb    AND
    ...                       Make Sure Nsa Cell Is Unblocked    AND
    ...                       Update Swconfig File Abio Nsa    AND
    ...                       Activate Collecting Asp Logs    AND
    ...                       Prepare gNB    modulation_qam=64QAM  sansa=NSA
    Add scout external execution id to the reporting portal
    Start To Collect Uplane Pcap Trace
    Start Script Ue Pc Attenuator Jitter
    Ue Prepare
    Ue Attached
    Generate Traffic Vi Ping
    Stop To Collect Uplane Pcap Trace
    Download Asp Logs
    Check The Asp Jitter Tdd Abio
    Validate ACSI Uplane Logs
    [Teardown]    Run keywords    Disconnect from gNB and eNB SA    AND
    ...                           Collect Remote Enb Snapshot If Execution Fails    suite_level=False    AND
    ...                           Clear Ue Pc Nsa Test              AND
    ...                           Make Sure Nsa Cell Is Blocked     AND
    ...                           Common Step Trigger               AND
    ...                           Cleanup Ue traffic files

[1][1.0] CB007220-D_A-CSI_Average_5G_DL_UL_Throughput
    [Tags]   SBTS00    SBTS23R2    SBTS22R4    SBTS23R1
    [Setup]   Run keywords    Create connection to gNB and eNB SA    AND
    ...                       Prepare Enb    AND
    ...                       Make Sure Nsa Cell Is Unblocked    AND
    ...                       Prepare gNB    modulation_qam=64QAM  sansa=NSA
    Add scout external execution id to the reporting portal
    Ue Prepare
    Ue Attached
    Run Traffic With Defined Parameters For Attenuator Script    param_script= 0 13 3   dl_traffic_check=845
    Run Traffic With Defined Parameters For Attenuator Script    param_script=13 27 3   dl_traffic_check=750
    Run Traffic With Defined Parameters For Attenuator Script    param_script=27 40 3   dl_traffic_check=450
    Run Traffic With Defined Parameters For Attenuator Script    param_script=40 53 3  dl_traffic_check=120
    Ue Detach
    Prepare Gnb With Acsi Turn Off
    Ue Attached
    Run Traffic With Defined Parameters For Attenuator Script    param_script= 0 13 3   dl_traffic_check=845
    Run Traffic With Defined Parameters For Attenuator Script    param_script=13 27 3   dl_traffic_check=750
    Run Traffic With Defined Parameters For Attenuator Script    param_script=27 40 3   dl_traffic_check=450
    Run Traffic With Defined Parameters For Attenuator Script    param_script=40 53 3   dl_traffic_check=120
    [Teardown]    Run keywords    Disconnect from gNB and eNB SA    AND
    ...                           Collect Remote Enb Snapshot If Execution Fails    suite_level=False    AND
    ...                           Clear Ue Pc Nsa Test              AND
    ...                           Make Sure Nsa Cell Is Blocked     AND
    ...                           Common Step Trigger               AND
    ...                           Cleanup Ue traffic files

