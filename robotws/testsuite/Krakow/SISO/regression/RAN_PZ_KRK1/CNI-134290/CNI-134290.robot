*** Settings ***
Documentation
...   Test suite for testing of CNI-134290
...   author: Radoslaw Serafin
...   contact: radoslaw.serafin@nokia.com


Library     taf.rfrl.common_resources.oam_kpi.report_oam_kpi
Library     taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions


*** Variables ***
${REPORT_TO_REP}      ${True}
${iterations_OAM_KPI_reset_RMODs}           100
${iterations_OAM_KPI_power_reset_RMODs}     100
${iterations_OAM_KPI_power_reset_gNB}       100
${iterations_OAM_KPI_block_unblock_cell}    100


*** Test Cases ***
[1][1.0] CNI-134290_OAM_KPI_reset_RMODs
    [Timeout]    20h

    Set Test Variable    &{target_OAM_KPI_reset_RMODs}    kpi51a=240  kpi51b=240

    Run Reset Rmod in Loop
    ...      iterations=${iterations_OAM_KPI_reset_RMODs}
    ...      target=${target_OAM_KPI_reset_RMODs}
    ...      report_to_rep=${REPORT_TO_REP}

[1][1.0] CNI-134290_OAM_KPI_power_reset_RMODs
    [Timeout]    20h

    Set Test Variable    &{target_OAM_KPI_power_reset_RMODs}    kpi54a=240  kpi54b=240

    Run Power Reset Rmod in Loop
    ...      iterations=${iterations_OAM_KPI_power_reset_RMODs}
    ...      target=${target_OAM_KPI_power_reset_RMODs}
    ...      report_to_rep=${REPORT_TO_REP}

[1][1.0] CNI-134290_OAM_KPI_power_reset_gNB
    [Timeout]    20h

    Set Test Variable    &{target_OAM_KPI_power_reset_gNB}    kpi3=600

    Run BTS Power On in Loop
    ...      iterations=${iterations_OAM_KPI_power_reset_gNB}
    ...      target=${target_OAM_KPI_power_reset_gNB}
    ...      report_to_rep=${REPORT_TO_REP}

[1][1.0] CNI-134290_OAM_KPI_block_unblock_cells
    [Timeout]    20h

    Set Test Variable    &{target_OAM_KPI_block_unblock_cell}    kpi17a=10  kpi17b=10

    Run Cell Block Unblock in Loop
    ...      iterations=${iterations_OAM_KPI_block_unblock_cell}
    ...      target=${target_OAM_KPI_block_unblock_cell}
    ...      report_to_rep=${REPORT_TO_REP}
