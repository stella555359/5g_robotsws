*** Settings ***
Documentation
...  Feature CB007271
...  author/contact: rafal.skrok@nokia.com

Library      ute_ue
Library      testsuite.Wroclaw.SyVe.RRM.CB007271.Resources7271
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Commission gnb and wait for bts to reach on air state
...                            Commission neighbouring gnb and wait for bts to reach on air state
Test Setup    Prepare Environment and start logging for 7271 feature

Test Teardown  Run Keywords    Make Sure Ue Actions Are Cleared
...                            Cleanup the setup collect logs if the test fails and unblock all cells
Suite Teardown     Collect remote gnb snapshot if suite fails

Force Tags        CLOUD_5G_CLASSICAL_SA_ASILL_ABINB1_AHLOA    STATE_SW_UPLOADED    CRT
...               RAN_5G        RAN_5G_FDD    RAN_5G_MP    RAN_5G_MP_CUSTOMER    RAN_5G_FDD_MP
...               SBTS00        SBTS22R3    SBTS23R4    SBTS23R1    SBTS23R2

*** Test Cases ***
CB007271_TC02_UL_performance_verification_IRC_vs_MRC_non-BF_FDD_CPRI_no_interference
    Add scout external execution id to the reporting portal
    Start and check UL tput ABIL
    Start and check UL tput ABIN
    Check if tput is OK on both TLs
