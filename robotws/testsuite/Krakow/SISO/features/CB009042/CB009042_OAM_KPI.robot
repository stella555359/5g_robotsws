*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009042 for SA configuration
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com

Library     taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/variables.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed


*** Variables ***
# RU reset KPI
${KPI_51a_b_iterations}    ${10}
&{KPI_51a_b_target}          kpi51a=${240}    kpi51b=${240}    # kpi51b target value is dummy

# RU power reset KPI
${KPI_54a_b_iterations}    ${10}
&{KPI_54a_b_target}          kpi54a=${240}    kpi54b=${240}    # kpi54b target value is dummy

# Cell block and unblock KPI
${KPI_17a_b_iterations}    ${10}
&{KPI_17a_b_target}        kpi17a=${10}    kpi17b=${10}

# BBMOD reset
${KPI_5_iterations}    ${10}
&{KPI_5_target}        kpi5=${270}             # check target if BBMOD other than ABIP


*** Test Cases ***
[1][1.0] Manual_SiSo_SM_KPI_51a_b_RU_reset_downtime
    run_reset_rmod_in_loop    iterations=${KPI_51a_b_iterations}
    ...                       target=&{KPI_51a_b_target}
    ...                       additional_allowed_alarms=${allowed_alarms_during_ru_reset}

[1][1.0] Manual_SiSo_SM_KPI_17a_b _Block_unblock_cell_duration
    run_cell_block_unblock_in_loop    iterations=${KPI_17a_b_iterations}
    ...                               target=&{KPI_17a_b_target}

[1][1.0] Manual_SiSo_SM_KPI_54_Power-on_RU_startup_availability
    run_power_reset_rmod_in_loop    iterations=${KPI_54a_b_iterations}
    ...                             target=&{KPI_54a_b_target}
    ...                             additional_allowed_alarms=${allowed_alarms_during_ru_power_reset}

[1][1.0] Manual_SiSo_SM_KPI5_capacity_module_reset_downtime
    run_reset_bbmod_in_loop    iterations=${KPI_5_iterations}
    ...                        target=&{KPI_5_target}
    ...                        additional_allowed_alarms=${allowed_alarms_during_bbu_reset}
