*** Settings ***
Documentation
...  Feature Power Loop Control 5GC000884
...  author/contact: rafal.skrok@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.5GC000884.Resources884       GALAXY_S21_ULTRA
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot


Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Prepare FDD gnb for 884 feature testing
Test Setup     Prepare Environment and start logging for 884 feature
Test Teardown     Restore base config and cleanup the setup and collect logs if the test fails    FDD
Suite Teardown   Collect snapshot if suite fails

Force Tags        CLOUD_5G_CLASSICAL_SA_2xANDROID_ASIBL_ABIOB1_AHLOA    STATE_SW_UPLOADED    CRT
...               RAN_5G        RAN_5G_FDD    RAN_5G_MP    RAN_5G_MP_CUSTOMER    RAN_5G_FDD_MP
...               SBTS22R4    SBTS23R1    SBTS23R2

*** Test Cases ***
5GC000884-A_PUSCH_Feature_verification_FDD_CPRI_SA
    Scenario Close Loop Power Control    duplex=FDD    ##active_flag=pucchPuschSrs
    Add scout external execution id to the reporting portal
    Tcp Command Check For Selected Parameter Value Actulclosedlooppwrctrl

5GC000884-B_PUCCH_Feature_verification_FDD_CPRI_SA
    Scenario Close Loop Power Control    duplex=FDD    active_flag=pucch
    Add scout external execution id to the reporting portal
    TPC command for downlink are sent properly according to current radio conditions

5GC000884-C_SRS_Feature_verification_FDD_CPRI_SA
    Scenario Close Loop Power Control    duplex=FDD    active_flag=puschSrs
    Add scout external execution id to the reporting portal
    TPC command and SRS are sent properly according to current radio conditions
