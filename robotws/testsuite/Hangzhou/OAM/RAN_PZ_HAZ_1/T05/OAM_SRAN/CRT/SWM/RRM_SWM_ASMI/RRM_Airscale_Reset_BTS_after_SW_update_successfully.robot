*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py


*** Variables ***
${TARGET_SW_NAME}          ${None}                   # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}     /home/ute/btsauto/TARGET_SW/    # Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW'
${UPDATE_TIMEOUT}          2400                      # Timeout for Download and Activation [sec]
${SW Download Timeout}      1800
${SW Activation Timeout}    150                      # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}        420                      # Timeout for ping loss during reset
${Ping regain timeout}      600                      # Timeout for ping regain during reset
${BTS_OnAir_Timeout}        15                       # Timeout for BTS on Air (in minutes)
${Test_Timeout}             30                       # Test timeout (in minutes)
${onAir Check Number}       60                 # Number of checks for proceduralStatus: onAir after RMODs reset is complete; check interval = 10s


*** Keywords ***
RRM_Airscale_Reset_BTS_after_SW_update_successfully
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to verified unsingned package update
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    100 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-LTE655

    Step1: Check path to SW package
    Step2: Get active and passive SW version
    Step3: Start SW update
    Stability check
    Reset testline
    Check if BTS onAir
    Check if all cells onAir

Step1: Check path to SW package
    [Documentation]    Short description.
    Log Step Header  Step1: Check path to SW package
    ${target_sw_path}  Get sw package from directory  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Set test variable  ${TARGET_SW_PATH}  ${target_sw_path}

Step2: Get active and passive SW version
    [Documentation]    Short description.
    Log Step Header  Step2: Get active and passive SW version
    Check if sw build already present on active partition  ${TARGET_SW_PATH}
    Log  SW not present on active partition  console=${TRUE}
    Check if sw build already present on passive partition  ${TARGET_SW_PATH}
    Log  SW not present on passive partition  console=${TRUE}

Step3: Start SW update
    [Documentation]    Short description.
    Log Step Header  Step3: Start SW update
    Log  Send main SW download and activation request  console=${TRUE}
    ${main_update_thread}  taf.sbts.oam.coam.admin.Run keyword in background
    ...   Update Software  sw_package=${TARGET_SW_PATH}  timeout=${UPDATE_TIMEOUT}
    Set test variable  ${MAIN_UPDATE_THREAD}  ${main_update_thread}
    Sleep  10

Stability check
    [Documentation]    Short description.
    Log Step Header  Stability check
    Log  Wait For Target To Be Not Reachable  console=${TRUE}
    Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${UPDATE_TIMEOUT}
    Log  Wait For Target To Be Reachable  console=${TRUE}
    Wait For Target To Be Reachable      hostname=${SMOD1['TRS_IP']}  timeout=500
    Log  Check If Target Is Stable for 100s  console=${TRUE}
    Check If Target Is Stable         ip=${SMOD1['TRS_IP']}  min_uptime=100  max_downtime=0  timeout=101
    Log  Check admin connection  console=${TRUE}
    Reset admin and infomodel connection if broken
    Log  Check SBTS SOAM cells and modules  console=${TRUE}
    Wait until keyword succeeds  20 min  30 s  Check SBTS SOAM cells and modules
    Log  Check SOAM Active Alarms  console=${TRUE}
    Check SOAM Active Alarms

Reset testline
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.run keyword in background    Reset  timeout=300
    log to console with time  Check if reset is performed
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    log to console with time  Reset completed. Waiting for eNB to be pingable...
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for reset  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after Reset
    Log  BTS is stable after Reset.  console=${TRUE}

Check if BTS onAir
    [Documentation]    Short description.
    Log Step Header  Check if BTS onAir
    Log  Will now check if BTS is OnAir, timeout=${BTS_OnAir_Timeout}min, interval=10sec  console=${TRUE}
    Wait until keyword succeeds  ${BTS_OnAir_Timeout} min  10 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

Check if all cells onAir
    [Documentation]    Short description.
    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
    #Sleep    300
    ${ping_status}  Check If Target Is Stable  ip=192.168.255.129  min_uptime=300  max_downtime=300  timeout=900
    Log Step Header  Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds untill success or TC timeout (30min).  console=${TRUE}
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  ${cell_state_table}  Run keyword and ignore error  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword and ignore error    Run keyword if  '${all_cell_status}' == 'PASS'  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
    END
