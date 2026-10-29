*** Settings ***
Documentation
...    Author: Xu Yuyan   Li Amaand
...    Email address: yuyan.xu@nokia-sbell.com    amaand.li@nokia-sbell.com
...    Maintainer: Xu Yuyan;    Li Amaand
...    Email address: yuyan.xu@nokia-sbell.com;    amaand.li@nokia-sbell.com;
...    Common KWs related to some operation on NOM for AIC.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement

*** Keywords ***
Setup NOM
    [Documentation]    Register NOM, Connect NOM
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Setup NOM |

    Get Common Variables
    #Register NOM Client
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable    ${NOM_OPEN_API_CLIENT_ID}    ${NOM_OPEN_API_CLIENT_ID}_${timestamp}
    Run Keyword And Ignore Error    nom_rest.Delete The Client    ${NOM_OPEN_API_CLIENT_ID}     ${NOM_OPEN_API_USERNAME}
    ...    ${NOM_OPEN_API_PASSWORD}    ${NOM_OPEN_API_GW}
    ${NOM_OPEN_API_CLIENT_SECRET}    nom_rest.Register The Client    ${NOM_OPEN_API_CLIENT_ID}
    ...    ${NOM_OPEN_API_USERNAME}    ${NOM_OPEN_API_PASSWORD}    ${NOM_OPEN_API_GW}
    #Connect NOM
    ${status}    Run Keyword And Return Status    nom_rest.Connect To    ${BASE_DOMAIN}     ${NOM_OPEN_API_GW}
    ...    ${NOM_OPEN_API_CLIENT_ID}    ${NOM_OPEN_API_CLIENT_SECRET}     443    ${NOM_OPEN_API_USERNAME}
    ...    ${NOM_OPEN_API_PASSWORD}    nom_v1    True
    Run Keyword If    ${status}    Log    Setup NOM session success    console=True
    ...    ELSE    FAIL    Setup NOM session fail!

Teardown NOM
    [Documentation]    delete NOM client
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Setup NOM |
    Run Keyword And Ignore Error    nom_rest.Delete The Client    ${NOM_OPEN_API_CLIENT_ID}
    ...    ${NOM_OPEN_API_USERNAME}    ${NOM_OPEN_API_PASSWORD}    ${NOM_OPEN_API_GW}
Get Common Variables
    [Documentation]    Get Common Variables
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Get Common Variables |
    set test variable    ${NOM_OPEN_API_CLIENT_ID}    openapi
    set test variable    ${NOM_OPEN_API_GW}    ${tl.nms.nom.https_rest_info.addr}
    set test variable    ${NOM_OPEN_API_USERNAME}    ${tl.nms.nom.https_main_info.username}
    set test variable    ${NOM_OPEN_API_PASSWORD}    ${tl.nms.nom.https_main_info.password}
    set test variable    ${BASE_DOMAIN}    ${tl.nms.nom.https_main_info.addr}
    set test variable    ${vDU_id}    ${tl.gnbs[0].dus[0].instance_id}
    set test variable    ${vCU_id}    ${tl.gnbs[0].instance_id}

NOM Integrate NE
    [Arguments]     ${integrate_plan_path}    ${integrate_plan_name}    ${timeout}=120s    ${reintegrate}=True
    [Documentation]   Integrate NE on NOM
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | integrate_plan_path    | yes | NE integrate plan path |
    ...   | integrate_plan_name    | yes | NE integrate plan name |
    ...   | timeout | no | timeout, default is 120s |
    ...   | reintegrate  | no | reintegrate, reintegrate in case the NE is already integrated to NOM, default is True |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | NOM Integrate NE | integrate_plan_path=/home/ute/vCU-11088-integration-plan.xml | integrate_plan_name=my_plan_name |
    CM Plan Import NOM Open API    ${integrate_plan_path}   ${integrate_plan_name}
    ${status}=    Run Keyword And Return Status    nom_rest.Integrate NE    ${integrate_plan_name}    ${timeout}   ${reintegrate}
    Run Keyword If    ${status}    Log    Integration ${integrate_plan_name} success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Integration ${integrate_plan_name} fail.    level=ERROR
    ...    AND    Fail    Integration ${integrate_plan_name} fail!

Get FHGW Id
    ${status}    Run Keyword And Return Status    Import Variables    ${tl.gnbs[0].dus[0].fhgws[0].user_config_path}
    Run Keyword If    Not ${status}    FAIL    Get FHGW user config file:${tl.gnbs[0].dus[0].fhgws[0].user_config_path} failed!
    ${status}    Run Keyword And Return Status    Set Test Variable     ${FHGW_id}    ${FHGW.fhgwId}
    Run Keyword If    ${status}    Log     FHGW Id is ${FHGW_id}   console=True
    ...    ELSE    FAIL    fhgwId does not existed in ${tl.gnbs[0].dus[0].fhgws[0].user_config_path}!
    [Return]    ${FHGW_id}


CM Plan Import NOM Open API
    [Arguments]    ${plan_path}    ${plan_name}
    ${status}=    Run Keyword And Return Status    nom_rest.Import Plan    ${plan_path}    name=${plan_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} import success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} import fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} import is fail!

CM Parameter Upload NOM Open API
    [Arguments]    ${integrated_ids}    ${timeout}=120s
    [Documentation]    Trigger CM Upload
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | integrated_ids    | yes | List of integrated element ids  |
    ...   | timeout    | no | default is 120s |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | CM Parameter Upload NOM Open API | integrated_ids=FHGW-11085 |
    ${status}    Run Keyword And Return Status    nom_rest.Upload Parameter    ${integrated_ids}    ${timeout}
    Run Keyword If    ${status}    Log    CM parameter upload finished successful.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    CM parameter upload fail.    level=ERROR
    ...    AND    Fail    CM parameter upload fail!

CM Plan Download NOM Open API
    [Arguments]     ${plan_name}    ${timeout}=30s
    [Documentation]    Download CM plan through NOM Open API
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | Name of the plan whose managed objects are to be integrated by this execution  |
    ...   | timeout    | no | default is 30s |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | CM Plan Download NOM Open API | plan_name=vCU-11088-delta-plan_2022-08-31_11-50-45 |
    ${status}=    Run Keyword And Return Status    nom_rest.Download Plan    ${plan_name}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} download success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} download fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} download is fail!

CM Plan Validate NOM Open API
    [Arguments]     ${plan_name}    ${timeout}=120s
    [Documentation]    Validate CM plan through NOM Open API
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | Name of the plan whose managed objects are to be integrated by this execution  |
    ...   | timeout    | no | default is 30s |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | CM Plan Validate NOM Open API | plan_name=vCU-11088-delta-plan_2022-08-31_11-50-45 |
    ${status}=    Run Keyword And Return Status    nom_rest.Validate Plan    ${plan_name}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} validate success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} validate fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} validate is fail!

CM Plan Activate NOM Open API
    [Arguments]     ${plan_name}    ${timeout}=120s
    [Documentation]    Activate CM plan through NOM Open API
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | Name of the plan whose managed objects are to be integrated by this execution  |
    ...   | timeout    | no | default is 30s |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | CM Plan Activate NOM Open API | plan_name=vCU-11088-delta-plan_2022-08-31_11-50-45 |
    ${status}=    Run Keyword And Return Status    nom_rest.Activate Plan    ${plan_name}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} Activate success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} Activate fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} Activate is fail!

CM Plan Provision NOM Open API
    [Arguments]     ${plan_name}    ${rollback_plan_generation}=False    ${timeout}=150s
    [Documentation]    Provision CM plan through NOM Open API
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | Name of the plan whose managed objects are to be integrated by this execution  |
    ...   | timeout    | no | default is 30s |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | CM Plan Provision NOM Open API | plan_name=vCU-11088-delta-plan_2022-08-31_11-50-45 |
    ${status}=    Run Keyword And Return Status    nom_rest.Provision Plan    ${plan_name}
    ...    ${rollback_plan_generation}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} Provision success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} Provision fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} Provision is fail!

CM Export Actual Configuration NOM Open API
    [Arguments]     ${integrated_dns}    ${output_actuals_file}
    [Documentation]   Export actual plan from NOM Open API for one or more NE
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | integrated_dns    | yes | List of managed object DNs  |
    ...   | output_actuals_file    | yes | Path to save file |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | CM Export Actual Configuration NOM Open API | integrated_dns=FHGW-11085 | output_actuals_file=/home/ute/cm_export_actual_plan.xml |
    Create File    ${output_actuals_file}
    ${file_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${output_actuals_file}
    ${status}    Run Keyword And Return Status    nom_rest.Export Plan    ${output_actuals_file}    ${integrated_dns}
    Run Keyword If    ${status} and ${file_exist}    Log    Export actual plan finished successful.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Export actual plan fail.    level=ERROR
    ...    AND    Fail    Export actual plan fail!

Generate Formatted Timestamp
    [Documentation]
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | current_time | NA |
    ...   Example
    ...  | ${current_time} | Generate Formatted Timestamp |
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}=    Get Time    format=year,month,day,hour,min,sec
    ${current_time}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}-${sec}
    [Return]  ${current_time}


Check CM Parameter Value From NOM Actual Plan
    [Arguments]    ${integrated_dn}    ${dist_name}    &{parameters_dict}
    [Documentation]    Check Actual Configuration Paramters
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | integrated_dn | List of managed object DNs |
    ...    | dist_name | dn of MO |
    ...    | parameters_dict | dictionary of parameter info, like parameter name:parameter value |
    ...    | Return Value | Description |
    ...    | None | NA |
    Log    Check Actual Configuration Parameters    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    CM Export Actual Configuration NOM Open API
    ...    ${integrated_dn}    ${TEST_LOG_DIRECTORY}/cm_export_actual_plan.xml
    ${param_names}    Get Dictionary Keys    ${parameters_dict}
    ${param_values}    Get Dictionary Values    ${parameters_dict}
    ${param_count}    Get Length    ${param_names}
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/cm_export_actual_plan.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${1}
    FOR    ${index}    IN RANGE    0    ${param_count}
        ${actual_value}    Set Variable If    '${param_values[${index}]}'=='None'    ${EMPTY}    ${param_values[${index}]}
        ${is_string}    Run Keyword And Return Status    Should Be String    ${actual_value}
        Run Keyword If    ${is_string}    Compare String Value In XML    ${scf_xml}    true    ${dist_name}    ${param_names[${index}]}
        ...    ${actual_value}
        ...    ELSE    Compare Unstring Value In XML    ${scf_xml}   true    ${dist_name}    ${param_names[${index}]}
        ...    ${actual_value}
    END


Compare String Value In XML
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    [Documentation]    Compare String Value In XML
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | scf_xml | scf file |
    ...    | ui_values | yes is UI value, no is internal value |
    ...    | dist_name | dn of MO |
    ...    | param_name | parameter name |
    ...    | expected_value | expected parameter value |
    ...    | Return Value | Description |
    ...    | None | NA |
    ${expected_value_formatted}    Run Keyword If    '${ui_values}'=='false'
    ...    Set Variable If      '${expected_value}'=='true'    1
    ...    '${expected_value}'=='false'    0
    ...    '${expected_value}'!='true'and '${expected_value}'!='false'    ${expected_value}
    ...    ELSE    Set Variable    ${expected_value}
    ${status}    ${value}    Run Keyword And Ignore Error    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ${actual_value}   Set Variable If   '${status}'=='PASS'    ${value}    ${EMPTY}
    Should Be Equal    ${actual_value}    ${expected_value_formatted}

Compare Unstring Value In XML
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    ${is_string}    Run Keyword If    len(${expected_value})>0    Run Keyword And Return Status    Should Be String    ${expected_value[0]}
    ...    ELSE    Set Variable    True
    ${actual_value}    Run Keyword If    ${is_string}     Compare List Value In XML
    ...    ${scf_xml}    ${dist_name}    ${param_name}    ${expected_value}
    ...    ELSE    Compare Structure Value In XML    ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}

Compare List Value In XML
    [Arguments]     ${scf_xml}    ${dist_name}    ${param_name}    ${expected_value}
    ${actual_value}    L_XML.Get Elements Texts    ${scf_xml}    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/p
    ${actual_value}    Convert To List    ${actual_value}
    Lists Should Be Equal    ${actual_value}    ${expected_value}

Compare Structure Value In XML
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    ${element_dic}    Create Dictionary
    ${actual_items}    L_XML.Get Child Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/item
    FOR    ${item}    IN    @{actual_items}
        ${p_name}    L_XML.Get Element Attribute    ${item}    name
        ${p_value}    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${element_dic}    ${p_name}    ${p_value}
    END
    ${actual_value}    Create List    ${element_dic}
    ${actual_value}    Convert To List    ${actual_value}
    ${expected_value_formatted}    Create List
    FOR    ${item}    IN    @{expected_value}
        ${expected_item_formatted}    Run Keyword If    '${ui_values}'=='false'
        ...    Convert Boolean Value From UI_Value To Internal_Value For Structure    ${item}
        ...    ELSE    Set Variable     ${item}
        Append To List    ${expected_value_formatted}    ${expected_item_formatted}
    END
    Lists Should Be Equal    ${actual_value}    ${expected_value_formatted}

Convert Boolean Value From UI_Value To Internal_Value For Structure
    [Arguments]    ${structure_values}
    ${keys}     Get Dictionary Keys    ${structure_values}
    FOR    ${key}    IN    @{keys}
         ${value}    Get From Dictionary    ${structure_values}    ${key}
         ${convert_value}    Set Variable If
         ...    '${value}'=='true'    1
         ...    '${value}'=='false'    0
         ...    '${value}'!='true' and '${value}'!='false'    ${value}
         Set To Dictionary    ${structure_values}    ${key}    ${convert_value}
    END
    [Return]    ${structure_values}

