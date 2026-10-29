*** Settings ***
Documentation
...  Feature 5GC001294
...  author/contact: rafal.skrok@nokia.com

Library      testsuite.Wroclaw.SyVe.RRM.5GC001294.TestCases.Resources1294
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Library         ute_ue
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot
Force Tags      CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AZQO_FXED_ENB    STATE_SW_UPLOADED
...             CIT    RAN_5G    RAN_5G_TDD    RAN_5G_MP    RAN_5G_MP_CUSTOMER    RAN_5G_TDD_MP
...             SBTS00    SBTS23R4    SBTS23R1    SBTS23R2

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
               ...    Prepare eNB
               ...    Commission gnb and wait for bts to reach on air state
               ...    Prepare neighbouring gnb
Test Setup    Run Keywords
              ...    Prepare Ue For Test
              ...    Start Bts Log
Test Teardown    Run Keywords
              ...    Detach Ue For Test
              ...    Cleanup Ue traffic files
              ...    Cleanup The Setup And Collect Logs If The Test Fails
Suite Teardown     Run Keywords
                   ...    Collect Remote bts snapshots if execution fails    AND
                   ...    Block All Sites

*** Test Cases ***
5GC001294-AA_TC02_UL_performance_verification_IRC_vs_MRC_non-BF_TDD_eCPRI_1_interference
    Add scout external execution id to the reporting portal
    Start And Check Ul Tput On Asik
    Start And Check Ul Tput On Asib
    Check if tput was better on Asib
