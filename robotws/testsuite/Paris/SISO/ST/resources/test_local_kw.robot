*** Settings ***
Documentation
...         Only for test local keywords

Resource    kw_coam_UTECM.robot
Resource    kw_classical.robot

*** Test Cases ***
# kw_classical.robot

Test KW Connect To HW Unit
    Connect To HW Unit      HOSTNAME   USER    PASSWORD    ALIAS}

Test KW disconnect from hw unit
    disconnect from hw unit     HW_CONNECTION

Test KW Connect To LMP
    Connect To LMP

Test KW disconnect from LMP
    disconnect from LMP

Test KW Connect To DCAP
    Connect To DCAP

Test KW disconnect from DCAP
    disconnect from DCAP

Test KW Connect To OAM
    Connect To OAM

Test KW disconnect from OAM
    disconnect from OAM

Test KW Check FCT Status From Asik AdetS Classical
    Check FCT Status From Asik AdetS Classical

# Test KW Check FBBs Status From Asik AdetS Classical
#     Check FBBs Status From Asik AdetS Classical

# Test KW Uncommissioned Check with Adet command
#     Uncommissioned Check with Adet command     RESET_MAX_TIME

# Test KW Check boards with Adet command
#     Check boards with Adet command

# Test KW Collect PM files
#     Collect PM files     folder

# Test KW Check the container status id=${node_id}
#     Check the container status id=${node_id}

# Test KW Check gNB ASIB ABIO containers are running
#     Check gNB ASIB ABIO containers are running

Test KW Deactivation Link Adaptation on swconfig
    Deactivation Link Adaptation on swconfig

Test KW Reset Board
    Reset Board

# Test KW Get Mem Usage
#     Get Mem Usage        board_id       period

Test KW Set gnb in uncommissioned mode
    Set gnb in uncommissioned mode


# kw_coam_UTECM.robot

Test KW Create Sessions
    Create Sessions

Test KW Create Sessions LMP
    Create Sessions LMP

Test KW Teardown Sessions
    Teardown Sessions

Test KW Software update with coam
    Software update with coam     dl_dir        vers      FSM      FBB

Test KW Perform gNB Site Reset
    Perform gNB Site Reset

Test KW Create Snapshot
    Create Snapshot

Test KW Check Rack Type
    Check Rack Type

Test KW Check AMOB Rack Type
    Check AMOB Rack Type

Test KW Check FSM Status From WEBUI
    Check FSM Status From WEBUI

Test KW Check FBBs Status From WEBUI
    Check FBBs Status From WEBUI

Test KW Check RUs Status
    Check RUs Status

Test KW Check Sync Status
    Check Sync Status

Test KW Check Cell Status
    Check Cell Status

Test KW Check gNB Status
    Check gNB Status

Test KW Reset RU Selenium
    Reset RU Selenium

Test KW Reset ABIL Selenium
    Reset ABIL Selenium

Test KW Enable ssh on WebEM
    Enable ssh on WebEM

Test KW Commission with scf file
    Commission with scf file

Test KW Cell_Lock_Unlock
    Cell_Lock_Unlock

Test KW Lock_Cells
    Lock_Cells       nbcells

Test KW Unlock_Cells
    Unlock_Cells     nbcells

Test KW Uncommissioned Check with WebEm
    Uncommissioned Check with WebEm    RESET_MAX_TIME

Test KW Uncommissioned Check with Adet command and WebEM
    Uncommissioned Check with Adet command and WebEM    RESET_MAX_TIME

Test KW Check Boards Status from webem
    Check Boards Status from webem

Test KW Get Active Alarms List
    Get Active Alarms List

Test KW Check If Alarm Allowed
    Check If Alarm Allowed

Test KW Check status of gNB until cell OnAir
    Check status of gNB until cell OnAir     RESET_MAX_TIME

Test KW Reset configuration gnb
    Reset configuration gnb

Test KW Save current scf
    Save current scf

Test KW Backup SCF Parameters
    Backup SCF Parameters

Test KW Modify SCF Parameters for band
    Modify SCF Parameters for band  RCELL_ID  chBw_value  nrarfcnDl_value  nrarfcnUl_value  gscn_value
    ...                             type0CoresetConfigurationIndex_value  frequencyDensityThresNrb_value

Test KW Restore SCF Parameters
    Restore SCF Parameters


*** Keywords ***

Result_Failure
    [Arguments]     ${RESET_START_DATE}=x     ${Time_Now}=x       ${out}=x        ${result}=Fail       ${TEST_LOOP}=x
    Log  ${RESET_START_DATE} ${Time_Now} ${out} ${result} ${TEST_LOOP}
    Log     Result_Failure

Result_success
    [Arguments]     ${RESET_START_DATE}=x      ${Time_Now}=x       ${out}=x       ${result}=Success    ${TEST_LOOP}=x
    Log  ${RESET_START_DATE} ${Time_Now} ${out} ${result} ${TEST_LOOP}
    Log     Result_success
