*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith.robot

*** Keywords ***
Modify bandwidth for multi cells
  [Arguments]    ${cell_list}    ${band_list}
    Selenium Login And Disable Screen Lock
    ${modify_params}  create list
    FOR    ${cell_id}   ${band}    IN ZIP    ${cell_list}   ${band_list}
        ${item}     Create Dictionary     dist_name=MRBTS-${MRBTS_id}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    node_index=${1}
        ...    filter_param=Bandwidth Part Profile distinguished name   p_name=bwpDN   value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${band}
        append to list  ${modify_params}  ${item}
        ${band}    set variable if    ${band}>80    ${80}    ${band}
        ${item}   create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Channel bandwidth  p_name=chBw  value=${band}MHz
        append to list  ${modify_params}  ${item}
        ${item}   Create Dictionary   dist_name=MRBTS-${MRBTS_id}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}   node_index=${0}
        ...    filter_param=Activate down sampling   p_name=actDownSampling   value=true
        run keyword if   ${band}==20   append to list  ${modify_params}  ${item}
    END
    Modify Parameters On WebEM With Node Index   modify_params=${modify_params}
    sleep   120s
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair
    Selenium Logout And Close Browser



Modify Parameters On WebEM With Node Index
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}    ${timeout}=360
    ${activate_plan_despite_errors}    set variable if    not ${if_pdl_check}    ${True}    ${despite_errors}
    run keyword and ignore error    run keyword if  ${activate_plan_despite_errors}  run keywords    selenium_coam.refresh_page   AND
    ...    sleep    20s
    FOR  ${item}  IN  @{modify_params}
        ${result}  Run Keyword And Ignore Error  Dictionary Should Contain Key  ${item}   node_index
        ${node_index}    set variable if    '${result[0]}'=='PASS'    ${item}[node_index]    ${None}
        selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]   node_index=${node_index}
    END
    selenium_coam.validate_plan
    run keyword if  ${is_activate}==True  selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    ...    timeout=${timeout}
