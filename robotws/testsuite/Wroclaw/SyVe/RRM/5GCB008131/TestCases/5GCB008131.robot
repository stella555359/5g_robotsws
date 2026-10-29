*** Settings ***
Documentation
...  8131 feature auto test
...
...  author/contact: jakub.kaszczyszyn@nokia.com based on krzysztof.1.wrobel@nokia.com's work with 7220 feature

Library         testsuite.Wroclaw.SyVe.RRM.5GCB008131.TestCases.Res8131
Library         taf.ue
Library         testsuite.Wroclaw.SyVe.RRM.resources.Rfrl   WITH NAME   rfrl
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Force Tags      CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AEHC_AHIB    STATE_SW_UPLOADED    CRT
...             RAN_5G    SBTS00    RAN_5G_MP    RAN_5G_MP_CUSTOMER    SBTS23R2    SBTS23R4    SBTS23R1

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation    AND
               ...             Erase Unused And Update Swconfig Flags                  AND
               ...             Commission Gnb And Wait For Bts To Reach On Air State
Suite Teardown    Collect Snapshot

Test Setup    Prepare Environment
Test Teardown  Run Keywords
               ...    Data Traffic For The Ue Is Stopped And Ue Detached    AND
               ...    Try To Remove Traffic Files    AND
               ...    Common Step Trigger

*** Test Cases ***
CB008131-B_TC01_A-CSI_handling_SA_PCell_FDD_20Mhz_SCell_TDD_100Mhz
    Given Gnb Is Up And Running
    And Add scout external execution id to the reporting portal
    Then Ue Attached
    When Higher And Lower Load Are Launched And Secondary Cell Addition Is Verified By Tput Check
    Then Uplane File Is Validated And Checked For Proper Acsi Quantity
    When Higher Load Is Stopped And Secondary Cell Removal Is Verified By Tput Check
    Then Uplane File Is Validated And Checked For Proper Acsi Quantity
    When Higher Load Is Launched Again And Secondary Cell Addition Is Verified By Tput Check
    Then Uplane File Is Validated And Checked For Proper Acsi Quantity
