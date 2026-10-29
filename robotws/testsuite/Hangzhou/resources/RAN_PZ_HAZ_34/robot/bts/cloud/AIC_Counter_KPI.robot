*** Settings ***
Documentation
...    author: mengli yang
...    contact: mengli.yang@nokia-sbell.com
...    Common KWs related to PM counter and KPI.


*** Variables ***

*** Keywords ***
#-------------------PM---------------------------------------------------------------------------------
Wait For New Measurement Period
    [Arguments]    ${interval}=5
    [Documentation]    This kw is used for wait for new measurement period
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | No | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Wait For New Measurement Period |
    ...
    Log    Waiting For Measurement Period    console=${TRUE}
    Wait Until Keyword Succeeds    5m    1m    Time To Start Calls    interval=${interval}

Time To Start Calls
    [Arguments]    ${interval}=5
    [Documentation]    This kw is used for wait for start make call in new measurement period
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | No | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | start make call in new measurement period |
    ...
    ${timenow} =    Get Current Date
    ${minutes_now} =    Convert Date    ${timenow}    result_format=%M
    ${minutes_now} =    Convert To Number    ${minutes_now}
    ${time}    Evaluate    ${minutes_now} % ${interval}
    Should Be True    ${time} == 0

Check Counter For vCU
    [Arguments]    ${counter_id}     ${measurement_id}    ${dimension_dist_name}  ${expected_value}
    ...            ${get_number}=1    ${gnb_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | get_number | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_values_final} | return latest counter value |
    ...
    ...    Example
    ...    | ${value}= | check CU counter |  M55112C00002  |   55112  |   MRBTS-5560/NRBTS-5560  |  900  |  4  |
    ...
    Login To vCU By Rest    ${gnb_index}
    ${res}=  cu.Get Counter    ${measurement_id}     ${dimension_dist_name}    ${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    ${expected_counter_values}=    set variable    ${counter_values[-${get_number}:]}
    ${status}=   set variable   False
    FOR    ${counter_item}    IN    @{expected_counter_values[::-1]}
        ${start_time}=   set variable  ${counter_item['start_time']}
        ${start_time}=   set variable  ${counter_item['value']}
        ${counter_value}    Get From Dictionary    ${counter_item}    value
        ${status}=   set variable if  ${counter_value}>${expected_value}   True
        Set Test Variable   ${counter_values_final}    ${counter_value}
        exit for loop if    ${counter_value}>${expected_value}
    END
    should be equal    ${status}  True   Check counter value failed!
    [Return]    ${counter_values_final}
    [Teardown]   Logout To vCU By Rest

Check Counter value Be Equal To Expected Value For vCU
    [Arguments]    ${counter_id}     ${measurement_id}    ${dimension_dist_name}  ${expected_value}=0
    ...            ${get_number}=1    ${gnb_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | get_number | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_values_final} | return latest counter value |
    ...
    ...    Example
    ...    | ${value}= | check CU counter |  M55112C00002  |   55112  |   MRBTS-5560/NRBTS-5560  |  900  |  4  |
    ...
    Login To vCU By Rest    ${gnb_index}
    ${res}=  cu.Get Counter    ${measurement_id}     ${dimension_dist_name}    ${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    ${expected_counter_values}=    set variable    ${counter_values[-${get_number}:]}
    ${status}=   set variable   False
    FOR    ${counter_item}    IN    @{expected_counter_values[::-1]}
        ${start_time}=   set variable  ${counter_item['start_time']}
        ${start_time}=   set variable  ${counter_item['value']}
        ${counter_value}    Get From Dictionary    ${counter_item}    value
        ${status}=   set variable if  ${counter_value}==${expected_value}   True
        Set Test Variable   ${counter_values_final}    ${counter_value}
        exit for loop if    ${counter_value}==${expected_value}
    END
    should be equal    ${status}  True   Check counter value failed!
    [Return]    ${counter_values_final}
    [Teardown]   Logout To vCU By Rest

Check Counter For vDU
    [Arguments]    ${counter_id}     ${dimension_dn}    ${expected_value}
    ...            ${get_number}=1    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | get_number | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_values_final} | return latest counter value |
    ...
    ...    Example
    ...    | ${value}= | check CU counter |  M55112C00002  |   55112  |   MRBTS-5560/NRBTS-5560  |  900  |  4  |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${counter_values}=    vdu.get_counter_values    ${counter_id}    ${dimension_dn}
    ${expected_counter_values}=    set variable    ${counter_values[-${get_number}:]}
    ${status}=   set variable   False
    FOR    ${counter_item}    IN    @{expected_counter_values[::-1]}
        ${start_time}=    set variable    ${counter_item['start_time']}
        ${start_time}=    set variable    ${counter_item['value']}
        ${counter_value}    Get From Dictionary    ${counter_item}    value
        ${status}=    set variable if    ${counter_value}>${expected_value}    True
        Set Test Variable    ${counter_values_final}    ${counter_value}
        exit for loop if    ${counter_value}>${expected_value}
    END
    should be equal    ${status}    True    Check counter value failed!
    [Return]    ${counter_values_final}
    [Teardown]    vDU Logout By Rest

Prepare Collect Counter
    [Arguments]    ${master_ip}=${VDU_HOSTNAME}    ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${namespace}=${VDU_NAMESPACE}    ${pod_name}=pm    ${container_name}=pmcore
    [Documentation]    this kw is used to Prepare Collect Counter
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | vcontainer_name | yes | set container name by the parameter |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare Collect Counter | pod_name=pm | container_name=pmcore |
    ...
    Wait For New Measurement Period
    counter.remove_pm_report_in_pm_container    master_ip=${master_ip}    username=${username}    password=${password}
    ...                                 pod_name=${pod_name}    container_name=${container_name}    namespace=${namespace}
    counter.remove_pm_file_in_ute    hostname=${PC_HOST}    username=${PC_USER}    password=${PC_PASSWORD}

Remove PM File
    [Arguments]    ${master_ip}=${VDU_HOSTNAME}    ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${namespace}=${VDU_NAMESPACE}    ${pod_name}=pm    ${container_name}=pmcore
    [Documentation]    this kw is used to Prepare Collect Counter
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | vcontainer_name | yes | set container name by the parameter |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare Collect Counter | pod_name=pm | container_name=pmcore |
    ...
    counter.remove_pm_report_in_pm_container    master_ip=${master_ip}    username=${username}    password=${password}
    ...                                 pod_name=${pod_name}    container_name=${container_name}    namespace=${namespace}

Get Counter Value In vDU
    [Arguments]   ${counter_list}    ${pod_prefix}=po-cran11     ${container_prefix}=ctr-cran11   ${pod_name}=pm
    ...            ${container_name}=pmcore    ${tmp_log_dir}=/tmp/pm/
    [Documentation]    this kw is used to Prepare Collect Counter
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_prefix | yes | set pod prefix, such as: po-cran1 |
    ...    | container_prefix | yes | set container prefix, such as: ctr-cran1 |
    ...    | container_name | yes | set container name by the parameter  |
    ...    | pod_name | yes | set pod name by the parameter |
    ...    | tmp_log_dir | yes | define tmp log dir |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare Collect Counter | pod_name=pm | container_name=pmcore |
    ...
    counter.collect_counter_to_ute    master_ip=${du_master_ip}    username=${du_master_user}    password=${du_master_pwd}
    ...                       vm_hostname=${PC_HOST}    vm_username=${PC_USER}    vm_password=${PC_PASSWORD}
    ...                       namespace=${du_namespace}    pod_prefix=${pod_prefix}    container_prefix=${container_prefix}
    ...                       container_name=${container_name}    pod_name=${pod_name}    tmp_log_dir=${tmp_log_dir}
    ${counter_value_list}    counter.get_pm_value    counter_list=${counter_list}
    [Return]    ${counter_value_list}