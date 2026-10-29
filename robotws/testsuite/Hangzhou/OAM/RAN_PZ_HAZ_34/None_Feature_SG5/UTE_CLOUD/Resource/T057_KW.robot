*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

*** Variables ***

*** Keywords ***
### part-1: 5GC000470 ###
Step1: Login WebUI
    log to console    Step1: Login WebUI
    WEBUI Login

Step2: Wait idle time
    log to console    Step2: Wait idle time
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    #run keyword and ignore error      selenium_coam.enable_screen_lock
    ${lock_screen_time}=    selenium_coam.get_lock_screen_time
    run keyword if    "${lock_screen_time}" != "${2}"     selenium_coam.set_lock_screen_time    lock_time=${2}
    sleep    130s
    selenium_coam.login_after_screen_lock    passwd=${WEBUI_PASSWORD}

Step3: Acquire login fail info
    log to console    Step3: Acquire login fail info
    @{fail_info}    run keyword and ignore error    selenium_coam.login     url=${WEBUI_URL}
    ...   username=${WEBUI_USER}     password=${WEBUI_PASSWORD}
    should be equal    ${fail_info}[0]    FAIL

Step4: Logout WebUI
    log to console    Step4: Logout WebUI
    run keyword and ignore error    WEBUI Logout

Step1: Check gNB is onAir
    log to console    Step1: Check gNB is onAir
    Check_gNB_status

Step2: Trigger fault 7300 on WebEM
    log to console    Step2: Trigger fault 7300 on WebEM
    Trigger fault 7300 on WebEM

Step3: Check fault 7300 display on WebEM
    log to console    Step3: Check fault 7300 display on WebEM
    ${Alarm_ob_CP}    set variable    [${BTS_Name}] MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Wait until keyword succeeds    2min    10s    Check fault on WebEM
    ...    alarm_filter=No X2 link available   Alarm_ID_CP=7107    Alarm_name_CP=${Alarm_name_CP}    Fault_ID_CP=7300
    ...    Fault_name_CP=No X2 link available    Severity_CP=${Severity_CP}    Alarm_ob_CP=${Alarm_ob_CP}
    run keyword and ignore error    WEBUI Logout

Recovery Env
    log to console    Recovery Env
    run keyword and ignore error    Clear fault 7300 on WebEM
    run keyword and ignore error    Wait until keyword succeeds    7min    10s
    ...    Check fault disappear on WebEM    alarm_filter=No X2 link available
    sleep   3min
    run keyword and ignore error    WEBUI Logout

Step2: Trigger fault 7308
    log to console    Step2: Trigger fault 7308
    Trigger fault 7308 on gNB

Step3: Check fault 7308 display on WebEM
    log to console    Step3: Check fault 7308 display on WebEM
    WEBUI Login
    ${Alarm_ob_CP}    set variable    [${BTS_Name}] MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-1
    Wait until keyword succeeds    10min    1min    Check fault on WebEM
    ...    alarm_filter=Transport layer connection failure   Alarm_ID_CP=7107
    ...    Alarm_name_CP=${Alarm_name_CP}    Fault_ID_CP=7308
    ...    Fault_name_CP=Transport layer connection failure in X2 interface
    ...    Severity_CP=${Severity_CP}    Alarm_ob_CP=${Alarm_ob_CP}
    Run Keyword And Ignore Error    WEBUI Logout

Recovery fault 7308
    log to console    Recovery fault 7308
    Teardown_fault_clear    alarm_filter=Transport layer connection failure

Trigger fault 7308 on gNB
    Trigger alarm on gNB    cmd=iptables -t filter -A OUTPUT -p sctp --dport 36422 -j DROP
    Trigger alarm on eNB    cmd=iptables -t filter -I INPUT 1 -s ${asik_addr} -p sctp --dport 36422 -j DROP

### part-3: 5GC002090 ###
"${Step}" Change Parameter via webUI
    log to console    \n"${Step}": Change Parameter via webUI
    ${Orig_val}    Get Parameter via webUI
    ...            dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...            filter_param=${Param_filter}
    ...            p_name=${Param_abbr}
    set test variable    ${Orig_val}
    Run Keyword If    '${Orig_val}'=='false'
    ...    set test variable    ${toBeModify_val}    true
    ...    ELSE
    ...    set test variable    ${toBeModify_val}    false
    ${afterModify_val}    ${errors}    Change Parameter via webUI
    ...            expected_val=${toBeModify_val}
    ...            dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...            filter_param=${Param_filter}
    ...            p_name=${Param_abbr}

"${Step}" Login WebEM and check gNB onair
    log to console           \n"${Step}": Login WebEM and check gNB onair
    Wait Until Keyword Succeeds    2min    30s    WEBUI Login
    ${mrbts_id}  ${nrbts_id}     Get Gnb BTS ID
    check gNB Staus onAir    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    search_text=Operational state

Get Gnb BTS ID
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               bts_port=${443}  name=coam
    &{bts_info}   coam.get_bts_info   connection=coam   timeout=10
    ${mrbts_id}    set variable     ${bts_info['mrbtsID']}
    ${nrbts_id}    set variable     ${bts_info['nrBtsId']}
    coam.teardown          connection=coam
    [Return]    ${mrbts_id}    ${nrbts_id}

Get Parameter via webUI
    [Arguments]    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ...                                                      timeout=${120}
    [Return]    ${current_val}

Change Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ${errors}    run keyword if  not '${current_val}'=='${expected_val}'
    ...    Set Parameter value via webUI     expected_val=${expected_val}
    ...                                      dist_name=${dist_name}
    ...                                      filter_param=${filter_param}
    ...                                      p_name=${p_name}
    ...                                      is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                      need_active=${need_active}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    Run keyword if    ${need_active}==${True}
    ...    should be equal    ${current_val}    ${expected_val}
    [Return]    ${current_val}    ${errors}

Set Parameter value via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    selenium_coam.set_parameter_value       dist_name=${dist_name}
    ...                                 filter_param=${filter_param}
    ...                                 new_value=${expected_val}
    ...                                 abbr=${p_name}
    ...                                 timeout=${120}
    selenium_coam.validate_plan
    ${errors}    Get Validate error
    Run keyword if    ${is_need_to_check_validation_errors}==${True}
    ...    Should be empty    ${errors}
    Run keyword if    ${need_active}==${True}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${errors}

Get Validate error
    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
    ${hardware_errors}      selenium_coam.get_hardware_errors    timeout=${120}
    [Return]    ${defination_errors}   ${relation_errors}   ${hardware_errors}

case teardown
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    run keyword and ignore error     WEBUI Logout
    csn.reset cache
