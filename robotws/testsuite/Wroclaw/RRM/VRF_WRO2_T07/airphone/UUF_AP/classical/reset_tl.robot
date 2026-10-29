*** Settings ***
Force Tags    NoResUsage    RF50

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./Keywords.robot
Library      ta5g_testline_management
Library      ta5g_enb
Library      ta5g_cell_operations
Library      ta5g_iphy

Suite Setup    Run Keywords    Enable Cloud
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
Reset_Test_Line
    Check All Cells Are Enabled Aic
    Trigger Site Reset
    Check Radios Availability
    Sleep    5s
    Check All Cells Are Enabled Aic
