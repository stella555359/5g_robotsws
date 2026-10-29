*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010498
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com


Library     taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    asir
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   variables.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               list_of_additional_allowed_alarms=${list_of_additional_allowed_alarms}
...               increase_time_for_checking_cells=700
#...               check_truck_roll=${False}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions


*** Variables ***
${iterations}         ${20}
&{target}             kpi1a=${630}    kpi1b=${630}    kpi1c=${630}


*** Test Cases ***
[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    run_site_reset_in_loop    iterations=${iterations}    target=${target}
    ...                       additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                       temp_allowed_alarms=${GNB_RESET_ALLOWED_ALARMS}
    ...                       delay_for_checking_allowed_alarms=${60}
