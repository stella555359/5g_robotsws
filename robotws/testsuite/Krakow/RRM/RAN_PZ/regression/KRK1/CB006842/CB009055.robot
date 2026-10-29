*** Settings ***
Documentation
...   author: Julia Luszcz, Agnieszka Bylica
...   contact: julia.luszcz@nokia.com, agnieszka.bylica@nokia.com
...   maintainer/contact: Agnieszka Bylica / agnieszka.bylica@nokia.com
...   Test suite for testing of feature CB006842 - the energy saving mode on ASiR


Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    asir_operations
Library     resources/resources.py
Resource    resources/resources.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown


*** Variables ***
${interval}                 15min
${main_antenna_id}          ${1}
${chained_antenna_id}       ${2}
@{antenna_ids}              ${main_antenna_id}    ${chained_antenna_id}
${time}                     6min


*** Test Cases ***
[1][1.0] CB006842_A_Activation_Deactivation_of_Energy_Consumption_Measurement_collection_via_Webem
    [Setup]     common_setups_and_teardowns.Common Preconditions
    activate_energy_consumption_measurements    interval=${interval}
    ${start_time}    ${stop_time}    gnb_counter.Wait for next PM period    interval=${interval}
    Sleep    1min    reason=Waiting for counters to update...
    resources.Verify ASIR counters are set       interval=${interval}
    ...                                                         start_timestamp=${start_time}
    ...                                                         stop_timestamp=${stop_time}
    resources.Verify summary counters are set    interval=${interval}
    ...                                                         start_timestamp=${start_time}
    ...                                                         stop_timestamp=${stop_time}
    [Teardown]  Run Keywords        deactivate_energy_consumption_measurements
    ...                             AND
    ...                             common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed


[1][1.0] CB006842_C_Activate_pRRH_load-based_power_saving_on_an_ASiR-sHUB
    [Setup]     Run Keywords         common_setups_and_teardowns.Common Preconditions
    ...                              AND
    ...                              activate_energy_saving_feature
    ${antennas}    asir_operations.Get All Antenna Ids
    asir_operations.Verify Antennas Are Enabled    ant_ids=${antennas}
    block_all_cells_connected_to_antenna    ant_id=${main_antenna_id}
    block_all_cells_connected_to_antenna    ant_id=${chained_antenna_id}
    Sleep    ${time}    reason=Waiting for the energy saving feature to turn off antennas...
    asir_operations.Verify Antennas Are Disabled    ant_ids=@{antenna_ids}
    [Teardown]  Run Keywords        unblock_all_cells_connected_to_antenna    ant_id=${main_antenna_id}
    ...                             AND
    ...                             unblock_all_cells_connected_to_antenna    ant_id=${chained_antenna_id}
    ...                             AND
    ...                             Wait Until Keyword Succeeds    5min    10s    gnb_cell.Verify All Cell Status
    ...                             AND
    ...                             deactivate_energy_saving_feature
    ...                             AND
    ...                             common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
