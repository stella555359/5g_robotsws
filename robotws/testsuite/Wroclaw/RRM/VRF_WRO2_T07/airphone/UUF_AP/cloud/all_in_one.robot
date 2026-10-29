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
Block_Unblock
    Check All Cells Are Enabled Aic
    Block And Unblock All Cells Multiple Times    number_of_loops=10
    Block And Unblock Single Cell Multiple Times    number_of_loops=10

Lock_Unlock
    Check All Cells Are Enabled Aic
    Lock And Unlock All Cells Multiple Times    number_of_loops=10
    Lock And Unlock Single Cell Multiple Times    number_of_loops=10

Locking_Vdu
    Check Admin Object Parameter Value Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=f1CLinkStatusCU    expected_state=available
    Check Admin Object Parameter Value Vdu Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=f1CLinkStatusDU    expected_state=available
    Check Admin Object Parameter Value Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=administrativeState    expected_state=Unlocked
    Check If Ng Link Is Active Aic
    Trigger Vdu Lock Aic
    Sleep    30s
    Check Admin Object Parameter Value Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=administrativeState    expected_state=Locked
    Check Admin Object Parameter Value Aic     dist_name=MRBTS-1/NRBTS-1/NRDU-1     parameter_name=f1CLinkStatusCU     expected_state=available
    Check Admin Object Parameter Value Aic     dist_name=MRBTS-1/NRBTS-1/NRDU-1     parameter_name=ngLinkStatus    expected_state=inactive
    Check Admin Object Parameter Value Vdu Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=f1CLinkStatusDU    expected_state=available
    Trigger Vdu Unlock Aic
    Sleep    10s
    Check Admin Object Parameter Value Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=administrativeState    expected_state=Unlocked
    Check Admin Object Parameter Value Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=f1CLinkStatusCU    expected_state=available
    Check Admin Object Parameter Value Vdu Aic    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_name=f1CLinkStatusDU    expected_state=available
    Check Admin Object Parameter Value Aic     dist_name=MRBTS-1/NRBTS-1/NRDU-1     parameter_name=ngLinkStatus    expected_state=active
    Wait For All Cells To Be Enabled Aic    timeout=20
    Check All Cells Are Enabled Aic

Reset_Radio
    Check All Cells Are Enabled Aic
    Reset Radio Aic
    Check Radios Availability Aic    timeout=60
    Wait For F1 Links To Be Available Aic   timeout=30
    Wait For Ng Link To Be Active Aic   timeout=60
    Check If Ng Link Is Active Aic
    Wait For All Cells To Be Enabled Aic    timeout=30
    Check All Cells Are Enabled Aic

Lock_Radio
    Check All Cells Are Enabled Aic
    Lock Radio Aic
    Unlock Radio Aic
    Wait For F1 Links To Be Available Aic
    Wait For Ng Link To Be Active Aic
    Check If Ng Link Is Active Aic
    Wait For All Cells To Be Enabled Aic    timeout=30
    Check All Cells Are Enabled Aic

Reset_VDU
    Check All Cells Are Enabled Aic
    Trigger Site Reset Aic Vdu
    Wait For F1 Links To Be Available Aic
    Wait For Ng Link To Be Active Aic
    Check If Ng Link Is Active Aic
    Wait For All Cells To Be Enabled Aic    timeout=30

Reset_VCU
    Check All Cells Are Enabled Aic
    Trigger Site Reset Aic Vcu
    Wait For Ng Link To Be Active Aic
    Check If Ng Link Is Active Aic
    Wait For All Cells To Be Enabled Aic    timeout=30
