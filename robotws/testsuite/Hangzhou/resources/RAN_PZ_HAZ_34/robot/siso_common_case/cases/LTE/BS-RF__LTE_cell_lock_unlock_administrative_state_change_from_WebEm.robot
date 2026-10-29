*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***



*** Keywords ***
BS-RF__LTE_cell_lock_unlock_administrative_state_change_from_WebEm
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Purpose of this test case is to verify that graceful shutdown feature for LTE cells is working properly.
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 8.23.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    LTE L3call with peak tp    Ul_peak_tp=${2}    Dl_peak_tp=${10}
    Lock LTE cell
    Unlock LTE cell
    LTE L3call with peak tp    Ul_peak_tp=${2}    Dl_peak_tp=${10}
    [Teardown]   Selenium Logout And Close Browser

LTE L3call with peak tp
    [Arguments]  ${Ul_peak_tp}    ${Dl_peak_tp}    ${ue_index}=${0}
    ${Ul_peak_traffic}=    Evaluate    ${Ul_peak_tp} + ${100}
    ${Dl_peak_traffic}=    Evaluate    ${Dl_peak_tp} + ${20}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${Dl_peak_traffic}
    ...    duration=600    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${Ul_peak_traffic}
    ...    duration=600    ue_index=${ue_index}
    sleep   3min
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    log_dir=${CASE_LOG_PATH}    ue_index=${ue_index}
    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${Dl_peak_tp}
    ...    log=${log_path}
    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${Ul_peak_tp}
    ...    log=${log_path}

Lock LTE cell
    [Arguments]
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
        ...    filter_param=Administrative state    p_name=administrativeState    value=locked
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    sleep    30s
    Cell Should Be Locked
    Cell Should Be Disabled
    [Teardown]   Selenium Logout And Close Browser

Unlock LTE cell
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
        ...    filter_param=Administrative state    p_name=administrativeState    value=unlocked
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    sleep    30s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
