*** Settings ***
Documentation

*** Keywords ***
Check Parameter Value From SCF For PDCCH
    [Arguments]    ${scf_content}    ${nrcell_dn}    ${addParam_dic}
    [Documentation]    keyword for checking parameters value under pdcchAutoConfig for FCT feature CB009451
    ...    | Input Parameters | Man. | Description |
    ...    | scf_content | Yes | scf content |
    ...    | nrcell_dn | Yes | nrcell distname |
    ...    | addParam_dic | Yes | dictionary. additional parameters needed check |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Check Parameter Value From SCF For PDCCH | scf_content = ${scf_content} | nrcell_dn=MRBTS-11085/NRBTS-11085/NRCELL-1 |
    ...    |addParam_dic= {'cellCoverageLevel': 'normal', 'initialBWPMode': 'sameAsCoreset0'} |
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${pdcchParams}   L_XML.Get Child Elements    ${scf_content}    .//managedObject[@distName="${nrcell_dn}"]/list[@name="pdcchAutoConfig"]/item
    ${pdcchParamsName_list}    Create List
    ${addParam_dic_keys}    Get Dictionary Keys    ${addParam_dic}
    Sort List    ${addParam_dic_keys}
    FOR    ${item}    IN    @{pdcchParams}
        ${paramName}    L_XML.Get Element Attribute    ${item}    name
        ${paramValue}    L_XML.Get Element Text    ${item}
        Should Be Equal As Strings    ${paramValue}    ${addParam_dic['${paramName}']}
        Append To List    ${pdcchParamsName_list}    ${paramName}
    END
    Sort List    ${pdcchParamsName_list}
    Lists Should Be Equal    ${addParam_dic_keys}    ${pdcchParamsName_list}

Check Saved FCT Json Report Content
    [Arguments]    ${json_report}    ${validation_results_webem}    ${outputparameters_webem}
    [Documentation]    keyword for checking FCT Json report content for FCT feature CB010974
    ...    | Input Parameters | Man. | Description |
    ...    | json_report | Yes | scf content |
    ...    | validation_results_webem | Yes | list. each item is a dictionary. from Validation results table on WebEM |
    ...    | outputparameters_webem | Yes | list. each item is a dictionary. from Additional output parameters table on WebEM |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Check Saved FCT Json Report Content | json_report = ${json_report} | validation_results_webem=${validation_results_webem} |
    ...    |outputparameters_webem= ${outputparameters_webem} |
    ${file_content}    OperatingSystem.Get File    ${json_report}
    ${report_content}    Evaluate    ${file_content}
    ${operationStatus}    Set Variable    ${report_content["operationStatus"]}
    ${operationResults_list}    Set Variable    ${report_content["operationResults"]}
    Run Keyword If    "${validation_results_webem[0]}"=="No data"    Run Keywords
    ...    Should be True    "${operationResults_list.__len__()}"=="${0}"    AND    Should Be True    "${operationStatus}"=="Finished"    AND
    ...    Should Contain    ${report_content["operationFeedback"]}    operation successful    AND    Return From Keyword
    ${sub_distName_list}    Create List
    ${sub_operationStatus_list}    Create List
    ${checks_sum}    Set Variable    0
    FOR    ${operationResult}    IN    @{operationResults_list}
        Append To List    ${sub_distName_list}    ${operationResult["distName"]}
        ${sub_addOutput_dic}    Set Variable    ${operationResult["additionalOutputParameters"]}
        _Check OutPutParameters In Json Report And WebEM    ${operationResult["distName"]}    ${sub_addOutput_dic}    ${outputparameters_webem}
        Append To List    ${sub_operationStatus_list}    ${operationResult["operationStatus"]}
        ${sub_checks_list}    Set Variable    ${operationResult["checks"]}
        ${sub_checks_len}    Get length    ${sub_checks_list}
        ${checks_sum}    evaluate    ${checks_sum}+${sub_checks_len}
    END
    ${sub_operationStatus_list}    Remove Duplicates    ${sub_operationStatus_list}
    ${sub_distName_list}    Remove Duplicates    ${sub_distName_list}
    ${finishedList}    Create List    Finished
    ${finished}    Run keyword And Return Status    Lists Should Be Equal    ${sub_operationStatus_list}    ${finishedList}
    #operationStatus
    Run Keyword If    ${finished}    Should Be Equal    ${operationStatus}    Finished    ELSE    Should Be Equal
    ...    ${operationStatus}    Failed
    #distName
    ${sub_DN_list_webem}    Create List
    FOR    ${result_webem}    IN    @{validation_results_webem}
        Append To List    ${sub_DN_list_webem}    ${result_webem["Object name"]}
    END
    ${sub_DN_list_webem}    Remove Duplicates    ${sub_DN_list_webem}
    Sort List    ${sub_distName_list}
    Sort List    ${sub_DN_list_webem}
    Lists Should Be Equal    ${sub_distName_list}    ${sub_DN_list_webem}
    #check checks number
    ${checks_num_webem}    Get length    ${validation_results_webem}
    ${checks_sum}    Convert To Integer    ${checks_sum}
    ${checks_num_webem}    Convert To Integer    ${checks_num_webem}
    Should be True    ${checks_sum}==${checks_num_webem}

_Check OutPutParameters In Json Report And WebEM
    [Arguments]    ${distname}    ${sub_addOutput_dic}    ${outputparameters_webem}
    [Documentation]    keyword for checking output parameters from Json report and WebEM table,invoke by KW:Check Saved FCT Json Report Content
    ...    | Input Parameters | Man. | Description |
    ...    | distname | Yes | scf content |
    ...    | sub_addOutput_dic | Yes | dictionary. it is all output parameters and values of one object in Json Report |
    ...    | outputparameters_webem | Yes | list. each item is a dictionary. from Additional output parameters table on WebEM |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | _Check OutPutParameters In Json Report And WebEM | distname = ${distname} | sub_addOutput_dic=${sub_addOutput_dic} |
    ...    | outputparameters_webem= ${outputparameters_webem} |
    ${sub_outputparamsWebem_dic}    Create Dictionary
    Run Keyword If    "${outputparameters_webem[0]}"=="No data"    Run Keywords
    ...    Dictionaries Should Be Equal    ${sub_addOutput_dic}    ${sub_outputparamsWebem_dic}    AND    Return From Keyword
    FOR    ${param_webem}    IN    @{outputparameters_webem}
        Run Keyword If    "${distname}"=="${param_webem["Object distinguished name"]}"
        ...    Set To Dictionary    ${sub_outputparamsWebem_dic}    ${param_webem["Abbreviation"]}=${param_webem["Value"]}
    END
    Dictionaries Should Be Equal    ${sub_addOutput_dic}    ${sub_outputparamsWebem_dic}

Clean Existing Restriction Rule
    [Documentation]    Clean existing restriction rule through plan provision for CB006530 function
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
     ...    | Input Parameters | Man. | Description |
    ...    | mo_id | Yes | MO distName|
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | scf_file | Yes | the path of scf file
    ...    | Return Value | Description |
    ...    | compare_result | return the comparation result for current sw release and tag|
    [Arguments]      ${mo_id}    ${scf_distName}    ${scf_file}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    ${clean_rules}    Set Variable    CB006530_Clean_Prevent_Rule_MRBTS-${vDU_id}_${timestamp}
    ${param_dic_emtpy}    Create Dictionary    preventParamModifList=${EMPTY}    preventParamModifTargetDN=${EMPTY}
    ${delete_rule_plan}    NetAct Create And Edit Plan    BTS_scf_initial=${scf_file}
    ...    name=${clean_rules}    description=Automation SyVe for MRBTS-${vDU_id}
    ...    mo_id=${mo_id}    scf_distName=${scf_distName}    &{param_dic_emtpy}
    NetAct Provision Plan    plan_name=${clean_rules}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Check If NetAct Plan Is Deleted    plan_name=${clean_rules}

Get MO DN From SCF
    [Documentation]    Get MO DN From SCF by xpath
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
     ...    | Input Parameters | Man. | Description |
    ...     | scf_path | Yes | cthe path of scf file |
    ...     | xpath | Yes | xpath locator of mo dn |
    [Arguments]   ${scf_path}    ${xpath}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse Xml    ${scf_path}
    ${xml_elements}    L_XML.Get Elements    ${scf_xml}    ${xpath}
    ${dn_list}    Create List
    FOR    ${obj}    IN    @{xml_elements}
        ${obj_dn}    L_XML.Get Element Attribute    ${obj}    distName
        Append To List    ${dn_list}     ${obj_dn}
    END
    [Return]    ${dn_list}

Check Specified Cell Status On vDU
    [Documentation]    Check Specified Cell Status On vDU
    ...    Author: yuyan xu
    [Arguments]    ${cellName}    ${expected_cellStatus_dic}
    ${cellStatus_Dic}    Get Specified Cell Status On vDU    ${cellName}
    ${keys}    get dictionary keys    ${expected_cellStatus_dic}
    FOR    ${key}   IN    @{keys}
        Should Be Equal    ${cellStatus_Dic["${key}"]}    ${expected_cellStatus_dic["${key}"]}
    END

Get Specified Cell Status On vDU
    [Arguments]    ${cellName}
    [Documentation]    Get Specified Cell Status On vDU
    ...    Author: yuyan xu
    ${cells_info}=  vdu.get_vdu_cells_status
    ${cellStatus_Dic}    Create Dictionary
    FOR    ${cell_info}    IN    @{cells_info}
       Continue For Loop If    '${cell_info["name"]}' != '${cellName}'
       Set To Dictionary    ${cellStatus_Dic}    operationalState=${cell_info["operational_state"]}
       ...    availabilityStatus=${cell_info["availability_status"]}
       ...    administrativeState=${cell_info["administrative_state"]}   blockState=${cell_info["blocking_state"]}
    END
    [return]    ${cellStatus_Dic}

Check Specified Cell Status On vCU
    [Documentation]    Check Specified Cell Status On vCU
    ...    Author: yuyan xu
    [Arguments]    ${cellName}    ${expected_cellStatus_dic}
    ${cellStatus_Dic}    Get Specified Cell Status On vCU    ${cellName}
    ${keys}    get dictionary keys    ${expected_cellStatus_dic}
    FOR    ${key}   IN    @{keys}
        Should Be Equal    ${cellStatus_Dic["${key}"]}    ${expected_cellStatus_dic["${key}"]}
    END

Get Specified Cell Status On vCU
    [Arguments]    ${cellName}
    [Documentation]    Get Specified Cell Status On vCU
    ...    Author: yuyan xu
    ${cells_info}=  cu.get_cells_statuses
    ${cellStatus_Dic}    Create Dictionary
    FOR    ${cell_info}    IN    @{cells_info}
       Continue For Loop If    '${cell_info["name"]}' != '${cellName}'
       Set To Dictionary    ${cellStatus_Dic}    operationalState=${cell_info["operational_state"]}
       ...    administrativeState=${cell_info["administrative_state"]}
    END
    [return]    ${cellStatus_Dic}

Enable CB012523 Feature-bk-12840
    [Arguments]    ${cellIds_list}    ${maxCellDisableTimeWhenNmsLost}=30    ${shutdownWindow}=180    ${alias}=default
    [Documentation]    Enable CB012523 Feature
    ...    Author: yuyan xu
    Log To Console    Enable CB012523 Feature
    Log    ${alias}
    ${plan_id}    ${action_id}   Generate Delta Plan In vDU    DELTA-PLAN-12523_001
    ${param_dic1}    create dictionary    disableCellWhenNmsLost=true
    ${param_dic2}    create dictionary    maxCellDisableTimeWhenNmsLost=${maxCellDisableTimeWhenNmsLost}    shutdownWindow=${shutdownWindow}
    FOR    ${cell_id}    IN    @{cellIds_list}
        Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${cell_id}    ${param_dic1}
    END
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ${param_dic2}
    Set Test Variable   ${plan_id}
    Validate Delta Plan By REST In vDU    ${plan_id}
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
    ${rtn}    Wait until keyword succeeds    300    30s   _Check Activate Delta Plan Status Should Be Expected
    ...    operation_id=${out['id']}    plan_id=${plan_id}    expected_status=success

Enable CB012523 Feature
    [Arguments]    ${cellIds_list}    ${maxCellDisableTimeWhenNmsLost}=30    ${shutdownWindow}=180    ${alias}=default
    [Documentation]    Enable CB012523 Feature
    ...    Author: yuyan xu
    Log To Console    Enable CB012523 Feature
    Log    ${alias}
    @{para_list}    Create List    maxCellDisableTimeWhenNmsLost    shutdownWindow
    @{value_list}    Create List    ${maxCellDisableTimeWhenNmsLost}    ${shutdownWindow}
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}
    FOR    ${cell_id}    IN    @{cellIds_list}
        Append To List    ${para_list}    disableCellWhenNmsLost
        Append To List    ${value_list}    true
        Append To List    ${mo_list}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${cell_id}
    END
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Check NMS State
    [Arguments]    ${expected_state}
    [Documentation]    Check NMS State as ${expected_state}
    ...    Author: yuyan xu
    Log To Console    Check NMS State
    ${nms_state}    vdu.get_nms
    ${dl_state}    Set Variable    ${nms_state["downlink_from_nms"]}
    Log To Console    ${dl_state}
    Should Be True    "${dl_state}"=="${expected_state}"

Get Parameter Value From vDU
    [Arguments]    ${scf_distName}    ${param_name}    ${include_runtime_data}=${True}
    [Documentation]    Helper keyword used for get parameter value from vDU, if not find this parameter,
    ...    will fail this keyword.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | param_name | Yes | parameters name | \ parameter_name unfit parameter in list
    ...    | include_runtime_data | No | parameters name | include runtime data
    ${result}    Set Variable    False
    ${time}    Get Time    epoch
    ${BTS_scf}    vdu.get_current_plan_file    local_dir_path=${TEST_LOG_DIRECTORY}    filename=current_scf_${time}.xml
    ...    include_runtime_data=${include_runtime_data}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf}
    ${result_value}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]/p
    ${result_value_dict}=    Create dictionary
    FOR    ${item}    IN    @{result_value}
        ${name}    L_XML.Get Element Attribute    ${item}    name
        ${value}    L_XML.Get Element Text    ${item}
        ${result}    Set Variable If    '${name}' == '${param_name}'    True
        Return From Keyword If    '${name}' == '${param_name}'    ${value}
    END
    Should Be True    ${result}    True

Get Parameter Value From vCU
    [Arguments]    ${scf_distName}    ${param_name}    ${include_runtime_data}=${True}
    [Documentation]    Helper keyword used for get parameter value from vCU, if not find this parameter,
    ...    will fail this keyword.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | param_name | Yes | parameters name | \ parameter_name unfit parameter in list
    ...    | include_runtime_data | No | parameters name | include runtime data
    ${result}    Set Variable    False
    ${time}    Get Time    epoch
    ${BTS_scf}    cu.get_current_plan_file    path=${TEST_LOG_DIRECTORY}/current_scf_${time}.xml
    ...    include_runtime_data=${include_runtime_data}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf}
    ${result_value}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]/p
    ${result_value_dict}=    Create dictionary
    FOR    ${item}    IN    @{result_value}
        ${name}    L_XML.Get Element Attribute    ${item}    name
        ${value}    L_XML.Get Element Text    ${item}
        ${result}    Set Variable If    '${name}' == '${param_name}'    True
        Return From Keyword If    '${name}' == '${param_name}'    ${value}
    END
    Should Be True    ${result}    True


Check IP Is Pingable
    [Arguments]    ${ip}    ${ping_count}=1    ${ping_timeout}=2    ${expect_pingable}=${True}
    [Documentation]    This KW is for linux system only
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c ${ping_count} -w ${ping_timeout} ${ip}
    ${ping_status}    Evaluate    ${rc}==${0}
    Should Be Equal    ${ping_status}    ${expect_pingable}

Create Plan To Modify Mutiple Parameters On NetAct
    [Arguments]    ${scf_initial}    ${plan_name}    ${description}=None    &{parameters_dict}
    [Documentation]    This KW is for Create Plan To Modify Mutiple Parameters On NetAct
    ...
    ...    *AUTHOR* yuyan.xu@nokia-sbell.com
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    ${plan}=    NetAct Create Plan    ${plan_name}    ${description}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${scf_initial}
    ${scf_distNames}    Get Dictionary Keys    ${parameters_dict}
    ${MRBTS_id}    Fetch From Left    ${scf_distNames[0]}    /
    FOR    ${scf_DN}    IN    @{scf_distNames}
    ${params_dic}    Set Variable    ${parameters_dict["${scf_DN}"]}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${scf_DN}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${scf_DN}    &{params_dic}
    END
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${plan_name}.xml    dist_names=PLMN-PLMN/${MRBTS_id}
    ...    plan_name=${plan_name}    operation_type=plan
    [Return]   ${plan_name}

Check RU Status As Expected
    [Arguments]     ${ru_id}   ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled    ${vdu_index}=0
    [Documentation]      Check specified cell status should be as expected.
    ...    Author: yuyan xu
    ...    | Check RU Status As Expected  |  123  |   locked  |  disabled  | 0 |
    Log     ${expected_operational_state} is not used
    ${ru_administrativeState}  ${ru_operationalState}=    Get Specified RU Status In vDU   ${ru_id}  ${vdu_index}
    should be true     "${ru_administrativeState}"=="${expected_administrative_state}" and "${ru_operationalState}"=="${expected_operational_state}"