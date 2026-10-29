*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to CM ADMIN API.
...    ******************
...    History of changes
...    ******************

Resource          hran_frame_taf_oam.robot
Library           XML    use_lxml=True
#Library           hran_ims

*** Variables ***
${MRBTS}          ${EMPTY}
${LNBTS}          ${EMPTY}
${ENB_ROOT_USER}    toor4nsn
${ENB_ROOT_PASS}    oZPS0POrRieRtu
${NOT_DEBIAN}     ${False}
# Cell status and RAT status in this list shall not be check.example:['WCDMA','GSM']
${IGNORE_RAT}     []
# The eight digit string represents the expected initial state and final state of NR, LTE, WCDMA and GSM respectively.
#It is initialized in 'Setup RAT Data' and used in 'Get RATs State Duration'
${EXPECTANT_RATS_STATE_API}    ${EMPTY}

*** Keywords ***
Create Random LNBTS TestData
    [Arguments]    ${source_json}    ${target_json}=tmp_data.json
    [Documentation]   Load test data from Json file for LNBTS and random select one group of test data into target json file
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | source_json | yes | Path for source json file |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | target_json | no | targe json file |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Example of simple usage:**
    ...   Create Random LNBTS TestData TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationFalse.json
    &{test_data}    Load Json File    ${source_json}
    ${static_param}    Get From Dictionary    ${test_data}    staticParam
    ${dynamic_param}    Get From Dictionary    ${test_data}    dynamicParam
    ${dynamic_param_list}    Convert To List    ${dynamic_param}
    ${count}    Get Length    ${dynamic_param_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${params}    Convert To List    ${dynamic_param_list[${index}]}
    Append To List    ${params}    ${static_param}
    ${file_str}    Convert To String    ${params}
    ${tmp_str}    Run Keyword If    "${LNBTS}"!="${EMPTY}" or "${MRBTS}"!="${EMPTY}"    Replace Variables    ${file_str}
    ${file_str}    Set Variable If    "${LNBTS}"!="${EMPTY}" or "${MRBTS}"!="${EMPTY}"    ${tmp_str}    ${file_str}
    Create File    ${target_json}    ${file_str.replace("'",'"')}

Execute FullCommission Due To Json File
    [Arguments]    ${scf_path}    ${step_data}    ${skip_rel_err}=${True}    ${should_activate}=${True}
    # If should_activate is ${False}, means download and validate only.
    [Documentation]    Load test data from Json file for LNBTS and random select one group of test data into target json file
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | scf_path | yes | Path for source scf file |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | step_data | yes | step data from json file |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | skip_rel_err | no | whether to skip relationship pdl error |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | should_activate | no | whether scf should be activate |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    **Example of simple usage:**
    ...    Execute FullCommission Due To Json File SCF_01_SBTS18.xml ${TEST_DATA["${key_in_json}"]} ${False} ${False}
    ${time}    Get Time    epoch
    Create XML From Old XML And Json    ${scf_path}    ${step_data}    data    ${OUTPUT_DIR}/${time}.xml
    ${bts_id}    Fetch From Right    ${MRBTS}    -
    ${ret}    ${rel_validate_str}    Run Keyword And Ignore Error    coam.Perform Commissioning    ${bts_id}
    ...    ${OUTPUT_DIR}/${time}.xml    ${skip_rel_err}
    ...    ${should_activate}
    ${skippedElements}    Convert To List    ${step_data["skippedElements"]}
    ${definitionErrors}    Convert To List    ${step_data["definitionErrors"]}
    ${missingObjectsErrors}    Convert To List    ${step_data["missingObjectsErrors"]}
    Run Keyword If    "${definitionErrors.__len__()}"=="${0}" and "${missingObjectsErrors.__len__()}"=="${0}"
    ...    Should Be True    "${ret}"=="PASS"
    Return From Keyword If    "${definitionErrors.__len__()}"=="${0}" and "${skippedElements.__len__()}"=="${0}"
    ${rel_validate_str}    Convert To String    ${rel_validate_str}
    &{rel_validate}    Evaluate    ${rel_validate_str}
    ${empty_list}    Create List
    ${skip_err_list}    Set Variable If
    ...    ${rel_validate['validationResult']['niddValidationResult']['logs']['skippedElements']} is None
    ...    ${empty_list}    ${rel_validate['validationResult']['niddValidationResult']['logs']['skippedElements']}
    ${definit_err_list}    Set Variable If
    ...    ${rel_validate['validationResult']['niddValidationResult']['logs']['definitionErrors']} is None
    ...    ${empty_list}    ${rel_validate['validationResult']['niddValidationResult']['logs']['definitionErrors']}
    ${missObj_err_list}    Set Variable If
    ...    ${rel_validate['validationResult']['niddValidationResult']['logs']['missingObjectsErrors']} is None
    ...    ${empty_list}    ${rel_validate['validationResult']['niddValidationResult']['logs']['missingObjectsErrors']}
    Should Be Equal As Integers    ${definit_err_list.__len__()}    ${definitionErrors.__len__()}
    Should Be Equal As Integers    ${skip_err_list.__len__()}    ${skippedElements.__len__()}
    FOR    ${err}    IN    @{skippedElements}
        ${ret}    SCF Configure Errors Should Contain    ${skip_err_list}    skippedElements    ${err["distName"]}
        ...    ${err["param"]}    ${err["error"]}
        ...    ${err["error_full_match"]}
        Should Be True    ${ret}    ${err["error"]} of ${err["param"]} on ${err["distName"]} does not raised
    END
    FOR    ${err}    IN    @{definitionErrors}
        ${ret}    SCF Configure Errors Should Contain    ${definit_err_list}    definitionErrors    ${err["distName"]}
        ...    ${err["param"]}    ${err["error"]}
        ...    ${err["error_full_match"]}
        Should Be True    ${ret}    ${err["error"]} of ${err["param"]} on ${err["distName"]} does not raised
    END


Execute Validation Due To Json File
    [Arguments]    ${scf_path}    ${step_data}    ${skip_rel_err}=${True}
    [Documentation]    Validate pdl rule according to json file defination
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | scf_path | yes | Path for source scf file |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | step_data | yes | step test data |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | skip_rel_err | no |skip relation error or not|
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Example of simple usage:**s
    ...    Execute Validation Due To Json File /home/ute/commissioning/SCF_01_SBTS18.xml step_data True
    ...    The step_data format:
    ...    "step1":{
    ...    "data":[],
    ...    "skippedElements":[],
    ...    "definitionErrors":[],
    ...    "missingObjectsErrors":[]
    ...    }
    ${new_xml_path}    Create XML From Old XML And Json    ${scf_path}    ${step_data}    data
    ${ret}    ${rel_validate_str}    Run Keyword And Ignore Error    validate_scf    ${new_xml_path}    ${skip_rel_err}
    ${skippedElements}    Convert To List    ${step_data["skippedElements"]}
    ${definitionErrors}    Convert To List    ${step_data["definitionErrors"]}
    ${missingObjectsErrors}    Convert To List    ${step_data["missingObjectsErrors"]}
    Run Keyword If    not ${definitionErrors.__len__()} and not ${missingObjectsErrors.__len__()}    Should Be True
    ...    "${ret}"=="PASS"
    Return From Keyword If    not ${definitionErrors.__len__()} and not ${missingObjectsErrors.__len__()}
    ${rel_validate_str}    Convert To String    ${rel_validate_str}
    ${rel_validate_str}    Fetch From Right    ${rel_validate_str}    Status reached:
    ${list_tmp}    Split String From Right    ${rel_validate_str}    }    1
    ${rel_validate_str}    Set Variable    ${list_tmp[0]}}
    &{rel_validate}    Evaluate    ${rel_validate_str}
    ${empty_list}    Create List
    ${skip_err_list}    Set Variable If    ${rel_validate["niddValidationResult"]["logs"]["skippedElements"]} is None
    ...    ${empty_list}    ${rel_validate["niddValidationResult"]["logs"]["skippedElements"]}
    ${definit_err_list}    Set Variable If    ${rel_validate["niddValidationResult"]["logs"]["definitionErrors"]} \ is None
    ...    ${empty_list}    ${rel_validate["niddValidationResult"]["logs"]["definitionErrors"]}
    ${missObj_err_list}    Set Variable If    ${rel_validate["niddValidationResult"]["logs"]["missingObjectsErrors"]} \ is None
    ...    ${empty_list}    ${rel_validate["niddValidationResult"]["logs"]["missingObjectsErrors"]}
    Should Be Equal As Integers    ${definit_err_list.__len__()}    ${definitionErrors.__len__()}
    Should Be Equal As Integers    ${skip_err_list.__len__()}    ${skippedElements.__len__()}
    FOR    ${err}    IN    @{skippedElements}
        ${ret}    SCF Configure Errors Should Contain    ${skip_err_list}    skippedElements    ${err["distName"]}
        ...    ${err["param"]}    ${err["error"]}
        ...    ${err["error_full_match"]}
        Should Be True    ${ret}    ${err["error"]} of ${err["param"]} on ${err["distName"]} does not raised
    END
    FOR    ${err}    IN    @{definitionErrors}
        ${ret}    SCF Configure Errors Should Contain    ${definit_err_list}    definitionErrors    ${err["distName"]}
        ...    ${err["param"]}    ${err["error"]}
        ...    ${err["error_full_match"]}
        Should Be True    ${ret}    ${err["error"]} of ${err["param"]} on ${err["distName"]} does not raised
    END

Execute DeltaCommission Due To Json File
    [Arguments]    ${step_data}    ${skip_rel_err}=${True}
    [Documentation]    Validate pdl rule for delta commission according to json file defination
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | step_data | yes | step test data |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | skip_rel_err | no |skip relation error or not|
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Example of simple usage:**
    ...    Execute Validation Due To Json File step_data True
    ...    The step_data format:
    ...    "step1":{
    ...    "data":[],
    ...    "skippedElements":[],
    ...    "definitionErrors":[],
    ...    "missingObjectsErrors":[]
    ...    }
    ${tmp_json_content}    Set Variable    ${step_data["data"]}
    ${tmp_json_content}    Convert To String    ${tmp_json_content}
    Create File    tmp_data.json    ${tmp_json_content.replace("'",'"')}
    ${ret}    ${rel_validate_str}    Run Keyword And Ignore Error    coam.perform_delta_recommissioning    tmp_data.json
    ...    ${skip_rel_err}
    ${empty_list}    Create List
    ${skippedElements}    Pop From Dictionary    ${step_data}    skippedElements    ${empty_list}
    ${definitionErrors}    Pop From Dictionary    ${step_data}    definitionErrors    ${empty_list}
    ${missingObjectsErrors}    Pop From Dictionary    ${step_data}    missingObjectsErrors    ${empty_list}
    ${relationErrors}    Pop From Dictionary    ${step_data}    relationErrors    ${empty_list}
    ${errText}    Pop From Dictionary    ${step_data}    errText    ${empty_list}
    ${err_count_expect}    Evaluate
    ...    ${definitionErrors.__len__()}+${missingObjectsErrors.__len__()}+${relationErrors.__len__()}+${errText.__len__()}
    Run Keyword If    '${err_count_expect}'=='${0}'    Should Be True    "${ret}"=="PASS"
    ${err_count_expect}    Evaluate
    ...    ${definitionErrors.__len__()}+${skippedElements.__len__()}+${relationErrors.__len__()}+${errText.__len__()}
    Return From Keyword If    '${err_count_expect}'=='${0}'
    ${rel_validate_str}    Convert To String    ${rel_validate_str}
    ${rel_validate_str}    Fetch From Right    ${rel_validate_str}    Status reached:
    ${list_tmp}    Split String From Right    ${rel_validate_str}    }    1
    ${rel_validate_str}    Set Variable    ${list_tmp[0]}}
    FOR    ${err}    IN    @{errText}
        Should Contain    ${list_tmp[0]}}    ${err}
    END
    #using errText means error of delta commission is not a dictionary string.
    Return From Keyword If    "${errText.__len__()}"!="${0}"
    &{rel_validate}    Evaluate    ${rel_validate_str}
    ${skip_err_list}    Set Variable If    ${rel_validate["niddValidationResult"]["logs"]["skippedElements"]} is None
    ...    ${empty_list}    ${rel_validate["niddValidationResult"]["logs"]["skippedElements"]}
    ${definit_err_list}    Set Variable If    ${rel_validate["niddValidationResult"]["logs"]["definitionErrors"]} is None
    ...    ${empty_list}    ${rel_validate["niddValidationResult"]["logs"]["definitionErrors"]}
    ${missObj_err_list}    Set Variable If    ${rel_validate["niddValidationResult"]["logs"]["missingObjectsErrors"]} is None
    ...    ${empty_list}    ${rel_validate["niddValidationResult"]["logs"]["missingObjectsErrors"]}
    ${relation_err_list}    Set Variable If    ${rel_validate["pdlValidationResult"]["logs"]["relationErrors"]} is None
    ...    ${empty_list}    ${rel_validate["pdlValidationResult"]["logs"]["relationErrors"]}
    Should Be Equal As Integers    ${definit_err_list.__len__()}    ${definitionErrors.__len__()}
    Should Be Equal As Integers    ${skip_err_list.__len__()}    ${skippedElements.__len__()}
    Should Be Equal As Integers    ${relation_err_list.__len__()}    ${relationErrors.__len__()}
    FOR    ${err}    IN    @{skippedElements}
        ${ret}    SCF Configure Errors Should Contain    ${skip_err_list}    skippedElements    ${err["distName"]}
        ...    ${err["param"]}    ${err["error"]}
        ...    ${err["error_full_match"]}
        Should Be True    ${ret}    ${err["error"]} of ${err["param"]} on ${err["distName"]} does not raised
    END
    FOR    ${err}    IN    @{definitionErrors}
        ${ret}    SCF Configure Errors Should Contain    ${definit_err_list}    definitionErrors    ${err["distName"]}
        ...    ${err["param"]}    ${err["error"]}
        ...    ${err["error_full_match"]}
        Should Be True    ${ret}    ${err["error"]} of ${err["param"]} on ${err["distName"]} does not raised
    END
    FOR    ${err}    IN    @{relationErrors}
        ${ret}    SCF Configure Errors Should Contain    ${relation_err_list}    relationErrors    ${err["distName"]}
        ...    ${err["feedback"]}    ${empty_list}
        ...    ${err["error_full_match"]}
        Should Be True    ${ret}    ${err["feedback"]} on ${err["distName"]} does not raised
    END

Load Json File
    [Arguments]    ${file_path}
    [Documentation]    Read test data from Json file and return the formatted content
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | file_path | yes | Path for source json file |
    ...
    ...    **Return Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | data | formatted data string |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Example of simple usage:**
    ...    Load Json File TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationFalse.json
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${data}    Evaluate    ${file_content}
    [Return]    ${data}

Get LNBTS Obj
    [Documentation]    Get the LNBTS object
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:** --
    Return From Keyword If    "${MRBTS}"!="" or "${LNBTS}"!=""
    ${lst}    coam.Get Ids For All    LNBTS
    ${lnbts_r}=    Fetch From Right    ${lst[0]}    /
    ${lnbts_id}=    Get Substring    ${lnbts_r}    8
    ${bts_id}    Admin Get BTS ID
    Set Global Variable    ${MRBTS}    MRBTS-${bts_id}
    Set Global Variable    ${LNBTS}    LNBTS-${lnbts_id}

Check AvailabilityStatus Seperately
    [Arguments]    ${mo_list}
    [Documentation]    deal with availabilityStatus change in CNI-61110
    ...
    ...    | **Author:** lixin.kangu@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    FOR    ${mo}    IN    @{mo_list}
        ${has_availStatus}    Run Keyword And Return Status    Dictionary Should Contain Key    ${mo}    availabilityStatus
        Run Keyword If    ${With_CNI61110}    Should Not Be True    ${has_availStatus}
        ...    ELSE    Should Be Equal As Strings    ${mo['availabilityStatus']}    Online
    END

Get States Values from object by Admin
    [Arguments]    ${states_list}    ${cell_object}
    [Documentation]    Admin get state value from object.
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:**
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+
    ...    | states_list | yes | The state under stateInfo like operationalState, availabilityStatus|
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | cell_object | yes | The id of LNCEL, WNCEL, GNCEL or NRCEL |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...
    ...    **Example of simple usage:**
    ...    @{states_values}= Get States Values from object by Admin operationalState
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-5397/LNCEL_R-1
    ${values_list}=    Create List
    FOR    ${state}    IN    @{states_list}
        ${obj_state}    Get From Dictionary    ${cell_object}    ${state}
        Append to list    ${values_list}    ${obj_state}
    END
    [Return]    @{values_list}

Create XML From Old XML And Json
    [Arguments]    ${src_xml}    ${case_data}    ${key}    ${new_xml_path}=${OUTPUT DIR}/tmpXML.xml
    [Documentation]    Create new xml file from an old one and json test data
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:**
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+
    ...    | src_xml | yes | The source xml path|
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | case_data | yes | The test data of step case |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | key | yes | The key in json file |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | new_xml_path | no | The path of the new xml file. Default value is tmpXML.xml |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    **Example of simple usage:**
    ...    ${new_xml_path} Create XML From Old XML And Json /home/ute/commissioning/SCF_01_SBTS18.xml step_data data
    ...    The step_data format:
    ...    "step1":{
    ...    "data":[],
    ...    "skippedElements":[],
    ...    "definitionErrors":[],
    ...    "missingObjectsErrors":[]
    ...    }
    ${xml}    Parse XML    ${src_xml}
    ${opers}    Convert To List    ${case_data["${key}"]}
    FOR    ${data}    IN    @{opers}
        ${oper}    Get From Dictionary    ${data}    operate
        Run Keyword If    '${data["operate"]}'=='SetAttribute'    XML.Set Elements Attribute
        ...    ${xml}    ${data["attribute"]}    ${data["value"]}    ${data["xpath"]}
        Run Keyword If    '${data["operate"]}'=='SetText'    XML.Set Elements Text
        ...    ${xml}    ${data["value"]}    ${None}    ${data["xpath"]}
        Run Keyword If    '${data["operate"]}'=='AddElement'    XML.Add Element
        ...    ${xml}    ${data["value"]}    ${None}    ${data["xpath"]}
        Run Keyword If    '${data["operate"]}'=='DelElement'    XML.Remove Elements
        ...    ${xml}    ${data["xpath"]}
    END
    FOR    ${data}    IN    @{opers}
        ${oper}    Get From Dictionary    ${data}    operate
        Continue For Loop If    '${data["operate"]}'!='SetMOVersion'
        ${version}    XML.Get Element Attribute    ${xml}    version    cmData/managedObject[@class="${data['value']}"][1]
        ${ret}    XML.Set Element Attribute    ${xml}    version    ${version}    ${data["xpath"]}
        Should Not Be Equal As Strings    ${ret}    ${None}
    END
    Save Xml    ${xml}    ${new_xml_path}
    [Return]    ${new_xml_path}

SCF Configure Errors Should Contain
    [Arguments]    ${delta_commission_errors}    ${err_type}    ${distName}    ${param}    ${error}    ${error_full_match}=${false}
    [Documentation]    Check if the delta_commission_errors contained one delta_commission_error with the same values of
    ...                'distName', 'param', 'error'
    ...
    ...    | **Author:** bin.7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin.7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+
    ...    | delta_commission_errors | yes | list of 'definitionErrors' or 'skippedElements' or 'relationErrors'|
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | err_type | yes | should be 'definitionErrors' or 'skippedElements' or 'relationErrors' |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | distName | yes | value of 'distName' |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | param | yes | value of 'field' or 'parameter' |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | error | yes | list of errors, e.g: ["key:NOT_EXIST","MRBTS-1813/EQM-1/APEQM-1/RMOD-100"]|
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | error_full_match | no | should the 'error' in the delta_commission_error need to be completely match ,
    ...    false for just need to be a sublist included |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | ${ret} | True if delta_commission_error is included in delta_commission_error_list. |
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    **Example of simple usage:**
    ...    Giving error_full_match as false and delta_commission_errors as one skippedElementsErrors as:
    ...
    ...    [
    ...    {
    ...    'distName': \ 'MRBTS-1813/EQM-1/APEQM-1/RMOD-100/RSL-1',
    ...    'error':
    ...    [
    ...    { 'key': \ 'MANAGED_OBJECT_WITH_DIST_NAME'},
    ...    \ ' MRBTS-1813/EQM-1/APEQM-1/RMOD-100 ',
    ...    { 'key': \ 'SHOULD_BE_PARENT'},
    ...    \ ' MRBTS-1813/EQM-1/APEQM-1/RMOD-100/RSL-1 ',
    ...    { 'key': \ 'NOT_EXIST'}
    ...    ],
    ...    'field': \ 'RSL'
    ...    }
    ...    ]
    ...
    ...    If anyone in delta_commission_errors has the same key-values of 'distName', 'field'('parameter'
    ...    if definitionErrors), and 'error' is the sublist of the one in delta_commission_errors, return TRUE,
    ...    otherwise return FALSE.
    ${err_expect}    Generate SCF Configure Error    ${err_type}    ${distName}    ${param}    ${error}
    ${ret}    SCF Configure Error Should Be Contained In    ${err_expect}    ${delta_commission_errors}
    ...    ${err_type}    ${error_full_match}
    [Return]    ${ret}

Generate SCF Configure Error
    [Arguments]    ${err_type}    ${distName}    ${param}    ${errors}
    [Documentation]    Generate skipped elements error.
    ...
    ...    | **Author:** bin.7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin.7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+
    ...    | err_type | yes |should be 'definitionErrors' or 'skippedElements' or 'relationErrors' |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | distName | yes | e.g:MRBTS-1813/EQM-1/APEQM-1/RMOD-100/RSL-1 |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | param | yes | field of 'skippedElements' \ or parameter of 'definitionErrors', e.g:RSL |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    | errors | yes | list of errors, e.g: ["key:NOT_EXIST","MRBTS-1813/EQM-1/APEQM-1/RMOD-100"] |
    ...    +-------------------+------+--------------------------------------------------------------------------+
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | ${delta_commission_error} | Returns: a dictionary likes. |
    ...    {
    ...    'distName': \ 'MRBTS-1813/EQM-1/APEQM-1/RMOD-100/RSL-1',
    ...    'error':
    ...    [
    ...    { 'key': \ 'MANAGED_OBJECT_WITH_DIST_NAME'},
    ...    \ ' MRBTS-1813/EQM-1/APEQM-1/RMOD-100 ',
    ...    { 'key': \ 'SHOULD_BE_PARENT'},
    ...    \ ' MRBTS-1813/EQM-1/APEQM-1/RMOD-100/RSL-1 ',
    ...    { 'key': \ 'NOT_EXIST'}
    ...    ],
    ...    'field': \ 'RSL'
    ...    }
    ...    or
    ...    {
    ...    'distName': 'MRBTS-1813/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1',
    ...    'parameter': 'l2IngressRate',
    ...    'error': [{'key': 'VALUE_IS_TOO_SMALL'}, ' 100.']
    ...    }
    ...    or
    ...    {
    ...    "distName":"${MRBTS}/${LNBTS}/LNCEL-${CELL_ID}",
    ...    "feedback":"Whenever LNCEL-${CELL_ID} having \$\{LNCEL-${CELL_ID}.administrativeState\} (value: unlocked)
    ...    equal to unlocked, it is required that \$\{LNCEL-${CELL_ID}.preventCellActivation\} (value: true) equal to false"
    ...    }
    ${err_list}    create list
    FOR    ${err}    IN    @{errors}
        ${tmp}    remove string    ${err}    key\:
        ${tmp}    Run keyword if    '${tmp}'!='${err}'    Create Dictionary    key=${tmp}
        ...    ELSE    set variable    ${tmp}
        Append to List    ${err_list}    ${tmp}
    END
    Sort List    ${err_list}
    ${para}    RUN keyword if    '${err_type}'=='definitionErrors'    set variable    parameter
    ...    ELSE IF    '${err_type}'=='skippedElements'    set variable    field
    ...    ELSE IF    '${err_type}'=='relationErrors'    set variable    feedback
    ...    ELSE    FAIL    err_type should be 'definitionErrors' or 'skippedElementsErrors' or 'relationErrors'
    ${delta_commission_error}    Create Dictionary    error=${err_list}    distName=${distName}    ${para}=${param}
    [Return]    ${delta_commission_error}

SCF Configure Error Should Be Contained In
    [Arguments]    ${delta_commission_error}    ${delta_commission_error_list}    ${err_type}    ${error_full_match}=${false}
    [Documentation]    Check if the delta_commission_error_list contained delta_commission_error.
    ...
    ...    | **Author:** bin.7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin.7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...    **Input Parameters:**
    ...    +-------------------+------+------------------------------------------------+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==================================================+
    ...    | delta_commission_error | yes |dictionary of 'definitionErrors' or 'skippedElements' |
    ...    +-------------------+------+--------------------------------------------------------+
    ...    | delta_commission_error_list | yes | list of 'definitionErrors' or 'skippedElements' |
    ...    +-------------------+------+---------------------------------------------------+
    ...    | err_type | yes | should be 'definitionErrors' or 'skippedElements' |
    ...    +-------------------+------+------------------------------------------------------------------+
    ...    | error_full_match | yes | should the 'error' in the delta_commission_error need to be completely match ,
    ...    false for just need to be a sublist included|
    ...    +-------------------+------+-------------------------------------------------------------------------------+
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | ${ret} | True if delta_commission_error is included in delta_commission_error_list. |
    ...    Example:
    ...    Giving error_full_match as false and delta_commission_error as one skippedElements as:
    ...
    ...    {
    ...    'distName': \ 'MRBTS-1813/EQM-1/APEQM-1/RMOD-100/RSL-1',
    ...    'error':
    ...    [
    ...    { 'key': \ 'MANAGED_OBJECT_WITH_DIST_NAME'},
    ...    \ ' MRBTS-1813/EQM-1/APEQM-1/RMOD-100 ',
    ...    { 'key': \ 'SHOULD_BE_PARENT'},
    ...    \ ' MRBTS-1813/EQM-1/APEQM-1/RMOD-100/RSL-1 ',
    ...    { 'key': \ 'NOT_EXIST'}
    ...    ],
    ...    'field': \ 'RSL'
    ...    }
    ...
    ...    If anyone in delta_commission_error_list \ has the same key-values of 'distName', 'field'('parameter' if definitionErrors),
    ...    and 'error' in delta_commission_error is sublist of the one in delta_commission_error_list, return TRUE, otherwise return FALSE.
    #Run Keyword Unless    '${err_type}'=='definitionErrors' or '${err_type}'=='skippedElements' or '${err_type}'=='relationErrors'
    Run Keyword If    '${err_type}'!='definitionErrors' and '${err_type}'!='skippedElements' and '${err_type}'!='relationErrors'
    ...    FAIL    err_type should be 'definitionErrors' or 'skippedElements' or 'relationErrors'
    ${err_check}    set variable    ${EMPTY}
    FOR    ${tmpErr}    IN    @{delta_commission_error_list}
        ${err_check}    run keyword if    '${err_type}'=='definitionErrors'    set variable if
        ...   '${tmpErr['distName']}'=='${delta_commission_error['distName']}' and '${tmpErr['parameter']}'=='${delta_commission_error['parameter']}'
        ...    ${tmpErr}    ${None}
        ...    ELSE IF    '${err_type}'=='skippedElements'    set variable if
        ...   '${tmpErr['distName']}'=='${delta_commission_error['distName']}' and '${tmpErr['field']}'=='${delta_commission_error['field']}'
        ...    ${tmpErr}    ${None}
        ...    ELSE IF    '${err_type}'=='relationErrors'    set variable if
        ...    '${err_type}'=='relationErrors' and '${tmpErr['feedback']}'=='${delta_commission_error['feedback']}'    ${tmpErr}    ${None}
        ...    ELSE    set variable    ${None}
        #Run keyword unless    ${err_check} is None    Exit For Loop
        Run keyword If    ${err_check} is not None    Exit For Loop
    END
    Return From Keyword If    ${err_check} is None    ${False}
    Return From Keyword If    '${err_type}'=='relationErrors'    ${True}
    ${ret_1}    Run Keyword And Return Status    List Should Contain Sub List    ${err_check['error']}    ${delta_commission_error['error']}
    ${ret_2}    Run Keyword And Return Status    List Should Contain Sub List    ${delta_commission_error['error']}    ${err_check['error']}
    ${ret}    evaluate    ${ret_1} and ${ret_2}
    return from keyword if    ${error_full_match}    ${ret}
    ${ret}    evaluate    ${ret_1} or ${ret_2}
    [Return]    ${ret}

Compare Alarm List
    [Arguments]    ${alarms_before}    ${alarms_after}    ${alarm_filter}=${None}
    [Documentation]    Compare alarms list before and after other opeartion
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | alarms_before | yes | the faults list before operation |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | alarms_after | yes | the faults list after operation |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | alarm_filter | no | the faults want to be ingored |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | ${alarms_cleared} | Return filterd faults list for cleard alarms |
    ...    | ${alarms_raised} | Return filterd faults list for raised alarms |
    ${alarms_cleared}    Create List
    ${alarms_raised}    Create List
    FOR    ${alarm}    IN    @{alarms_before}
        ${value}    Pop From Dictionary    ${alarm}    observationTime    ${EMPTY}
        FOR    ${object}    IN    @{alarm["alarmingObjectIds"]}
             ${value}    Pop From Dictionary    ${object}    internal    ${EMPTY}
        END
    END
    FOR    ${alarm}    IN    @{alarms_after}
        ${value}    Pop From Dictionary    ${alarm}    observationTime    ${EMPTY}
        FOR    ${object}    IN    @{alarm["alarmingObjectIds"]}
             ${value}    Pop From Dictionary    ${object}    internal    ${EMPTY}
        END
    END
    FOR    ${alarm}    IN    @{alarms_before}
        ${is_cleared}    Run Keyword And Return Status    List Should Not Contain Value    ${alarms_after}    ${alarm}
        Run Keyword If    ${is_cleared}    Append To List    ${alarms_cleared}    ${alarm}
    END
    FOR    ${alarm}    IN    @{alarms_after}
        ${is_raised}    Run Keyword And Return Status    List Should Not Contain Value    ${alarms_before}    ${alarm}
        Run Keyword If    ${is_raised}    Append To List    ${alarms_raised}    ${alarm}
    END
    Return From Keyword If    ${alarm_filter}==${None}    ${alarms_cleared}    ${alarms_raised}
    FOR    ${a_filter}    IN    @{alarm_filter}
        ${alarms_cleared}    Remove Alarm From Alarm List    ${alarms_cleared}    ${a_filter}
        ${alarms_raised}    Remove Alarm From Alarm List    ${alarms_raised}    ${a_filter}
    END
    [Return]    ${alarms_cleared}    ${alarms_raised}

Remove Alarm From Alarm List
    [Arguments]    ${alarm_list}    ${dic_filter}
    [Documentation]    Filt Alarm From Alarm List
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | alarm_list | yes | fault list |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | key | yes | specific fault identifier |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | val | yes | specific fault |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | ${alarm_list} | Return filterd faults list |
    FOR    ${alarm}    IN    @{alarm_list}
        ${is_contain}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${alarm}    ${dic_filter}
        Run Keyword If    ${is_contain}    Remove Values From List    ${alarm_list}    ${alarm}
    END
    [Return]    ${alarm_list}

Get RMODs Active Cell List
    [Documentation]    Get current active cells list of all RMOD.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | dic_RMOD_active_cell | dictionary with keys of RMOD Name |
    ...
    ...    **EXAMPLE**
    ...    | ${dic_RMOD_active_cell} | Get RMODs Active Cell List |
    ...    ${dic_RMOD_active_cell}={
    ...    MRBTS-1815/EQM-1/APEQM-1/RMOD-1: {u'activeLteCellsList': [1, 2, 3], u'activeGsmCellsList': [],
    ...    u'activeNrCellsList': [], u'activeWcdmaCellsList': [1, 2, 3]}
    ...    MRBTS-1815/EQM-1/APEQM-1/RMOD-3: {u'activeLteCellsList': [], u'activeGsmCellsList': [],
    ...    u'activeNrCellsList': [1, 2, 3], u'activeWcdmaCellsList': []}
    ...    }
    ${dic_RMOD_active_cell}    Create Dictionary
    ${RMOD_R_list}    ute_admin_infomodel.query_infomodel    get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR    ${MO}    IN    @{RMOD_R_list}
        ${DN}    Set Variable    ${MO['dist_name']}
        ${RMOD_DN}    Infomodel Get Objects Parameter    ${DN}    configDN
        ${count}    Get Length    ${RMOD_DN}
        Should Be True    ${count}==${1}
        ${tmp_dic}    Create Dictionary    activeLteCellsList=${MO['activeLteCellsList']}
        ...    activeGsmCellsList=${MO['activeGsmCellsList']}    activeNrCellsList=${MO['activeNrCellsList']}
        ...    activeWcdmaCellsList=${MO['activeWcdmaCellsList']}
        ${tmp_str_list}    Split String    ${RMOD_DN[0]}    MRBTS_A-
        ${MO_name}    Set Variable    MRBTS-${tmp_str_list[1].replace("_A","")}
        Set To Dictionary    ${dic_RMOD_active_cell}    ${MO_name}    ${tmp_dic}
    END
    [Return]    ${dic_RMOD_active_cell}

Get Sole MO DN
    [Arguments]    ${query_str}    ${param_name}    ${param_value}=${EMPTY}    ${MO_DNs_to_return}=${None}
    [Documentation]    Query MOs according to ${query STR} and classify MOs according to the value of the parameter ${param name}.
    ...    Each category randomly selects one MO to obtain its DN to form a list, and returns the list.
    ...    When the value of ${param value} is specified, only the DN of MO with the value of ${param value}
    ...    of parameter ${param name} is returned randomly.
    ...    Parameter ${Mo_ DNs_ to_ Return} is a reserved parameter of KW, which cannot be passed in by the caller.
    ...
    ...    When ${param name} is a child of dictionary, the parent and child are separated by dots. For example:
    ...    stateInfo.administrativeState
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | query_str | Yes | Parameter used when calling KW ute_admin_infomodel.query_infomodel |
    ...    | param_name | Yes | |
    ...    | param_value | No | |
    ...    | MO_DNs_to_return | No | DO NOT set value to this parameter |
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | MO_DNs_to_return | List of DN of MO |
    ...
    ...    **EXAMPLE**
    ...    | ${BBMOD_R_MOs} | Get Sole MO DN | //EQM_R-*//BBMOD_R-* | productName | ABIA AirScale Capacity |
    ...    | ${unlocked_LTE_cell} | Get Sole MO DN | //LNCEL_R-* | stateInfo.administrativeState | Unlocked |
    ...    | ${BBMOD_R_MOs_to_reset} | Get Sole MO DN | //EQM_R-*//BBMOD_R-* | productName |
    ...
    ...    ${BBMOD_R_MOs} = ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-3']
    ...
    ...    ${unlocked_LTE_cell} = ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-3542/LNCEL_R-3']
    ...
    ...    ${BBMOD_R_MOs_to_reset} = ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1',
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-2']
    ${is_first_loop}    Run Keyword And Return Status    Should Be True    ${MO_DNs_to_return} is None
    ${empty_list}    Create List
    ${MO_DNs_to_return}    Set Variable If    ${is_first_loop}    ${empty_list}    ${MO_DNs_to_return}
    ${MOs}    Run Keyword If    ${is_first_loop}    ute_admin_infomodel.query_infomodel    get list ${query_str}
    #Query all MOS to be processed, only when entering kW for the first time
    ${MO_Object_List}    Set Variable If    ${is_first_loop}    ${MOs}    ${MO_Object_List}
    Run Keyword If    ${is_first_loop}    Set Suite Variable    ${MO_Object_List}
    ${count}    Get Length    ${MO_Object_List}
    Return From Keyword If    ${count}==${0}    ${MO_DNs_to_return}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${p_list}    Split String    ${param_name}    .
    ${value}    Set Variable If    len(${p_list})==2    ${MO_Object_List[${index}]["${p_list[0]}"]["${p_list[1]}"]}
    ...    ${MO_Object_List[${index}]["${p_list[0]}"]}
    #First, if the parameter value is consistent with the specified value, or if the parameter value is not specified,
    #randomly select one.
    ${bool_1}    Run Keyword And Return Status    Should Be Equal As Strings    ${value}    ${param_value}
    ${bool_2}    Run Keyword And Return Status    Should Be Equal As Strings    ${EMPTY}    ${param_value}
    Run Keyword If    ${bool_1} or ${bool_2}    Append To List    ${MO_DNs_to_return}    ${MO_Object_List[${index}]["dist_name"]}
    #Second, remove the MOs with the same value of other a in the total MOs as the MO randomly selected.
    FOR    ${MO}    IN    @{MO_Object_List}
        ${mo_val}    Set Variable If    len(${p_list})==2    ${MO["${p_list[0]}"]["${p_list[1]}"]}    ${MO["${p_list[0]}"]}
        ${bool}    Run Keyword And Return Status    Should Be Equal As Strings    ${value}    ${mo_val}
        Run Keyword If    ${bool}    Remove Values From List    ${MO_Object_List}    ${MO}
    END
    Get Sole MO DN    ${query_str}    ${param_name}    ${param_value}    ${MO_DNs_to_return}
    [Return]    ${MO_DNs_to_return}

Get MO Name Of MO_R
    [Arguments]    ${MO_R_DN}
    [Documentation]    Get MO name of the giving MO_R.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | MO_R_DN | Yes | accurate DN of RMOD_R |
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | Parameter | Description |
    ...    | MO_name | Name of RMOD |
    ...
    ...    **EXAMPLE**
    ...    | ${name} | Get RMOD Name Of RMOD_R | /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-3 |
    ...    ${name} = MRBTS-1810/EQM-1/APEQM-1/RMOD-7
    ${rel_MO_1}    Infomodel Get Objects Parameter    ${MO_R_DN}    configDN    ${True}
    ${rel_MO_2}    Infomodel Get Objects Parameter    ${MO_R_DN}/CONF_REF-1    distName    ${True}
    ${rel_MO}    Combine Lists    ${rel_MO_1}    ${rel_MO_2}
    Should Be True    len(${rel_MO}) != 0
    ${tmp_str_list}    Split String    ${rel_MO[0]}    MRBTS_A-
    ${MO_name}    Set Variable    MRBTS-${tmp_str_list[1].replace("_A","")}
    [Return]    ${MO_name}

Set administrativeState Of MO_R
    [Arguments]    ${MO_R}    ${value}
    [Documentation]    Set administrativeState status Of MO_R
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | MO_R | Yes | accurate DN of BBMOD_R |
    ...    | value | Yes | expected status |
    ${MO_DN}    Get MO Name Of MO_R    ${MO_R}
    LOG    Set administrativeState Of ${MO_DN} to ${value}    console=${True}
    coam.Perform parameter recommissioning    ${MO_DN}    administrativeState    update    ${value}    ${False}
    Wait Until Keyword Succeeds    1 minutes    5 secs    Query Infomodel    check ${MO_R} is [administrativeState="${value}"]

Get BBMOD_R Related Cells
    [Arguments]    ${BBMOD_R_MO}
    [Documentation]    Get 2G/3G/4G cells related to BBMOD_R.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | BBMOD_R_MO | MO DN |
    ...
    ...    **EXAMPLE**
    ...    |${cell_dic} | Get BBMOD_R Related Cells | /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-2/BBMOD_R-1|
    ...    ${cell_dic}={u'LTE': [], u'WCDMA': [1, 2, 3], u'GSM': []}
    ${empty_list}    Create List
    ${cell_dic}    Create Dictionary    LTE=${empty_list}    WCDMA=${empty_list}    GSM=${empty_list}    5G=${empty_list}
    ${has_bbpool_r}    ute_admin_infomodel.query_infomodel
    ...  check //RUNTIME_VIEW-*//BBPOOL_R-* is [bbPwrGroupDNList[?]=regex"${BBMOD_R_MO}/POWERGROUP_R-\\d+"]    timeout=30
    ...    allow_negative_result=${True}
    Return From Keyword If    not ${has_bbpool_r}    ${cell_dic}
    ${MO_BBPOOL}    ute_admin_infomodel.query_infomodel
    ...    get list //RUNTIME_VIEW-*//BBPOOL_R-* is [bbPwrGroupDNList[?]=regex"${BBMOD_R_MO}/POWERGROUP_R-\\d+"]    timeout=30
    FOR    ${MO}    IN    @{MO_BBPOOL}
        ${tmp_list}    Combine Lists    ${cell_dic['${MO["bbPoolTech"]}']}    ${MO["bbPoolCellsList"]}
        ${tmp_list}    Remove Duplicates    ${tmp_list}
        Set To Dictionary    ${cell_dic}    ${MO["bbPoolTech"]}    ${tmp_list}
    END
    [Return]    ${cell_dic}

Get DN Of RMOD_R Related To BBMOD_R
    [Arguments]    ${MO_BBMOD_R}
    [Documentation]    Get DN of RMOD_Rs which are connected or not to MO_BBMOD_R.
    ...    Return a dictionary contanis two items, item with key 'IRRESPECTIVE_RMOD_R_DN',
    ...    value is list of RMOD_R DNs those not connected to MO_BBMOD_R, item with key 'RELATE_RMOD_R_DN',
    ...    value is list of RMOD_R DNs those connected to MO_BBMOD_R.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | MO_BBMOD_R | Yes | accurate DN of BBMOD_R |
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | relative_mos | Dictionary of list |
    ...
    ...    **EXAMPLE**
    ...    | ${MO_DNs} | Get DN Of RMOD_R Related To BBMOD_R | /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1
    ...    /CABINET_R-1/BBMOD_R-1 |
    ...    ${MO_DNs} = {'IRRESPECTIVE_RMOD_R_DN': ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1'],
    ...    'RELATE_RMOD_R_DN': ['/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-3']}
    ${relative_mos}    Create Dictionary
    ${RMOD_MO}    Create List
    ${IRRESPECTIVE_RMOD_DN}    Infomodel Get Objects Parameter    //EQM_R-*//RMOD_R-*    dist_name    ${True}
    Set To Dictionary    ${relative_mos}    IRRESPECTIVE_RMOD_R_DN    ${IRRESPECTIVE_RMOD_DN}
    Set To Dictionary    ${relative_mos}    RELATE_RMOD_R_DN    ${RMOD_MO}
    ${count}    ute_admin_infomodel.query_infomodel    get count //EQM_R-*//CABLINK_R-* is [firstEndpointDN="${MO_BBMOD_R}"]
    Return From Keyword If    ${count}==${0}    ${relative_mos}
    ${links}    ute_admin_infomodel.query_infomodel    get list //EQM_R-*//CABLINK_R-* is [firstEndpointDN="${MO_BBMOD_R}"]
    FOR    ${link}    IN    @{links}
        Run Keyword If    "${link['secondEndpointDN'].split('/')[-1].split('-')[0]}"=="RMOD_R"    Append To List
        ...    ${relative_mos['RELATE_RMOD_R_DN']}    ${link['secondEndpointDN']}
    END
    ${relative_mos['RELATE_RMOD_R_DN']}    Remove Duplicates    ${relative_mos['RELATE_RMOD_R_DN']}
    Remove Values From List    ${relative_mos['IRRESPECTIVE_RMOD_R_DN']}    @{RMOD_MO}
    [Return]    ${relative_mos}

Get RMOD_R Related NRCells Via Infomodel
    [Arguments]    ${RMOD_R_DN}
    [Documentation]    Get 5G cells related to RMOD_R.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | MO_R_DN | Yes | accurate DN of RMOD_R |
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | activeNrCellsList | cell list |
    ...
    ...    **EXAMPLE**
    ...    | ${activeNrCellsList} | Get RMOD_R Related NRCells | /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-3 |
    ...    ${activeNrCellsList}=[2, 3, 1]
    ${activeNrCellsList}    Create List
    ${rel_MO}    Infomodel Get Objects Parameter    ${RMOD_R_DN}    configDN    ${True}
    Should Be True    len(${rel_MO}) == 1
    ${RMOD_name}    Set Variable    ${rel_MO[0]}
    ${has_related_nrcell}    ute_admin_infomodel.query_infomodel
    ...    check //BTS_CONF-*//NRCELL_A-* is [rModDNList[?]="${RMOD_name}"]    timeout=30    allow_negative_result=${True}
    Return From Keyword If    not ${has_related_nrcell}    ${activeNrCellsList}
    ${nrcell_A_related_to_RMOD_list}    ute_admin_infomodel.query_infomodel
    ...    get list //BTS_CONF-*//NRCELL_A-* is [rModDNList[?]="${RMOD_name}"]
    FOR    ${cell_mo}    IN    @{nrcell_A_related_to_RMOD_list}
        ${int_id}    Convert To Integer    ${cell_mo['lcrId']}
        Append To List    ${activeNrCellsList}    ${int_id}
    END

Get RMOD_R Related NRCells
    [Arguments]    ${RMOD_R_DN}
    [Documentation]    Get 5G cells related to RMOD_R.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | MO_R_DN | Yes | accurate DN of RMOD_R |
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | activeNrCellsList | cell list |
    ...
    ...    **EXAMPLE**
    ...    | ${activeNrCellsList} | Get RMOD_R Related NRCells | /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/
    ...    APEQM_R-1/RMOD_R-3 |
    ...    ${activeNrCellsList}=[2, 3, 1]
    ${activeNrCellsList}    Create List
    ${bts_info}    coam.get_bts_info
    ${list_rmod_infor}    Set Variable    ${bts_info["radioModules"]["rmod"]}
    ${carrierList}    Create List
    FOR    ${rmod_infor}    IN    @{list_rmod_infor}
        Continue For Loop If    '${RMOD_R_DN}'!='${rmod_infor["id"]["internal"]}'
        Append To List    ${carrierList}    @{rmod_infor["carrierList"]}
    END
    FOR    ${carrier}    IN    @{carrierList}
        ${ret}    ${cell_id}    Run Keyword And Ignore Error    Should Match Regexp    ${carrier["id"]["configuration"]}
        ...    NRCELL-\\d+
        Continue For Loop If    "${ret}"=="FAIL"
        Append To List    ${activeNrCellsList}    ${cell_id.split('-')[-1]}
    END
    ${activeNrCellsList}    Remove Duplicates    ${activeNrCellsList}
    Log List    ${activeNrCellsList}
    [Return]    ${activeNrCellsList}

Print KPI
    [Arguments]    ${json_file_path}    ${kpi_file_name}=${TEST_NAME}.txt    ${should_cell_list}=${True}
    ...    ${cell_list}=${EMPTY}    ${print_head}=${False}
    Return From Keyword If    '${NOT_DEBIAN}'=='${True}'
    LOG    Printing KPI....    console=${True}
    ${time}    BuiltIn.Get Time    time_=UTC + 8 hour
    ${delta_data}    Load Json File    ${json_file_path}
    ${event_definition}    Load Json File    TestDataSet/KPI_CONF/KPI_EVENT_DEFINITION.json
    ${ims_file}    Set Variable If    "${delta_data["ims_file"]}"==""    ${BTS Files}/IM/InfoModel_log
    ...    ${BTS Files}/IM/${delta_data["ims_file"]}
    ${tmp_cell_list}    Run Keyword If    ${should_cell_list}    Get All Cell IDs
    ${cell_list}    Set Variable If    ${should_cell_list}    ${tmp_cell_list}    ${cell_list}
    hran_ims.setup_ims_file    ${ims_file}.ims2
    hran_ims.register_cells_list    ${cell_list}
    ${event_delta}    Get Dictionary Keys    ${delta_data["event"]}
    FOR    ${delta}    IN    @{event_delta}
        hran_ims.add_event    ${delta}    ${event_definition["${delta_data["event"]["${delta}"]}"]}
    END
    ${cell_delta}    Get Dictionary Keys    ${delta_data["cell_action"]}
    FOR    ${delta}    IN    @{cell_delta}
        hran_ims.add_cell    ${delta}    ${delta_data["cell_action"]["${delta}"]["cell_up"]}
        ...    ${delta_data["cell_action"]["${delta}"]["cell_down"]}    ${delta_data["cell_action"]["${delta}"]["first_cell"]}
        ...    ${delta_data["cell_action"]["${delta}"]["last_cell"]}
    END
    ${kpi_delta}    Get Dictionary Keys    ${delta_data["kpi_delta"]}
    FOR    ${delta}    IN    @{kpi_delta}
        hran_ims.create_delta    ${delta}    ${delta_data["kpi_delta"]["${delta}"][0]}    ${delta_data["kpi_delta"]["${delta}"][1]}
    END
    ${kpi_data}    ${regist_time_msg}    ${row_data}    hran_ims.get_kpi_delta
    ${kpi_head}    Set Variable
    ...  ---\n TESTLINE_NAME|CUR_VERSION|CASE_NAME|EXECUTE_TIME\n ${TESTLINE_NAME}|${active SW version}|${TEST_NAME}|${time}\n +++\n
    Run Keyword If    ${print_head}    Append To File    KPI_DATA/${kpi_file_name}    ${kpi_head}\n
    Append To File    KPI_DATA/${kpi_file_name}    ${kpi_data}\n
    Append To File    KPI_DATA/${kpi_file_name}    ${regist_time_msg}
    LOG    KPI printed: KPI_DATA/${kpi_file_name}    console=${True}
    LOG    ${row_data}
    ${row_lines}    Split To Lines    ${row_data}
    FOR    ${row}    IN    @{row_lines}
        ${cols}    Split String    ${row}    |
        ${xsl_row_data}    Create List    ${TESTLINE_NAME}    ${active SW version}    ${TEST_NAME}    ${time}
        ...    @{cols[1:-1]}
        LOG    ${xsl_row_data}
        hran_ims.append_row_to_xls    KPI_DATA/SBTS_CM_KPI.xlsx    SBTS_CM_KPI    ${xsl_row_data}
        ${xsl_row_smart_data}    Create List    ${HW_CONFIG}    ${active SW version}    ${cols[1]}    ${cols[4]}
        hran_ims.append_row_to_xls    KPI_DATA/SBTS_CM_KPI_SMART.xlsx    SBTS_CM_KPI_SMART    ${xsl_row_smart_data}
    END
    [Teardown]    Run Keyword If    '${NOT_DEBIAN}'=='${False}'    hran_ims.clear_delta

Commond_Setup_For_ImsLog_Collection
    Return From Keyword If    '${NOT_DEBIAN}'=='${True}'
    Common Test Setup SBTS    syslog_launch=${TRUE}    btssm_launch=${FALSE}    modules_check=${TRUE}
    ...    cells_check=${FALSE}    alarms_check=${FALSE}    scf_check=${FALSE}

Save IMS and Restart IMS model
    [Arguments]    ${ims_file_name}=InfoModel_log
    Return From Keyword If    '${NOT_DEBIAN}'=='${True}'
    LOG    saving ims2 log:\n${BTS Files}/IM/${ims_file_name}.ims2    console=${True}
    ${ims_file_name}    Set Variable If    "${ims_file_name}"==""    InfoModel_log    ${ims_file_name}
    Save Infomodel Log    filename=${BTS Files}/IM/${ims_file_name}.ims2    timeout=300
    Teardown Infomodel
    Wait Until Keyword Succeeds    60s    10s    OperatingSystem .File Should Exist    ${BTS Files}/IM/${ims_file_name}.ims2
    LOG    ${BTS Files}/IM/${ims_file_name}.ims2 saved.    console=${True}
    Start Infomodel

Get All Cell IDs
    ${lcl}    coam.get_ids_for_all    LNCEL
    ${gcl}    coam.get_ids_for_all    GNCEL
    ${wcl}    coam.get_ids_for_all    WNCEL
    ${all_cell_list}    Combine Lists    ${lcl}    ${gcl}    ${wcl}
    [Return]    ${all_cell_list}

Get Random Cell Obj
    [Arguments]    ${cell_type}
    ${id_list}    coam.Get Ids For All    ${cell_type}
    ${cell_mo}    Evaluate    random.choice(${id_list})    random
    Set Global Variable    ${CELL_MO}    ${cell_mo}
    ${id}    Fetch From Right    ${CELL_MO}    -
    Set Global Variable    ${CELL_ID}    ${id}

Execute Shell Command Background
    [Arguments]    ${cmd}    ${alias_name}    ${cwd}=${EMPTY}
    Comment    Start Process    ${cmd}    alias=${alias_name}    shell=${True}
    Run Keyword If    "${cwd}"==""    Start Process    ${cmd}    alias=${alias_name}    shell=${True}
    Run Keyword If    "${cwd}"!=""    Start Process    ${cmd}    alias=${alias_name}    shell=${True}    cwd=${cwd}

Wait Backgroud Process Finish And Get Output
    [Arguments]    ${alias_name}    ${time_out}
    ${result}    Wait For Process    ${alias_name}    ${time_out}    kill
    ${std_output}    Set Variable    ${result.stdout}
    [Return]    ${result}    ${std_output}

Compare_SCF_XML
    [Arguments]    ${scf_file_1}    ${scf_file_2}
    [Documentation]    Compare all MOs and parameters of MOs between two SCF files.
    ...    For MO comparation, only check the attribute 'distName'.
    ...    Return a dictionary containing the difference between two SCF files like:
    ...    {
    ...    xpath:[element of first SCF, element of second SCF]
    ...    }
    ...    If MO is not exist on one SCF file, the element will be None.
    ${xml_1}    Parse XML    ${scf_file_1}
    ${xml_2}    Parse XML    ${scf_file_2}
    ${dic_diff}    Create Dictionary
    ${list_MO_elements_1}    XML.Get Elements    ${xml_1}    cmData/managedObject
    ${list_MO_elements_2}    XML.Get Elements    ${xml_2}    cmData/managedObject
    #Find MOs in ${scf_file_1} only
    FOR    ${element}    IN    @{list_MO_elements_1}
        ${distName}    XML.Get Element Attribute    ${element}    distName
        ${list_element}    XML.Get Elements    ${xml_2}    cmData/managedObject[@distName="${distName}"]
        ${count}    Get Length    ${list_element}
        Continue For Loop If    "${count}"=="${1}"
        Record_SCF_Diff    ${dic_diff}    cmData/managedObject[@distName="${distName}"]    ${element}    ${EMPTY}
        Remove Values From List    ${list_MO_elements_1}    ${element}
        LOG    Removed cmData/managedObject[@distName="${distName}"]
    END
    #Find MOs in ${scf_file_2} only
    FOR    ${element}    IN    @{list_MO_elements_2}
        ${distName}    XML.Get Element Attribute    ${element}    distName
        ${list_element}    XML.Get Elements    ${xml_1}    cmData/managedObject[@distName="${distName}"]
        ${count}    Get Length    ${list_element}
        Continue For Loop If    "${count}"=="${1}"
        Record_SCF_Diff    ${dic_diff}    cmData/managedObject[@distName="${distName}"]    ${EMPTY}    ${element}
        XML.Remove Element    ${xml_2}    cmData/managedObject[@distName="${distName}"]
        LOG    Removed cmData/managedObject[@distName="${distName}"]
    END
    #Find MOs difference between ${scf_file_1} and ${scf_file_2}
    FOR    ${element1}    IN    @{list_MO_elements_1}
        ${distName}    XML.Get Element Attribute    ${element1}    distName
        ${element2}    XML.Get Element    ${xml_2}    cmData/managedObject[@distName="${distName}"]
        ${list_child_element_1}    XML.Get Child Elements    ${element1}
        ${list_child_element_2}    XML.Get Child Elements    ${element2}
        ${count_1}    Get Length    ${list_child_element_1}
        ${count_2}    Get Length    ${list_child_element_2}
        Run Keyword If    "${count_1}"!="${count_2}"    Record_SCF_Diff    ${dic_diff}
        ...    cmData/managedObject[@distName="${distName}"]    ${element1}
        ...    ${element2}
        Continue For Loop If    "${count_1}"=="${0}" or "${count_1}"!="${count_2}"
        SCF_XML_Should_Contain_MO_Element    ${dic_diff}    ${xml_2}    ${element1}
    END
    [Return]    ${dic_diff}

SCF_XML_Should_Contain_MO_Element
    [Arguments]    ${dic_diff}    ${SCF_XML}    ${MO_element}
    ${distName}    XML.Get Element Attribute    ${MO_element}    distName
    ${list_child_element}    XML.Get Child Elements    ${MO_element}
    FOR    ${child_element}    IN    @{list_child_element}
        ${param_name}    XML.Get Element Attribute    ${child_element}    name
        ${param_element}    XML.Get Element    ${SCF_XML}    cmData/managedObject[@distName="${distName}"]/*[@name="${param_name}"]
        ${is_equal}    Run Keyword And Return Status    Elements Should Be Equal    ${param_element}    ${child_element}
        Continue For Loop If    ${is_equal}
        Record_SCF_Diff    ${dic_diff}    cmData/managedObject[@distName="${distName}"]/*[@name="${param_name}"]
        ...    ${child_element}    ${param_element}
    END

Record_SCF_Diff
    [Arguments]    ${dic_diff}    ${xpath}    ${element_left}    ${element_right}
    ${str1}    Run Keyword If    "${element_left}" != "${EMPTY}"    Element To String    ${element_left}
    ${str2}    Run Keyword If    "${element_right}" != "${EMPTY}"    Element To String    ${element_right}
    ${list_diff}    Create List    ${str1}    ${str2}
    Set To Dictionary    ${dic_diff}    ${xpath}    ${list_diff}

Wait Until All Cells Onair_BKInfomodel
    [Arguments]    ${retry}=${18}    ${interval}=10s
    ${are_cells_online}    Set Variable    ${False}
    FOR    ${counter}    IN RANGE    ${0}    ${retry}
        ${are_cells_online}    ${cells_statuses}    Infomodel Check If All Objects From Path Are Online
        ...    /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*    10 sec    ${True}
        ...    administrativeState=Unlocked    blockingState=Unblocked    operationalState=Enabled
        ...    proceduralState=OnAirDone    availabilityStatus=Online
        Exit For Loop If    ${are_cells_online}
        Sleep    ${interval}
    END
    Should Be True    ${are_cells_online}

Wait Until All Cells Onair
    [Arguments]    ${retry}=${18}    ${interval}=10s
    ${are_cells_online}    Set Variable    ${False}
    FOR    ${counter}    IN RANGE    ${0}    ${retry}
        ${are_gcells_online}    Check If All Objects Are Online    GNCEL    10 sec
        ...    administrativeState=${_Com_Unlocked_}    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
        ${are_wcells_online}    Check If All Objects Are Online    WNCEL    10 sec
        ...    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
        ${are_lcells_online}    Check If All Objects Are Online    LNCEL    10 sec
        ...    administrativeState=${_Unlocked_}    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
        ...    proceduralState=${_OnAirDone_}
        ${are_nrcells_online}    Check If All Objects Are Online    NRCEL    10 sec
        ...    administrativeState=${_Com_Unlocked_}    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
        ${g_w_status}    Set Variable    "${are_gcells_online}"=="PASS" and "${are_wcells_online}"=="PASS"
        ${l_n_status}    Set Variable    "${are_lcells_online}"=="PASS" and "${are_nrcells_online}"=="PASS"
        Exit For Loop If    ${g_w_status} and ${l_n_status}
        Sleep    ${interval}
    END
    ${g_w_status}    Set Variable    "${are_gcells_online}"=="PASS" and "${are_wcells_online}"=="PASS"
    ${l_n_status}    Set Variable    "${are_lcells_online}"=="PASS" and "${are_nrcells_online}"=="PASS"
    Should Be True     ${g_w_status} and ${l_n_status}

Check_Cells_Status_Without_Ignoring_RAT
    ${dic_rat_objStr}    Create Dictionary    LTE=/MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*
    ...   GSM=/MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*   WCDMA=/MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*
    ${list_ignore_rat}    Evaluate    ${IGNORE_RAT_STATUS}
    Remove From Dictionary    ${dic_rat_objStr}    @{list_ignore_rat}
    ${rats}    Get Dictionary Keys    ${dic_rat_objStr}
    FOR    ${objStr}    IN    @{rats}
        ${are_cells_online}    ${cells_statuses}    Infomodel Check If All Objects From Path Are Online
        ...    /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*    10 sec    ${True}
        ...    administrativeState=Unlocked    blockingState=Unblocked    operationalState=Enabled    proceduralState=OnAirDone
        ...    availabilityStatus=Online
        Should Be True    ${are_cells_online}
    END

Remove_RAT_From_SCF
    [Arguments]    ${src_scf}    ${rat}    ${dst_scf}=tmpSCF.xml
    ${xml}    L_XML.Parse XML    ${src_scf}
    ${tmp_str1}    Set Variable
    ...    {"WCDMA":{"Cell_Mapping":"cmData/managedObject[@class='com.nokia.srbts.mnl:LCELW']",
    ${tmp_str2}    Set Variable
    ...    "Cell":"cmData/managedObject[@class='com.nokia.srbts.wcdma:WNBTS']","Others":[]},
    ${tmp_str3}    Set Variable
    ...    "GSM":{"Cell_Mapping":"cmData/managedObject[@class='com.nokia.srbts.mnl:LCELC']",
    ${tmp_str4}    Set Variable
    ...    "Cell":"cmData/managedObject[@class='com.nokia.srbts.gsm:GNBTS']",
    ${tmp_str5}    Set Variable
    ...    "Others":[{"xpath":"cmData/managedObject[@class='com.nokia.srbts.mnl:FEATGADM']/p[@name='actIpV4BasedPktAbTrs']",
    ${tmp_str6}    Set Variable
    ...   "operate":"SetText","value":"false"}]},"LTE":{"Cell_Mapping":"cmData/managedObject[@class='com.nokia.srbts.mnl:LCELL']",
    ${tmp_str7}    Set Variable
    ...    "Cell":"cmData/managedObject[@class='NOKLTE:LNBTS']",
    ${tmp_str8}    Set Variable
    ...    "Others":[{"xpath":"cmData/managedObject[@class='com.nokia.srbts.eqm:RMOD']/p[@name='linkSpeed']",
    ${tmp_str9}    Set Variable
    ...    "operate":"DelElement","value":""}]},"NR":{"Cell_Mapping":"cmData/managedObject[@class='com.nokia.srbts.mnl:LCELNR']",
    ${tmp_str10}    Set Variable
    ...    "Cell":"cmData/managedObject[@class='com.nokia.srbts.nrbts:NRBTS']",
    ${tmp_str11}    Set Variable
    ...    "Others":[{"xpath":"cmData/managedObject[@class='NOKLTE:LNADJGNB']","operate":"DelElement","value":""}]}}
    ${tmp_str_part1}    Set Variable   ${tmp_str1}${tmp_str2}${tmp_str3}${tmp_str4}${tmp_str5}
    ${tmp_str_part2}    Set Variable   ${tmp_str6}${tmp_str7}${tmp_str8}${tmp_str9}${tmp_str10}${tmp_str11}
    &{dic_RAT_Xpath}    Evaluate    ${tmp_str_part1}${tmp_str_part2}
    ${list_cell_mapping_elements}    L_XML.Get Elements    ${xml}    ${dic_RAT_Xpath["${rat}"]["Cell_Mapping"]}
    ${list_cell_mapping_distName}    Create List
    FOR    ${element}    IN    @{list_cell_mapping_elements}
        ${distName}    L_XML.Get Element Attribute    ${element}    distName
        Append To List    ${list_cell_mapping_distName}    ${distName}
    END
    FOR    ${distName}    IN    @{list_cell_mapping_distName}
        L_XML.Remove Elements    ${xml}    cmData/managedObject[contains(@distName,"${distName}")]
    END
    ${list_cell_elements}    L_XML.Get Elements    ${xml}    ${dic_RAT_Xpath["${rat}"]["Cell"]}
    ${list_cell_distName}    Create List
    FOR    ${element}    IN    @{list_cell_elements}
        ${distName}    L_XML.Get Element Attribute    ${element}    distName
        Append To List    ${list_cell_distName}    ${distName}
    END
    FOR    ${distName}    IN    @{list_cell_distName}
        L_XML.Remove Elements    ${xml}    cmData/managedObject[contains(@distName,"${distName}")]
    END
    L_XML.Save Xml    ${xml}    ${dst_scf}
    Create XML From Old XML And Json    ${dst_scf}    ${dic_RAT_Xpath["${rat}"]}    Others    ${dst_scf}

Remove_MOs_Not_In_Src_XML
    [Arguments]    ${src_xml}    ${dst_xml}    ${new_dst_folder}
    ${file_name}    Fetch From Right    ${dst_xml}    /
    ${xml_src}    Parse XML    ${src_xml}
    ${xml_dst}    Parse XML    ${dst_xml}
    ${es_src}    XML.Get Elements    ${xml_src}    cmData/managedObject
    ${es_dst}    XML.Get Elements    ${xml_dst}    cmData/managedObject
    ${list_all_dist_src}    Create List
    ${list_all_dist_dst}    Create List
    FOR    ${e}    IN    @{es_src}
        ${dist_name}    XML.Get Element Attribute    ${e}    distName
        Append To List    ${list_all_dist_src}    ${dist_name}
    END
    FOR    ${e}    IN    @{es_dst}
        ${dist_name}    XML.Get Element Attribute    ${e}    distName
        Append To List    ${list_all_dist_dst}    ${dist_name}
    END
    Remove Values From List    ${list_all_dist_dst}    @{list_all_dist_src}
    LOG    ${list_all_dist_dst}
    FOR    ${dist_Name}    IN    @{list_all_dist_dst}
        XML.Remove Elements    ${xml_dst}    cmData/managedObject[@distName="${dist_Name}"]    ${True}
    END
    Save XML    ${xml_dst}    ${new_dst_folder}/${file_name}

Remove_RAT_From_SCF_Files_Of_Folder
    [Arguments]    ${rat}    ${scf_folder_path}    ${dst_folder_path}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${list_scf_files}    OperatingSystem.List Files In Directory    ${scf_folder_path}    *.xml
    LOG    ${list_scf_files}    console=${True}
    FOR    ${flie}    IN    @{list_scf_files}
        Remove_RAT_From_SCF    ${scf_folder_path}/${flie}    ${rat}    ${dst_folder_path}/${flie}
    END

Check File Exist On Remote Server Via SSH
    [Arguments]    ${file_path}    ${file_name}    ${should_exist}=${True}    ${remote_ip}=${MPLANE_IP}
    ...    ${user_name}=toor4nsn    ${pwd}=oZPS0POrRieRtu
    SSHLibrary.Open Connection    ${remote_ip}
    SSHLibrary.Login    ${user_name}    ${pwd}
    @{result}    SSHLibrary.Execute Command    cd ${File_path} \ && ls    return_stderr=${True}
    Run keyword if    '${should_exist}'=='${True}'    SSHLibrary.File Should Exist    ${File_path}/${file_name}
    ...    ELSE    SSHLibrary.File Should Not Exist    ${File_path}/${file_name}
    [Teardown]    SSHLibrary.close_connection

Set Flag Of SBTS Swconfig
    [Arguments]    ${flag_name}    ${flag_value}
    [Documentation]    This KW will connect to SBTS via SSH and modify /rom/swconfig.txt, the IP is MPLANE_IP.
    ...    If flag_name is not found in swconfig.txt and flag_value is not ${EMPTY},
    ...    the flag_name shall be added to swconfig.txt.
    ...    If flag_name is found in swconfig.txt and value is not equal to flag_value,
    ...    the old flag in swconfig.txt shall be commented and add a new flag with flag_value to swconfig.txt.
    ...    If flag_name is found in swconfig.txt and flag_value is ${EMPTY},
    ...    the flag_name in swconfig.txt shall be commented.
    ...
    ...    Shall return value of flag_name before modified. If flag_name is not exist before, return ${EMPTY}.
    Check File Exist On Remote Server Via SSH    /rom    swconfig.txt
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@${MPLANE_IP}:/rom/swconfig.txt ${OUTPUT_DIR}/ \
    Sleep    3s
    OperatingSystem.File Should Exist    ${OUTPUT_DIR}/swconfig.txt
    ${file_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/swconfig.txt
    LOG    File content of ${OUTPUT_DIR}/swconfig.txt before modify:\n${file_content}    TRACE
    ${flag_val}    Get Regexp Matches    ${file_content}    \#*\\s*${flag_name}\\s*=\\s*\\d+
    ${count}    Get Length    ${flag_val}
    ${cur_val}    Set Variable    ${EMPTY}
    Return From Keyword If    '${count}'=='${0}' and '${flag_value}'=='${EMPTY}'    ${cur_val}
    : FOR    ${str}    IN    @{flag_val}
    \    ${file_content}    Replace String Using Regexp    ${file_content}    ${str.strip()}    \#${str.strip()}
    \    ${is_comment_line}    Run Keyword And Return Status    Should Start With    ${str.strip()}    \#
    \    Continue For Loop If    ${is_comment_line}
    \    ${val}    Fetch From Right    ${str.strip()}    =
    \    ${cur_val}    Set Variable    ${val.strip()}
    Return From Keyword If    '${cur_val}'=='${flag_value}'    ${cur_val}
    ${replace_str}    Set Variable If    '${cur_val}'=='${EMPTY}' and '${flag_value}'!='${EMPTY}'
    ...    ${flag_name}=${flag_value}    ${EMPTY}
    ${replace_str}    Set Variable If    '${cur_val}'!='${EMPTY}' and '${flag_value}'!='${cur_val}'
    ...    ${flag_name}=${flag_value}    ${replace_str}
    ${replace_str}    Set Variable If    '${flag_value}'=='${EMPTY}'    ${EMPTY}    ${replace_str}
    ${file_content}    Set Variable    ${file_content}\n${replace_str}
    LOG    File content of ${OUTPUT_DIR}/swconfig.txt after modify:\n${file_content}    TRACE
    Create File    ${OUTPUT_DIR}/swconfig_after_modify.txt    ${file_content.strip()}
    Sleep    1s
    OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p oZPS0POrRieRtu scp ${OUTPUT_DIR}/swconfig_after_modify.txt toor4nsn@${MPLANE_IP}:/rom/swconfig.txt \
    [Return]    ${cur_val}

Fetch Cells Mapping From Infomodel Local
    [Arguments]    ${Rat_Type}
    [Documentation]    Fetch cells mapping in SCF and Runtime View
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | Rat_Type | Yes | e.g. GNBTS,WNBTS,LNBTS,NRBTS
    ...    *OUTPUT*
    ...    | cells_mapping|return data dictionary
    &{cells_mapping}    Create Dictionary
    ${cell_RT_path}    Set Variable If    "${Rat_Type}" == "GNBTS"    //GNBTS_R-*/GNBCF_R-*/GNCEL_CONF_M-*/GNCEL_R-*
    ...    "${Rat_Type}" == "WNBTS"    //WNBTS_R-*/WNCEL_R-*    "${Rat_Type}" == "LNBTS"
    ...    //LNBTS_R-*/LNCEL_R-*    "${Rat_Type}" == "NRBTS"    //NRBTS_R-*/NRCELL_R-*
    ${cells_RT_obj}    Query infomodel    get list ${cell_RT_path}
    FOR    ${cell_RT_obj}    IN    @{cells_RT_obj}
        ${cell_RT}    Set Variable    ${cell_RT_obj["dist_name"]}
        ${cell_RT_REF}    Query infomodel    get list ${cell_RT_obj["dist_name"]}/CONF_REF-1
        ${cell_CONF_A}    Set Variable    ${cell_RT_REF[0]["distName"]}
        ${cell_CONF_id}    Fetch From Right    ${cell_CONF_A}    -
        ${cell_CONF}    Set Variable    NRCELL-${cell_CONF_id}
        ${cell_CONF}    Set Variable If    "${Rat_Type}" == "GNBTS"    GNCEL-${cell_CONF_id}    "${Rat_Type}" == "WNBTS"
        ...    WNCEL-${cell_CONF_id}    "${Rat_Type}" == "LNBTS"
        ...    LNCEL-${cell_CONF_id}    "${Rat_Type}" == "NRBTS"    NRCELL-${cell_CONF_id}
        Set To Dictionary    ${cells_mapping}    ${cell_CONF}    ${cell_RT}
    END
    [Return]    ${cells_mapping}

Get RATs State Duration
    [Arguments]    ${retry}    ${retry_interval}    ${delay}=${300}
    [Documentation]    Based on ${EXPECTANT_RATS_STATE_API} determines the expected initial and final status of all rat.
    ...    It starts when the status of any rat changes until the status of all rat return to the expected final status.
    ...    During this period, the status experienced by all rat will be obtained by this kW.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${retry} | Yes | repeat time to get all RAT status until their status become expected final status |
    ...    | ${retry_interval}|Yes |repeat interval to get all RAT status until their status become expected final status|
    ...    | ${delay} | No | time limit to wait for the first status changes |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ${rats_states} | dictionary, all status of RATs |
    ...    | ${is_finished} | boolean, return true if any one RAT status changed and all RAT become expected final status|
    ...
    ...    *EXAMPLE*
    ...    | ${rats_states} | ${is_finished} | Get RATs State Duration | 600 | 1 |
    ...    ${rats_states}={'gsm'=['ALL_ENABLED'],'lte'=['ALL_ENABLED'],'wcdma'=['ALL_ENABLED','ALL_DISABLED',
    ...    'PARTIALLY_DISABLED','ALL_FAILED'],'nr'=['NO_CELLS']}
    ...    ${is_finished}=${True}
    [Timeout]    20 minutes
    Setup RAT Data
    ${rat_status}    Get RAT Status
    ${tmp_lte_states_list}    Create List    ${rat_status['lte']}
    ${tmp_gsm_states_list}    Create List    ${rat_status['gsm']}
    ${tmp_wcdma_states_list}    Create List    ${rat_status['wcdma']}
    ${tmp_nr_states_list}    Create List    ${rat_status['nr']}
    ${is_changed}    Set Variable    ${False}
    FOR    ${step}    IN RANGE    ${0}    ${delay}
        ${rat_status}    Get RAT Status
        Sleep    1s
        ${condition1}    Set Variable
        ...    "${rat_status['lte']}"=="${EXPECTANT_RATS_STATE_API['lte']['original_rat_state']}"
        ${condition2}    Set Variable
        ...    "${rat_status['gsm']}"=="${EXPECTANT_RATS_STATE_API['gsm']['original_rat_state']}"
        ${condition3}    Set Variable
        ...    "${rat_status['wcdma']}"=="${EXPECTANT_RATS_STATE_API['wcdma']['original_rat_state']}"
        ${condition4}    Set Variable
        ...    "${rat_status['nr']}"=="${EXPECTANT_RATS_STATE_API['nr']['original_rat_state']}"
        Continue For Loop If    ${condition1} and ${condition2} and ${condition3} and ${condition4}
        ${is_changed}    Set Variable    ${True}
        Append To List    ${tmp_lte_states_list}    ${rat_status['lte']}
        Append To List    ${tmp_gsm_states_list}    ${rat_status['gsm']}
        Append To List    ${tmp_wcdma_states_list}    ${rat_status['wcdma']}
        Append To List    ${tmp_nr_states_list}    ${rat_status['nr']}
        Exit For Loop
    END
    LOG    ${tmp_lte_states_list}\n${tmp_gsm_states_list}\n${tmp_wcdma_states_list}\n
    Should Be True    ${is_changed}    All RATs did not change status in ${delay} seconds.
    ${is_finished}    Set Variable    ${False}
    FOR    ${step}    IN RANGE    ${0}    ${retry}
        ${rat_status}    Get RAT Status
        Append To List    ${tmp_lte_states_list}    ${rat_status['lte']}
        Append To List    ${tmp_gsm_states_list}    ${rat_status['gsm']}
        Append To List    ${tmp_wcdma_states_list}    ${rat_status['wcdma']}
        Append To List    ${tmp_nr_states_list}    ${rat_status['nr']}
        Sleep    ${retry_interval}
        ${condition1}    Set Variable
        ...    "${rat_status['lte']}"!="${EXPECTANT_RATS_STATE_API['lte']['final_rat_state']}"
        ${condition2}    Set Variable
        ...    "${rat_status['gsm']}"!="${EXPECTANT_RATS_STATE_API['gsm']['final_rat_state']}"
        ${condition3}    Set Variable
        ...    "${rat_status['wcdma']}"!="${EXPECTANT_RATS_STATE_API['wcdma']['final_rat_state']}"
        ${condition4}    Set Variable
        ...    "${rat_status['nr']}"!="${EXPECTANT_RATS_STATE_API['nr']['original_rat_state']}"
        Continue For Loop If    ${condition1} or ${condition2} or ${condition3} or ${condition4}
        ${is_finished}    Set Variable    ${True}
        Exit For Loop
    END
    ${lte_states_list}    Remove Duplicates    ${tmp_lte_states_list}
    ${gsm_states_list}    Remove Duplicates    ${tmp_gsm_states_list}
    ${wcdma_states_list}    Remove Duplicates    ${tmp_wcdma_states_list}
    ${nr_states_list}    Remove Duplicates    ${tmp_nr_states_list}
    ${rats_states}    Create Dictionary    gsm=${gsm_states_list}    lte=${lte_states_list}    wcdma=${wcdma_states_list}
    ...    nr=${nr_states_list}
    [Return]    ${rats_states}    ${is_finished}

Setup RAT Data
    [Documentation]    Based on ${EXPECTANT_RATS_STATE_API} determines the expected initial and final status of all rat.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${initialised}    Run Keyword And Return Status    Should Not Be Equal As Strings    ${EXPECTANT_RATS_STATE_API}
    ...   ${EMPTY}
    Return From Keyword If    ${initialised}
    ${dic_bit_rat_state}    Create Dictionary    0=ALL_ENABLED    1=NO_CELLS    2=PARTIALLY_DISABLED    3=ALL_DISABLED
    ...    4=ALL_FAILED
    ${rat_list}    Create List    nr    lte    wcdma    gsm
    ${EXPECTANT_RATS_STATE_API}    Create Dictionary
    FOR    ${i}    IN RANGE    0    4
        ${not_need_add}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${dic_bit_rat_state}
        ...    ${RAT_BIT[${i}]}
        Continue For Loop If    ${not_need_add}
        ${dic_tmp}    Create Dictionary    original_rat_state=${dic_bit_rat_state['${RAT_BIT[${i}]}']}
        ...    final_rat_state=${dic_bit_rat_state['${RAT_BIT[${i+4}]}']}
        Set To Dictionary    ${EXPECTANT_RATS_STATE_API}    ${rat_list[${i}]}    ${dic_tmp}
    END
    LOG    ${EXPECTANT_RATS_STATE_API}
    Set Suite Variable    ${EXPECTANT_RATS_STATE_API}
    ${GNB_CU_TYPE}    Get_gNbCuType
    Set Suite Variable    ${GNB_CU_TYPE}

Get RAT Status
    [Arguments]    ${alias}=default
    [Documentation]    Return a dictionary, example: {u'wcdma': u'ALL_ENABLED', u'nr': u'NO_CELLS', u'gsm': u'ALL_ENABLED',
    ...    u'lte': u'ALL_ENABLED'}
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${dic_cur_bts_info}    coam.get_bts_info    connection=${alias}
    ${ratState}    Pop From Dictionary    ${dic_cur_bts_info}    ratState
    [Return]    ${ratState}

Get_gNbCuType
    [Documentation]    Get value of parameter 'gNbCuType' of SBTS.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${dic_cur_bts_info}    coam.get_bts_info
    ${gNbCuType}    Pop From Dictionary    ${dic_cur_bts_info}    gNbCuType    SA
    [Return]    ${gNbCuType}

Check IP Is Pingable
    [Arguments]    ${ip}    ${ping_count}=1    ${ping_timeout}=2    ${expect_pingable}=${True}
    [Documentation]    This KW is for linux system only
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c ${ping_count} -w ${ping_timeout} ${ip}
    ${ping_status}    Evaluate    ${rc}==${0}
    Should Be Equal    ${ping_status}    ${expect_pingable}

Wait Until SBTS Disconnected
    [Arguments]    ${timeout}=300s
    [Documentation]    This KW is for linux system only.
    ...    Wait until 192.168.255.129 is not ping able from local PC.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    Wait Until Keyword Succeeds    ${timeout}    1s    Check IP Is Pingable    192.168.255.129    expect_pingable=${False}

Check SBTS Has Restarted Successful
    [Documentation]    When the 192.168.255.129 fails to Ping, it is judged that SBTS starts to restart
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    LOG    Check SBTS Has Restarted Successful    console=${True}
    Wait Until SBTS Disconnected
    LOG    SBTS is disconnected.Wait for SBTS online.    console=${True}
    Wait Until Keyword Succeeds    20 min    60 sec    Check SBTS SMOD RMOD Cells Alarms

Check RATs Has Reseted Successful
    [Arguments]    ${RAT_list}    ${time_out}=${600}    ${retry_interval}=${1}    ${expected_action}=reset   @{exceptive_RATs}
    [Documentation]    Check if the RATs given are reseted successful.
    ...    Fail if the RATs did not reseted successful.
    ...    Fail if service of any RATs not given has been down during the process of checking.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    LOG    Check RATs Has Reseted Successful    console=${True}
    Return From Keyword If    "${RAT_list.__len__()}"=="${0}"
    ${retry}    Evaluate    ${time_out}/${retry_interval}
    ${rats_states}    ${is_finished}    Get RATs State Duration    ${retry}    ${retry_interval}
    Should Be True    ${is_finished}
    FOR    ${rat}    IN    @{RAT_list}
        ${lower_rat}    Convert To Lower Case    ${rat}
        ${state_list}    Get From Dictionary    ${rats_states}    ${lower_rat}
        Comment    List Should Contain Value    ${state_list}    PARTIALLY_DISABLED
        List Should Contain Value    ${state_list}    ALL_DISABLED
        Run Keyword If    '${expected_action}'=='reset'    List Should Contain Value    ${state_list}    ALL_FAILED
        Append To List    ${exceptive_RATs}    ${lower_rat}
    END
    #NR RAT service depend on LTE RAT if gNbCuType is NSA
    ${has_LTE}    Get Count    ${RAT_list}    LTE
    Run Keyword If    '${GNB_CU_TYPE}'=='NSA' and '${has_LTE}' == '${1}'    Append To List    ${exceptive_RATs}    nr
    FOR    ${rat}    IN    @{exceptive_RATs}
        Remove From Dictionary    ${rats_states}    ${rat}
    END
    ${other_rats}    Get Dictionary Keys    ${rats_states}
    FOR    ${rat}    IN    @{other_rats}
        ${state_list}    Get From Dictionary    ${rats_states}    ${rat}
        Comment    List Should Not Contain Value    ${state_list}    PARTIALLY_DISABLED
        List Should Not Contain Value    ${state_list}    ALL_DISABLED
        List Should Not Contain Value    ${state_list}    ALL_FAILED
    END

Get Cells State Duration
    [Arguments]    ${retry}    ${retry_interval}    ${dic_state_fields}=${None}    ${delay}=${300}
    [Documentation]    Based on ${dic_state_fields} determines the expected initial status of all cells.
    ...   It starts when the status of any cell changes until the status of all cell return to the expected initial status.
    ...   During this period, the status experienced by all cells will be obtained by this kW.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${retry} | Yes | repeat time to get all cell status until their status become expected final status|
    ...    | ${retry_interval}|Yes|repeat interval to get all cell status until their status become expected final status|
    ...    | ${dic_state_fields} |NO|Default is {'availabilityStatus': 'Online', 'operationalState': 'Enabled'}
    ...    while given value is ${None} |
    ...    | ${delay} | No | time limit to wait for the first status changes |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ${cells_states} | list, all status of cells, |
    ...    | ${is_finished} | boolean, return true if no cell status changed within the delay time, or any one cell status
    ...    changed but all cell status return to the expected initial status |
    ...
    ...    *EXAMPLE*
    ...    | ${cells_states} | ${is_finished} | Get Cells State Duration | 600 | 1 |
    ...    ${cells_states}=[{'MRBTS-1810/LNBTS-3753/LNCEL-1': {'administrativeState': 'Unlocked','availabilityStatus':
    ...    'Offline','blockingState': 'Unblocked','operationalState': 'Disabled','usageState': 'Idle'}},
    ...    {'MRBTS-1810/LNBTS-3753/LNCEL-1': {'administrativeState': 'Unlocked','availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Idle'}}]
    ...    ${is_finished}=${True}
    ...
    ...    | ${cells_states} | ${is_finished} | Get Cells State Duration | 600 | 1 |
    ...    ${cells_states}=[]
    ...    ${is_finished}=${True}
    ${default_dic_state_fields}    Create Dictionary    availabilityStatus=Online    operationalState=Enabled
    ${dic_state_fields}    Set Variable If    ${dic_state_fields} is None    ${default_dic_state_fields}
    ...    ${dic_state_fields}
    ${diff_cells}    Create List
    ${cells_states}    Create List
    ${is_finished}    Set Variable    ${False}
    ${is_changed}    Set Variable    ${False}
    ${scf_runtime_name_mapper}    ${all_cell_status}    Get Current Name And Status Of All Cells
    ${cells_states_unexpected}    Check Cells States As Expected    ${all_cell_status}    ${default_dic_state_fields}
    Should Be Empty    ${cells_states_unexpected}    Some cells initial state are not as expected.
    Sleep    1s
    FOR    ${step}    IN RANGE    ${0}    ${delay}
        ${tmp_scf_runtime_name_mapper}    ${tmp_all_cell_status}    Get Current Name And Status Of All Cells
        ${tmp_diff_cells1}    ${tmp_diff_cells2}    Compare Cells States    ${tmp_all_cell_status}    ${all_cell_status}
        ${not_empty_1}    Run Keyword And Return Status    Should Not Be Empty    ${tmp_diff_cells1}
        ${not_empty_2}    Run Keyword And Return Status    Should Not Be Empty    ${tmp_diff_cells2}
        Run Keyword If    ${not_empty_1}    Append To List    ${diff_cells}    ${tmp_diff_cells1}
        Run Keyword If    ${not_empty_2}    Append To List    ${diff_cells}    ${tmp_diff_cells2}
        ${is_changed}    Run Keyword And Return Status    Should Not Be Empty    ${diff_cells}
        Exit For Loop If    ${is_changed}
        Sleep    ${retry_interval}
    END
    Return From Keyword If    not ${is_changed}    ${cells_states}    ${True}
    FOR    ${step}    IN RANGE    ${0}    ${retry}
        ${tmp_scf_runtime_name_mapper}    ${tmp_all_cell_status}    Get Current Name And Status Of All Cells
        ${cells_unexpected}    Check Cells States As Expected    ${tmp_all_cell_status}    ${default_dic_state_fields}
        ${is_finished}    Run Keyword And Return Status    Should Be Empty    ${cells_unexpected}
        Exit For Loop If    ${is_finished}
        Append To List    ${diff_cells}    ${cells_unexpected}
        Sleep    ${retry_interval}
    END
    ${cells_states}    Remove Duplicates    ${diff_cells}
    [Return]    ${cells_states}    ${is_finished}

Compare Cells States
    [Arguments]    ${dic_cells_states_1}    ${dic_cells_states_2}
    [Documentation]    Compare the states of all cells and return different cells and their states
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${dic_cells_states_1} | Yes | states of all cells |
    ...    | ${dic_cells_states_2} | Yes | states of all cells |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ${states_of_diff_cells_1} | dictionary, different states in ${dic_cells_states_1} |
    ...    | ${states_of_diff_cells_2} | dictionary, different states in ${dic_cells_states_2} |
    ...
    ...    *EXAMPLE*
    ...    | ${tmp_scf_runtime_name_mapper} | ${tmp_all_cell_status} | Get Current Name And Status Of All Cells |
    ...   | ${tmp_diff_cells1} | ${tmp_diff_cells2} | Compare Cells States | ${tmp_all_cell_status} | ${all_cell_status} |
    ...   ${tmp_scf_runtime_name_mapper} = {'MRBTS-1810/LNBTS-3753/LNCEL-1': {'administrativeState':
    ...   'Unlocked','availabilityStatus': 'Offline','blockingState': 'Unblocked','operationalState': 'Disabled','usageState':
    ...   'Idle'},'MRBTS-1810/LNBTS-3753/LNCEL-2': {'administrativeState': 'Unlocked','availabilityStatus': 'Online',
    ...   'blockingState':'Unblocked','operationalState': 'Enabled','usageState': 'Idle'}}
    ...   ${tmp_all_cell_status} = {'MRBTS-1810/LNBTS-3753/LNCEL-1': {'administrativeState': 'Unlocked','availabilityStatus':
    ...   'Online','blockingState': 'Unblocked','operationalState':'Enabled','usageState': 'Idle'},
    ...   'MRBTS-1810/LNBTS-3753/LNCEL-2': {'administrativeState': 'Unlocked','availabilityStatus': 'Online',
    ...    'blockingState':'Unblocked','operationalState': 'Enabled','usageState': 'Idle'}}
    ...    ${tmp_diff_cells1} = {u'MRBTS-1810/LNBTS-3753/LNCEL-1': {u'usageState': u'Idle', u'administrativeState':
    ...   u'Unlocked', u'operationalState': u'Disabled', u'availabilityStatus': u'Offline', u'blockingState': u'Unblocked'}}
    ...    ${tmp_diff_cells2} = {u'MRBTS-1810/LNBTS-3753/LNCEL-1': {u'usageState': u'Idle', u'administrativeState':
    ...    u'Unlocked', u'operationalState': u'Enabled', u'availabilityStatus': u'Online', u'blockingState': u'Unblocked'}}
    ${cell_list_1}    Get Dictionary Keys    ${dic_cells_states_1}
    ${cell_list_2}    Get Dictionary Keys    ${dic_cells_states_2}
    ${tmp_cell_list_1}    Copy List    ${cell_list_1}
    ${tmp_cell_list_2}    Copy List    ${cell_list_2}
    Remove Values From List    ${tmp_cell_list_1}    @{cell_list_2}
    Remove Values From List    ${tmp_cell_list_2}    @{cell_list_1}
    ${diff_cells}    Combine Lists    ${tmp_cell_list_1}    ${tmp_cell_list_2}
    FOR    ${cell}    IN    @{cell_list_1}
        ${is_equal}    Run Keyword And Return Status    Dictionaries Should Be Equal    ${dic_cells_states_1["${cell}"]}
        ...    ${dic_cells_states_2["${cell}"]}
        Continue For Loop If    ${is_equal}
        Append To List    ${diff_cells}    ${cell}
    END
    ${states_of_diff_cells_1}    Create Dictionary
    ${states_of_diff_cells_2}    Create Dictionary
    FOR    ${cell}    IN    @{diff_cells}
        ${dic1}    Pop From Dictionary    ${dic_cells_states_1}    ${cell}    ${None}
        ${dic2}    Pop From Dictionary    ${dic_cells_states_2}    ${cell}    ${None}
        Run Keyword If    ${dic1} is not None    Set To Dictionary    ${states_of_diff_cells_1}    ${cell}=${dic1}
        Run Keyword If    ${dic2} is not None    Set To Dictionary    ${states_of_diff_cells_2}    ${cell}=${dic2}
    END
    [Return]    ${states_of_diff_cells_1}    ${states_of_diff_cells_2}

Check Cells States As Expected
    [Arguments]    ${all_cell_status}    ${dic_state_fields}=${None}
    [Documentation]    Check Cells States As Expected
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${all_cell_status} | Yes | states of all cells |
    ...    | ${dic_state_fields} | No | Default is {'availabilityStatus': 'Online', 'operationalState': 'Enabled'}
    ...    while given value is ${None} |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ${cells_states_unexpected} | dictionary, unexpected different states |
    ...
    ...    *EXAMPLE*
    ...    | ${scf_runtime_name_mapper} | ${all_cell_status} | Get Current Name And Status Of All Cells |
    ...    | ${cells_states_unexpected}|Check Cells States As Expected|${all_cell_status}|${default_dic_state_fields}|
    ...    ${all_cell_status} = {'MRBTS-1810/GNBTS-1/GNBCF-1/GNCEL-1': {'administrativeState': 'Unlocked',
    ...   'availabilityStatus': 'Online','blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Active'}}
    ...    ${cells_states_unexpected} = {}
    #yuki as log1.html ${default_dic_state_fields}    Create Dictionary    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    ${default_dic_state_fields}    Create Dictionary    operationalState=ENABLED    blockingState=UNBLOCKED
    ${dic_state_fields}    Set Variable If    ${dic_state_fields} is None   ${default_dic_state_fields}   ${dic_state_fields}
    ${cells}    Get Dictionary Keys    ${all_cell_status}
    ${cells_states_unexpected}    Create Dictionary
    FOR    ${cell}    IN    @{cells}
        ${is_as_expected}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary
        ...    ${all_cell_status["${cell}"]}    ${default_dic_state_fields}
        Continue For Loop If    ${is_as_expected}
        Set To Dictionary    ${cells_states_unexpected}    ${cell}=${all_cell_status["${cell}"]}
    END
    [Return]    ${cells_states_unexpected}

Check Cells States Has Changed In Time
    [Arguments]    ${name_of_cell_list}    ${timeout}=300    ${inter_val}=1    ${dic_state_fields}=${None}
    [Documentation]    Check states of given cells has changed and finally return to state as ${dic_state_fields} in time
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${name_of_cell_list} | Yes | states of all cells |
    ...    | ${timeout} | No | Default is 300 |
    ...    | ${inter_val} \ | No | Default is 1 |
    ...    | ${dic_state_fields} | No | Default is {'availabilityStatus': 'Online', 'operationalState': 'Enabled'}
    ...    while given value is ${None} |
    ...
    ...    *EXAMPLE*
    ...    | Check Cells States Has Changed In Time | ${ACTION_OBJECT_LIST} | 180 |
    ...    ${ACTION_OBJECT_LIST}=['MRBTS-1810/LNBTS-3753/LNCEL-1']
    ${default_dic_state_fields}    Create Dictionary    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    ${dic_state_fields}   Set Variable If    ${dic_state_fields} is None    ${default_dic_state_fields}    ${dic_state_fields}
    ${cells_states}    ${is_finished}    Get Cells State Duration    ${timeout}    ${inter_val}    ${dic_state_fields}
    ${list_state_changed_cells}    Create List
    FOR    ${cell_states}    IN    @{cells_states}
        ${cells}    Get Dictionary Keys    ${cell_states}
        Append To List    ${list_state_changed_cells}    @{cells}
    END
    ${list_state_changed_cells}    Remove Duplicates    ${list_state_changed_cells}
    Sort List    ${list_state_changed_cells}
    Sort List    ${name_of_cell_list}
    Lists Should Be Equal    ${list_state_changed_cells}    ${name_of_cell_list}    msg=Unexpected cells states changed.
    Should Be True    ${is_finished}    Some cells final state are not as expected.

Check No Cells States Has Changed In Time
    [Arguments]    ${timeout}=60    ${inter_val}=1    ${dic_state_fields}=${None}
    [Documentation]    Check that all cells remain in a state as ${dic_state_fields} for a period of time
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${timeout} | No | Default is 300 |
    ...    | ${inter_val} \ | No | Default is 1 |
    ...    | ${dic_state_fields} | No | Default is {'availabilityStatus': 'Online', 'operationalState': 'Enabled'}
    ...    while given value is ${None} |
    ...
    ...    *EXAMPLE*
    ...    | Check No Cells States Has Changed In Time | 300 |
    ${default_dic_state_fields}    Create Dictionary    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    ${dic_state_fields}    Set Variable If    ${dic_state_fields} is None    ${default_dic_state_fields}    ${dic_state_fields}
    ${cells_states}    ${is_finished}    Get Cells State Duration    1    ${inter_val}    ${dic_state_fields}    ${timeout}
    Should Be True    ${is_finished}    Some cells final state are not as expected.
    Should Be Empty    ${cells_states}    Some cells state changed.

Get Cell IDs for All RAT
    ${LTE_cell_ids}    coam.get_ids_for_all    LNCEL
    ${GSM_cell_ids}    coam.get_ids_for_all    GNCEL
    ${WCDMA_cell_ids}    coam.get_ids_for_all    WNCEL
    ${NR_cell_ids}    coam.get_ids_for_all    NRCEL
    Set Test Variable    ${LTE_cell_ids}
    Set Test Variable    ${GSM_cell_ids}
    Set Test Variable    ${WCDMA_cell_ids}
    Set Test Variable    ${NR_cell_ids}