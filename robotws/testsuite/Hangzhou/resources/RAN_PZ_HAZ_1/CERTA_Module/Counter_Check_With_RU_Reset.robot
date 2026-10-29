*** Settings ***
Documentation
...    Author: Wu Amy
...    Contact: amy.wu@nokia-sbell.com
...    Common KW use to counter check with ru reset
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the authors.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user:
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Resource    ./library/counter_check_with_ru_reset/utils.robot



*** Keywords ***
Counter Check With RU Reset
    [Arguments]  ${product_type}
    ...          ${ue_type}
    ...          ${bts_index}=${0}
    ...          ${cudu_index}=${0}
    ...          ${scf_path}=${None}
    ...          ${cell_distname_id}=${None}
    ...          ${counter_rule}=${None}
    ...          ${source}=${None}
    ...          ${source_max}=${None}
    ...          ${tl_descriptor_path}=${None}
    ...          ${timeout}=${300}
    ...          &{kwargs}
    Run Keyword If    "${scf_path}" != "${None}"    Parameter Operation    operation=full_commission
    ...    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    scf_path=${scf_path}
    BTS Operation    operation=verify    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    verify_status=SITE_ONAIR+CELL_ONAIR    timeout=${timeout}
    ${cell_list}    ${cell_info}    ${rus_distname}    Get Related Cell Info    product_type=${product_type}
    ...    cell_distname_id=${cell_distname_id}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${PA_param}    Create Dictionary    source=${source}    source_max=${source_max}
    ...    tl_descriptor_path=${tl_descriptor_path}    cell_list=${cell_list}    call_cell=${cell_info}
    Counter Operation    operation=start_collect_counter    product_type=${product_type}    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}    counter_rule=${counter_rule}
    set to dictionary    ${kwargs}    pci=${cell_info["phyCellId"]}
    UE L3 Call with traffic    ${product_type}    ${ue_type}    ${PA_param}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}    &{kwargs}
    Log To Console    \nCollect Counter And Check Rule...
    ${before_counter_value}    Counter Operation     operation=collect_counter_and_check_rule    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${value1}    Copy Dictionary    ${before_counter_value["value"]}    deepcopy=True
    Log To Console    \nCounter Rule Collect result1 is: ${before_counter_value}
    Log To Console    \nRU Resetting...
    BTS Operation    ru_reset    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    distname_id=${rus_distname}      need_verify=yes
    BTS Operation    verify    product_type=${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    need_verify=${True}    verify_status=CELL_ONAIR    timeout=${timeout}
    UE L3 Call with traffic    ${product_type}    ${ue_type}    ${PA_param}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}    &{kwargs}
    Log To Console    \nCollect Counter And Check Rule...
    ${after_counter_value}    Counter Operation     operation=collect_counter_and_check_rule    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    Log To Console    \nCounter Rule Collect result2 is: ${after_counter_value}
    ${value2}    Get From Dictionary    ${after_counter_value}    value
    ${result}    Counter Operation    operation=compare
    ...                  before_counter_value=${value1}
    ...                  after_counter_value=${value2}
