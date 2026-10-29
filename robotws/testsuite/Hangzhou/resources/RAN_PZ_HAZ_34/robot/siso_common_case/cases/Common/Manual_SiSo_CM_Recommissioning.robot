*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${dist_name}      MRBTS-${MRBTS_ID}/MNLENT-1
${filter_param}      Recovery reset delay
${abbr}      recoveryResetDelay
${new_value}      ${1}
${max_value}      ${1201}
${sync_dist_name}      MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
${sync_filter_param}      Holdover mode in temperature control
${sync_abbr}      holdOverModeUsed

*** Keywords ***
Manual_SiSo_CM_Recommissioning
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify that BTS can be recommissioned by WebEM correctly.
    ...    Commissioning is done using WebEM and previously created SCF.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.30.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${timeout}=60
    ${origin_value}    Get Single Parameter Value on WebUI   dist_name=${dist_name}   filter_param=${filter_param}
    Verify Out Range Single Parameter Value And Undo Change   dist_name=${dist_name}   filter_param=${filter_param}
    ...    abbr=${abbr}   new_value=${max_value}
    Create file in BBMOD
    Modify and Check Single Parameter Value without reset  dist_name=${dist_name}   filter_param=${filter_param}
    ...    abbr=${abbr}   new_value=${new_value}
    Check and Delete file Exist in BBMOD
    Modify and Check Single Parameter Value without reset  dist_name=${dist_name}   filter_param=${filter_param}
    ...    abbr=${abbr}   new_value=${origin_value}
    Modify Single Parameter Value on WebUI  dist_name=${sync_dist_name}   filter_param=${sync_filter_param}
    ...    abbr=${sync_abbr}   new_value=true  timeout=${timeout}
    Wait until keyword succeeds    5min    30s    RU Should Be Offline
    Wait until keyword succeeds    5min    30s    RU Should Be Online
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Close Start Up View Window
    Modify Single Parameter Value on WebUI  dist_name=${sync_dist_name}   filter_param=${sync_filter_param}
    ...    abbr=${sync_abbr}   new_value=false  timeout=${timeout}
    Wait until keyword succeeds    5min    30s    RU Should Be Offline
    Wait until keyword succeeds    5min    30s    RU Should Be Online
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Close Start Up View Window
