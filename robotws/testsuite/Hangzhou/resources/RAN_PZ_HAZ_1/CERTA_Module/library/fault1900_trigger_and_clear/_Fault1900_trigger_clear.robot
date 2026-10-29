*** Settings ***
Documentation
...    Author: Xiang Liangliang
...    Contact: liang.xiang@nokia-sbell.com
...    Common KWs use to trigger and clear fault 1900

Library           Collections
Library           re
Library           DateTime
Library           OperatingSystem
Library           Process
Library           Screenshot
Library           String
Library           yaml
Library           XML
Library           Telnet
Library           json

*** Variables ***
${BTS_ID}    ${tl.gnbs[0].instance_id}


*** Keywords ***
Fault1900_Trigger_And_Clear_gnb
    [Arguments]  ${product_type}=gnb
    ...          ${bts_index}=${0}
    ...          ${cudu_index}=${0}
    ...          ${cell_distname_id}=${None}
    ...          ${timeout}=${300}
    ...          &{kwargs}
    Log To Console    ${cudu_index}
    Log To Console    ${cell_distname_id}
    Log To Console    ${timeout}
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    ${result}  ${ret}   _Verify SBTS Concurrent mode
    ...           product_type=${product_type}
    ...           gnb_index=${bts_index}
    Run Keyword And Return If   "${result}"=="${False}"    fail    msg=your SBTS is not configured in concurrent mode!!!
    ${target_distname}    _Trigger Check Clear Fault 1900    ret=${ret}
    _Verify SBTS cell status
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${0}


_Verify SBTS Concurrent mode
    [Arguments]    ${product_type}=gnb    ${gnb_index}=${0}    ${alias}=default
    log to console    \n * * * SBTS is configured in concurrent mode * * *
    ${connection}=    _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${alias}
    ${RMOD_ID_LIST}=  coam.Get Ids For All  RMOD  alias=${connection}
    Sort List  ${RMOD_ID_LIST}
    ${NR_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${CELL_Id_List}=  coam.Get Cell Mapping By Module Id  ${item}  alias=${connection}
        @{temp}=  Create List  ${item}  ${CELL_Id_list}
        Append To List  ${NR_RM_CELL_list}  ${temp}
    END
    Sort List  ${NR_RM_CELL_list}
    ${ret}=  Get Target RU Dist Name    ${NR_RM_CELL_list}
    ${res}    run keyword and return status    should not be empty     ${ret}
    [Return]  ${res}    ${ret}


Get All RU Info
    [Arguments]     ${connection}
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_info}    create dictionary
    FOR  ${ru}  IN  @{rmod_info}
        ${productName}    set variable    ${ru['productName']}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    (RMOD-\\d+)    1
        log to console     ${ru.id.internal}
        set to dictionary    ${ru_info}    ${ru.id.internal}    ${productName}
    END
    [Return]  ${ru_info}


_Get RU Name and Max cell Power
    [Arguments]    ${ret}    ${connection}=default
    log to console    \n * * * Start to get target RU name and its max cell power * * *
    ${ru_peoductname_dict}    Get All RU Info     connection=${connection}
    ${ru_product_name}    get from dictionary    ${ru_peoductname_dict}    ${ret}
    ${json_file}    set variable    ${CURDIR}/RU_Power_Mapping.json
    ${max_cell_power}    bts_base.get_max_cell_power    json_file=${json_file}   product_name=${ru_product_name}
    log to console    ${max_cell_power}
    [Return]  ${ru_product_name}    ${max_cell_power}

_Trigger Check Clear Fault 1900
    [Arguments]    ${ret}    ${connection}=default
    log to console    \n * * * Start to trigger fault 1900 * * *
    FOR    ${item}    IN    @{ret}
        ${item_key}=    Get Dictionary Keys    ${item}
        ${item_value}=    Get From Dictionary    ${item}    ${item_key[0]}
        ${ru_product_name}    ${max_cell_power}    _Get RU Name and Max cell Power    ret=${item_key[0]}
        ${min_power_ori}    ${min_power_w}    ${cell_power_sum}    ${target_distname}
        ...    Calculate All Cell Power on RU    ${item_value}    ${connection}
        log to console    ${cell_power_sum}
        ${delta_cell_power_w}   Evaluate    ${max_cell_power}-${cell_power_sum}+1+${min_power_w}
        ${cell_power_modified}    Convert W To dbm    ${delta_cell_power_w}
        ${cell_power_modified} =    Evaluate    ${cell_power_modified} * 10
        change cell power     ${cell_power_modified}    ${target_distname}    ${connection}
        Sleep    20s
        _Check Fault 1900    ${item_key[0]}    ${connection}
        ${ping_status_after_reset}   tool_for_ping.check_target_stable
        ...  ip=192.168.255.129  min_uptime=20  max_downtime=30  timeout=60
        ${local_file_path}    Run Keyword If    "${ping_status_after_reset}"=="False"
        ...        Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
        Sleep    20s
        _Clear Fault 1900    ${min_power_ori}    ${target_distname}    ${connection}
    END
    [Return]      ${target_distname}
    [Teardown]    Run Keyword And Ignore Error   _bts.logout    connection=${connection}

_Clear Fault 1900
    [Arguments]    ${origin_cell_power}    ${target_distname}    ${connection}=default
    log to console    \n * * * Start to clear fault 1900 * * *
    ${origin_cell_power}    Evaluate    ${origin_cell_power}*10
    Change Cell Power    ${origin_cell_power}    ${target_distname}    ${connection}
    log to console    Fault 1900 is cleared!!!

_Check Fault 1900
    [Arguments]    ${dist_name}    ${connection}=default
    log to console    \n * * * Start to check fault 1900 * * *
    Get faultid for SBTS    ${dist_name}    connection=${connection}

_Verify SBTS cell status
    [Arguments]
    log to console    \n * * * Start to verify SBTS cell status * * *
#    BTS Operation    operation=verify    product_type=gnb   bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR

Get Target RU Dist Name
    [Arguments]     ${rmod_info}
    ${rmod_len}    get length    ${rmod_info}
    ${loop_len}    evaluate     ${rmod_len}-1
    @{concurrent_mode_list}    create list
    FOR    ${cell_index}    IN RANGE    ${rmod_len}
           ${ru_NRCELL}    bts_base.get_matching_elements    ${rmod_info[${cell_index}][1]}    (NRCELL\_R\-\\d+)
           ${ru_LNCEL}    bts_base.get_matching_elements     ${rmod_info[${cell_index}][1]}    (LNCEL\_R\-\\d+)
           ${ru_NRCELL_len}    get length    ${ru_NRCELL}
           ${ru_LNCEL_len}    get length    ${ru_LNCEL}
           ${result}    Run Keyword If    ${ru_NRCELL_len}>=1 and ${ru_LNCEL_len}>=1
           ...          Create Dictionary    ${rmod_info[${cell_index}][0]}    ${rmod_info[${cell_index}][1]}
           Run Keyword If    ${result}!=${None}    Append To List    ${concurrent_mode_list}    ${result}
    END
    [Return]    ${concurrent_mode_list}

Get Cell Power On Target Ru
    [Arguments]    ${dist_name}    ${connection}=default
    ${cell_power}    coam.get_rf_output_power    connection=${connection}    lncel_dist_name=${dist_name}
    [Return]    ${cell_power}

Convert dbm To W
    [Arguments]    ${val_dbm}
    [Documentation]     This KW converts dbm to mW.
    ...                 Argument         |   Value
    ...                 ---------------------------------
    ...                 val_dbm           |   [float]
    ${res} =   Evaluate   round(10**((${val_dbm})/10.0)/1000, 2)
    [Return]    ${res}

Convert W To dbm
    [Arguments]    ${val_w}
    [Documentation]     This KW converts W to dbm.
    ...                 Argument         |   Value
    ...                 ---------------------------------
    ...                 val_w             |   [float]
    ${res} =   Evaluate   round(10*math.log10(${val_w}*1000), 1)    modules=math
    [Return]    ${res}

Calculate All Cell Power on RU
    [Arguments]    ${cell_distname_list}   ${connection}=default
    ${min_power} =    Set Variable    None
    ${target_distname} =    Set Variable    None
    ${cell_power_w_list}    Create List
    ${cell_distname_list_len}    get length    ${cell_distname_list}
    FOR    ${index}    IN RANGE    ${cell_distname_list_len}
        ${cell_distname} =    Set Variable    ${cell_distname_list[${index}]}
        ${cell_power}    Get Cell Power On Target Ru    ${cell_distname}    ${connection}
        ${cell_power_dbm}    Set Variable    ${cell_power['maximumOutputPower']}
        Run Keyword If    '${min_power}' == 'None' or ${cell_power_dbm} < ${min_power}
        ...    run keywords    Set test Variable    ${min_power}    ${cell_power_dbm}
        ...    AND    Set test Variable    ${target_distname}    ${cell_distname}
        ${cell_power_w}    Convert dbm To W    ${cell_power_dbm}
        ${min_power_w}    Convert dbm To W    ${min_power}
        Append To List    ${cell_power_w_list}    ${cell_power_w}
        ${cell_power_sum}    Evaluate    sum(${cell_power_w_list})
    END
    [Return]    ${min_power}   ${min_power_w}    ${cell_power_sum}    ${target_distname}

Change Cell Power
    [Arguments]    ${cell_power_modified}    ${dist_name}    ${connection}=default
    Log To Console    ${connection}
    log to console    \n * * * Start to change cell power * * *
    ${target_cell}    modify_cell_dstname    ${dist_name}    ${BTS_ID}
    @{para_list}   Create List   pMax
    @{value_list}   Create List   ${cell_power_modified}
    @{mo_list}   Create List   ${target_cell}
    ${res}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}

Get faultid for SBTS
    [Arguments]    ${target_object}    ${connection}=default   ${expect_fault_id}=1900
    @{alarms}     coam.get_active_alarms    connection=${connection}
    ${flag_exist}  set variable   ${False}
    FOR    ${alarm_dict}    IN   @{alarms}
        ${configobjectname}    set variable    ${alarm_dict["alarmingObjectIds"][0]["internal"]}
        Run Keyword If   "${alarm_dict["faultId"]}"=="${expect_fault_id}" and "${configobjectname}"=="${target_object}"
        ...     run keywords
        ...     Set Test Variable    ${flag_exist}   ${True}
        ...     AND    exit for loop
    END
    should be equal    ${flag_exist}    ${True}

