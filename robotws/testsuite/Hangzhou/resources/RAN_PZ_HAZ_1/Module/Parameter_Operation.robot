*** Settings ***
Documentation
...    Author: Xiang Liangliang; Cao Ge
...    Email address: liang.xiang@nokia-sbell.com; ge.cao@nokia-sbell.com;
...    Maintainer: Xiang Liangliang;    Cao Ge
...    Email address: liang.xiang@nokia-sbell.com;    ge.cao@nokia-sbell.com;
...    Common KWs for modify parameter of AIC NE.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/01.+Module+of+Parameter+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Resource    ./library/_Parameter_Operation.robot



*** Keywords ***
Parameter Operation
    [Arguments]  ${operation}
    ...          ${product_type}
    ...          ${bts_index}=${0}
    ...          ${cudu_index}=${0}
    ...          ${delta_file_path}=${None}
    ...          ${para_list}=${None}
    ...          ${value_list}=${None}
    ...          ${mo_list}=${None}
    ...          ${scf_path}=${None}
    ...          ${timeout}=${600}
    ...          &{kwargs}
    [Documentation]  Parameter Operation
    ...    Author: Xiang Liang,gcao
    ...    Contact: liang.xiang@nokia-sbell.com,ge.cao@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operation | Yes |  operation type,"delta_plan_update" or "parameter_update" or "parameter_value_check" or
    ...     "full_commission" or "activate_plan".
    ...     if "delta_plan_update",parameter ${delta_file_path} should not be empty,
    ...     if "full_commission",parameter ${scf_path} should not be empty,
    ...     if "parameter_update" parameter ${para_list} ,${value_list} and ${mo_list} should not be empty,
    ...     if "parameter_value_check",parameter ${para_list} and ${mo_list} should not be empty,
    ...     if "activate_plan",parameter ${plan_id} should not be empty.|
    ...   | product_type | Yes |  Parameter Operation on vcu or vdu or gnb or enb|
    ...   | bts_index | NO |  gnb index in testline configurtion file. Default is 0. |
    ...   | cudu_index | NO | cu or vdu index in testline configurtion file. Default is 0. |
    ...   | delta_file_path | NO | Path of delta file |
    ...   | para_list | NO | prameter name list,for example: ["ethernetLinkInterval","ipFilteringInterval"] |
    ...   | value_list | NO | parameter value list,for example: ["15min","15min"],
    ...     if parameter value need random select from a list,This random list should be written as a string
    ...     connected with symbol "+",for example:"test_10868_btsname_03+test_10868_01+test_10868_02",then
    ...     parameter value list is: ["test_10868_btsname_03+test_10868_01+test_10868_02"] |
    ...   | mo_list |  NO | mo list,for example: ["MRBTS-${MRBTS_ID}/TNLSVC-1/PMTNLINT-1","MRBTS-${MRBTS_ID}/TNLSVC-1/PMTNLINT-1" |
    ...   | timeout | NO | Timeout for the delta commission finished, default is 300s. |
    ...
    ...    Example
    ...    | Parameter Operation | operation=delta_plan_update   product_type=vcu
    ...      delta_file_path=/home/ute/testline_configuration/Delta_configuration_scf_MRBTS-10868.xml |
    ...
    @{product_type_list}   create list   vdu   vcu   gnb   enb
    ${product_type}     Convert To Lowercase    ${product_type}
    Should Contain   ${product_type_list}   ${product_type}
    ${out}  Parameter Operation Internal   operation=${operation}   ne_type=${product_type}   ne_index=${cudu_index}
    ...     gnb_index=${bts_index}   delta_file_path=${delta_file_path}   para_list=${para_list}   value_list=${value_list}
    ...     mo_list=${mo_list}   scf_path=${scf_path}   timeout=${timeout}    kwargs=${kwargs}
    [Return]  ${out}

