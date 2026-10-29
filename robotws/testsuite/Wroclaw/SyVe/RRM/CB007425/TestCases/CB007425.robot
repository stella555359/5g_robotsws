*** Settings ***
Documentation
...  Feature CB007425
...  author/contact: rafal.skrok@nokia.com

Library      testsuite.Wroclaw.SyVe.RRM.CB007425.TestCases.Resources7425
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Library         ute_ue
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Force Tags      CLOUD_5G_CLASSICAL_ASIMR_ABIOB1_AZQO_FXED    STATE_SW_UPLOADED
...             CIT    RAN_5G    RAN_5G_TDD    RAN_5G_MP    RAN_5G_MP_CUSTOMER    RAN_5G_TDD_MP
...             SBTS00    SBTS23R1    SBTS23R2    SBTS23R4

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
               ...    Prepare eNB
               ...    Commission gnb and wait for bts to reach on air state
               ...    Prepare neighbouring gnb
Test Setup    Run Keywords
              ...    Prepare Ue For Test
              ...    Start Bts Log
Test Teardown    Run Keywords
              ...    Detach Ue For Test
              ...    Cleanup The Setup And Collect Logs If The Test Fails
Suite Teardown     Run Keywords
                   ...    Collect Remote bts snapshots if execution fails    AND
                   ...    Collect Snapshot If Suite Fails    AND
                   ...    Block All Sites

*** Test Cases ***
[1]CB007425 TC03 UL performance verification IRC vs MRC non-BF TDD eCPRI 1 interference
    Add scout external execution id to the reporting portal
    Start And Check Ul Tput On Asik
    Start And Check Ul Tput On Asim
    Check if tput was better on Asim
