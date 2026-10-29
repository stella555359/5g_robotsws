*** Settings ***
Documentation
...  Feature  CB009926 - RU Parity - cmwave step 2
...
...  author/contact: maciej.futyma@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.features.Res9926and9193
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot
Library         ute_ue

Suite Setup    Prepare Suite  CB009926

Test Setup     Prepare Test  CB009926

Test Teardown     Teardown Test

Suite Teardown   Teardown Suite

*** Variables ***
${FEATURE}=    CB009926

*** Test Cases ***
CB009359-SR-C_05_NR_only_16DL_8UL_2CC_NR100_NR90_interworking_wth_CB008360
    [Setup]    Run Keywords  Prepare Two Active Ues
    ...                      AND  Prepare Test  CB009926
    Add scout external execution id to the reporting portal
    Given Multiple ues are attached to the cell
    When Data RX started for the all ues
    And Collect TTI Traces
    Then Check Values For Interworking With CB008360
    And Stop Traffic on all ues
    And Multiple Ues Are Detached From Cell
    And Remove TTI Traces
    When Switch Blocked Cells
    And Multiple ues are attached to the cell
    And Data RX started for the all ues
    And Collect TTI Traces
    Then Check Values For Interworking With CB008360
    And Stop Traffic on all ues
    [Teardown]    Run Keywords  Switch Back Blocked Cells
    ...                         Teardown Test

CB008004-SR-CE_002-time_offset_parameter_reconfiguration_in_runtime
    [Setup]    Run Keywords  Prepare One Active Ue
    ...                      AND  Prepare Test  CB009926
    Add scout external execution id to the reporting portal
    Given Activate First Offset
    And Multiple ues are attached to the cell
    When Data TX started for the all ues
    And Collect Tti Traces
    Then Check Values For Time Offset Reconfiguration
    And Stop Traffic On All Ues
    And Remove TTI Traces
    When Activate Second Offset
    And Multiple ues are attached to the cell
    And Data TX started for the all ues
    And Collect Tti Traces
    Then Check Values For Time Offset Reconfiguration
    And Stop Traffic On All Ues
    And Remove TTI Traces
    When Activate Third Offset
    And Multiple ues are attached to the cell
    And Data TX started for the all ues
    And Collect Tti Traces
    Then Check Values For Time Offset Reconfiguration
    And Stop Traffic On All Ues
    [Teardown]    Run Keywords  Return To Base Config
    ...                         Teardown Test
