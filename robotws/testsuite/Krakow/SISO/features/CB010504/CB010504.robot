*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010504
...   author: Julia Luszcz
...   contact: julia.luszcz@nokia.com


Library     taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    asir
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   variables.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${additional_allowed_alarms}

Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords    gnblog.collect_snapshot
...               AND             Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
&{target}                       kpi1a=${630}    kpi1b=${630}    kpi1c=${630}
${iterations}                   ${20}
${CIT_iterations}                   ${3}


*** Test Cases ***
OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    run_site_reset_in_loop    iterations=${iterations}    target=${target}
    ...                       additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                       temp_allowed_alarms=${GNB_RESET_ALLOWED_ALARMS}


[1][1.0] [1.0]SiSo_Auto_BTS_site_reset
    run_site_reset_in_loop    iterations=${CIT_iterations}    target=${target}
    ...                       additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                       temp_allowed_alarms=${GNB_RESET_ALLOWED_ALARMS}
