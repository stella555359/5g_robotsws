*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Xiang Liangliang;    Cao Ge
...    Email address: liang.xiang@nokia-sbell.com;    ge.cao@nokia-sbell.com;
...    Common KWs related to PM counter and KPI.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement


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
    Wait Until Keyword Succeeds    45m    1m    Time To Start Calls    interval=${interval}

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
    ...            ${get_number}=1    ${gnb_index}=0    ${comparison}=greater
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
    should not be empty    ${res['values']}
    ${counter_values}=  set variable    ${res["values"]}
    ${expected_counter_values}=    set variable    ${counter_values[-${get_number}:]}
    ${status}=   set variable   False
    FOR    ${counter_item}    IN    @{expected_counter_values[::-1]}
        ${start_time}=   set variable  ${counter_item['start_time']}
        ${start_time}=   set variable  ${counter_item['value']}
        ${counter_value}    Get From Dictionary    ${counter_item}    value
        Set Test Variable    ${counter_values_final}    ${counter_value}
        ${status}=     Run Keyword If    '${comparison}'=='greater'  set variable if
        ...                                              ${counter_value}>${expected_value}    True
        ...           ELSE IF    '${comparison}'=='equal'    set variable if
        ...                                              ${counter_value}==${expected_value}    True
        ...           ELSE IF    '${comparison}'=='less'    set variable if
        ...                                              ${counter_value}<${expected_value}    True
        Run Keyword If    '${comparison}'=='greater'  exit for loop if    ${counter_value}>${expected_value}
        ...    ELSE IF    '${comparison}'=='equal'    exit for loop if    ${counter_value}==${expected_value}
        ...    ELSE IF    '${comparison}'=='less'    exit for loop if    ${counter_value}<${expected_value}
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
    should not be empty    ${res['values']}
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
    ...            ${get_number}=1    ${gnb_index}=0    ${vdu_index}=0    ${comparison}=greater
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
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${counter_values}=    vdu.get_counter_values    ${counter_id}    ${dimension_dn}
    should not be empty    ${counter_values}
    ${expected_counter_values}=    set variable    ${counter_values[-${get_number}:]}
    ${status}=   set variable   False
    FOR    ${counter_item}    IN    @{expected_counter_values[::-1]}
        ${start_time}=    set variable    ${counter_item['start_time']}
        ${start_time}=    set variable    ${counter_item['value']}
        ${counter_value}    Get From Dictionary    ${counter_item}    value
        Set Test Variable    ${counter_values_final}    ${counter_value}
        ${status}=     Run Keyword If    '${comparison}'=='greater'  set variable if
        ...                                              ${counter_value}>${expected_value}    True
        ...           ELSE IF    '${comparison}'=='equal'    set variable if
        ...                                              ${counter_value}==${expected_value}    True
        ...           ELSE IF    '${comparison}'=='less'    set variable if
        ...                                              ${counter_value}<${expected_value}    True
        Run Keyword If    '${comparison}'=='greater'  exit for loop if    ${counter_value}>${expected_value}
        ...    ELSE IF    '${comparison}'=='equal'    exit for loop if    ${counter_value}==${expected_value}
        ...    ELSE IF    '${comparison}'=='less'    exit for loop if    ${counter_value}<${expected_value}
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

Collect PM File To UTE
    [Arguments]   ${master_ip}=${VDU_HOSTNAME}    ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...           ${namespace}=${VDU_NAMESPACE}    ${pod_prefix}=po-cran1     ${container_prefix}=ctr-cran1
    ...           ${pod_name}=pm    ${container_name}=pmcore    ${tmp_log_dir}=/tmp/pm/    ${local_path}=/tmp/pm.tar.gz
    [Documentation]    this kw is used to Collect PM File To UTE
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
    ...    | Collect PM File To UTE | pod_name=pm | container_name=pmcore |
    ...
    counter.collect_counter_to_ute    master_ip=${master_ip}    username=${username}    password=${password}
    ...                       vm_hostname=${PC_HOST}    vm_username=${PC_USER}    vm_password=${PC_PASSWORD}
    ...                       namespace=${namespace}    pod_prefix=${pod_prefix}    container_prefix=${container_prefix}
    ...                       container_name=${container_name}    pod_name=${pod_name}    tmp_log_dir=${tmp_log_dir}
    ...                       local_path=${local_path}

Generate Counter PIId
     [Arguments]   ${start_id}    ${stop_id}    ${step}=1
    [Documentation]    this kw is used to generate counter PI Id generator object
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | start_id | yes | start value of the counter PI Id sequence, such as: M55360C01000 |
    ...    | stop_id | yes | end value of the counter PI Id sequence, such as: M55360C01272 |
    ...    | step | yes | denoting the difference between any two numbers in the sequence, such as: 1  |
    ...
    ...    | Return Value | Description |
    ...    | counter_piid | Returns a generator object |
    ...
    ...    Example
    ...    | Generate Counter PIId | start_id=M55360C01000 | stop_id=M55360C01272 | step=1 |
    ${counter_piid}    counter.counter_piid_generator    start_id=${start_id}    stop_id=${stop_id}    step=${step}
    Log to Console    \n***Generate a counter PI Id generator object***
    [Return]    ${counter_piid}

_Get Counter For vDU
    [Arguments]    ${counter_id}     ${dimension_dn}
    ...            ${get_number}=1    ${gnb_index}=0    ${vdu_index}=0
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${counter_values}=    vdu.get_counter_values    ${counter_id}    ${dimension_dn}
    ${expected_counter_values}   run keyword if     ${counter_values}!=None
    ...    set variable    ${counter_values[-${get_number}:]}
    ...    ELSE    set variable    ${None}
    [Return]   ${expected_counter_values}
    [Teardown]    vDU Logout By Rest

Get UL BLER
    [Arguments]    ${dn_mo}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    [Documentation]    Get UL BLER from webUI via rest API.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | dn_mo | Yes | the dimension dist name that the counter belongs to, like MRBTS-11068/NRBTS-11068/NRCELL-1|
    ...
    ...    | Return Value | Description |
    ...    | ${ratio} | return Ul BLER |
    ...
    ...    Example
    ...    | ${ratio}= | Get UL BLER |  dn_mo=MRBTS-11068/NRBTS-11068/NRCELL-1  |
    ...
    @{initial_sent}    create list    M55302C00001  M55302C00002  M55302C00003  M55302C00004  M55302C00005  M55302C00006
	...                               M55302C00007  M55302C00008  M55302C00009  M55302C00010  M55302C00011  M55302C00012
	...                               M55302C00013  M55302C00014  M55302C00015  M55302C00016  M55302C00017  M55302C00018
	...                               M55302C00019  M55302C00020  M55302C00021  M55302C00022  M55302C00023  M55302C00024
	...                               M55302C00025  M55302C00026  M55302C00027  M55302C00028  M55302C00000
	...                               M55302C06001  M55302C06002  M55302C06003  M55302C06004  M55302C06005  M55302C06006
	...                               M55302C06007  M55302C06008  M55302C06009  M55302C06010  M55302C06011  M55302C06012
	...                               M55302C06013  M55302C06014  M55302C06015  M55302C06016  M55302C06017  M55302C06018
	...                               M55302C06019  M55302C06020  M55302C06021  M55302C06022  M55302C06023  M55302C06024
	...                               M55302C06025  M55302C06026  M55302C06027  M55302C06000
	...                               M55302C11001  M55302C11002  M55302C11003  M55302C11004  M55302C11005  M55302C11006
	...                               M55302C11007  M55302C11008  M55302C11009  M55302C11010  M55302C11011  M55302C11012
    ...                               M55302C11013  M55302C11014  M55302C11015  M55302C11016  M55302C11017  M55302C11018
    ...                               M55302C11019  M55302C11020  M55302C11021  M55302C11022  M55302C11023  M55302C11025
	...                               M55302C11026  M55302C11027  M55302C11000
    @{initial_success}    create list    M55302C04001  M55302C04002  M55302C04003  M55302C04004  M55302C04005  M55302C04006
	...                                  M55302C04007  M55302C04008  M55302C04009  M55302C04010  M55302C04011  M55302C04012
	...                                  M55302C04013  M55302C04014  M55302C04015  M55302C04016  M55302C04017  M55302C04018
	...                                  M55302C04019  M55302C04020  M55302C04021  M55302C04022  M55302C04023  M55302C04024
	...                                  M55302C04025  M55302C04026  M55302C04027  M55302C04028  M55302C04000
    ...                                  M55302C08001  M55302C08002	 M55302C08003  M55302C08004  M55302C08005  M55302C08006
	...                                  M55302C08007  M55302C08008  M55302C08009  M55302C08010  M55302C08011  M55302C08012
	...                                  M55302C08013  M55302C08014  M55302C08015  M55302C08016  M55302C08017  M55302C08018
	...                                  M55302C08019  M55302C08020  M55302C08021  M55302C08022  M55302C08023  M55302C08024
	...                                  M55302C08025  M55302C08026  M55302C08027  M55302C08000
	...                                  M55302C13001  M55302C13002  M55302C13003  M55302C13004  M55302C13005  M55302C13006
    ...                                  M55302C13007  M55302C13008  M55302C13009  M55302C13010  M55302C13011  M55302C13012
	...                                  M55302C13013  M55302C13014  M55302C13015  M55302C13016  M55302C13017  M55302C13018
    ...                                  M55302C13019  M55302C13020  M55302C13021  M55302C13022  M55302C13023  M55302C13024
	...                                  M55302C13025  M55302C13026  M55302C13027  M55302C13000
    ${initial_sent_sum}    Set Variable    ${0}
    ${initial_success_sum}    Set Variable    ${0}
    FOR    ${counter_id}  IN   @{initial_sent}
        ${counter_value}    _Get Counter For vDU   counter_id=${counter_id}    dimension_dn=${dn_mo}
        ${initial_sent_sum}   run keyword if   ${counter_value}!=None
        ...      Evaluate    ${counter_value[${0}]['value']}+${initial_sent_sum}
    END
    FOR    ${counter_id}  IN   @{initial_success}
        ${counter_value}    _Get Counter For vDU   counter_id=${counter_id}    dimension_dn=${dn_mo}
        ${initial_success_sum}   run keyword if   ${counter_value}!=None
        ...      Evaluate    ${counter_value[${0}]['value']}+${initial_success_sum}
    END
    ${ratio}    Evaluate     (${initial_sent_sum}-${initial_success_sum})/${initial_sent_sum}
    ${ratio}    Evaluate    round(${ratio},3)
#    ${ratio}    Set Variable     ${ratio}%
    [Return]    ${ratio}


Get DL BLER
    [Arguments]    ${dn_mo}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    [Documentation]    Get DL BLER from webUI via rest API.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | dn_mo | Yes | the dimension dist name that the counter belongs to, like MRBTS-11068/NRBTS-11068/NRCELL-1|
    ...
    ...    | Return Value | Description |
    ...    | ${ratio} | return Dl BLER |
    ...
    ...    Example
    ...    | ${ratio}= | Get DL BLER |  dn_mo=MRBTS-11068/NRBTS-11068/NRCELL-1  |
    ...
    @{initial_sent}    create list    M55300C00018    M55300C00019  M55300C00020   M55300C00021   M55300C00022   M55300C00023
    ...                               M55300C00024    M55300C00025  M55300C00026    M55300C00027   M55300C00028  M55300C00017
    ...                               M55300C04018    M55300C04019  M55300C04020    M55300C04021   M55300C04022    M55300C04023
    ...                               M55300C04024    M55300C04025  M55300C04026    M55300C04027
    @{initial_success}    create list    M55300C01017    M55300C01018     M55300C01019    M55300C01020   M55300C01021    M55300C01022
    ...                                  M55300C01023    M55300C01024     M55300C01025    M55300C01026   M55300C01027    M55300C01028
    ...                                  M55300C05018    M55300C05019     M55300C05020    M55300C05021   M55300C05022    M55300C05023
    ...                                  M55300C05024    M55300C05025     M55300C05026    M55300C05027
    ${initial_sent_sum}    Set Variable    ${0}
    ${initial_success_sum}    Set Variable    ${0}
    FOR    ${counter_id}  IN   @{initial_sent}
        ${counter_value}    _Get Counter For vDU   counter_id=${counter_id}    dimension_dn=${dn_mo}
        ${initial_sent_sum}   run keyword if   ${counter_value}!=None
        ...      Evaluate    ${counter_value[${0}]['value']}+${initial_sent_sum}
    END
    FOR    ${counter_id}  IN   @{initial_success}
        ${counter_value}    _Get Counter For vDU   counter_id=${counter_id}    dimension_dn=${dn_mo}
        ${initial_success_sum}   run keyword if   ${counter_value}!=None
        ...      Evaluate    ${counter_value[${0}]['value']}+${initial_success_sum}
    END
    ${ratio}    Evaluate     (${initial_sent_sum}-${initial_success_sum})/${initial_sent_sum}
    ${ratio}    Evaluate    round(${ratio},3)
#    ${ratio}    Set Variable     ${ratio}%
    [Return]    ${ratio}
