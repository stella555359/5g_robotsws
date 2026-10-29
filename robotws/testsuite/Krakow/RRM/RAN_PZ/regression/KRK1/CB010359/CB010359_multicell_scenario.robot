*** Settings ***

Documentation    :copyright: Nokia

Library     ./resources/resources.py
Library     taf.ul.ue.sim.env_setup
Library     ute_wtssim
Library     ta5g_cell_operations
Library     ta5g_commissioning
Library     ta5g_enb
Resource    resources/resources.robot

*** Variables ***
${scfc}              ${CURDIR}/resources/scf.xml
${cus.ini}           ${CURDIR}/resources/cus.ini
${lua}               ${CURDIR}/resources/epc.lua

*** Test Cases ***
USCB010359-A#01_PA_warming_up_in_first_activated_DL_slots_after_Rx-to-Tx_switching_point_multicell_scenario_CUS
    [Setup]   Run Keywords              Set 5G Dummy Interface  scfc_file_path=${scfc}
    ...                                 AND
    ...                                 Add eNB Configuration    ${scfc}
    ...                                 AND
    ...                                 Add Simulator      sim_type=cus    config=${cus.ini}
    ...                                 AND
    ...                                 Add Epc    ${lua}
    ...                                 AND
    ...                                 Configure Environment     validate_sim=${False}
    Verify gNB procedural state       expected_status=onAir
    Activate feature flag for all cells
    Wait for all cells to be enabled
    Verify gNB procedural state       expected_status=onAir
    [Teardown]      Run Keywords        Deactivate feature flag for all cells
    ...                                 AND
    ...                                 Wait for all cells to be enabled
    ...                                 AND
    ...                                 Verify gNB procedural state       expected_status=onAir
