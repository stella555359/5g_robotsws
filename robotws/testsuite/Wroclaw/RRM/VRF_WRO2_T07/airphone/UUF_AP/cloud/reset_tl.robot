*** Settings ***
Force Tags    NoResUsage    RF50

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./Keywords.robot
Library      ta5g_testline_management
Library      ta5g_enb
Library      ta5g_cell_operations

Suite Setup    Run Keywords    Enable Cloud
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach OnAir    lua_cfg=/opt/iphy/latest/basic_setup.cfg
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
Reset_VDU
    Trigger Site Reset Aic Vdu
    Wait For F1 Links To Be Available Aic
    Wait For Ng Link To Be Active Aic
    Check If Ng Link Is Active Aic
    Wait For All Cells To Be Enabled Aic    timeout=20

Reset_VCU
    Trigger Site Reset Aic Vcu
    Wait For Ng Link To Be Active Aic
    Check If Ng Link Is Active Aic
    Wait For All Cells To Be Enabled Aic    timeout=20
