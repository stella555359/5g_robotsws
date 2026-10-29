*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :contact: anna.roskosz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000431_keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_cell_operations
Library      ta5g_admin_operations
Library      5GC000431_keywords.py
Library      ta5g_ue_mobility
Library      ta5g_iperf_traffic

Suite Setup    Reach Onair And Collect Logs
    ...        lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...        output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown     Run Keywords    Find Scfc and Send Delta Commissioning    scfc_filename=delta_default_configuration.json
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{CELLS_LIST}=                        1                  2
@{NOTENERGYSAVING_ENERGYSAVING}       notEnergySaving    energySaving
@{ENABLED_DISABLED}                   Enabled            Disabled
@{NOTENERGYSAVING_SWITCHINGOFF}       notEnergySaving    switchingOff
@{NOTENERGYSAVING_NOTENERGYSAVING}    notEnergySaving    notEnergySaving
@{ENABLED_ENABLED}                    Enabled            Enabled

*** Test Cases ***
5GC000431_A_19_Cell_Switch_On_Procedure
    [Documentation]
    ...        This test case describes cell switching on procedure
    ...
    ...        Testcase checks:
    ...        - checking if one cell is in energy saving state
    ...
    ...        - checking if current load is greater than lbpsMaxLoad for the last 2-minutes,
    ...          switched off cell is starting switching on procedure
    ...          and state of the switched off cell is set to enabled
    ...
    ...        OPTIMIZED TC :

    Set Current Date In Delta And Return Lbps Start Time
    ...    scfc_filename=delta_2_cells_lbpsLastCellSOEnabled_true_switch_on.json
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_2_cells_lbpsLastCellSOEnabled_true_switch_on.json
    Wait For Cells Parameters Value Change
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{NOTENERGYSAVING_SWITCHINGOFF}
    ...    timeout=500
    Wait For Cells Parameters Value Change
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{NOTENERGYSAVING_ENERGYSAVING}
    Check Cells Are In Correct State    cell_ids=@{CELLS_LIST}    search_key=operationalState    cells_status=@{ENABLED_DISABLED}
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Traffic And Check If Average Throughput Is Reached    pdu_gw_id=1    margin=10%    duration=140
    Check Cells Parameter Values
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{NOTENERGYSAVING_NOTENERGYSAVING}
    Check Cells Are In Correct State    cell_ids=@{CELLS_LIST}    search_key=operationalState    cells_status=@{ENABLED_ENABLED}
