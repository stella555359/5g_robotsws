*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com
...    Theese KWs should be unexposed to user. It is internally used to collect logs for common BTS.


Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Process
Library           String
Library           taf.collectors.core                   WITH NAME    log_module_core
Variables         ../config/shared_variables.py

*** Variables ***
${CLOUDRAN_TEMPLATE_PATH}     ${CURDIR}/../config/log_parameters_template.yml
${CLASSICAL_TEMPLATE_PATH}    ${CURDIR}/../config/classical_log_parameters_template.yml

*** Keywords ***
################################ Prepare log direcotry for log module #################################
_CommonBTS.Create Log Directory For Log Module
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create the Suite-level or Test-level log directory for the log module.
    ...        - The Suite-level log directory is named ${LOG_MODULE_SUITE_LOG_DIRECTORY}.
    ...        - The Test-level log directory is named ${LOG_MODULE_LOG_DIRECTORY}.
    ...        - If possible, it first reuses the Suite-level/Test-level log directory in RRM/OAM/SISO CA.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Create Log Directory For Log Module
    ...
    ${execution_level}=    _CommonBTS.Determine Execution Level
    Run Keyword If    '${execution_level}' == 'SUITE'
    ...    _CommonBTS.Create Suite Level Log Directory For Log Module
    ...    ELSE IF    '${execution_level}' == 'TEST CASE'
    ...    _CommonBTS.Create Test Level Log Directory For Log Module


################################ Supported #################################
_CommonBTS.Create Suite Level Log Directory For Log Module
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create the Suite-level log directory for the log module.
    ...        - The Suite-level log directory is named ${LOG_MODULE_SUITE_LOG_DIRECTORY}.
    ...        - If possible, it first reuses the Suite-level log directory in RRM/OAM/SISO CA.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Create Log Directory For Log Module
    ...
    ${exists}=    Run Keyword And Return Status    Variable Should Exist    ${LOG_MODULE_SUITE_LOG_DIRECTORY}
    return from keyword if    ${exists}    ${True}

    ${is_reused}=    _CommonBTS.Reuse Suite Level Log Directory From Multiple CA
    return from keyword if    ${is_reused}    ${True}

    _CommonBTS.Create New Suite Log Directory For Log Module

_CommonBTS.Create Test Level Log Directory For Log Module
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create the Test-level log directory for the log module.
    ...        - The Test-level log directory is named ${LOG_MODULE_LOG_DIRECTORY}.
    ...        - If possible, it first reuses the Test-level test log directory in RRM/OAM/SISO CA.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Create Log Directory For Log Module
    ...
    ${exists}=    Run Keyword And Return Status    Variable Should Exist    ${LOG_MODULE_LOG_DIRECTORY}
    return from keyword if    ${exists}    ${True}

    ${is_reused}=    _CommonBTS.Reuse Test Level Test Log Directory From Multiple CA
    return from keyword if    ${is_reused}    ${True}

    _CommonBTS.Create New Log Directory For Log Module

_CommonBTS.Reuse Test Level Test Log Directory From Multiple CA
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to reuse the Test-level test log directory in RRM/OAM/SISO CA.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Test Log Directory Exists
    ...
    # RRM CA
    ${rrm_exists}=    _CommonBTS.Reuse Test Level Test Log Directory    ${RRM_CA_test_log_directory_variable_name}
    return from keyword if    ${rrm_exists}    ${True}
    # OAM CA
    ${oam_exists}=    _CommonBTS.Reuse Test Level Test Log Directory    ${OAM_CA_test_log_directory_variable_name}
    return from keyword if    ${oam_exists}    ${True}
    # SISO CA
    ${siso_exists}=    _CommonBTS.Reuse Test Level Test Log Directory    ${SISO_CA_test_log_directory_variable_name}
    return from keyword if    ${siso_exists}    ${True}
    [Return]    ${False}

_CommonBTS.Reuse Test Level Test Log Directory
    [Arguments]    ${log_dir_var_name}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to reuse the Test-level test log directory in RRM/OAM/SISO CA exists.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Test Log Directory Exists
    ...
    ${exists}=    Run Keyword And Return Status    Variable Should Exist    ${${log_dir_var_name}}
    Run Keyword If    '${exists}'=='${True}'    _CommonBTS.Set Log Directory Variable For Log Module
    ...    ${${log_dir_var_name}}
    [Return]    ${exists}

_CommonBTS.Set Log Directory Variable For Log Module
    [Arguments]    ${log_dir}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to set ${LOG_MODULE_LOG_DIRECTORY}.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_dir | Yes |  |
    ...    *Example:*
    ...        - _CommonBTS.Set Log Directory Variable For Log Module
    ...
    Set Test Variable    ${LOG_MODULE_LOG_DIRECTORY}    ${log_dir}
    Create directory     ${LOG_MODULE_LOG_DIRECTORY}

_CommonBTS.Create New Log Directory For Log Module
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create new log riectory for the log module.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Create New Log Directory For Log Module
    ...
    # RRM CA
    ${is_success}=    _CommonBTS.Create Log Directory With CA Suite Log Directory
    ...    ${RRM_CA_suite_log_directory_variable_name}
    return from keyword if    ${is_success}    ${True}
    # OAM CA
    ${is_success}=    _CommonBTS.Create Log Directory With CA Suite Log Directory
    ...    ${OAM_CA_suite_log_directory_variable_name}
    return from keyword if    ${is_success}    ${True}
    # SISO CA
    ${is_success}=    _CommonBTS.Create Log Directory With CA Suite Log Directory
    ...    ${SISO_CA_suite_log_directory_variable_name}
    return from keyword if    ${is_success}    ${True}

    _CommonBTS.Create Log Directory From Scratch

_CommonBTS.Create Log Directory With CA Suite Log Directory
    [Arguments]    ${suite_log_dir_var_name}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create new log riectory for the log module based on suite log directory.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | suite_log_dir | Yes |  |
    ...    *Returns:*
    ...        - True: Succeeded to create
    ...        - False: Failed to create
    ...    *Example:*
    ...        - _CommonBTS.Create Log Directory With CA Suite Log Directory
    ...
    ${exists}=    Run Keyword And Return Status
    ...    Variable Should Exist    ${${suite_log_dir_var_name}}
    return from keyword if    not ${exists}    ${False}

    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${case_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_directory}    Join path    ${${suite_log_dir_var_name}}    ${case_name}_${timestamp}
    _CommonBTS.Set Log Directory Variable For Log Module    ${case_directory}
    [Return]    ${True}

_CommonBTS.Create Log Directory From Scratch
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create new log riectory for the log module from scratch.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Create Log Directory From Scratch
    ...
    ${suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${suite_directory}    Join path    ${OUTPUT_DIR}    ${suite_name}_${timestamp}
    Create directory    ${suite_directory}

    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${case_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_directory}    Join path    ${suite_directory}    ${case_name}_${timestamp}
    _CommonBTS.Set Log Directory Variable For Log Module    ${case_directory}

_CommonBTS.Reuse Suite Level Log Directory From Multiple CA
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to reuse the Suite-level test log directory in RRM/OAM/SISO CA.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Reuse Suite Level Log Directory From Multiple CA
    ...
    # RRM CA
    ${rrm_exists}=    _CommonBTS.Reuse Suite Level Log Directory    ${RRM_CA_suite_log_directory_variable_name}
    return from keyword if    ${rrm_exists}    ${True}
    # OAM CA
    ${oam_exists}=    _CommonBTS.Reuse Suite Level Log Directory    ${OAM_CA_suite_log_directory_variable_name}
    return from keyword if    ${oam_exists}    ${True}
    # SISO CA
    ${siso_exists}=    _CommonBTS.Reuse Suite Level Log Directory    ${SISO_CA_suite_log_directory_variable_name}
    return from keyword if    ${siso_exists}    ${True}
    [Return]    ${False}

_CommonBTS.Reuse Suite Level Log Directory
    [Arguments]    ${log_dir_var_name}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to reuse the Suite-level log directory in RRM/OAM/SISO CA exists.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Reuse Suite Level Log Directory
    ...
    ${exists}=    Run Keyword And Return Status    Variable Should Exist    ${${log_dir_var_name}}
    Run Keyword If    '${exists}'=='${True}'    _CommonBTS.Set Suite Log Directory Variable For Log Module
    ...    ${${log_dir_var_name}}
    [Return]    ${exists}

_CommonBTS.Set Suite Log Directory Variable For Log Module
    [Arguments]    ${log_dir}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to set ${LOG_MODULE_SUITE_LOG_DIRECTORY}.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_dir | Yes |  |
    ...    *Example:*
    ...        - _CommonBTS.Set Log Directory Variable For Log Module
    ...
    set suite variable    ${LOG_MODULE_SUITE_LOG_DIRECTORY}    ${log_dir}
    Create directory      ${LOG_MODULE_SUITE_LOG_DIRECTORY}

_CommonBTS.Create New Suite Log Directory For Log Module
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to create new suite-level log riectory for the log module.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Create New Suite Log Directory For Log Module
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${suite_directory}    Join path    ${OUTPUT_DIR}    log_module_${timestamp}
    _CommonBTS.Set Suite Log Directory Variable For Log Module    ${suite_directory}

_CommonBTS.Determine Execution Level
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to determine current execution level.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Determine Execution Level
    ...
    ${test_name}=    Get Variable Value    ${TEST NAME}    None
    ${level}=    Set Variable If    '${test_name}' != 'None'    TEST CASE    SUITE
    [Return]    ${level}

_CommonBTS.Get Log Directory For Log Module By Level
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get the log directory for log module based on the execution level.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Example:*
    ...        - _CommonBTS.Get Log Directory For Log Module By Level
    ...
    ${execution_level}=    _CommonBTS.Determine Execution Level
    ${log_dir_by_level}    Set Variable If    '${execution_level}' == 'SUITE'    ${LOG_MODULE_SUITE_LOG_DIRECTORY}
    ...    '${execution_level}' == 'TEST CASE'    ${LOG_MODULE_LOG_DIRECTORY}
    [Return]    ${log_dir_by_level}


################################ Prepare dcap-related parameters #################################
_CommonBTS.prepare_dcap_server_from_dict_params
    [Arguments]    ${dict_argument}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare dict_argument.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | dict_argument | Yes | { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    *Example:*
    ...        - _CloudRAN.prepare_tti_dict_params
    ...
    [Return]    ${dict_argument["dcap_server"]}

_CommonBTS.prepare_dcap_argument_from_dict_params
    [Arguments]    ${dict_argument}    ${argument_key}=argument
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare dcap arguments from the dict paramters.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | dict_argument | Yes | { dcap_server: {host: x, username: x, password: x, port: x}, argument: {} } |
    ...    *Example:*
    ...        - _CommonBTS.prepare_dcap_argument_from_dict_params
    ...
    ${is_input}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${dict_argument}    ${argument_key}
    ${result}=    Set Variable If
    ...    ${is_input}    ${dict_argument["${argument_key}"]}    ${None}
    [Return]    ${result}


################################ Prepare template parameters #################################
_CommonBTS.get_params_from_template
    [Arguments]    ${key_chain}
    ...            ${path_to_template}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to get parameters from a template file. It supports varialbe numbers of keys.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | key_chain | Yes | a list. Varialbe numbers of keys |
    ...    | path_to_template | Yes | the path to the template file |
    ...    *Example:*
    ...        - _CommonBTS.get_params_from_template
    ...
    ${template}=    utility.load_yaml_to_dict    ${path_to_template}
    &{params}=    Create Dictionary
    FOR    ${index}    ${key}    IN ENUMERATE    @{key_chain}
         ${params}=    Run Keyword If    ${index}==${0}    Set Variable    ${template["${key}"]}
         ...    ELSE    Set Variable    ${params["${key}"]}
    END
    [Return]    ${params}

_CommonBTS.prepare_template_params
    [Arguments]    ${log_type}
    ...            ${path_to_template}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to prepare template parameters.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | log_type | Yes | bip, wireshark, tti, syslog, snapshot, etc. |
    ...    *Example:*
    ...        - _CommonBTS.prepare_template_params
    ...
    ${key_chain}=    create list    log_params    ${log_type}
    ${template_params}=    _CommonBTS.get_params_from_template    ${key_chain}    ${path_to_template}
    [Return]    ${template_params}

_CommonBTS.Check And Lookup Values
    [Arguments]   ${log_type}    ${product_type}    ${dict_argument}    ${argument_key}=argument
    ${dcap_argument}   Create Dictionary
    ${values}=    Create List
    ${keys}=    Evaluate    '${log_type}'.split('+')
    FOR    ${key}    IN    @{keys}
        Run Keyword If    '${key}' in ${${product_type}_log_type_dict}
        ...    Append To List    ${values}    ${${product_type}_log_type_dict}[${key}]
        IF    "${key}" == "snapshot" and "${product_type}" in ["gnb", "enb"]
            ${bts_custom_profile_list}    Create List    immediateSnapshot
            Set To Dictionary    ${dcap_argument}    bts_custom_profile=${bts_custom_profile_list}
        END
    END
    Set To Dictionary    ${dcap_argument}    ${product_type}_custom_profile=${values}
    Set To Dictionary    ${dict_argument}    ${argument_key}=${dcap_argument}
