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


Force Tags      CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AHCA_AEQN    STATE_SW_UPLOADED
...             RAN_5G    SBTS00    RAN_5G_MP    RAN_5G_MP_CUSTOMER    SBTS23R3    SBTS23R1    SBTS23R2
...             SBTS23R4

*** Test Cases ***
[1][1.0] CB007220-CA_A-CSI_SA_single_UE_single_carrier_UL_DL_256QAM
    [Tags]    CIT
    [Setup]   Run keywords    Create connection to gNB and eNB SA      AND
    ...                       Make Sure Nsa Cell Is Blocked            AND
    ...                       Prepare Ue Pc To Test
    Prepare gNB    modulation_qam=256QAM  sansa=SA
    Add scout external execution id to the reporting portal
    Start To Collect Uplane Pcap Trace
    Ue Prepare
    Ue Attached
    Start Brush Traffic Ul Dl
    Stop To Collect Uplane Pcap Trace
    Validate ACSI Uplane Logs
    [Teardown]    Run Keywords    Disconnect from gNB and eNB SA    AND
                  ...             Common step trigger    AND
                  ...             Cleanup Ue traffic files
