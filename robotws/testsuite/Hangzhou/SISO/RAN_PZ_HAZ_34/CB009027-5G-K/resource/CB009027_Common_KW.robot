*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_SM_RF_Module_lock_unlock_with_5GC001086_enabled_4x8DL4U_100M
    Modify actUlSrsBm Parameter for CB001086
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}

General_SiSo_Cell_block_and_unblock_with_5GC001086_enabled_4x8DL4UL_100M
    Modify actUlSrsBm Parameter for CB001086
    E2E_SiSo_Cell_block_and_unblock_gNB   with_call=${False}

Modify actUlSrsBm Parameter for CB001086
    [Arguments]    ${actUlSrsBm}=true
    Selenium Login And Disable Screen Lock
    Log to console    Modify actUlSrsBm Parameter to ${actUlSrsBm}
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate uplink SRS based beam management
    ...    abbr=actUlSrsBm
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate uplink SRS based beam management  p_name=actUlSrsBm  value=${actUlSrsBm}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actUlSrsBm}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]    Selenium Logout And Close Browser
