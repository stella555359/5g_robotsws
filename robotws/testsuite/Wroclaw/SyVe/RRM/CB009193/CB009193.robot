*** Settings ***
Documentation
...  Feature  CB009193 - RU Parity - cmwave step 3
...
...  author/contact: maciej.futyma@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.Res9926and9193
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot
Library         ute_ue

Suite Setup    Prepare Suite  CB009193

Test Setup     Prepare Test  CB009193

Test Teardown     Teardown Test

Suite Teardown   Teardown Suite

*** Test Cases ***
CB008701_16DL_4Ues_noRankDowngrade
    [Setup]    Run Keywords  Prepare Four Active Ues
    ...                      AND  Prepare Test  feature=CB009193
    Add scout external execution id to the reporting portal
    Given Multiple ues are attached to the cell
    When Data TX started for the all ues
    And Collect TTI Traces
    Then Check Values On 4 Ues No Rank Downgrade

CB009007-A_01_Basic case for enable PDSCH scheduling on special slot BI6,4 with beamforming
    [Setup]    Run Keywords  Prepare One Active Ue
    ...                      AND  Prepare Test  feature=CB009193
    Add scout external execution id to the reporting portal
    Given Multiple ues are attached to the cell
    When Data TX started for the all ues
    And Collect TTI Traces
    Then Check Values On Basic Case

CB008360-B Two UEs (rank 2) with non-GBR high load are paired in two subcells
    [Setup]    Run Keywords  Prepare Two Active Ues
    ...                      AND  Prepare Test  feature=CB009193
    Add scout external execution id to the reporting portal
    Given Multiple ues are attached to the cell
    When Data RX started for the all ues
    And Collect TTI Traces
    Then Check Values On Two Ues With Non Gbr
