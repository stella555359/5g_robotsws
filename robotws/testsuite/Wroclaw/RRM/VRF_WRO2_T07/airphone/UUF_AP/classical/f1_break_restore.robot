*** Settings ***
Force Tags    NoResUsage    RF50

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./Keywords.robot
Library      ta5g_testline_management
Library      ta5g_enb
Library      ta5g_cell_operations

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
F1_Break_Restore
    Break F1 Link And Wait For Faults To Be Up
    Restore F1 Link And Wait For Faults To Be Down
    Attach Multiple UE And Establish PDU Session With Traffic
    Break F1 Link And Restore It Multiple Times    number_of_loops=10
    Break F1 Link And Restore It Multiple Times    number_of_loops=10
    Check All Cells Are Enabled

