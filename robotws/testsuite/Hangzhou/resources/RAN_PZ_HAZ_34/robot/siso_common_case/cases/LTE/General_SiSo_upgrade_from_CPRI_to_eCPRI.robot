*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot

*** Variables ***

${arti_hz_sbts}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/

*** Keywords ***
General_SiSo_upgrade_from_CPRI_to_eCPRI
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Test case covers user scenario #2 from feature CB005793 This is a top-level user scenario
        ...    for remote protocol change for RU from CPRI to eCRPI via WebEM or NetAct interface
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 8.29.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    [Arguments]  ${cell_id}=${1}    ${switch_to_radio_protocol}=ECPRI
    ${current_pkg}    Download trunk SW    SW=${Active_SW_version}
    set suite variable    ${current_pkg}
    ${radio_protocol_temp}    get_radio_protocal_via_admin
    run keyword if    '${radio_protocol_temp}'!='${switch_to_radio_protocol}'    Enb Cpri Ecpri Switch    current_pkg=${current_pkg}
Enb Cpri Ecpri Switch
    [Arguments]    ${current_pkg}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    Delete CMD Object If Exist
    Add PRTCLCHGRES Object Via Webem LTE
    log to console    start check fault 23 appear
    Expect Fault Should Present LTE     faultId=23
    log to console    upload current version package and activate: ${current_pkg}
    Perform SW Update    ${SUITE_LOG_PATH}/${current_pkg}
    sleep  360
    Wait Until Keyword Succeeds    10min    360s    Verify all cells should be onair    cell_type=${cell_type}
    log to console  start check fault 23 disappear
    Expect Fault Should Absent LTE     faultId=23
    run keyword and ignore error    Validate Check on WebUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    Check Protocol Change Result Via Webem
    Delete CMD Object If Exist
    Selenium Logout And Close Browser
    ${radio_protocol_after_switch}    get_radio_protocal_via_admin
    [Teardown]    Selenium Logout And Close Browser
Download trunk SW
    [Arguments]    ${SW}=${Active_SW_version}    ${package_store_path}=${SUITE_LOG_PATH}
    ${sw_name}    ${sw_full_url}    get trunk sw name    SW=${SW}
    ${status}          run keyword and return status    file should exist   ${package_store_path}/${sw_name}
    run keyword if      ${status}    remove file    ${package_store_path}/${sw_name}
    ${sw_url}          Catenate    sudo wget ${sw_full_url} -nv -P ${package_store_path}
    ${res}             Run         ${sw_url}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    should be true    ${status}
    [Return]    ${sw_name}
get trunk sw name
    [Arguments]    ${SW}=${Active_SW_version}
    ${sbts_status}    run keyword and return status     Should contain    ${SW}    SBTS
    @{result}    string.split string    ${SW}    separator=_
    ${sbts_trunk}    run keyword and return status      Should Contain Any   ${SW}    _ENB_9999_
    ${SW_vesion_tmp}       set variable if      ${sbts_trunk}    SBTS00    ${result}[0]
    ${sw_version}   run keyword if    ${sbts_trunk}    Replace String    ${SW}    ${result}[0]    SBTS00
    ...           ELSE    set variable     ${SW}
    ${sw_name}    set variable if      ${sbts_status}    ${sw_version}_release_BTSSM_downloadable_A54.zip
    ...    AirScale-${SW}.zip
    ${arti_path}    run keyword if
    ...    ${sbts_status}==${True} and ${sbts_trunk}==${True}      set variable     ${arti_hz_sbts}${SW_vesion_tmp}_packages/
    ...    ELSE      set variable    ${arti_hz}
    ${sw_full_url}    set variable     ${arti_path}${sw_version}/${sw_name}
    [Return]    ${sw_name}    ${sw_full_url}
Add PRTCLCHGRES Object Via Webem LTE
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    log to console  \n***Add PRTCLCHGRES Object Via Webem***
    ${link_speed}    ${radio_protocol_type}    Get Cpri Ecpri Switch Params LTE
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1
    ...    object_class_name=CMD    id_value=1    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/CMD-1
    ...    object_class_name=PRTCLCHGREQ    id_value=1    timeout=15
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/CMD-1/PRTCLCHGREQ-1
        ${ru_index_temp}    convert to number  ${ru_index}
        ${node_index_temp}    Evaluate  ${ru_index_temp}-1
        selenium_coam.add_element    dist_name=${dist_name}
        ...    filter_param=Radio modules upgrade    abbr=rModUpgrade    timeout=15
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Link speed
        ...    abbr=linkSpeed    new_value=${link_speed}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio protocol type
        ...    abbr=radioProtocolType    new_value=${radio_protocol_type}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio module distinguished name
        ...    abbr=rModDN    new_value=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    node_index=${node_index_temp}
    END
    selenium_coam.validate_plan
    run keyword and ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=15
Get Cpri Ecpri Switch Params LTE
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    selenium_coam.enable_virtual_display
    Wait Until Keyword Succeeds    1min    10s    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${radio_protocol}    get_radio_protocal_via_admin
    ${link_speed}    set variable if    '${radio_protocol}'=='CPRI'    eCpri10    Cpri7
    ${radio_protocol_type}    set variable if    '${radio_protocol}'=='CPRI'    10eCPRI    TDDCPRI
    [Return]  ${link_speed}    ${radio_protocol_type}
